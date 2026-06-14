// ====================================================================================================== //
// Resident-only IACT data SPAD: CSC payload log with absolute pointers (production resident path).
// Segment commits drive Iact_Address_Spad metadata; iterator reads via resident_read_abs_idx.
// Eyeriss v2 PE: 16×13b payload entries (physical ring; absolute wr_abs/free_abs indexing).
// ====================================================================================================== //

module Iact_Data_Spad
#(
    parameter integer IACT_DATA_W      = 13,
    parameter integer SPAD_DEPTH       = 16,
    // Absolute ring pointers: SPAD_DEPTH entries need +1 bit for monotonic wr/free indexing.
    parameter integer RES_ABS_PTR_W    = ($clog2(SPAD_DEPTH) + 1)
)
(
    input  wire                         clk,
    input  wire                         rst,

    input  wire                         resident_en,
    input  wire                         resident_flush,
    input  wire                         resident_free_update_valid,
    input  wire [RES_ABS_PTR_W-1:0]     resident_free_abs_in,
    input  wire                         resident_data_valid,
    input  wire [IACT_DATA_W-1:0]       resident_data_in,
    input  wire                         resident_data_last,
    input  wire                         resident_seg_empty,
    output wire                         resident_data_ready,
    output reg                          resident_seg_commit_valid,
    output reg  [RES_ABS_PTR_W-1:0]     resident_seg_commit_begin,
    output reg  [RES_ABS_PTR_W-1:0]     resident_seg_commit_end,
    input  wire [RES_ABS_PTR_W-1:0]     resident_read_abs_idx,
    output reg  [IACT_DATA_W-1:0]       resident_data_out,
    output reg                          resident_seg_open,
    output reg  [RES_ABS_PTR_W-1:0]     resident_wr_abs,
    output reg  [RES_ABS_PTR_W-1:0]     resident_free_abs
);

localparam integer RESIDENT_DATA_IDX_W = $clog2(SPAD_DEPTH);

(* ram_style = "distributed" *)
reg [IACT_DATA_W-1:0] mem [0:SPAD_DEPTH-1];

reg [RES_ABS_PTR_W-1:0]    resident_seg_begin_abs;
wire [RESIDENT_DATA_IDX_W-1:0] resident_wr_idx_w;
wire [RESIDENT_DATA_IDX_W-1:0] resident_rd_idx_w;

assign resident_wr_idx_w = resident_wr_abs[RESIDENT_DATA_IDX_W-1:0];
assign resident_rd_idx_w = resident_read_abs_idx[RESIDENT_DATA_IDX_W-1:0];

wire [RES_ABS_PTR_W-1:0] resident_used_w = resident_wr_abs - resident_free_abs;
assign resident_data_ready = (rst == 1'b0) && resident_en && (resident_used_w < SPAD_DEPTH[RES_ABS_PTR_W-1:0]);

always @(posedge clk) begin
    if (rst) begin
        resident_data_out <= {IACT_DATA_W{1'b0}};
        resident_seg_commit_valid <= 1'b0;
        resident_seg_commit_begin <= {RES_ABS_PTR_W{1'b0}};
        resident_seg_commit_end   <= {RES_ABS_PTR_W{1'b0}};
        resident_seg_open         <= 1'b0;
        resident_seg_begin_abs    <= {RES_ABS_PTR_W{1'b0}};
        resident_wr_abs           <= {RES_ABS_PTR_W{1'b0}};
        resident_free_abs         <= {RES_ABS_PTR_W{1'b0}};
    end
    else begin
        resident_seg_commit_valid <= 1'b0;
        resident_data_out <= mem[resident_rd_idx_w];

        if (resident_en) begin
            if (resident_flush) begin
                resident_seg_open      <= 1'b0;
                resident_seg_begin_abs <= {RES_ABS_PTR_W{1'b0}};
                resident_wr_abs        <= {RES_ABS_PTR_W{1'b0}};
                resident_free_abs      <= {RES_ABS_PTR_W{1'b0}};
            end else begin
                if (resident_free_update_valid) begin
                    resident_free_abs <= resident_free_abs_in;
                end

                if (resident_seg_empty && !resident_seg_open) begin
                    resident_seg_commit_valid <= 1'b1;
                    resident_seg_commit_begin <= resident_wr_abs;
                    resident_seg_commit_end   <= resident_wr_abs;
                end

                if (resident_data_valid && resident_data_ready) begin
                    if (!resident_seg_open) begin
                        resident_seg_open      <= 1'b1;
                        resident_seg_begin_abs <= resident_wr_abs;
                    end
                    mem[resident_wr_idx_w] <= resident_data_in;
                    resident_wr_abs <= resident_wr_abs + {{(RES_ABS_PTR_W-1){1'b0}},1'b1};

                    if (resident_data_last) begin
                        resident_seg_open <= 1'b0;
                        resident_seg_commit_valid <= 1'b1;
                        resident_seg_commit_begin <= resident_seg_open ? resident_seg_begin_abs : resident_wr_abs;
                        resident_seg_commit_end   <= resident_wr_abs + {{(RES_ABS_PTR_W-1){1'b0}},1'b1};
                    end
                end
            end
        end
    end
end

endmodule
