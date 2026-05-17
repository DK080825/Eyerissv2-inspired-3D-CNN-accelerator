// ================================================================================================ //
// 4x4 PE-cluster intra-NoC inspired by Eyeriss v2 hierarchical mesh philosophy.
//
// Key ideas:
// 1) iact NoC:  4-router to 16-PE flexible distribution (all-to-all style via destination masks)
// 2) weight NoC: 4 row routers, each serves only its own row (row-restricted multicast/broadcast)
// 3) psum NoC:  4 column reduction paths (vertical accumulation chain semantics)
//
// This file only defines intra-cluster NoC and PE-side router interfaces.
// PE array instantiation can be integrated on top of these PE-side buses.
// ================================================================================================ //

module PE_Cluster4x4_IntraNoC #(
    parameter integer IACT_W   = 13,
    parameter integer WEIGHT_W = 24,
    parameter integer PSUM_W   = 21
)(
    input  wire                       clk,
    input  wire                       rst_n,

    // ------------------------------------
    // Layer mode controls
    // ------------------------------------
    // 00: standard conv, 01: depth-wise conv, 10: fully connected, 11: reserved
    input  wire [1:0]                 layer_mode,
    // iact_router_prio picks winner when multiple iact routers target same PE at once.
    // 0 = router0 highest priority ... 3 = router3 highest priority.
    input  wire [1:0]                 iact_router_prio,

    // ------------------------------------
    // IACT routers (4) -> NoC
    // ------------------------------------
    input  wire [3:0]                 iact_in_valid,
    output wire [3:0]                 iact_in_ready,
    input  wire [4*IACT_W-1:0]        iact_in_data,
    // Each iact router provides 16-bit PE destination mask:
    // bit [r*4+c] targets PE(r,c), supports unicast/multicast/broadcast.
    input  wire [4*16-1:0]            iact_in_dst_mask,

    // ------------------------------------
    // WEIGHT routers (4 rows) -> NoC
    // ------------------------------------
    input  wire [3:0]                 weight_in_valid,
    output wire [3:0]                 weight_in_ready,
    input  wire [4*WEIGHT_W-1:0]      weight_in_data,
    // Row-local 4-bit mask for each row router:
    // bit[c] targets PE(row, c), supports row-unicast/multicast/broadcast.
    input  wire [4*4-1:0]             weight_row_dst_mask,

    // ------------------------------------
    // PSUM routers (4 columns) <-> NoC
    // ------------------------------------
    // External column input (usually from south/previous cluster stage)
    input  wire [3:0]                 psum_col_in_valid,
    output wire [3:0]                 psum_col_in_ready,
    input  wire signed [4*PSUM_W-1:0] psum_col_in_data,
    // External column output (usually to north/next stage)
    output wire [3:0]                 psum_col_out_valid,
    input  wire [3:0]                 psum_col_out_ready,
    output wire signed [4*PSUM_W-1:0] psum_col_out_data,

    // ------------------------------------
    // PE-side iact sink interface (16 PEs)
    // ------------------------------------
    output wire [15:0]                pe_iact_valid,
    input  wire [15:0]                pe_iact_ready,
    output wire [16*IACT_W-1:0]       pe_iact_data,

    // ------------------------------------
    // PE-side weight sink interface (16 PEs)
    // ------------------------------------
    output wire [15:0]                pe_weight_valid,
    input  wire [15:0]                pe_weight_ready,
    output wire [16*WEIGHT_W-1:0]     pe_weight_data,

    // ------------------------------------
    // PE-side psum interfaces (16 PEs)
    // Vertical chain order: row3 -> row2 -> row1 -> row0.
    // pe_psum_in_*  : input to each PE from lower hop or external column input.
    // pe_psum_out_* : output from each PE to upper hop or external column output.
    // ------------------------------------
    output wire [15:0]                pe_psum_in_valid,
    input  wire [15:0]                pe_psum_in_ready,
    output wire signed [16*PSUM_W-1:0] pe_psum_in_data,

    input  wire [15:0]                pe_psum_out_valid,
    output wire [15:0]                pe_psum_out_ready,
    input  wire signed [16*PSUM_W-1:0] pe_psum_out_data
);

    wire [1:0] unused_layer_mode = layer_mode;
    wire [1:0] unused_prio_cfg = iact_router_prio;
    wire       unused_cfg_tieoff = unused_layer_mode[0] ^ unused_prio_cfg[0];

    PE4x4_IACT_Fabric #(
        .DATA_W(IACT_W)
    ) u_iact_fabric (
        .clk               (clk),
        .rst_n             (rst_n),
        .router_prio       (iact_router_prio),
        .in_valid          (iact_in_valid),
        .in_ready          (iact_in_ready),
        .in_data           (iact_in_data),
        .in_dst_mask       (iact_in_dst_mask),
        .pe_valid          (pe_iact_valid),
        .pe_ready          (pe_iact_ready),
        .pe_data           (pe_iact_data)
    );

    PE4x4_WEIGHT_RowFabric #(
        .DATA_W(WEIGHT_W)
    ) u_weight_fabric (
        .in_valid          (weight_in_valid),
        .in_ready          (weight_in_ready),
        .in_data           (weight_in_data),
        .row_dst_mask      (weight_row_dst_mask),
        .pe_valid          (pe_weight_valid),
        .pe_ready          (pe_weight_ready),
        .pe_data           (pe_weight_data)
    );

    PE4x4_PSUM_ColumnReduce #(
        .DATA_W(PSUM_W)
    ) u_psum_reduce (
        .col_in_valid      (psum_col_in_valid),
        .col_in_ready      (psum_col_in_ready),
        .col_in_data       (psum_col_in_data),
        .col_out_valid     (psum_col_out_valid),
        .col_out_ready     (psum_col_out_ready),
        .col_out_data      (psum_col_out_data),
        .pe_psum_in_valid  (pe_psum_in_valid),
        .pe_psum_in_ready  (pe_psum_in_ready),
        .pe_psum_in_data   (pe_psum_in_data),
        .pe_psum_out_valid (pe_psum_out_valid),
        .pe_psum_out_ready (pe_psum_out_ready),
        .pe_psum_out_data  (pe_psum_out_data)
    );

    wire _unused_keep = unused_cfg_tieoff;

endmodule


// ================================================================================================ //
// IACT fabric with lightweight elastic destination buffering.
//
// Final behavior:
// - Atomic source acceptance means a beat is accepted into all selected destination buffers.
// - PE consumption from those buffers is non-atomic.
// - A beat completes only when accepted_mask covers every bit in dst_mask.
// - Local buffering reduces stall sensitivity, but a full destination buffer can still block
//   the current beat.
// - Ready is generated from registered destination buffer state to avoid a long combinational
//   backpressure path.
//
// Practical choice for a 4x4 cluster:
// - single outstanding ingress beat per router
// - per-PE 1-entry skid buffer shared across all routers
// ================================================================================================ //
module PE4x4_IACT_Fabric #(
    parameter integer DATA_W = 13
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire [1:0]            router_prio,
    input  wire [3:0]            in_valid,
    output wire [3:0]            in_ready,
    input  wire [4*DATA_W-1:0]   in_data,
    input  wire [4*16-1:0]       in_dst_mask,
    output reg  [15:0]           pe_valid,
    input  wire [15:0]           pe_ready,
    output reg  [16*DATA_W-1:0]  pe_data
);
    localparam integer PE_COUNT = 16;
    localparam integer Q_DEPTH   = 2;

    reg [Q_DEPTH-1:0]                         q_valid;
    reg [3:0]                                 q_src;
    reg [PE_COUNT-1:0]                        q_dst_mask [0:Q_DEPTH-1];
    reg [PE_COUNT-1:0]                        q_accepted_mask [0:Q_DEPTH-1];
    reg [PE_COUNT*DATA_W-1:0]                 q_data [0:Q_DEPTH-1];

    reg [PE_COUNT-1:0]                        dest_buf_valid;
    reg [PE_COUNT*DATA_W-1:0]                 dest_buf_data;

    reg [3:0]                                 grant_src;
    reg [PE_COUNT-1:0]                        grant_dst_mask;
    reg [PE_COUNT-1:0]                        grant_src_dst_mask;

    integer p;

    wire [PE_COUNT-1:0] pe_fire = pe_valid & pe_ready;
    wire q0_complete = q_valid[0] && ((q_accepted_mask[0] | q_dst_mask[0]) == q_dst_mask[0]);
    wire q1_complete = q_valid[1] && ((q_accepted_mask[1] | q_dst_mask[1]) == q_dst_mask[1]);

    function [PE_COUNT-1:0] src_mask_for;
        input [3:0] src_idx;
        input [4*16-1:0] masks;
        begin
            src_mask_for = masks[(src_idx*16) +: 16];
        end
    endfunction

    function [3:0] select_router;
        input [3:0] vld;
        begin
            case (router_prio)
                2'd0: select_router = vld[0] ? 4'd0 : (vld[1] ? 4'd1 : (vld[2] ? 4'd2 : (vld[3] ? 4'd3 : 4'd0)));
                2'd1: select_router = vld[1] ? 4'd1 : (vld[2] ? 4'd2 : (vld[3] ? 4'd3 : (vld[0] ? 4'd0 : 4'd0)));
                2'd2: select_router = vld[2] ? 4'd2 : (vld[3] ? 4'd3 : (vld[0] ? 4'd0 : (vld[1] ? 4'd1 : 4'd0)));
                default: select_router = vld[3] ? 4'd3 : (vld[0] ? 4'd0 : (vld[1] ? 4'd1 : (vld[2] ? 4'd2 : 4'd0)));
            endcase
        end
    endfunction

    function [PE_COUNT-1:0] conflict_free_mask;
        input [3:0] src;
        input [PE_COUNT-1:0] mask0;
        input [PE_COUNT-1:0] mask1;
        input [PE_COUNT-1:0] mask2;
        input [PE_COUNT-1:0] mask3;
        reg [PE_COUNT-1:0] chosen;
        integer i;
        begin
            chosen = 16'b0;
            for (i = 0; i < PE_COUNT; i = i + 1) begin
                case (src)
                    4'd0: if (mask0[i] && !chosen[i]) chosen[i] = 1'b1;
                    4'd1: if (mask1[i] && !chosen[i]) chosen[i] = 1'b1;
                    4'd2: if (mask2[i] && !chosen[i]) chosen[i] = 1'b1;
                    4'd3: if (mask3[i] && !chosen[i]) chosen[i] = 1'b1;
                endcase
            end
            conflict_free_mask = chosen;
        end
    endfunction

    reg [PE_COUNT-1:0] q0_free_next;
    reg [PE_COUNT-1:0] q1_free_next;
    reg [3:0]          can_accept_src;
    reg                q0_adv;
    reg                q1_adv;
    reg                issue0;
    reg                issue1;
    reg [3:0]          sel0;
    reg [3:0]          sel1;
    reg [PE_COUNT-1:0] sel0_mask;
    reg [PE_COUNT-1:0] sel1_mask;
    reg [PE_COUNT-1:0] in_mask0;
    reg [PE_COUNT-1:0] in_mask1;
    reg [PE_COUNT-1:0] in_mask2;
    reg [PE_COUNT-1:0] in_mask3;

    always @(*) begin
        in_mask0 = src_mask_for(4'd0, in_dst_mask);
        in_mask1 = src_mask_for(4'd1, in_dst_mask);
        in_mask2 = src_mask_for(4'd2, in_dst_mask);
        in_mask3 = src_mask_for(4'd3, in_dst_mask);

        q0_adv = q0_complete;
        q1_adv = q0_adv && q1_complete;

        q0_free_next = (~dest_buf_valid) | pe_fire;
        q1_free_next = q0_free_next;

        can_accept_src[0] = in_valid[0] && (((in_mask0 & ~q0_free_next) == 16'b0) || (!q_valid[0] && !q_valid[1]));
        can_accept_src[1] = in_valid[1] && (((in_mask1 & ~q0_free_next) == 16'b0) || (!q_valid[0] && !q_valid[1]));
        can_accept_src[2] = in_valid[2] && (((in_mask2 & ~q0_free_next) == 16'b0) || (!q_valid[0] && !q_valid[1]));
        can_accept_src[3] = in_valid[3] && (((in_mask3 & ~q0_free_next) == 16'b0) || (!q_valid[0] && !q_valid[1]));

        sel0 = select_router(can_accept_src);
        sel1 = 4'd0;
        if ((|can_accept_src) && !(can_accept_src[sel0])) begin
            sel1 = 4'd0;
        end

        // Build a single granted source for this cycle; one beat is issued into slot 0,
        // and slot 1 is used as the 2-deep ingress cushion when the queue is occupied.
        grant_src = 4'd0;
        grant_dst_mask = 16'b0;
        grant_src_dst_mask = 16'b0;
        if (!q_valid[0]) begin
            grant_src = sel0;
            case (sel0)
                4'd0: grant_src_dst_mask = in_mask0;
                4'd1: grant_src_dst_mask = in_mask1;
                4'd2: grant_src_dst_mask = in_mask2;
                4'd3: grant_src_dst_mask = in_mask3;
            endcase
            grant_dst_mask = grant_src_dst_mask;
        end else if (!q_valid[1] && q0_complete) begin
            grant_src = sel0;
            case (sel0)
                4'd0: grant_src_dst_mask = in_mask0;
                4'd1: grant_src_dst_mask = in_mask1;
                4'd2: grant_src_dst_mask = in_mask2;
                4'd3: grant_src_dst_mask = in_mask3;
            endcase
            grant_dst_mask = grant_src_dst_mask;
        end

        in_ready[0] = in_valid[0] && (grant_src == 4'd0 || (!q_valid[0] && !q_valid[1]));
        in_ready[1] = in_valid[1] && (grant_src == 4'd1 || (!q_valid[0] && !q_valid[1]));
        in_ready[2] = in_valid[2] && (grant_src == 4'd2 || (!q_valid[0] && !q_valid[1]));
        in_ready[3] = in_valid[3] && (grant_src == 4'd3 || (!q_valid[0] && !q_valid[1]));
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            q_valid <= 2'b00;
            q_src[0] <= 1'b0;
            q_src[1] <= 1'b0;
            q_dst_mask[0] <= 16'b0;
            q_dst_mask[1] <= 16'b0;
            q_accepted_mask[0] <= 16'b0;
            q_accepted_mask[1] <= 16'b0;
            q_data[0] <= {PE_COUNT*DATA_W{1'b0}};
            q_data[1] <= {PE_COUNT*DATA_W{1'b0}};
            dest_buf_valid <= 16'b0;
            dest_buf_data <= {PE_COUNT*DATA_W{1'b0}};
            pe_valid <= 16'b0;
            pe_data <= {PE_COUNT*DATA_W{1'b0}};
        end else begin
            // Local per-PE skid buffers. A selected destination may still block this beat if full.
            for (p = 0; p < PE_COUNT; p = p + 1) begin
                if (dest_buf_valid[p] && pe_ready[p]) begin
                    dest_buf_valid[p] <= 1'b0;
                end
            end

            // Advance / compact the 2-deep ingress queue.
            if (q_valid[0] && q0_complete) begin
                q_valid[0] <= q_valid[1];
                q_src[0] <= q_src[1];
                q_dst_mask[0] <= q_dst_mask[1];
                q_accepted_mask[0] <= q_accepted_mask[1];
                q_data[0] <= q_data[1];
                q_valid[1] <= 1'b0;
                q_src[1] <= 1'b0;
                q_dst_mask[1] <= 16'b0;
                q_accepted_mask[1] <= 16'b0;
                q_data[1] <= {PE_COUNT*DATA_W{1'b0}};
            end

            // Issue a new ingress beat into the first free queue slot.
            if (|in_valid && ((~q_valid) != 2'b00)) begin
                if (!q_valid[0]) begin
                    q_valid[0] <= 1'b1;
                    q_src[0] <= grant_src;
                    q_dst_mask[0] <= grant_dst_mask;
                    q_accepted_mask[0] <= 16'b0;
                    q_data[0] <= {PE_COUNT*DATA_W{1'b0}};
                    q_data[0][(grant_src*DATA_W) +: DATA_W] <= in_data[(grant_src*DATA_W) +: DATA_W];
                end else if (!q_valid[1] && q0_complete) begin
                    q_valid[1] <= 1'b1;
                    q_src[1] <= grant_src;
                    q_dst_mask[1] <= grant_dst_mask;
                    q_accepted_mask[1] <= 16'b0;
                    q_data[1] <= {PE_COUNT*DATA_W{1'b0}};
                    q_data[1][(grant_src*DATA_W) +: DATA_W] <= in_data[(grant_src*DATA_W) +: DATA_W];
                end
            end

            // Per-destination enqueue into local skid buffer and accepted-mask update.
            for (p = 0; p < PE_COUNT; p = p + 1) begin
                if (q_valid[0] && q_dst_mask[0][p] && !q_accepted_mask[0][p] && !dest_buf_valid[p]) begin
                    dest_buf_valid[p] <= 1'b1;
                    dest_buf_data[(p*DATA_W) +: DATA_W] <= q_data[0][(q_src[0]*DATA_W) +: DATA_W];
                    q_accepted_mask[0][p] <= 1'b1;
                end else if (q_valid[1] && q_dst_mask[1][p] && !q_accepted_mask[1][p] && !dest_buf_valid[p]) begin
                    dest_buf_valid[p] <= 1'b1;
                    dest_buf_data[(p*DATA_W) +: DATA_W] <= q_data[1][(q_src[1]*DATA_W) +: DATA_W];
                    q_accepted_mask[1][p] <= 1'b1;
                end

                pe_valid[p] <= dest_buf_valid[p];
                pe_data[(p*DATA_W) +: DATA_W] <= dest_buf_data[(p*DATA_W) +: DATA_W];
            end
        end
    end

endmodule


// ================================================================================================ //
// Weight row-restricted fabric.
//
// Router r can only drive row r (PE indices r*4 + [0..3]).
// This enforces row-stationary horizontal reuse and avoids all-to-all over-connect.
// ================================================================================================ //
module PE4x4_WEIGHT_RowFabric #(
    parameter integer DATA_W = 24
)(
    input  wire [3:0]            in_valid,
    output wire [3:0]            in_ready,
    input  wire [4*DATA_W-1:0]   in_data,
    input  wire [4*4-1:0]        row_dst_mask,
    output wire [15:0]           pe_valid,
    input  wire [15:0]           pe_ready,
    output wire [16*DATA_W-1:0]  pe_data
);
    genvar r, c;
    generate
        for (r = 0; r < 4; r = r + 1) begin : gen_rows
            wire [3:0] row_mask = row_dst_mask[(r*4) +: 4];
            wire [3:0] row_vld  = {4{in_valid[r]}} & row_mask;
            wire [3:0] row_rdy;
            wire       row_fire;

            for (c = 0; c < 4; c = c + 1) begin : gen_cols
                localparam integer PE_IDX = (r*4) + c;
                assign pe_valid[PE_IDX] = row_vld[c] & row_fire;
                assign pe_data[(PE_IDX*DATA_W) +: DATA_W] = in_data[(r*DATA_W) +: DATA_W];
                assign row_rdy[c] = pe_ready[PE_IDX] | ~row_vld[c];
            end

            assign in_ready[r] = &row_rdy;
            assign row_fire   = in_valid[r] & in_ready[r];
        end
    endgenerate
endmodule


// ================================================================================================ //
// PSUM vertical column reduction network wiring.
//
// For each column c:
// - External input feeds bottom PE (row3, c)
// - PE(row3,c) -> PE(row2,c) -> PE(row1,c) -> PE(row0,c)
// - Top PE output is exported to external column output
// ================================================================================================ //
module PE4x4_PSUM_ColumnReduce #(
    parameter integer DATA_W = 21
)(
    input  wire [3:0]                  col_in_valid,
    output wire [3:0]                  col_in_ready,
    input  wire signed [4*DATA_W-1:0]  col_in_data,
    output wire [3:0]                  col_out_valid,
    input  wire [3:0]                  col_out_ready,
    output wire signed [4*DATA_W-1:0]  col_out_data,
    output wire [15:0]                 pe_psum_in_valid,
    input  wire [15:0]                 pe_psum_in_ready,
    output wire signed [16*DATA_W-1:0] pe_psum_in_data,
    input  wire [15:0]                 pe_psum_out_valid,
    output wire [15:0]                 pe_psum_out_ready,
    input  wire signed [16*DATA_W-1:0] pe_psum_out_data
);
    // PE index helper: idx(row,col) = row*4 + col, row=0 top, row=3 bottom.
    genvar c;
    generate
        for (c = 0; c < 4; c = c + 1) begin : gen_col
            localparam integer IDX_R0 = (0*4) + c;
            localparam integer IDX_R1 = (1*4) + c;
            localparam integer IDX_R2 = (2*4) + c;
            localparam integer IDX_R3 = (3*4) + c;

            // Bottom PE gets external column input.
            assign pe_psum_in_valid[IDX_R3] = col_in_valid[c];
            assign pe_psum_in_data[(IDX_R3*DATA_W) +: DATA_W] = col_in_data[(c*DATA_W) +: DATA_W];
            assign col_in_ready[c] = pe_psum_in_ready[IDX_R3];

            // Internal upward forwarding.
            assign pe_psum_in_valid[IDX_R2] = pe_psum_out_valid[IDX_R3];
            assign pe_psum_in_data[(IDX_R2*DATA_W) +: DATA_W] = pe_psum_out_data[(IDX_R3*DATA_W) +: DATA_W];
            assign pe_psum_out_ready[IDX_R3] = pe_psum_in_ready[IDX_R2];

            assign pe_psum_in_valid[IDX_R1] = pe_psum_out_valid[IDX_R2];
            assign pe_psum_in_data[(IDX_R1*DATA_W) +: DATA_W] = pe_psum_out_data[(IDX_R2*DATA_W) +: DATA_W];
            assign pe_psum_out_ready[IDX_R2] = pe_psum_in_ready[IDX_R1];

            assign pe_psum_in_valid[IDX_R0] = pe_psum_out_valid[IDX_R1];
            assign pe_psum_in_data[(IDX_R0*DATA_W) +: DATA_W] = pe_psum_out_data[(IDX_R1*DATA_W) +: DATA_W];
            assign pe_psum_out_ready[IDX_R1] = pe_psum_in_ready[IDX_R0];

            // Top PE exits cluster.
            assign col_out_valid[c] = pe_psum_out_valid[IDX_R0];
            assign col_out_data[(c*DATA_W) +: DATA_W] = pe_psum_out_data[(IDX_R0*DATA_W) +: DATA_W];
            assign pe_psum_out_ready[IDX_R0] = col_out_ready[c];
        end
    endgenerate
endmodule
