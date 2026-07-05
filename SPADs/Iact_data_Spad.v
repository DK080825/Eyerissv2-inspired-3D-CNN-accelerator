// ============================================================================
// Module      : Iact_Data_Spad
// Author      : Do Quoc Khanh
// Description : Local IACT data storage inside one PE.
//               It stores non-zero IACT payload words for the current window.
//               The storage works like a small ring buffer.
//               During sliding, old useful data stays in place and new IACT
//               data is appended at the write pointer.
// ============================================================================

module Iact_Data_Spad
#(
    parameter integer IACT_DATA_W      = 12,
    parameter integer SPAD_DEPTH       = 16,
    // Absolute ring pointers: SPAD_DEPTH entries need +1 bit for monotonic wr/free indexing.
    parameter integer RES_ABS_PTR_W    = ($clog2(SPAD_DEPTH) + 1),
    parameter integer RES_IDX_W        = $clog2(SPAD_DEPTH)
)
(
    input  wire                         clk,
    input  wire                         rst,

    // PE core -> SPAD: clear the current IACT window.
    input  wire                         resident_flush,

    // PE core -> SPAD: free old entries after sliding.
    input  wire                         resident_free_update_valid,
    input  wire [RES_ABS_PTR_W-1:0]     resident_free_abs_in,

    // Fabric -> SPAD: new IACT payload word.
    input  wire                         resident_data_valid,
    input  wire [IACT_DATA_W-1:0]       resident_data_in,
    output wire                         resident_data_ready,

    // PE core -> SPAD: read one stored payload word.
    input  wire [RES_IDX_W-1:0]         resident_read_idx,
    output reg  [IACT_DATA_W-1:0]       resident_data_out,

    // SPAD -> PE core: current ring-buffer positions.
    output reg  [RES_ABS_PTR_W-1:0]     resident_wr_abs,
    output reg  [RES_ABS_PTR_W-1:0]     resident_free_abs
);

// Small PE-local storage: keep as registers.
(* ram_style = "registers", ramstyle = "logic" *)
reg [IACT_DATA_W-1:0] mem [0:SPAD_DEPTH-1];

wire [RES_IDX_W-1:0] resident_wr_idx_w;
wire [RES_IDX_W-1:0] resident_rd_idx_w;

assign resident_wr_idx_w = resident_wr_abs[RES_IDX_W-1:0];
assign resident_rd_idx_w = resident_read_idx;

wire [RES_ABS_PTR_W-1:0] resident_used_w = resident_wr_abs - resident_free_abs;
assign resident_data_ready = (rst == 1'b0) && (resident_used_w < SPAD_DEPTH[RES_ABS_PTR_W-1:0]);

always @(posedge clk) begin
    if (rst) begin
        resident_data_out <= {IACT_DATA_W{1'b0}};
        resident_wr_abs           <= {RES_ABS_PTR_W{1'b0}};
        resident_free_abs         <= {RES_ABS_PTR_W{1'b0}};
    end
    else begin
        resident_data_out <= mem[resident_rd_idx_w];

        if (resident_flush) begin
            resident_wr_abs        <= {RES_ABS_PTR_W{1'b0}};
            resident_free_abs      <= {RES_ABS_PTR_W{1'b0}};
        end else begin
            if (resident_free_update_valid) begin
                resident_free_abs <= resident_free_abs_in;
            end

            if (resident_data_valid && resident_data_ready) begin
                mem[resident_wr_idx_w] <= resident_data_in;
                resident_wr_abs <= resident_wr_abs + {{(RES_ABS_PTR_W-1){1'b0}},1'b1};
            end
        end
    end
end

endmodule
