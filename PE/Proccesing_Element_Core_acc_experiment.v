//***************************************************************************
// Title: Processing Element Core
// Author: DoKhanh
// Date: 08/04/2026
// Description: PE core pipeline for MAC datapath, resident IACT fetch, psum
//               merge/writeback, and max-pool.
//***************************************************************************

`default_nettype none
module Processing_Element_core_pipeline #(
    // SPAD depths (Eyeriss v2 PE)
    parameter integer IACT_ADDR_SPAD_DEPTH   = 9,
    parameter integer IACT_DATA_SPAD_DEPTH   = 16,
    parameter integer WEIGHT_ADDR_SPAD_DEPTH = 16,
    parameter integer WEIGHT_DATA_SPAD_DEPTH = 96,
    parameter integer PSUM_SPAD_DEPTH          = 32,
    // Derived widths: $clog2(depth) indexes RAM; iact boundaries use +1 bit for exclusive-end (0..depth).
    parameter integer IACT_ADDR_W            = ($clog2(IACT_DATA_SPAD_DEPTH) + 1),
    parameter integer IACT_DATA_PTR_W          = ($clog2(IACT_DATA_SPAD_DEPTH) + 1),
    parameter integer IACT_SEG_IDX_W           = $clog2(IACT_ADDR_SPAD_DEPTH),
    parameter integer WEIGHT_ADDR_W            = $clog2(WEIGHT_DATA_SPAD_DEPTH),
    parameter integer WEIGHT_COL_IDX_W         = $clog2(WEIGHT_ADDR_SPAD_DEPTH),
    parameter integer WEIGHT_WORD_PTR_W        = $clog2(WEIGHT_DATA_SPAD_DEPTH),
    parameter integer PSUM_ADDR_W              = $clog2(PSUM_SPAD_DEPTH),
    parameter integer IACT_DATA_W              = 13,
    parameter integer IACT_COUNT_W             = 5,
    parameter integer IACT_VALUE_W             = 8,
    parameter integer WEIGHT_COUNT_W           = 4,
    parameter integer WEIGHT_VALUE_W           = 8,
    parameter integer WEIGHT_PACKED_W          = 24,
    parameter integer PSUM_W                   = 21,
    parameter integer WEIGHT_MATRIX_ROW        = 32,
    // M0 active rows per MAC (1..WEIGHT_MATRIX_ROW), from ctrl_cfg_m0_in each MAC.
    parameter integer ACC_CFG_M0               = 4
)(
    input  wire                         clk,
    input  wire                         rst,

    output wire                         psum_router_ready_out,
    input  wire                         psum_router_valid_in,
    input  wire signed [PSUM_W-1:0]     psum_router_data_in,
    input  wire                         psum_router_ready_in,
    output wire                         psum_router_valid_out,
    output wire signed [PSUM_W-1:0]     psum_router_data_out,
    
    input  wire                         iact_router_addr_valid_in,
    input  wire [IACT_ADDR_W-1:0]       iact_router_addr_in,
    output wire                         iact_router_addr_ready_out,
    input  wire                         iact_router_data_valid_in,
    input  wire [IACT_DATA_W-1:0]       iact_router_data_in,
    output wire                         iact_router_data_ready_out,

    input  wire                         weight_router_addr_valid_in,
    input  wire [WEIGHT_ADDR_W-1:0]     weight_router_addr_in,
    output wire                         weight_router_addr_ready_out,
    input  wire                         weight_router_data_valid_in,
    input  wire [WEIGHT_PACKED_W-1:0]   weight_router_data_in,
    output wire                         weight_router_data_ready_out,

    input  wire                         cluster_ctrl_mac_en_in,
    input  wire                         cluster_ctrl_psum_enq_en_in,
    input  wire                         cluster_ctrl_load_en_in,
    output wire                         ctrl_status_cal_fin_out,
    output wire                         ctrl_status_slide_safe_out,
    output wire                         ctrl_status_iact_address_write_fin_out,
    output wire                         ctrl_status_iact_data_write_fin_out,
    output wire                         ctrl_status_weight_address_write_fin_out,
    output wire                         ctrl_status_weight_data_write_fin_out,
    output wire                         ctrl_status_psum_acc_fin_out,
    input  wire [PSUM_ADDR_W-1:0]       ctrl_cfg_psum_depth_in,
    input  wire                         ctrl_cfg_psum_spad_clear_in,

    // Resident convolution window configuration (single resident IACT frontend)
    input  wire [4:0]                   ctrl_cfg_window_size_in,
    input  wire [4:0]                   ctrl_cfg_segment_len_in,
    input  wire [3:0]                   ctrl_cfg_window_seg_count_in,
    input  wire [4:0]                   ctrl_cfg_psum_base_in,
    input  wire [5:0]                   ctrl_cfg_m0_in,
    input  wire                         ctrl_cfg_iact_flush_in,
    input  wire                         ctrl_cfg_slide_commit_in,

    // max-pooling signals
    input  wire                         cluster_ctrl_pool_cmp_en_in,
    input  wire                         cluster_ctrl_pool_cmp_stop_in,
    input  wire                         pool_router_elem_valid_in,
    output wire                         pool_router_elem_ready_out,
    input  wire signed [IACT_VALUE_W-1:0] pool_router_elem_data_in,
    input  wire                         pool_router_win_first_in,
    input  wire                         pool_router_win_last_in,
    output wire                         pool_router_out_valid_out,
    input  wire                         pool_router_out_ready_in,
    output wire signed [IACT_VALUE_W-1:0] pool_router_out_data_out
);

localparam [1:0] MODE_IDLE   = 2'd0;
localparam [1:0] MODE_RUN    = 2'd1;
localparam [1:0] MODE_MERGE  = 2'd2;
localparam [1:0] MODE_POOL   = 2'd3;
localparam [IACT_ADDR_W-1:0] IACT_ADDR_SENTINEL = {IACT_ADDR_W{1'b1}};

// -----------------------------------------------------------------------------
// coarse mode and completion pulses
// -----------------------------------------------------------------------------
reg [1:0] mode_r;
reg       cal_fin_r;
reg       psum_acc_fin_r;

// Max-pool compare engine (separate from MAC / psum datapath)
reg signed [IACT_VALUE_W-1:0] pool_max_r;
reg                           pool_out_valid_r;
reg signed [IACT_VALUE_W-1:0] pool_out_r;

wire signed [IACT_VALUE_W-1:0] pool_next_max_w;
wire                           pool_xfer_w;

assign pool_next_max_w = pool_router_win_first_in ? $signed(pool_router_elem_data_in)
       : (($signed(pool_router_elem_data_in) > $signed(pool_max_r)) ? pool_router_elem_data_in : pool_max_r);
assign pool_xfer_w     = (mode_r == MODE_POOL) && pool_router_elem_valid_in && pool_router_elem_ready_out;
assign pool_router_elem_ready_out = (mode_r == MODE_POOL) && (!pool_out_valid_r || pool_router_out_ready_in);
assign pool_router_out_valid_out = pool_out_valid_r;
assign pool_router_out_data_out  = pool_out_r;
reg [PSUM_ADDR_W-1:0] merge_idx_r;
reg                                psum_rd_en0_r;
assign ctrl_status_cal_fin_out       = cal_fin_r;
assign ctrl_status_psum_acc_fin_out = psum_acc_fin_r;
assign psum_router_ready_out  = (mode_r == MODE_MERGE) ? psum_router_ready_in : 1'b0;
reg psum_in_valid_r;
assign psum_router_valid_out = (mode_r == MODE_MERGE) ? psum_in_valid_r : 1'b0;

reg merge_req_pending_r;
reg weight_addr_loaded_r;
reg weight_data_loaded_r;

// MAC start request latch
reg mac_req_pending_r;
wire mac_start_w;
wire mac_start_ready_w;
assign mac_start_w = cluster_ctrl_mac_en_in;
//

reg                            load_en_r;
reg                            weight_addr_load_seen_r;
reg                            weight_data_load_seen_r;
wire                           load_rise_w;
assign load_rise_w = cluster_ctrl_load_en_in & ~load_en_r;
// -----------------------------------------------------------------------------
// SPad interfaces — IACT address/data SPads are resident-only (metadata ring + payload log)
// -----------------------------------------------------------------------------
wire                               iact_address_stream_done_w;
wire [IACT_DATA_PTR_W-1:0]         iact_spad_resident_rd_seg_begin_w;
wire [IACT_DATA_PTR_W-1:0]         iact_spad_resident_rd_seg_end_w;
reg  [IACT_DATA_PTR_W:0]           iact_expected_data_entries_r;
wire                               iact_addr_entry_fire_w;
wire                               iact_payload_write_fire_w;
wire                               last_payload_entry_fire_w;
reg                                iact_data_stream_done_r;
reg                                iact_address_stream_done_r;

// Resident payload log wiring
wire                               iact_data_resident_en_w;
wire                               iact_data_resident_flush_w;
wire                               iact_data_resident_free_update_valid_w;
wire [IACT_DATA_PTR_W-1:0]         iact_data_resident_free_abs_w;
wire                               iact_data_resident_data_valid_w;
wire [IACT_DATA_W-1:0]             iact_data_resident_data_in_w;
wire                               iact_data_resident_data_last_w;
wire                               iact_data_resident_seg_empty_w;
wire                               iact_data_resident_data_ready_w;
wire [IACT_DATA_PTR_W-1:0]         iact_data_resident_read_abs_idx_w;
wire [IACT_DATA_W-1:0]             iact_data_resident_data_out_w;
wire                               iact_data_resident_seg_open_w;
wire [IACT_DATA_PTR_W-1:0]         iact_data_resident_wr_abs_w;
wire [IACT_DATA_PTR_W-1:0]         iact_data_resident_free_abs_out_w;

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
wire signed [PSUM_W-1:0]           psum_out_w;
reg signed  [PSUM_W-1:0]           psum_out_r;
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
wire                               backend_drained_post_mac_w;

always @(posedge clk) begin
    if (rst)
        cfg_slide_commit_d1_r <= 1'b0;
    else
        cfg_slide_commit_d1_r <= ctrl_cfg_slide_commit_in;
end
assign iact_slide_commit_rise_w =
    ctrl_cfg_slide_commit_in &&
    !cfg_slide_commit_d1_r &&
    (slide_commit_arm_w === 1'b1);

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
    .RES_ABS_PTR_W (IACT_DATA_PTR_W)
) u_iact_data_spad (
    .clk           (clk),
    .rst           (rst),
    .resident_en               (iact_data_resident_en_w),
    .resident_flush            (iact_data_resident_flush_w),
    .resident_free_update_valid(iact_data_resident_free_update_valid_w),
    .resident_free_abs_in      (iact_data_resident_free_abs_w),
    .resident_data_valid       (iact_data_resident_data_valid_w),
    .resident_data_in          (iact_data_resident_data_in_w),
    .resident_data_last        (iact_data_resident_data_last_w),
    .resident_seg_empty        (iact_data_resident_seg_empty_w),
    .resident_data_ready       (iact_data_resident_data_ready_w),
    .resident_seg_commit_valid (),
    .resident_seg_commit_begin (),
    .resident_seg_commit_end   (),
    .resident_read_abs_idx     (iact_data_resident_read_abs_idx_w),
    .resident_data_out         (iact_data_resident_data_out_w),
    .resident_seg_open         (iact_data_resident_seg_open_w),
    .resident_wr_abs           (iact_data_resident_wr_abs_w),
    .resident_free_abs         (iact_data_resident_free_abs_out_w)
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
localparam integer IACT_SEG_DEPTH  = IACT_ADDR_SPAD_DEPTH;
localparam integer SEG_PTR_W       = $clog2(IACT_SEG_DEPTH);
localparam [SEG_PTR_W-1:0]         SEG_RING_LAST = IACT_SEG_DEPTH - 1;
localparam [3:0] ST_IDLE         = 4'd0;
localparam [3:0] ST_ITER_INIT    = 4'd2;
localparam [3:0] ST_ITER_SEG     = 4'd3;
localparam [3:0] ST_ITER_SEG_USE = 4'd4;
localparam [3:0] ST_ITER_ENTRY   = 4'd5;
localparam [3:0] ST_ITER_DECODE  = 4'd6;
localparam [3:0] ST_NEXT_SEG     = 4'd7;
localparam [3:0] ST_DONE         = 4'd8;
localparam [3:0] ST_ITER_PAYLOAD_WAIT    = 4'd9;
localparam [3:0] ST_ITER_PAYLOAD_CAPTURE = 4'd10;

// Wrap ring indices 0..IACT_SEG_DEPTH-1 (depth 9 needs explicit wrap; depth 8 worked by 3-bit overflow).
function [SEG_PTR_W-1:0] seg_ring_inc_f;
    input [SEG_PTR_W-1:0] cur;
    begin
        if (cur == SEG_RING_LAST)
            seg_ring_inc_f = {SEG_PTR_W{1'b0}};
        else
            seg_ring_inc_f = cur + {{(SEG_PTR_W-1){1'b0}}, 1'b1};
    end
endfunction

// -----------------------------------------------------------------------------
// Resident iterator and MAC pipeline.
// -----------------------------------------------------------------------------
reg [3:0] wm_state_r;
reg       iter_active_r;
reg       iter_done_r;
reg [SEG_PTR_W-1:0] iter_phys_seg_r;
reg [IACT_DATA_PTR_W-1:0] iter_entry_abs_r, iter_entry_end_abs_r;
reg                        iter_first_entry_r;
reg [IACT_DATA_PTR_W-1:0]  iter_offset_base_r, iter_logical_seg_base_r;
reg [PSUM_ADDR_W-1:0]            window_psum_base_r;
reg                                itr_rd_valid_r;
reg                                itr_cap_valid_r;
reg                                itr_dec_valid_r;
reg [IACT_DATA_PTR_W-1:0]          itr_rd_entry_abs_r;
reg [IACT_DATA_PTR_W-1:0]          itr_rd_entry_end_r;
reg                                itr_rd_first_r;
reg [IACT_DATA_PTR_W-1:0]          itr_rd_offset_base_r;
reg [IACT_DATA_PTR_W-1:0]          itr_rd_log_seg_r;
reg [PSUM_ADDR_W-1:0]              itr_rd_psum_base_r;
reg [IACT_DATA_W-1:0]              itr_cap_word_r;
reg [IACT_DATA_PTR_W-1:0]          itr_cap_entry_abs_r;
reg [IACT_DATA_PTR_W-1:0]          itr_cap_entry_end_r;
reg                                itr_cap_first_r;
reg [IACT_DATA_PTR_W-1:0]          itr_cap_offset_base_r;
reg [IACT_DATA_PTR_W-1:0]          itr_cap_log_seg_r;
reg [PSUM_ADDR_W-1:0]              itr_cap_psum_base_r;
reg signed [IACT_VALUE_W-1:0]      itr_dec_value_r;
reg [WEIGHT_COL_IDX_W-1:0]         itr_dec_weight_col_r;
reg [PSUM_ADDR_W-1:0]              itr_dec_psum_base_r;
reg [IACT_DATA_PTR_W-1:0]          itr_dec_offset_in_seg_r;
reg                                itr_dec_skip_r;
reg [IACT_DATA_PTR_W-1:0]          sliding_resp_retire_offp1_r;
// Sliding → MAC queue (hold beat until queue accepts)
reg                                sliding_resp_valid_r;
reg signed [IACT_VALUE_W-1:0]      sliding_resp_value_r;
reg [WEIGHT_COL_IDX_W-1:0]        sliding_resp_weight_col_r;
reg [PSUM_ADDR_W-1:0]              sliding_resp_psum_base_r;
wire      resident_window_ready_w;
wire [IACT_DATA_PTR_W-1:0] iter_entry_next_w = iter_entry_abs_r + {{(IACT_DATA_PTR_W-1){1'b0}}, 1'b1};
wire       iter_entry_is_last_w = (iter_entry_next_w == iter_entry_end_abs_r);
wire [4:0] current_window_size_w = ctrl_cfg_window_size_in;
wire [3:0] current_window_seg_count_w = ctrl_cfg_window_seg_count_in;
wire [4:0] current_segment_len_w      = ctrl_cfg_segment_len_in;

assign resident_window_ready_w =
    iact_address_stream_done_r &&
    iact_data_stream_done_r &&
    (ctrl_cfg_window_seg_count_in != 4'd0) &&
    !iter_active_r &&
    !sliding_resp_valid_r &&
    !itr_rd_valid_r &&
    !itr_cap_valid_r &&
    !itr_dec_valid_r &&
    (wm_state_r == ST_IDLE || wm_state_r == ST_DONE);

// -----------------------------------------------------------------------------
// Sliding prefetch: asserted when iterator scan for current window is finished but
// backend may still be draining queued MAC tasks — safe cycle to pulse slide_commit
// without corrupting resident metadata / iterators.
// -----------------------------------------------------------------------------
wire itr_pipe_empty_w;
assign itr_pipe_empty_w =
    !itr_rd_valid_r && !itr_cap_valid_r && !itr_dec_valid_r && !sliding_resp_valid_r;

assign slide_safe_w =
    (mode_r == MODE_RUN) &&
    iter_done_r &&
    !iter_active_r &&
    itr_pipe_empty_w &&
    (wm_state_r == ST_IDLE || wm_state_r == ST_DONE);

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
assign iact_iter_seg_begin_w = iact_spad_resident_rd_seg_begin_w;
assign iact_iter_seg_end_w   = iact_spad_resident_rd_seg_end_w;

// CSC decode from itr_cap_* (latched into itr_dec_* in ST_ITER_DECODE).
wire [IACT_VALUE_W-1:0]      itr_dec_val_w;
wire [IACT_COUNT_W-1:0]      itr_dec_cnt_w;
wire [IACT_DATA_PTR_W-1:0]   itr_dec_off_in_w;
wire [IACT_DATA_PTR_W-1:0]   itr_dec_log_col_w;
wire                         itr_dec_skip_w;
assign itr_dec_val_w   = itr_cap_word_r[IACT_DATA_W-1:IACT_COUNT_W];
assign itr_dec_cnt_w   = itr_cap_word_r[IACT_COUNT_W-1:0];
assign itr_dec_off_in_w =
    itr_cap_first_r ? itr_dec_cnt_w : (itr_cap_offset_base_r + itr_dec_cnt_w);
assign itr_dec_log_col_w = itr_cap_log_seg_r + itr_dec_off_in_w;
assign itr_dec_skip_w    = (itr_dec_log_col_w >= {{(IACT_DATA_PTR_W-5){1'b0}}, current_window_size_w});

// -----------------------------------------------------------------------------
// Drive resident Iact_* SPad ports from router + window manager.
// -----------------------------------------------------------------------------

// Payload valid matches router handshake (write_fire defined after iact_router_data_ready_out).
assign iact_data_resident_en_w            = 1'b1;
assign iact_data_resident_flush_w          = ctrl_cfg_iact_flush_in;
assign iact_data_resident_data_valid_w     = iact_payload_write_fire_w;
assign iact_data_resident_data_in_w        = iact_router_data_in;
assign iact_data_resident_data_last_w      = 1'b0;
assign iact_data_resident_seg_empty_w      = 1'b0;

assign iact_data_resident_free_update_valid_w = iact_slide_do_r;
assign iact_data_resident_free_abs_w      = iact_slide_capture_b1_r;
assign iact_data_resident_read_abs_idx_w = iter_entry_abs_r;

assign mac_start_ready_w =
    weight_addr_loaded_r && weight_data_loaded_r && resident_window_ready_w;

// -----------------------------------------------------------------------------
// Normalized task interface and 2-entry task queue
// -----------------------------------------------------------------------------
// Resident iterator → sliding_resp_* (pending iact beat) → frontend_task_* → weight/psum/MAC backend.
reg                              q0_valid_r, q1_valid_r;
reg signed [IACT_VALUE_W-1:0]    q0_value_r, q1_value_r;
reg [WEIGHT_COL_IDX_W-1:0]       q0_weight_col_r, q1_weight_col_r;
reg [PSUM_ADDR_W-1:0]            q0_psum_base_r, q1_psum_base_r;
wire                             queue_full_w;
wire                             queue_empty_w;
wire                             queue_pop_w;
wire                             frontend_task_valid_w;
wire                             frontend_task_ready_w;
wire signed [IACT_VALUE_W-1:0]   frontend_task_iact_value_w;
wire [WEIGHT_COL_IDX_W-1:0]      frontend_task_weight_col_w;
wire [PSUM_ADDR_W-1:0]           frontend_task_psum_base_w;
always @(posedge clk) begin
    if (rst) begin
        window_psum_base_r <= {PSUM_ADDR_W{1'b0}};
    end else begin
        if (mode_r == MODE_RUN && wm_state_r == ST_IDLE && sliding_iter_start_w)
            window_psum_base_r <= ctrl_cfg_psum_base_in;
    end
end

assign frontend_task_valid_w      = sliding_resp_valid_r;
assign frontend_task_iact_value_w  = sliding_resp_value_r;
assign frontend_task_weight_col_w  = sliding_resp_weight_col_r;
assign frontend_task_psum_base_w   = sliding_resp_psum_base_r;
assign frontend_task_ready_w       = !queue_full_w;

// -----------------------------------------------------------------------------
// S2 (weight-address stage) registers
// -----------------------------------------------------------------------------
reg                              s2_valid_r;
reg signed [IACT_VALUE_W-1:0]    s2_iact_value_r;
reg [WEIGHT_COL_IDX_W-1:0]       s2_weight_col_r;
reg [PSUM_ADDR_W-1:0]            s2_psum_base_r;

assign weight_address_rd_col_idx_w = s2_weight_col_r;

// -----------------------------------------------------------------------------
// active task and overlapped weight/MAC/writeback pipeline
// -----------------------------------------------------------------------------
reg                              active_task_valid_r;
reg signed [IACT_VALUE_W-1:0]    active_iact_value_r;
reg [WEIGHT_COL_IDX_W-1:0]       active_weight_col_r;
reg [PSUM_ADDR_W-1:0]            active_psum_base_r;
reg [WEIGHT_WORD_PTR_W-1:0]      weight_word_ptr_r;
reg [WEIGHT_WORD_PTR_W-1:0]      weight_word_end_r;
reg [PSUM_ADDR_W-1:0]            weight_row_base_r;
reg                              weight_first_word_r;
reg                              weight_issue_done_r;
reg                              s3_pending_r;
reg                              s3_delay_r;    
reg signed [IACT_VALUE_W-1:0]    s3_iact_value_r;
reg [WEIGHT_COL_IDX_W-1:0]       s3_weight_col_r;
reg [PSUM_ADDR_W-1:0]            s3_psum_base_r;
reg [PSUM_ADDR_W-1:0]            s3_weight_row_base_r;
reg                              s3_weight_first_word_r;
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
reg signed [PSUM_W-1:0]          s5_product0_r;
reg signed [PSUM_W-1:0]          s5_product1_r;
reg                              s5_last_weight_word_r;

// -----------------------------------------------------------------------------
// Local psum accumulator (WEIGHT_MATRIX_ROW entries per MAC base)
// -----------------------------------------------------------------------------
localparam integer ACC_ROW_IDX_W   = (WEIGHT_MATRIX_ROW <= 1) ? 1 : $clog2(WEIGHT_MATRIX_ROW);
localparam integer ACC_M0_W        = (WEIGHT_MATRIX_ROW <= 1) ? 1 : $clog2(WEIGHT_MATRIX_ROW + 1);
localparam integer ACC_PRELOAD_PAIRS_MAX = (WEIGHT_MATRIX_ROW + 1) / 2;
localparam integer ACC_PRELOAD_IDX_W =
    (ACC_PRELOAD_PAIRS_MAX <= 1) ? 1 : $clog2(ACC_PRELOAD_PAIRS_MAX + 1);

function automatic [ACC_ROW_IDX_W-1:0] lowest_dirty_row(input [WEIGHT_MATRIX_ROW-1:0] mask);
    integer k;
    reg found;
    begin
        lowest_dirty_row = {ACC_ROW_IDX_W{1'b0}};
        found = 0;
        for (k = 0; k < WEIGHT_MATRIX_ROW; k = k + 1)
            if (!found && mask[k]) begin
                lowest_dirty_row = k[ACC_ROW_IDX_W-1:0];
                found = 1;
            end
    end
endfunction

function automatic [ACC_M0_W:0] acc_dirty_popcount_fn(input [WEIGHT_MATRIX_ROW-1:0] mask);
    integer k;
    begin
        acc_dirty_popcount_fn = {(ACC_M0_W + 1){1'b0}};
        for (k = 0; k < WEIGHT_MATRIX_ROW; k = k + 1)
            acc_dirty_popcount_fn = acc_dirty_popcount_fn + {{ACC_M0_W{1'b0}}, mask[k]};
    end
endfunction

localparam [2:0] ACC_IDLE     = 3'd0;
localparam [2:0] ACC_PRELOAD  = 3'd1;
localparam [2:0] ACC_COMPUTE  = 3'd2;

reg [2:0]                        acc_phase_r;
reg [PSUM_ADDR_W-1:0]            acc_base_r;
reg signed [PSUM_W-1:0]          acc_r [0:WEIGHT_MATRIX_ROW-1];
reg [WEIGHT_MATRIX_ROW-1:0]      acc_dirty_r;
reg                              acc_ready_r;
reg                              acc_flush_done_r;
reg                              run_drained_latched_r;
reg [ACC_PRELOAD_IDX_W-1:0]        acc_preload_pair_r;
reg                              acc_post_compute_flush_r;
reg [ACC_M0_W-1:0]               acc_m0_r;
// Always honor runtime M0 (ctrl_cfg_m0_in); do not require +define+PE_ACC_USE_M0_PORT on RTL compile.
wire [ACC_M0_W-1:0]                acc_m0_cfg_w = ctrl_cfg_m0_in[ACC_M0_W-1:0];
wire [ACC_ROW_IDX_W-1:0]           acc_preload_row0_w = {acc_preload_pair_r, 1'b0};
wire [ACC_ROW_IDX_W-1:0]           acc_preload_row1_w =
    acc_preload_row0_w + {{(ACC_ROW_IDX_W - 1){1'b0}}, 1'b1};
wire                               acc_preload_row1_valid_w =
    ({1'b0, acc_preload_row1_w} < WEIGHT_MATRIX_ROW);
wire [ACC_ROW_IDX_W:0]             acc_preload_rows_done_w =
    {1'b0, acc_preload_row1_valid_w ? acc_preload_row1_w : acc_preload_row0_w} + 1'b1;
wire                               acc_m0_cfg_legal_w =
    (acc_m0_cfg_w >= {{(ACC_M0_W - 1){1'b0}}, 1'b1}) &&
    ($unsigned(acc_m0_cfg_w) <= WEIGHT_MATRIX_ROW);
wire                               acc_psum_cfg_legal_w =
    (ctrl_cfg_psum_base_in + acc_m0_cfg_w[PSUM_ADDR_W-1:0] <= PSUM_SPAD_DEPTH);
wire                               mac_cfg_legal_w = acc_m0_cfg_legal_w && acc_psum_cfg_legal_w;
// Flush beat: write up to two lowest dirty rows per cycle (independent 2W ports).
wire [ACC_ROW_IDX_W-1:0]         acc_flush_a_w;
wire [ACC_ROW_IDX_W-1:0]         acc_flush_b_w;
wire                             acc_flush_b_valid_w;
wire [WEIGHT_MATRIX_ROW-1:0]     acc_dirty_after_ab_w;
wire                             acc_flush_beat_done_w;

// Iterator starts only after accumulator preload completes.
wire                             sliding_iter_start_eff_w;
assign sliding_iter_start_eff_w = sliding_iter_start_w && acc_ready_r;

wire [WEIGHT_MATRIX_ROW:0]         acc_m0_shift_w =
    {{(WEIGHT_MATRIX_ROW - ACC_M0_W){1'b0}}, 1'b1} << acc_m0_r;
wire [WEIGHT_MATRIX_ROW-1:0]       acc_m0_active_mask_w =
    (acc_m0_shift_w > {WEIGHT_MATRIX_ROW{1'b0}}) ?
    (acc_m0_shift_w[WEIGHT_MATRIX_ROW-1:0] - 1'b1) : {WEIGHT_MATRIX_ROW{1'b0}};
wire [WEIGHT_MATRIX_ROW-1:0]       acc_dirty_active_w = acc_dirty_r & acc_m0_active_mask_w;

assign acc_flush_a_w = lowest_dirty_row(acc_dirty_active_w);

wire [WEIGHT_MATRIX_ROW-1:0]       acc_dirty_after_a_w;

assign acc_dirty_after_a_w =
    acc_dirty_r & ~({{(WEIGHT_MATRIX_ROW - 1){1'b0}}, 1'b1} << acc_flush_a_w);

assign acc_flush_b_valid_w = |acc_dirty_active_w & ~({{(WEIGHT_MATRIX_ROW - 1){1'b0}}, 1'b1} << acc_flush_a_w);

assign acc_flush_b_w = lowest_dirty_row(acc_dirty_active_w & ~({{(WEIGHT_MATRIX_ROW - 1){1'b0}}, 1'b1} << acc_flush_a_w));

assign acc_dirty_after_ab_w =
    acc_dirty_after_a_w & ~({{(WEIGHT_MATRIX_ROW - 1){1'b0}}, 1'b1} << acc_flush_b_w);

assign acc_flush_beat_done_w = ~|acc_dirty_after_ab_w;

wire                             issue_weight_word_w;
wire [PSUM_ADDR_W-1:0]           s4_weight_row0_calc_w;
wire [PSUM_ADDR_W-1:0]           s4_weight_base_after_lane0_w;
wire [PSUM_ADDR_W-1:0]           s4_weight_row1_calc_w;
wire [PSUM_ADDR_W-1:0]           s4_weight_next_base_w;
wire [PSUM_ADDR_W-1:0]           s4_psum_addr0_w;
wire [PSUM_ADDR_W-1:0]           s4_psum_addr1_w;
wire                             s4_last_weight_word_w;
wire signed [PSUM_W-1:0]         s5_product0_w;
wire signed [PSUM_W-1:0]         s5_product1_w;
wire                             frontend_done_w;
wire                             backend_pipe_empty_w;
wire                             run_compute_done_w;
wire                             acc_mac_complete_w;
wire                             acc_flush_hold_w;
wire                             acc_mac_idle_w;
wire                             acc_bypass_spad_rmw_w;
wire [ACC_ROW_IDX_W-1:0]         s5_local_row0_w;
wire [ACC_ROW_IDX_W-1:0]         s5_local_row1_w;
wire                             allow_active_start_acc_w;
wire                             allow_active_start_w;

wire [WEIGHT_WORD_PTR_W-1:0] weight_issue_ptr_plus1_w;
wire                         issue_this_is_last_w;
wire [PSUM_ADDR_W-1:0]       issue_row_base_w;
wire                         issue_first_word_w;
wire                         weight_addr_load_accept_w;
wire                         weight_data_load_accept_w;

assign weight_issue_ptr_plus1_w = weight_word_ptr_r + {{(WEIGHT_WORD_PTR_W-1){1'b0}},1'b1};
assign issue_this_is_last_w     = (weight_issue_ptr_plus1_w >= weight_word_end_r);
assign issue_row_base_w   = s3_pending_r ? s4_weight_next_base_w : weight_row_base_r;
assign issue_first_word_w = s3_pending_r ? 1'b0                  : weight_first_word_r;
assign weight_router_addr_ready_out = cluster_ctrl_load_en_in &&
                                       weight_address_spad_data_in_ready_w;
assign weight_router_data_ready_out = cluster_ctrl_load_en_in &&
                                       weight_data_spad_data_in_ready_w;
assign weight_addr_load_accept_w = weight_router_addr_valid_in &&
                                   weight_router_addr_ready_out;
assign weight_data_load_accept_w = weight_router_data_valid_in &&
                                   weight_router_data_ready_out;

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
    !s3_delay_r && !s3_pending_r && acc_ready_r && !acc_flush_hold_w;

// Overlap: promote next S2 task after last weight issue, without waiting for prior S4/S5 drain.
assign allow_active_start_acc_w =
    acc_bypass_spad_rmw_w &&
    !acc_flush_hold_w &&
    s2_valid_r &&
    !s3_delay_r &&
    !s3_pending_r &&
    (!active_task_valid_r || weight_issue_done_r);

assign allow_active_start_w =
    allow_active_start_acc_w ||
    ((acc_phase_r == ACC_COMPUTE) && !acc_flush_hold_w &&
     s2_valid_r && !active_task_valid_r && !s3_delay_r && !s3_pending_r &&
     !s4_valid_r && !s5_valid_r);

assign s4_weight_row0_calc_w = s3_weight_first_word_r ?
                               {{(PSUM_ADDR_W-WEIGHT_COUNT_W){1'b0}}, weight_lane0_count_w} :
                               (s3_weight_row_base_r + {{(PSUM_ADDR_W-WEIGHT_COUNT_W){1'b0}}, weight_lane0_count_w});
assign s4_weight_base_after_lane0_w = s4_weight_row0_calc_w + {{(PSUM_ADDR_W-1){1'b0}},1'b1};
assign s4_weight_row1_calc_w = s4_weight_base_after_lane0_w + {{(PSUM_ADDR_W-WEIGHT_COUNT_W){1'b0}}, weight_lane1_count_w}; //Note
assign s4_weight_next_base_w = weight_lane1_valid_w ?
                               (s4_weight_row1_calc_w + {{(PSUM_ADDR_W-1){1'b0}},1'b1}) :
                               s4_weight_base_after_lane0_w;
assign s4_psum_addr0_w       = s3_psum_base_r + s4_weight_row0_calc_w;
assign s4_psum_addr1_w       = s3_psum_base_r + s4_weight_row1_calc_w;
assign s4_last_weight_word_w = ((s3_weight_word_ptr_r + {{(WEIGHT_WORD_PTR_W-1){1'b0}},1'b1}) >= s3_weight_word_end_r);
assign s5_product0_w         = s4_lane0_valid_r ? ($signed(s4_weight_value0_r) * $signed(s4_iact_value_r)) : $signed({PSUM_W{1'b0}});
assign s5_product1_w         = s4_lane1_valid_r ? ($signed(s4_weight_value1_r) * $signed(s4_iact_value_r)) : $signed({PSUM_W{1'b0}});

assign acc_bypass_spad_rmw_w = (mode_r == MODE_RUN) && (acc_phase_r == ACC_COMPUTE);
wire [PSUM_ADDR_W-1:0]           s5_row_off0_full_w = s5_psum_addr0_r - acc_base_r;
wire [PSUM_ADDR_W-1:0]           s5_row_off1_full_w = s5_psum_addr1_r - acc_base_r;
assign s5_local_row0_w           = s5_row_off0_full_w[ACC_ROW_IDX_W-1:0];
assign s5_local_row1_w           = s5_row_off1_full_w[ACC_ROW_IDX_W-1:0];
wire                               s5_lane0_acc_en_w =
    s5_lane0_valid_r && (s5_psum_addr0_r >= acc_base_r) &&
    (s5_row_off0_full_w < acc_m0_r) && (s5_row_off0_full_w < WEIGHT_MATRIX_ROW);
wire                               s5_lane1_acc_en_w =
    s5_lane1_valid_r && (s5_psum_addr1_r >= acc_base_r) &&
    (s5_row_off1_full_w < acc_m0_r) && (s5_row_off1_full_w < WEIGHT_MATRIX_ROW);
// Flush beats run in ACC_COMPUTE (post-MAC drain); backend is empty when run_compute_done asserts.
wire                               acc_flush_beat_w =
    (acc_phase_r == ACC_COMPUTE) &&
    (run_compute_done_w || acc_post_compute_flush_r) &&
    |acc_dirty_active_w;
// Accumulator MAC: drain through S5 only (no S6 writeback stage).
assign backend_pipe_empty_w  =
    !s2_valid_r && !active_task_valid_r && !s3_delay_r && !s3_pending_r &&
    !s4_valid_r && !s5_valid_r;
assign backend_drained_post_mac_w =
    !s2_valid_r && !s3_delay_r && !s3_pending_r && !s4_valid_r && !s5_valid_r;
assign slide_safe_post_mac_w =
    (mode_r == MODE_IDLE) &&
    run_drained_latched_r &&
    iter_done_r &&
    !iter_active_r &&
    itr_pipe_empty_w &&
    backend_drained_post_mac_w;
assign slide_commit_arm_w = slide_safe_w || slide_safe_post_mac_w;
assign ctrl_status_slide_safe_out = slide_commit_arm_w;

assign run_compute_done_w    = frontend_done_w && queue_empty_w && backend_pipe_empty_w;
assign acc_flush_hold_w      = acc_post_compute_flush_r || (run_compute_done_w && |acc_dirty_r);
assign acc_mac_complete_w    = run_compute_done_w && acc_flush_done_r;
assign acc_mac_idle_w        = (acc_phase_r == ACC_IDLE) || acc_flush_done_r;
// Sliding frontend done: iterator has completed the configured window scan and no
// pending response beat remains to be enqueued. Do not require wm_state_r==ST_DONE
// because the FSM returns to ST_IDLE once start deasserts.
assign frontend_done_w =
    iter_done_r && (wm_state_r == ST_IDLE) && itr_pipe_empty_w;

assign queue_pop_w   = (mode_r == MODE_RUN) && !s2_valid_r && q0_valid_r;
assign psum_out_w      = (mode_r == MODE_MERGE) ? ($signed(psum_spad_rd_data0_w) + $signed(psum_router_data_in)) : $signed({PSUM_W{1'b0}});
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
        if (!cluster_ctrl_load_en_in) begin
            weight_addr_load_seen_r <= 1'b0;
            weight_data_load_seen_r <= 1'b0;
        end
        if (weight_addr_load_accept_w && !weight_addr_load_seen_r)
            weight_addr_load_seen_r <= 1'b1;
        if (weight_data_load_accept_w && !weight_data_load_seen_r)
            weight_data_load_seen_r <= 1'b1;
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
        pool_max_r               <= {IACT_VALUE_W{1'b0}};
        pool_out_valid_r         <= 1'b0;
        pool_out_r               <= {IACT_VALUE_W{1'b0}};
        weight_data_read_en_r       <= 1'b0;
        weight_data_read_word_idx_r <= {WEIGHT_WORD_PTR_W{1'b0}};

        //add signal fix merge
        merge_req_pending_r     <= 1'b0;

        mac_req_pending_r <= 1'b0;
        weight_addr_loaded_r <= 1'b0;
        weight_data_loaded_r <= 1'b0;
        weight_addr_load_seen_r <= 1'b0;
        weight_data_load_seen_r <= 1'b0;

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
        psum_out_r <= {PSUM_W{1'b0}};
        psum_in_valid_r <= 1'b0;

        q0_valid_r               <= 1'b0;
        q1_valid_r               <= 1'b0;
        q0_value_r               <= {IACT_VALUE_W{1'b0}};
        q1_value_r               <= {IACT_VALUE_W{1'b0}};
        q0_weight_col_r          <= {WEIGHT_COL_IDX_W{1'b0}};
        q1_weight_col_r          <= {WEIGHT_COL_IDX_W{1'b0}};
        q0_psum_base_r           <= {PSUM_ADDR_W{1'b0}};
        q1_psum_base_r           <= {PSUM_ADDR_W{1'b0}};

        s2_valid_r               <= 1'b0;
        s2_iact_value_r          <= {IACT_VALUE_W{1'b0}};
        s2_weight_col_r          <= {WEIGHT_COL_IDX_W{1'b0}};
        s2_psum_base_r           <= {PSUM_ADDR_W{1'b0}};

        active_task_valid_r      <= 1'b0;
        active_iact_value_r      <= {IACT_VALUE_W{1'b0}};
        active_weight_col_r      <= {WEIGHT_COL_IDX_W{1'b0}};
        active_psum_base_r       <= {PSUM_ADDR_W{1'b0}};
        weight_word_ptr_r        <= {WEIGHT_WORD_PTR_W{1'b0}};
        weight_word_end_r        <= {WEIGHT_WORD_PTR_W{1'b0}};
        weight_row_base_r        <= {PSUM_ADDR_W{1'b0}};
        weight_first_word_r      <= 1'b1;
        weight_issue_done_r      <= 1'b0;

        s3_pending_r             <= 1'b0;
        s3_delay_r               <= 1'b0;
        s3_iact_value_r          <= {IACT_VALUE_W{1'b0}};
        s3_weight_col_r          <= {WEIGHT_COL_IDX_W{1'b0}};
        s3_psum_base_r           <= {PSUM_ADDR_W{1'b0}};
        s3_weight_row_base_r     <= {PSUM_ADDR_W{1'b0}};
        s3_weight_first_word_r   <= 1'b1;
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
        s5_product0_r            <= {PSUM_W{1'b0}};
        s5_product1_r            <= {PSUM_W{1'b0}};
        s5_last_weight_word_r    <= 1'b0;

        acc_phase_r            <= ACC_IDLE;
        acc_base_r             <= {PSUM_ADDR_W{1'b0}};
        acc_dirty_r            <= {WEIGHT_MATRIX_ROW{1'b0}};
        acc_ready_r            <= 1'b0;
        acc_flush_done_r       <= 1'b0;
        run_drained_latched_r  <= 1'b0;
        acc_preload_pair_r         <= {ACC_PRELOAD_IDX_W{1'b0}};
        acc_post_compute_flush_r   <= 1'b0;
        acc_m0_r                   <= {ACC_M0_W{1'b0}};

        sliding_resp_valid_r     <= 1'b0;
        sliding_resp_value_r     <= {IACT_VALUE_W{1'b0}};
        sliding_resp_weight_col_r <= {WEIGHT_COL_IDX_W{1'b0}};
        sliding_resp_psum_base_r <= {PSUM_ADDR_W{1'b0}};
        sliding_resp_retire_offp1_r <= {IACT_DATA_PTR_W{1'b0}};
        itr_rd_valid_r           <= 1'b0;
        itr_cap_valid_r          <= 1'b0;
        itr_dec_valid_r          <= 1'b0;
        itr_rd_entry_abs_r       <= {IACT_DATA_PTR_W{1'b0}};
        itr_rd_entry_end_r       <= {IACT_DATA_PTR_W{1'b0}};
        itr_rd_first_r           <= 1'b1;
        itr_rd_offset_base_r     <= {IACT_DATA_PTR_W{1'b0}};
        itr_rd_log_seg_r         <= {IACT_DATA_PTR_W{1'b0}};
        itr_rd_psum_base_r       <= {PSUM_ADDR_W{1'b0}};
        itr_cap_word_r           <= {IACT_DATA_W{1'b0}};
        itr_cap_entry_abs_r      <= {IACT_DATA_PTR_W{1'b0}};
        itr_cap_entry_end_r      <= {IACT_DATA_PTR_W{1'b0}};
        itr_cap_first_r          <= 1'b1;
        itr_cap_offset_base_r    <= {IACT_DATA_PTR_W{1'b0}};
        itr_cap_log_seg_r        <= {IACT_DATA_PTR_W{1'b0}};
        itr_cap_psum_base_r      <= {PSUM_ADDR_W{1'b0}};
        itr_dec_value_r          <= {IACT_VALUE_W{1'b0}};
        itr_dec_weight_col_r     <= {WEIGHT_COL_IDX_W{1'b0}};
        itr_dec_psum_base_r      <= {PSUM_ADDR_W{1'b0}};
        itr_dec_offset_in_seg_r  <= {IACT_DATA_PTR_W{1'b0}};
        itr_dec_skip_r           <= 1'b0;
        wm_state_r               <= ST_IDLE;
        iter_active_r            <= 1'b0;
        iter_done_r              <= 1'b0;
        iter_seg_rel_r           <= {IACT_SEG_IDX_W{1'b0}};
        iter_phys_seg_r          <= {SEG_PTR_W{1'b0}};
        iter_entry_abs_r         <= {IACT_DATA_PTR_W{1'b0}};
        iter_entry_end_abs_r     <= {IACT_DATA_PTR_W{1'b0}};
        iter_first_entry_r       <= 1'b1;
        iter_offset_base_r       <= {IACT_DATA_PTR_W{1'b0}};
        iter_logical_seg_base_r  <= {IACT_DATA_PTR_W{1'b0}};
    end else begin

        if (mac_start_w && (mode_r == MODE_IDLE))
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
            s4_valid_r             <= 1'b0;
            s5_valid_r             <= 1'b0;
            iter_active_r          <= 1'b0;
            iter_done_r            <= 1'b0;
            iter_seg_rel_r         <= {IACT_SEG_IDX_W{1'b0}};
            iter_phys_seg_r        <= {SEG_PTR_W{1'b0}};
            iter_entry_abs_r       <= {IACT_DATA_PTR_W{1'b0}};
            iter_entry_end_abs_r   <= {IACT_DATA_PTR_W{1'b0}};
            iter_first_entry_r     <= 1'b1;
            iter_offset_base_r     <= {IACT_DATA_PTR_W{1'b0}};
            iter_logical_seg_base_r<= {IACT_DATA_PTR_W{1'b0}};
        wm_state_r             <= ST_IDLE;
            sliding_resp_valid_r   <= 1'b0;
            sliding_resp_retire_offp1_r <= {IACT_DATA_PTR_W{1'b0}};
            itr_rd_valid_r         <= 1'b0;
            itr_cap_valid_r        <= 1'b0;
            itr_dec_valid_r        <= 1'b0;
            window_psum_base_r       <= {PSUM_ADDR_W{1'b0}};
        end

        // Pool compare datapath (no MAC / weight / psum use)
        if (mode_r == MODE_POOL) begin
            if (pool_xfer_w && pool_router_win_last_in) begin
                pool_out_r       <= pool_next_max_w;
                pool_out_valid_r <= 1'b1;
            end else if (pool_out_valid_r && pool_router_out_ready_in) begin
                pool_out_valid_r <= 1'b0;
            end
            if (pool_xfer_w)
                pool_max_r <= pool_next_max_w;
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
        psum_out_r             <= psum_out_w;
        psum_in_valid_r       <= psum_router_valid_in;

        if (ctrl_cfg_psum_spad_clear_in) begin
            acc_phase_r        <= ACC_IDLE;
            acc_ready_r        <= 1'b0;
            acc_flush_done_r   <= 1'b0;
            acc_dirty_r        <= {WEIGHT_MATRIX_ROW{1'b0}};
            acc_preload_pair_r       <= {ACC_PRELOAD_IDX_W{1'b0}};
            acc_post_compute_flush_r <= 1'b0;
            acc_m0_r                 <= {ACC_M0_W{1'b0}};
        end

        // Accumulator preload / flush (owns Psum_Spad ports during these phases)
        if ((mode_r == MODE_RUN) && !ctrl_cfg_psum_spad_clear_in) begin
            case (acc_phase_r)
                // Preload: ceil(M0/2) beats, two SPAD rows per beat (async read).
                ACC_PRELOAD: begin
                    psum_rd_en0_r <= 1'b1;
                    psum_rd_en1_r <= 1'b1;
                    psum_rd_addr0_r <= acc_base_r + {{(PSUM_ADDR_W - ACC_ROW_IDX_W){1'b0}}, acc_preload_row0_w};
                    psum_rd_addr1_r <= acc_base_r + {{(PSUM_ADDR_W - ACC_ROW_IDX_W){1'b0}}, acc_preload_row1_w};
                    acc_r[acc_preload_row0_w] <= psum_spad_rd_data0_w;
                    if (acc_preload_row1_valid_w)
                        acc_r[acc_preload_row1_w] <= psum_spad_rd_data1_w;
                    if (acc_preload_rows_done_w >= {1'b0, acc_m0_cfg_w}) begin
                        acc_dirty_r        <= {WEIGHT_MATRIX_ROW{1'b0}};
                        acc_ready_r        <= 1'b1;
                        acc_phase_r        <= ACC_COMPUTE;
                        acc_preload_pair_r <= {ACC_PRELOAD_IDX_W{1'b0}};
                    end else begin
                        acc_preload_pair_r <= acc_preload_pair_r + 1'b1;
                    end
                end
                ACC_COMPUTE: begin
                    if (run_compute_done_w) begin
                        acc_ready_r <= 1'b0;
                        if (|acc_dirty_r) begin
                            acc_post_compute_flush_r <= ~acc_flush_beat_done_w;
                            acc_flush_done_r         <= acc_flush_beat_done_w;
                        end else begin
                            acc_post_compute_flush_r <= 1'b0;
                            acc_flush_done_r         <= 1'b1;
                        end
                    end else if (acc_post_compute_flush_r) begin
                        acc_post_compute_flush_r <= ~(acc_flush_beat_done_w || ~|acc_dirty_r);
                        if (acc_flush_beat_done_w || ~|acc_dirty_r)
                            acc_flush_done_r <= 1'b1;
                    end
                end
                default: begin
                end
            endcase

            // Flush beat(s): up to 2 dirty rows per cycle; first beat may overlap MAC-complete cycle.
            if (acc_flush_beat_w && |acc_dirty_active_w) begin
                psum_wr_en0_r   <= 1'b1;
                psum_wr_addr0_r <= acc_base_r + {{(PSUM_ADDR_W-ACC_ROW_IDX_W){1'b0}}, acc_flush_a_w};
                psum_wr_data0_r <= acc_r[acc_flush_a_w];
                acc_dirty_r[acc_flush_a_w] <= 1'b0;
                if (acc_flush_b_valid_w) begin
                    psum_wr_en1_r   <= 1'b1;
                    psum_wr_addr1_r <= acc_base_r + {{(PSUM_ADDR_W-ACC_ROW_IDX_W){1'b0}}, acc_flush_b_w};
                    psum_wr_data1_r <= acc_r[acc_flush_b_w];
                    acc_dirty_r[acc_flush_b_w] <= 1'b0;
                end
            end
        end

        // S4 -> S5 (product latch; accumulator update at S5, no per-product SPAD RMW)
        s5_valid_r <= s4_valid_r && !acc_flush_hold_w;
        if (s4_valid_r) begin
            s5_lane0_valid_r      <= s4_lane0_valid_r;
            s5_lane1_valid_r      <= s4_lane1_valid_r;
            s5_psum_addr0_r       <= s4_psum_addr0_r;
            s5_psum_addr1_r       <= s4_psum_addr1_r;
            s5_product0_r         <= s5_product0_w;
            s5_product1_r         <= s5_product1_w;
            s5_last_weight_word_r <= s4_last_weight_word_r;
        end else begin
            s5_lane0_valid_r      <= 1'b0;
            s5_lane1_valid_r      <= 1'b0;
            s5_last_weight_word_r <= 1'b0;
        end

        // returned weight word -> S4 and update next issue state
        s4_valid_r <= s3_pending_r && !acc_flush_hold_w;
        if (s3_pending_r) begin
            s4_lane0_valid_r          <= weight_lane0_valid_w;
            s4_lane1_valid_r          <= weight_lane1_valid_w;
            s4_iact_value_r           <= s3_iact_value_r;
            s4_weight_value0_r        <= weight_lane0_value_w;
            s4_weight_value1_r        <= weight_lane1_value_w;
            s4_psum_addr0_r           <= s4_psum_addr0_w;
            s4_psum_addr1_r           <= s4_psum_addr1_w;
            s4_last_weight_word_r     <= s4_last_weight_word_w;

            if (!s4_last_weight_word_w) begin
                weight_row_base_r   <= s4_weight_next_base_w;
                weight_first_word_r <= 1'b0;
            end
        end
        s3_pending_r <= 1'b0;

        // Latch a merge request so a one-cycle pulse from the testbench is enough.
        if (cluster_ctrl_psum_enq_en_in)
            merge_req_pending_r <= 1'b1;

        case (mode_r)
            MODE_IDLE: begin
                // start requirements: at least two address entries in address_spad and one data entry in data_spad
                if (merge_req_pending_r && acc_mac_idle_w) begin
                    mode_r <= MODE_MERGE;
                    merge_idx_r <= {PSUM_ADDR_W{1'b0}};
                    merge_req_pending_r <= 1'b0;
                    // Prefetch address 0 so first merge beat sees valid local psum data.
                    psum_rd_en0_r <= 1'b1;
                    psum_rd_addr0_r <= {PSUM_ADDR_W{1'b0}};
                end else if (mac_req_pending_r && mac_start_ready_w) begin
                    if (mac_cfg_legal_w) begin
                    mode_r                   <= MODE_RUN;
                    mac_req_pending_r <= 1'b0;
                    wm_state_r          <= ST_IDLE;
                    // Each MAC invocation: allow resident iterator to run again; drop stale task beat.
                    iter_done_r                <= 1'b0;
                    iter_active_r              <= 1'b0;
                    sliding_resp_valid_r       <= 1'b0;
                    sliding_resp_retire_offp1_r <= {IACT_DATA_PTR_W{1'b0}};
                    itr_rd_valid_r             <= 1'b0;
                    itr_cap_valid_r            <= 1'b0;
                    itr_dec_valid_r            <= 1'b0;
                    iter_seg_rel_r             <= {IACT_SEG_IDX_W{1'b0}};
                    iter_phys_seg_r            <= {SEG_PTR_W{1'b0}};
                    iter_entry_abs_r           <= {IACT_DATA_PTR_W{1'b0}};
                    iter_entry_end_abs_r       <= {IACT_DATA_PTR_W{1'b0}};
                    iter_first_entry_r         <= 1'b1;
                    iter_offset_base_r         <= {IACT_DATA_PTR_W{1'b0}};
                    iter_logical_seg_base_r    <= {IACT_DATA_PTR_W{1'b0}};
                    window_psum_base_r         <= ctrl_cfg_psum_base_in;
                    acc_base_r                 <= ctrl_cfg_psum_base_in;
                    acc_phase_r                <= ACC_PRELOAD;
                    acc_ready_r                <= 1'b0;
                    acc_flush_done_r           <= 1'b0;
                    run_drained_latched_r      <= 1'b0;
                    acc_preload_pair_r         <= {ACC_PRELOAD_IDX_W{1'b0}};
                    acc_post_compute_flush_r   <= 1'b0;
                    acc_dirty_r                <= {WEIGHT_MATRIX_ROW{1'b0}};
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
                end else if (cluster_ctrl_pool_cmp_en_in) begin
                    mode_r           <= MODE_POOL;
                    pool_max_r       <= {IACT_VALUE_W{1'b0}};
                    pool_out_valid_r <= 1'b0;
                end
            end

            MODE_RUN: begin
                // -----------------------------------------------------------------
                // Resident window manager: Address/Data SPads + iterator → sliding_resp_* pending beat.
                // -----------------------------------------------------------------
                    case (wm_state_r)
                        ST_IDLE: begin
                            if (sliding_iter_start_eff_w) begin
                                iter_active_r <= 1'b1;
                                iter_done_r <= 1'b0;
                                wm_state_r <= ST_ITER_INIT;
                            end
                        end
                        ST_ITER_INIT: begin
                            iter_seg_rel_r <= {IACT_SEG_IDX_W{1'b0}};
                            iter_phys_seg_r <= {SEG_PTR_W{1'b0}};
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
                                iter_first_entry_r <= 1'b1;
                                iter_offset_base_r <= {IACT_DATA_PTR_W{1'b0}};
                                itr_rd_entry_abs_r <= iact_iter_seg_begin_w;
                                itr_rd_entry_end_r <= iact_iter_seg_end_w;
                                itr_rd_first_r <= 1'b1;
                                itr_rd_offset_base_r <= {IACT_DATA_PTR_W{1'b0}};
                                itr_rd_log_seg_r <= iter_logical_seg_base_r;
                                itr_rd_psum_base_r <= window_psum_base_r;
                                itr_rd_valid_r <= 1'b1;
                                wm_state_r <= ST_ITER_PAYLOAD_WAIT;
                            end
                        end
                        ST_ITER_PAYLOAD_WAIT: begin
                            // Registered Data SPad: address (iter_entry_abs_r) held; data valid next cycle.
                            wm_state_r <= ST_ITER_PAYLOAD_CAPTURE;
                        end
                        ST_ITER_PAYLOAD_CAPTURE: begin
                            itr_cap_word_r <= iact_data_resident_data_out_w;
                            itr_cap_entry_abs_r <= itr_rd_entry_abs_r;
                            itr_cap_entry_end_r <= itr_rd_entry_end_r;
                            itr_cap_first_r <= itr_rd_first_r;
                            itr_cap_offset_base_r <= itr_rd_offset_base_r;
                            itr_cap_log_seg_r <= itr_rd_log_seg_r;
                            itr_cap_psum_base_r <= itr_rd_psum_base_r;
                            itr_rd_valid_r <= 1'b0;
                            itr_cap_valid_r <= 1'b1;
                            wm_state_r <= ST_ITER_DECODE;
                        end
                        ST_ITER_DECODE: begin
                            itr_dec_value_r <= itr_dec_val_w;
                            itr_dec_weight_col_r <= itr_dec_log_col_w[WEIGHT_COL_IDX_W-1:0];
                            itr_dec_psum_base_r <= itr_cap_psum_base_r;
                            itr_dec_offset_in_seg_r <= itr_dec_off_in_w;
                            itr_dec_skip_r <= itr_dec_skip_w;
                            itr_cap_valid_r <= 1'b0;
                            itr_dec_valid_r <= 1'b1;
                            wm_state_r <= ST_ITER_ENTRY;
                        end
                        ST_ITER_ENTRY: begin
                            if (sliding_resp_valid_r) begin
                                if (frontend_task_ready_w) begin
                                    sliding_resp_valid_r <= 1'b0;
                                    iter_offset_base_r <= sliding_resp_retire_offp1_r;
                                    iter_first_entry_r <= 1'b0;
                                    iter_entry_abs_r <= iter_entry_next_w;
                                    if (iter_entry_is_last_w) begin
                                        wm_state_r <= ST_NEXT_SEG;
                                    end else begin
                                        wm_state_r <= ST_ITER_PAYLOAD_WAIT;
                                        itr_rd_entry_abs_r <= iter_entry_next_w;
                                        itr_rd_entry_end_r <= iter_entry_end_abs_r;
                                        itr_rd_first_r <= 1'b0;
                                        itr_rd_offset_base_r <= sliding_resp_retire_offp1_r;
                                        itr_rd_log_seg_r <= iter_logical_seg_base_r;
                                        itr_rd_psum_base_r <= window_psum_base_r;
                                        itr_rd_valid_r <= 1'b1;
                                    end
                                end
                            end else if (itr_dec_valid_r && itr_dec_skip_r) begin
                                iter_offset_base_r <= itr_dec_offset_in_seg_r + {{(IACT_DATA_PTR_W-1){1'b0}}, 1'b1};
                                iter_first_entry_r <= 1'b0;
                                iter_entry_abs_r <= iter_entry_next_w;
                                itr_dec_valid_r <= 1'b0;
                                if (iter_entry_is_last_w) begin
                                    wm_state_r <= ST_NEXT_SEG;
                                end else begin
                                    wm_state_r <= ST_ITER_PAYLOAD_WAIT;
                                    itr_rd_entry_abs_r <= iter_entry_next_w;
                                    itr_rd_entry_end_r <= iter_entry_end_abs_r;
                                    itr_rd_first_r <= 1'b0;
                                    itr_rd_offset_base_r <= itr_dec_offset_in_seg_r + {{(IACT_DATA_PTR_W-1){1'b0}}, 1'b1};
                                    itr_rd_log_seg_r <= iter_logical_seg_base_r;
                                    itr_rd_psum_base_r <= window_psum_base_r;
                                    itr_rd_valid_r <= 1'b1;
                                end
                            end else if (itr_dec_valid_r && !itr_dec_skip_r && !sliding_resp_valid_r) begin
                                sliding_resp_valid_r <= 1'b1;
                                sliding_resp_value_r <= itr_dec_value_r;
                                sliding_resp_weight_col_r <= itr_dec_weight_col_r;
                                sliding_resp_psum_base_r <= itr_dec_psum_base_r;
                                sliding_resp_retire_offp1_r <= itr_dec_offset_in_seg_r + {{(IACT_DATA_PTR_W-1){1'b0}}, 1'b1};
                                itr_dec_valid_r <= 1'b0;
                            end
                        end
                        ST_NEXT_SEG: begin
                            if ((iter_seg_rel_r + {{(IACT_SEG_IDX_W-1){1'b0}}, 1'b1}) >= current_window_seg_count_w) begin
                                iter_active_r <= 1'b0;
                                iter_done_r <= 1'b1;
                                wm_state_r <= ST_DONE;
                            end else begin
                                iter_seg_rel_r <= iter_seg_rel_r + {{(IACT_SEG_IDX_W-1){1'b0}}, 1'b1};
                                iter_phys_seg_r <= seg_ring_inc_f(iter_phys_seg_r);
                                iter_logical_seg_base_r <= iter_logical_seg_base_r + current_segment_len_w;
                                wm_state_r <= ST_ITER_SEG;
                            end
                        end
                        ST_DONE: begin
                            if (!sliding_iter_start_w)
                                wm_state_r <= ST_IDLE;
                        end
                    endcase

                // pop queue into S2 when S2 is free
                if (queue_pop_w) begin
                    s2_valid_r       <= 1'b1;
                    s2_iact_value_r  <= q0_value_r;
                    s2_weight_col_r  <= q0_weight_col_r;
                    s2_psum_base_r   <= q0_psum_base_r;
                end

                // Promote S2 -> active when allowed.
                if (allow_active_start_w) begin
                    if (weight_col_begin_w == weight_col_end_w) begin
                        s2_valid_r <= 1'b0;
                    end else begin
                        active_task_valid_r <= 1'b1;
                        active_iact_value_r <= s2_iact_value_r;
                        active_weight_col_r <= s2_weight_col_r;
                        active_psum_base_r  <= s2_psum_base_r;
                        weight_word_ptr_r   <= weight_col_begin_w;
                        weight_word_end_r   <= weight_col_end_w;
                        weight_row_base_r   <= {PSUM_ADDR_W{1'b0}};
                        weight_first_word_r <= 1'b1;
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
                    s3_weight_col_r             <= active_weight_col_r;
                    s3_psum_base_r              <= active_psum_base_r;
                    s3_weight_row_base_r        <= issue_row_base_w;
                    s3_weight_first_word_r      <= issue_first_word_w;
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
                
                if (acc_mac_complete_w && !run_drained_latched_r) begin
                    run_drained_latched_r <= 1'b1;
                    mode_r                <= MODE_IDLE;
                    cal_fin_r             <= 1'b1;
                    acc_phase_r           <= ACC_IDLE;
                    acc_ready_r           <= 1'b0;
                    acc_flush_done_r           <= 1'b0;
                    acc_post_compute_flush_r   <= 1'b0;
                end

                if (s5_valid_r && s5_last_weight_word_r && active_task_valid_r &&
                    weight_issue_done_r && queue_empty_w && !s2_valid_r) begin
                    active_task_valid_r <= 1'b0;
                    weight_issue_done_r <= 1'b0;
                end
            end
            // increase merge_idx
            MODE_MERGE: begin
                psum_rd_en0_r   <= 1'b1;
                // Keep read address aligned with the next handshake beat after prefetch.
                psum_rd_addr0_r <= merge_idx_r
                                 + (((psum_router_valid_in && psum_router_ready_in) && (merge_idx_r != ctrl_cfg_psum_depth_in))
                                    ? {{(PSUM_ADDR_W-1){1'b0}},1'b1}
                                    : {PSUM_ADDR_W{1'b0}});
                if (psum_router_valid_in && psum_router_ready_in) begin
                    if (merge_idx_r == ctrl_cfg_psum_depth_in) begin
                        psum_acc_fin_r   <= 1'b1;
                        mode_r           <= MODE_IDLE;
                        merge_req_pending_r <= 1'b0;
                    end else begin
                        merge_idx_r <= merge_idx_r + {{(PSUM_ADDR_W-1){1'b0}},1'b1};
                    end
                end
            end

            MODE_POOL: begin
                if (cluster_ctrl_pool_cmp_stop_in && !pool_out_valid_r)
                    mode_r <= MODE_IDLE;
            end

            default: begin
                mode_r <= MODE_IDLE;
            end
        endcase

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
                    q0_psum_base_r  <= q1_psum_base_r;
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
                    q0_psum_base_r  <= frontend_task_psum_base_w;
                end else begin
                    q1_valid_r      <= 1'b1;
                    q1_value_r      <= frontend_task_iact_value_w;
                    q1_weight_col_r <= frontend_task_weight_col_w;
                    q1_psum_base_r  <= frontend_task_psum_base_w;
                end
            end
            2'b11: begin
                if (q1_valid_r) begin
                    q0_valid_r      <= 1'b1;
                    q0_value_r      <= q1_value_r;
                    q0_weight_col_r <= q1_weight_col_r;
                    q0_psum_base_r  <= q1_psum_base_r;
                    q1_valid_r      <= 1'b1;
                    q1_value_r      <= frontend_task_iact_value_w;
                    q1_weight_col_r <= frontend_task_weight_col_w;
                    q1_psum_base_r  <= frontend_task_psum_base_w;
                end else begin
                    q0_valid_r      <= 1'b1;
                    q0_value_r      <= frontend_task_iact_value_w;
                    q0_weight_col_r <= frontend_task_weight_col_w;
                    q0_psum_base_r  <= frontend_task_psum_base_w;
                    q1_valid_r      <= 1'b0;
                end
            end
        endcase
end
end

// Direct accumulator update at S5 commit (single-cycle reg read + add + write)
always @(posedge clk) begin
    if (rst) begin
        // acc_r reset handled in main block
    end else if (ctrl_cfg_psum_spad_clear_in) begin
        // acc_r cleared in main block
    end else if (s5_valid_r && (acc_phase_r == ACC_COMPUTE) && !acc_flush_hold_w) begin
        if (s5_lane0_valid_r && s5_lane1_valid_r && (s5_psum_addr0_r == s5_psum_addr1_r)) begin
            if (s5_lane0_acc_en_w && s5_lane1_acc_en_w) begin
                acc_r[s5_local_row0_w] <= acc_r[s5_local_row0_w] + s5_product0_r + s5_product1_r;
                acc_dirty_r[s5_local_row0_w] <= 1'b1;
            end else if (s5_lane0_acc_en_w) begin
                acc_r[s5_local_row0_w] <= acc_r[s5_local_row0_w] + s5_product0_r;
                acc_dirty_r[s5_local_row0_w] <= 1'b1;
            end else if (s5_lane1_acc_en_w) begin
                acc_r[s5_local_row1_w] <= acc_r[s5_local_row1_w] + s5_product1_r;
                acc_dirty_r[s5_local_row1_w] <= 1'b1;
            end
        end else begin
            if (s5_lane0_valid_r && s5_lane0_acc_en_w) begin
                acc_r[s5_local_row0_w] <= acc_r[s5_local_row0_w] + s5_product0_r;
                acc_dirty_r[s5_local_row0_w] <= 1'b1;
            end
            if (s5_lane1_valid_r && s5_lane1_acc_en_w) begin
                acc_r[s5_local_row1_w] <= acc_r[s5_local_row1_w] + s5_product1_r;
                acc_dirty_r[s5_local_row1_w] <= 1'b1;
            end
        end
    end
end


endmodule