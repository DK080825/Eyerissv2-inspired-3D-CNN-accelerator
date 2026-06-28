`timescale 1ns/1ps

// ====================================================================================================== //
// PPU_Wrapper
//
// Purpose:
// - Load config once for a whole channel / tile:
//      bias, M0, n, z_out
// - Stream psum samples continuously through the inner PPU using that fixed config
// - Prevent config change while the PPU pipeline still contains in-flight samples
//
// Usage:
// 1) Wait until cfg_ready = 1
// 2) Assert cfg_load for 1 cycle with cfg_bias/cfg_M0/cfg_n/cfg_z_out
// 3) After config is loaded, cfg_valid becomes 1
// 4) Stream psum with psum_valid while psum_ready = 1
// 5) To change config for next channel/tile, stop psum stream and wait until ppu_idle = 1,
//    then load new config
//
// Notes:
// - Inner PPU has no ready input, so wrapper exposes psum_ready = 1 whenever config is valid
//   and no config load is happening in the same cycle.
// - Config is only allowed to load when pipeline is idle.
// - ppu_busy / ppu_idle are derived from an in-flight sample counter.
// ====================================================================================================== //

module PPU_Wrapper #(
    parameter integer PSUM_W   = 21,
    parameter integer BIAS_W   = 21,
    parameter integer ADD_W    = 22,
    parameter integer M0_W     = 32,
    parameter integer SHIFT_W  = 6,
    parameter integer LATENCY  = 4   // must match inner PPU valid latency
)(
    input  wire                      clock,
    input  wire                      reset,

    // ----------------------------------------------------------------------------------------------
    // Config interface: load once per channel/tile
    // ----------------------------------------------------------------------------------------------
    input  wire                      cfg_load,
    input  wire signed [BIAS_W-1:0]  cfg_bias,
    input  wire        [M0_W-1:0]    cfg_M0,
    input  wire        [SHIFT_W-1:0] cfg_n,
    input  wire signed [7:0]         cfg_z_out,

    output wire                      cfg_ready,   // can accept cfg_load now
    output reg                       cfg_valid,   // at least one valid config has been loaded

    // ----------------------------------------------------------------------------------------------
    // Psum stream from PE
    // ----------------------------------------------------------------------------------------------
    input  wire                      psum_valid,
    input  wire signed [PSUM_W-1:0]  psum_in,
    output wire                      psum_ready,

    // ----------------------------------------------------------------------------------------------
    // Output stream
    // ----------------------------------------------------------------------------------------------
    output wire                      out_valid,
    output wire signed [7:0]         out_int8,

    // ----------------------------------------------------------------------------------------------
    // Status
    // ----------------------------------------------------------------------------------------------
    output wire                      ppu_busy,
    output wire                      ppu_idle
);

    // ==============================================================================================
    // Localparams
    // ==============================================================================================
    localparam integer INFLIGHT_W = (LATENCY <= 1) ? 1 : $clog2(LATENCY + 1);

    // ==============================================================================================
    // Config registers
    // ==============================================================================================
    reg signed [BIAS_W-1:0]  bias_cfg_reg;
    reg        [M0_W-1:0]    M0_cfg_reg;
    reg        [SHIFT_W-1:0] n_cfg_reg;
    reg signed [7:0]         z_out_cfg_reg;

    // ==============================================================================================
    // In-flight counter
    // Counts how many valid samples are currently inside the PPU pipeline
    // ==============================================================================================
    reg [INFLIGHT_W-1:0] inflight_count;

    // ==============================================================================================
    // Handshake / status
    // ==============================================================================================
    wire cfg_load_fire;
    wire psum_fire;
    wire ppu_valid_in;

    assign ppu_idle  = (inflight_count == {INFLIGHT_W{1'b0}});
    assign ppu_busy  = ~ppu_idle;

    // Only allow new config when pipeline is empty
    assign cfg_ready = (~reset) & ppu_idle;

    // Psum stream is accepted only after config has been loaded,
    // and not in the same cycle as cfg_load
    assign psum_ready = (~reset) & cfg_valid & (~cfg_load);

    assign cfg_load_fire = cfg_load  & cfg_ready;
    assign psum_fire     = psum_valid & psum_ready;

    // Inner PPU sees valid only when wrapper truly accepts a psum sample
    assign ppu_valid_in  = psum_fire;

    // ==============================================================================================
    // Config register load
    // ==============================================================================================
    always @(posedge clock) begin
        if (reset) begin
            bias_cfg_reg  <= {BIAS_W{1'b0}};
            M0_cfg_reg    <= {M0_W{1'b0}};
            n_cfg_reg     <= {SHIFT_W{1'b0}};
            z_out_cfg_reg <= 8'sd0;
            cfg_valid     <= 1'b0;
        end
        else begin
            if (cfg_load_fire) begin
                bias_cfg_reg  <= cfg_bias;
                M0_cfg_reg    <= cfg_M0;
                n_cfg_reg     <= cfg_n;
                z_out_cfg_reg <= cfg_z_out;
                cfg_valid     <= 1'b1;
            end
        end
    end

    // ==============================================================================================
    // In-flight counter update
    // - Increment when a new psum sample enters the inner PPU
    // - Decrement when inner PPU produces a valid output
    // ==============================================================================================
    always @(posedge clock) begin
        if (reset) begin
            inflight_count <= {INFLIGHT_W{1'b0}};
        end
        else begin
            case ({psum_fire, out_valid})
                2'b10: begin
                    // new sample enters, no sample exits
                    if (inflight_count < LATENCY[INFLIGHT_W-1:0])
                        inflight_count <= inflight_count + 1'b1;
                    else
                        inflight_count <= inflight_count;
                end

                2'b01: begin
                    // sample exits, no new sample enters
                    if (inflight_count != {INFLIGHT_W{1'b0}})
                        inflight_count <= inflight_count - 1'b1;
                    else
                        inflight_count <= inflight_count;
                end

                2'b11: begin
                    // one enters, one exits: steady-state streaming
                    inflight_count <= inflight_count;
                end

                default: begin
                    inflight_count <= inflight_count;
                end
            endcase
        end
    end

    // ==============================================================================================
    // Inner PPU instance
    // ==============================================================================================
    PPU #(
        .PSUM_W (PSUM_W),
        .BIAS_W (BIAS_W),
        .ADD_W  (ADD_W),
        .M0_W   (M0_W),
        .SHIFT_W(SHIFT_W)
    ) u_PPU (
        .clock    (clock),
        .reset    (reset),

        .valid_in (ppu_valid_in),
        .psum_in  (psum_in),
        .bias_in  (bias_cfg_reg),
        .M0_in    (M0_cfg_reg),
        .n_in     (n_cfg_reg),
        .z_out    (z_out_cfg_reg),

        .valid_out(out_valid),
        .out_int8 (out_int8)
    );

endmodule