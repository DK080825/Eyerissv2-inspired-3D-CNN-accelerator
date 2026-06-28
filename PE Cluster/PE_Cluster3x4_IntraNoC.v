// ================================================================================================ //
// 3x4 PE-cluster intra-NoC (primitive fabrics only; see docs/PE_CLUSTER3x4_INTRANOC_BEHAVIOR.md).
//
//   PE index pe_idx = row * PE_COLS + col   (PE_ROWS=3, PE_COLS=4, PE_COUNT=12)
//
// Modules:
//   PE3x4_WEIGHT_RowFabric  — one ingress per row, column mask within row
//   PE3x4_IACT_SlotIngress_Fabric — shared IACT addr/data slot ingress primitive (NOC-F1)
//   PE3x4_PSUM_ColumnReduce — fixed vertical PSUM chain per column (R2->R1->R0)
//
// Verification: tb/tb_pe_cluster3x4_intranoc_primitives.sv
// ================================================================================================ //

module PE3x4_WEIGHT_RowFabric #(
    parameter integer PE_ROWS  = 3,
    parameter integer PE_COLS  = 4,
    parameter integer SRC_COUNT = 3,
    parameter integer DATA_W    = 24
)(
    input  wire                             clk,
    input  wire                             rst,
    input  wire [SRC_COUNT-1:0]             src_valid_in,
    output wire [SRC_COUNT-1:0]             src_ready_out,
    input  wire [SRC_COUNT*DATA_W-1:0]      src_data_in,
    input  wire [PE_ROWS*PE_COLS-1:0]       row_dst_mask_in,
    output wire [(PE_ROWS*PE_COLS)-1:0]     pe_valid_out,
    input  wire [(PE_ROWS*PE_COLS)-1:0]     pe_ready_in,
    output wire [(PE_ROWS*PE_COLS)*DATA_W-1:0] pe_data_out
);
    localparam integer PE_COUNT = PE_ROWS * PE_COLS;

    genvar r, c;
    generate
        for (r = 0; r < PE_ROWS; r = r + 1) begin : gen_rows
            wire [PE_COLS-1:0] row_mask_w = row_dst_mask_in[(r*PE_COLS) +: PE_COLS];
            wire [PE_COLS-1:0] row_vld_w  = {PE_COLS{src_valid_in[r]}} & row_mask_w;
            wire [PE_COLS-1:0] row_rdy_w;
            wire row_fire_w;
            for (c = 0; c < PE_COLS; c = c + 1) begin : gen_cols
                localparam integer PE_IDX = (r*PE_COLS) + c;
                assign pe_valid_out[PE_IDX] = row_vld_w[c] & row_fire_w;
                assign pe_data_out[(PE_IDX*DATA_W) +: DATA_W] = src_data_in[(r*DATA_W) +: DATA_W];
                assign row_rdy_w[c] = pe_ready_in[PE_IDX] | ~row_vld_w[c];
            end
            assign src_ready_out[r] = &row_rdy_w;
            assign row_fire_w = src_valid_in[r] & src_ready_out[r];
        end
    endgenerate
endmodule

module PE3x4_IACT_Atomic_Mask_Fabric #(
    parameter integer PE_ROWS   = 3,
    parameter integer PE_COLS   = 4,
    parameter integer SRC_COUNT = 8,
    parameter integer DATA_W    = 12
)(
    input  wire [1:0]                               router_prio_in,
    input  wire [SRC_COUNT-1:0]                     src_valid_in,
    output wire [SRC_COUNT-1:0]                     src_ready_out,
    input  wire [SRC_COUNT*DATA_W-1:0]              src_data_in,
    input  wire [SRC_COUNT*(PE_ROWS*PE_COLS)-1:0]   src_dst_mask_in,
    input  wire [(PE_ROWS*PE_COLS)-1:0]             active_pe_mask_in,
    output wire [(PE_ROWS*PE_COLS)-1:0]             pe_valid_out,
    input  wire [(PE_ROWS*PE_COLS)-1:0]             pe_ready_in,
    output wire [(PE_ROWS*PE_COLS)*DATA_W-1:0]      pe_data_out
);
    localparam integer PE_COUNT = PE_ROWS * PE_COLS;

    reg [SRC_COUNT-1:0] src_ready_w;
    reg [PE_COUNT-1:0] pe_valid_w;
    reg [PE_COUNT*DATA_W-1:0] pe_data_w;
    reg [PE_COUNT-1:0] pe_assigned_w;
    reg [SRC_COUNT-1:0] lane_fire_w;
    reg [PE_COUNT*SRC_COUNT-1:0] pe_owner_w;
    reg [PE_COUNT-1:0] eff_mask_w;
    reg lane_can_fire_w;
    reg all_ready_w;
    integer lane_pos;
    integer lane_idx;
    integer pe_idx;
    integer prio_base;

    assign src_ready_out = src_ready_w;
    assign pe_valid_out  = pe_valid_w;
    assign pe_data_out   = pe_data_w;

    always @(*) begin
        case (router_prio_in)
            2'd0: prio_base = 0;
            2'd1: prio_base = 1;
            2'd2: prio_base = 2;
            default: prio_base = 3;
        endcase

        src_ready_w = {SRC_COUNT{1'b1}};
        pe_valid_w = {PE_COUNT{1'b0}};
        pe_data_w = {(PE_COUNT*DATA_W){1'b0}};
        pe_assigned_w = {PE_COUNT{1'b0}};
        lane_fire_w = {SRC_COUNT{1'b0}};
        pe_owner_w = {(PE_COUNT*SRC_COUNT){1'b0}};

        for (lane_pos = 0; lane_pos < SRC_COUNT; lane_pos = lane_pos + 1) begin
            lane_idx = prio_base + lane_pos;
            if (lane_idx >= SRC_COUNT)
                lane_idx = lane_idx - SRC_COUNT;

            if (src_valid_in[lane_idx]) begin
                eff_mask_w = src_dst_mask_in[(lane_idx*PE_COUNT) +: PE_COUNT] & active_pe_mask_in;
                if (eff_mask_w == {PE_COUNT{1'b0}}) begin
                    src_ready_w[lane_idx] = 1'b1;
                end else begin
                    all_ready_w = 1'b1;
                    for (pe_idx = 0; pe_idx < PE_COUNT; pe_idx = pe_idx + 1) begin
                        if (eff_mask_w[pe_idx] && (!pe_ready_in[pe_idx] || pe_assigned_w[pe_idx]))
                            all_ready_w = 1'b0;
                    end
                    lane_can_fire_w = all_ready_w;
                    src_ready_w[lane_idx] = lane_can_fire_w;

                    if (lane_can_fire_w) begin
                        lane_fire_w[lane_idx] = 1'b1;
                        for (pe_idx = 0; pe_idx < PE_COUNT; pe_idx = pe_idx + 1) begin
                            if (eff_mask_w[pe_idx]) begin
                                pe_valid_w[pe_idx] = 1'b1;
                                pe_data_w[(pe_idx*DATA_W) +: DATA_W] = src_data_in[(lane_idx*DATA_W) +: DATA_W];
                                pe_assigned_w[pe_idx] = 1'b1;
                                pe_owner_w[(pe_idx*SRC_COUNT) + lane_idx] = 1'b1;
                            end
                        end
                    end
                end
            end
        end
    end


module PE3x4_PSUM_ColumnReduce #(
    parameter integer PE_ROWS = 3,
    parameter integer PE_COLS = 4,
    parameter integer DATA_W  = 21
)(
    input  wire [PE_COLS-1:0]               col_in_valid,
    output wire [PE_COLS-1:0]               col_in_ready,
    input  wire signed [PE_COLS*DATA_W-1:0] col_in_data,
    output wire [PE_COLS-1:0]               col_out_valid,
    input  wire [PE_COLS-1:0]               col_out_ready,
    output wire signed [PE_COLS*DATA_W-1:0] col_out_data,
    output wire [(PE_ROWS*PE_COLS)-1:0]     pe_psum_in_valid,
    input  wire [(PE_ROWS*PE_COLS)-1:0]     pe_psum_in_ready,
    output wire signed [(PE_ROWS*PE_COLS)*DATA_W-1:0] pe_psum_in_data,
    input  wire [(PE_ROWS*PE_COLS)-1:0]     pe_psum_out_valid,
    output wire [(PE_ROWS*PE_COLS)-1:0]     pe_psum_out_ready,
    input  wire signed [(PE_ROWS*PE_COLS)*DATA_W-1:0] pe_psum_out_data
);
    genvar c;
    generate
        for (c = 0; c < PE_COLS; c = c + 1) begin : gen_col
            localparam integer IDX_R0 = (0*PE_COLS) + c;
            localparam integer IDX_R1 = (1*PE_COLS) + c;
            localparam integer IDX_R2 = (2*PE_COLS) + c;
            assign pe_psum_in_valid[IDX_R2] = col_in_valid[c];
            assign pe_psum_in_data[(IDX_R2*DATA_W) +: DATA_W] = col_in_data[(c*DATA_W) +: DATA_W];
            assign col_in_ready[c] = pe_psum_in_ready[IDX_R2];
            assign pe_psum_in_valid[IDX_R1] = pe_psum_out_valid[IDX_R2];
            assign pe_psum_in_data[(IDX_R1*DATA_W) +: DATA_W] = pe_psum_out_data[(IDX_R2*DATA_W) +: DATA_W];
            assign pe_psum_out_ready[IDX_R2] = pe_psum_in_ready[IDX_R1];
            assign pe_psum_in_valid[IDX_R0] = pe_psum_out_valid[IDX_R1];
            assign pe_psum_in_data[(IDX_R0*DATA_W) +: DATA_W] = pe_psum_out_data[(IDX_R1*DATA_W) +: DATA_W];
            assign pe_psum_out_ready[IDX_R1] = pe_psum_in_ready[IDX_R0];
            assign col_out_valid[c] = pe_psum_out_valid[IDX_R0];
            assign col_out_data[(c*DATA_W) +: DATA_W] = pe_psum_out_data[(IDX_R0*DATA_W) +: DATA_W];
            assign pe_psum_out_ready[IDX_R0] = col_out_ready[c];
        end
    endgenerate
endmodule
