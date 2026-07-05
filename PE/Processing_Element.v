// ============================================================================
// Module      : Processing_Element
// Author      : Do Quoc Khanh
// Description : One Processing Element wrapper.
//               It receives IACT, Weight, and PSUM data from the local fabric.
//               It keeps small FIFOs around the core to handle valid/ready.
//               Cluster control starts load, MAC, slide, and PSUM output.
//               The core stores local data and performs the MAC work.
// ============================================================================

module Processing_Element (
    input  wire                  clk,
    input  wire                  rst,

    // Local fabric -> PE: PSUM input. PE -> local fabric: ready.
    output wire                  psum_router_ready_out,
    input  wire                  psum_router_valid_in,
    input  wire signed [41:0]    psum_router_data_in,
    // PE -> local fabric: PSUM output. Local fabric -> PE: ready.
    input  wire                  psum_router_ready_in,
    output wire                  psum_router_valid_out,
    output wire signed [41:0]    psum_router_data_out,

    // Local fabric -> PE: IACT address stream.
    output wire                  iact_router_addr_ready_out,
    input  wire                  iact_router_addr_valid_in,
    input  wire [4:0]            iact_router_addr_in,

    // Local fabric -> PE: IACT data stream.
    output wire                  iact_router_data_ready_out,
    input  wire                  iact_router_data_valid_in,
    input  wire [11:0]           iact_router_data_in,

    // Local fabric -> PE: Weight address stream.
    output wire                  weight_router_addr_ready_out,
    input  wire                  weight_router_addr_valid_in,
    input  wire [6:0]            weight_router_addr_in,

    // Local fabric -> PE: Weight data stream.
    output wire                  weight_router_data_ready_out,
    input  wire                  weight_router_data_valid_in,
    input  wire [23:0]           weight_router_data_in,

    // PE -> cluster controller: load/MAC status.
    output wire                  ctrl_status_iact_address_write_fin_out,
    output wire                  ctrl_status_iact_data_write_fin_out,
    output wire                  ctrl_status_weight_address_write_fin_out,
    output wire                  ctrl_status_weight_data_write_fin_out,
    output wire                  ctrl_status_psum_acc_fin_out,
    output wire                  ctrl_status_slide_safe_out,

    // Cluster controller -> PE: main control pulses.
    input  wire                  cluster_ctrl_psum_enq_en_in,
    input  wire                  cluster_ctrl_psum_passthrough_en_in,
    input  wire                  cluster_ctrl_load_en_in,
    input  wire                  cluster_ctrl_mac_en_in,
    output wire                  ctrl_status_cal_fin_out,

    // Cluster controller -> PE: clear old load status.
    input  wire                  iact_write_fin_clear,
    input  wire                  weight_write_fin_clear,
    output wire                  all_write_fin,

    // Cluster controller -> PE: clear PSUM storage.
    input  wire                  psum_spad_clear,

    // Cluster controller -> PE: current layer settings.
    input  wire [4:0]            ctrl_cfg_segment_len_in,
    input  wire [3:0]            ctrl_cfg_window_seg_count_in,
    input  wire [5:0]            ctrl_cfg_m0_in,
    input  wire                  ctrl_cfg_iact_flush_in,
    input  wire                  ctrl_cfg_slide_commit_in
);

parameter integer IACT_ADDR_DATA_WIDTH   = 5;
parameter integer IACT_DATA_DATA_WIDTH   = 12;
parameter integer WEIGHT_ADDR_DATA_WIDTH  = 7;
parameter integer WEIGHT_DATA_DATA_WIDTH  = 24;

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

reg iact_addr_write_fin_r;
reg iact_data_write_fin_r;
reg weight_addr_write_fin_r;
reg weight_data_write_fin_r;

wire cluster_ctrl_psum_enq_en_w;

wire fifo_iact_addr_in_ready_w;
wire fifo_iact_addr_out_ready_w;
wire fifo_iact_addr_out_valid_w;
wire [4:0] fifo_iact_addr_out_w;

wire fifo_iact_data_in_ready_w;
wire fifo_iact_data_out_ready_w;
wire fifo_iact_data_out_valid_w;
wire [11:0] fifo_iact_data_out_w;

wire fifo_weight_addr_in_ready_w;
wire fifo_weight_addr_out_ready_w;
wire fifo_weight_addr_out_valid_w;
wire [6:0] fifo_weight_addr_out_w;

wire fifo_weight_data_in_ready_w;
wire fifo_weight_data_out_ready_w;
wire fifo_weight_data_out_valid_w;
wire [23:0] fifo_weight_data_out_w;

wire fifo_psum_in_in_ready_w;
wire fifo_psum_in_out_ready_w;
wire fifo_psum_in_out_valid_w;
wire signed [41:0] fifo_psum_in_out_w;

wire fifo_psum_out_fifo_in_ready_w;
wire fifo_psum_out_core_ready_w;
wire fifo_psum_out_out_ready_w;
wire fifo_psum_out_out_valid_w;
wire signed [41:0] fifo_psum_out_out_w;
wire psum_passthrough_w;

assign psum_passthrough_w = cluster_ctrl_psum_passthrough_en_in;

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

Processing_Element_Controller u_processing_element_controller (
    .clk                               (clk),
    .rst                               (rst),
    .top_psum_enq_en_in                (cluster_ctrl_psum_enq_en_in),
    .core_ctrl_status_psum_acc_fin_in  (ctrl_status_psum_acc_fin_w),
    .cluster_ctrl_psum_enq_en_out      (cluster_ctrl_psum_enq_en_w)
);

Processing_Element_core_pipeline u_processing_element_core_pipeline (
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
    .cluster_ctrl_psum_enq_en_in       (cluster_ctrl_psum_enq_en_w),
    .cluster_ctrl_load_en_in           (cluster_ctrl_load_en_in),
    .ctrl_status_cal_fin_out           (ctrl_status_cal_fin_w),
    .ctrl_status_slide_safe_out        (ctrl_status_slide_safe_w),
    .ctrl_status_iact_address_write_fin_out (ctrl_status_iact_address_write_fin_w),
    .ctrl_status_iact_data_write_fin_out    (ctrl_status_iact_data_write_fin_w),
    .ctrl_status_weight_address_write_fin_out (ctrl_status_weight_address_write_fin_w),
    .ctrl_status_weight_data_write_fin_out    (ctrl_status_weight_data_write_fin_w),
    .ctrl_status_psum_acc_fin_out      (ctrl_status_psum_acc_fin_w),
    .ctrl_cfg_psum_spad_clear_in       (psum_spad_clear),
    .ctrl_cfg_segment_len_in           (ctrl_cfg_segment_len_in),
    .ctrl_cfg_window_seg_count_in      (ctrl_cfg_window_seg_count_in),
    .ctrl_cfg_m0_in                    (ctrl_cfg_m0_in),
    .ctrl_cfg_iact_flush_in            (ctrl_cfg_iact_flush_in),
    .ctrl_cfg_slide_commit_in          (ctrl_cfg_slide_commit_in)
);

PE_data_FIFO #(.DATA_IN_WIDTH(IACT_ADDR_DATA_WIDTH)) u_iact_addr_fifo (
    .clk            (clk),
    .rst            (rst),
    .data_in_ready  (fifo_iact_addr_in_ready_w),
    .data_in_valid  (iact_router_addr_valid_in),
    .data_in        (iact_router_addr_in),
    .data_out_ready (fifo_iact_addr_out_ready_w),
    .data_out_valid (fifo_iact_addr_out_valid_w),
    .data_out       (fifo_iact_addr_out_w)
);

PE_data_FIFO #(.DATA_IN_WIDTH(IACT_DATA_DATA_WIDTH)) u_iact_data_fifo (
    .clk            (clk),
    .rst            (rst),
    .data_in_ready  (fifo_iact_data_in_ready_w),
    .data_in_valid  (iact_router_data_valid_in),
    .data_in        (iact_router_data_in),
    .data_out_ready (fifo_iact_data_out_ready_w),
    .data_out_valid (fifo_iact_data_out_valid_w),
    .data_out       (fifo_iact_data_out_w)
);

PE_data_FIFO #(.DATA_IN_WIDTH(WEIGHT_ADDR_DATA_WIDTH)) u_weight_addr_fifo (
    .clk            (clk),
    .rst            (rst),
    .data_in_ready  (fifo_weight_addr_in_ready_w),
    .data_in_valid  (weight_router_addr_valid_in),
    .data_in        (weight_router_addr_in),
    .data_out_ready (fifo_weight_addr_out_ready_w),
    .data_out_valid (fifo_weight_addr_out_valid_w),
    .data_out       (fifo_weight_addr_out_w)
);

PE_data_FIFO #(.DATA_IN_WIDTH(WEIGHT_DATA_DATA_WIDTH)) u_weight_data_fifo (
    .clk            (clk),
    .rst            (rst),
    .data_in_ready  (fifo_weight_data_in_ready_w),
    .data_in_valid  (weight_router_data_valid_in),
    .data_in        (weight_router_data_in),
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
    .data_in_valid  (psum_passthrough_w ? 1'b0 : psum_router_valid_in),
    .data_in        (psum_router_data_in),
    .data_out_ready (fifo_psum_in_out_ready_w),
    .data_out_valid (fifo_psum_in_out_valid_w),
    .data_out       (fifo_psum_in_out_w)
);

PE_psum_FIFO #(
    .DATA_WIDTH(42),
    .BUFFER_DEPTH(4)
) u_psum_out_fifo (
    .clk            (clk),
    .rst            (rst),
    .data_in_ready  (fifo_psum_out_fifo_in_ready_w),
    .data_in_valid  (psum_passthrough_w ? 1'b0 : psum_router_valid_core_w),
    .data_in        (psum_router_data_core_w),
    .data_out_ready (fifo_psum_out_out_ready_w),
    .data_out_valid (fifo_psum_out_out_valid_w),
    .data_out       (fifo_psum_out_out_w)
);

// P1/P2: IACT ingress ready = FIFO input ready; pop only during active load before write_fin latch.
// Allow pop while slide_safe so row-slide append can stream after a latched write_fin.
wire iact_fifo_pop_allow_w = (~iact_addr_write_fin_r) | ctrl_status_slide_safe_w;
assign iact_router_addr_ready_out = fifo_iact_addr_in_ready_w;
assign iact_addr_valid_w          = fifo_iact_addr_out_valid_w;
assign iact_addr_data_w           = fifo_iact_addr_out_w;
assign fifo_iact_addr_out_ready_w = cluster_ctrl_load_en_in & iact_fifo_pop_allow_w &
                                    iact_addr_ready_w;

assign iact_router_data_ready_out = fifo_iact_data_in_ready_w;
assign iact_data_valid_w          = fifo_iact_data_out_valid_w;
assign iact_data_data_w           = fifo_iact_data_out_w;
assign fifo_iact_data_out_ready_w = cluster_ctrl_load_en_in & iact_fifo_pop_allow_w &
                                    iact_data_ready_w;

// P1/P2: Weight ingress backpressure + load-phase pop gating.
assign weight_router_addr_ready_out = fifo_weight_addr_in_ready_w;
assign weight_addr_valid_w          = fifo_weight_addr_out_valid_w;
assign weight_addr_data_w           = fifo_weight_addr_out_w;
assign fifo_weight_addr_out_ready_w = cluster_ctrl_load_en_in & (~weight_addr_write_fin_r) &
                                      weight_addr_ready_w;

assign weight_router_data_ready_out = fifo_weight_data_in_ready_w;
assign weight_data_valid_w          = fifo_weight_data_out_valid_w;
assign weight_data_data_w           = fifo_weight_data_out_w;
assign fifo_weight_data_out_ready_w = cluster_ctrl_load_en_in & (~weight_data_write_fin_r) &
                                      weight_data_ready_w;

// P1: PSUM in — top ready from FIFO in; core pop when core ready.
assign fifo_psum_in_out_ready_w = psum_passthrough_w ? 1'b0 : psum_router_ready_core_w;

// P0: PSUM out — core -> fifo in; top <- fifo out; downstream ready -> fifo out pop.
// Core merge backpressure must wait for downstream pop when FIFO holds a beat (not ~full alone).
assign fifo_psum_out_out_ready_w = psum_passthrough_w ? 1'b0 : psum_router_ready_in;
// Stall core only while the final pending beat is held in/out of the output FIFO.
assign fifo_psum_out_core_ready_w =
    psum_passthrough_w ? 1'b0 :
    (psum_merge_out_pending_w
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
