// ============================================================================
// Module      : Processing_Element
// Author      : Do Quoc Khanh
// Description : Top-level PE wrapper around Processing_Element_core_pipeline.
//               Provides FIFO-backed router ports, load-phase pop gating, and
//               PSUM input/output decoupling.
//               Cluster control drives load, MAC, slide, and PSUM merge through
//               this wrapper while the core performs local sparse computation.
// ============================================================================

module Processing_Element (
    input  wire                  clk,
    input  wire                  rst,

    output wire                  psum_router_ready_out,
    input  wire                  psum_router_valid_in,
    input  wire signed [41:0]    psum_router_data_in,
    input  wire                  psum_router_ready_in,
    output wire                  psum_router_valid_out,
    output wire signed [41:0]    psum_router_data_out,

    output wire                  iact_router_addr_ready_out,
    input  wire                  iact_router_addr_valid_in,
    input  wire [4:0]            iact_router_addr_in,

    output wire                  iact_router_data_ready_out,
    input  wire                  iact_router_data_valid_in,
    input  wire [11:0]           iact_router_data_in,

    output wire                  weight_router_addr_ready_out,
    input  wire                  weight_router_addr_valid_in,
    input  wire [6:0]            weight_router_addr_in,

    output wire                  weight_router_data_ready_out,
    input  wire                  weight_router_data_valid_in,
    input  wire [23:0]           weight_router_data_in,

    output wire                  ctrl_status_iact_address_write_fin_out,
    output wire                  ctrl_status_iact_data_write_fin_out,
    output wire                  ctrl_status_weight_address_write_fin_out,
    output wire                  ctrl_status_weight_data_write_fin_out,
    output wire                  ctrl_status_psum_acc_fin_out,
    output wire                  ctrl_status_slide_safe_out,

    input  wire                  cluster_ctrl_external_control_en_in,
    input  wire                  cluster_ctrl_psum_enq_en_in,
    input  wire                  cluster_ctrl_psum_passthrough_en_in,
    input  wire                  cluster_ctrl_load_en_in,
    input  wire                  cluster_ctrl_load_session_in,
    input  wire                  cluster_ctrl_mac_en_in,
    output wire                  ctrl_status_cal_fin_out,

    input  wire                  iact_write_fin_clear,
    input  wire                  weight_write_fin_clear,
    output wire                  all_write_fin,

    input  wire [4:0]            ctrl_cfg_psum_depth_in,
    input  wire                  psum_spad_clear,

    input  wire [4:0]            ctrl_cfg_window_size_in,
    input  wire [4:0]            ctrl_cfg_segment_len_in,
    input  wire [3:0]            ctrl_cfg_window_seg_count_in,
    input  wire [4:0]            ctrl_cfg_psum_base_in,
    input  wire [5:0]            ctrl_cfg_m0_in,
    input  wire                  ctrl_cfg_iact_flush_in,
    input  wire                  ctrl_cfg_slide_commit_in,

    input  wire                  cluster_ctrl_pool_cmp_en_in,
    input  wire                  cluster_ctrl_pool_cmp_stop_in,
    input  wire                  pool_router_elem_valid_in,
    output wire                  pool_router_elem_ready_out,
    input  wire signed [7:0]     pool_router_elem_data_in,
    input  wire                  pool_router_win_first_in,
    input  wire                  pool_router_win_last_in,
    output wire                  pool_router_out_valid_out,
    input  wire                  pool_router_out_ready_in,
    output wire signed [7:0]     pool_router_out_data_out
);

parameter integer IACT_ADDR_DATA_WIDTH   = 5;
parameter integer IACT_DATA_DATA_WIDTH   = 12;
parameter integer WEIGHT_ADDR_DATA_WIDTH  = 7;
parameter integer WEIGHT_DATA_DATA_WIDTH  = 24;
parameter integer ENABLE_POOL             = 1;

wire psum_router_ready_core_w;
wire psum_router_valid_core_w;
wire signed [41:0] psum_router_data_core_w;
wire psum_merge_out_pending_w;

wire iact_addr_valid_w;
wire iact_addr_ready_w;
wire [4:0] iact_addr_data_w;

wire iact_data_valid_w;
wire iact_data_ready_w;
wire [11:0] iact_data_data_w;

wire weight_addr_valid_w;
wire weight_addr_ready_w;
wire [6:0] weight_addr_data_w;

wire weight_data_valid_w;
wire weight_data_ready_w;
wire [23:0] weight_data_data_w;

wire ctrl_status_iact_address_write_fin_w;
wire ctrl_status_iact_data_write_fin_w;
wire ctrl_status_weight_address_write_fin_w;
wire ctrl_status_weight_data_write_fin_w;
wire ctrl_status_psum_acc_fin_w;
wire ctrl_status_slide_safe_w;
wire ctrl_status_cal_fin_w;

wire core_pool_elem_ready_w;
wire core_pool_out_valid_w;
wire signed [7:0] core_pool_out_data_w;

reg iact_addr_write_fin_r;
reg iact_data_write_fin_r;
reg weight_addr_write_fin_r;
reg weight_data_write_fin_r;

wire top_psum_enq_en_w;
wire cluster_ctrl_psum_enq_en_w;
wire cluster_ctrl_psum_enq_core_w;

wire fifo_iact_addr_in_ready_w;
wire fifo_iact_addr_in_valid_w;
wire [4:0] fifo_iact_addr_in_w;
wire fifo_iact_addr_out_ready_w;
wire fifo_iact_addr_out_valid_w;
wire [4:0] fifo_iact_addr_out_w;

wire fifo_iact_data_in_ready_w;
wire fifo_iact_data_in_valid_w;
wire [11:0] fifo_iact_data_in_w;
wire fifo_iact_data_out_ready_w;
wire fifo_iact_data_out_valid_w;
wire [11:0] fifo_iact_data_out_w;

wire fifo_weight_addr_in_ready_w;
wire fifo_weight_addr_in_valid_w;
wire [6:0] fifo_weight_addr_in_w;
wire fifo_weight_addr_out_ready_w;
wire fifo_weight_addr_out_valid_w;
wire [6:0] fifo_weight_addr_out_w;

wire fifo_weight_data_in_ready_w;
wire fifo_weight_data_in_valid_w;
wire [23:0] fifo_weight_data_in_w;
wire fifo_weight_data_out_ready_w;
wire fifo_weight_data_out_valid_w;
wire [23:0] fifo_weight_data_out_w;

wire fifo_psum_in_in_ready_w;
wire fifo_psum_in_in_valid_w;
wire signed [41:0] fifo_psum_in_in_w;
wire fifo_psum_in_out_ready_w;
wire fifo_psum_in_out_valid_w;
wire signed [41:0] fifo_psum_in_out_w;

wire fifo_psum_out_fifo_in_ready_w;
wire fifo_psum_out_core_ready_w;
wire fifo_psum_out_in_valid_w;
wire signed [41:0] fifo_psum_out_in_w;
wire fifo_psum_out_out_ready_w;
wire fifo_psum_out_out_valid_w;
wire signed [41:0] fifo_psum_out_out_w;
wire psum_passthrough_w;

assign psum_passthrough_w = (cluster_ctrl_psum_passthrough_en_in === 1'b1);
assign top_psum_enq_en_w = cluster_ctrl_psum_enq_en_in;
// Merge starts reach core only via controller accept (no top bypass).
assign cluster_ctrl_psum_enq_core_w = cluster_ctrl_psum_enq_en_w;

assign all_write_fin = iact_addr_write_fin_r & iact_data_write_fin_r &
                       weight_addr_write_fin_r & weight_data_write_fin_r;
assign ctrl_status_iact_address_write_fin_out = iact_addr_write_fin_r;
assign ctrl_status_iact_data_write_fin_out    = iact_data_write_fin_r;
assign ctrl_status_weight_address_write_fin_out = weight_addr_write_fin_r;
assign ctrl_status_weight_data_write_fin_out  = weight_data_write_fin_r;
assign ctrl_status_psum_acc_fin_out           = ctrl_status_psum_acc_fin_w;
assign ctrl_status_slide_safe_out             = ctrl_status_slide_safe_w;
assign ctrl_status_cal_fin_out = ctrl_status_cal_fin_w;

// P0/P1: PSUM paths through FIFOs (no top-level bypass unless passthrough enabled).
// Safety rule: psum_passthrough_en_in may only change at tile/session boundaries.
// No PSUM transaction may be in flight when toggling the bypass mode.
assign psum_router_ready_out   = psum_passthrough_w ? psum_router_ready_in : fifo_psum_in_in_ready_w;
assign psum_router_valid_out   = psum_passthrough_w ? psum_router_valid_in  : fifo_psum_out_out_valid_w;
assign psum_router_data_out    = psum_passthrough_w ? psum_router_data_in   : fifo_psum_out_out_w;

assign pool_router_elem_ready_out = core_pool_elem_ready_w;
assign pool_router_out_valid_out  = core_pool_out_valid_w;
assign pool_router_out_data_out   = core_pool_out_data_w;

Processing_Element_Controller u_processing_element_controller (
    .clk                               (clk),
    .rst                               (rst),
    .top_psum_enq_en_in                (top_psum_enq_en_w),
    .core_ctrl_status_psum_acc_fin_in  (ctrl_status_psum_acc_fin_w),
    .cluster_ctrl_psum_enq_en_out      (cluster_ctrl_psum_enq_en_w)
);

Processing_Element_core_pipeline #(
    .ENABLE_POOL(ENABLE_POOL)
) u_processing_element_core_pipeline (
    .clk                               (clk),
    .rst                               (rst),
    .psum_router_ready_out             (psum_router_ready_core_w),
    .psum_router_valid_in              (fifo_psum_in_out_valid_w),
    .psum_router_data_in               (fifo_psum_in_out_w),
    .psum_router_ready_in              (fifo_psum_out_core_ready_w),
    .psum_router_valid_out             (psum_router_valid_core_w),
    .psum_router_data_out              (psum_router_data_core_w),
    .psum_merge_out_pending_out        (psum_merge_out_pending_w),
    .iact_router_addr_valid_in         (iact_addr_valid_w),
    .iact_router_addr_in               (iact_addr_data_w),
    .iact_router_addr_ready_out        (iact_addr_ready_w),
    .iact_router_data_valid_in         (iact_data_valid_w),
    .iact_router_data_in               (iact_data_data_w),
    .iact_router_data_ready_out        (iact_data_ready_w),
    .weight_router_addr_valid_in       (weight_addr_valid_w),
    .weight_router_addr_in             (weight_addr_data_w),
    .weight_router_addr_ready_out      (weight_addr_ready_w),
    .weight_router_data_valid_in       (weight_data_valid_w),
    .weight_router_data_in             (weight_data_data_w),
    .weight_router_data_ready_out      (weight_data_ready_w),
    .cluster_ctrl_mac_en_in            (cluster_ctrl_mac_en_in),
    .cluster_ctrl_psum_enq_en_in       (cluster_ctrl_psum_enq_core_w),
    .cluster_ctrl_load_en_in           (cluster_ctrl_load_en_in),
    .ctrl_status_cal_fin_out           (ctrl_status_cal_fin_w),
    .ctrl_status_slide_safe_out        (ctrl_status_slide_safe_w),
    .ctrl_status_iact_address_write_fin_out (ctrl_status_iact_address_write_fin_w),
    .ctrl_status_iact_data_write_fin_out    (ctrl_status_iact_data_write_fin_w),
    .ctrl_status_weight_address_write_fin_out (ctrl_status_weight_address_write_fin_w),
    .ctrl_status_weight_data_write_fin_out    (ctrl_status_weight_data_write_fin_w),
    .ctrl_status_psum_acc_fin_out      (ctrl_status_psum_acc_fin_w),
    .ctrl_cfg_psum_depth_in            (ctrl_cfg_psum_depth_in),
    .ctrl_cfg_psum_spad_clear_in       (psum_spad_clear),
    .ctrl_cfg_window_size_in           (ctrl_cfg_window_size_in),
    .ctrl_cfg_segment_len_in           (ctrl_cfg_segment_len_in),
    .ctrl_cfg_window_seg_count_in      (ctrl_cfg_window_seg_count_in),
    .ctrl_cfg_psum_base_in             (ctrl_cfg_psum_base_in),
    .ctrl_cfg_m0_in                    (ctrl_cfg_m0_in),
    .ctrl_cfg_iact_flush_in            (ctrl_cfg_iact_flush_in),
    .ctrl_cfg_slide_commit_in          (ctrl_cfg_slide_commit_in),
    .cluster_ctrl_pool_cmp_en_in       (cluster_ctrl_pool_cmp_en_in),
    .cluster_ctrl_pool_cmp_stop_in     (cluster_ctrl_pool_cmp_stop_in),
    .pool_router_elem_valid_in         (pool_router_elem_valid_in),
    .pool_router_elem_ready_out        (core_pool_elem_ready_w),
    .pool_router_elem_data_in          (pool_router_elem_data_in),
    .pool_router_win_first_in          (pool_router_win_first_in),
    .pool_router_win_last_in           (pool_router_win_last_in),
    .pool_router_out_valid_out         (core_pool_out_valid_w),
    .pool_router_out_ready_in          (pool_router_out_ready_in),
    .pool_router_out_data_out          (core_pool_out_data_w)
);

PE_data_FIFO #(.DATA_IN_WIDTH(IACT_ADDR_DATA_WIDTH)) u_iact_addr_fifo (
    .clk            (clk),
    .rst            (rst),
    .data_in_ready  (fifo_iact_addr_in_ready_w),
    .data_in_valid  (fifo_iact_addr_in_valid_w),
    .data_in        (fifo_iact_addr_in_w),
    .data_out_ready (fifo_iact_addr_out_ready_w),
    .data_out_valid (fifo_iact_addr_out_valid_w),
    .data_out       (fifo_iact_addr_out_w)
);

PE_data_FIFO #(.DATA_IN_WIDTH(IACT_DATA_DATA_WIDTH)) u_iact_data_fifo (
    .clk            (clk),
    .rst            (rst),
    .data_in_ready  (fifo_iact_data_in_ready_w),
    .data_in_valid  (fifo_iact_data_in_valid_w),
    .data_in        (fifo_iact_data_in_w),
    .data_out_ready (fifo_iact_data_out_ready_w),
    .data_out_valid (fifo_iact_data_out_valid_w),
    .data_out       (fifo_iact_data_out_w)
);

PE_data_FIFO #(.DATA_IN_WIDTH(WEIGHT_ADDR_DATA_WIDTH)) u_weight_addr_fifo (
    .clk            (clk),
    .rst            (rst),
    .data_in_ready  (fifo_weight_addr_in_ready_w),
    .data_in_valid  (fifo_weight_addr_in_valid_w),
    .data_in        (fifo_weight_addr_in_w),
    .data_out_ready (fifo_weight_addr_out_ready_w),
    .data_out_valid (fifo_weight_addr_out_valid_w),
    .data_out       (fifo_weight_addr_out_w)
);

PE_data_FIFO #(.DATA_IN_WIDTH(WEIGHT_DATA_DATA_WIDTH)) u_weight_data_fifo (
    .clk            (clk),
    .rst            (rst),
    .data_in_ready  (fifo_weight_data_in_ready_w),
    .data_in_valid  (fifo_weight_data_in_valid_w),
    .data_in        (fifo_weight_data_in_w),
    .data_out_ready (fifo_weight_data_out_ready_w),
    .data_out_valid (fifo_weight_data_out_valid_w),
    .data_out       (fifo_weight_data_out_w)
);

PE_psum_FIFO #(
    .DATA_WIDTH(42)
) u_psum_in_fifo (
    .clk            (clk),
    .rst            (rst),
    .data_in_ready  (fifo_psum_in_in_ready_w),
    .data_in_valid  (fifo_psum_in_in_valid_w),
    .data_in        (fifo_psum_in_in_w),
    .data_out_ready (fifo_psum_in_out_ready_w),
    .data_out_valid (fifo_psum_in_out_valid_w),
    .data_out       (fifo_psum_in_out_w)
);

PE_psum_FIFO #(
    .DATA_WIDTH(42),
    .BUFFER_DEPTH(16)
) u_psum_out_fifo (
    .clk            (clk),
    .rst            (rst),
    .data_in_ready  (fifo_psum_out_fifo_in_ready_w),
    .data_in_valid  (fifo_psum_out_in_valid_w),
    .data_in        (fifo_psum_out_in_w),
    .data_out_ready (fifo_psum_out_out_ready_w),
    .data_out_valid (fifo_psum_out_out_valid_w),
    .data_out       (fifo_psum_out_out_w)
);

// P1/P2: IACT ingress ready = FIFO input ready; pop only during active load before write_fin latch.
// Allow pop while slide_safe so row-slide append can stream after a latched write_fin.
wire iact_fifo_pop_allow_w =
    (~iact_addr_write_fin_r) | ctrl_status_slide_safe_w;
assign fifo_iact_addr_in_valid_w  = iact_router_addr_valid_in;
assign fifo_iact_addr_in_w        = iact_router_addr_in;
assign iact_router_addr_ready_out = fifo_iact_addr_in_ready_w;
assign iact_addr_valid_w          = fifo_iact_addr_out_valid_w;
assign iact_addr_data_w           = fifo_iact_addr_out_w;
assign fifo_iact_addr_out_ready_w = cluster_ctrl_load_en_in & iact_fifo_pop_allow_w &
                                    iact_addr_ready_w;

assign fifo_iact_data_in_valid_w  = iact_router_data_valid_in;
assign fifo_iact_data_in_w        = iact_router_data_in;
assign iact_router_data_ready_out = fifo_iact_data_in_ready_w;
assign iact_data_valid_w          = fifo_iact_data_out_valid_w;
assign iact_data_data_w           = fifo_iact_data_out_w;
assign fifo_iact_data_out_ready_w = cluster_ctrl_load_en_in & iact_fifo_pop_allow_w &
                                    iact_data_ready_w;

// P1/P2: Weight ingress backpressure + load-phase pop gating.
assign fifo_weight_addr_in_valid_w  = weight_router_addr_valid_in;
assign fifo_weight_addr_in_w        = weight_router_addr_in;
assign weight_router_addr_ready_out = fifo_weight_addr_in_ready_w;
assign weight_addr_valid_w          = fifo_weight_addr_out_valid_w;
assign weight_addr_data_w           = fifo_weight_addr_out_w;
assign fifo_weight_addr_out_ready_w = cluster_ctrl_load_en_in & (~weight_addr_write_fin_r) &
                                      weight_addr_ready_w;

assign fifo_weight_data_in_valid_w  = weight_router_data_valid_in;
assign fifo_weight_data_in_w        = weight_router_data_in;
assign weight_router_data_ready_out = fifo_weight_data_in_ready_w;
assign weight_data_valid_w          = fifo_weight_data_out_valid_w;
assign weight_data_data_w           = fifo_weight_data_out_w;
assign fifo_weight_data_out_ready_w = cluster_ctrl_load_en_in & (~weight_data_write_fin_r) &
                                      weight_data_ready_w;

// P1: PSUM in — top ready from FIFO in; core pop when core ready.
assign fifo_psum_in_in_valid_w  = psum_passthrough_w ? 1'b0 : psum_router_valid_in;
assign fifo_psum_in_in_w        = psum_router_data_in;
assign fifo_psum_in_out_ready_w = psum_passthrough_w ? 1'b0 : psum_router_ready_core_w;

// P0: PSUM out — core -> fifo in; top <- fifo out; downstream ready -> fifo out pop.
// Core merge backpressure must wait for downstream pop when FIFO holds a beat (not ~full alone).
assign fifo_psum_out_in_valid_w  = psum_passthrough_w ? 1'b0 : psum_router_valid_core_w;
assign fifo_psum_out_in_w        = psum_router_data_core_w;
assign fifo_psum_out_out_ready_w = psum_passthrough_w ? 1'b0 : psum_router_ready_in;
wire psum_merge_pending_hold_w;
assign psum_merge_pending_hold_w  = (psum_merge_out_pending_w === 1'b1);
// Stall core only while the final pending beat is held in/out of the output FIFO.
assign fifo_psum_out_core_ready_w =
    psum_passthrough_w ? 1'b0 :
    (psum_merge_pending_hold_w
        ? (fifo_psum_out_fifo_in_ready_w &
           (~fifo_psum_out_out_valid_w | fifo_psum_out_out_ready_w))
        : fifo_psum_out_fifo_in_ready_w);

always @(posedge clk) begin
    if (rst) begin
        iact_addr_write_fin_r   <= 1'b0;
        iact_data_write_fin_r    <= 1'b0;
        weight_addr_write_fin_r  <= 1'b0;
        weight_data_write_fin_r  <= 1'b0;
    end else begin
        if (iact_write_fin_clear) begin
            iact_addr_write_fin_r  <= 1'b0;
            iact_data_write_fin_r   <= 1'b0;
        end else begin
            iact_addr_write_fin_r <= iact_addr_write_fin_r | ctrl_status_iact_address_write_fin_w;
            iact_data_write_fin_r  <= iact_data_write_fin_r  | ctrl_status_iact_data_write_fin_w;
        end

        if (weight_write_fin_clear) begin
            weight_addr_write_fin_r <= 1'b0;
            weight_data_write_fin_r  <= 1'b0;
        end else begin
            weight_addr_write_fin_r <= weight_addr_write_fin_r | ctrl_status_weight_address_write_fin_w;
            weight_data_write_fin_r  <= weight_data_write_fin_r  | ctrl_status_weight_data_write_fin_w;
        end
    end
end

endmodule
