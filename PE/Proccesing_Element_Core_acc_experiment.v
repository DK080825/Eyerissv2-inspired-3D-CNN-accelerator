// ============================================================================
// Module      : Processing_Element_core_pipeline
// Author      : Do Quoc Khanh
// Description : Main compute core inside one PE.
//               It loads IACT, Weight, and PSUM into local SPADs.
//               It reads IACT and Weight entries, multiplies them, and adds
//               the result into PSUM.
//               It supports sliding by keeping old IACT segments and appending
//               only the new segment.
//               It reports load done, slide ready, and MAC done to the cluster.
// ============================================================================

`default_nettype none
module Processing_Element_core_pipeline #(
    // Local SPAD sizes used by one PE.
    parameter integer IACT_ADDR_SPAD_DEPTH   = 10,
    parameter integer IACT_DATA_SPAD_DEPTH   = 32,
    parameter integer WEIGHT_ADDR_SPAD_DEPTH = 16,
    parameter integer WEIGHT_DATA_SPAD_DEPTH = 96,
    parameter integer PSUM_SPAD_DEPTH          = 8,
    // IACT address stores segment boundaries.
    parameter integer IACT_ADDR_W            = 5,
    parameter integer IACT_DATA_PTR_W          = ($clog2(IACT_DATA_SPAD_DEPTH) + 1),
    parameter integer IACT_SEG_IDX_W           = $clog2(IACT_ADDR_SPAD_DEPTH),
    parameter integer WEIGHT_ADDR_W            = $clog2(WEIGHT_DATA_SPAD_DEPTH),
    parameter integer WEIGHT_COL_IDX_W         = $clog2(WEIGHT_ADDR_SPAD_DEPTH),
    parameter integer WEIGHT_WORD_PTR_W        = $clog2(WEIGHT_DATA_SPAD_DEPTH),
    parameter integer PSUM_ADDR_W              = $clog2(PSUM_SPAD_DEPTH),
    parameter integer PSUM_DEPTH_COUNT_W       = $clog2(PSUM_SPAD_DEPTH + 1),
    parameter integer IACT_DATA_IDX_W          = $clog2(IACT_DATA_SPAD_DEPTH),
    parameter integer IACT_DATA_W              = 12,
    parameter integer IACT_COUNT_W             = 4,
    parameter integer IACT_VALUE_W             = 8,
    parameter integer WEIGHT_COUNT_W           = 4,
    parameter integer WEIGHT_VALUE_W           = 8,
    parameter integer WEIGHT_PACKED_W          = 24,
    parameter integer PSUM_W                   = 21,
    // Maximum number of PSUM rows supported by this PE.
    parameter integer WEIGHT_MATRIX_ROW        = 32
)(
    input  wire                         clk,
    input  wire                         rst,

    // Local fabric -> PE: PSUM seed. PE -> local fabric: ready.
    output wire                         psum_router_ready_out,
    input  wire                         psum_router_valid_in,
    input  wire signed [(2*PSUM_W)-1:0] psum_router_data_in,
    // PE -> local fabric: PSUM result. Local fabric -> PE: ready.
    input  wire                         psum_router_ready_in,
    output wire                         psum_router_valid_out,
    output wire signed [(2*PSUM_W)-1:0] psum_router_data_out,
    output wire                         psum_merge_out_pending_out,

    // Local fabric -> PE: IACT address and data.
    input  wire                         iact_router_addr_valid_in,
    input  wire [IACT_ADDR_W-1:0]       iact_router_addr_in,
    output wire                         iact_router_addr_ready_out,
    input  wire                         iact_router_data_valid_in,
    input  wire [IACT_DATA_W-1:0]       iact_router_data_in,
    output wire                         iact_router_data_ready_out,

    // Local fabric -> PE: Weight address and data.
    input  wire                         weight_router_addr_valid_in,
    input  wire [WEIGHT_ADDR_W-1:0]     weight_router_addr_in,
    output wire                         weight_router_addr_ready_out,
    input  wire                         weight_router_data_valid_in,
    input  wire [WEIGHT_PACKED_W-1:0]   weight_router_data_in,
    output wire                         weight_router_data_ready_out,

    // Cluster controller -> PE: run/load control.
    input  wire                         cluster_ctrl_mac_en_in,
    input  wire                         cluster_ctrl_psum_enq_en_in,
    input  wire                         cluster_ctrl_load_en_in,
    // PE -> cluster controller: current status.
    output wire                         ctrl_status_cal_fin_out,
    output wire                         ctrl_status_slide_safe_out,
    output wire                         ctrl_status_iact_address_write_fin_out,
    output wire                         ctrl_status_iact_data_write_fin_out,
    output wire                         ctrl_status_weight_address_write_fin_out,
    output wire                         ctrl_status_weight_data_write_fin_out,
    output wire                         ctrl_status_psum_acc_fin_out,
    input  wire                         ctrl_cfg_psum_spad_clear_in,

    // Cluster controller -> PE: current layer/window settings.
    input  wire [4:0]                   ctrl_cfg_segment_len_in,
    input  wire [3:0]                   ctrl_cfg_window_seg_count_in,
    input  wire [5:0]                   ctrl_cfg_m0_in,
    input  wire                         ctrl_cfg_iact_flush_in,
    input  wire                         ctrl_cfg_slide_commit_in
);

localparam [1:0] MODE_IDLE   = 2'd0;
localparam [1:0] MODE_RUN    = 2'd1;
localparam [1:0] MODE_MERGE  = 2'd2;
localparam [IACT_ADDR_W-1:0] IACT_ADDR_SENTINEL = {IACT_ADDR_W{1'b1}};
localparam integer MAC_PRODUCT_W = IACT_VALUE_W + WEIGHT_VALUE_W;

// Main mode and completion pulses.
reg [1:0] mode_r;
reg       cal_fin_r;
reg       psum_acc_fin_r;
reg [PSUM_ADDR_W-1:0] merge_idx_r;
reg                                psum_rd_en0_r;
reg                                psum_in_valid_r;
reg                                merge_out_pending_r;
reg signed [(2*PSUM_W)-1:0]        merge_out_pending_data_r;
assign ctrl_status_cal_fin_out       = cal_fin_r;
assign ctrl_status_psum_acc_fin_out = psum_acc_fin_r;
assign psum_router_ready_out  = (mode_r == MODE_MERGE)
    ? (merge_out_pending_r ? 1'b0 : psum_router_ready_in)
    : 1'b0;
assign psum_router_valid_out = (mode_r == MODE_MERGE) &&
    (merge_out_pending_r | psum_in_valid_r);
assign psum_merge_out_pending_out = merge_out_pending_r;

reg merge_req_pending_r;
reg weight_addr_loaded_r;
reg weight_data_loaded_r;

// MAC start request latch
reg mac_req_pending_r;
wire mac_start_ready_w;
//

reg                            load_en_r;
wire                           load_rise_w;
assign load_rise_w = cluster_ctrl_load_en_in & ~load_en_r;
// -----------------------------------------------------------------------------
// SPad interfaces — IACT address/data SPads are resident-only (metadata ring + payload log)
// -----------------------------------------------------------------------------
wire                               iact_address_stream_done_w;
wire [IACT_ADDR_W-1:0]             iact_spad_resident_rd_seg_begin_w;
wire [IACT_ADDR_W-1:0]             iact_spad_resident_rd_seg_end_w;
reg  [IACT_DATA_PTR_W:0]           iact_expected_data_entries_r;
wire                               iact_addr_entry_fire_w;
wire                               iact_payload_write_fire_w;
wire                               last_payload_entry_fire_w;
reg                                iact_data_stream_done_r;
reg                                iact_address_stream_done_r;

// Resident payload log wiring
wire                               iact_data_resident_data_ready_w;
wire [IACT_DATA_IDX_W-1:0]         iact_data_resident_read_idx_w;
wire [IACT_DATA_W-1:0]             iact_data_resident_data_out_w;
wire [IACT_DATA_PTR_W-1:0]         iact_data_resident_wr_abs_w;

wire                               weight_address_spad_data_in_ready_w;
wire                               weight_address_spad_write_fin_w;
wire  [WEIGHT_COL_IDX_W-1:0]       weight_address_rd_col_idx_w;
wire [WEIGHT_ADDR_W-1:0]           weight_col_begin_w;
wire [WEIGHT_ADDR_W-1:0]           weight_col_end_w;

wire                               weight_data_spad_data_in_ready_w;
wire                               weight_data_spad_write_fin_w;
reg                                weight_data_read_en_r;
reg  [WEIGHT_WORD_PTR_W-1:0]       weight_data_read_word_idx_r;
wire                               weight_lane0_valid_w;
wire [WEIGHT_COUNT_W-1:0]          weight_lane0_count_w;
wire signed [WEIGHT_VALUE_W-1:0]   weight_lane0_value_w;
wire                               weight_lane1_valid_w;
wire [WEIGHT_COUNT_W-1:0]          weight_lane1_count_w;
wire signed [WEIGHT_VALUE_W-1:0]   weight_lane1_value_w;

reg                                psum_rd_en1_r;
reg  [PSUM_ADDR_W-1:0]             psum_rd_addr0_r;
reg  [PSUM_ADDR_W-1:0]             psum_rd_addr1_r;
reg                                psum_wr_en0_r;
reg                                psum_wr_en1_r;
reg  [PSUM_ADDR_W-1:0]             psum_wr_addr0_r;
reg  [PSUM_ADDR_W-1:0]             psum_wr_addr1_r;
reg  signed [PSUM_W-1:0]           psum_wr_data0_r;
reg  signed [PSUM_W-1:0]           psum_wr_data1_r;
wire signed [PSUM_W-1:0]           psum_spad_rd_data0_w;
wire signed [PSUM_W-1:0]           psum_spad_rd_data1_w;
wire signed [(2*PSUM_W)-1:0]       psum_out_w;
reg signed  [(2*PSUM_W)-1:0]       psum_out_r;
reg [IACT_SEG_IDX_W-1:0]           iter_seg_rel_r;

// -----------------------------------------------------------------------------
// slide_commit: shift address-vector chain (drop oldest segment), advance data free_abs,
// reopen address programming for one appended boundary + sentinel (no flush).
// -----------------------------------------------------------------------------
reg                                cfg_slide_commit_d1_r;
reg                                iact_slide_do_r;
reg [IACT_ADDR_W-1:0]              iact_slide_capture_b1_r;
wire                               iact_slide_commit_rise_w;
wire [IACT_ADDR_W-1:0]             iact_addr_boundary1_out_w;
// Driven after resident WM registers (iter_done_r, wm_state_r, ...); used by slide_commit gating above.
wire                               slide_safe_w;
wire                               slide_safe_post_mac_w;
wire                               slide_commit_arm_w;

always @(posedge clk) begin
    if (rst)
        cfg_slide_commit_d1_r <= 1'b0;
    else
        cfg_slide_commit_d1_r <= ctrl_cfg_slide_commit_in;
end
assign iact_slide_commit_rise_w =
    ctrl_cfg_slide_commit_in &&
    !cfg_slide_commit_d1_r &&
    slide_commit_arm_w;

always @(posedge clk) begin
    if (rst || ctrl_cfg_iact_flush_in)
        iact_slide_do_r <= 1'b0;
    else
        iact_slide_do_r <= iact_slide_commit_rise_w;
end

always @(posedge clk) begin
    if (rst || ctrl_cfg_iact_flush_in)
        iact_slide_capture_b1_r <= {IACT_ADDR_W{1'b0}};
    else if (iact_slide_commit_rise_w)
        iact_slide_capture_b1_r <= iact_addr_boundary1_out_w;
end

assign psum_router_data_out = psum_out_r;

Iact_Address_Spad #(
    .IACT_ADDR_SPAD_DEPTH(IACT_ADDR_SPAD_DEPTH),
    .IACT_ADDR_W         (IACT_ADDR_W),
    .IACT_ADDR_IDX_W     (IACT_SEG_IDX_W)
) u_iact_address_spad (
    .clk          (clk),
    .rst          (rst),
    .data_in_ready (iact_router_addr_ready_out),
    .data_in_valid (iact_router_addr_valid_in),
    .data_in       (iact_router_addr_in),
    .write_en      (cluster_ctrl_load_en_in),
    .flush         (ctrl_cfg_iact_flush_in),
    .write_fin     (iact_address_stream_done_w),
    .rd_seg_idx    (iter_seg_rel_r[IACT_SEG_IDX_W-1:0]),
    .seg_begin     (iact_spad_resident_rd_seg_begin_w),
    .seg_end       (iact_spad_resident_rd_seg_end_w),
    .slide_shift   (iact_slide_do_r),
    .slide_append_idx(ctrl_cfg_window_seg_count_in[IACT_SEG_IDX_W-1:0]),
    .boundary1_out (iact_addr_boundary1_out_w)
);

Iact_Data_Spad #(
    .IACT_DATA_W   (IACT_DATA_W),
    .SPAD_DEPTH    (IACT_DATA_SPAD_DEPTH),
    .RES_ABS_PTR_W (IACT_DATA_PTR_W),
    .RES_IDX_W     (IACT_DATA_IDX_W)
) u_iact_data_spad (
    .clk           (clk),
    .rst           (rst),
    .resident_flush            (ctrl_cfg_iact_flush_in),
    .resident_free_update_valid(iact_slide_do_r),
    .resident_free_abs_in      ({{(IACT_DATA_PTR_W-IACT_ADDR_W){1'b0}}, iact_slide_capture_b1_r}),
    .resident_data_valid       (iact_payload_write_fire_w),
    .resident_data_in          (iact_router_data_in),
    .resident_data_ready       (iact_data_resident_data_ready_w),
    .resident_read_idx         (iact_data_resident_read_idx_w),
    .resident_data_out         (iact_data_resident_data_out_w),
    .resident_wr_abs           (iact_data_resident_wr_abs_w),
    .resident_free_abs         ()
);

Weight_Address_Spad #(
    .SPAD_DEPTH       (WEIGHT_ADDR_SPAD_DEPTH),
    .WEIGHT_ADDR_W    (WEIGHT_ADDR_W),
    .WEIGHT_COL_IDX_W (WEIGHT_COL_IDX_W)
) u_weight_address_spad (
    .clk           (clk),
    .rst           (rst),
    .data_in_ready (weight_address_spad_data_in_ready_w),
    .data_in_valid (weight_router_addr_valid_in),
    .data_in       (weight_router_addr_in),
    .write_en      (cluster_ctrl_load_en_in),
    .write_fin     (weight_address_spad_write_fin_w),
    .rd_col_idx    (weight_address_rd_col_idx_w),
    .col_begin     (weight_col_begin_w),
    .col_end       (weight_col_end_w)
);

Weight_Data_Spad #(
    .SPAD_DEPTH        (WEIGHT_DATA_SPAD_DEPTH),
    .WEIGHT_PACKED_W   (WEIGHT_PACKED_W),
    .WEIGHT_WORD_PTR_W (WEIGHT_WORD_PTR_W),
    .WEIGHT_COUNT_W    (WEIGHT_COUNT_W),
    .WEIGHT_VALUE_W    (WEIGHT_VALUE_W)
) u_weight_data_spad (
    .clk           (clk),
    .rst           (rst),
    .data_in_ready (weight_data_spad_data_in_ready_w),
    .data_in_valid (weight_router_data_valid_in),
    .data_in       (weight_router_data_in),
    .write_en      (cluster_ctrl_load_en_in),
    .write_fin     (weight_data_spad_write_fin_w),
    .read_en       (weight_data_read_en_r),
    .read_word_idx (weight_data_read_word_idx_r),
    .lane0_valid   (weight_lane0_valid_w),
    .lane0_count   (weight_lane0_count_w),
    .lane0_value   (weight_lane0_value_w),
    .lane1_valid   (weight_lane1_valid_w),
    .lane1_count   (weight_lane1_count_w),
    .lane1_value   (weight_lane1_value_w)
);

Psum_Spad_2R2W #(
    .SPAD_DEPTH  (PSUM_SPAD_DEPTH),
    .PSUM_ADDR_W (PSUM_ADDR_W),
    .PSUM_WIDTH  (PSUM_W)
) u_psum_spad (
    .clk             (clk),
    .rst             (rst),
    .rd_en0          (psum_rd_en0_r),
    .rd_addr0        (psum_rd_addr0_r),
    .rd_data0        (psum_spad_rd_data0_w),
    .rd_en1          (psum_rd_en1_r),
    .rd_addr1        (psum_rd_addr1_r),
    .rd_data1        (psum_spad_rd_data1_w),
    .wr_en0          (psum_wr_en0_r),
    .wr_addr0        (psum_wr_addr0_r),
    .wr_data0        (psum_wr_data0_r),
    .wr_en1          (psum_wr_en1_r),
    .wr_addr1        (psum_wr_addr1_r),
    .wr_data1        (psum_wr_data1_r),
    .psum_spad_clear (ctrl_cfg_psum_spad_clear_in)
);

// ctrl_status_iact_*_write_fin_out mirror resident_window_ready_w; wire declarations stay below resident iterator wires for tool ordering.

// -----------------------------------------------------------------------------
// Resident IACT window manager — metadata from resident Address SPad, payload from resident Data SPad
// -----------------------------------------------------------------------------
localparam [3:0] ST_IDLE         = 4'd0;
localparam [3:0] ST_ITER_INIT    = 4'd2;
localparam [3:0] ST_ITER_SEG     = 4'd3;
localparam [3:0] ST_ITER_SEG_USE = 4'd4;
localparam [3:0] ST_ITER_ENTRY   = 4'd5;
localparam [3:0] ST_ITER_DECODE  = 4'd6;
localparam [3:0] ST_NEXT_SEG     = 4'd7;
localparam [3:0] ST_ITER_PAYLOAD_WAIT    = 4'd9;
localparam [3:0] ST_ITER_PAYLOAD_CAPTURE = 4'd10;

// -----------------------------------------------------------------------------
// Resident iterator and MAC pipeline.
// -----------------------------------------------------------------------------
reg [3:0] wm_state_r;
reg       iter_active_r;
reg       iter_done_r;
reg [IACT_DATA_PTR_W-1:0] iter_entry_abs_r, iter_entry_end_abs_r;
reg [IACT_DATA_PTR_W-1:0]  iter_logical_seg_base_r;
reg                                itr_rd_first_r;
reg [IACT_DATA_PTR_W-1:0]          itr_rd_offset_base_r;
reg [IACT_DATA_W-1:0]              itr_cap_word_r;
reg                                itr_cap_first_r;
reg [IACT_DATA_PTR_W-1:0]          itr_cap_offset_base_r;
reg signed [IACT_VALUE_W-1:0]      itr_dec_value_r;
reg [WEIGHT_COL_IDX_W-1:0]         itr_dec_weight_col_r;
reg [IACT_DATA_PTR_W-1:0]          itr_dec_offset_in_seg_r;
reg                                itr_dec_skip_r;
reg [IACT_DATA_PTR_W-1:0]          sliding_resp_retire_offp1_r;
// Sliding → MAC queue (hold beat until queue accepts)
reg                                sliding_resp_valid_r;
reg signed [IACT_VALUE_W-1:0]      sliding_resp_value_r;
reg [WEIGHT_COL_IDX_W-1:0]        sliding_resp_weight_col_r;
wire      resident_window_ready_w;
wire [IACT_DATA_PTR_W-1:0] iter_entry_next_w = iter_entry_abs_r + {{(IACT_DATA_PTR_W-1){1'b0}}, 1'b1};
wire       iter_entry_is_last_w = (iter_entry_next_w == iter_entry_end_abs_r);
wire [3:0] current_window_seg_count_w = ctrl_cfg_window_seg_count_in;
wire [4:0] current_segment_len_w      = ctrl_cfg_segment_len_in;

assign resident_window_ready_w =
    iact_address_stream_done_r &&
    iact_data_stream_done_r &&
    (ctrl_cfg_window_seg_count_in != 4'd0) &&
    !iter_active_r &&
    !sliding_resp_valid_r &&
    (wm_state_r == ST_IDLE);

// -----------------------------------------------------------------------------
// Sliding prefetch: asserted when iterator scan for current window is finished but
// backend may still be draining queued MAC tasks — safe cycle to pulse slide_commit
// without corrupting resident metadata / iterators.
// -----------------------------------------------------------------------------
wire itr_pipe_empty_w;
assign itr_pipe_empty_w =
    !sliding_resp_valid_r && (wm_state_r == ST_IDLE);

assign slide_safe_w =
    (mode_r == MODE_RUN) &&
    iter_done_r &&
    !iter_active_r &&
    itr_pipe_empty_w &&
    (wm_state_r == ST_IDLE);

// Status outputs track resident-window readiness (configured segment count present, idle iterator, no pending task beat).
assign ctrl_status_iact_address_write_fin_out   = resident_window_ready_w;
assign ctrl_status_iact_data_write_fin_out      = resident_window_ready_w;
assign ctrl_status_weight_address_write_fin_out = weight_address_spad_write_fin_w;
assign ctrl_status_weight_data_write_fin_out    = weight_data_spad_write_fin_w;
wire       sliding_iter_start_w = iact_data_stream_done_r && !iter_active_r && !iter_done_r;

// -----------------------------------------------------------------------------
// Iterator-source abstraction (resident Address SPad metadata → decode)
// -----------------------------------------------------------------------------
wire                               iact_iter_seg_valid_w;
wire [IACT_DATA_PTR_W-1:0]         iact_iter_seg_begin_w;
wire [IACT_DATA_PTR_W-1:0]         iact_iter_seg_end_w;
assign iact_iter_seg_valid_w = iact_address_stream_done_r;
assign iact_iter_seg_begin_w =
    {{(IACT_DATA_PTR_W - IACT_ADDR_W){1'b0}}, iact_spad_resident_rd_seg_begin_w};
assign iact_iter_seg_end_w =
    {{(IACT_DATA_PTR_W - IACT_ADDR_W){1'b0}}, iact_spad_resident_rd_seg_end_w};

// CSC decode from itr_cap_* (latched into itr_dec_* in ST_ITER_DECODE).
wire [IACT_VALUE_W-1:0]      itr_dec_val_w;
wire [IACT_COUNT_W-1:0]      itr_dec_cnt_w;
wire [IACT_DATA_PTR_W-1:0]   itr_dec_off_in_w;
wire [IACT_DATA_PTR_W-1:0]   itr_dec_rel_col_w;
wire [WEIGHT_COL_IDX_W-1:0]  itr_dec_full_weight_col_w;
wire                         itr_dec_skip_w;
assign itr_dec_val_w   = itr_cap_word_r[IACT_DATA_W-1:IACT_COUNT_W];
assign itr_dec_cnt_w   = itr_cap_word_r[IACT_COUNT_W-1:0];
assign itr_dec_off_in_w =
    itr_cap_first_r ? itr_dec_cnt_w : (itr_cap_offset_base_r + itr_dec_cnt_w);
// Relative column within segment (skip); full column indexes Weight_Address_Spad (C0 x S).
assign itr_dec_rel_col_w = itr_dec_off_in_w;
assign itr_dec_skip_w    =
    (itr_dec_rel_col_w >= {{(IACT_DATA_PTR_W-5){1'b0}}, current_segment_len_w});
assign itr_dec_full_weight_col_w = iter_logical_seg_base_r + itr_dec_rel_col_w;

// -----------------------------------------------------------------------------
// Drive resident Iact_* SPad ports from router + window manager.
// -----------------------------------------------------------------------------

assign mac_start_ready_w =
    weight_addr_loaded_r && weight_data_loaded_r && resident_window_ready_w;

assign iact_data_resident_read_idx_w = iter_entry_abs_r[IACT_DATA_IDX_W-1:0];

// -----------------------------------------------------------------------------
// Normalized task interface and 2-entry task queue
// -----------------------------------------------------------------------------
// Resident iterator → sliding_resp_* (pending iact beat) → frontend_task_* → weight/psum/MAC backend.
reg                              q0_valid_r, q1_valid_r;
reg signed [IACT_VALUE_W-1:0]    q0_value_r, q1_value_r;
reg [WEIGHT_COL_IDX_W-1:0]       q0_weight_col_r, q1_weight_col_r;
wire                             queue_full_w;
wire                             queue_empty_w;
wire                             queue_pop_w;
wire                             frontend_task_valid_w;
wire                             frontend_task_ready_w;
wire signed [IACT_VALUE_W-1:0]   frontend_task_iact_value_w;
wire [WEIGHT_COL_IDX_W-1:0]      frontend_task_weight_col_w;

assign frontend_task_valid_w      = sliding_resp_valid_r;
assign frontend_task_iact_value_w  = sliding_resp_value_r;
assign frontend_task_weight_col_w  = sliding_resp_weight_col_r;
assign frontend_task_ready_w       = !queue_full_w;

// -----------------------------------------------------------------------------
// S2 (weight-address stage) registers
// -----------------------------------------------------------------------------
reg                              s2_valid_r;
reg signed [IACT_VALUE_W-1:0]    s2_iact_value_r;
reg [WEIGHT_COL_IDX_W-1:0]       s2_weight_col_r;

// -----------------------------------------------------------------------------
// active task and overlapped weight/MAC/writeback pipeline
// -----------------------------------------------------------------------------
reg                              active_task_valid_r;
reg signed [IACT_VALUE_W-1:0]    active_iact_value_r;
reg [WEIGHT_COL_IDX_W-1:0]       active_weight_col_r;

reg [WEIGHT_WORD_PTR_W-1:0]      weight_word_ptr_r;
reg [WEIGHT_WORD_PTR_W-1:0]      weight_word_end_r;
reg [PSUM_ADDR_W-1:0]            weight_row_base_r;
reg                              weight_issue_done_r;
reg                              s3_pending_r;
reg                              s3_delay_r;    
reg signed [IACT_VALUE_W-1:0]    s3_iact_value_r;
reg [PSUM_ADDR_W-1:0]            s3_weight_row_base_r;
reg [WEIGHT_WORD_PTR_W-1:0]      s3_weight_word_ptr_r;
reg [WEIGHT_WORD_PTR_W-1:0]      s3_weight_word_end_r;

reg                              s4_valid_r;
reg                              s4_lane0_valid_r;
reg                              s4_lane1_valid_r;
reg signed [IACT_VALUE_W-1:0]    s4_iact_value_r;
reg signed [WEIGHT_VALUE_W-1:0]  s4_weight_value0_r;
reg signed [WEIGHT_VALUE_W-1:0]  s4_weight_value1_r;
reg [PSUM_ADDR_W-1:0]            s4_psum_addr0_r;
reg [PSUM_ADDR_W-1:0]            s4_psum_addr1_r;
reg                              s4_last_weight_word_r;

reg                              s5_valid_r;
reg                              s5_lane0_valid_r;
reg                              s5_lane1_valid_r;
reg [PSUM_ADDR_W-1:0]            s5_psum_addr0_r;
reg [PSUM_ADDR_W-1:0]            s5_psum_addr1_r;
reg signed [PSUM_W-1:0]          s5_psum_old0_r;
reg signed [PSUM_W-1:0]          s5_psum_old1_r;
reg signed [PSUM_W-1:0]          s5_product0_r;
reg signed [PSUM_W-1:0]          s5_product1_r;
reg                              s5_last_weight_word_r;

// -----------------------------------------------------------------------------
// Direct PSUM SPAD accumulation
// -----------------------------------------------------------------------------
localparam integer ACC_M0_W        = (PSUM_SPAD_DEPTH <= 1) ? 1 : $clog2(PSUM_SPAD_DEPTH + 1);
localparam [PSUM_DEPTH_COUNT_W-1:0] PSUM_DEPTH_LAST = PSUM_SPAD_DEPTH - 1;

reg                              acc_ready_r;
reg                              run_drained_latched_r;
reg [ACC_M0_W-1:0]               acc_m0_r;
// Always honor runtime M0 (ctrl_cfg_m0_in); do not require +define+PE_ACC_USE_M0_PORT on RTL compile.
wire [ACC_M0_W-1:0]                acc_m0_cfg_w = ctrl_cfg_m0_in[ACC_M0_W-1:0];
wire                               acc_m0_cfg_legal_w =
    (acc_m0_cfg_w >= {{(ACC_M0_W - 1){1'b0}}, 1'b1}) &&
    ($unsigned(ctrl_cfg_m0_in) <= PSUM_SPAD_DEPTH);
wire [PSUM_DEPTH_COUNT_W-1:0]      psum_depth_cfg_w =
    ($unsigned(ctrl_cfg_m0_in) >= PSUM_SPAD_DEPTH) ? PSUM_DEPTH_LAST :
    (ctrl_cfg_m0_in == 6'd0)                      ? {PSUM_DEPTH_COUNT_W{1'b0}} :
                                                     (ctrl_cfg_m0_in[PSUM_DEPTH_COUNT_W-1:0] - {{(PSUM_DEPTH_COUNT_W-1){1'b0}}, 1'b1});

wire                             issue_weight_word_w;
wire [PSUM_ADDR_W-1:0]           s4_weight_row0_calc_w;
wire [PSUM_ADDR_W-1:0]           s4_weight_base_after_lane0_w;
wire [PSUM_ADDR_W-1:0]           s4_weight_row1_calc_w;
wire [PSUM_ADDR_W-1:0]           s4_weight_next_base_w;
wire [PSUM_ADDR_W-1:0]           s4_psum_addr0_w;
wire [PSUM_ADDR_W-1:0]           s4_psum_addr1_w;
wire                             s4_last_weight_word_w;
(* use_dsp = "yes" *) wire signed [MAC_PRODUCT_W-1:0] s5_product0_raw_w;
(* use_dsp = "yes" *) wire signed [MAC_PRODUCT_W-1:0] s5_product1_raw_w;
wire signed [PSUM_W-1:0]         s5_product0_ext_w;
wire signed [PSUM_W-1:0]         s5_product1_ext_w;
wire                             frontend_done_w;
wire                             backend_pipe_empty_w;
wire                             active_task_final_s5_w;
wire                             allow_active_start_w;

wire [WEIGHT_WORD_PTR_W-1:0] weight_issue_ptr_plus1_w;
wire                         issue_this_is_last_w;
wire [PSUM_ADDR_W-1:0]       issue_row_base_w;
wire [PSUM_ADDR_W-1:0]       weight_lane0_count_ext_w;
wire [PSUM_ADDR_W-1:0]       weight_lane1_count_ext_w;

assign weight_lane0_count_ext_w = weight_lane0_count_w;
assign weight_lane1_count_ext_w = weight_lane1_count_w;

// 8b x 8b signed product is sign-extended to the 21b PSUM datapath.
assign s5_product0_ext_w = {{(PSUM_W-MAC_PRODUCT_W){s5_product0_raw_w[MAC_PRODUCT_W-1]}}, s5_product0_raw_w};
assign s5_product1_ext_w = {{(PSUM_W-MAC_PRODUCT_W){s5_product1_raw_w[MAC_PRODUCT_W-1]}}, s5_product1_raw_w};

assign weight_issue_ptr_plus1_w = weight_word_ptr_r + {{(WEIGHT_WORD_PTR_W-1){1'b0}},1'b1};
assign issue_this_is_last_w     = (weight_issue_ptr_plus1_w >= weight_word_end_r);
assign issue_row_base_w   = s3_pending_r ? s4_weight_next_base_w : weight_row_base_r;
assign weight_router_addr_ready_out = cluster_ctrl_load_en_in &&
                                       weight_address_spad_data_in_ready_w;
assign weight_router_data_ready_out = cluster_ctrl_load_en_in &&
                                       weight_data_spad_data_in_ready_w;
assign iact_router_data_ready_out =
    cluster_ctrl_load_en_in &&
    iact_data_resident_data_ready_w &&
    !(iact_address_stream_done_r && iact_data_stream_done_r);
assign iact_payload_write_fire_w =
    iact_router_data_valid_in &&
    iact_router_data_ready_out;

assign iact_addr_entry_fire_w =
    iact_router_addr_valid_in && iact_router_addr_ready_out;

assign last_payload_entry_fire_w =
    iact_payload_write_fire_w &&
    ((iact_data_resident_wr_abs_w + {{(IACT_DATA_PTR_W-1){1'b0}},1'b1}) ==
     iact_expected_data_entries_r[IACT_DATA_PTR_W-1:0]);

assign issue_weight_word_w =
    (mode_r == MODE_RUN) && active_task_valid_r && !weight_issue_done_r &&
    !s3_delay_r && !s3_pending_r && acc_ready_r;

assign active_task_final_s5_w =
    s5_valid_r && s5_last_weight_word_r && active_task_valid_r &&
    weight_issue_done_r && queue_empty_w;

// Overlap: promote next S2 task after last weight issue, without waiting for prior S4/S5 drain.
assign allow_active_start_w =
    (mode_r == MODE_RUN) &&
    acc_ready_r &&
    s2_valid_r &&
    !s3_delay_r &&
    !s3_pending_r &&
    !active_task_final_s5_w &&
    (!active_task_valid_r || weight_issue_done_r);

// Overlap promote: S2->active must read Address SPAD for s2_weight_col, not stale active col.
assign weight_address_rd_col_idx_w =
    allow_active_start_w ? s2_weight_col_r :
    active_task_valid_r  ? active_weight_col_r :
                           s2_weight_col_r;

// Weight CSC: lane0_m = row_base + lane0_count; counts are continuous across the column.
assign s4_weight_row0_calc_w =
    s3_weight_row_base_r + weight_lane0_count_ext_w;
assign s4_weight_base_after_lane0_w = s4_weight_row0_calc_w + {{(PSUM_ADDR_W-1){1'b0}},1'b1};
assign s4_weight_row1_calc_w =
    s4_weight_base_after_lane0_w + weight_lane1_count_ext_w;
assign s4_weight_next_base_w = weight_lane1_valid_w ?
                               (s4_weight_row1_calc_w + {{(PSUM_ADDR_W-1){1'b0}},1'b1}) :
                               s4_weight_base_after_lane0_w;
// Sparse weight column: lane count fields decode the PSUM row.
assign s4_psum_addr0_w       = s4_weight_row0_calc_w;
assign s4_psum_addr1_w       = s4_weight_row1_calc_w;
assign s4_last_weight_word_w = ((s3_weight_word_ptr_r + {{(WEIGHT_WORD_PTR_W-1){1'b0}},1'b1}) >= s3_weight_word_end_r);
assign s5_product0_raw_w     = $signed(s4_weight_value0_r) * $signed(s4_iact_value_r);
assign s5_product1_raw_w     = $signed(s4_weight_value1_r) * $signed(s4_iact_value_r);
wire signed [PSUM_W-1:0]         psum_acc_rd_data0_w =
    (psum_wr_en1_r && (psum_wr_addr1_r == psum_rd_addr0_r)) ? psum_wr_data1_r :
    (psum_wr_en0_r && (psum_wr_addr0_r == psum_rd_addr0_r)) ? psum_wr_data0_r :
                                                              psum_spad_rd_data0_w;
wire signed [PSUM_W-1:0]         psum_acc_rd_data1_w =
    (psum_wr_en1_r && (psum_wr_addr1_r == psum_rd_addr1_r)) ? psum_wr_data1_r :
    (psum_wr_en0_r && (psum_wr_addr0_r == psum_rd_addr1_r)) ? psum_wr_data0_r :
                                                              psum_spad_rd_data1_w;
(* use_dsp = "no" *) wire signed [PSUM_W-1:0] acc_sum_lane0_w =
    s5_psum_old0_r + s5_product0_r;
(* use_dsp = "no" *) wire signed [PSUM_W-1:0] acc_sum_lane1_w =
    s5_psum_old1_r + s5_product1_r;
wire                               s5_lane0_acc_en_w =
    s5_lane0_valid_r && (s5_psum_addr0_r < acc_m0_r);
wire                               s5_lane1_acc_en_w =
    s5_lane1_valid_r && (s5_psum_addr1_r < acc_m0_r);
wire                               s5_acc_update_w =
    !ctrl_cfg_psum_spad_clear_in && s5_valid_r && acc_ready_r;
// Direct accumulation updates PSUM SPAD at S5; no post-MAC accumulator flush is required.
assign backend_pipe_empty_w  =
    !s2_valid_r && !active_task_valid_r && !s3_delay_r && !s3_pending_r &&
    !s4_valid_r && !s5_valid_r;
assign slide_safe_post_mac_w =
    (mode_r == MODE_IDLE) &&
    run_drained_latched_r &&
    frontend_done_w &&
    backend_pipe_empty_w;
assign slide_commit_arm_w = slide_safe_w || slide_safe_post_mac_w;
assign ctrl_status_slide_safe_out = slide_commit_arm_w;

// Sliding frontend done: iterator has completed the configured window scan and no
// pending response beat remains to be enqueued.
assign frontend_done_w =
    iter_done_r && (wm_state_r == ST_IDLE) && itr_pipe_empty_w;

assign queue_pop_w   = (mode_r == MODE_RUN) && !s2_valid_r && q0_valid_r;
wire signed [PSUM_W-1:0] psum_router_lane0_w = psum_router_data_in[PSUM_W-1:0];
wire signed [PSUM_W-1:0] psum_router_lane1_w = psum_router_data_in[(2*PSUM_W)-1:PSUM_W];
wire [PSUM_DEPTH_COUNT_W-1:0] merge_idx_p1_count_w =
    {{1'b0}, merge_idx_r} + {{(PSUM_DEPTH_COUNT_W-1){1'b0}}, 1'b1};
wire merge_lane1_valid_w = (merge_idx_p1_count_w <= psum_depth_cfg_w);
wire merge_pair_last_w   = (merge_idx_p1_count_w >= psum_depth_cfg_w);
wire signed [PSUM_W-1:0] psum_merge_lane0_w =
    $signed(psum_spad_rd_data0_w) + $signed(psum_router_lane0_w);
wire signed [PSUM_W-1:0] psum_merge_lane1_w =
    merge_lane1_valid_w
        ? ($signed(psum_spad_rd_data1_w) + $signed(psum_router_lane1_w))
        : {PSUM_W{1'b0}};
assign psum_out_w = (mode_r == MODE_MERGE)
    ? (merge_out_pending_r
        ? merge_out_pending_data_r
        : {psum_merge_lane1_w, psum_merge_lane0_w})
    : $signed({(2*PSUM_W){1'b0}});
assign queue_full_w  = q0_valid_r & q1_valid_r;
assign queue_empty_w = ~q0_valid_r && ~q1_valid_r;

// -----------------------------------------------------------------------------
// load bookkeeping
// -----------------------------------------------------------------------------
always @(posedge clk) begin
    if (rst) begin
        load_en_r               <= 1'b0;
        iact_expected_data_entries_r <= {(IACT_DATA_PTR_W+1){1'b0}};
        iact_data_stream_done_r <= 1'b0;
        iact_address_stream_done_r <= 1'b0;
    end else begin
        load_en_r <= cluster_ctrl_load_en_in;
        if (ctrl_cfg_iact_flush_in) begin
            iact_expected_data_entries_r <= {(IACT_DATA_PTR_W+1){1'b0}};
            iact_data_stream_done_r <= 1'b0;
            iact_address_stream_done_r <= 1'b0;
        end else if (iact_slide_do_r) begin
            iact_address_stream_done_r <= 1'b0;
            iact_data_stream_done_r <= 1'b0;
            iact_expected_data_entries_r <= {(IACT_DATA_PTR_W+1){1'b0}};
        end else if (load_rise_w) begin
            iact_expected_data_entries_r <= {(IACT_DATA_PTR_W+1){1'b0}};
            iact_data_stream_done_r <= 1'b0;
            iact_address_stream_done_r <= 1'b0;
        end else begin
            if (iact_address_stream_done_w) begin
                iact_address_stream_done_r <= 1'b1;
                // Last boundary is cumulative exclusive-end in absolute payload indices:
                // if wr_abs already reached that end before any new payload handshake, trailing segment empty.
                if (iact_data_resident_wr_abs_w == iact_expected_data_entries_r[IACT_DATA_PTR_W-1:0])
                    iact_data_stream_done_r <= 1'b1;
            end
            if (last_payload_entry_fire_w)
                iact_data_stream_done_r <= 1'b1;
            if (iact_addr_entry_fire_w && (iact_router_addr_in != IACT_ADDR_SENTINEL)) begin
                iact_expected_data_entries_r <= {{(IACT_DATA_PTR_W+1-IACT_ADDR_W){1'b0}}, iact_router_addr_in};
            end
        end
    end
end

// -----------------------------------------------------------------------------
// main sequential logic
// -----------------------------------------------------------------------------
always @(posedge clk) begin
    if (rst) begin
        mode_r                  <= MODE_IDLE;
        merge_idx_r             <= {PSUM_ADDR_W{1'b0}};
        cal_fin_r               <= 1'b0;
        psum_acc_fin_r          <= 1'b0;
        weight_data_read_en_r       <= 1'b0;
        weight_data_read_word_idx_r <= {WEIGHT_WORD_PTR_W{1'b0}};

        merge_req_pending_r     <= 1'b0;

        mac_req_pending_r <= 1'b0;
        weight_addr_loaded_r <= 1'b0;
        weight_data_loaded_r <= 1'b0;

        psum_rd_en0_r <= 1'b0;
        psum_rd_en1_r <= 1'b0;
        psum_rd_addr0_r <= {PSUM_ADDR_W{1'b0}};
        psum_rd_addr1_r <= {PSUM_ADDR_W{1'b0}};
        psum_wr_en0_r <= 1'b0;
        psum_wr_en1_r <= 1'b0;
        psum_wr_addr0_r <= {PSUM_ADDR_W{1'b0}};
        psum_wr_addr1_r <= {PSUM_ADDR_W{1'b0}};
        psum_wr_data0_r <= {PSUM_W{1'b0}};
        psum_wr_data1_r <= {PSUM_W{1'b0}};
        psum_out_r <= {(2*PSUM_W){1'b0}};
        psum_in_valid_r <= 1'b0;
        merge_out_pending_r <= 1'b0;
        merge_out_pending_data_r <= {(2*PSUM_W){1'b0}};

        q0_valid_r               <= 1'b0;
        q1_valid_r               <= 1'b0;
        q0_value_r               <= {IACT_VALUE_W{1'b0}};
        q1_value_r               <= {IACT_VALUE_W{1'b0}};
        q0_weight_col_r          <= {WEIGHT_COL_IDX_W{1'b0}};
        q1_weight_col_r          <= {WEIGHT_COL_IDX_W{1'b0}};

        s2_valid_r               <= 1'b0;
        s2_iact_value_r          <= {IACT_VALUE_W{1'b0}};
        s2_weight_col_r          <= {WEIGHT_COL_IDX_W{1'b0}};

        active_task_valid_r      <= 1'b0;
        active_iact_value_r      <= {IACT_VALUE_W{1'b0}};
        active_weight_col_r      <= {WEIGHT_COL_IDX_W{1'b0}};
        weight_word_ptr_r        <= {WEIGHT_WORD_PTR_W{1'b0}};
        weight_word_end_r        <= {WEIGHT_WORD_PTR_W{1'b0}};
        weight_row_base_r        <= {PSUM_ADDR_W{1'b0}};
        weight_issue_done_r      <= 1'b0;

        s3_pending_r             <= 1'b0;
        s3_delay_r               <= 1'b0;
        s3_iact_value_r          <= {IACT_VALUE_W{1'b0}};
        s3_weight_row_base_r     <= {PSUM_ADDR_W{1'b0}};
        s3_weight_word_ptr_r     <= {WEIGHT_WORD_PTR_W{1'b0}};
        s3_weight_word_end_r     <= {WEIGHT_WORD_PTR_W{1'b0}};

        s4_valid_r               <= 1'b0;
        s4_lane0_valid_r         <= 1'b0;
        s4_lane1_valid_r         <= 1'b0;
        s4_iact_value_r          <= {IACT_VALUE_W{1'b0}};
        s4_weight_value0_r       <= {WEIGHT_VALUE_W{1'b0}};
        s4_weight_value1_r       <= {WEIGHT_VALUE_W{1'b0}};
        s4_psum_addr0_r          <= {PSUM_ADDR_W{1'b0}};
        s4_psum_addr1_r          <= {PSUM_ADDR_W{1'b0}};
        s4_last_weight_word_r    <= 1'b0;

        s5_valid_r               <= 1'b0;
        s5_lane0_valid_r         <= 1'b0;
        s5_lane1_valid_r         <= 1'b0;
        s5_psum_addr0_r          <= {PSUM_ADDR_W{1'b0}};
        s5_psum_addr1_r          <= {PSUM_ADDR_W{1'b0}};
        s5_psum_old0_r           <= {PSUM_W{1'b0}};
        s5_psum_old1_r           <= {PSUM_W{1'b0}};
        s5_product0_r            <= {PSUM_W{1'b0}};
        s5_product1_r            <= {PSUM_W{1'b0}};
        s5_last_weight_word_r    <= 1'b0;

        acc_ready_r            <= 1'b0;
        run_drained_latched_r  <= 1'b0;
        acc_m0_r                   <= {ACC_M0_W{1'b0}};

        sliding_resp_valid_r     <= 1'b0;
        sliding_resp_value_r     <= {IACT_VALUE_W{1'b0}};
        sliding_resp_weight_col_r <= {WEIGHT_COL_IDX_W{1'b0}};
        sliding_resp_retire_offp1_r <= {IACT_DATA_PTR_W{1'b0}};
        itr_rd_first_r           <= 1'b1;
        itr_rd_offset_base_r     <= {IACT_DATA_PTR_W{1'b0}};
        itr_cap_word_r           <= {IACT_DATA_W{1'b0}};
        itr_cap_first_r          <= 1'b1;
        itr_cap_offset_base_r    <= {IACT_DATA_PTR_W{1'b0}};
        itr_dec_value_r          <= {IACT_VALUE_W{1'b0}};
        itr_dec_weight_col_r     <= {WEIGHT_COL_IDX_W{1'b0}};
        itr_dec_offset_in_seg_r  <= {IACT_DATA_PTR_W{1'b0}};
        itr_dec_skip_r           <= 1'b0;
        wm_state_r               <= ST_IDLE;
        iter_active_r            <= 1'b0;
        iter_done_r              <= 1'b0;
        iter_seg_rel_r           <= {IACT_SEG_IDX_W{1'b0}};
        iter_entry_abs_r         <= {IACT_DATA_PTR_W{1'b0}};
        iter_entry_end_abs_r     <= {IACT_DATA_PTR_W{1'b0}};
        iter_logical_seg_base_r  <= {IACT_DATA_PTR_W{1'b0}};
    end else begin

        if (cluster_ctrl_mac_en_in && (mode_r == MODE_IDLE))
            mac_req_pending_r <= 1'b1;
        if (weight_address_spad_write_fin_w)
            weight_addr_loaded_r <= 1'b1;
        if (weight_data_spad_write_fin_w)
            weight_data_loaded_r <= 1'b1;
        cal_fin_r      <= 1'b0;
        psum_acc_fin_r <= 1'b0;

        if (ctrl_cfg_iact_flush_in) begin
            q0_valid_r             <= 1'b0;
            q1_valid_r             <= 1'b0;
            s2_valid_r             <= 1'b0;
            active_task_valid_r    <= 1'b0;
            weight_issue_done_r    <= 1'b0;
            s3_pending_r           <= 1'b0;
            s3_delay_r             <= 1'b0;
            s4_valid_r             <= 1'b0;
            s5_valid_r             <= 1'b0;
            iter_active_r          <= 1'b0;
            iter_done_r            <= 1'b0;
            iter_seg_rel_r         <= {IACT_SEG_IDX_W{1'b0}};
            iter_entry_abs_r       <= {IACT_DATA_PTR_W{1'b0}};
            iter_entry_end_abs_r   <= {IACT_DATA_PTR_W{1'b0}};
            iter_logical_seg_base_r<= {IACT_DATA_PTR_W{1'b0}};
            wm_state_r             <= ST_IDLE;
            sliding_resp_valid_r   <= 1'b0;
            sliding_resp_retire_offp1_r <= {IACT_DATA_PTR_W{1'b0}};
        end

        weight_data_read_en_r       <= 1'b0;
        weight_data_read_word_idx_r <= weight_word_ptr_r;

        psum_rd_en0_r    <= 1'b0;
        psum_rd_en1_r    <= 1'b0;
        psum_rd_addr0_r  <= {PSUM_ADDR_W{1'b0}};
        psum_rd_addr1_r  <= {PSUM_ADDR_W{1'b0}};
        psum_wr_en0_r    <= 1'b0;
        psum_wr_en1_r    <= 1'b0;
        psum_wr_addr0_r       <= {PSUM_ADDR_W{1'b0}};
        psum_wr_addr1_r       <= {PSUM_ADDR_W{1'b0}};
        psum_wr_data0_r       <= {PSUM_W{1'b0}};
        psum_wr_data1_r       <= {PSUM_W{1'b0}};
        if (mode_r == MODE_MERGE && merge_out_pending_r)
            psum_out_r <= merge_out_pending_data_r;
        else
            psum_out_r <= psum_out_w;
        if (mode_r == MODE_MERGE && merge_out_pending_r)
            psum_in_valid_r <= 1'b0;
        else
            psum_in_valid_r <= psum_router_valid_in;

        if (ctrl_cfg_psum_spad_clear_in) begin
            acc_ready_r        <= 1'b0;
            acc_m0_r                 <= {ACC_M0_W{1'b0}};
        end

        // S4 -> S5 (product latch; PSUM SPAD read was issued when S4 was loaded)
        s5_valid_r <= s4_valid_r;
        if (s4_valid_r) begin
            s5_lane0_valid_r      <= s4_lane0_valid_r;
            s5_lane1_valid_r      <= s4_lane1_valid_r;
            s5_psum_addr0_r       <= s4_psum_addr0_r;
            s5_psum_addr1_r       <= s4_psum_addr1_r;
            s5_psum_old0_r        <= psum_acc_rd_data0_w;
            s5_psum_old1_r        <= psum_acc_rd_data1_w;
            s5_product0_r         <= s5_product0_ext_w;
            s5_product1_r         <= s5_product1_ext_w;
            s5_last_weight_word_r <= s4_last_weight_word_r;
        end else begin
            s5_lane0_valid_r      <= 1'b0;
            s5_lane1_valid_r      <= 1'b0;
            s5_psum_old0_r        <= {PSUM_W{1'b0}};
            s5_psum_old1_r        <= {PSUM_W{1'b0}};
            s5_last_weight_word_r <= 1'b0;
        end

        // returned weight word -> S4 and update next issue state
        s4_valid_r <= s3_pending_r;
        if (s3_pending_r) begin
            s4_lane0_valid_r          <= weight_lane0_valid_w;
            s4_lane1_valid_r          <= weight_lane1_valid_w;
            s4_iact_value_r           <= s3_iact_value_r;
            s4_weight_value0_r        <= weight_lane0_value_w;
            s4_weight_value1_r        <= weight_lane1_value_w;
            s4_psum_addr0_r           <= s4_psum_addr0_w;
            s4_psum_addr1_r           <= s4_psum_addr1_w;
            s4_last_weight_word_r     <= s4_last_weight_word_w;

            psum_rd_en0_r             <= weight_lane0_valid_w;
            psum_rd_addr0_r           <= s4_psum_addr0_w;
            psum_rd_en1_r             <= weight_lane1_valid_w;
            psum_rd_addr1_r           <= s4_psum_addr1_w;

            if (!s4_last_weight_word_w) begin
                weight_row_base_r   <= s4_weight_next_base_w;
            end
        end
        s3_pending_r <= 1'b0;

        // Latch a merge request so a one-cycle pulse from the testbench is enough.
        if (cluster_ctrl_psum_enq_en_in)
            merge_req_pending_r <= 1'b1;

        case (mode_r)
            MODE_IDLE: begin
                // start requirements: at least two address entries in address_spad and one data entry in data_spad
                if (merge_req_pending_r) begin
                    mode_r <= MODE_MERGE;
                    merge_idx_r <= {PSUM_ADDR_W{1'b0}};
                    merge_out_pending_r <= 1'b0;
                    merge_req_pending_r <= 1'b0;
                    // Prefetch one PSUM pair so the first merge beat sees both local values.
                    psum_rd_en0_r <= 1'b1;
                    psum_rd_en1_r <= 1'b1;
                    psum_rd_addr0_r <= {PSUM_ADDR_W{1'b0}};
                    psum_rd_addr1_r <= {{(PSUM_ADDR_W-1){1'b0}}, 1'b1};
                end else if (mac_req_pending_r && mac_start_ready_w) begin
                    if (acc_m0_cfg_legal_w) begin
                    mode_r                   <= MODE_RUN;
                    mac_req_pending_r <= 1'b0;
                    wm_state_r          <= ST_IDLE;
                    // Each MAC invocation: allow resident iterator to run again; drop stale task beat.
                    iter_done_r                <= 1'b0;
                    iter_active_r              <= 1'b0;
                    sliding_resp_valid_r       <= 1'b0;
                    sliding_resp_retire_offp1_r <= {IACT_DATA_PTR_W{1'b0}};
                    iter_seg_rel_r             <= {IACT_SEG_IDX_W{1'b0}};
                    iter_entry_abs_r           <= {IACT_DATA_PTR_W{1'b0}};
                    iter_entry_end_abs_r       <= {IACT_DATA_PTR_W{1'b0}};
                    iter_logical_seg_base_r    <= {IACT_DATA_PTR_W{1'b0}};
                    acc_ready_r                <= 1'b1;
                    run_drained_latched_r      <= 1'b0;
                    acc_m0_r                   <= acc_m0_cfg_w;
                    q0_valid_r          <= 1'b0;
                    q1_valid_r          <= 1'b0;
                    s2_valid_r           <= 1'b0;
                    active_task_valid_r  <= 1'b0;
                    weight_issue_done_r  <= 1'b0;
                    s3_pending_r         <= 1'b0;
                    s4_valid_r           <= 1'b0;
                    s5_valid_r           <= 1'b0;
                    end else begin
                        mac_req_pending_r <= 1'b0;
                    end
                end
            end

            MODE_RUN: begin
                // -----------------------------------------------------------------
                // Resident window manager: Address/Data SPads + iterator → sliding_resp_* pending beat.
                // -----------------------------------------------------------------
                    case (wm_state_r)
                        ST_IDLE: begin
                            if (sliding_iter_start_w && acc_ready_r) begin
                                iter_active_r <= 1'b1;
                                iter_done_r <= 1'b0;
                                wm_state_r <= ST_ITER_INIT;
                            end
                        end
                        ST_ITER_INIT: begin
                            iter_seg_rel_r <= {IACT_SEG_IDX_W{1'b0}};
                            iter_logical_seg_base_r <= {IACT_DATA_PTR_W{1'b0}};
                            wm_state_r <= ST_ITER_SEG;
                        end
                        ST_ITER_SEG: begin
                            wm_state_r <= ST_ITER_SEG_USE;
                        end
                        ST_ITER_SEG_USE: begin
                            if (!iact_iter_seg_valid_w || (iact_iter_seg_begin_w == iact_iter_seg_end_w)) begin
                                wm_state_r <= ST_NEXT_SEG;
                            end else begin
                                iter_entry_abs_r <= iact_iter_seg_begin_w;
                                iter_entry_end_abs_r <= iact_iter_seg_end_w;
                                itr_rd_first_r <= 1'b1;
                                itr_rd_offset_base_r <= {IACT_DATA_PTR_W{1'b0}};
                                wm_state_r <= ST_ITER_PAYLOAD_WAIT;
                            end
                        end
                        ST_ITER_PAYLOAD_WAIT: begin
                            // Registered Data SPad: address (iter_entry_abs_r) held; data valid next cycle.
                            wm_state_r <= ST_ITER_PAYLOAD_CAPTURE;
                        end
                        ST_ITER_PAYLOAD_CAPTURE: begin
                            itr_cap_word_r <= iact_data_resident_data_out_w;
                            itr_cap_first_r <= itr_rd_first_r;
                            itr_cap_offset_base_r <= itr_rd_offset_base_r;
                            wm_state_r <= ST_ITER_DECODE;
                        end
                        ST_ITER_DECODE: begin
                            itr_dec_value_r <= itr_dec_val_w;
                            itr_dec_weight_col_r <= itr_dec_full_weight_col_w;
                            itr_dec_offset_in_seg_r <= itr_dec_off_in_w;
                            itr_dec_skip_r <= itr_dec_skip_w;
                            wm_state_r <= ST_ITER_ENTRY;
                        end
                        ST_ITER_ENTRY: begin
                            if (sliding_resp_valid_r) begin
                                if (frontend_task_ready_w) begin
                                    sliding_resp_valid_r <= 1'b0;
                                    iter_entry_abs_r <= iter_entry_next_w;
                                    if (iter_entry_is_last_w) begin
                                        wm_state_r <= ST_NEXT_SEG;
                                    end else begin
                                        wm_state_r <= ST_ITER_PAYLOAD_WAIT;
                                        itr_rd_first_r <= 1'b0;
                                        itr_rd_offset_base_r <= sliding_resp_retire_offp1_r;
                                    end
                                end
                            end else if (itr_dec_skip_r) begin
                                iter_entry_abs_r <= iter_entry_next_w;
                                if (iter_entry_is_last_w) begin
                                    wm_state_r <= ST_NEXT_SEG;
                                end else begin
                                    wm_state_r <= ST_ITER_PAYLOAD_WAIT;
                                    itr_rd_first_r <= 1'b0;
                                    itr_rd_offset_base_r <= itr_dec_offset_in_seg_r + {{(IACT_DATA_PTR_W-1){1'b0}}, 1'b1};
                                end
                            end else if (!sliding_resp_valid_r) begin
                                sliding_resp_valid_r <= 1'b1;
                                sliding_resp_value_r <= itr_dec_value_r;
                                sliding_resp_weight_col_r <= itr_dec_weight_col_r;
                                sliding_resp_retire_offp1_r <= itr_dec_offset_in_seg_r + {{(IACT_DATA_PTR_W-1){1'b0}}, 1'b1};
                            end
                        end
                        ST_NEXT_SEG: begin
                            if ((iter_seg_rel_r + {{(IACT_SEG_IDX_W-1){1'b0}}, 1'b1}) >= current_window_seg_count_w) begin
                                iter_active_r <= 1'b0;
                                iter_done_r <= 1'b1;
                                wm_state_r <= ST_IDLE;
                            end else begin
                                iter_seg_rel_r <= iter_seg_rel_r + {{(IACT_SEG_IDX_W-1){1'b0}}, 1'b1};
                                iter_logical_seg_base_r <= iter_logical_seg_base_r + current_segment_len_w;
                                wm_state_r <= ST_ITER_SEG;
                            end
                        end
                    endcase

                // pop queue into S2 when S2 is free
                if (queue_pop_w) begin
                    s2_valid_r       <= 1'b1;
                    s2_iact_value_r  <= q0_value_r;
                    s2_weight_col_r  <= q0_weight_col_r;
                end

                // Promote S2 -> active when allowed.
                if (allow_active_start_w) begin
                    if (weight_col_begin_w == weight_col_end_w) begin
                        s2_valid_r <= 1'b0;
                    end else begin
                        active_task_valid_r <= 1'b1;
                        active_iact_value_r <= s2_iact_value_r;
                        active_weight_col_r <= s2_weight_col_r;
                        weight_word_ptr_r   <= weight_col_begin_w;
                        weight_word_end_r   <= weight_col_end_w;
                        weight_row_base_r   <= {PSUM_ADDR_W{1'b0}};
                        weight_issue_done_r <= 1'b0;
                        s2_valid_r          <= 1'b0;
                    end
                end

                // issue next weight word of the active task
                if (issue_weight_word_w) begin
                    weight_data_read_en_r       <= 1'b1;
                    weight_data_read_word_idx_r <= weight_word_ptr_r;
                    s3_delay_r                  <= 1'b1;
                    s3_iact_value_r             <= active_iact_value_r;
                    s3_weight_row_base_r        <= issue_row_base_w;
                    s3_weight_word_ptr_r        <= weight_word_ptr_r;
                    s3_weight_word_end_r        <= weight_word_end_r;

                    if (issue_this_is_last_w) begin
                        weight_issue_done_r <= 1'b1;  
                    end else begin
                        weight_word_ptr_r  <= weight_issue_ptr_plus1_w;
                    end
                end

                if (s3_delay_r) begin
                    s3_pending_r <= 1'b1;
                    s3_delay_r   <= 1'b0;
                end
                
                if (frontend_done_w && queue_empty_w && backend_pipe_empty_w &&
                    !run_drained_latched_r) begin
                    run_drained_latched_r <= 1'b1;
                    mode_r                <= MODE_IDLE;
                    cal_fin_r             <= 1'b1;
                    acc_ready_r           <= 1'b0;
                end

                // Retire the active task when its final issued weight word leaves
                // S5. S2 promotion is deliberately held off for this cycle so the
                // active task register is not retired and replaced at the same edge.
                if (active_task_final_s5_w) begin
                    active_task_valid_r <= 1'b0;
                    weight_issue_done_r <= 1'b0;
                end
            end
            // Merge: hold final output beat until downstream accepts (Phase 1X / S-B).
            MODE_MERGE: begin
                if (merge_out_pending_r) begin
                    if (psum_router_ready_in) begin
                        merge_out_pending_r <= 1'b0;
                        psum_acc_fin_r      <= 1'b1;
                        mode_r              <= MODE_IDLE;
                        merge_req_pending_r <= 1'b0;
                    end
                end else begin
                    psum_rd_en0_r   <= 1'b1;
                    psum_rd_en1_r   <= 1'b1;
                    psum_rd_addr0_r <= merge_idx_r
                                     + (((psum_router_valid_in && psum_router_ready_in) &&
                                         !merge_pair_last_w)
                                        ? {{(PSUM_ADDR_W-2){1'b0}},2'b10}
                                        : {PSUM_ADDR_W{1'b0}});
                    psum_rd_addr1_r <= merge_idx_r
                                     + (((psum_router_valid_in && psum_router_ready_in) &&
                                         !merge_pair_last_w)
                                        ? {{(PSUM_ADDR_W-2){1'b0}},2'b11}
                                        : {{(PSUM_ADDR_W-1){1'b0}},1'b1});
                    if (psum_router_valid_in && psum_router_ready_in) begin
                        if (merge_pair_last_w) begin
                            merge_out_pending_r      <= 1'b1;
                            merge_out_pending_data_r <= psum_out_w;
                        end else begin
                            merge_idx_r <= merge_idx_r + {{(PSUM_ADDR_W-2){1'b0}},2'b10};
                        end
                    end
                end
            end

            default: begin
                mode_r <= MODE_IDLE;
            end
        endcase

        // Direct PSUM SPAD update at S5 commit.
        if (s5_acc_update_w) begin
            if (s5_lane0_acc_en_w) begin
                psum_wr_en0_r   <= 1'b1;
                psum_wr_addr0_r <= s5_psum_addr0_r;
                psum_wr_data0_r <= acc_sum_lane0_w;
            end
            if (s5_lane1_acc_en_w) begin
                psum_wr_en1_r   <= 1'b1;
                psum_wr_addr1_r <= s5_psum_addr1_r;
                psum_wr_data1_r <= acc_sum_lane1_w;
            end
        end

        // 2-entry queue update, after normalized frontend push/pop decisions are known
        case ({frontend_task_valid_w && frontend_task_ready_w, queue_pop_w})
            2'b00: begin
                // no-op
            end
            2'b01: begin
                if (q1_valid_r) begin
                    q0_valid_r      <= 1'b1;
                    q0_value_r      <= q1_value_r;
                    q0_weight_col_r <= q1_weight_col_r;
                    q1_valid_r      <= 1'b0;
                end else begin
                    q0_valid_r <= 1'b0;
                end
            end
            2'b10: begin
                if (!q0_valid_r) begin
                    q0_valid_r      <= 1'b1;
                    q0_value_r      <= frontend_task_iact_value_w;
                    q0_weight_col_r <= frontend_task_weight_col_w;
                end else begin
                    q1_valid_r      <= 1'b1;
                    q1_value_r      <= frontend_task_iact_value_w;
                    q1_weight_col_r <= frontend_task_weight_col_w;
                end
            end
            2'b11: begin
                if (q1_valid_r) begin
                    q0_valid_r      <= 1'b1;
                    q0_value_r      <= q1_value_r;
                    q0_weight_col_r <= q1_weight_col_r;
                    q1_valid_r      <= 1'b1;
                    q1_value_r      <= frontend_task_iact_value_w;
                    q1_weight_col_r <= frontend_task_weight_col_w;
                end else begin
                    q0_valid_r      <= 1'b1;
                    q0_value_r      <= frontend_task_iact_value_w;
                    q0_weight_col_r <= frontend_task_weight_col_w;
                    q1_valid_r      <= 1'b0;
                end
            end
        endcase
    end
end

endmodule
