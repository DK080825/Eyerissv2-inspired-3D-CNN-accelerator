// ================================================================================================ //
// PE_Cluster3x4_Top — cluster wrapper: Dataflow_Controller + HMesh.
// BYPASS_CTRL=1: external ports drive native HMesh interfaces.
// BYPASS_CTRL=0: controller drives native HMesh interfaces.
// ================================================================================================ //

module PE_Cluster3x4_Top #(
    parameter integer BYPASS_CTRL = 1
) (
    input  wire                        clk,
    input  wire                        rst,

    // -------------------------------------------------------------------------------------------- //
    // Controller job interface (active when BYPASS_CTRL=0)
    // -------------------------------------------------------------------------------------------- //
    input  wire                        ctrl_job_start_in,
    input  wire                        ctrl_job_abort_in,
    input  wire [1:0]                  ctrl_exec_mode_in,
    input  wire [11:0]                 ctrl_pe_mask_in,
    output wire                        ctrl_job_busy_out,
    output wire                        ctrl_job_done_out,
    output wire                        ctrl_job_error_out,
    output wire [4:0]                  ctrl_state_dbg_out,

    input  wire [4:0]                  desc_kernel_h_in,
    input  wire [4:0]                  desc_kernel_w_in,
    input  wire [4:0]                  desc_stride_h_in,
    input  wire [4:0]                  desc_stride_w_in,
    input  wire [4:0]                  desc_c_in_in,
    input  wire [5:0]                  desc_m_out_in,
    input  wire [15:0]                 desc_output_window_count_in,
    input  wire [15:0]                 desc_append_segment_count_in,
    input  wire [15:0]                 desc_iact_addr_base_in,
    input  wire [15:0]                 desc_iact_addr_word_count_in,
    input  wire [15:0]                 desc_iact_data_base_in,
    input  wire [15:0]                 desc_iact_data_word_count_in,
    input  wire [15:0]                 desc_iact_append_addr_base_in,
    input  wire [15:0]                 desc_iact_append_addr_word_count_in,
    input  wire [15:0]                 desc_iact_append_data_base_in,
    input  wire [15:0]                 desc_iact_append_data_word_count_in,
    input  wire [15:0]                 desc_weight_addr_base_in,
    input  wire [15:0]                 desc_weight_addr_word_count_in,
    input  wire [15:0]                 desc_weight_data_base_in,
    input  wire [15:0]                 desc_weight_data_word_count_in,
    input  wire                        desc_weight_compute_buf_sel_in,
    input  wire [15:0]                 desc_psum_read_base_in,
    input  wire [15:0]                 desc_psum_write_base_in,
    input  wire [15:0]                 desc_psum_count_in,
    input  wire [4:0]                  desc_psum_depth_in,
    input  wire [4:0]                  desc_psum_base_in,
    input  wire [5:0]                  desc_m0_in,

    output wire                        glb_iact_addr_rd_valid_out,
    input  wire                        glb_iact_addr_rd_ready_in,
    output wire [15:0]                 glb_iact_addr_rd_addr_out,
    input  wire                        glb_iact_addr_resp_valid_in,
    output wire                        glb_iact_addr_resp_ready_out,
    input  wire [39:0]                 glb_iact_addr_resp_data_in,

    output wire                        glb_iact_data_rd_valid_out,
    input  wire                        glb_iact_data_rd_ready_in,
    output wire [15:0]                 glb_iact_data_rd_addr_out,
    input  wire                        glb_iact_data_resp_valid_in,
    output wire                        glb_iact_data_resp_ready_out,
    input  wire [103:0]                glb_iact_data_resp_data_in,

    output wire                        glb_weight_addr_rd_valid_out,
    input  wire                        glb_weight_addr_rd_ready_in,
    output wire [15:0]                 glb_weight_addr_rd_addr_out,
    input  wire                        glb_weight_addr_resp_valid_in,
    output wire                        glb_weight_addr_resp_ready_out,
    input  wire [20:0]                 glb_weight_addr_resp_data_in,

    output wire                        glb_weight_data_rd_valid_out,
    input  wire                        glb_weight_data_rd_ready_in,
    output wire [15:0]                 glb_weight_data_rd_addr_out,
    input  wire                        glb_weight_data_resp_valid_in,
    output wire                        glb_weight_data_resp_ready_out,
    input  wire [71:0]                 glb_weight_data_resp_data_in,

    // -------------------------------------------------------------------------------------------- //
    // Legacy HMesh ports (active when BYPASS_CTRL=1)
    // -------------------------------------------------------------------------------------------- //
    input  wire [1:0]                  layer_mode_in,
    input  wire [1:0]                  iact_router_prio_in,

    input  wire [7:0]                  iact_addr_slot_valid_in,
    output wire [7:0]                  iact_addr_slot_ready_out,
    input  wire [39:0]                 iact_addr_data_in,
    input  wire [95:0]                 iact_addr_dst_mask_in,

    input  wire [7:0]                  iact_data_slot_valid_in,
    output wire [7:0]                  iact_data_slot_ready_out,
    input  wire [103:0]                iact_data_in,
    input  wire [95:0]                 iact_data_dst_mask_in,

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
    input  wire signed [83:0]          psum_col_data_from_router_in,
    input  wire [3:0]                  psum_col_valid_from_south_in,
    output wire [3:0]                  psum_col_ready_from_south_out,
    input  wire signed [83:0]          psum_col_data_from_south_in,
    output wire [3:0]                  psum_col_valid_out,
    input  wire [3:0]                  psum_col_ready_in,
    output wire signed [83:0]          psum_col_data_out,

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
    // Observability (passthrough from HMesh)
    // -------------------------------------------------------------------------------------------- //
    output wire [11:0]                 pe_iact_addr_valid_out,
    output wire [11:0]                 pe_iact_addr_ready_out,
    output wire [59:0]                 pe_iact_addr_data_out,
    output wire [11:0]                 pe_iact_data_valid_out,
    output wire [11:0]                 pe_iact_data_ready_out,
    output wire [155:0]                pe_iact_data_out,
    output wire [11:0]                 pe_weight_addr_valid_out,
    output wire [11:0]                 pe_weight_addr_ready_out,
    output wire [83:0]                 pe_weight_addr_data_out,
    output wire [11:0]                 pe_weight_data_valid_out,
    output wire [11:0]                 pe_weight_data_ready_out,
    output wire [287:0]                pe_weight_data_out,

    output wire [11:0]                 pe_psum_router_ready_out,
    output wire [11:0]                 pe_psum_in_valid_out,
    output wire [11:0]                 pe_psum_in_ready_out,
    output wire signed [251:0]         pe_psum_in_data_out,
    output wire [11:0]                 pe_psum_out_valid_out,
    output wire [11:0]                 pe_psum_out_ready_out,
    output wire signed [251:0]         pe_psum_out_data_out,

    output wire [11:0]                 pe_iact_addr_write_fin_out,
    output wire [11:0]                 pe_iact_data_write_fin_out,
    output wire [11:0]                 pe_weight_addr_write_fin_out,
    output wire [11:0]                 pe_weight_data_write_fin_out,
    output wire [11:0]                 pe_psum_acc_fin_out,
    output wire [11:0]                 pe_slide_safe_out,
    output wire [11:0]                 pe_all_write_fin_out,
    output wire [11:0]                 pe_cal_fin_out,
    output wire [11:0]                 pe_load_en_out,
    output wire [11:0]                 pe_write_fin_sticky_out,
    output wire [11:0]                 pe_cal_fin_sticky_out
);
    localparam integer BYPASS_CTRL_ACTIVE = (BYPASS_CTRL != 0);

    // -------------------------------------------------------------------------------------------- //
    // Controller -> HMesh muxed drive
    // -------------------------------------------------------------------------------------------- //
    wire [1:0]                  hm_layer_mode_w;
    wire [1:0]                  hm_iact_router_prio_w;

    wire [7:0]                  hm_iact_addr_slot_valid_w;
    wire [39:0]                 hm_iact_addr_data_w;
    wire [95:0]                 hm_iact_addr_dst_mask_w;
    wire [7:0]                  hm_iact_data_slot_valid_w;
    wire [103:0]                hm_iact_data_w;
    wire [95:0]                 hm_iact_data_dst_mask_w;

    wire [2:0]                  hm_weight_addr_valid_w;
    wire [2:0]                  hm_weight_addr_ready_w;
    wire [20:0]                 hm_weight_addr_data_w;
    wire [11:0]                 hm_weight_addr_row_dst_mask_w;
    wire [2:0]                  hm_weight_data_valid_w;
    wire [2:0]                  hm_weight_data_ready_w;
    wire [71:0]                 hm_weight_data_w;
    wire [11:0]                 hm_weight_data_row_dst_mask_w;


    wire                        hm_psum_col_sel_w;
    wire [3:0]                  hm_psum_col_valid_from_router_w;
    wire signed [83:0]          hm_psum_col_data_from_router_w;
    wire [3:0]                  hm_psum_col_valid_from_south_w;
    wire signed [83:0]          hm_psum_col_data_from_south_w;

    wire [11:0]                 hm_pe_disable_w;
    wire                        hm_psum_enq_en_w;
    wire                        hm_do_load_en_w;
    wire                        hm_do_mac_en_w;
    wire                        hm_iact_write_fin_clear_w;
    wire                        hm_weight_write_fin_clear_w;
    wire [4:0]                  hm_psum_depth_w;
    wire                        hm_psum_spad_clear_w;

    wire [4:0]                  hm_ctrl_cfg_window_size_w;
    wire [4:0]                  hm_ctrl_cfg_segment_len_w;
    wire [3:0]                  hm_ctrl_cfg_window_seg_count_w;
    wire [4:0]                  hm_ctrl_cfg_psum_base_w;
    wire [5:0]                  hm_ctrl_cfg_m0_w;
    wire                        hm_ctrl_cfg_iact_flush_w;
    wire                        hm_ctrl_cfg_slide_commit_w;

    wire [11:0]                 hm_pool_cmp_en_w;
    wire [11:0]                 hm_pool_cmp_stop_w;
    wire [11:0]                 hm_pool_elem_valid_w;
    wire signed [95:0]          hm_pool_elem_data_w;
    wire [11:0]                 hm_pool_win_first_w;
    wire [11:0]                 hm_pool_win_last_w;

    // Controller outputs
    wire [1:0]                  ctrl_layer_mode_out;
    wire [1:0]                  ctrl_iact_router_prio_out;
    wire [7:0]                  ctrl_iact_addr_slot_valid_out;
    wire [39:0]                 ctrl_iact_addr_data_out;
    wire [95:0]                 ctrl_iact_addr_dst_mask_out;
    wire [7:0]                  ctrl_iact_data_slot_valid_out;
    wire [103:0]                ctrl_iact_data_out;
    wire [95:0]                 ctrl_iact_data_dst_mask_out;
    wire [2:0]                  ctrl_weight_addr_valid_out;
    wire [20:0]                 ctrl_weight_addr_data_out;
    wire [11:0]                 ctrl_weight_addr_row_dst_mask_out;
    wire [2:0]                  ctrl_weight_data_valid_out;
    wire [71:0]                 ctrl_weight_data_out;
    wire [11:0]                 ctrl_weight_data_row_dst_mask_out;
    wire                        ctrl_psum_col_sel_out;
    wire [3:0]                  ctrl_psum_col_valid_from_router_out;
    wire signed [83:0]          ctrl_psum_col_data_from_router_out;
    wire [3:0]                  ctrl_psum_col_valid_from_south_out;
    wire signed [83:0]          ctrl_psum_col_data_from_south_out;
    wire [11:0]                 ctrl_pe_disable_out;
    wire                        ctrl_psum_enq_en_out;
    wire                        ctrl_do_load_en_out;
    wire                        ctrl_do_mac_en_out;
    wire                        ctrl_iact_write_fin_clear_out;
    wire                        ctrl_weight_write_fin_clear_out;
    wire [4:0]                  ctrl_psum_depth_out;
    wire                        ctrl_psum_spad_clear_out;
    wire [4:0]                  ctrl_cfg_window_size_out;
    wire [4:0]                  ctrl_cfg_segment_len_out;
    wire [3:0]                  ctrl_cfg_window_seg_count_out;
    wire [4:0]                  ctrl_cfg_psum_base_out;
    wire [5:0]                  ctrl_cfg_m0_out;
    wire                        ctrl_cfg_iact_flush_out;
    wire                        ctrl_cfg_slide_commit_out;
    wire [11:0]                 ctrl_pool_cmp_en_out;
    wire [11:0]                 ctrl_pool_cmp_stop_out;
    wire [11:0]                 ctrl_pool_elem_valid_out;
    wire signed [95:0]          ctrl_pool_elem_data_out;
    wire [11:0]                 ctrl_pool_win_first_out;
    wire [11:0]                 ctrl_pool_win_last_out;

    wire                        ctrl_job_busy_w;
    wire                        ctrl_job_done_w;
    wire                        ctrl_job_error_w;
    wire [4:0]                  ctrl_state_dbg_w;
    wire                        ctrl_desc_ready_w;
    wire                        ctrl_dbg_iact_addr_word_valid_w;
    wire [39:0]                 ctrl_dbg_iact_addr_word_data_w;
    wire [15:0]                 ctrl_dbg_iact_addr_word_index_w;
    wire                        ctrl_dbg_iact_addr_seq_done_w;
    wire                        ctrl_dbg_iact_data_word_valid_w;
    wire [103:0]                ctrl_dbg_iact_data_word_data_w;
    wire [15:0]                 ctrl_dbg_iact_data_word_index_w;
    wire                        ctrl_dbg_iact_data_seq_done_w;
    wire                        ctrl_dbg_weight_addr_word_valid_w;
    wire [20:0]                 ctrl_dbg_weight_addr_word_data_w;
    wire [15:0]                 ctrl_dbg_weight_addr_word_index_w;
    wire                        ctrl_dbg_weight_addr_seq_done_w;
    wire                        ctrl_dbg_weight_addr_stage_valid_w;
    wire [20:0]                 ctrl_dbg_weight_addr_stage_payload_w;
    wire [2:0]                  ctrl_dbg_weight_addr_stage_valid_lanes_w;
    wire [11:0]                 ctrl_dbg_weight_addr_stage_row_dst_mask_w;
    wire [15:0]                 ctrl_dbg_weight_addr_stage_index_w;
    wire                        ctrl_dbg_weight_data_word_valid_w;
    wire [71:0]                 ctrl_dbg_weight_data_word_data_w;
    wire [15:0]                 ctrl_dbg_weight_data_word_index_w;
    wire                        ctrl_dbg_weight_data_seq_done_w;
    wire                        ctrl_dbg_weight_data_stage_valid_w;
    wire [71:0]                 ctrl_dbg_weight_data_stage_payload_w;
    wire [2:0]                  ctrl_dbg_weight_data_stage_valid_lanes_w;
    wire [11:0]                 ctrl_dbg_weight_data_stage_row_dst_mask_w;
    wire [15:0]                 ctrl_dbg_weight_data_stage_index_w;

    // -------------------------------------------------------------------------------------------- //
    // BYPASS_CTRL mux: legacy external vs controller
    // -------------------------------------------------------------------------------------------- //
    assign hm_layer_mode_w       = BYPASS_CTRL_ACTIVE ? layer_mode_in       : ctrl_layer_mode_out;
    assign hm_iact_router_prio_w = BYPASS_CTRL_ACTIVE ? iact_router_prio_in : ctrl_iact_router_prio_out;

    assign hm_iact_addr_slot_valid_w = BYPASS_CTRL_ACTIVE ? iact_addr_slot_valid_in : ctrl_iact_addr_slot_valid_out;
    assign hm_iact_addr_data_w       = BYPASS_CTRL_ACTIVE ? iact_addr_data_in       : ctrl_iact_addr_data_out;
    assign hm_iact_addr_dst_mask_w   = BYPASS_CTRL_ACTIVE ? iact_addr_dst_mask_in   : ctrl_iact_addr_dst_mask_out;
    assign hm_iact_data_slot_valid_w = BYPASS_CTRL_ACTIVE ? iact_data_slot_valid_in : ctrl_iact_data_slot_valid_out;
    assign hm_iact_data_w = BYPASS_CTRL_ACTIVE ? iact_data_in : ctrl_iact_data_out;
    assign hm_iact_data_dst_mask_w = BYPASS_CTRL_ACTIVE ? iact_data_dst_mask_in : ctrl_iact_data_dst_mask_out;

    assign hm_weight_addr_valid_w        = BYPASS_CTRL_ACTIVE ? weight_addr_valid_in        : ctrl_weight_addr_valid_out;
    assign hm_weight_addr_data_w         = BYPASS_CTRL_ACTIVE ? weight_addr_in              : ctrl_weight_addr_data_out;
    assign hm_weight_addr_row_dst_mask_w = BYPASS_CTRL_ACTIVE ? weight_addr_row_dst_mask_in : ctrl_weight_addr_row_dst_mask_out;
    assign hm_weight_data_valid_w        = BYPASS_CTRL_ACTIVE ? weight_data_valid_in        : ctrl_weight_data_valid_out;
    assign hm_weight_data_w              = BYPASS_CTRL_ACTIVE ? weight_data_in              : ctrl_weight_data_out;
    assign hm_weight_data_row_dst_mask_w = BYPASS_CTRL_ACTIVE ? weight_data_row_dst_mask_in : ctrl_weight_data_row_dst_mask_out;

    assign hm_psum_col_sel_w                  = BYPASS_CTRL_ACTIVE ? psum_col_sel_in                  : ctrl_psum_col_sel_out;
    assign hm_psum_col_valid_from_router_w    = BYPASS_CTRL_ACTIVE ? psum_col_valid_from_router_in    : ctrl_psum_col_valid_from_router_out;
    assign hm_psum_col_data_from_router_w     = BYPASS_CTRL_ACTIVE ? psum_col_data_from_router_in     : ctrl_psum_col_data_from_router_out;
    assign hm_psum_col_valid_from_south_w     = BYPASS_CTRL_ACTIVE ? psum_col_valid_from_south_in     : ctrl_psum_col_valid_from_south_out;
    assign hm_psum_col_data_from_south_w     = BYPASS_CTRL_ACTIVE ? psum_col_data_from_south_in      : ctrl_psum_col_data_from_south_out;

    assign hm_pe_disable_w             = BYPASS_CTRL_ACTIVE ? pe_disable_in             : ctrl_pe_disable_out;
    assign hm_psum_enq_en_w            = BYPASS_CTRL_ACTIVE ? psum_enq_en_in            : ctrl_psum_enq_en_out;
    assign hm_do_load_en_w             = BYPASS_CTRL_ACTIVE ? do_load_en_in             : ctrl_do_load_en_out;
    // Production MAC pulse: from TB/top until Dataflow_Controller drives ctrl_do_mac_en_out.
    assign hm_do_mac_en_w              = BYPASS_CTRL_ACTIVE ? do_mac_en_in              : ctrl_do_mac_en_out;
    assign hm_iact_write_fin_clear_w   = BYPASS_CTRL_ACTIVE ? iact_write_fin_clear_in   : ctrl_iact_write_fin_clear_out;
    assign hm_weight_write_fin_clear_w = BYPASS_CTRL_ACTIVE ? weight_write_fin_clear_in : ctrl_weight_write_fin_clear_out;
    assign hm_psum_depth_w             = BYPASS_CTRL_ACTIVE ? psum_depth_in             : ctrl_psum_depth_out;
    assign hm_psum_spad_clear_w        = BYPASS_CTRL_ACTIVE ? psum_spad_clear_in        : ctrl_psum_spad_clear_out;

    assign hm_ctrl_cfg_window_size_w      = BYPASS_CTRL_ACTIVE ? ctrl_cfg_window_size_in      : ctrl_cfg_window_size_out;
    assign hm_ctrl_cfg_segment_len_w      = BYPASS_CTRL_ACTIVE ? ctrl_cfg_segment_len_in      : ctrl_cfg_segment_len_out;
    assign hm_ctrl_cfg_window_seg_count_w = BYPASS_CTRL_ACTIVE ? ctrl_cfg_window_seg_count_in : ctrl_cfg_window_seg_count_out;
    assign hm_ctrl_cfg_psum_base_w        = BYPASS_CTRL_ACTIVE ? ctrl_cfg_psum_base_in        : ctrl_cfg_psum_base_out;
    assign hm_ctrl_cfg_m0_w               = BYPASS_CTRL_ACTIVE ? ctrl_cfg_m0_in               : ctrl_cfg_m0_out;
    assign hm_ctrl_cfg_iact_flush_w       = BYPASS_CTRL_ACTIVE ? ctrl_cfg_iact_flush_in       : ctrl_cfg_iact_flush_out;
    assign hm_ctrl_cfg_slide_commit_w     = BYPASS_CTRL_ACTIVE ? ctrl_cfg_slide_commit_in     : ctrl_cfg_slide_commit_out;

    assign hm_pool_cmp_en_w     = BYPASS_CTRL_ACTIVE ? pool_cmp_en_in     : ctrl_pool_cmp_en_out;
    assign hm_pool_cmp_stop_w   = BYPASS_CTRL_ACTIVE ? pool_cmp_stop_in   : ctrl_pool_cmp_stop_out;
    assign hm_pool_elem_valid_w = BYPASS_CTRL_ACTIVE ? pool_elem_valid_in : ctrl_pool_elem_valid_out;
    assign hm_pool_elem_data_w  = BYPASS_CTRL_ACTIVE ? pool_elem_data_in  : ctrl_pool_elem_data_out;
    assign hm_pool_win_first_w  = BYPASS_CTRL_ACTIVE ? pool_win_first_in  : ctrl_pool_win_first_out;
    assign hm_pool_win_last_w   = BYPASS_CTRL_ACTIVE ? pool_win_last_in   : ctrl_pool_win_last_out;

    assign ctrl_job_busy_out  = BYPASS_CTRL_ACTIVE ? 1'b0 : ctrl_job_busy_w;
    assign ctrl_job_done_out  = BYPASS_CTRL_ACTIVE ? 1'b0 : ctrl_job_done_w;
    assign ctrl_job_error_out = BYPASS_CTRL_ACTIVE ? 1'b0 : ctrl_job_error_w;
    assign ctrl_state_dbg_out = BYPASS_CTRL_ACTIVE ? 5'b0 : ctrl_state_dbg_w;

    PE_Cluster3x4_Dataflow_Controller u_dataflow_ctrl (
        .clk(clk),
        .rst(rst),
        .ctrl_job_start_in(ctrl_job_start_in),
        .ctrl_job_abort_in(ctrl_job_abort_in),
        .ctrl_exec_mode_in(ctrl_exec_mode_in),
        .ctrl_pe_mask_in(ctrl_pe_mask_in),
        .ctrl_job_busy_out(ctrl_job_busy_w),
        .ctrl_job_done_out(ctrl_job_done_w),
        .ctrl_job_error_out(ctrl_job_error_w),
        .ctrl_state_dbg_out(ctrl_state_dbg_w),
        .ctrl_dbg_iact_addr_word_valid_out(ctrl_dbg_iact_addr_word_valid_w),
        .ctrl_dbg_iact_addr_word_ready_in(1'b1),
        .ctrl_dbg_iact_addr_word_data_out(ctrl_dbg_iact_addr_word_data_w),
        .ctrl_dbg_iact_addr_word_index_out(ctrl_dbg_iact_addr_word_index_w),
        .ctrl_dbg_iact_addr_seq_done_out(ctrl_dbg_iact_addr_seq_done_w),
        .ctrl_dbg_iact_addr_stage_valid_out(),
        .ctrl_dbg_iact_addr_stage_ready_in(1'b1),
        .ctrl_dbg_iact_addr_stage_payload_out(),
        .ctrl_dbg_iact_addr_stage_slot_valid_out(),
        .ctrl_dbg_iact_addr_stage_dst_mask_out(),
        .ctrl_dbg_iact_addr_stage_index_out(),
        .ctrl_dbg_iact_data_word_valid_out(ctrl_dbg_iact_data_word_valid_w),
        .ctrl_dbg_iact_data_word_ready_in(1'b1),
        .ctrl_dbg_iact_data_word_data_out(ctrl_dbg_iact_data_word_data_w),
        .ctrl_dbg_iact_data_word_index_out(ctrl_dbg_iact_data_word_index_w),
        .ctrl_dbg_iact_data_seq_done_out(ctrl_dbg_iact_data_seq_done_w),
        .ctrl_dbg_iact_data_stage_valid_out(),
        .ctrl_dbg_iact_data_stage_ready_in(1'b1),
        .ctrl_dbg_iact_data_stage_payload_out(),
        .ctrl_dbg_iact_data_stage_slot_valid_out(),
        .ctrl_dbg_iact_data_stage_dst_mask_out(),
        .ctrl_dbg_iact_data_stage_index_out(),
        .ctrl_dbg_weight_addr_word_valid_out(ctrl_dbg_weight_addr_word_valid_w),
        .ctrl_dbg_weight_addr_word_ready_in(1'b1),
        .ctrl_dbg_weight_addr_word_data_out(ctrl_dbg_weight_addr_word_data_w),
        .ctrl_dbg_weight_addr_word_index_out(ctrl_dbg_weight_addr_word_index_w),
        .ctrl_dbg_weight_addr_seq_done_out(ctrl_dbg_weight_addr_seq_done_w),
        .ctrl_dbg_weight_addr_stage_valid_out(ctrl_dbg_weight_addr_stage_valid_w),
        .ctrl_dbg_weight_addr_stage_ready_in(1'b1),
        .ctrl_dbg_weight_addr_stage_payload_out(ctrl_dbg_weight_addr_stage_payload_w),
        .ctrl_dbg_weight_addr_stage_valid_lanes_out(ctrl_dbg_weight_addr_stage_valid_lanes_w),
        .ctrl_dbg_weight_addr_stage_row_dst_mask_out(ctrl_dbg_weight_addr_stage_row_dst_mask_w),
        .ctrl_dbg_weight_addr_stage_index_out(ctrl_dbg_weight_addr_stage_index_w),
        .ctrl_dbg_weight_data_word_valid_out(ctrl_dbg_weight_data_word_valid_w),
        .ctrl_dbg_weight_data_word_ready_in(1'b1),
        .ctrl_dbg_weight_data_word_data_out(ctrl_dbg_weight_data_word_data_w),
        .ctrl_dbg_weight_data_word_index_out(ctrl_dbg_weight_data_word_index_w),
        .ctrl_dbg_weight_data_seq_done_out(ctrl_dbg_weight_data_seq_done_w),
        .ctrl_dbg_weight_data_stage_valid_out(ctrl_dbg_weight_data_stage_valid_w),
        .ctrl_dbg_weight_data_stage_ready_in(1'b1),
        .ctrl_dbg_weight_data_stage_payload_out(ctrl_dbg_weight_data_stage_payload_w),
        .ctrl_dbg_weight_data_stage_valid_lanes_out(ctrl_dbg_weight_data_stage_valid_lanes_w),
        .ctrl_dbg_weight_data_stage_row_dst_mask_out(ctrl_dbg_weight_data_stage_row_dst_mask_w),
        .ctrl_dbg_weight_data_stage_index_out(ctrl_dbg_weight_data_stage_index_w),
        .desc_valid_in(ctrl_job_start_in),
        .desc_ready_out(ctrl_desc_ready_w),
        .desc_kernel_h_in(desc_kernel_h_in),
        .desc_kernel_w_in(desc_kernel_w_in),
        .desc_stride_h_in(desc_stride_h_in),
        .desc_stride_w_in(desc_stride_w_in),
        .desc_c_in_in(desc_c_in_in),
        .desc_m_out_in(desc_m_out_in),
        .desc_active_pe_mask_in(ctrl_pe_mask_in),
        .desc_output_window_count_in(desc_output_window_count_in),
        .desc_append_segment_count_in(desc_append_segment_count_in),
        .desc_iact_addr_base_in(desc_iact_addr_base_in),
        .desc_iact_addr_word_count_in(desc_iact_addr_word_count_in),
        .desc_iact_data_base_in(desc_iact_data_base_in),
        .desc_iact_data_word_count_in(desc_iact_data_word_count_in),
        .desc_iact_append_addr_base_in(desc_iact_append_addr_base_in),
        .desc_iact_append_addr_word_count_in(desc_iact_append_addr_word_count_in),
        .desc_iact_append_data_base_in(desc_iact_append_data_base_in),
        .desc_iact_append_data_word_count_in(desc_iact_append_data_word_count_in),
        .desc_weight_addr_base_in(desc_weight_addr_base_in),
        .desc_weight_addr_word_count_in(desc_weight_addr_word_count_in),
        .desc_weight_data_base_in(desc_weight_data_base_in),
        .desc_weight_data_word_count_in(desc_weight_data_word_count_in),
        .desc_weight_compute_buf_sel_in(desc_weight_compute_buf_sel_in),
        .desc_psum_read_base_in(desc_psum_read_base_in),
        .desc_psum_write_base_in(desc_psum_write_base_in),
        .desc_psum_count_in(desc_psum_count_in),
        .desc_psum_depth_in(desc_psum_depth_in),
        .desc_psum_base_in(desc_psum_base_in),
        .desc_m0_in(desc_m0_in),
        .glb_iact_addr_rd_valid_out(glb_iact_addr_rd_valid_out),
        .glb_iact_addr_rd_ready_in(glb_iact_addr_rd_ready_in),
        .glb_iact_addr_rd_addr_out(glb_iact_addr_rd_addr_out),
        .glb_iact_addr_resp_valid_in(glb_iact_addr_resp_valid_in),
        .glb_iact_addr_resp_ready_out(glb_iact_addr_resp_ready_out),
        .glb_iact_addr_resp_data_in(glb_iact_addr_resp_data_in),
        .glb_iact_data_rd_valid_out(glb_iact_data_rd_valid_out),
        .glb_iact_data_rd_ready_in(glb_iact_data_rd_ready_in),
        .glb_iact_data_rd_addr_out(glb_iact_data_rd_addr_out),
        .glb_iact_data_resp_valid_in(glb_iact_data_resp_valid_in),
        .glb_iact_data_resp_ready_out(glb_iact_data_resp_ready_out),
        .glb_iact_data_resp_data_in(glb_iact_data_resp_data_in),
        .glb_weight_addr_rd_valid_out(glb_weight_addr_rd_valid_out),
        .glb_weight_addr_rd_ready_in(glb_weight_addr_rd_ready_in),
        .glb_weight_addr_rd_addr_out(glb_weight_addr_rd_addr_out),
        .glb_weight_addr_resp_valid_in(glb_weight_addr_resp_valid_in),
        .glb_weight_addr_resp_ready_out(glb_weight_addr_resp_ready_out),
        .glb_weight_addr_resp_data_in(glb_weight_addr_resp_data_in),
        .glb_weight_data_rd_valid_out(glb_weight_data_rd_valid_out),
        .glb_weight_data_rd_ready_in(glb_weight_data_rd_ready_in),
        .glb_weight_data_rd_addr_out(glb_weight_data_rd_addr_out),
        .glb_weight_data_resp_valid_in(glb_weight_data_resp_valid_in),
        .glb_weight_data_resp_ready_out(glb_weight_data_resp_ready_out),
        .glb_weight_data_resp_data_in(glb_weight_data_resp_data_in),
        .hm_all_write_fin_in(all_write_fin_out),
        .hm_all_cal_fin_in(all_cal_fin_out),
        .hm_pe_iact_addr_write_fin_in(pe_iact_addr_write_fin_out),
        .hm_pe_iact_data_write_fin_in(pe_iact_data_write_fin_out),
        .hm_pe_weight_addr_write_fin_in(pe_weight_addr_write_fin_out),
        .hm_pe_weight_data_write_fin_in(pe_weight_data_write_fin_out),
        .hm_pe_slide_safe_in(pe_slide_safe_out),
        .hm_pe_cal_fin_in(pe_cal_fin_out),
        .hm_pe_psum_acc_fin_in(pe_psum_acc_fin_out),
        .hm_iact_addr_ready_in(iact_addr_slot_ready_out),
        .hm_iact_data_ready_in(iact_data_slot_ready_out),
        .hm_weight_addr_ready_in(hm_weight_addr_ready_w),
        .hm_weight_data_ready_in(hm_weight_data_ready_w),
        .hm_psum_col_ready_from_router_in(psum_col_ready_from_router_out),
        .hm_psum_col_ready_from_south_in(psum_col_ready_from_south_out),
        .hm_psum_col_valid_in(psum_col_valid_out),
        .hm_psum_col_ready_in(psum_col_ready_in),
        .ctrl_layer_mode_out(ctrl_layer_mode_out),
        .ctrl_iact_router_prio_out(ctrl_iact_router_prio_out),
        .ctrl_iact_addr_slot_valid_out(ctrl_iact_addr_slot_valid_out),
        .ctrl_iact_addr_data_out(ctrl_iact_addr_data_out),
        .ctrl_iact_addr_dst_mask_out(ctrl_iact_addr_dst_mask_out),
        .ctrl_iact_data_slot_valid_out(ctrl_iact_data_slot_valid_out),
        .ctrl_iact_data_out(ctrl_iact_data_out),
        .ctrl_iact_data_dst_mask_out(ctrl_iact_data_dst_mask_out),
        .ctrl_weight_addr_valid_out(ctrl_weight_addr_valid_out),
        .ctrl_weight_addr_data_out(ctrl_weight_addr_data_out),
        .ctrl_weight_addr_row_dst_mask_out(ctrl_weight_addr_row_dst_mask_out),
        .ctrl_weight_data_valid_out(ctrl_weight_data_valid_out),
        .ctrl_weight_data_out(ctrl_weight_data_out),
        .ctrl_weight_data_row_dst_mask_out(ctrl_weight_data_row_dst_mask_out),
        .ctrl_psum_col_sel_out(ctrl_psum_col_sel_out),
        .ctrl_psum_col_valid_from_router_out(ctrl_psum_col_valid_from_router_out),
        .ctrl_psum_col_data_from_router_out(ctrl_psum_col_data_from_router_out),
        .ctrl_psum_col_valid_from_south_out(ctrl_psum_col_valid_from_south_out),
        .ctrl_psum_col_data_from_south_out(ctrl_psum_col_data_from_south_out),
        .ctrl_pe_disable_out(ctrl_pe_disable_out),
        .ctrl_psum_enq_en_out(ctrl_psum_enq_en_out),
        .ctrl_do_load_en_out(ctrl_do_load_en_out),
        .ctrl_do_mac_en_out(ctrl_do_mac_en_out),
        .ctrl_iact_write_fin_clear_out(ctrl_iact_write_fin_clear_out),
        .ctrl_weight_write_fin_clear_out(ctrl_weight_write_fin_clear_out),
        .ctrl_psum_depth_out(ctrl_psum_depth_out),
        .ctrl_psum_spad_clear_out(ctrl_psum_spad_clear_out),
        .ctrl_cfg_window_size_out(ctrl_cfg_window_size_out),
        .ctrl_cfg_segment_len_out(ctrl_cfg_segment_len_out),
        .ctrl_cfg_window_seg_count_out(ctrl_cfg_window_seg_count_out),
        .ctrl_cfg_psum_base_out(ctrl_cfg_psum_base_out),
        .ctrl_cfg_m0_out(ctrl_cfg_m0_out),
        .ctrl_cfg_iact_flush_out(ctrl_cfg_iact_flush_out),
        .ctrl_cfg_slide_commit_out(ctrl_cfg_slide_commit_out),
        .ctrl_pool_cmp_en_out(ctrl_pool_cmp_en_out),
        .ctrl_pool_cmp_stop_out(ctrl_pool_cmp_stop_out),
        .ctrl_pool_elem_valid_out(ctrl_pool_elem_valid_out),
        .ctrl_pool_elem_data_out(ctrl_pool_elem_data_out),
        .ctrl_pool_win_first_out(ctrl_pool_win_first_out),
        .ctrl_pool_win_last_out(ctrl_pool_win_last_out)
    );

    PE_Cluster3x4_HMesh u_hmesh (
        .clk(clk),
        .rst(rst),
        .layer_mode_in(hm_layer_mode_w),
        .iact_router_prio_in(hm_iact_router_prio_w),
        .iact_addr_slot_valid_in(hm_iact_addr_slot_valid_w),
        .iact_addr_slot_ready_out(iact_addr_slot_ready_out),
        .iact_addr_data_in(hm_iact_addr_data_w),
        .iact_addr_dst_mask_in(hm_iact_addr_dst_mask_w),
        .iact_data_slot_valid_in(hm_iact_data_slot_valid_w),
        .iact_data_slot_ready_out(iact_data_slot_ready_out),
        .iact_data_in(hm_iact_data_w),
        .iact_data_dst_mask_in(hm_iact_data_dst_mask_w),
        .weight_addr_valid_in(hm_weight_addr_valid_w),
        .weight_addr_ready_out(hm_weight_addr_ready_w),
        .weight_addr_in(hm_weight_addr_data_w),
        .weight_addr_row_dst_mask_in(hm_weight_addr_row_dst_mask_w),
        .weight_data_valid_in(hm_weight_data_valid_w),
        .weight_data_ready_out(hm_weight_data_ready_w),
        .weight_data_in(hm_weight_data_w),
        .weight_data_row_dst_mask_in(hm_weight_data_row_dst_mask_w),
        .psum_col_sel_in(hm_psum_col_sel_w),
        .psum_col_valid_from_router_in(hm_psum_col_valid_from_router_w),
        .psum_col_ready_from_router_out(psum_col_ready_from_router_out),
        .psum_col_data_from_router_in(hm_psum_col_data_from_router_w),
        .psum_col_valid_from_south_in(hm_psum_col_valid_from_south_w),
        .psum_col_ready_from_south_out(psum_col_ready_from_south_out),
        .psum_col_data_from_south_in(hm_psum_col_data_from_south_w),
        .psum_col_valid_out(psum_col_valid_out),
        .psum_col_ready_in(psum_col_ready_in),
        .psum_col_data_out(psum_col_data_out),
        .pe_disable_in(hm_pe_disable_w),
        .psum_enq_en_in(hm_psum_enq_en_w),
        .do_load_en_in(hm_do_load_en_w),
        .do_mac_en_in(hm_do_mac_en_w),
        .iact_write_fin_clear_in(hm_iact_write_fin_clear_w),
        .weight_write_fin_clear_in(hm_weight_write_fin_clear_w),
        .psum_depth_in(hm_psum_depth_w),
        .psum_spad_clear_in(hm_psum_spad_clear_w),
        .all_write_fin_out(all_write_fin_out),
        .all_cal_fin_out(all_cal_fin_out),
        .ctrl_cfg_window_size_in(hm_ctrl_cfg_window_size_w),
        .ctrl_cfg_segment_len_in(hm_ctrl_cfg_segment_len_w),
        .ctrl_cfg_window_seg_count_in(hm_ctrl_cfg_window_seg_count_w),
        .ctrl_cfg_psum_base_in(hm_ctrl_cfg_psum_base_w),
        .ctrl_cfg_m0_in(hm_ctrl_cfg_m0_w),
        .ctrl_cfg_iact_flush_in(hm_ctrl_cfg_iact_flush_w),
        .ctrl_cfg_slide_commit_in(hm_ctrl_cfg_slide_commit_w),
        .pool_cmp_en_in(hm_pool_cmp_en_w),
        .pool_cmp_stop_in(hm_pool_cmp_stop_w),
        .pool_elem_valid_in(hm_pool_elem_valid_w),
        .pool_elem_ready_out(pool_elem_ready_out),
        .pool_elem_data_in(hm_pool_elem_data_w),
        .pool_win_first_in(hm_pool_win_first_w),
        .pool_win_last_in(hm_pool_win_last_w),
        .pool_out_valid_out(pool_out_valid_out),
        .pool_out_ready_in(pool_out_ready_in),
        .pool_out_data_out(pool_out_data_out),
        .pe_iact_addr_valid_out(pe_iact_addr_valid_out),
        .pe_iact_addr_ready_out(pe_iact_addr_ready_out),
        .pe_iact_addr_data_out(pe_iact_addr_data_out),
        .pe_iact_data_valid_out(pe_iact_data_valid_out),
        .pe_iact_data_ready_out(pe_iact_data_ready_out),
        .pe_iact_data_out(pe_iact_data_out),
        .pe_weight_addr_valid_out(pe_weight_addr_valid_out),
        .pe_weight_addr_ready_out(pe_weight_addr_ready_out),
        .pe_weight_addr_data_out(pe_weight_addr_data_out),
        .pe_weight_data_valid_out(pe_weight_data_valid_out),
        .pe_weight_data_ready_out(pe_weight_data_ready_out),
        .pe_weight_data_out(pe_weight_data_out),
        .pe_psum_router_ready_out(pe_psum_router_ready_out),
        .pe_psum_in_valid_out(pe_psum_in_valid_out),
        .pe_psum_in_ready_out(pe_psum_in_ready_out),
        .pe_psum_in_data_out(pe_psum_in_data_out),
        .pe_psum_out_valid_out(pe_psum_out_valid_out),
        .pe_psum_out_ready_out(pe_psum_out_ready_out),
        .pe_psum_out_data_out(pe_psum_out_data_out),
        .pe_iact_addr_write_fin_out(pe_iact_addr_write_fin_out),
        .pe_iact_data_write_fin_out(pe_iact_data_write_fin_out),
        .pe_weight_addr_write_fin_out(pe_weight_addr_write_fin_out),
        .pe_weight_data_write_fin_out(pe_weight_data_write_fin_out),
        .pe_psum_acc_fin_out(pe_psum_acc_fin_out),
        .pe_slide_safe_out(pe_slide_safe_out),
        .pe_all_write_fin_out(pe_all_write_fin_out),
        .pe_cal_fin_out(pe_cal_fin_out),
        .pe_load_en_out(pe_load_en_out),
        .pe_write_fin_sticky_out(pe_write_fin_sticky_out),
        .pe_cal_fin_sticky_out(pe_cal_fin_sticky_out)
    );

endmodule
