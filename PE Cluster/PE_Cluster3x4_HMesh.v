// ================================================================================================ //
// 3x4 PE cluster local fabric.
// Layout mapping: PE index = row * 4 + col, with rows=3 and cols=4.
//
// The controller sends data, masks, load/MAC controls, and clear pulses.
// HMesh fans data into the 12 PEs and returns only the status bits the
// controller needs.
// ================================================================================================ //

module PE_Cluster3x4_HMesh (
    input  wire                        clk,
    input  wire                        rst,

    // Three physical IACT lanes, each carrying two independently-routed packets:
    // lane0={slot0,slot1}, lane1={slot2,slot3}, lane2={slot4,slot5}.
    input  wire [5:0]                  iact_addr_slot_valid_in,
    output wire [5:0]                  iact_addr_slot_ready_out,
    input  wire [29:0]                 iact_addr_data_in,
    input  wire [71:0]                 iact_addr_dst_mask_in,

    input  wire [5:0]                  iact_data_slot_valid_in,
    output wire [5:0]                  iact_data_slot_ready_out,
    input  wire [71:0]                 iact_data_in,
    input  wire [71:0]                 iact_data_dst_mask_in,

    input  wire [2:0]                  weight_addr_valid_in,
    output wire [2:0]                  weight_addr_ready_out,
    input  wire [20:0]                 weight_addr_in,
    input  wire [11:0]                 weight_addr_row_dst_mask_in,

    input  wire [2:0]                  weight_data_valid_in,
    output wire [2:0]                  weight_data_ready_out,
    input  wire [71:0]                 weight_data_in,
    input  wire [11:0]                 weight_data_row_dst_mask_in,

    input  wire [3:0]                  psum_col_valid_in,
    output wire [3:0]                  psum_col_ready_out,
    input  wire signed [167:0]         psum_col_data_in,
    output wire [3:0]                  psum_col_valid_out,
    input  wire [3:0]                  psum_col_ready_in,
    output wire signed [167:0]         psum_col_data_out,

    input  wire [11:0]                 pe_disable_in,
    input  wire                        psum_enq_en_in,
    input  wire                        do_load_en_in,
    input  wire                        do_mac_en_in,
    input  wire                        iact_write_fin_clear_in,
    input  wire                        weight_write_fin_clear_in,
    input  wire                        psum_spad_clear_in,

    input  wire [4:0]                  ctrl_cfg_segment_len_in,
    input  wire [3:0]                  ctrl_cfg_window_seg_count_in,
    input  wire [5:0]                  ctrl_cfg_m0_in,
    input  wire                        ctrl_cfg_iact_flush_in,
    input  wire                        ctrl_cfg_slide_commit_in,

    // -------------------------------------------------------------------------------------------- //
    // Per-PE status from Processing_Element (packed by PE index)
    // -------------------------------------------------------------------------------------------- //
    output wire [11:0]                 pe_iact_addr_write_fin_out,
    output wire [11:0]                 pe_iact_data_write_fin_out,
    output wire [11:0]                 pe_weight_addr_write_fin_out,
    output wire [11:0]                 pe_weight_data_write_fin_out,
    output wire [11:0]                 pe_psum_acc_fin_out,
    output wire [11:0]                 pe_slide_safe_out,
    output wire [11:0]                 pe_cal_fin_out
);
    localparam integer PE_ROWS = 3;
    localparam integer PE_COLS = 4;
    localparam integer PE_COUNT = PE_ROWS * PE_COLS;
    localparam integer WEIGHT_ROUTER_N = 3;
    localparam integer IACT_ADDR_W = 5;  // matches Processing_Element_core_pipeline ($clog2(16)+1)
    localparam integer IACT_DATA_W = 12;
    localparam integer IACT_PHYSICAL_LANE_COUNT = 3;
    localparam integer IACT_PACKETS_PER_LANE = 2;
    localparam integer IACT_SLOT_COUNT = IACT_PHYSICAL_LANE_COUNT * IACT_PACKETS_PER_LANE;
    localparam integer IACT_DATA_SLOT_COUNT = IACT_SLOT_COUNT;
    localparam integer WEIGHT_ADDR_W = 7;
    localparam integer WEIGHT_DATA_W = 24;
    localparam integer PSUM_W = 42;

    // NOC-F2: strip disabled PEs from all route masks before fabric ingress.
    wire [PE_COUNT-1:0] active_pe_mask_w = ~pe_disable_in;

    wire [PE_COUNT-1:0]               pe_iact_addr_valid_w;
    wire [PE_COUNT-1:0]               pe_iact_addr_ready_w;
    wire [PE_COUNT*IACT_ADDR_W-1:0]   pe_iact_addr_data_w;
    wire [PE_COUNT-1:0]               pe_iact_data_valid_w;
    wire [PE_COUNT-1:0]               pe_iact_data_ready_w;
    wire [PE_COUNT*IACT_DATA_W-1:0]   pe_iact_data_data_w;

    localparam integer IACT_ADDR_SLOT_COUNT = IACT_SLOT_COUNT;

    wire [IACT_ADDR_SLOT_COUNT*PE_COUNT-1:0]    iact_addr_dst_mask_active_w;
    wire [IACT_DATA_SLOT_COUNT*PE_COUNT-1:0]    iact_data_dst_mask_active_w;

    wire [PE_COUNT-1:0]                          weight_addr_row_dst_mask_active_w;
    wire [PE_COUNT-1:0]                          weight_data_row_dst_mask_active_w;
    wire [PE_COUNT-1:0]               pe_weight_addr_valid_w;
    wire [PE_COUNT-1:0]               pe_weight_addr_ready_w;
    wire [PE_COUNT*WEIGHT_ADDR_W-1:0] pe_weight_addr_data_w;
    wire [PE_COUNT-1:0]               pe_weight_data_valid_w;
    wire [PE_COUNT-1:0]               pe_weight_data_ready_w;
    wire [PE_COUNT*WEIGHT_DATA_W-1:0] pe_weight_data_data_w;

    wire [PE_COUNT-1:0]               pe_psum_router_ready_w;
    wire [PE_COUNT-1:0]               pe_psum_in_valid_w;
    wire [PE_COUNT-1:0]               pe_psum_in_ready_w;
    wire signed [PE_COUNT*PSUM_W-1:0] pe_psum_in_data_w;
    wire [PE_COUNT-1:0]               pe_psum_out_valid_w;
    wire [PE_COUNT-1:0]               pe_psum_out_ready_w;
    wire signed [PE_COUNT*PSUM_W-1:0] pe_psum_out_data_w;

    wire [PE_COUNT-1:0] pe_iact_addr_write_fin_w;
    wire [PE_COUNT-1:0] pe_iact_data_write_fin_w;
    wire [PE_COUNT-1:0] pe_weight_addr_write_fin_w;
    wire [PE_COUNT-1:0] pe_weight_data_write_fin_w;
    wire [PE_COUNT-1:0] pe_psum_acc_fin_w;
    wire [PE_COUNT-1:0] pe_slide_safe_w;
    wire [PE_COUNT-1:0] pe_cal_fin_w;
    wire [PE_COUNT-1:0] pe_load_en_w;
    wire [PE_COUNT-1:0] pe_mac_en_w;
    wire [PE_COUNT-1:0] pe_psum_enq_w;

    // ColumnReduce pe_psum_in_ready[*] must track each PE input-side ready (from wrapper).
    assign pe_psum_in_ready_w         = pe_psum_router_ready_w;

    // PE status tap
    assign pe_iact_addr_write_fin_out   = pe_iact_addr_write_fin_w;
    assign pe_iact_data_write_fin_out   = pe_iact_data_write_fin_w;
    assign pe_weight_addr_write_fin_out = pe_weight_addr_write_fin_w;
    assign pe_weight_data_write_fin_out = pe_weight_data_write_fin_w;
    assign pe_psum_acc_fin_out          = pe_psum_acc_fin_w;
    assign pe_slide_safe_out            = pe_slide_safe_w;
    assign pe_cal_fin_out               = pe_cal_fin_w;

    genvar iact_addr_slot_g;
    generate
        for (iact_addr_slot_g = 0; iact_addr_slot_g < IACT_ADDR_SLOT_COUNT; iact_addr_slot_g = iact_addr_slot_g + 1) begin : gen_iact_addr_active_mask
            assign iact_addr_dst_mask_active_w[(iact_addr_slot_g*PE_COUNT) +: PE_COUNT] =
                iact_addr_dst_mask_in[(iact_addr_slot_g*PE_COUNT) +: PE_COUNT] & active_pe_mask_w;
        end
    endgenerate

    PE3x4_IACT_Atomic_Mask_Fabric #(
        .PE_ROWS(PE_ROWS), .PE_COLS(PE_COLS), .SRC_COUNT(IACT_ADDR_SLOT_COUNT), .DATA_W(IACT_ADDR_W)
    ) u_iact_addr_fabric (
        .src_valid_in(iact_addr_slot_valid_in),
        .src_ready_out(iact_addr_slot_ready_out),
        .src_data_in(iact_addr_data_in),
        .src_dst_mask_in(iact_addr_dst_mask_active_w),
        .active_pe_mask_in(active_pe_mask_w),
        .pe_valid_out(pe_iact_addr_valid_w),
        .pe_ready_in(pe_iact_addr_ready_w),
        .pe_data_out(pe_iact_addr_data_w)
    );

    genvar iact_data_slot_g;
    generate
        for (iact_data_slot_g = 0; iact_data_slot_g < IACT_DATA_SLOT_COUNT;
             iact_data_slot_g = iact_data_slot_g + 1) begin : gen_iact_data_active_mask
            assign iact_data_dst_mask_active_w[(iact_data_slot_g*PE_COUNT) +: PE_COUNT] =
                iact_data_dst_mask_in[(iact_data_slot_g*PE_COUNT) +: PE_COUNT] & active_pe_mask_w;
        end
    endgenerate

    PE3x4_IACT_Atomic_Mask_Fabric #(
        .PE_ROWS(PE_ROWS), .PE_COLS(PE_COLS), .SRC_COUNT(IACT_DATA_SLOT_COUNT), .DATA_W(IACT_DATA_W)
    ) u_iact_data_fabric (
        .src_valid_in(iact_data_slot_valid_in),
        .src_ready_out(iact_data_slot_ready_out),
        .src_data_in(iact_data_in),
        .src_dst_mask_in(iact_data_dst_mask_active_w),
        .active_pe_mask_in(active_pe_mask_w),
        .pe_valid_out(pe_iact_data_valid_w),
        .pe_ready_in(pe_iact_data_ready_w),
        .pe_data_out(pe_iact_data_data_w)
    );

    assign weight_addr_row_dst_mask_active_w = weight_addr_row_dst_mask_in & active_pe_mask_w;
    assign weight_data_row_dst_mask_active_w = weight_data_row_dst_mask_in & active_pe_mask_w;

    PE3x4_WEIGHT_RowFabric #(
        .PE_ROWS(PE_ROWS), .PE_COLS(PE_COLS), .SRC_COUNT(PE_ROWS), .DATA_W(WEIGHT_ADDR_W)
    ) u_weight_addr_fabric (
        .clk(clk),
        .rst(rst),
        .src_valid_in(weight_addr_valid_in),
        .src_ready_out(weight_addr_ready_out),
        .src_data_in(weight_addr_in),
        .row_dst_mask_in(weight_addr_row_dst_mask_active_w),
        .pe_valid_out(pe_weight_addr_valid_w),
        .pe_ready_in(pe_weight_addr_ready_w),
        .pe_data_out(pe_weight_addr_data_w)
    );

    PE3x4_WEIGHT_RowFabric #(
        .PE_ROWS(PE_ROWS), .PE_COLS(PE_COLS), .SRC_COUNT(PE_ROWS), .DATA_W(WEIGHT_DATA_W)
    ) u_weight_data_fabric (
        .clk(clk),
        .rst(rst),
        .src_valid_in(weight_data_valid_in),
        .src_ready_out(weight_data_ready_out),
        .src_data_in(weight_data_in),
        .row_dst_mask_in(weight_data_row_dst_mask_active_w),
        .pe_valid_out(pe_weight_data_valid_w),
        .pe_ready_in(pe_weight_data_ready_w),
        .pe_data_out(pe_weight_data_data_w)
    );

    PE3x4_PSUM_ColumnReduce #(
        .PE_ROWS(PE_ROWS), .PE_COLS(PE_COLS), .DATA_W(PSUM_W)
    ) u_psum_column_reduce (
        .col_in_valid(psum_col_valid_in),
        .col_in_ready(psum_col_ready_out),
        .col_in_data(psum_col_data_in),
        .col_out_valid(psum_col_valid_out),
        .col_out_ready(psum_col_ready_in),
        .col_out_data(psum_col_data_out),
        .pe_psum_in_valid(pe_psum_in_valid_w),
        .pe_psum_in_ready(pe_psum_in_ready_w),
        .pe_psum_in_data(pe_psum_in_data_w),
        .pe_psum_out_valid(pe_psum_out_valid_w),
        .pe_psum_out_ready(pe_psum_out_ready_w),
        .pe_psum_out_data(pe_psum_out_data_w)
    );

    genvar pe_idx;
    generate
        for (pe_idx = 0; pe_idx < PE_COUNT; pe_idx = pe_idx + 1) begin : gen_pe
            // do_load_en / do_mac_en are explicit cluster dataflow gates.
            assign pe_load_en_w[pe_idx]  = do_load_en_in  & ~pe_disable_in[pe_idx];
            assign pe_mac_en_w[pe_idx]   = do_mac_en_in   & ~pe_disable_in[pe_idx];
            assign pe_psum_enq_w[pe_idx] = psum_enq_en_in & ~pe_disable_in[pe_idx];

            Processing_Element pe_inst (
                .clk(clk),
                .rst(rst),

                .psum_router_ready_out(pe_psum_router_ready_w[pe_idx]),
                .psum_router_valid_in(pe_psum_in_valid_w[pe_idx]),
                .psum_router_data_in(pe_psum_in_data_w[(pe_idx*PSUM_W) +: PSUM_W]),
                .psum_router_ready_in(pe_psum_out_ready_w[pe_idx]),
                .psum_router_valid_out(pe_psum_out_valid_w[pe_idx]),
                .psum_router_data_out(pe_psum_out_data_w[(pe_idx*PSUM_W) +: PSUM_W]),

                .iact_router_addr_ready_out(pe_iact_addr_ready_w[pe_idx]),
                .iact_router_addr_valid_in(pe_iact_addr_valid_w[pe_idx]),
                .iact_router_addr_in(pe_iact_addr_data_w[(pe_idx*IACT_ADDR_W) +: IACT_ADDR_W]),
                .iact_router_data_ready_out(pe_iact_data_ready_w[pe_idx]),
                .iact_router_data_valid_in(pe_iact_data_valid_w[pe_idx]),
                .iact_router_data_in(pe_iact_data_data_w[(pe_idx*IACT_DATA_W) +: IACT_DATA_W]),

                .weight_router_addr_ready_out(pe_weight_addr_ready_w[pe_idx]),
                .weight_router_addr_valid_in(pe_weight_addr_valid_w[pe_idx]),
                .weight_router_addr_in(pe_weight_addr_data_w[(pe_idx*WEIGHT_ADDR_W) +: WEIGHT_ADDR_W]),
                .weight_router_data_ready_out(pe_weight_data_ready_w[pe_idx]),
                .weight_router_data_valid_in(pe_weight_data_valid_w[pe_idx]),
                .weight_router_data_in(pe_weight_data_data_w[(pe_idx*WEIGHT_DATA_W) +: WEIGHT_DATA_W]),

                .ctrl_status_iact_address_write_fin_out(pe_iact_addr_write_fin_w[pe_idx]),
                .ctrl_status_iact_data_write_fin_out(pe_iact_data_write_fin_w[pe_idx]),
                .ctrl_status_weight_address_write_fin_out(pe_weight_addr_write_fin_w[pe_idx]),
                .ctrl_status_weight_data_write_fin_out(pe_weight_data_write_fin_w[pe_idx]),
                .ctrl_status_psum_acc_fin_out(pe_psum_acc_fin_w[pe_idx]),
                .ctrl_status_slide_safe_out(pe_slide_safe_w[pe_idx]),

                .cluster_ctrl_psum_enq_en_in(pe_psum_enq_w[pe_idx]),
                .cluster_ctrl_psum_passthrough_en_in(pe_disable_in[pe_idx]),
                .cluster_ctrl_load_en_in(pe_load_en_w[pe_idx]),
                .cluster_ctrl_mac_en_in(pe_mac_en_w[pe_idx]),
                .ctrl_status_cal_fin_out(pe_cal_fin_w[pe_idx]),

                .iact_write_fin_clear(iact_write_fin_clear_in),
                .weight_write_fin_clear(weight_write_fin_clear_in),
                .all_write_fin(),

                .psum_spad_clear(psum_spad_clear_in),
                .ctrl_cfg_segment_len_in(ctrl_cfg_segment_len_in),
                .ctrl_cfg_window_seg_count_in(ctrl_cfg_window_seg_count_in),
                .ctrl_cfg_m0_in(ctrl_cfg_m0_in),
                .ctrl_cfg_iact_flush_in(ctrl_cfg_iact_flush_in),
                .ctrl_cfg_slide_commit_in(ctrl_cfg_slide_commit_in)
            );
        end
    endgenerate

endmodule
