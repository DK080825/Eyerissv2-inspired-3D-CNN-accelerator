// ================================================================================================ //
// 3x4 PE-cluster intra-NoC (primitive fabrics only; see docs/PE_CLUSTER3x4_INTRANOC_BEHAVIOR.md).
//
// Layout:
//   PE index pe_idx = row * PE_COLS + col   (PE_ROWS=3, PE_COLS=4, PE_COUNT=12)
//
// Modules:
//   PE3x4_Mask_Fabric       — multicast + per-PE priority arbitration (IACT addr/data routers)
//   PE3x4_WEIGHT_RowFabric  — one ingress per row, column mask within row
//   PE3x4_IACT_SlotIngress_Fabric — shared IACT addr/data slot ingress primitive (NOC-F1)
//   PE3x4_PSUM_ColumnReduce — fixed vertical PSUM chain per column (R2->R1->R0)
//
// Verification: tb/tb_pe_cluster3x4_intranoc_primitives.sv
// ================================================================================================ //

module PE3x4_Mask_Fabric #(
    parameter integer PE_ROWS  = 3,
    parameter integer PE_COLS  = 4,
    parameter integer SRC_COUNT = 4,
    parameter integer DATA_W    = 13
)(
    input  wire                               clk,
    input  wire                               rst,
    input  wire [1:0]                        router_prio_in,
    input  wire [SRC_COUNT-1:0]               src_valid_in,
    output wire [SRC_COUNT-1:0]               src_ready_out,
    output wire [SRC_COUNT-1:0]               src_release_out,
    input  wire [SRC_COUNT*DATA_W-1:0]        src_data_in,
    input  wire [SRC_COUNT*(PE_ROWS*PE_COLS)-1:0] src_dst_mask_in,
    output wire [(PE_ROWS*PE_COLS)-1:0]       pe_valid_out,
    input  wire [(PE_ROWS*PE_COLS)-1:0]       pe_ready_in,
    output wire [(PE_ROWS*PE_COLS)*DATA_W-1:0] pe_data_out
);
    // Per-router in-flight multicast beat + per-PE priority arbitration.
    // router_prio_in selects the winning source independently for each PE.
    localparam integer PE_COUNT  = PE_ROWS * PE_COLS;
    localparam integer SRC_IDX_W  = (SRC_COUNT <= 1) ? 1 : $clog2(SRC_COUNT);

    reg [SRC_COUNT-1:0] inflight_valid_r;
    reg [SRC_COUNT*DATA_W-1:0] inflight_data_r;
    reg [SRC_COUNT*PE_COUNT-1:0] inflight_mask_r;
    reg [SRC_COUNT*PE_COUNT-1:0] inflight_accepted_r;

    reg [PE_COUNT-1:0] dest_buf_valid_r;
    reg [DATA_W-1:0] dest_buf_data_r [0:PE_COUNT-1];

    reg [SRC_COUNT-1:0] src_ready_w;
    reg [PE_COUNT-1:0] pe_winner_valid_w;
    reg [SRC_IDX_W-1:0] pe_winner_src_w [0:PE_COUNT-1];

    integer arb_i;
    integer arb_prio_idx;
    integer arb_scan_idx;
    integer arb_prio_base;
    integer arb_p;
    integer arb_r;
    integer seq_i;
    integer seq_p;
    integer seq_r;
    integer assert_i;

    assign src_ready_out = src_ready_w;
    generate
        genvar gr;
        wire [SRC_COUNT-1:0] src_complete_w;
        for (gr = 0; gr < SRC_COUNT; gr = gr + 1) begin : gen_src_release
            wire [PE_COUNT-1:0] src_mask_w = inflight_mask_r[(gr*PE_COUNT) +: PE_COUNT];
            wire [PE_COUNT-1:0] src_acc_w  = inflight_accepted_r[(gr*PE_COUNT) +: PE_COUNT];
            assign src_complete_w[gr] = ((src_acc_w & src_mask_w) == src_mask_w);
            assign src_release_out[gr] = inflight_valid_r[gr] & src_complete_w[gr];
        end
    endgenerate
    assign pe_valid_out  = dest_buf_valid_r;
    generate
        genvar gp;
        for (gp = 0; gp < PE_COUNT; gp = gp + 1) begin : gen_pe_data
            assign pe_data_out[(gp*DATA_W) +: DATA_W] = dest_buf_data_r[gp];
        end
    endgenerate

    function [PE_COUNT-1:0] inflight_mask_f;
        input [SRC_IDX_W-1:0] src_idx;
        begin
            inflight_mask_f = inflight_mask_r[(src_idx*PE_COUNT) +: PE_COUNT];
        end
    endfunction

    function [PE_COUNT-1:0] inflight_accepted_f;
        input [SRC_IDX_W-1:0] src_idx;
        begin
            inflight_accepted_f = inflight_accepted_r[(src_idx*PE_COUNT) +: PE_COUNT];
        end
    endfunction

    function inflight_complete_f;
        input [SRC_IDX_W-1:0] src_idx;
        reg [PE_COUNT-1:0] mask_v;
        reg [PE_COUNT-1:0] acc_v;
        begin
            mask_v = inflight_mask_f(src_idx);
            acc_v  = inflight_accepted_f(src_idx);
            inflight_complete_f = (acc_v & mask_v) == mask_v;
        end
    endfunction

    // src_ready_w: source slot is idle and can accept a new beat.
    always @(*) begin
        for (arb_i = 0; arb_i < SRC_COUNT; arb_i = arb_i + 1) begin
            src_ready_w[arb_i] = !inflight_valid_r[arb_i];
        end
    end

    // Per-PE winner among in-flight routers with pending (unaccepted) mask bits.
    always @(*) begin
        case (router_prio_in)
            2'd0: arb_prio_base = 0;
            2'd1: arb_prio_base = 1;
            2'd2: arb_prio_base = 2;
            default: arb_prio_base = 3;
        endcase
        for (arb_p = 0; arb_p < PE_COUNT; arb_p = arb_p + 1) begin
            pe_winner_valid_w[arb_p] = 1'b0;
            pe_winner_src_w[arb_p] = {SRC_IDX_W{1'b0}};
            for (arb_prio_idx = 0; arb_prio_idx < SRC_COUNT; arb_prio_idx = arb_prio_idx + 1) begin
                arb_scan_idx = arb_prio_base + arb_prio_idx;
                if (arb_scan_idx >= SRC_COUNT)
                    arb_scan_idx = arb_scan_idx - SRC_COUNT;
                arb_r = arb_scan_idx;
                if (!pe_winner_valid_w[arb_p] && inflight_valid_r[arb_r]) begin
                    if (inflight_mask_r[(arb_r*PE_COUNT)+arb_p] &&
                        !inflight_accepted_r[(arb_r*PE_COUNT)+arb_p]) begin
                        pe_winner_valid_w[arb_p] = 1'b1;
                        pe_winner_src_w[arb_p] = arb_r[SRC_IDX_W-1:0];
                    end
                end
            end
        end
    end

`ifndef SYNTHESIS
    always @(posedge clk) begin
        if (!rst) begin
            for (assert_i = 0; assert_i < SRC_COUNT; assert_i = assert_i + 1) begin
                if (src_valid_in[assert_i] &&
                    (src_dst_mask_in[(assert_i*PE_COUNT) +: PE_COUNT] == {PE_COUNT{1'b0}}))
                    $error("PE3x4_Mask_Fabric: zero dst mask is illegal");
            end
        end
    end
`endif

    always @(posedge clk) begin
        if (rst) begin
            inflight_valid_r <= {SRC_COUNT{1'b0}};
            inflight_data_r <= {(SRC_COUNT*DATA_W){1'b0}};
            inflight_mask_r <= {(SRC_COUNT*PE_COUNT){1'b0}};
            inflight_accepted_r <= {(SRC_COUNT*PE_COUNT){1'b0}};
            dest_buf_valid_r <= {PE_COUNT{1'b0}};
            for (seq_p = 0; seq_p < PE_COUNT; seq_p = seq_p + 1)
                dest_buf_data_r[seq_p] <= {DATA_W{1'b0}};
        end else begin
            for (seq_p = 0; seq_p < PE_COUNT; seq_p = seq_p + 1) begin
                if (dest_buf_valid_r[seq_p] && pe_ready_in[seq_p])
                    dest_buf_valid_r[seq_p] <= 1'b0;
            end
            for (seq_i = 0; seq_i < SRC_COUNT; seq_i = seq_i + 1) begin
                if (inflight_valid_r[seq_i] && inflight_complete_f(seq_i[SRC_IDX_W-1:0])) begin
                    inflight_valid_r[seq_i] <= 1'b0;
                end else if (!inflight_valid_r[seq_i] && src_valid_in[seq_i]) begin
                    inflight_valid_r[seq_i] <= 1'b1;
                    inflight_data_r[(seq_i*DATA_W) +: DATA_W] <= src_data_in[(seq_i*DATA_W) +: DATA_W];
                    inflight_mask_r[(seq_i*PE_COUNT) +: PE_COUNT] <=
                        src_dst_mask_in[(seq_i*PE_COUNT) +: PE_COUNT];
                    inflight_accepted_r[(seq_i*PE_COUNT) +: PE_COUNT] <= {PE_COUNT{1'b0}};
                end
            end
            for (seq_p = 0; seq_p < PE_COUNT; seq_p = seq_p + 1) begin
                if (pe_winner_valid_w[seq_p] && !dest_buf_valid_r[seq_p]) begin
                    seq_r = pe_winner_src_w[seq_p];
                    dest_buf_valid_r[seq_p] <= 1'b1;
                    dest_buf_data_r[seq_p] <= inflight_data_r[(seq_r*DATA_W) +: DATA_W];
                    inflight_accepted_r[(seq_r*PE_COUNT)+seq_p] <= 1'b1;
                end
            end
        end
    end
endmodule

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
`ifndef SYNTHESIS
    initial begin
        if (SRC_COUNT !== PE_ROWS)
            $error("PE3x4_WEIGHT_RowFabric: SRC_COUNT must equal PE_ROWS");
    end
`endif
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

module PE3x4_IACT_SlotIngress_Fabric #(
    parameter integer SLOT_COUNT = 8,
    parameter integer DATA_W     = 13,
    parameter integer PE_COUNT   = 12
)(
    input  wire                         clk,
    input  wire                         rst,
    input  wire [SLOT_COUNT-1:0]        slot_valid_in,
    output wire [SLOT_COUNT-1:0]        slot_ready_out,
    input  wire [SLOT_COUNT*DATA_W-1:0] slot_data_in,
    input  wire [SLOT_COUNT*PE_COUNT-1:0] slot_dst_mask_in,
    output wire [SLOT_COUNT-1:0]        fabric_valid_out,
    input  wire [SLOT_COUNT-1:0]        fabric_ready_in,
    output wire [SLOT_COUNT*DATA_W-1:0] fabric_data_out,
    output wire [SLOT_COUNT*PE_COUNT-1:0] fabric_dst_mask_out
);
    reg buffer_empty_r;
    reg [SLOT_COUNT-1:0] slot_valid_r;
    reg [SLOT_COUNT*DATA_W-1:0] slot_data_r;
    reg [SLOT_COUNT*PE_COUNT-1:0] slot_mask_r;

    integer slot_i;
    reg [SLOT_COUNT-1:0] slot_valid_nxt_w;

`ifndef SYNTHESIS
    initial begin
        if (SLOT_COUNT <= 0)
            $error("PE3x4_IACT_SlotIngress_Fabric: SLOT_COUNT must be > 0");
        if (DATA_W <= 0)
            $error("PE3x4_IACT_SlotIngress_Fabric: DATA_W must be > 0");
        if (PE_COUNT <= 0)
            $error("PE3x4_IACT_SlotIngress_Fabric: PE_COUNT must be > 0");
    end
`endif

    assign slot_ready_out = {SLOT_COUNT{buffer_empty_r}};
    assign fabric_valid_out    = buffer_empty_r ? {SLOT_COUNT{1'b0}} : slot_valid_r;
    assign fabric_data_out     = slot_data_r;
    assign fabric_dst_mask_out = slot_mask_r;

    always @(posedge clk) begin
        if (rst) begin
            buffer_empty_r <= 1'b1;
            slot_valid_r <= {SLOT_COUNT{1'b0}};
            slot_data_r <= 0;
            slot_mask_r <= 0;
        end else begin
            if (buffer_empty_r && |slot_valid_in) begin
                slot_valid_r <= slot_valid_in;
                slot_data_r <= slot_data_in;
                slot_mask_r <= slot_dst_mask_in;
                buffer_empty_r <= 1'b0;
            end else if (!buffer_empty_r) begin
                slot_valid_nxt_w = slot_valid_r;
                for (slot_i = 0; slot_i < SLOT_COUNT; slot_i = slot_i + 1) begin
                    if (slot_valid_r[slot_i] && fabric_ready_in[slot_i])
                        slot_valid_nxt_w[slot_i] = 1'b0;
                end
                slot_valid_r <= slot_valid_nxt_w;
                if (!(|slot_valid_nxt_w))
                    buffer_empty_r <= 1'b1;
            end
        end
    end
endmodule

module PE3x4_IACT_Atomic_Mask_Fabric #(
    parameter integer PE_ROWS   = 3,
    parameter integer PE_COLS   = 4,
    parameter integer SRC_COUNT = 8,
    parameter integer DATA_W    = 13
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

`ifndef SYNTHESIS
    integer a_lane;
    integer a_pe;
    reg [PE_COUNT-1:0] a_eff_mask;
    always @(*) begin
        for (a_lane = 0; a_lane < SRC_COUNT; a_lane = a_lane + 1) begin
            a_eff_mask = src_dst_mask_in[(a_lane*PE_COUNT) +: PE_COUNT] & active_pe_mask_in;
            if (src_valid_in[a_lane] && !lane_fire_w[a_lane]) begin
                for (a_pe = 0; a_pe < PE_COUNT; a_pe = a_pe + 1) begin
                    if (a_eff_mask[a_pe] && pe_owner_w[(a_pe*SRC_COUNT) + a_lane])
                        $error("PE3x4_IACT_Atomic_Mask_Fabric: blocked lane %0d partially delivered to PE%0d", a_lane, a_pe);
                end
            end
        end
        for (a_pe = 0; a_pe < PE_COUNT; a_pe = a_pe + 1) begin
            if (pe_valid_w[a_pe] && !active_pe_mask_in[a_pe])
                $error("PE3x4_IACT_Atomic_Mask_Fabric: disabled PE%0d received IACT", a_pe);
        end
    end
`endif
endmodule

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
