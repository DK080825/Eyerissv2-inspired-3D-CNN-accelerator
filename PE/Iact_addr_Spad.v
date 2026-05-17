// ====================================================================================================== //
// IACT CSC address-vector SPAD (Option B, Step 2).
// - Streams boundary values like Weight_Address_Spad; one accepted beat = one addr[] entry.
// - Segment i: seg_begin = addr[rd_seg_idx], seg_end = addr[rd_seg_idx+1] (exclusive end semantics).
// - Empty segment: seg_begin == seg_end (repeated boundary).
// - Sentinel 8'hFF terminates programming; it is NOT stored. write_fin is a 1-cycle pulse registered
//   one cycle after the sentinel handshake (for stable sampling by core/TB).
// - Eyeriss v2 PE: 9×8b cumulative boundary entries (supports up to 8 segments + slide append slot).
//
// NOTE (Step 2 / Option A compile): Processing_Element_core_pipeline still expects the legacy resident
//       commit-ring port list. Full-core compile will fail until Step 3 rewires the core. Use the
//       isolated tb_iact_address_spad_vector.sv + run_iact_address_vector_spad_tb.bat for Step 2.
// ====================================================================================================== //

`default_nettype none

module Iact_Address_Spad #(
    parameter integer IACT_ADDR_SPAD_DEPTH = 9,
    parameter integer IACT_ADDR_W          = 5,  // cumulative payload boundary ($clog2(data_depth)+1)
    parameter integer IACT_ADDR_IDX_W      = 4   // segment slot index ($clog2(IACT_ADDR_SPAD_DEPTH))
) (
    input  wire                        clk,
    input  wire                        rst,

    output wire                        data_in_ready,
    input  wire                        data_in_valid,
    input  wire [IACT_ADDR_W-1:0]      data_in,
    input  wire                        write_en,
    input  wire                        flush,
    output reg                         write_fin,

    input  wire [IACT_ADDR_IDX_W-1:0]           rd_seg_idx,
    output wire [IACT_ADDR_W-1:0]     seg_begin,
    output wire [IACT_ADDR_W-1:0]     seg_end,

    // Resident window slide (no flush): shift boundary chain left by one segment, reopen programming
    // so host can append one new boundary + sentinel. slide_append_idx = cfg_window_seg_count (S).
    input  wire                        slide_shift,
    input  wire [IACT_ADDR_IDX_W-1:0]  slide_append_idx,
    output wire [IACT_ADDR_W-1:0]      boundary1_out
);

  localparam integer IACT_ADDR_VECTOR_DEPTH = IACT_ADDR_SPAD_DEPTH;
  localparam integer WA_W = $clog2(IACT_ADDR_VECTOR_DEPTH);

  localparam [IACT_ADDR_W-1:0] IACT_ADDR_SENTINEL = {IACT_ADDR_W{1'b1}};
  // Write position: 0..8 = stored boundary index; 9 = awaiting sentinel (no data on ready).
  localparam [WA_W:0] PTR_LAST_DATA  = {1'b0, {WA_W {1'b1}}};
  localparam [WA_W:0] PTR_AWAIT_SENT = IACT_ADDR_VECTOR_DEPTH[WA_W:0];

  (* ram_style = "distributed" *)
  reg [IACT_ADDR_W-1:0] iact_address_vector[0:IACT_ADDR_VECTOR_DEPTH-1];

  reg [WA_W:0] spad_write_addr_r;
  reg          program_done_r;
  reg          overflow_latched_r;
  reg          await_sentinel_r;

  // Ready: no combinatorial dependency on data_in.
  assign data_in_ready =
      write_en && !program_done_r && !overflow_latched_r && !flush &&
      ((spad_write_addr_r < IACT_ADDR_VECTOR_DEPTH[WA_W:0]) || await_sentinel_r);

  wire data_in_shake = data_in_valid && data_in_ready;

  wire sentinel_in = (data_in == IACT_ADDR_SENTINEL);

  integer init_i;
  reg [IACT_ADDR_W-1:0] seg_begin_r;
  reg [IACT_ADDR_W-1:0] seg_end_r;

  reg          sentinel_shake_d1_r;

  wire [4:0] rd_seg_idx_ext = {1'b0, rd_seg_idx};
  wire [4:0] rd_seg_idx_p1 = rd_seg_idx_ext + 5'd1;

  assign boundary1_out = iact_address_vector[1];

  integer slide_i;

  always @(posedge clk) begin
    if (rst) begin
      write_fin              <= 1'b0;
      sentinel_shake_d1_r    <= 1'b0;
      program_done_r      <= 1'b0;
      overflow_latched_r  <= 1'b0;
      await_sentinel_r    <= 1'b0;
      spad_write_addr_r   <= {(WA_W + 1) {1'b0}};
      for (init_i = 0; init_i < IACT_ADDR_VECTOR_DEPTH; init_i = init_i + 1)
        iact_address_vector[init_i] <= IACT_ADDR_SENTINEL;
    end else if (flush) begin
      write_fin              <= 1'b0;
      sentinel_shake_d1_r    <= 1'b0;
      program_done_r      <= 1'b0;
      overflow_latched_r  <= 1'b0;
      await_sentinel_r    <= 1'b0;
      spad_write_addr_r   <= {(WA_W + 1) {1'b0}};
      for (init_i = 0; init_i < IACT_ADDR_VECTOR_DEPTH; init_i = init_i + 1)
        iact_address_vector[init_i] <= IACT_ADDR_SENTINEL;
    end else begin
      if (slide_shift && program_done_r) begin
        write_fin           <= 1'b0;
        sentinel_shake_d1_r <= 1'b0;
        for (slide_i = 0; slide_i < IACT_ADDR_VECTOR_DEPTH - 1; slide_i = slide_i + 1)
          iact_address_vector[slide_i] <= iact_address_vector[slide_i + 1];
        iact_address_vector[IACT_ADDR_VECTOR_DEPTH - 1] <= IACT_ADDR_SENTINEL;
        program_done_r     <= 1'b0;
        overflow_latched_r <= 1'b0;
        await_sentinel_r   <= 1'b0;
        spad_write_addr_r  <= {{(WA_W + 1 - IACT_ADDR_IDX_W) {1'b0}}, slide_append_idx};
      end else begin
        if (data_in_shake) begin
          if (sentinel_in) begin
            program_done_r     <= 1'b1;
            await_sentinel_r   <= 1'b0;
            spad_write_addr_r  <= {(WA_W + 1) {1'b0}};
          end else begin
            if (await_sentinel_r) begin
              overflow_latched_r <= 1'b1;
            end else if (spad_write_addr_r < IACT_ADDR_VECTOR_DEPTH[WA_W:0]) begin
              iact_address_vector[spad_write_addr_r[WA_W-1:0]] <= data_in;
              if (spad_write_addr_r == PTR_LAST_DATA) begin
                spad_write_addr_r <= PTR_AWAIT_SENT;
                await_sentinel_r  <= 1'b1;
              end else
                spad_write_addr_r <= spad_write_addr_r + {{WA_W {1'b0}}, 1'b1};
            end else begin
              overflow_latched_r <= 1'b1;
            end
          end
        end
        sentinel_shake_d1_r <= (data_in_shake && sentinel_in);
        write_fin            <= sentinel_shake_d1_r;
      end
    end
  end

  // Combinational read: OOB uses SENTINEL (not a legal stored boundary for iterator use).
  always @* begin
    seg_begin_r = IACT_ADDR_SENTINEL;
    seg_end_r   = IACT_ADDR_SENTINEL;
    if (rd_seg_idx_ext < IACT_ADDR_VECTOR_DEPTH)
      seg_begin_r = iact_address_vector[rd_seg_idx];
    if (rd_seg_idx_p1 < IACT_ADDR_VECTOR_DEPTH)
      seg_end_r = iact_address_vector[rd_seg_idx_p1[WA_W-1:0]];
  end

  assign seg_begin = seg_begin_r;
  assign seg_end   = seg_end_r;

endmodule

`default_nettype wire
