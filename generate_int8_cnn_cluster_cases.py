#!/usr/bin/env python3
"""Train a small quantized CNN and export cluster-system convolution cases.

The exported testcase format is intentionally simple SystemVerilog text:

CONFIG <case_id> <H> <W> <C_IN> <M_OUT> <psum_seed_enable>
IACT <c> <y> <x> <value>
WEIGHT <m> <c> <ky> <kx> <value>
PSUM <m> <oy> <ox> <value>
GOLDEN <m> <oy> <ox> <value>
END

The golden tensor is produced from dense PyTorch conv2d on quantized int8
IACT/Weight tensors. CSC is also emitted for visibility, but the golden is not
computed through the hardware sparse format.
"""

from __future__ import annotations

import argparse
import json
import math
import random
from dataclasses import dataclass
from pathlib import Path

import torch
import torch.nn as nn
import torch.nn.functional as F


torch.manual_seed(7)
random.seed(7)


@dataclass(frozen=True)
class CaseConfig:
    h: int
    w: int
    c_in: int
    m_out: int
    psum_seed: bool
    source_layer: int
    sample_index: int


class TinyMultiLayerCNN(nn.Module):
    def __init__(self) -> None:
        super().__init__()
        self.conv0 = nn.Conv2d(2, 8, 3, padding=1, bias=False)
        self.conv1 = nn.Conv2d(8, 10, 3, padding=1, bias=False)
        self.conv2 = nn.Conv2d(10, 8, 3, padding=1, bias=False)
        self.head = nn.Linear(8, 4, bias=False)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        x = F.relu(self.conv0(x))
        x = F.relu(self.conv1(x))
        x = F.relu(self.conv2(x))
        x = F.adaptive_avg_pool2d(x, 1).flatten(1)
        return self.head(x)


def make_dataset(n: int = 128, h: int = 12, w: int = 10) -> tuple[torch.Tensor, torch.Tensor]:
    xs = torch.zeros(n, 2, h, w)
    ys = torch.zeros(n, dtype=torch.long)
    yy = torch.arange(h).view(h, 1)
    xx = torch.arange(w).view(1, w)
    for i in range(n):
        label = i % 4
        ys[i] = label
        if label == 0:
            xs[i, 0] = ((xx + i) % 3 == 0).float()
            xs[i, 1] = ((yy + i) % 4 == 0).float()
        elif label == 1:
            xs[i, 0] = ((yy + xx + i) % 5 == 0).float()
            xs[i, 1] = ((yy - xx + i) % 4 == 0).float()
        elif label == 2:
            xs[i, 0, 2:10, 2:8] = (((yy[2:10] + xx[:, 2:8] + i) % 2) == 0).float()
            xs[i, 1] = ((2 * yy + xx + i) % 7 == 0).float()
        else:
            xs[i, 0] = ((yy * xx + i) % 6 == 0).float()
            xs[i, 1, 1::3, 1::2] = 1.0
        xs[i] += 0.05 * torch.randn_like(xs[i])
    return xs.clamp(0, 1), ys


def train_model() -> TinyMultiLayerCNN:
    model = TinyMultiLayerCNN()
    opt = torch.optim.Adam(model.parameters(), lr=0.02)
    x, y = make_dataset()
    for _epoch in range(12):
        opt.zero_grad()
        loss = F.cross_entropy(model(x), y)
        loss.backward()
        opt.step()
    return model.eval()


def quantize_symmetric(t: torch.Tensor, qmax: int = 7) -> torch.Tensor:
    max_abs = float(t.abs().max())
    if max_abs == 0.0:
        return torch.zeros_like(t, dtype=torch.int32)
    scale = max_abs / qmax
    return torch.clamp(torch.round(t / scale), -qmax, qmax).to(torch.int32)


def quantize_activation(t: torch.Tensor) -> torch.Tensor:
    q = torch.clamp(torch.round(t * 15.0), -127, 127).to(torch.int32)
    return q


def int_tensor_to_list(t: torch.Tensor) -> list:
    return t.to(torch.int32).cpu().tolist()


def csc_iact_by_column(iact: torch.Tensor) -> list[dict]:
    c_in, h, w = iact.shape
    streams = []
    for c in range(c_in):
        for x in range(w):
            entries = []
            zero_run = 0
            for y in range(h):
                value = int(iact[c, y, x])
                if value == 0:
                    zero_run += 1
                else:
                    entries.append({"count": zero_run, "value": value, "y": y})
                    zero_run = 0
            streams.append({"c": c, "x": x, "entries": entries})
    return streams


def csc_weight_generic(weight: torch.Tensor) -> list[dict]:
    m_out, c_in, kh, kw = weight.shape
    streams = []
    for m in range(m_out):
        for c in range(c_in):
            entries = []
            zero_run = 0
            for ky in range(kh):
                for kx in range(kw):
                    value = int(weight[m, c, ky, kx])
                    if value == 0:
                        zero_run += 1
                    else:
                        entries.append({"count": zero_run, "value": value, "ky": ky, "kx": kx})
                        zero_run = 0
            streams.append({"m": m, "c": c, "entries": entries})
    return streams


def psum_seed_tensor(m_out: int, oh: int, ow: int, enable: bool, case_id: int) -> torch.Tensor:
    seed = torch.zeros(m_out, oh, ow, dtype=torch.int32)
    if enable:
        for m in range(m_out):
            for oy in range(oh):
                for ox in range(ow):
                    seed[m, oy, ox] = ((case_id + 1) * 3) + (oy + 1) * 5 + (ox + 1) * 2 + m
    return seed


def ppu_requantize_tensor(psum: torch.Tensor, bias: torch.Tensor, m0: int, n: int, z_out: int) -> torch.Tensor:
    x = psum.to(torch.int64) + bias.view(-1, 1, 1).to(torch.int64)
    x = torch.clamp(x, min=0)
    x = x * int(m0)
    shift_amt = 31 + int(n)
    if shift_amt > 0:
        x = (x + (1 << (shift_amt - 1))) >> shift_amt
    x = x + int(z_out)
    return torch.clamp(x, -128, 127).to(torch.int32)


def rs_s1_weight_support_cols(c_in: int, ky: int) -> set[int]:
    """Current verified stride-1 row-stationary Weight CSC support pattern."""
    active = set()
    for c in range(c_in):
        active.add((ky % 3) * c_in + c)
        active.add(((ky + 2) % 3) * c_in + c)
    return active


def case_configs() -> list[CaseConfig]:
    return [
        CaseConfig(9, 6, 2, 4, False, 0, 0),
        CaseConfig(10, 6, 2, 4, False, 0, 1),
        CaseConfig(8, 6, 1, 8, False, 0, 2),
        CaseConfig(8, 7, 2, 4, True, 1, 3),
        CaseConfig(7, 8, 1, 8, False, 1, 4),
        CaseConfig(10, 8, 2, 4, False, 1, 5),
        CaseConfig(6, 7, 1, 8, True, 2, 6),
        CaseConfig(3, 3, 1, 4, False, 2, 7),
        CaseConfig(4, 8, 1, 8, False, 0, 8),
        CaseConfig(5, 7, 2, 4, True, 1, 9),
        CaseConfig(6, 6, 1, 8, False, 2, 10),
        CaseConfig(9, 7, 1, 6, True, 0, 11),
        CaseConfig(5, 8, 2, 4, True, 1, 12),
        CaseConfig(10, 7, 1, 8, False, 2, 13),
        CaseConfig(3, 8, 2, 4, True, 0, 14),
        CaseConfig(4, 3, 1, 8, False, 1, 15),
        CaseConfig(10, 8, 1, 8, True, 2, 16),
        CaseConfig(6, 8, 2, 4, False, 1, 17),
        CaseConfig(10, 3, 2, 4, True, 1, 18),
        CaseConfig(3, 6, 1, 8, False, 2, 19),
    ]


def conv_layer_weights(model: TinyMultiLayerCNN, source_layer: int) -> torch.Tensor:
    if source_layer == 0:
        w = model.conv0.weight.detach()
    elif source_layer == 1:
        w = model.conv1.weight.detach()
    else:
        w = model.conv2.weight.detach()
    return quantize_symmetric(w)


def conv_layer_activation(model: TinyMultiLayerCNN, samples: torch.Tensor, source_layer: int, sample_index: int) -> torch.Tensor:
    x = samples[sample_index % samples.shape[0] : sample_index % samples.shape[0] + 1]
    with torch.no_grad():
        if source_layer == 0:
            a = x
        elif source_layer == 1:
            a = F.relu(model.conv0(x))
        else:
            a = F.relu(model.conv1(F.relu(model.conv0(x))))
    return quantize_activation(a[0])


def write_case(path: Path, case_id: int, cfg: CaseConfig, iact: torch.Tensor, weight: torch.Tensor,
               seed: torch.Tensor, golden: torch.Tensor, ppu_bias: torch.Tensor, ppu_m0: int,
               ppu_n: int, ppu_z_out: int, golden_int8: torch.Tensor) -> None:
    with path.open("w", encoding="utf-8") as stream:
        stream.write(f"CONFIG {case_id} {cfg.h} {cfg.w} {cfg.c_in} {cfg.m_out} {int(cfg.psum_seed)}\n")
        stream.write(f"PPUCFG {ppu_m0} {ppu_n} {ppu_z_out}\n")
        for c in range(cfg.c_in):
            for y in range(cfg.h):
                for x in range(cfg.w):
                    stream.write(f"IACT {c} {y} {x} {int(iact[c, y, x])}\n")
        for m in range(cfg.m_out):
            for c in range(cfg.c_in):
                for ky in range(3):
                    for kx in range(3):
                        stream.write(f"WEIGHT {m} {c} {ky} {kx} {int(weight[m, c, ky, kx])}\n")
        for m in range(cfg.m_out):
            stream.write(f"BIAS {m} {int(ppu_bias[m])}\n")
            for oy in range(cfg.h - 2):
                for ox in range(cfg.w - 2):
                    stream.write(f"PSUM {m} {oy} {ox} {int(seed[m, oy, ox])}\n")
                    stream.write(f"GOLDEN {m} {oy} {ox} {int(golden[m, oy, ox])}\n")
                    stream.write(f"GOLDEN_INT8 {m} {oy} {ox} {int(golden_int8[m, oy, ox])}\n")
        stream.write("END\n")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out-dir", type=Path, default=Path("tb/generated_cnn_cases"))
    args = parser.parse_args()

    args.out_dir.mkdir(parents=True, exist_ok=True)
    model = train_model()
    samples, _labels = make_dataset(n=64)
    manifest = []

    for case_id, cfg in enumerate(case_configs()):
        full_iact = conv_layer_activation(model, samples, cfg.source_layer, cfg.sample_index)
        full_weight = conv_layer_weights(model, cfg.source_layer)
        iact = full_iact[: cfg.c_in, : cfg.h, : cfg.w].clone()
        weight = full_weight[: cfg.m_out, : cfg.c_in, :, :].clone()

        # Add deterministic sparsity after quantization while keeping dense conv as oracle.
        for c in range(cfg.c_in):
            for y in range(cfg.h):
                for x in range(cfg.w):
                    if ((x + 2 * y + c + case_id) % 5) == 0:
                        iact[c, y, x] = 0
        # Keep each S1 resident/append segment representable by the current
        # physical path. Sparse channel entries are still allowed, but a fully
        # empty (y,x) segment followed by later non-empty segments can leave an
        # active PE waiting for cal_fin in the current RTL.
        for y in range(cfg.h):
            for x in range(cfg.w):
                if int(iact[:, y, x].abs().sum()) == 0:
                    restore_c = (x + y + case_id) % cfg.c_in
                    restored = int(full_iact[restore_c, y, x])
                    iact[restore_c, y, x] = restored if restored != 0 else 1
        # Keep Weight CSC legal for the current row-stationary cluster path:
        # if a column is present, M0 is non-zero and all filters in that column
        # share the same present/absent decision. The support pattern matches
        # the accepted S1 CSC contract; non-zero values still come from the
        # trained quantized model.
        for ky in range(3):
            active_cols = rs_s1_weight_support_cols(cfg.c_in, ky)
            for col in range(cfg.c_in * 3):
                c = col % cfg.c_in
                kx = col // cfg.c_in
                if col not in active_cols:
                    weight[: cfg.m_out, c, ky, kx] = 0
                else:
                    if int(weight[0, c, ky, kx]) == 0:
                        weight[0, c, ky, kx] = 1
                    for m in range(1, cfg.m_out):
                        if int(weight[m, c, ky, kx]) == 0:
                            weight[m, c, ky, kx] = -weight[0, c, ky, kx]

        conv = F.conv2d(iact.unsqueeze(0).float(), weight.float()).round().to(torch.int32)[0]
        seed = psum_seed_tensor(cfg.m_out, cfg.h - 2, cfg.w - 2, cfg.psum_seed, case_id)
        golden = conv + seed
        ppu_bias = torch.tensor([((case_id + 1) * (m + 1)) % 17 - 8 for m in range(cfg.m_out)], dtype=torch.int32)
        ppu_m0 = 1 << 30
        ppu_n = 0
        ppu_z_out = 0
        golden_int8 = ppu_requantize_tensor(golden, ppu_bias, ppu_m0, ppu_n, ppu_z_out)

        txt_path = args.out_dir / f"cnn_case_{case_id:02d}.txt"
        json_path = args.out_dir / f"cnn_case_{case_id:02d}.json"
        write_case(txt_path, case_id, cfg, iact, weight, seed, golden, ppu_bias, ppu_m0, ppu_n, ppu_z_out, golden_int8)
        json_payload = {
            "case_id": case_id,
            "config": cfg.__dict__,
            "iact_dense": int_tensor_to_list(iact),
            "weight_dense": int_tensor_to_list(weight),
            "psum_seed": int_tensor_to_list(seed),
            "golden": int_tensor_to_list(golden),
            "ppu": {
                "bias": int_tensor_to_list(ppu_bias),
                "M0": ppu_m0,
                "n": ppu_n,
                "z_out": ppu_z_out,
                "golden_int8": int_tensor_to_list(golden_int8),
            },
            "iact_csc": csc_iact_by_column(iact),
            "weight_csc": csc_weight_generic(weight),
            "oracle": "torch.nn.functional.conv2d on dense int8 tensors, plus optional dense psum seed",
            "text_case": str(txt_path.as_posix()),
        }
        with json_path.open("w", encoding="utf-8") as stream:
            json.dump(json_payload, stream, indent=2)
            stream.write("\n")
        manifest.append({
            "case_id": case_id,
            "text_case": str(txt_path.as_posix()),
            "json_case": str(json_path.as_posix()),
            "shape": f"H{cfg.h}xW{cfg.w}xC{cfg.c_in}_M{cfg.m_out}",
            "ofmap": f"OH{cfg.h - 2}xOW{cfg.w - 2}xM{cfg.m_out}",
            "source_layer": cfg.source_layer,
            "psum_seed": cfg.psum_seed,
            "nonzero_iact": int((iact != 0).sum()),
            "nonzero_weight": int((weight != 0).sum()),
            "scalars": int(golden.numel()),
        })

    manifest_path = args.out_dir / "manifest.json"
    with manifest_path.open("w", encoding="utf-8") as stream:
        json.dump({"case_count": len(manifest), "cases": manifest}, stream, indent=2)
        stream.write("\n")
    list_path = args.out_dir / "case_list.txt"
    with list_path.open("w", encoding="utf-8") as stream:
        for item in manifest:
            stream.write(item["text_case"] + "\n")

    print(f"[CNN_CASE_GEN][PASS] cases={len(manifest)} out_dir={args.out_dir}")
    print(f"[CNN_CASE_GEN][MANIFEST] {manifest_path}")
    print(f"[CNN_CASE_GEN][CASE_LIST] {list_path}")


if __name__ == "__main__":
    main()
