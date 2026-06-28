// ============================================================================
// Module      : PE_Cluster3x4_Top
// Author      : Do Quoc Khanh
// Description : Top-level wrapper for one 3x4 PE cluster.
//               Instantiates the Dataflow Controller and local HMesh/PE array.
//               The controller owns native ingress emission, scheduling metadata,
//               slide/MAC control, and PSUM drain coordination for the cluster.
// ============================================================================

module PE_Cluster3x4_Top #(
    parameter integer GLB_AW = 8,
    parameter integer ENABLE_POOL = 1
) (
    input  wire                        clk,
    input  wire                        rst,

    // -------------------------------------------------------------------------------------------- //
    // Controller job interface
    // -------------------------------------------------------------------------------------------- //
    input  wire                        ctrl_job_start_in,
    input  wire                        ctrl_job_abort_in,
    output wire                        ctrl_job_busy_out,
    output wire                        ctrl_job_done_out,
    output wire                        ctrl_job_error_out,

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
    input  wire                        desc_weight_load_en_in,
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
    input  wire [29:0]                 glb_iact_addr_resp_data_in,

    output wire                        glb_iact_data_rd_valid_out,
    input  wire                        glb_iact_data_rd_ready_in,
    output wire [GLB_AW-1:0]           glb_iact_data_rd_addr_out,
    input  wire                        glb_iact_data_resp_valid_in,
    output wire                        glb_iact_data_resp_ready_out,
    input  wire [71:0]                 glb_iact_data_resp_data_in,

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

    output wire                        glb_psum_wr_valid_out,
    input  wire                        glb_psum_wr_ready_in,
    output wire [GLB_AW-1:0]           glb_psum_wr_addr_out,
    output wire [167:0]                glb_psum_wr_data_out,
    output wire                        glb_psum_rd_valid_out,
    input  wire                        glb_psum_rd_ready_in,
    output wire [GLB_AW-1:0]           glb_psum_rd_addr_out,
    input  wire                        glb_psum_rd_resp_valid_in,
    output wire                        glb_psum_rd_resp_ready_out,
    input  wire [167:0]                glb_psum_rd_resp_data_in,

    // PSUM result stream observability
    output wire [3:0]                  psum_col_valid_out,
    output wire signed [167:0]         psum_col_data_out,

    // -------------------------------------------------------------------------------------------- //
    // Router Cluster boundary
    // -------------------------------------------------------------------------------------------- //
    output wire [5:0]                  router_iact_data_in_sel_out,
    output wire [8:0]                  router_iact_route_mask_out,
    output wire [2:0]                  router_weight_data_in_sel_out,
    output wire [2:0]                  router_weight_route_horizontal_out,
    output wire [3:0]                  router_psum_data_in_sel_out,
    output wire [3:0]                  router_psum_route_to_pe_out,

    output wire [5:0]                  router_local_iact_addr_valid_out,
    input  wire [5:0]                  router_local_iact_addr_ready_in,
    output wire [29:0]                 router_local_iact_addr_data_out,
    output wire [5:0]                  router_local_iact_data_valid_out,
    input  wire [5:0]                  router_local_iact_data_ready_in,
    output wire [71:0]                 router_local_iact_data_out,
    input  wire [5:0]                  router_pe_iact_addr_valid_in,
    output wire [5:0]                  router_pe_iact_addr_ready_out,
    input  wire [29:0]                 router_pe_iact_addr_data_in,
    input  wire [5:0]                  router_pe_iact_data_valid_in,
    output wire [5:0]                  router_pe_iact_data_ready_out,
    input  wire [71:0]                 router_pe_iact_data_in,

    output wire [2:0]                  router_local_weight_addr_valid_out,
    input  wire [2:0]                  router_local_weight_addr_ready_in,
    output wire [20:0]                 router_local_weight_addr_data_out,
    output wire [2:0]                  router_local_weight_data_valid_out,
    input  wire [2:0]                  router_local_weight_data_ready_in,
    output wire [71:0]                 router_local_weight_data_out,
    input  wire [2:0]                  router_pe_weight_addr_valid_in,
    output wire [2:0]                  router_pe_weight_addr_ready_out,
    input  wire [20:0]                 router_pe_weight_addr_data_in,
    input  wire [2:0]                  router_pe_weight_data_valid_in,
    output wire [2:0]                  router_pe_weight_data_ready_out,
    input  wire [71:0]                 router_pe_weight_data_in,

    output wire [3:0]                  router_pe_psum_return_valid_out,
    input  wire [3:0]                  router_pe_psum_return_ready_in,
    output wire signed [167:0]         router_pe_psum_return_data_out,
    input  wire [3:0]                  router_local_psum_return_valid_in,
    output wire [3:0]                  router_local_psum_return_ready_out,
    input  wire signed [167:0]         router_local_psum_return_data_in,
    output wire [3:0]                  router_local_psum_forward_valid_out,
    input  wire [3:0]                  router_local_psum_forward_ready_in,
    output wire signed [167:0]         router_local_psum_forward_data_out,
    output wire [3:0]                  router_north_psum_forward_valid_out,
    input  wire [3:0]                  router_north_psum_forward_ready_in,
    output wire signed [167:0]         router_north_psum_forward_data_out,
    input  wire [3:0]                  router_pe_psum_forward_valid_in,
    output wire [3:0]                  router_pe_psum_forward_ready_out,
    input  wire signed [167:0]         router_pe_psum_forward_data_in,

    // -------------------------------------------------------------------------------------------- //
    // Observability (passthrough from HMesh)
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
    // -------------------------------------------------------------------------------------------- //
    // Controller -> HMesh drive
    // -------------------------------------------------------------------------------------------- //
    wire [5:0]                  hm_iact_addr_slot_valid_w;
    wire [5:0]                  hm_iact_addr_slot_ready_w;
    wire [29:0]                 hm_iact_addr_data_w;
    wire [71:0]                 hm_iact_addr_dst_mask_w;
    wire [5:0]                  hm_iact_data_slot_valid_w;
    wire [5:0]                  hm_iact_data_slot_ready_w;
    wire [71:0]                 hm_iact_data_w;
    wire [71:0]                 hm_iact_data_dst_mask_w;

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
    wire signed [167:0]         hm_psum_col_data_from_router_w;
    wire [3:0]                  hm_psum_col_valid_from_south_w;
    wire signed [167:0]         hm_psum_col_data_from_south_w;
    wire [3:0]                  hm_psum_col_ready_from_router_w;
    wire [3:0]                  hm_psum_col_ready_from_south_w;
    wire [3:0]                  hm_psum_col_valid_raw_w;
    wire [3:0]                  hm_psum_col_ready_raw_w;
    wire signed [167:0]         hm_psum_col_data_raw_w;

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

    // Controller outputs
    wire [5:0]                  ctrl_iact_addr_slot_valid_out;
    wire [29:0]                 ctrl_iact_addr_data_out;
    wire [71:0]                 ctrl_iact_addr_dst_mask_out;
    wire [5:0]                  ctrl_iact_data_slot_valid_out;
    wire [71:0]                 ctrl_iact_data_out;
    wire [71:0]                 ctrl_iact_data_dst_mask_out;
    wire [2:0]                  ctrl_weight_addr_valid_out;
    wire [20:0]                 ctrl_weight_addr_data_out;
    wire [11:0]                 ctrl_weight_addr_row_dst_mask_out;
    wire [2:0]                  ctrl_weight_data_valid_out;
    wire [71:0]                 ctrl_weight_data_out;
    wire [11:0]                 ctrl_weight_data_row_dst_mask_out;
    wire                        ctrl_psum_col_sel_out;
    wire [3:0]                  ctrl_psum_col_valid_from_router_out;
    wire signed [167:0]         ctrl_psum_col_data_from_router_out;
    wire [3:0]                  ctrl_psum_col_valid_from_south_out;
    wire signed [167:0]         ctrl_psum_col_data_from_south_out;
    wire                        ctrl_glb_psum_wr_valid_w;
    wire [GLB_AW-1:0]           ctrl_glb_psum_wr_addr_w;
    wire [167:0]                ctrl_glb_psum_wr_data_w;
    wire                        ctrl_glb_psum_rd_valid_w;
    wire [GLB_AW-1:0]           ctrl_glb_psum_rd_addr_w;
    wire                        ctrl_glb_psum_rd_resp_ready_w;
    wire                        ctrl_psum_col_sink_ready_w;
    wire                        ctrl_psum_col_capture_ready_w;
    wire [3:0]                  ctrl_psum_return_ready_w;
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
    wire                        ctrl_job_busy_w;
    wire                        ctrl_job_done_w;
    wire                        ctrl_job_error_w;
    wire                        ctrl_desc_ready_w;

    // -------------------------------------------------------------------------------------------- //
    // Production Top has one controller-owned native-ingress path.
    // -------------------------------------------------------------------------------------------- //
    assign hm_iact_addr_slot_valid_w = router_pe_iact_addr_valid_in;
    assign hm_iact_addr_data_w       = router_pe_iact_addr_data_in;
    assign hm_iact_addr_dst_mask_w   = ctrl_iact_addr_dst_mask_out;
    assign hm_iact_data_slot_valid_w = router_pe_iact_data_valid_in;
    assign hm_iact_data_w            = router_pe_iact_data_in;
    assign hm_iact_data_dst_mask_w   = ctrl_iact_data_dst_mask_out;
    assign hm_weight_addr_valid_w    = router_pe_weight_addr_valid_in;
    assign hm_weight_addr_data_w     = router_pe_weight_addr_data_in;
    assign hm_weight_addr_row_dst_mask_w = ctrl_weight_addr_row_dst_mask_out;
    assign hm_weight_data_valid_w    = router_pe_weight_data_valid_in;
    assign hm_weight_data_w          = router_pe_weight_data_in;
    assign hm_weight_data_row_dst_mask_w = ctrl_weight_data_row_dst_mask_out;
    assign hm_psum_col_sel_w               = 1'b0;
    assign hm_psum_col_valid_from_router_w = 4'b0;
    assign hm_psum_col_data_from_router_w  = 168'b0;
    assign hm_psum_col_valid_from_south_w  = router_pe_psum_forward_valid_in;
    assign hm_psum_col_data_from_south_w   = router_pe_psum_forward_data_in;
    assign hm_pe_disable_w             = ctrl_pe_disable_out;
    assign hm_psum_enq_en_w            = ctrl_psum_enq_en_out;
    assign hm_do_load_en_w             = ctrl_do_load_en_out;
    assign hm_do_mac_en_w              = ctrl_do_mac_en_out;
    assign hm_iact_write_fin_clear_w   = ctrl_iact_write_fin_clear_out;
    assign hm_weight_write_fin_clear_w = ctrl_weight_write_fin_clear_out;
    assign hm_psum_depth_w             = ctrl_psum_depth_out;
    assign hm_psum_spad_clear_w        = ctrl_psum_spad_clear_out;
    assign hm_ctrl_cfg_window_size_w      = ctrl_cfg_window_size_out;
    assign hm_ctrl_cfg_segment_len_w      = ctrl_cfg_segment_len_out;
    assign hm_ctrl_cfg_window_seg_count_w = ctrl_cfg_window_seg_count_out;
    assign hm_ctrl_cfg_psum_base_w        = ctrl_cfg_psum_base_out;
    assign hm_ctrl_cfg_m0_w               = ctrl_cfg_m0_out;
    assign hm_ctrl_cfg_iact_flush_w       = ctrl_cfg_iact_flush_out;
    assign hm_ctrl_cfg_slide_commit_w     = ctrl_cfg_slide_commit_out;
    assign ctrl_job_busy_out  = ctrl_job_busy_w;
    assign ctrl_job_done_out  = ctrl_job_done_w;
    assign ctrl_job_error_out = ctrl_job_error_w;
    assign glb_psum_wr_valid_out = ctrl_glb_psum_wr_valid_w;
    assign glb_psum_wr_addr_out = ctrl_glb_psum_wr_addr_w;
    assign glb_psum_wr_data_out = ctrl_glb_psum_wr_data_w;
    assign glb_psum_rd_valid_out = ctrl_glb_psum_rd_valid_w;
    assign glb_psum_rd_addr_out = ctrl_glb_psum_rd_addr_w;
    assign glb_psum_rd_resp_ready_out = ctrl_glb_psum_rd_resp_ready_w;
    assign ctrl_psum_return_ready_w =
        {4{ctrl_psum_col_capture_ready_w ||
            ctrl_psum_col_sink_ready_w}};

    assign router_iact_data_in_sel_out = 6'b0;
    assign router_iact_route_mask_out = 9'b0;
    assign router_weight_data_in_sel_out = 3'b0;
    assign router_weight_route_horizontal_out = 3'b0;
    assign router_psum_data_in_sel_out = {4{ctrl_psum_col_sel_out}};
    assign router_psum_route_to_pe_out = 4'hf;

    assign router_local_iact_addr_valid_out = ctrl_iact_addr_slot_valid_out;
    assign router_local_iact_addr_data_out = ctrl_iact_addr_data_out;
    assign router_local_iact_data_valid_out = ctrl_iact_data_slot_valid_out;
    assign router_local_iact_data_out = ctrl_iact_data_out;
    assign router_pe_iact_addr_ready_out = hm_iact_addr_slot_ready_w;
    assign router_pe_iact_data_ready_out = hm_iact_data_slot_ready_w;

    assign router_local_weight_addr_valid_out = ctrl_weight_addr_valid_out;
    assign router_local_weight_addr_data_out = ctrl_weight_addr_data_out;
    assign router_local_weight_data_valid_out = ctrl_weight_data_valid_out;
    assign router_local_weight_data_out = ctrl_weight_data_out;
    assign router_pe_weight_addr_ready_out = hm_weight_addr_ready_w;
    assign router_pe_weight_data_ready_out = hm_weight_data_ready_w;

    assign router_pe_psum_return_valid_out = hm_psum_col_valid_raw_w;
    assign router_pe_psum_return_data_out = hm_psum_col_data_raw_w;
    assign hm_psum_col_ready_raw_w = router_pe_psum_return_ready_in;
    assign router_local_psum_return_ready_out = ctrl_psum_return_ready_w;
    assign router_local_psum_forward_valid_out = ctrl_psum_col_valid_from_router_out;
    assign router_local_psum_forward_data_out = ctrl_psum_col_data_from_router_out;
    assign router_north_psum_forward_valid_out = ctrl_psum_col_valid_from_south_out;
    assign router_north_psum_forward_data_out = ctrl_psum_col_data_from_south_out;
    assign router_pe_psum_forward_ready_out = hm_psum_col_ready_from_south_w;
    assign psum_col_valid_out = router_local_psum_return_valid_in;
    assign psum_col_data_out = router_local_psum_return_data_in;

    PE_Cluster3x4_Dataflow_Controller #(
        .GLB_AW(GLB_AW)
    ) u_dataflow_ctrl (
        .clk(clk),
        .rst(rst),
        .ctrl_job_start_in(ctrl_job_start_in),
        .ctrl_job_abort_in(ctrl_job_abort_in),
        .ctrl_job_busy_out(ctrl_job_busy_w),
        .ctrl_job_done_out(ctrl_job_done_w),
        .ctrl_job_error_out(ctrl_job_error_w),
        .desc_valid_in(ctrl_job_start_in),
        .desc_ready_out(ctrl_desc_ready_w),
        .desc_kernel_h_in(desc_kernel_h_in),
        .desc_kernel_w_in(desc_kernel_w_in),
        .desc_stride_h_in(desc_stride_h_in),
        .desc_stride_w_in(desc_stride_w_in),
        .desc_c_in_in(desc_c_in_in),
        .desc_m_out_in(desc_m_out_in),
        .desc_active_pe_mask_in(desc_active_pe_mask_in),
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
        .desc_weight_load_en_in(desc_weight_load_en_in),
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
        .hm_pe_iact_addr_write_fin_in(pe_iact_addr_write_fin_out),
        .hm_pe_iact_data_write_fin_in(pe_iact_data_write_fin_out),
        .hm_pe_weight_addr_write_fin_in(pe_weight_addr_write_fin_out),
        .hm_pe_weight_data_write_fin_in(pe_weight_data_write_fin_out),
        .hm_pe_slide_safe_in(pe_slide_safe_out),
        .hm_pe_cal_fin_in(pe_cal_fin_out),
        .hm_pe_psum_acc_fin_in(pe_psum_acc_fin_out),
        .hm_iact_addr_ready_in(router_local_iact_addr_ready_in),
        .hm_iact_data_ready_in(router_local_iact_data_ready_in),
        .hm_weight_addr_ready_in(router_local_weight_addr_ready_in),
        .hm_weight_data_ready_in(router_local_weight_data_ready_in),
        .hm_psum_col_ready_from_south_in(router_north_psum_forward_ready_in),
        .hm_psum_col_valid_in(psum_col_valid_out),
        .hm_psum_col_ready_in(ctrl_psum_return_ready_w),
        .hm_psum_col_data_in(psum_col_data_out),
        .glb_psum_wr_valid_out(ctrl_glb_psum_wr_valid_w),
        .glb_psum_wr_ready_in(glb_psum_wr_ready_in),
        .glb_psum_wr_addr_out(ctrl_glb_psum_wr_addr_w),
        .glb_psum_wr_data_out(ctrl_glb_psum_wr_data_w),
        .glb_psum_rd_valid_out(ctrl_glb_psum_rd_valid_w),
        .glb_psum_rd_ready_in(glb_psum_rd_ready_in),
        .glb_psum_rd_addr_out(ctrl_glb_psum_rd_addr_w),
        .glb_psum_rd_resp_valid_in(glb_psum_rd_resp_valid_in),
        .glb_psum_rd_resp_ready_out(ctrl_glb_psum_rd_resp_ready_w),
        .glb_psum_rd_resp_data_in(glb_psum_rd_resp_data_in),
        .ctrl_psum_col_sink_ready_out(ctrl_psum_col_sink_ready_w),
        .ctrl_psum_col_capture_ready_out(ctrl_psum_col_capture_ready_w),
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
        .ctrl_cfg_slide_commit_out(ctrl_cfg_slide_commit_out)
    );

    PE_Cluster3x4_HMesh #(
        .ENABLE_POOL(ENABLE_POOL)
    ) u_hmesh (
        .clk(clk),
        .rst(rst),
        .layer_mode_in(2'b00),
        .iact_router_prio_in(2'b00),
        .iact_addr_slot_valid_in(hm_iact_addr_slot_valid_w),
        .iact_addr_slot_ready_out(hm_iact_addr_slot_ready_w),
        .iact_addr_data_in(hm_iact_addr_data_w),
        .iact_addr_dst_mask_in(hm_iact_addr_dst_mask_w),
        .iact_data_slot_valid_in(hm_iact_data_slot_valid_w),
        .iact_data_slot_ready_out(hm_iact_data_slot_ready_w),
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
        .psum_col_ready_from_router_out(hm_psum_col_ready_from_router_w),
        .psum_col_data_from_router_in(hm_psum_col_data_from_router_w),
        .psum_col_valid_from_south_in(hm_psum_col_valid_from_south_w),
        .psum_col_ready_from_south_out(hm_psum_col_ready_from_south_w),
        .psum_col_data_from_south_in(hm_psum_col_data_from_south_w),
        .psum_col_valid_out(hm_psum_col_valid_raw_w),
        .psum_col_ready_in(hm_psum_col_ready_raw_w),
        .psum_col_data_out(hm_psum_col_data_raw_w),
        .pe_disable_in(hm_pe_disable_w),
        .psum_enq_en_in(hm_psum_enq_en_w),
        .do_load_en_in(hm_do_load_en_w),
        .do_mac_en_in(hm_do_mac_en_w),
        .iact_write_fin_clear_in(hm_iact_write_fin_clear_w),
        .weight_write_fin_clear_in(hm_weight_write_fin_clear_w),
        .psum_depth_in(hm_psum_depth_w),
        .psum_spad_clear_in(hm_psum_spad_clear_w),
        .all_write_fin_out(),
        .all_cal_fin_out(),
        .ctrl_cfg_window_size_in(hm_ctrl_cfg_window_size_w),
        .ctrl_cfg_segment_len_in(hm_ctrl_cfg_segment_len_w),
        .ctrl_cfg_window_seg_count_in(hm_ctrl_cfg_window_seg_count_w),
        .ctrl_cfg_psum_base_in(hm_ctrl_cfg_psum_base_w),
        .ctrl_cfg_m0_in(hm_ctrl_cfg_m0_w),
        .ctrl_cfg_iact_flush_in(hm_ctrl_cfg_iact_flush_w),
        .ctrl_cfg_slide_commit_in(hm_ctrl_cfg_slide_commit_w),
        .pool_cmp_en_in(12'h000),
        .pool_cmp_stop_in(12'h000),
        .pool_elem_valid_in(12'h000),
        .pool_elem_ready_out(),
        .pool_elem_data_in(96'sd0),
        .pool_win_first_in(12'h000),
        .pool_win_last_in(12'h000),
        .pool_out_valid_out(),
        .pool_out_ready_in(12'hfff),
        .pool_out_data_out(),
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
