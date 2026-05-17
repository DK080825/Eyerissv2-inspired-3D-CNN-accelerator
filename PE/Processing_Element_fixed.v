// ====================================================================================================== //
// Top-level PE wrapper around Processing_Element_core_pipeline.
// Handles FIFO buffering, sticky write-finish tracking, controller sequencing,
// and external streaming interfaces.
// ====================================================================================================== //

module Processing_Element (
    input  wire                   clk,
    input  wire                   rst,

    output wire                   psum_router_ready_out,
    input  wire                   psum_router_valid_in,
    input  wire signed [20:0]     psum_router_data_in,
    input  wire                   psum_router_ready_in,
    output wire                   psum_router_valid_out,
    output wire signed [20:0]     psum_router_data_out,

    output wire                   iact_router_addr_ready_out,
    input  wire                   iact_router_addr_valid_in,
    input  wire [7:0]             iact_router_addr_in,

    output wire                   iact_router_data_ready_out,
    input  wire                   iact_router_data_valid_in,
    input  wire [12:0]            iact_router_data_in,

    output wire                   weight_router_addr_ready_out,
    input  wire                   weight_router_addr_valid_in,
    input  wire [6:0]             weight_router_addr_in,

    output wire                   weight_router_data_ready_out,
    input  wire                   weight_router_data_valid_in,
    input  wire [23:0]            weight_router_data_in,

    output wire                   ctrl_status_iact_address_write_fin_out,
    output wire                   ctrl_status_iact_data_write_fin_out,
    output wire                   ctrl_status_weight_address_write_fin_out,
    output wire                   ctrl_status_weight_data_write_fin_out,
    output wire                   ctrl_status_psum_acc_fin_out,
    output wire                   ctrl_status_slide_safe_out,

    input  wire                   cluster_ctrl_psum_enq_en_in,
    input  wire                   cluster_ctrl_load_en_in,
    output wire                   ctrl_status_cal_fin_out,

    input  wire                   iact_write_fin_clear,
    input  wire                   weight_write_fin_clear,
    output wire                   all_write_fin,
    output wire 

    input  wire [4:0]             ctrl_cfg_psum_depth_in,
    input  wire                   psum_spad_clear,

    input  wire [4:0]             ctrl_cfg_window_size_in,
    input  wire [4:0]             ctrl_cfg_segment_len_in,
    input  wire [3:0]             ctrl_cfg_window_seg_count_in,
    input  wire [4:0]             ctrl_cfg_psum_base_in,
    input  wire [5:0]             ctrl_cfg_m0_in,
    input  wire                   ctrl_cfg_iact_flush_in,
    input  wire                   ctrl_cfg_slide_commit_in,

    input  wire                   cluster_ctrl_pool_cmp_en_in,
    input  wire                   cluster_ctrl_pool_cmp_stop_in,
    input  wire                   pool_router_elem_valid_in,
    output wire                   pool_router_elem_ready_out,
    input  wire signed [7:0]      pool_router_elem_data_in,
    input  wire                   pool_router_win_first_in,
    input  wire                   pool_router_win_last_in,
    output wire                   pool_router_out_valid_out,
    input  wire                   pool_router_out_ready_in,
    output wire signed [7:0]      pool_router_out_data_out
);

//
// ==================================================================== //
//                              Parameters                              //
// ==================================================================== //
//
parameter IACT_ADDR_DATA_WIDTH   = 8;    // iact address width
parameter IACT_DATA_DATA_WIDTH   = 13;   // iact data = 8-bit value + 5-bit count
parameter WEIGHT_ADDR_DATA_WIDTH = 7;    // weight address width
parameter WEIGHT_DATA_DATA_WIDTH = 24;   // packed 2-lane weight word

//
// ==================================================================== //
//                              Wires                                   //
// ==================================================================== //
//

// ------------------------------------
// PE ctrl module
// ------------------------------------
// signal to controller
wire                core_ctrl_status_psum_acc_fin_w;
wire                ctr_cluster_ctrl_mac_en_w;
wire                ctr_cluster_ctrl_psum_enq_en_w;
wire                ctr_cluster_ctrl_load_en_w;
wire                core_ctrl_status_cal_fin_w;
wire                top_psum_enq_en_w;
wire                top_do_load_en_w;
wire                top_cal_fin_w;
wire                top_all_write_fin_w;

// ------------------------------------
// PE core module
// ------------------------------------
wire                core_ctrl_status_slide_safe_w;
wire                core_psum_router_ready_w;
wire                core_psum_router_valid_in_w;
wire signed [20:0]  core_psum_router_data_in_w;
wire                core_psum_router_ready_in_w;
wire                core_psum_router_valid_out_w;
wire signed [20:0]  core_psum_router_data_out_w;
wire                core_pool_router_elem_ready_w;
wire                core_pool_router_out_valid_w;
wire signed [7:0]   core_pool_router_out_data_w;

wire                core_iact_router_addr_valid_w;
wire        [7:0]   core_iact_router_addr_w;
wire                core_iact_router_addr_ready_w;
wire                core_iact_router_data_valid_w;
wire        [12:0]  core_iact_router_data_w;
wire                core_iact_router_data_ready_w;

wire                core_weight_router_addr_valid_w;
wire        [7:0]   core_weight_router_addr_w;
wire                core_weight_router_addr_ready_w;
wire                core_weight_router_data_valid_w;
wire        [23:0]  core_weight_router_data_w;
wire                core_weight_router_data_ready_w;

wire                core_ctrl_status_iact_address_write_fin_w;
wire                core_ctrl_status_iact_data_write_fin_w;
wire                core_ctrl_status_weight_address_write_fin_w;
wire                core_ctrl_status_weight_data_write_fin_w;
wire                core_ctrl_status_psum_acc_fin_w;

// ------------------------------------
// FIFO - iact address
// ------------------------------------
wire                FIFO_iact_address_in_ready;
wire                FIFO_iact_address_in_valid;
wire        [7:0]   FIFO_iact_address_in;
wire                FIFO_iact_address_out_ready;
wire                FIFO_iact_address_out_valid;
wire        [7:0]   FIFO_iact_address_out;

// ------------------------------------
// FIFO - iact data
// ------------------------------------
wire                FIFO_iact_data_in_ready;
wire                FIFO_iact_data_in_valid;
wire        [12:0]  FIFO_iact_data_in;
wire                FIFO_iact_data_out_ready;
wire                FIFO_iact_data_out_valid;
wire        [12:0]  FIFO_iact_data_out;

// ------------------------------------
// FIFO - weight address
// ------------------------------------
wire                FIFO_weight_address_in_ready;
wire                FIFO_weight_address_in_valid;
wire        [6:0]   FIFO_weight_address_in;
wire                FIFO_weight_address_out_ready;
wire                FIFO_weight_address_out_valid;
wire        [6:0]   FIFO_weight_address_out;

// ------------------------------------
// FIFO - weight data
// ------------------------------------
wire                FIFO_weight_data_in_ready;
wire                FIFO_weight_data_in_valid;
wire        [23:0]  FIFO_weight_data_in;
wire                FIFO_weight_data_out_ready;
wire                FIFO_weight_data_out_valid;
wire        [23:0]  FIFO_weight_data_out;

// ------------------------------------
// FIFO - psum in
// ------------------------------------
wire                FIFO_in_psum_in_ready;
wire                FIFO_in_psum_in_valid;
wire signed [20:0]  FIFO_in_psum_in;
wire                FIFO_in_psum_out_ready;
wire                FIFO_in_psum_out_valid;
wire signed [20:0]  FIFO_in_psum_out;

// ------------------------------------
// FIFO - psum out
// ------------------------------------
wire                FIFO_out_psum_in_ready;
wire                FIFO_out_psum_in_valid;
wire signed [20:0]  FIFO_out_psum_in;
wire                FIFO_out_psum_out_ready;
wire                FIFO_out_psum_out_valid;
wire signed [20:0]  FIFO_out_psum_out;

//
// ==================================================================== //
//                              Registers                               //
// ==================================================================== //
//
reg iact_addr_write_fin_r;
reg iact_data_write_fin_r;
reg weight_addr_write_fin_r;
reg weight_data_write_fin_r;

//
// ==================================================================== //
//                              Instantiation                           //
// ==================================================================== //
//

// ------------------------------------
// PE controller
// ------------------------------------
Processing_Element_Controller Processing_Element_Controller_inst (
    .clk                          (clk),
    .rst                          (rst),
    .top_psum_enq_en_in             (top_psum_enq_en_w),
    .top_do_load_en_in              (top_do_load_en_w),
    .core_ctrl_status_cal_fin_in    (core_ctrl_status_cal_fin_w),
    .core_ctrl_status_psum_acc_fin_in (core_ctrl_status_psum_acc_fin_w),
    .top_all_write_fin_in           (top_all_write_fin_w),
    .cluster_ctrl_mac_en_out        (ctr_cluster_ctrl_mac_en_w),
    .cluster_ctrl_psum_enq_en_out   (ctr_cluster_ctrl_psum_enq_en_w),
    .cluster_ctrl_load_en_out       (ctr_cluster_ctrl_load_en_w),
    .top_cal_fin_out                (top_cal_fin_w)
);

// ------------------------------------
// PE core
// ------------------------------------
Processing_Element_core_pipeline Processing_Element_core_inst (
    .clk                               (clk),
    .rst                               (rst),
    .psum_router_ready_out             (core_psum_router_ready_w),
    .psum_router_valid_in              (core_psum_router_valid_in_w),
    .psum_router_data_in               (core_psum_router_data_in_w),
    .psum_router_ready_in              (core_psum_router_ready_in_w),
    .psum_router_valid_out             (core_psum_router_valid_out_w),
    .psum_router_data_out              (core_psum_router_data_out_w),
    .iact_router_addr_valid_in         (core_iact_router_addr_valid_w),
    .iact_router_addr_in               (core_iact_router_addr_w),
    .iact_router_addr_ready_out        (core_iact_router_addr_ready_w),
    .iact_router_data_valid_in         (core_iact_router_data_valid_w),
    .iact_router_data_in               (core_iact_router_data_w),
    .iact_router_data_ready_out        (core_iact_router_data_ready_w),
    .weight_router_addr_valid_in       (core_weight_router_addr_valid_w),
    .weight_router_addr_in             (core_weight_router_addr_w),
    .weight_router_addr_ready_out      (core_weight_router_addr_ready_w),
    .weight_router_data_valid_in       (core_weight_router_data_valid_w),
    .weight_router_data_in             (core_weight_router_data_w),
    .weight_router_data_ready_out      (core_weight_router_data_ready_w),
    .cluster_ctrl_mac_en_in            (ctr_cluster_ctrl_mac_en_w),
    .cluster_ctrl_psum_enq_en_in       (ctr_cluster_ctrl_psum_enq_en_w),
    .cluster_ctrl_load_en_in           (ctr_cluster_ctrl_load_en_w),
    .ctrl_status_cal_fin_out           (core_ctrl_status_cal_fin_w),
    .ctrl_status_slide_safe_out        (core_ctrl_status_slide_safe_w),
    .ctrl_status_iact_address_write_fin_out (core_ctrl_status_iact_address_write_fin_w),
    .ctrl_status_iact_data_write_fin_out    (core_ctrl_status_iact_data_write_fin_w),
    .ctrl_status_weight_address_write_fin_out (core_ctrl_status_weight_address_write_fin_w),
    .ctrl_status_weight_data_write_fin_out    (core_ctrl_status_weight_data_write_fin_w),
    .ctrl_status_psum_acc_fin_out      (core_ctrl_status_psum_acc_fin_in_w),
    .ctrl_cfg_psum_depth_in            (PSUM_DEPTH),
    .ctrl_cfg_psum_spad_clear_in       (psum_spad_clear),
    .ctrl_cfg_window_size_in           (ctrl_cfg_window_size_in),
    .ctrl_cfg_segment_len_in           (ctrl_cfg_segment_len_in),
    .ctrl_cfg_window_seg_count_in      (ctrl_cfg_window_seg_count_in),
    .ctrl_cfg_psum_base_in             (ctrl_cfg_psum_base_in),
    .ctrl_cfg_m0_in                    (ctrl_cfg_m0_in),
    .ctrl_cfg_iact_flush_in            (ctrl_cfg_iact_flush_in),
    .ctrl_cfg_slide_commit_in          (ctrl_cfg_slide_commit_in),
    .cluster_ctrl_pool_cmp_en_in       (pool_cmp_en),
    .cluster_ctrl_pool_cmp_stop_in     (pool_cmp_stop),
    .pool_router_elem_valid_in         (pool_elem_in_valid),
    .pool_router_elem_ready_out        (core_pool_router_elem_ready_w),
    .pool_router_elem_data_in          (pool_elem_in),
    .pool_router_win_first_in          (pool_win_first),
    .pool_router_win_last_in           (pool_win_last),
    .pool_router_out_valid_out         (core_pool_router_out_valid_w),
    .pool_router_out_ready_in          (pool_out_ready),
    .pool_router_out_data_out          (core_pool_router_out_data_w)
);

// ------------------------------------
// FIFO for iact address
// ------------------------------------
PE_data_FIFO #(
    .DATA_IN_WIDTH(IACT_ADDR_DATA_WIDTH)
) iact_addr_FIFO (
    .clk            (clk),
    .rst            (rst),
    .data_in_ready  (FIFO_iact_address_in_ready),
    .data_in_valid  (FIFO_iact_address_in_valid),
    .data_in        (FIFO_iact_address_in),
    .data_out_ready (FIFO_iact_address_out_ready),
    .data_out_valid (FIFO_iact_address_out_valid),
    .data_out       (FIFO_iact_address_out)
);

// ------------------------------------
// FIFO for iact data
// ------------------------------------
PE_data_FIFO #(
    .DATA_IN_WIDTH(IACT_DATA_DATA_WIDTH)
) iact_data_FIFO (
    .clk            (clk),
    .rst            (rst),
    .data_in_ready  (FIFO_iact_data_in_ready),
    .data_in_valid  (FIFO_iact_data_in_valid),
    .data_in        (FIFO_iact_data_in),
    .data_out_ready (FIFO_iact_data_out_ready),
    .data_out_valid (FIFO_iact_data_out_valid),
    .data_out       (FIFO_iact_data_out)
);

// ------------------------------------
// FIFO for weight address
// ------------------------------------
PE_data_FIFO #(
    .DATA_IN_WIDTH(WEIGHT_ADDR_DATA_WIDTH)
) weight_addr_FIFO (
    .clk            (clk),
    .rst            (rst),
    .data_in_ready  (FIFO_weight_address_in_ready),
    .data_in_valid  (FIFO_weight_address_in_valid),
    .data_in        (FIFO_weight_address_in),
    .data_out_ready (FIFO_weight_address_out_ready),
    .data_out_valid (FIFO_weight_address_out_valid),
    .data_out       (FIFO_weight_address_out)
);

// ------------------------------------
// FIFO for weight data
// ------------------------------------
PE_data_FIFO #(
    .DATA_IN_WIDTH(WEIGHT_DATA_DATA_WIDTH)
) weight_data_FIFO (
    .clk            (clk),
    .rst            (rst),
    .data_in_ready  (FIFO_weight_data_in_ready),
    .data_in_valid  (FIFO_weight_data_in_valid),
    .data_in        (FIFO_weight_data_in),
    .data_out_ready (FIFO_weight_data_out_ready),
    .data_out_valid (FIFO_weight_data_out_valid),
    .data_out       (FIFO_weight_data_out)
);

// ------------------------------------
// FIFO for psum in
// ------------------------------------
PE_psum_FIFO psum_in_FIFO (
    .clk            (clk),
    .rst            (rst),
    .data_in_ready  (FIFO_in_psum_in_ready),
    .data_in_valid  (FIFO_in_psum_in_valid),
    .data_in        (FIFO_in_psum_in),
    .data_out_ready (FIFO_in_psum_out_ready),
    .data_out_valid (FIFO_in_psum_out_valid),
    .data_out       (FIFO_in_psum_out)
);

// ------------------------------------
// FIFO for psum out
// ------------------------------------
PE_psum_FIFO psum_out_FIFO (
    .clk            (clk),
    .rst            (rst),
    .data_in_ready  (FIFO_out_psum_in_ready),
    .data_in_valid  (FIFO_out_psum_in_valid),
    .data_in        (FIFO_out_psum_in),
    .data_out_ready (FIFO_out_psum_out_ready),
    .data_out_valid (FIFO_out_psum_out_valid),
    .data_out       (FIFO_out_psum_out)
);

//
// ==================================================================== //
//                              Combinational                           //
// ==================================================================== //
//

// ------------------------------------
// top-level outputs
// ------------------------------------


assign all_write_fin           = iact_addr_write_fin_r & iact_data_write_fin_r &
                                  weight_addr_write_fin_r & weight_data_write_fin_r;
assign psum_in_ready            = FIFO_in_psum_in_ready;
assign psum_out_valid           = FIFO_out_psum_out_valid;
assign psum_out                 = FIFO_out_psum_out;
assign iact_address_in_ready    = FIFO_iact_address_in_ready;
assign iact_data_in_ready       = FIFO_iact_data_in_ready;
assign weight_address_in_ready  = FIFO_weight_address_in_ready;
assign weight_data_in_ready     = FIFO_weight_data_in_ready;
assign iact_address_write_fin   = iact_addr_write_fin_r;
assign iact_data_write_fin      = iact_data_write_fin_r;
assign weight_address_write_fin = weight_addr_write_fin_r;
assign weight_data_write_fin    = weight_data_write_fin_r;
assign psum_add_fin             = core_ctrl_status_psum_acc_fin_w;
assign cal_fin                  = top_cal_fin_w;
assign pool_elem_in_ready       = core_pool_router_elem_ready_w;
assign pool_out_valid           = core_pool_router_out_valid_w;
assign pool_out                 = core_pool_router_out_data_w;
assign ctrl_status_slide_safe_out = core_ctrl_status_slide_safe_w;

// ------------------------------------
// controller connections
// ------------------------------------
// add signal to controller
assign top_psum_enq_en_w   = psum_enq_en;
assign top_do_load_en_w    = do_load_en;
assign top_all_write_fin_w = all_write_fin;

assign core_psum_router_valid_in_w  = FIFO_in_psum_out_valid;
assign core_psum_router_data_in_w   = FIFO_in_psum_out;
assign FIFO_in_psum_out_ready       = core_psum_router_ready_w;
assign FIFO_out_psum_in_valid       = core_psum_router_valid_out_w;
assign FIFO_out_psum_in             = core_psum_router_data_out_w;
assign core_psum_router_ready_in_w  = FIFO_out_psum_out_ready;

assign core_iact_router_addr_valid_w = FIFO_iact_address_out_valid;
assign core_iact_router_addr_w       = FIFO_iact_address_out;
assign FIFO_iact_address_out_ready   = core_iact_router_addr_ready_w;
assign core_iact_router_data_valid_w  = FIFO_iact_data_out_valid;
assign core_iact_router_data_w        = FIFO_iact_data_out;
assign FIFO_iact_data_out_ready      = core_iact_router_data_ready_w;

assign core_weight_router_addr_valid_w = FIFO_weight_address_out_valid;
assign core_weight_router_addr_w       = FIFO_weight_address_out;
assign FIFO_weight_address_out_ready   = core_weight_router_addr_ready_w;
assign core_weight_router_data_valid_w  = FIFO_weight_data_out_valid;
assign core_weight_router_data_w        = FIFO_weight_data_out;
assign FIFO_weight_data_out_ready      = core_weight_router_data_ready_w;

//
// ==================================================================== //
//                              Sequential                              //
// ==================================================================== //
//

always @(posedge clk) begin
    if (rst) begin
        iact_addr_write_fin_r <= 1'b0;
        iact_data_write_fin_r <= 1'b0;
    end else if (iact_write_fin_clear) begin
        iact_addr_write_fin_r <= 1'b0;
        iact_data_write_fin_r <= 1'b0;
    end else begin
        iact_addr_write_fin_r <= iact_addr_write_fin_r | core_ctrl_status_iact_address_write_fin_w;
        iact_data_write_fin_r <= iact_data_write_fin_r | core_ctrl_status_iact_data_write_fin_w;
    end
end

always @(posedge clk) begin
    if (rst) begin
        weight_addr_write_fin_r <= 1'b0;
        weight_data_write_fin_r <= 1'b0;
    end else if (weight_write_fin_clear) begin
        weight_addr_write_fin_r <= 1'b0;
        weight_data_write_fin_r <= 1'b0;
    end else begin
        weight_addr_write_fin_r <= weight_addr_write_fin_r | core_ctrl_status_weight_address_write_fin_w;
        weight_data_write_fin_r <= weight_data_write_fin_r | core_ctrl_status_weight_data_write_fin_w;
    end
end

endmodule