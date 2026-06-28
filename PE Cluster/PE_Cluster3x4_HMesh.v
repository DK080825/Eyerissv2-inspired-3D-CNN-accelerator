// ================================================================================================ //
// 3x4 PE cluster top with parameterized intra-cluster NoC.
// Layout mapping: PE index = row * 4 + col, with rows=3 and cols=4.
//
// Processing_Element production control (all 12 PEs):
//   cluster_ctrl_load_en_in             = do_load_en_in & ~pe_disable_in[pe]
//   cluster_ctrl_mac_en_in              = do_mac_en_in  & ~pe_disable_in[pe]
//   cluster_ctrl_psum_enq_en_in         = psum_enq_en_in & ~pe_disable_in[pe] (P1a)
//   ctrl_status_cal_fin_out               = core MAC completion (PE wrapper)
//
// layer_mode_in: reserved — no HMesh routing/FSM behavior; |layer_mode_in| only silences lint.
//
// Cluster sticky status (compatibility until Dataflow audit):
//   all_write_fin_out / all_cal_fin_out use OR-accumulated write_fin_r / cal_fin_r
//   (includes pe_disable_in). Per-PE live aggregates deferred (see P1b).
// ================================================================================================ //

module PE_Cluster3x4_HMesh #(
    parameter integer ENABLE_POOL = 1
) (
    input  wire                        clk,
    input  wire                        rst,

    input  wire [1:0]                  layer_mode_in,
    input  wire [1:0]                  iact_router_prio_in,

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

    input  wire                        psum_col_sel_in,
    input  wire [3:0]                  psum_col_valid_from_router_in,
    output wire [3:0]                  psum_col_ready_from_router_out,
    input  wire signed [167:0]         psum_col_data_from_router_in,
    input  wire [3:0]                  psum_col_valid_from_south_in,
    output wire [3:0]                  psum_col_ready_from_south_out,
    input  wire signed [167:0]         psum_col_data_from_south_in,
    output wire [3:0]                  psum_col_valid_out,
    input  wire [3:0]                  psum_col_ready_in,
    output wire signed [167:0]         psum_col_data_out,

    input  wire [11:0]                 pe_disable_in,
    input  wire                        psum_enq_en_in,
    input  wire                        do_load_en_in,
    input  wire                        do_mac_en_in,
    input  wire                        iact_write_fin_clear_in,
    input  wire                        weight_write_fin_clear_in,
    input  wire [4:0]                  psum_depth_in,
    input  wire                        psum_spad_clear_in,
    output wire                        all_write_fin_out,
    output wire                        all_cal_fin_out,

    input  wire [4:0]                  ctrl_cfg_window_size_in,
    input  wire [4:0]                  ctrl_cfg_segment_len_in,
    input  wire [3:0]                  ctrl_cfg_window_seg_count_in,
    input  wire [4:0]                  ctrl_cfg_psum_base_in,
    input  wire [5:0]                  ctrl_cfg_m0_in,
    input  wire                        ctrl_cfg_iact_flush_in,
    input  wire                        ctrl_cfg_slide_commit_in,

    input  wire [11:0]                 pool_cmp_en_in,
    input  wire [11:0]                 pool_cmp_stop_in,
    input  wire [11:0]                 pool_elem_valid_in,
    output wire [11:0]                 pool_elem_ready_out,
    input  wire signed [95:0]          pool_elem_data_in,
    input  wire [11:0]                 pool_win_first_in,
    input  wire [11:0]                 pool_win_last_in,
    output wire [11:0]                 pool_out_valid_out,
    input  wire [11:0]                 pool_out_ready_in,
    output wire signed [95:0]          pool_out_data_out,

    // -------------------------------------------------------------------------------------------- //
    // Per-PE observability: fabric <-> PE router interface (packed by PE index)
    // -------------------------------------------------------------------------------------------- //
    output wire [11:0]                 pe_iact_addr_valid_out,
    output wire [11:0]                 pe_iact_addr_ready_out,
    output wire [59:0]                 pe_iact_addr_data_out,
    output wire [11:0]                 pe_iact_data_valid_out,
    output wire [11:0]                 pe_iact_data_ready_out,
    output wire [143:0]                pe_iact_data_out,
    output wire [11:0]                 pe_weight_addr_valid_out,
    output wire [11:0]                 pe_weight_addr_ready_out,
    output wire [83:0]                 pe_weight_addr_data_out,
    output wire [11:0]                 pe_weight_data_valid_out,
    output wire [11:0]                 pe_weight_data_ready_out,
    output wire [287:0]                pe_weight_data_out,

    output wire [11:0]                 pe_psum_router_ready_out,
    output wire [11:0]                 pe_psum_in_valid_out,
    output wire [11:0]                 pe_psum_in_ready_out,
    output wire signed [503:0]         pe_psum_in_data_out,
    output wire [11:0]                 pe_psum_out_valid_out,
    output wire [11:0]                 pe_psum_out_ready_out,
    output wire signed [503:0]         pe_psum_out_data_out,

    // -------------------------------------------------------------------------------------------- //
    // Per-PE status from Processing_Element (packed by PE index)
    // -------------------------------------------------------------------------------------------- //
    output wire [11:0]                 pe_iact_addr_write_fin_out,
    output wire [11:0]                 pe_iact_data_write_fin_out,
    output wire [11:0]                 pe_weight_addr_write_fin_out,
    output wire [11:0]                 pe_weight_data_write_fin_out,
    output wire [11:0]                 pe_psum_acc_fin_out,
    output wire [11:0]                 pe_slide_safe_out,
    output wire [11:0]                 pe_all_write_fin_out,
    output wire [11:0]                 pe_cal_fin_out,
    output wire [11:0]                 pe_load_en_out,

    // Cluster FSM sticky flags (per PE, OR-accumulated)
    output wire [11:0]                 pe_write_fin_sticky_out,
    output wire [11:0]                 pe_cal_fin_sticky_out
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
    localparam integer POOL_W = 8;

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
    wire [PE_COUNT-1:0] pe_all_write_fin_w;
    wire [PE_COUNT-1:0] pe_cal_fin_w;
    wire [PE_COUNT-1:0] pe_load_en_w;
    wire [PE_COUNT-1:0] pe_mac_en_w;
    wire [PE_COUNT-1:0] pe_psum_enq_w;

    wire [3:0]                 psum_col_in_valid_w;
    wire [3:0]                 psum_col_in_ready_w;
    wire signed [167:0]        psum_col_in_data_w;
    wire [3:0]                 psum_col_out_valid_w;
    wire signed [167:0]        psum_col_out_data_w;

    assign psum_col_in_valid_w = psum_col_sel_in ? psum_col_valid_from_router_in : psum_col_valid_from_south_in;
    assign psum_col_in_data_w  = psum_col_sel_in ? psum_col_data_from_router_in : psum_col_data_from_south_in;
    assign psum_col_ready_from_router_out = psum_col_sel_in ? psum_col_in_ready_w : 4'b0;
    assign psum_col_ready_from_south_out  = psum_col_sel_in ? 4'b0 : psum_col_in_ready_w;
    assign psum_col_valid_out             = psum_col_out_valid_w;
    assign psum_col_data_out              = psum_col_out_data_w;

    // Fabric <-> PE tap (packed buses)
    assign pe_iact_addr_valid_out   = pe_iact_addr_valid_w;
    assign pe_iact_addr_ready_out   = pe_iact_addr_ready_w;
    assign pe_iact_addr_data_out    = pe_iact_addr_data_w;
    assign pe_iact_data_valid_out   = pe_iact_data_valid_w;
    assign pe_iact_data_ready_out   = pe_iact_data_ready_w;
    assign pe_iact_data_out         = pe_iact_data_data_w;
    assign pe_weight_addr_valid_out = pe_weight_addr_valid_w;
    assign pe_weight_addr_ready_out = pe_weight_addr_ready_w;
    assign pe_weight_addr_data_out  = pe_weight_addr_data_w;
    assign pe_weight_data_valid_out = pe_weight_data_valid_w;
    assign pe_weight_data_ready_out = pe_weight_data_ready_w;
    assign pe_weight_data_out       = pe_weight_data_data_w;

    assign pe_psum_router_ready_out = pe_psum_router_ready_w;
    // ColumnReduce pe_psum_in_ready[*] must track each PE input-side ready (from wrapper).
    assign pe_psum_in_ready_w         = pe_psum_router_ready_w;
    assign pe_psum_in_valid_out     = pe_psum_in_valid_w;
    assign pe_psum_in_ready_out     = pe_psum_in_ready_w;
    assign pe_psum_in_data_out      = pe_psum_in_data_w;
    assign pe_psum_out_valid_out    = pe_psum_out_valid_w;
    assign pe_psum_out_ready_out    = pe_psum_out_ready_w;
    assign pe_psum_out_data_out     = pe_psum_out_data_w;

    // PE status tap
    assign pe_iact_addr_write_fin_out   = pe_iact_addr_write_fin_w;
    assign pe_iact_data_write_fin_out   = pe_iact_data_write_fin_w;
    assign pe_weight_addr_write_fin_out = pe_weight_addr_write_fin_w;
    assign pe_weight_data_write_fin_out = pe_weight_data_write_fin_w;
    assign pe_psum_acc_fin_out          = pe_psum_acc_fin_w;
    assign pe_slide_safe_out            = pe_slide_safe_w;
    assign pe_all_write_fin_out         = pe_all_write_fin_w;
    assign pe_cal_fin_out               = pe_cal_fin_w;
    assign pe_load_en_out               = pe_load_en_w;

    reg  [PE_COUNT-1:0] write_fin_r;
    reg  [PE_COUNT-1:0] cal_fin_r;

    assign all_write_fin_out        = &write_fin_r;
    assign all_cal_fin_out          = &cal_fin_r;
    assign pe_write_fin_sticky_out  = write_fin_r;
    assign pe_cal_fin_sticky_out    = cal_fin_r;

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
        .router_prio_in(2'b00),
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
        .router_prio_in(iact_router_prio_in),
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
        .col_in_valid(psum_col_in_valid_w),
        .col_in_ready(psum_col_in_ready_w),
        .col_in_data(psum_col_in_data_w),
        .col_out_valid(psum_col_out_valid_w),
        .col_out_ready(psum_col_ready_in),
        .col_out_data(psum_col_out_data_w),
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

            Processing_Element #(
                .ENABLE_POOL(ENABLE_POOL)
            ) pe_inst (
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
                .all_write_fin(pe_all_write_fin_w[pe_idx]),

                .ctrl_cfg_psum_depth_in(psum_depth_in),
                .psum_spad_clear(psum_spad_clear_in),
                .ctrl_cfg_window_size_in(ctrl_cfg_window_size_in),
                .ctrl_cfg_segment_len_in(ctrl_cfg_segment_len_in),
                .ctrl_cfg_window_seg_count_in(ctrl_cfg_window_seg_count_in),
                .ctrl_cfg_psum_base_in(ctrl_cfg_psum_base_in),
                .ctrl_cfg_m0_in(ctrl_cfg_m0_in),
                .ctrl_cfg_iact_flush_in(ctrl_cfg_iact_flush_in),
                .ctrl_cfg_slide_commit_in(ctrl_cfg_slide_commit_in),

                .cluster_ctrl_pool_cmp_en_in(pool_cmp_en_in[pe_idx]),
                .cluster_ctrl_pool_cmp_stop_in(pool_cmp_stop_in[pe_idx]),
                .pool_router_elem_valid_in(pool_elem_valid_in[pe_idx]),
                .pool_router_elem_ready_out(pool_elem_ready_out[pe_idx]),
                .pool_router_elem_data_in(pool_elem_data_in[(pe_idx*POOL_W) +: POOL_W]),
                .pool_router_win_first_in(pool_win_first_in[pe_idx]),
                .pool_router_win_last_in(pool_win_last_in[pe_idx]),
                .pool_router_out_valid_out(pool_out_valid_out[pe_idx]),
                .pool_router_out_ready_in(pool_out_ready_in[pe_idx]),
                .pool_router_out_data_out(pool_out_data_out[(pe_idx*POOL_W) +: POOL_W])
            );
        end
    endgenerate

    always @(posedge clk) begin
        if (rst) begin
            write_fin_r <= {PE_COUNT{1'b0}};
            cal_fin_r   <= {PE_COUNT{1'b0}};
        end else if (all_cal_fin_out) begin
            write_fin_r <= {PE_COUNT{1'b0}};
            cal_fin_r   <= {PE_COUNT{1'b0}};
        end else begin
            write_fin_r <= write_fin_r | pe_all_write_fin_w | pe_disable_in;
            cal_fin_r   <= cal_fin_r   | pe_cal_fin_w       | pe_disable_in;
        end
    end
endmodule
