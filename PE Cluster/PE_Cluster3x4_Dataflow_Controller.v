`timescale 1ns/1ps

module PE_Cluster3x4_Dataflow_Controller #(
    parameter integer GLB_AW = 16
) (
    input  wire                        clk,
    input  wire                        rst,

    input  wire                        ctrl_job_start_in,
    input  wire                        ctrl_job_abort_in,
    input  wire [1:0]                  ctrl_exec_mode_in,
    input  wire [11:0]                 ctrl_pe_mask_in,
    output wire                        ctrl_job_busy_out,
    output wire                        ctrl_job_done_out,
    output wire                        ctrl_job_error_out,
    output wire [4:0]                  ctrl_state_dbg_out,
    output wire                        ctrl_dbg_iact_addr_word_valid_out,
    input  wire                        ctrl_dbg_iact_addr_word_ready_in,
    output wire [39:0]                 ctrl_dbg_iact_addr_word_data_out,
    output wire [15:0]                 ctrl_dbg_iact_addr_word_index_out,
    output wire                        ctrl_dbg_iact_addr_seq_done_out,
    output wire                        ctrl_dbg_iact_addr_stage_valid_out,
    input  wire                        ctrl_dbg_iact_addr_stage_ready_in,
    output wire [39:0]                 ctrl_dbg_iact_addr_stage_payload_out,
    output wire [7:0]                  ctrl_dbg_iact_addr_stage_slot_valid_out,
    output wire [95:0]                 ctrl_dbg_iact_addr_stage_dst_mask_out,
    output wire [15:0]                 ctrl_dbg_iact_addr_stage_index_out,
    output wire                        ctrl_dbg_iact_data_word_valid_out,
    input  wire                        ctrl_dbg_iact_data_word_ready_in,
    output wire [103:0]                ctrl_dbg_iact_data_word_data_out,
    output wire [15:0]                 ctrl_dbg_iact_data_word_index_out,
    output wire                        ctrl_dbg_iact_data_seq_done_out,
    output wire                        ctrl_dbg_iact_data_stage_valid_out,
    input  wire                        ctrl_dbg_iact_data_stage_ready_in,
    output wire [103:0]                ctrl_dbg_iact_data_stage_payload_out,
    output wire [7:0]                  ctrl_dbg_iact_data_stage_slot_valid_out,
    output wire [95:0]                 ctrl_dbg_iact_data_stage_dst_mask_out,
    output wire [15:0]                 ctrl_dbg_iact_data_stage_index_out,
    output wire                        ctrl_dbg_weight_addr_word_valid_out,
    input  wire                        ctrl_dbg_weight_addr_word_ready_in,
    output wire [20:0]                 ctrl_dbg_weight_addr_word_data_out,
    output wire [15:0]                 ctrl_dbg_weight_addr_word_index_out,
    output wire                        ctrl_dbg_weight_addr_seq_done_out,
    output wire                        ctrl_dbg_weight_addr_stage_valid_out,
    input  wire                        ctrl_dbg_weight_addr_stage_ready_in,
    output wire [20:0]                 ctrl_dbg_weight_addr_stage_payload_out,
    output wire [2:0]                  ctrl_dbg_weight_addr_stage_valid_lanes_out,
    output wire [11:0]                 ctrl_dbg_weight_addr_stage_row_dst_mask_out,
    output wire [15:0]                 ctrl_dbg_weight_addr_stage_index_out,
    output wire                        ctrl_dbg_weight_data_word_valid_out,
    input  wire                        ctrl_dbg_weight_data_word_ready_in,
    output wire [71:0]                 ctrl_dbg_weight_data_word_data_out,
    output wire [15:0]                 ctrl_dbg_weight_data_word_index_out,
    output wire                        ctrl_dbg_weight_data_seq_done_out,
    output wire                        ctrl_dbg_weight_data_stage_valid_out,
    input  wire                        ctrl_dbg_weight_data_stage_ready_in,
    output wire [71:0]                 ctrl_dbg_weight_data_stage_payload_out,
    output wire [2:0]                  ctrl_dbg_weight_data_stage_valid_lanes_out,
    output wire [11:0]                 ctrl_dbg_weight_data_stage_row_dst_mask_out,
    output wire [15:0]                 ctrl_dbg_weight_data_stage_index_out,

    input  wire                        desc_valid_in,
    output wire                        desc_ready_out,
    input  wire [4:0]                  desc_kernel_h_in,
    input  wire [4:0]                  desc_kernel_w_in,
    input  wire [4:0]                  desc_stride_h_in,
    input  wire [4:0]                  desc_stride_w_in,
    input  wire [4:0]                  desc_c_in_in,
    input  wire [5:0]                  desc_m_out_in,
    input  wire [11:0]                 desc_active_pe_mask_in,
    input  wire [15:0]                 desc_output_window_count_in,
    input  wire [15:0]                 desc_append_segment_count_in,
    input  wire [GLB_AW-1:0]           desc_iact_addr_base_in,
    input  wire [15:0]                 desc_iact_addr_word_count_in,
    input  wire [GLB_AW-1:0]           desc_iact_data_base_in,
    input  wire [15:0]                 desc_iact_data_word_count_in,
    input  wire [GLB_AW-1:0]           desc_iact_append_addr_base_in,
    input  wire [15:0]                 desc_iact_append_addr_word_count_in,
    input  wire [GLB_AW-1:0]           desc_iact_append_data_base_in,
    input  wire [15:0]                 desc_iact_append_data_word_count_in,
    input  wire [GLB_AW-1:0]           desc_weight_addr_base_in,
    input  wire [15:0]                 desc_weight_addr_word_count_in,
    input  wire [GLB_AW-1:0]           desc_weight_data_base_in,
    input  wire [15:0]                 desc_weight_data_word_count_in,
    input  wire                        desc_weight_compute_buf_sel_in,
    input  wire [GLB_AW-1:0]           desc_psum_read_base_in,
    input  wire [GLB_AW-1:0]           desc_psum_write_base_in,
    input  wire [15:0]                 desc_psum_count_in,
    input  wire [4:0]                  desc_psum_depth_in,
    input  wire [4:0]                  desc_psum_base_in,
    input  wire [5:0]                  desc_m0_in,

    output wire                        glb_iact_addr_rd_valid_out,
    input  wire                        glb_iact_addr_rd_ready_in,
    output wire [GLB_AW-1:0]           glb_iact_addr_rd_addr_out,
    input  wire                        glb_iact_addr_resp_valid_in,
    output wire                        glb_iact_addr_resp_ready_out,
    input  wire [39:0]                 glb_iact_addr_resp_data_in,

    output wire                        glb_iact_data_rd_valid_out,
    input  wire                        glb_iact_data_rd_ready_in,
    output wire [GLB_AW-1:0]           glb_iact_data_rd_addr_out,
    input  wire                        glb_iact_data_resp_valid_in,
    output wire                        glb_iact_data_resp_ready_out,
    input  wire [103:0]                glb_iact_data_resp_data_in,

    output wire                        glb_weight_addr_rd_valid_out,
    input  wire                        glb_weight_addr_rd_ready_in,
    output wire [GLB_AW-1:0]           glb_weight_addr_rd_addr_out,
    input  wire                        glb_weight_addr_resp_valid_in,
    output wire                        glb_weight_addr_resp_ready_out,
    input  wire [20:0]                 glb_weight_addr_resp_data_in,

    output wire                        glb_weight_data_rd_valid_out,
    input  wire                        glb_weight_data_rd_ready_in,
    output wire [GLB_AW-1:0]           glb_weight_data_rd_addr_out,
    input  wire                        glb_weight_data_resp_valid_in,
    output wire                        glb_weight_data_resp_ready_out,
    input  wire [71:0]                 glb_weight_data_resp_data_in,

    input  wire                        hm_all_write_fin_in,
    input  wire                        hm_all_cal_fin_in,
    input  wire [11:0]                 hm_pe_iact_addr_write_fin_in,
    input  wire [11:0]                 hm_pe_iact_data_write_fin_in,
    input  wire [11:0]                 hm_pe_weight_addr_write_fin_in,
    input  wire [11:0]                 hm_pe_weight_data_write_fin_in,
    input  wire [11:0]                 hm_pe_slide_safe_in,
    input  wire [11:0]                 hm_pe_cal_fin_in,
    input  wire [11:0]                 hm_pe_psum_acc_fin_in,
    input  wire [7:0]                  hm_iact_addr_ready_in,
    input  wire [7:0]                  hm_iact_data_ready_in,
    input  wire [2:0]                  hm_weight_addr_ready_in,
    input  wire [2:0]                  hm_weight_data_ready_in,
    input  wire [3:0]                  hm_psum_col_ready_from_router_in,
    input  wire [3:0]                  hm_psum_col_ready_from_south_in,
    input  wire [3:0]                  hm_psum_col_valid_in,
    input  wire [3:0]                  hm_psum_col_ready_in,

    output wire [1:0]                  ctrl_layer_mode_out,
    output wire [1:0]                  ctrl_iact_router_prio_out,
    output wire [7:0]                  ctrl_iact_addr_slot_valid_out,
    output wire [39:0]                 ctrl_iact_addr_data_out,
    output wire [95:0]                 ctrl_iact_addr_dst_mask_out,
    output wire [7:0]                  ctrl_iact_data_slot_valid_out,
    output wire [103:0]                ctrl_iact_data_out,
    output wire [95:0]                 ctrl_iact_data_dst_mask_out,
    output wire                        ctrl_do_mac_en_out,
    output wire [2:0]                  ctrl_weight_addr_valid_out,
    output wire [20:0]                 ctrl_weight_addr_data_out,
    output wire [11:0]                 ctrl_weight_addr_row_dst_mask_out,
    output wire [2:0]                  ctrl_weight_data_valid_out,
    output wire [71:0]                 ctrl_weight_data_out,
    output wire [11:0]                 ctrl_weight_data_row_dst_mask_out,
    output wire                        ctrl_psum_col_sel_out,
    output wire [3:0]                  ctrl_psum_col_valid_from_router_out,
    output wire signed [83:0]          ctrl_psum_col_data_from_router_out,
    output wire [3:0]                  ctrl_psum_col_valid_from_south_out,
    output wire signed [83:0]          ctrl_psum_col_data_from_south_out,
    output wire [11:0]                 ctrl_pe_disable_out,
    output wire                        ctrl_psum_enq_en_out,
    output wire                        ctrl_do_load_en_out,
    output wire                        ctrl_iact_write_fin_clear_out,
    output wire                        ctrl_weight_write_fin_clear_out,
    output wire [4:0]                  ctrl_psum_depth_out,
    output wire                        ctrl_psum_spad_clear_out,
    output wire [4:0]                  ctrl_cfg_window_size_out,
    output wire [4:0]                  ctrl_cfg_segment_len_out,
    output wire [3:0]                  ctrl_cfg_window_seg_count_out,
    output wire [4:0]                  ctrl_cfg_psum_base_out,
    output wire [5:0]                  ctrl_cfg_m0_out,
    output wire                        ctrl_cfg_iact_flush_out,
    output wire                        ctrl_cfg_slide_commit_out,
    output wire [11:0]                 ctrl_pool_cmp_en_out,
    output wire [11:0]                 ctrl_pool_cmp_stop_out,
    output wire [11:0]                 ctrl_pool_elem_valid_out,
    output wire signed [95:0]          ctrl_pool_elem_data_out,
    output wire [11:0]                 ctrl_pool_win_first_out,
    output wire [11:0]                 ctrl_pool_win_last_out
);

    localparam [4:0] ST_IDLE             = 5'd0;
    localparam [4:0] ST_LATCH_DESC       = 5'd1;
    localparam [4:0] ST_VALIDATE_DESC    = 5'd2;
    localparam [4:0] ST_CFG_PE           = 5'd3;
    localparam [4:0] ST_APPEND_REARM     = 5'd4;
    localparam [4:0] ST_WEIGHT_ADDR_READ = 5'd5;
    localparam [4:0] ST_WEIGHT_DATA_READ = 5'd6;
    localparam [4:0] ST_IACT_ADDR_READ   = 5'd7;
    localparam [4:0] ST_IACT_DATA_READ   = 5'd8;
    localparam [4:0] ST_MAC_PULSE        = 5'd9;
    localparam [4:0] ST_WAIT_CAL         = 5'd10;
    localparam [4:0] ST_WAIT_SLIDE_SAFE  = 5'd11;
    localparam [4:0] ST_SLIDE_COMMIT     = 5'd12;
    localparam [4:0] ST_PSUM_CLEAR       = 5'd13;
    localparam [4:0] ST_PSUM_ENQ         = 5'd14;
    localparam [4:0] ST_PSUM_DRAIN       = 5'd15;
    localparam [4:0] ST_DONE             = 5'd16;
    localparam [4:0] ST_ERROR            = 5'd17;
    localparam [4:0] ST_PASS_REARM       = 5'd18;

    reg [4:0]        state_r;
    reg              start_prev_r;
    reg [19:0]       watchdog_r;
    reg [4:0]        kernel_h_r;
    reg [4:0]        kernel_w_r;
    reg [4:0]        stride_h_r;
    reg [4:0]        stride_w_r;
    reg [4:0]        c_in_r;
    reg [5:0]        m_out_r;
    reg [11:0]       active_pe_mask_r;
    reg [15:0]       output_window_count_r;
    reg [15:0]       current_window_idx_r;
    reg [15:0]       append_segment_count_r;
    reg [15:0]       append_index_r;
    reg [GLB_AW-1:0] iact_addr_base_r;
    reg [15:0]       iact_addr_word_count_r;
    reg [GLB_AW-1:0] iact_data_base_r;
    reg [15:0]       iact_data_word_count_r;
    reg [GLB_AW-1:0] iact_append_addr_base_r;
    reg [15:0]       iact_append_addr_word_count_r;
    reg [GLB_AW-1:0] iact_append_data_base_r;
    reg [15:0]       iact_append_data_word_count_r;
    reg [GLB_AW-1:0] weight_addr_base_r;
    reg [15:0]       weight_addr_word_count_r;
    reg [GLB_AW-1:0] weight_data_base_r;
    reg [15:0]       weight_data_word_count_r;
    reg              weight_compute_buf_sel_r;
    reg [GLB_AW-1:0] psum_read_base_r;
    reg [GLB_AW-1:0] psum_write_base_r;
    reg [15:0]       psum_count_r;
    reg [4:0]        psum_depth_r;
    reg [4:0]        psum_base_r;
    reg [5:0]        m0_r;
    reg              iact_addr_seq_started_r;
    reg              iact_data_seq_started_r;
    reg              iact_addr_stage_valid_r;
    reg [39:0]       iact_addr_stage_payload_r;
    reg [7:0]        iact_addr_stage_slot_valid_r;
    reg [95:0]       iact_addr_stage_dst_mask_r;
    reg [15:0]       iact_addr_stage_index_r;
    reg              iact_addr_seq_done_seen_r;
    reg              iact_addr_sched_done_seen_r;
    reg              iact_data_stage_valid_r;
    reg [103:0]      iact_data_stage_payload_r;
    reg [7:0]        iact_data_stage_slot_valid_r;
    reg [95:0]       iact_data_stage_dst_mask_r;
    reg [15:0]       iact_data_stage_index_r;
    reg              iact_data_seq_done_seen_r;
    reg              iact_data_sched_done_seen_r;
    reg              weight_phase_meta_valid_r;
    reg [2:0]        weight_phase_valid_lanes_r;
    reg [11:0]       weight_phase_row_dst_mask_r;
    reg              weight_addr_stage_valid_r;
    reg [20:0]       weight_addr_stage_payload_r;
    reg [2:0]        weight_addr_stage_valid_lanes_r;
    reg [11:0]       weight_addr_stage_row_dst_mask_r;
    reg [15:0]       weight_addr_stage_index_r;
    reg              weight_addr_seq_done_seen_r;
    reg              weight_data_seq_started_r;
    reg              weight_data_stage_valid_r;
    reg [71:0]       weight_data_stage_payload_r;
    reg [2:0]        weight_data_stage_valid_lanes_r;
    reg [11:0]       weight_data_stage_row_dst_mask_r;
    reg [15:0]       weight_data_stage_index_r;
    reg              weight_data_seq_done_seen_r;
    reg [11:0]       cal_fin_seen_r;
    reg [11:0]       slide_safe_seen_r;
    reg              iact_append_phase_r;
    reg [11:0]       iact_addr_write_fin_seen_r;
    reg [11:0]       iact_data_write_fin_seen_r;
    reg              slide_after_psum_drain_r;
    reg [11:0]       psum_acc_fin_seen_r;
    reg [5:0]        psum_seed_count_r [0:3];
    reg [5:0]        psum_output_count_r [0:3];
    reg [3:0]        psum_active_col_mask_r;
    integer          psum_col_i;

    wire start_pulse_w = ctrl_job_start_in & ~start_prev_r;
    wire desc_accept_w = (state_r == ST_LATCH_DESC) & desc_valid_in;
    wire weight_load_contract_valid_w =
        ((weight_addr_word_count_r == 16'd0) && (weight_data_word_count_r == 16'd0)) ||
        ((weight_addr_word_count_r != 16'd0) && (weight_data_word_count_r != 16'd0));
    wire w0_compute_requested_w = (iact_addr_word_count_r != 16'd0) &
                                  (iact_data_word_count_r != 16'd0);
    wire valid_k3_s1_rs_w = (kernel_h_r == 5'd3) & (kernel_w_r == 5'd3) &
                            (stride_h_r == 5'd1) & (stride_w_r == 5'd1) &
                            (c_in_r != 5'd0) & (active_pe_mask_r != 12'h000) &
                            (output_window_count_r != 16'd0) &
                            (!w0_compute_requested_w || weight_load_contract_valid_w) &
                            ((output_window_count_r == 16'd1) ||
                             (append_segment_count_r == 16'd1));
    wire weight_addr_seq_start_w = (state_r == ST_CFG_PE);
    wire weight_addr_seq_done_w;
    wire weight_addr_seq_busy_w;
    wire weight_data_seq_start_w = (state_r == ST_WEIGHT_DATA_READ) && !weight_data_seq_started_r;
    wire weight_data_seq_start_ready_w;
    wire weight_data_seq_done_w;
    wire weight_data_seq_busy_w;
    wire iact_addr_seq_start_w = (state_r == ST_IACT_ADDR_READ) && !iact_addr_seq_started_r;
    wire iact_addr_seq_start_ready_w;
    wire iact_addr_seq_done_w;
    wire iact_addr_seq_busy_w;
    wire iact_data_seq_start_w = (state_r == ST_IACT_DATA_READ) && !iact_data_seq_started_r;
    wire iact_data_seq_start_ready_w;
    wire iact_data_seq_done_w;
    wire iact_data_seq_busy_w;
    wire iact_addr_seq_word_valid_w;
    wire iact_addr_seq_word_ready_w;
    wire [39:0] iact_addr_seq_word_data_w;
    wire [15:0] iact_addr_seq_word_index_w;
    wire iact_addr_sched_meta_valid_w;
    wire iact_addr_sched_meta_ready_w;
    wire [7:0] iact_addr_sched_slot_valid_w;
    wire [95:0] iact_addr_sched_dst_mask_w;
    wire [15:0] iact_addr_sched_beat_index_w;
    wire iact_addr_sched_done_w;
    wire iact_addr_sched_error_w;
    wire iact_data_seq_word_valid_w;
    wire iact_data_seq_word_ready_w;
    wire [103:0] iact_data_seq_word_data_w;
    wire [15:0] iact_data_seq_word_index_w;
    wire iact_data_sched_meta_valid_w;
    wire iact_data_sched_meta_ready_w;
    wire [7:0] iact_data_sched_slot_valid_w;
    wire [95:0] iact_data_sched_dst_mask_w;
    wire [15:0] iact_data_sched_beat_index_w;
    wire iact_data_sched_done_w;
    wire iact_data_sched_error_w;
    wire iact_addr_sched_index_match_w;
    wire iact_data_sched_index_match_w;

    wire [7:0] iact_addr_slot_present_w = 8'h3f;
    wire [7:0] iact_data_slot_present_w = {
        2'b00,
        (iact_data_seq_word_data_w[65 +: 13] != 13'h000),
        (iact_data_seq_word_data_w[52 +: 13] != 13'h000),
        (iact_data_seq_word_data_w[39 +: 13] != 13'h000),
        (iact_data_seq_word_data_w[26 +: 13] != 13'h000),
        (iact_data_seq_word_data_w[13 +: 13] != 13'h000),
        (iact_data_seq_word_data_w[0 +: 13] != 13'h000)
    };
    wire weight_sched_meta_valid_w;
    wire weight_sched_meta_ready_w;
    wire [2:0] weight_sched_valid_lanes_w;
    wire [11:0] weight_sched_row_dst_mask_w;
    wire [3:0] weight_sched_beat_index_w;
    wire weight_sched_done_w;
    wire weight_sched_error_w;
    wire weight_addr_seq_word_valid_w;
    wire weight_addr_seq_word_ready_w;
    wire [20:0] weight_addr_seq_word_data_w;
    wire [15:0] weight_addr_seq_word_index_w;
    wire weight_data_seq_word_valid_w;
    wire weight_data_seq_word_ready_w;
    wire [71:0] weight_data_seq_word_data_w;
    wire [15:0] weight_data_seq_word_index_w;
    wire weight_addr_native_ready_w = ((hm_weight_addr_ready_in & weight_addr_stage_valid_lanes_r) ==
                                       weight_addr_stage_valid_lanes_r);
    wire weight_data_native_ready_w = ((hm_weight_data_ready_in & weight_data_stage_valid_lanes_r) ==
                                       weight_data_stage_valid_lanes_r);
    wire weight_addr_write_fin_done_w = ((hm_pe_weight_addr_write_fin_in & active_pe_mask_r) ==
                                         active_pe_mask_r);
    wire weight_data_write_fin_done_w = ((hm_pe_weight_data_write_fin_in & active_pe_mask_r) ==
                                         active_pe_mask_r);
    wire iact_addr_native_ready_w = ((hm_iact_addr_ready_in & iact_addr_stage_slot_valid_r) ==
                                     iact_addr_stage_slot_valid_r);
    wire iact_data_native_ready_w = ((hm_iact_data_ready_in & iact_data_stage_slot_valid_r) ==
                                     iact_data_stage_slot_valid_r);
    wire [11:0] iact_addr_write_fin_seen_next_w =
        iact_addr_write_fin_seen_r | (hm_pe_iact_addr_write_fin_in & active_pe_mask_r);
    wire [11:0] iact_data_write_fin_seen_next_w =
        iact_data_write_fin_seen_r | (hm_pe_iact_data_write_fin_in & active_pe_mask_r);
    wire iact_addr_write_fin_done_w = ((iact_addr_write_fin_seen_next_w & active_pe_mask_r) ==
                                       active_pe_mask_r);
    wire iact_data_write_fin_done_w = ((iact_data_write_fin_seen_next_w & active_pe_mask_r) ==
                                       active_pe_mask_r);
    wire [11:0] cal_fin_seen_next_w = cal_fin_seen_r | (hm_pe_cal_fin_in & active_pe_mask_r);
    wire cal_fin_done_w = ((cal_fin_seen_next_w & active_pe_mask_r) == active_pe_mask_r);
    wire [11:0] slide_safe_seen_next_w = slide_safe_seen_r | (hm_pe_slide_safe_in & active_pe_mask_r);
    wire slide_safe_done_w = ((slide_safe_seen_next_w & active_pe_mask_r) == active_pe_mask_r);
    wire [15:0] append_next_index_w = append_index_r + 16'd1;
    wire append_loop_active_w = (append_segment_count_r != 16'd0);
    wire append_loop_more_w = (append_next_index_w < append_segment_count_r);
    wire [15:0] window_next_index_w = current_window_idx_r + 16'd1;
    wire window_more_w = (window_next_index_w < output_window_count_r);
    wire [15:0] transition_index_w =
        (current_window_idx_r == 16'd0) ? 16'd0 : (current_window_idx_r - 16'd1);
    wire [15:0] total_append_index_w =
        (transition_index_w * append_segment_count_r) + append_index_r;
    wire [GLB_AW-1:0] append_addr_iter_base_w =
        iact_append_addr_base_r + (total_append_index_w * iact_append_addr_word_count_r);
    wire [GLB_AW-1:0] append_data_iter_base_w =
        iact_append_data_base_r + (total_append_index_w * iact_append_data_word_count_r);
    wire [3:0] active_col_mask_w = {
        |{active_pe_mask_r[11], active_pe_mask_r[7], active_pe_mask_r[3]},
        |{active_pe_mask_r[10], active_pe_mask_r[6], active_pe_mask_r[2]},
        |{active_pe_mask_r[9],  active_pe_mask_r[5], active_pe_mask_r[1]},
        |{active_pe_mask_r[8],  active_pe_mask_r[4], active_pe_mask_r[0]}
    };
    wire [3:0] psum_seed_fire_w =
        ctrl_psum_col_valid_from_south_out & hm_psum_col_ready_from_south_in;
    wire [3:0] psum_output_fire_w =
        hm_psum_col_valid_in & hm_psum_col_ready_in & psum_active_col_mask_r;
    wire [11:0] psum_acc_fin_seen_next_w = psum_acc_fin_seen_r | hm_pe_psum_acc_fin_in;
    wire psum_acc_fin_done_w =
        ((psum_acc_fin_seen_next_w & active_pe_mask_r) == active_pe_mask_r);
    wire psum_drain_done_w =
        (!psum_active_col_mask_r[0] || ((psum_seed_count_r[0] >= m0_r) && (psum_output_count_r[0] >= m0_r))) &&
        (!psum_active_col_mask_r[1] || ((psum_seed_count_r[1] >= m0_r) && (psum_output_count_r[1] >= m0_r))) &&
        (!psum_active_col_mask_r[2] || ((psum_seed_count_r[2] >= m0_r) && (psum_output_count_r[2] >= m0_r))) &&
        (!psum_active_col_mask_r[3] || ((psum_seed_count_r[3] >= m0_r) && (psum_output_count_r[3] >= m0_r))) &&
        psum_acc_fin_done_w;
    wire weight_addr_stage_ready_w = ctrl_dbg_weight_addr_word_ready_in &
                                     ctrl_dbg_weight_addr_stage_ready_in &
                                     weight_addr_native_ready_w;
    wire weight_data_stage_ready_w = ctrl_dbg_weight_data_word_ready_in &
                                     ctrl_dbg_weight_data_stage_ready_in &
                                     weight_data_native_ready_w;
    wire iact_addr_stage_ready_w = ctrl_dbg_iact_addr_word_ready_in &
                                   ctrl_dbg_iact_addr_stage_ready_in &
                                   iact_addr_native_ready_w;
    wire iact_data_stage_ready_w = ctrl_dbg_iact_data_word_ready_in &
                                   ctrl_dbg_iact_data_stage_ready_in &
                                   iact_data_native_ready_w;
    wire iact_addr_stage_fire_w = iact_addr_stage_valid_r & iact_addr_stage_ready_w;
    wire iact_data_stage_fire_w = iact_data_stage_valid_r & iact_data_stage_ready_w;
    wire weight_addr_stage_fire_w = weight_addr_stage_valid_r & weight_addr_stage_ready_w;
    wire weight_data_stage_fire_w = weight_data_stage_valid_r & weight_data_stage_ready_w;
    wire iact_addr_stage_can_accept_w = !iact_addr_stage_valid_r || iact_addr_stage_fire_w;
    wire iact_addr_stage_load_w = iact_addr_seq_word_valid_w &
                                  iact_addr_sched_meta_valid_w &
                                  iact_addr_sched_index_match_w &
                                  iact_addr_stage_can_accept_w;
    wire iact_data_stage_can_accept_w = !iact_data_stage_valid_r || iact_data_stage_fire_w;
    wire iact_data_stage_load_w = iact_data_seq_word_valid_w &
                                  iact_data_sched_meta_valid_w &
                                  iact_data_sched_index_match_w &
                                  iact_data_stage_can_accept_w;
    assign iact_addr_sched_index_match_w =
        iact_addr_sched_beat_index_w == iact_addr_seq_word_index_w;
    assign iact_data_sched_index_match_w =
        iact_data_sched_beat_index_w == iact_data_seq_word_index_w;

    always @(posedge clk) begin
        if (rst) start_prev_r <= 1'b0;
        else start_prev_r <= ctrl_job_start_in;
    end

    always @(posedge clk) begin
        if (rst) begin
            state_r <= ST_IDLE;
            watchdog_r <= 20'd0;
            kernel_h_r <= 5'd0;
            kernel_w_r <= 5'd0;
            stride_h_r <= 5'd0;
            stride_w_r <= 5'd0;
            c_in_r <= 5'd0;
            m_out_r <= 6'd0;
            active_pe_mask_r <= 12'h000;
            output_window_count_r <= 16'd0;
            current_window_idx_r <= 16'd0;
            append_segment_count_r <= 16'd0;
            append_index_r <= 16'd0;
            iact_addr_base_r <= {GLB_AW{1'b0}};
            iact_addr_word_count_r <= 16'd0;
            iact_data_base_r <= {GLB_AW{1'b0}};
            iact_data_word_count_r <= 16'd0;
            iact_append_addr_base_r <= {GLB_AW{1'b0}};
            iact_append_addr_word_count_r <= 16'd0;
            iact_append_data_base_r <= {GLB_AW{1'b0}};
            iact_append_data_word_count_r <= 16'd0;
            weight_addr_base_r <= {GLB_AW{1'b0}};
            weight_addr_word_count_r <= 16'd0;
            weight_data_base_r <= {GLB_AW{1'b0}};
            weight_data_word_count_r <= 16'd0;
            weight_compute_buf_sel_r <= 1'b0;
            psum_read_base_r <= {GLB_AW{1'b0}};
            psum_write_base_r <= {GLB_AW{1'b0}};
            psum_count_r <= 16'd0;
            psum_depth_r <= 5'd0;
            psum_base_r <= 5'd0;
            m0_r <= 6'd0;
            iact_addr_seq_started_r <= 1'b0;
            iact_data_seq_started_r <= 1'b0;
            iact_addr_stage_valid_r <= 1'b0;
            iact_addr_stage_payload_r <= 40'h0;
            iact_addr_stage_slot_valid_r <= 8'h00;
            iact_addr_stage_dst_mask_r <= 96'h0;
            iact_addr_stage_index_r <= 16'd0;
            iact_addr_seq_done_seen_r <= 1'b0;
            iact_addr_sched_done_seen_r <= 1'b0;
            iact_data_stage_valid_r <= 1'b0;
            iact_data_stage_payload_r <= 104'h0;
            iact_data_stage_slot_valid_r <= 8'h00;
            iact_data_stage_dst_mask_r <= 96'h0;
            iact_data_stage_index_r <= 16'd0;
            iact_data_seq_done_seen_r <= 1'b0;
            iact_data_sched_done_seen_r <= 1'b0;
            weight_phase_meta_valid_r <= 1'b0;
            weight_phase_valid_lanes_r <= 3'b000;
            weight_phase_row_dst_mask_r <= 12'h000;
            weight_addr_stage_valid_r <= 1'b0;
            weight_addr_stage_payload_r <= 21'h0;
            weight_addr_stage_valid_lanes_r <= 3'b000;
            weight_addr_stage_row_dst_mask_r <= 12'h000;
            weight_addr_stage_index_r <= 16'd0;
            weight_addr_seq_done_seen_r <= 1'b0;
            weight_data_seq_started_r <= 1'b0;
            weight_data_stage_valid_r <= 1'b0;
            weight_data_stage_payload_r <= 72'h0;
            weight_data_stage_valid_lanes_r <= 3'b000;
            weight_data_stage_row_dst_mask_r <= 12'h000;
            weight_data_stage_index_r <= 16'd0;
            weight_data_seq_done_seen_r <= 1'b0;
            cal_fin_seen_r <= 12'h000;
            slide_safe_seen_r <= 12'h000;
            iact_append_phase_r <= 1'b0;
            iact_addr_write_fin_seen_r <= 12'h000;
            iact_data_write_fin_seen_r <= 12'h000;
            slide_after_psum_drain_r <= 1'b0;
            psum_acc_fin_seen_r <= 12'h000;
            psum_active_col_mask_r <= 4'h0;
            for (psum_col_i = 0; psum_col_i < 4; psum_col_i = psum_col_i + 1) begin
                psum_seed_count_r[psum_col_i] <= 6'd0;
                psum_output_count_r[psum_col_i] <= 6'd0;
            end
        end else begin
            if ((state_r != ST_IDLE) && (state_r != ST_DONE) && (state_r != ST_ERROR))
                watchdog_r <= watchdog_r + 20'd1;
            else
                watchdog_r <= 20'd0;

            if (ctrl_job_abort_in) begin
                state_r <= ST_ERROR;
            end else begin
                case (state_r)
                    ST_IDLE: begin
                        if (start_pulse_w) state_r <= ST_LATCH_DESC;
                    end

                    ST_LATCH_DESC: begin
                        if (desc_accept_w) begin
                            kernel_h_r <= desc_kernel_h_in;
                            kernel_w_r <= desc_kernel_w_in;
                            stride_h_r <= desc_stride_h_in;
                            stride_w_r <= desc_stride_w_in;
                            c_in_r <= desc_c_in_in;
                            m_out_r <= desc_m_out_in;
                            active_pe_mask_r <= desc_active_pe_mask_in;
                            output_window_count_r <= desc_output_window_count_in;
                            current_window_idx_r <= 16'd0;
                            append_segment_count_r <= desc_append_segment_count_in;
                            append_index_r <= 16'd0;
                            iact_addr_base_r <= desc_iact_addr_base_in;
                            iact_addr_word_count_r <= desc_iact_addr_word_count_in;
                            iact_data_base_r <= desc_iact_data_base_in;
                            iact_data_word_count_r <= desc_iact_data_word_count_in;
                            iact_append_addr_base_r <= desc_iact_append_addr_base_in;
                            iact_append_addr_word_count_r <= desc_iact_append_addr_word_count_in;
                            iact_append_data_base_r <= desc_iact_append_data_base_in;
                            iact_append_data_word_count_r <= desc_iact_append_data_word_count_in;
                            weight_addr_base_r <= desc_weight_addr_base_in;
                            weight_addr_word_count_r <= desc_weight_addr_word_count_in;
                            weight_data_base_r <= desc_weight_data_base_in;
                            weight_data_word_count_r <= desc_weight_data_word_count_in;
                            weight_compute_buf_sel_r <= desc_weight_compute_buf_sel_in;
                            psum_read_base_r <= desc_psum_read_base_in;
                            psum_write_base_r <= desc_psum_write_base_in;
                            psum_count_r <= desc_psum_count_in;
                            psum_depth_r <= desc_psum_depth_in;
                            psum_base_r <= desc_psum_base_in;
                            m0_r <= desc_m0_in;
                            state_r <= ST_VALIDATE_DESC;
                        end else if (watchdog_r == 20'hfffff) begin
                            state_r <= ST_ERROR;
                        end
                    end

                    ST_VALIDATE_DESC: begin
                        if (valid_k3_s1_rs_w) state_r <= ST_PASS_REARM;
                        else state_r <= ST_ERROR;
                    end

                    ST_PASS_REARM: begin
                        state_r <= ST_CFG_PE;
                    end

                    ST_CFG_PE: begin
                        weight_phase_meta_valid_r <= 1'b0;
                        weight_phase_valid_lanes_r <= 3'b000;
                        weight_phase_row_dst_mask_r <= 12'h000;
                        weight_addr_seq_done_seen_r <= 1'b0;
                        weight_data_seq_started_r <= 1'b0;
                        weight_data_seq_done_seen_r <= 1'b0;
                        iact_addr_seq_done_seen_r <= 1'b0;
                        iact_addr_sched_done_seen_r <= 1'b0;
                        iact_data_seq_done_seen_r <= 1'b0;
                        iact_data_sched_done_seen_r <= 1'b0;
                        iact_addr_seq_started_r <= 1'b0;
                        iact_data_seq_started_r <= 1'b0;
                        cal_fin_seen_r <= 12'h000;
                        slide_safe_seen_r <= 12'h000;
                        current_window_idx_r <= 16'd0;
                        append_index_r <= 16'd0;
                        iact_append_phase_r <= 1'b0;
                        iact_addr_write_fin_seen_r <= 12'h000;
                        iact_data_write_fin_seen_r <= 12'h000;
                        slide_after_psum_drain_r <= 1'b0;
                        psum_active_col_mask_r <= active_col_mask_w;
                        for (psum_col_i = 0; psum_col_i < 4; psum_col_i = psum_col_i + 1) begin
                            psum_seed_count_r[psum_col_i] <= 6'd0;
                            psum_output_count_r[psum_col_i] <= 6'd0;
                        end
                        if (weight_sched_error_w)
                            state_r <= ST_ERROR;
                        if (weight_addr_word_count_r != 16'd0)
                            state_r <= ST_WEIGHT_ADDR_READ;
                        else if (weight_data_word_count_r != 16'd0)
                            state_r <= ST_WEIGHT_DATA_READ;
                        else if (iact_addr_word_count_r != 16'd0)
                            state_r <= ST_IACT_ADDR_READ;
                        else if (iact_data_word_count_r != 16'd0)
                            state_r <= ST_IACT_DATA_READ;
                        else
                            state_r <= ST_DONE;
                    end

                    ST_WEIGHT_ADDR_READ: begin
                        if (weight_addr_seq_done_w)
                            weight_addr_seq_done_seen_r <= 1'b1;

                        if ((weight_addr_seq_done_seen_r | weight_addr_seq_done_w) &
                            !weight_addr_stage_valid_r &
                            !(weight_addr_seq_word_valid_w && weight_addr_seq_word_ready_w) &
                            weight_addr_write_fin_done_w) begin
                            if (weight_data_word_count_r != 16'd0)
                                state_r <= ST_WEIGHT_DATA_READ;
                            else if (iact_addr_word_count_r != 16'd0)
                                state_r <= ST_IACT_ADDR_READ;
                            else if (iact_data_word_count_r != 16'd0)
                                state_r <= ST_IACT_DATA_READ;
                            else
                                state_r <= ST_DONE;
                        end
                        else if (watchdog_r == 20'hfffff)
                            state_r <= ST_ERROR;
                    end

                    ST_WEIGHT_DATA_READ: begin
                        if (weight_data_seq_start_w && weight_data_seq_start_ready_w)
                            weight_data_seq_started_r <= 1'b1;
                        if (weight_data_seq_done_w)
                            weight_data_seq_done_seen_r <= 1'b1;

                        if ((weight_data_seq_done_seen_r | weight_data_seq_done_w) &
                            !weight_data_stage_valid_r &
                            !(weight_data_seq_word_valid_w && weight_data_seq_word_ready_w) &
                            weight_data_write_fin_done_w) begin
                            if (iact_addr_word_count_r != 16'd0)
                                state_r <= ST_IACT_ADDR_READ;
                            else if (iact_data_word_count_r != 16'd0)
                                state_r <= ST_IACT_DATA_READ;
                            else
                                state_r <= ST_DONE;
                        end
                        else if (watchdog_r == 20'hfffff)
                            state_r <= ST_ERROR;
                    end

                    ST_IACT_ADDR_READ: begin
                        if (iact_addr_seq_start_w && iact_addr_seq_start_ready_w)
                            iact_addr_seq_started_r <= 1'b1;
                        if (iact_addr_seq_done_w)
                            iact_addr_seq_done_seen_r <= 1'b1;
                        if (iact_addr_sched_done_w)
                            iact_addr_sched_done_seen_r <= 1'b1;
                        iact_addr_write_fin_seen_r <= iact_addr_write_fin_seen_next_w;
                        if (iact_addr_sched_error_w)
                            state_r <= ST_ERROR;

                        if ((iact_addr_seq_done_seen_r | iact_addr_seq_done_w) &
                            (iact_addr_sched_done_seen_r | iact_addr_sched_done_w) &
                            !iact_addr_stage_valid_r &
                            !iact_addr_stage_load_w) begin
                            if (iact_data_word_count_r != 16'd0) begin
                                iact_data_write_fin_seen_r <= 12'h000;
                                iact_data_seq_done_seen_r <= 1'b0;
                                iact_data_sched_done_seen_r <= 1'b0;
                                iact_data_seq_started_r <= 1'b0;
                                state_r <= ST_IACT_DATA_READ;
                            end
                            else if (iact_addr_write_fin_done_w) begin
                                if (w0_compute_requested_w)
                                    state_r <= ST_PSUM_CLEAR;
                                else
                                    state_r <= ST_DONE;
                            end
                        end
                        else if (watchdog_r == 20'hfffff)
                            state_r <= ST_ERROR;
                    end

                    ST_IACT_DATA_READ: begin
                        if (iact_data_seq_start_w && iact_data_seq_start_ready_w)
                            iact_data_seq_started_r <= 1'b1;
                        if (iact_data_seq_done_w)
                            iact_data_seq_done_seen_r <= 1'b1;
                        if (iact_data_sched_done_w)
                            iact_data_sched_done_seen_r <= 1'b1;
                        iact_data_write_fin_seen_r <= iact_data_write_fin_seen_next_w;
                        if (iact_data_sched_error_w)
                            state_r <= ST_ERROR;

                        if ((iact_data_seq_done_seen_r | iact_data_seq_done_w) &
                            (iact_data_sched_done_seen_r | iact_data_sched_done_w) &
                            !iact_data_stage_valid_r &
                            !iact_data_stage_load_w &
                            iact_data_write_fin_done_w) begin
                            if (iact_append_phase_r) begin
                                iact_append_phase_r <= 1'b0;
                                cal_fin_seen_r <= 12'h000;
                                state_r <= ST_PSUM_CLEAR;
                            end else if (w0_compute_requested_w) begin
                                cal_fin_seen_r <= 12'h000;
                                state_r <= ST_PSUM_CLEAR;
                            end else begin
                                state_r <= ST_DONE;
                            end
                        end
                        else if (watchdog_r == 20'hfffff)
                            state_r <= ST_ERROR;
                    end

                    ST_PSUM_CLEAR: begin
                        cal_fin_seen_r <= 12'h000;
                        state_r <= ST_MAC_PULSE;
                    end

                    ST_MAC_PULSE: begin
                        cal_fin_seen_r <= 12'h000;
                        slide_safe_seen_r <= 12'h000;
                        state_r <= ST_WAIT_CAL;
                    end

                    ST_WAIT_CAL: begin
                        cal_fin_seen_r <= cal_fin_seen_next_w;
                        if (cal_fin_done_w) begin
                            if (window_more_w)
                                state_r <= ST_WAIT_SLIDE_SAFE;
                            else
                                state_r <= ST_PSUM_ENQ;
                        end
                        else if (watchdog_r == 20'hfffff)
                            state_r <= ST_ERROR;
                    end

                    ST_PSUM_ENQ: begin
                        psum_active_col_mask_r <= active_col_mask_w;
                        psum_acc_fin_seen_r <= 12'h000;
                        for (psum_col_i = 0; psum_col_i < 4; psum_col_i = psum_col_i + 1) begin
                            psum_seed_count_r[psum_col_i] <= 6'd0;
                            psum_output_count_r[psum_col_i] <= 6'd0;
                        end
                        state_r <= ST_PSUM_DRAIN;
                    end

                    ST_PSUM_DRAIN: begin
                        psum_acc_fin_seen_r <= psum_acc_fin_seen_next_w;
                        for (psum_col_i = 0; psum_col_i < 4; psum_col_i = psum_col_i + 1) begin
                            if (psum_seed_fire_w[psum_col_i] && (psum_seed_count_r[psum_col_i] < m0_r))
                                psum_seed_count_r[psum_col_i] <= psum_seed_count_r[psum_col_i] + 6'd1;
                            if (psum_output_fire_w[psum_col_i] && (psum_output_count_r[psum_col_i] < m0_r))
                                psum_output_count_r[psum_col_i] <= psum_output_count_r[psum_col_i] + 6'd1;
                        end
                        if (psum_drain_done_w) begin
                            if (slide_after_psum_drain_r) begin
                                slide_after_psum_drain_r <= 1'b0;
                                state_r <= ST_APPEND_REARM;
                            end else begin
                                state_r <= ST_DONE;
                            end
                        end else if (watchdog_r == 20'hfffff) begin
                            state_r <= ST_ERROR;
                        end
                    end

                    ST_WAIT_SLIDE_SAFE: begin
                        slide_safe_seen_r <= slide_safe_seen_next_w;
                        if (slide_safe_done_w)
                            state_r <= ST_SLIDE_COMMIT;
                        else if (watchdog_r == 20'hfffff)
                            state_r <= ST_ERROR;
                    end

                    ST_SLIDE_COMMIT: begin
                        current_window_idx_r <= window_next_index_w;
                        append_index_r <= 16'd0;
                        slide_after_psum_drain_r <= 1'b1;
                        state_r <= ST_PSUM_ENQ;
                    end

                    ST_APPEND_REARM: begin
                        if (append_loop_active_w && (iact_append_addr_word_count_r != 16'd0)) begin
                            iact_append_phase_r <= 1'b1;
                            iact_addr_base_r <= append_addr_iter_base_w;
                            iact_addr_word_count_r <= iact_append_addr_word_count_r;
                            iact_data_base_r <= append_data_iter_base_w;
                            iact_data_word_count_r <= iact_append_data_word_count_r;
                            iact_addr_seq_done_seen_r <= 1'b0;
                            iact_addr_sched_done_seen_r <= 1'b0;
                            iact_data_seq_done_seen_r <= 1'b0;
                            iact_data_sched_done_seen_r <= 1'b0;
                            iact_addr_seq_started_r <= 1'b0;
                            iact_data_seq_started_r <= 1'b0;
                            iact_addr_write_fin_seen_r <= 12'h000;
                            iact_data_write_fin_seen_r <= 12'h000;
                            state_r <= ST_IACT_ADDR_READ;
                        end else if (append_loop_active_w && (iact_append_data_word_count_r != 16'd0)) begin
                            iact_append_phase_r <= 1'b1;
                            iact_addr_word_count_r <= 16'd0;
                            iact_data_base_r <= append_data_iter_base_w;
                            iact_data_word_count_r <= iact_append_data_word_count_r;
                            iact_data_seq_done_seen_r <= 1'b0;
                            iact_data_sched_done_seen_r <= 1'b0;
                            iact_data_seq_started_r <= 1'b0;
                            iact_data_write_fin_seen_r <= 12'h000;
                            state_r <= ST_IACT_DATA_READ;
                        end else begin
                            state_r <= ST_PSUM_CLEAR;
                        end
                    end

                    ST_DONE: begin
                        if (!ctrl_job_start_in) state_r <= ST_IDLE;
                    end

                    default: state_r <= ST_ERROR;
                endcase
            end

            if (weight_sched_meta_valid_w && weight_sched_meta_ready_w) begin
                weight_phase_meta_valid_r <= 1'b1;
                weight_phase_valid_lanes_r <= weight_sched_valid_lanes_w;
                weight_phase_row_dst_mask_r <= weight_sched_row_dst_mask_w;
            end

            if (weight_addr_seq_word_valid_w && weight_addr_seq_word_ready_w) begin
                weight_addr_stage_valid_r <= 1'b1;
                weight_addr_stage_payload_r <= weight_addr_seq_word_data_w;
                weight_addr_stage_valid_lanes_r <= weight_phase_valid_lanes_r;
                weight_addr_stage_row_dst_mask_r <= weight_phase_row_dst_mask_r;
                weight_addr_stage_index_r <= weight_addr_seq_word_index_w;
            end else if (weight_addr_stage_fire_w) begin
                weight_addr_stage_valid_r <= 1'b0;
            end

            if (weight_data_seq_word_valid_w && weight_data_seq_word_ready_w) begin
                weight_data_stage_valid_r <= 1'b1;
                weight_data_stage_payload_r <= weight_data_seq_word_data_w;
                weight_data_stage_valid_lanes_r <= weight_phase_valid_lanes_r;
                weight_data_stage_row_dst_mask_r <= weight_phase_row_dst_mask_r;
                weight_data_stage_index_r <= weight_data_seq_word_index_w;
            end else if (weight_data_stage_fire_w) begin
                weight_data_stage_valid_r <= 1'b0;
            end

            if (iact_addr_stage_load_w) begin
                iact_addr_stage_valid_r <= 1'b1;
                iact_addr_stage_payload_r <= iact_addr_seq_word_data_w;
                iact_addr_stage_slot_valid_r <= iact_addr_sched_slot_valid_w;
                iact_addr_stage_dst_mask_r <= iact_addr_sched_dst_mask_w;
                iact_addr_stage_index_r <= iact_addr_seq_word_index_w;
            end else if (iact_addr_stage_fire_w) begin
                iact_addr_stage_valid_r <= 1'b0;
            end
            if (iact_addr_seq_word_valid_w && iact_addr_sched_meta_valid_w &&
                !iact_addr_sched_index_match_w)
                state_r <= ST_ERROR;

            if (iact_data_stage_load_w) begin
                iact_data_stage_valid_r <= 1'b1;
                iact_data_stage_payload_r <= iact_data_seq_word_data_w;
                iact_data_stage_slot_valid_r <= iact_data_sched_slot_valid_w;
                iact_data_stage_dst_mask_r <= iact_data_sched_dst_mask_w;
                iact_data_stage_index_r <= iact_data_seq_word_index_w;
            end else if (iact_data_stage_fire_w) begin
                iact_data_stage_valid_r <= 1'b0;
            end
            if (iact_data_seq_word_valid_w && iact_data_sched_meta_valid_w &&
                !iact_data_sched_index_match_w)
                state_r <= ST_ERROR;

        end
    end

    assign desc_ready_out = (state_r == ST_LATCH_DESC);

    assign ctrl_state_dbg_out = state_r;
    assign ctrl_job_busy_out = (state_r != ST_IDLE) && (state_r != ST_DONE) && (state_r != ST_ERROR);
    assign ctrl_job_done_out = (state_r == ST_DONE);
    assign ctrl_job_error_out = (state_r == ST_ERROR);

    assign ctrl_dbg_iact_addr_stage_valid_out = iact_addr_stage_valid_r;
    assign ctrl_dbg_iact_addr_stage_payload_out = iact_addr_stage_payload_r;
    assign ctrl_dbg_iact_addr_stage_slot_valid_out = iact_addr_stage_slot_valid_r;
    assign ctrl_dbg_iact_addr_stage_dst_mask_out = iact_addr_stage_dst_mask_r;
    assign ctrl_dbg_iact_addr_stage_index_out = iact_addr_stage_index_r;
    assign ctrl_dbg_iact_addr_word_valid_out = iact_addr_stage_valid_r;
    assign ctrl_dbg_iact_addr_word_data_out = iact_addr_stage_payload_r;
    assign ctrl_dbg_iact_addr_word_index_out = iact_addr_stage_index_r;

    assign ctrl_dbg_iact_data_stage_valid_out = iact_data_stage_valid_r;
    assign ctrl_dbg_iact_data_stage_payload_out = iact_data_stage_payload_r;
    assign ctrl_dbg_iact_data_stage_slot_valid_out = iact_data_stage_slot_valid_r;
    assign ctrl_dbg_iact_data_stage_dst_mask_out = iact_data_stage_dst_mask_r;
    assign ctrl_dbg_iact_data_stage_index_out = iact_data_stage_index_r;
    assign ctrl_dbg_iact_data_word_valid_out = iact_data_stage_valid_r;
    assign ctrl_dbg_iact_data_word_data_out = iact_data_stage_payload_r;
    assign ctrl_dbg_iact_data_word_index_out = iact_data_stage_index_r;

    assign ctrl_dbg_weight_addr_stage_valid_out = weight_addr_stage_valid_r;
    assign ctrl_dbg_weight_addr_stage_payload_out = weight_addr_stage_payload_r;
    assign ctrl_dbg_weight_addr_stage_valid_lanes_out = weight_addr_stage_valid_lanes_r;
    assign ctrl_dbg_weight_addr_stage_row_dst_mask_out = weight_addr_stage_row_dst_mask_r;
    assign ctrl_dbg_weight_addr_stage_index_out = weight_addr_stage_index_r;
    assign ctrl_dbg_weight_addr_word_valid_out = weight_addr_stage_valid_r;
    assign ctrl_dbg_weight_addr_word_data_out = weight_addr_stage_payload_r;
    assign ctrl_dbg_weight_addr_word_index_out = weight_addr_stage_index_r;

    assign ctrl_dbg_weight_data_stage_valid_out = weight_data_stage_valid_r;
    assign ctrl_dbg_weight_data_stage_payload_out = weight_data_stage_payload_r;
    assign ctrl_dbg_weight_data_stage_valid_lanes_out = weight_data_stage_valid_lanes_r;
    assign ctrl_dbg_weight_data_stage_row_dst_mask_out = weight_data_stage_row_dst_mask_r;
    assign ctrl_dbg_weight_data_stage_index_out = weight_data_stage_index_r;
    assign ctrl_dbg_weight_data_word_valid_out = weight_data_stage_valid_r;
    assign ctrl_dbg_weight_data_word_data_out = weight_data_stage_payload_r;
    assign ctrl_dbg_weight_data_word_index_out = weight_data_stage_index_r;

    assign ctrl_layer_mode_out = 2'b00;
    assign ctrl_iact_router_prio_out = 2'b00;
    assign ctrl_iact_addr_slot_valid_out = iact_addr_stage_valid_r ? iact_addr_stage_slot_valid_r : 8'h00;
    assign ctrl_iact_addr_data_out = iact_addr_stage_payload_r;
    assign ctrl_iact_addr_dst_mask_out = iact_addr_stage_valid_r ? iact_addr_stage_dst_mask_r : 96'h0;
    assign ctrl_iact_data_slot_valid_out = iact_data_stage_valid_r ? iact_data_stage_slot_valid_r : 8'h00;
    assign ctrl_iact_data_out = iact_data_stage_payload_r;
    assign ctrl_iact_data_dst_mask_out = iact_data_stage_valid_r ? iact_data_stage_dst_mask_r : 96'h0;
    assign ctrl_do_mac_en_out = (state_r == ST_MAC_PULSE);
    assign ctrl_weight_addr_valid_out = weight_addr_stage_valid_r ? weight_addr_stage_valid_lanes_r : 3'b000;
    assign ctrl_weight_addr_data_out = weight_addr_stage_payload_r;
    assign ctrl_weight_addr_row_dst_mask_out = weight_addr_stage_valid_r ? weight_addr_stage_row_dst_mask_r : 12'h000;
    assign ctrl_weight_data_valid_out = weight_data_stage_valid_r ? weight_data_stage_valid_lanes_r : 3'b000;
    assign ctrl_weight_data_out = weight_data_stage_payload_r;
    assign ctrl_weight_data_row_dst_mask_out = weight_data_stage_valid_r ? weight_data_stage_row_dst_mask_r : 12'h000;
    assign ctrl_psum_col_sel_out = 1'b0;
    assign ctrl_psum_col_valid_from_router_out = 4'h0;
    assign ctrl_psum_col_data_from_router_out = 84'sd0;
    assign ctrl_psum_col_valid_from_south_out = (state_r == ST_PSUM_DRAIN) ? {
        psum_active_col_mask_r[3] & (psum_seed_count_r[3] < m0_r),
        psum_active_col_mask_r[2] & (psum_seed_count_r[2] < m0_r),
        psum_active_col_mask_r[1] & (psum_seed_count_r[1] < m0_r),
        psum_active_col_mask_r[0] & (psum_seed_count_r[0] < m0_r)
    } : 4'h0;
    assign ctrl_psum_col_data_from_south_out = 84'sd0;
    assign ctrl_pe_disable_out = ~active_pe_mask_r;
    assign ctrl_psum_enq_en_out = (state_r == ST_PSUM_ENQ);
    assign ctrl_do_load_en_out =
        (state_r == ST_PASS_REARM) ||
        (state_r == ST_CFG_PE) ||
        (state_r == ST_WEIGHT_ADDR_READ) ||
        (state_r == ST_WEIGHT_DATA_READ) ||
        (state_r == ST_APPEND_REARM) ||
        (state_r == ST_IACT_ADDR_READ) ||
        (state_r == ST_IACT_DATA_READ);
    assign ctrl_iact_write_fin_clear_out =
        (state_r == ST_PASS_REARM) || (state_r == ST_APPEND_REARM);
    assign ctrl_weight_write_fin_clear_out =
        (state_r == ST_PASS_REARM) &&
        ((weight_addr_word_count_r != 16'd0) || (weight_data_word_count_r != 16'd0));
    assign ctrl_psum_depth_out = psum_depth_r;
    assign ctrl_psum_spad_clear_out = (state_r == ST_PSUM_CLEAR);
    assign ctrl_cfg_window_size_out = valid_k3_s1_rs_w ? (c_in_r + c_in_r + c_in_r) : 5'd0;
    assign ctrl_cfg_segment_len_out = valid_k3_s1_rs_w ? c_in_r : 5'd0;
    assign ctrl_cfg_window_seg_count_out = valid_k3_s1_rs_w ? 4'd3 : 4'd0;
    assign ctrl_cfg_psum_base_out = psum_base_r;
    assign ctrl_cfg_m0_out = m0_r;
    assign ctrl_cfg_iact_flush_out = (state_r == ST_PASS_REARM);
    assign ctrl_cfg_slide_commit_out = (state_r == ST_SLIDE_COMMIT);
    assign ctrl_pool_cmp_en_out = 12'h000;
    assign ctrl_pool_cmp_stop_out = 12'h000;
    assign ctrl_pool_elem_valid_out = 12'h000;
    assign ctrl_pool_elem_data_out = 96'sd0;
    assign ctrl_pool_win_first_out = 12'h000;
    assign ctrl_pool_win_last_out = 12'h000;

    PE3x4_GLB_Read_Sequencer #(
        .AWIDTH(GLB_AW),
        .DATA_WIDTH(40),
        .COUNT_WIDTH(16)
    ) u_iact_addr_read_seq (
        .clk(clk),
        .rst(rst),
        .start_valid_in(iact_addr_seq_start_w),
        .start_ready_out(iact_addr_seq_start_ready_w),
        .base_addr_in(iact_addr_base_r),
        .word_count_in(iact_addr_word_count_r),
        .rd_valid_out(glb_iact_addr_rd_valid_out),
        .rd_ready_in(glb_iact_addr_rd_ready_in),
        .rd_addr_out(glb_iact_addr_rd_addr_out),
        .resp_valid_in(glb_iact_addr_resp_valid_in),
        .resp_ready_out(glb_iact_addr_resp_ready_out),
        .resp_data_in(glb_iact_addr_resp_data_in),
        .word_valid_out(iact_addr_seq_word_valid_w),
        .word_ready_in(iact_addr_seq_word_ready_w),
        .word_data_out(iact_addr_seq_word_data_w),
        .word_index_out(iact_addr_seq_word_index_w),
        .busy_out(iact_addr_seq_busy_w),
        .done_out(iact_addr_seq_done_w)
    );

    assign ctrl_dbg_iact_addr_seq_done_out = iact_addr_seq_done_w;
    assign iact_addr_seq_word_ready_w =
        iact_addr_sched_meta_valid_w &
        iact_addr_sched_index_match_w &
        iact_addr_stage_can_accept_w;
    assign iact_addr_sched_meta_ready_w =
        iact_addr_seq_word_valid_w &
        iact_addr_sched_index_match_w &
        iact_addr_stage_can_accept_w;

    PE3x4_RS_IACT_Scheduler u_iact_addr_rs_sched (
        .clk(clk),
        .rst(rst),
        .start_in(iact_addr_seq_start_w),
        .k_in(kernel_h_r),
        .stride_in(stride_w_r),
        .active_pe_mask_in(active_pe_mask_r),
        .beat_count_in(iact_addr_word_count_r),
        .slot_present_in(iact_addr_slot_present_w),
        .meta_valid_out(iact_addr_sched_meta_valid_w),
        .meta_ready_in(iact_addr_sched_meta_ready_w),
        .slot_valid_out(iact_addr_sched_slot_valid_w),
        .dst_mask_out(iact_addr_sched_dst_mask_w),
        .beat_index_out(iact_addr_sched_beat_index_w),
        .done_out(iact_addr_sched_done_w),
        .error_out(iact_addr_sched_error_w)
    );

    PE3x4_GLB_Read_Sequencer #(
        .AWIDTH(GLB_AW),
        .DATA_WIDTH(104),
        .COUNT_WIDTH(16)
    ) u_iact_data_read_seq (
        .clk(clk),
        .rst(rst),
        .start_valid_in(iact_data_seq_start_w),
        .start_ready_out(iact_data_seq_start_ready_w),
        .base_addr_in(iact_data_base_r),
        .word_count_in(iact_data_word_count_r),
        .rd_valid_out(glb_iact_data_rd_valid_out),
        .rd_ready_in(glb_iact_data_rd_ready_in),
        .rd_addr_out(glb_iact_data_rd_addr_out),
        .resp_valid_in(glb_iact_data_resp_valid_in),
        .resp_ready_out(glb_iact_data_resp_ready_out),
        .resp_data_in(glb_iact_data_resp_data_in),
        .word_valid_out(iact_data_seq_word_valid_w),
        .word_ready_in(iact_data_seq_word_ready_w),
        .word_data_out(iact_data_seq_word_data_w),
        .word_index_out(iact_data_seq_word_index_w),
        .busy_out(iact_data_seq_busy_w),
        .done_out(iact_data_seq_done_w)
    );

    assign ctrl_dbg_iact_data_seq_done_out = iact_data_seq_done_w;
    assign iact_data_seq_word_ready_w =
        iact_data_sched_meta_valid_w &
        iact_data_sched_index_match_w &
        iact_data_stage_can_accept_w;
    assign iact_data_sched_meta_ready_w =
        iact_data_seq_word_valid_w &
        iact_data_sched_index_match_w &
        iact_data_stage_can_accept_w;

    PE3x4_RS_IACT_Scheduler u_iact_data_rs_sched (
        .clk(clk),
        .rst(rst),
        .start_in(iact_data_seq_start_w),
        .k_in(kernel_h_r),
        .stride_in(stride_w_r),
        .active_pe_mask_in(active_pe_mask_r),
        .beat_count_in(iact_data_word_count_r),
        .slot_present_in(iact_data_slot_present_w),
        .meta_valid_out(iact_data_sched_meta_valid_w),
        .meta_ready_in(iact_data_sched_meta_ready_w),
        .slot_valid_out(iact_data_sched_slot_valid_w),
        .dst_mask_out(iact_data_sched_dst_mask_w),
        .beat_index_out(iact_data_sched_beat_index_w),
        .done_out(iact_data_sched_done_w),
        .error_out(iact_data_sched_error_w)
    );

    PE3x4_RS_Weight_Scheduler u_weight_rs_sched (
        .clk(clk),
        .rst(rst),
        .start_in(weight_addr_seq_start_w),
        .k_in(kernel_h_r),
        .active_pe_mask_in(active_pe_mask_r),
        .meta_valid_out(weight_sched_meta_valid_w),
        .meta_ready_in(weight_sched_meta_ready_w),
        .weight_valid_lanes_out(weight_sched_valid_lanes_w),
        .weight_row_dst_mask_out(weight_sched_row_dst_mask_w),
        .beat_index_out(weight_sched_beat_index_w),
        .done_out(weight_sched_done_w),
        .error_out(weight_sched_error_w)
    );

    assign weight_sched_meta_ready_w = !weight_phase_meta_valid_r;

    PE3x4_GLB_Read_Sequencer #(
        .AWIDTH(GLB_AW),
        .DATA_WIDTH(21),
        .COUNT_WIDTH(16)
    ) u_weight_addr_read_seq (
        .clk(clk),
        .rst(rst),
        .start_valid_in(weight_addr_seq_start_w),
        .start_ready_out(),
        .base_addr_in(weight_addr_base_r),
        .word_count_in(weight_addr_word_count_r),
        .rd_valid_out(glb_weight_addr_rd_valid_out),
        .rd_ready_in(glb_weight_addr_rd_ready_in),
        .rd_addr_out(glb_weight_addr_rd_addr_out),
        .resp_valid_in(glb_weight_addr_resp_valid_in),
        .resp_ready_out(glb_weight_addr_resp_ready_out),
        .resp_data_in(glb_weight_addr_resp_data_in),
        .word_valid_out(weight_addr_seq_word_valid_w),
        .word_ready_in(weight_addr_seq_word_ready_w),
        .word_data_out(weight_addr_seq_word_data_w),
        .word_index_out(weight_addr_seq_word_index_w),
        .busy_out(weight_addr_seq_busy_w),
        .done_out(weight_addr_seq_done_w)
    );

    assign ctrl_dbg_weight_addr_seq_done_out = weight_addr_seq_done_w;
    assign weight_addr_seq_word_ready_w = weight_phase_meta_valid_r &
                                          (!weight_addr_stage_valid_r || weight_addr_stage_fire_w);

    PE3x4_GLB_Read_Sequencer #(
        .AWIDTH(GLB_AW),
        .DATA_WIDTH(72),
        .COUNT_WIDTH(16)
    ) u_weight_data_read_seq (
        .clk(clk),
        .rst(rst),
        .start_valid_in(weight_data_seq_start_w),
        .start_ready_out(weight_data_seq_start_ready_w),
        .base_addr_in(weight_data_base_r),
        .word_count_in(weight_data_word_count_r),
        .rd_valid_out(glb_weight_data_rd_valid_out),
        .rd_ready_in(glb_weight_data_rd_ready_in),
        .rd_addr_out(glb_weight_data_rd_addr_out),
        .resp_valid_in(glb_weight_data_resp_valid_in),
        .resp_ready_out(glb_weight_data_resp_ready_out),
        .resp_data_in(glb_weight_data_resp_data_in),
        .word_valid_out(weight_data_seq_word_valid_w),
        .word_ready_in(weight_data_seq_word_ready_w),
        .word_data_out(weight_data_seq_word_data_w),
        .word_index_out(weight_data_seq_word_index_w),
        .busy_out(weight_data_seq_busy_w),
        .done_out(weight_data_seq_done_w)
    );

    assign ctrl_dbg_weight_data_seq_done_out = weight_data_seq_done_w;
    assign weight_data_seq_word_ready_w = weight_phase_meta_valid_r &
                                          (!weight_data_stage_valid_r || weight_data_stage_fire_w);

    wire _unused_w = ctrl_exec_mode_in[0] | ctrl_exec_mode_in[1] |
                     ctrl_pe_mask_in[0] |
                     m_out_r[0] | output_window_count_r[0] |
                     append_segment_count_r[0] | append_index_r[0] |
                     slide_after_psum_drain_r |
                     iact_append_addr_base_r[0] | iact_append_addr_word_count_r[0] |
                     iact_append_data_base_r[0] | iact_append_data_word_count_r[0] |
                     weight_compute_buf_sel_r | psum_read_base_r[0] |
                     psum_write_base_r[0] | psum_count_r[0] |
                     stride_h_r[0] | stride_w_r[0] |
                     iact_addr_seq_busy_w | iact_data_seq_busy_w |
                     weight_sched_beat_index_w[0] | weight_sched_done_w |
                     weight_addr_seq_busy_w | weight_data_seq_busy_w |
                     hm_all_write_fin_in | hm_all_cal_fin_in |
                     hm_pe_iact_addr_write_fin_in[0] |
                     hm_pe_iact_data_write_fin_in[0] |
                     hm_pe_weight_addr_write_fin_in[0] |
                     hm_pe_weight_data_write_fin_in[0] |
                     hm_pe_slide_safe_in[0] | hm_pe_cal_fin_in[0] |
                     hm_iact_addr_ready_in[0] | hm_iact_data_ready_in[0] |
                     hm_weight_addr_ready_in[0] | hm_weight_data_ready_in[0] |
                     hm_psum_col_ready_from_router_in[0] |
                     hm_psum_col_ready_from_south_in[0] |
                     hm_psum_col_valid_in[0] | hm_psum_col_ready_in[0] |
                     hm_pe_psum_acc_fin_in[0];
endmodule
