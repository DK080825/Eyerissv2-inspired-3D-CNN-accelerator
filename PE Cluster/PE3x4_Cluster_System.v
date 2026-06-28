// ============================================================================
// Module      : PE3x4_Cluster_System
// Author      : Do Quoc Khanh
// Description : One-cluster integration wrapper for the GLB Cluster,
//               Router Cluster, and PE_Cluster3x4_Top compute path.
//               GLB stores payload, while scheduling, masks, slide/MAC control,
//               and PSUM writeback ordering stay in the cluster controller path.
//               This module defines the clean system boundary for one PE cluster.
// ============================================================================

module PE3x4_Cluster_System #(
    parameter integer GLB_AW = 8
) (
    input  wire                        clk,
    input  wire                        rst,

    // -------------------------------------------------------------------------------------------- //
    // Host / DMA-facing GLB Cluster access
    // -------------------------------------------------------------------------------------------- //
    input  wire                        glb_host_wr_valid_in,
    output wire                        glb_host_wr_ready_out,
    input  wire [2:0]                  glb_host_wr_region_in,
    input  wire [GLB_AW-1:0]           glb_host_wr_addr_in,
    input  wire [167:0]                glb_host_wr_data_in,

    input  wire                        glb_host_rd_valid_in,
    output wire                        glb_host_rd_ready_out,
    input  wire [2:0]                  glb_host_rd_region_in,
    input  wire [GLB_AW-1:0]           glb_host_rd_addr_in,
    output wire                        glb_host_rd_valid_out,
    input  wire                        glb_host_rd_ready_in,
    output wire [167:0]                glb_host_rd_data_out,
    input  wire                        glb_psum_wr_ready_gate_in,

    // ------------------------------------------------------- //
    // Weight ping-pong ownership controls
    // -------------------------------------------------- //
    input  wire                        weight_host_load_start_in,
    input  wire                        weight_host_load_buf_sel_in,
    input  wire                        weight_host_load_done_in,
    input  wire                        weight_compute_acquire_in,
    input  wire                        weight_compute_buf_sel_in,
    input  wire                        weight_compute_release_in,
    input  wire                        weight_error_clear_in,
    output wire                        weight_error_out,
    output wire                        weight_ping_valid_out,
    output wire                        weight_pong_valid_out,
    output wire                        weight_ping_busy_out,
    output wire                        weight_pong_busy_out,

    // -------------------------------------------------- //
    // Controller job and descriptor interface
    // --------------------------------------------------- //
    input  wire                        ctrl_job_start_in,
    input  wire                        ctrl_job_abort_in,
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


    // GLB transaction debugging signals.
    output wire                        dbg_glb_iact_addr_rd_valid_out,
    output wire                        dbg_glb_iact_addr_rd_ready_out,
    output wire [GLB_AW-1:0]           dbg_glb_iact_addr_rd_addr_out,
    output wire                        dbg_glb_iact_data_rd_valid_out,
    output wire                        dbg_glb_iact_data_rd_ready_out,
    output wire [GLB_AW-1:0]           dbg_glb_iact_data_rd_addr_out,
    output wire                        dbg_glb_weight_addr_rd_valid_out,
    output wire                        dbg_glb_weight_addr_rd_ready_out,
    output wire [GLB_AW-1:0]           dbg_glb_weight_addr_rd_addr_out,
    output wire                        dbg_glb_weight_data_rd_valid_out,
    output wire                        dbg_glb_weight_data_rd_ready_out,
    output wire [GLB_AW-1:0]           dbg_glb_weight_data_rd_addr_out,
    output wire                        dbg_glb_psum_wr_valid_out,
    output wire                        dbg_glb_psum_wr_ready_out,
    output wire [GLB_AW-1:0]           dbg_glb_psum_wr_addr_out,
    output wire [167:0]                dbg_glb_psum_wr_data_out,
    output wire                        dbg_glb_psum_rd_valid_out,
    output wire                        dbg_glb_psum_rd_ready_out,
    output wire [GLB_AW-1:0]           dbg_glb_psum_rd_addr_out,

    output wire                        dbg_do_mac_en_out,
    output wire                        dbg_slide_commit_out,
    output wire [5:0]                  dbg_iact_addr_slot_valid_out,
    output wire [71:0]                 dbg_iact_addr_dst_mask_out,
    output wire [5:0]                  dbg_iact_data_slot_valid_out,
    output wire [71:0]                 dbg_iact_data_dst_mask_out,
    output wire [15:0]                 dbg_current_window_idx_out
);
    wire                        glb_iact_addr_rd_valid_w;
    wire                        glb_iact_addr_rd_ready_w;
    wire [GLB_AW-1:0]           glb_iact_addr_rd_addr_w;
    wire                        glb_iact_addr_resp_valid_w;
    wire                        glb_iact_addr_resp_ready_w;
    wire [29:0]                 glb_iact_addr_resp_data_w;

    wire                        glb_iact_data_rd_valid_w;
    wire                        glb_iact_data_rd_ready_w;
    wire [GLB_AW-1:0]           glb_iact_data_rd_addr_w;
    wire                        glb_iact_data_resp_valid_w;
    wire                        glb_iact_data_resp_ready_w;
    wire [71:0]                 glb_iact_data_resp_data_w;

    wire                        glb_weight_addr_rd_valid_w;
    wire                        glb_weight_addr_rd_ready_w;
    wire [GLB_AW-1:0]           glb_weight_addr_rd_addr_w;
    wire                        glb_weight_addr_resp_valid_w;
    wire                        glb_weight_addr_resp_ready_w;
    wire [20:0]                 glb_weight_addr_resp_data_w;

    wire                        glb_weight_data_rd_valid_w;
    wire                        glb_weight_data_rd_ready_w;
    wire [GLB_AW-1:0]           glb_weight_data_rd_addr_w;
    wire                        glb_weight_data_resp_valid_w;
    wire                        glb_weight_data_resp_ready_w;
    wire [71:0]                 glb_weight_data_resp_data_w;

    wire                        glb_psum_wr_valid_w;
    wire                        glb_psum_wr_ready_w;
    wire [GLB_AW-1:0]           glb_psum_wr_addr_w;
    wire [167:0]                glb_psum_wr_data_w;
    wire                        glb_psum_rd_valid_w;
    wire                        glb_psum_rd_ready_w;
    wire [GLB_AW-1:0]           glb_psum_rd_addr_w;
    wire                        glb_psum_rd_resp_valid_w;
    wire                        glb_psum_rd_resp_ready_w;
    wire [167:0]                glb_psum_rd_resp_data_w;
    

    wire [5:0]                  router_iact_data_in_sel_w;
    wire [8:0]                  router_iact_route_mask_w;
    wire [2:0]                  router_weight_data_in_sel_w;
    wire [2:0]                  router_weight_route_horizontal_w;
    wire [3:0]                  router_psum_data_in_sel_w;
    wire [3:0]                  router_psum_route_to_pe_w;

    wire [5:0]                  router_local_iact_addr_valid_w;
    wire [5:0]                  router_local_iact_addr_ready_w;
    wire [29:0]                 router_local_iact_addr_data_w;
    wire [5:0]                  router_local_iact_data_valid_w;
    wire [5:0]                  router_local_iact_data_ready_w;
    wire [71:0]                 router_local_iact_data_w;
    wire [5:0]                  router_pe_iact_addr_valid_w;
    wire [5:0]                  router_pe_iact_addr_ready_w;
    wire [29:0]                 router_pe_iact_addr_data_w;
    wire [5:0]                  router_pe_iact_data_valid_w;
    wire [5:0]                  router_pe_iact_data_ready_w;
    wire [71:0]                 router_pe_iact_data_w;

    wire [2:0]                  router_local_weight_addr_valid_w;
    wire [2:0]                  router_local_weight_addr_ready_w;
    wire [20:0]                 router_local_weight_addr_data_w;
    wire [2:0]                  router_local_weight_data_valid_w;
    wire [2:0]                  router_local_weight_data_ready_w;
    wire [71:0]                 router_local_weight_data_w;
    wire [2:0]                  router_pe_weight_addr_valid_w;
    wire [2:0]                  router_pe_weight_addr_ready_w;
    wire [20:0]                 router_pe_weight_addr_data_w;
    wire [2:0]                  router_pe_weight_data_valid_w;
    wire [2:0]                  router_pe_weight_data_ready_w;
    wire [71:0]                 router_pe_weight_data_w;

    wire [3:0]                  router_pe_psum_return_valid_w;
    wire [3:0]                  router_pe_psum_return_ready_w;
    wire signed [167:0]         router_pe_psum_return_data_w;
    wire [3:0]                  router_local_psum_return_valid_w;
    wire [3:0]                  router_local_psum_return_ready_w;
    wire signed [167:0]         router_local_psum_return_data_w;
    wire [3:0]                  router_local_psum_forward_valid_w;
    wire [3:0]                  router_local_psum_forward_ready_w;
    wire signed [167:0]         router_local_psum_forward_data_w;
    wire [3:0]                  router_north_psum_forward_valid_w;
    wire [3:0]                  router_north_psum_forward_ready_w;
    wire signed [167:0]         router_north_psum_forward_data_w;
    wire [3:0]                  router_pe_psum_forward_valid_w;
    wire [3:0]                  router_pe_psum_forward_ready_w;
    wire signed [167:0]         router_pe_psum_forward_data_w;

    PE_Cluster3x4_Top #(
        .GLB_AW(GLB_AW),
        .ENABLE_POOL(0)
    ) u_pe_cluster_top (
        .clk(clk),
        .rst(rst),
        .ctrl_job_start_in(ctrl_job_start_in),
        .ctrl_job_abort_in(ctrl_job_abort_in),
        .ctrl_job_busy_out(ctrl_job_busy_out),
        .ctrl_job_done_out(ctrl_job_done_out),
        .ctrl_job_error_out(ctrl_job_error_out),
        .ctrl_state_dbg_out(ctrl_state_dbg_out),
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
        .glb_iact_addr_rd_valid_out(glb_iact_addr_rd_valid_w),
        .glb_iact_addr_rd_ready_in(glb_iact_addr_rd_ready_w),
        .glb_iact_addr_rd_addr_out(glb_iact_addr_rd_addr_w),
        .glb_iact_addr_resp_valid_in(glb_iact_addr_resp_valid_w),
        .glb_iact_addr_resp_ready_out(glb_iact_addr_resp_ready_w),
        .glb_iact_addr_resp_data_in(glb_iact_addr_resp_data_w),
        .glb_iact_data_rd_valid_out(glb_iact_data_rd_valid_w),
        .glb_iact_data_rd_ready_in(glb_iact_data_rd_ready_w),
        .glb_iact_data_rd_addr_out(glb_iact_data_rd_addr_w),
        .glb_iact_data_resp_valid_in(glb_iact_data_resp_valid_w),
        .glb_iact_data_resp_ready_out(glb_iact_data_resp_ready_w),
        .glb_iact_data_resp_data_in(glb_iact_data_resp_data_w),
        .glb_weight_addr_rd_valid_out(glb_weight_addr_rd_valid_w),
        .glb_weight_addr_rd_ready_in(glb_weight_addr_rd_ready_w),
        .glb_weight_addr_rd_addr_out(glb_weight_addr_rd_addr_w),
        .glb_weight_addr_resp_valid_in(glb_weight_addr_resp_valid_w),
        .glb_weight_addr_resp_ready_out(glb_weight_addr_resp_ready_w),
        .glb_weight_addr_resp_data_in(glb_weight_addr_resp_data_w),
        .glb_weight_data_rd_valid_out(glb_weight_data_rd_valid_w),
        .glb_weight_data_rd_ready_in(glb_weight_data_rd_ready_w),
        .glb_weight_data_rd_addr_out(glb_weight_data_rd_addr_w),
        .glb_weight_data_resp_valid_in(glb_weight_data_resp_valid_w),
        .glb_weight_data_resp_ready_out(glb_weight_data_resp_ready_w),
        .glb_weight_data_resp_data_in(glb_weight_data_resp_data_w),
        .glb_psum_wr_valid_out(glb_psum_wr_valid_w),
        .glb_psum_wr_ready_in(glb_psum_wr_ready_w && glb_psum_wr_ready_gate_in),
        .glb_psum_wr_addr_out(glb_psum_wr_addr_w),
        .glb_psum_wr_data_out(glb_psum_wr_data_w),
        .glb_psum_rd_valid_out(glb_psum_rd_valid_w),
        .glb_psum_rd_ready_in(glb_psum_rd_ready_w),
        .glb_psum_rd_addr_out(glb_psum_rd_addr_w),
        .glb_psum_rd_resp_valid_in(glb_psum_rd_resp_valid_w),
        .glb_psum_rd_resp_ready_out(glb_psum_rd_resp_ready_w),
        .glb_psum_rd_resp_data_in(glb_psum_rd_resp_data_w),
        .router_iact_data_in_sel_out(router_iact_data_in_sel_w),
        .router_iact_route_mask_out(router_iact_route_mask_w),
        .router_weight_data_in_sel_out(router_weight_data_in_sel_w),
        .router_weight_route_horizontal_out(router_weight_route_horizontal_w),
        .router_psum_data_in_sel_out(router_psum_data_in_sel_w),
        .router_psum_route_to_pe_out(router_psum_route_to_pe_w),
        .router_local_iact_addr_valid_out(router_local_iact_addr_valid_w),
        .router_local_iact_addr_ready_in(router_local_iact_addr_ready_w),
        .router_local_iact_addr_data_out(router_local_iact_addr_data_w),
        .router_local_iact_data_valid_out(router_local_iact_data_valid_w),
        .router_local_iact_data_ready_in(router_local_iact_data_ready_w),
        .router_local_iact_data_out(router_local_iact_data_w),
        .router_pe_iact_addr_valid_in(router_pe_iact_addr_valid_w),
        .router_pe_iact_addr_ready_out(router_pe_iact_addr_ready_w),
        .router_pe_iact_addr_data_in(router_pe_iact_addr_data_w),
        .router_pe_iact_data_valid_in(router_pe_iact_data_valid_w),
        .router_pe_iact_data_ready_out(router_pe_iact_data_ready_w),
        .router_pe_iact_data_in(router_pe_iact_data_w),
        .router_local_weight_addr_valid_out(router_local_weight_addr_valid_w),
        .router_local_weight_addr_ready_in(router_local_weight_addr_ready_w),
        .router_local_weight_addr_data_out(router_local_weight_addr_data_w),
        .router_local_weight_data_valid_out(router_local_weight_data_valid_w),
        .router_local_weight_data_ready_in(router_local_weight_data_ready_w),
        .router_local_weight_data_out(router_local_weight_data_w),
        .router_pe_weight_addr_valid_in(router_pe_weight_addr_valid_w),
        .router_pe_weight_addr_ready_out(router_pe_weight_addr_ready_w),
        .router_pe_weight_addr_data_in(router_pe_weight_addr_data_w),
        .router_pe_weight_data_valid_in(router_pe_weight_data_valid_w),
        .router_pe_weight_data_ready_out(router_pe_weight_data_ready_w),
        .router_pe_weight_data_in(router_pe_weight_data_w),
        .router_pe_psum_return_valid_out(router_pe_psum_return_valid_w),
        .router_pe_psum_return_ready_in(router_pe_psum_return_ready_w),
        .router_pe_psum_return_data_out(router_pe_psum_return_data_w),
        .router_local_psum_return_valid_in(router_local_psum_return_valid_w),
        .router_local_psum_return_ready_out(router_local_psum_return_ready_w),
        .router_local_psum_return_data_in(router_local_psum_return_data_w),
        .router_local_psum_forward_valid_out(router_local_psum_forward_valid_w),
        .router_local_psum_forward_ready_in(router_local_psum_forward_ready_w),
        .router_local_psum_forward_data_out(router_local_psum_forward_data_w),
        .router_north_psum_forward_valid_out(router_north_psum_forward_valid_w),
        .router_north_psum_forward_ready_in(router_north_psum_forward_ready_w),
        .router_north_psum_forward_data_out(router_north_psum_forward_data_w),
        .router_pe_psum_forward_valid_in(router_pe_psum_forward_valid_w),
        .router_pe_psum_forward_ready_out(router_pe_psum_forward_ready_w),
        .router_pe_psum_forward_data_in(router_pe_psum_forward_data_w),
        .psum_col_valid_out(unused_psum_col_valid_w),
        .psum_col_data_out(unused_psum_col_data_w),
        .pe_iact_addr_valid_out(unused_pe_iact_addr_valid_w),
        .pe_iact_addr_ready_out(unused_pe_iact_addr_ready_w),
        .pe_iact_addr_data_out(unused_pe_iact_addr_data_w),
        .pe_iact_data_valid_out(unused_pe_iact_data_valid_w),
        .pe_iact_data_ready_out(unused_pe_iact_data_ready_w),
        .pe_iact_data_out(unused_pe_iact_data_w),
        .pe_weight_addr_valid_out(unused_pe_weight_addr_valid_w),
        .pe_weight_addr_ready_out(unused_pe_weight_addr_ready_w),
        .pe_weight_addr_data_out(unused_pe_weight_addr_data_w),
        .pe_weight_data_valid_out(unused_pe_weight_data_valid_w),
        .pe_weight_data_ready_out(unused_pe_weight_data_ready_w),
        .pe_weight_data_out(unused_pe_weight_data_w),
        .pe_psum_router_ready_out(unused_pe_psum_router_ready_w),
        .pe_psum_in_valid_out(unused_pe_psum_in_valid_w),
        .pe_psum_in_ready_out(unused_pe_psum_in_ready_w),
        .pe_psum_in_data_out(unused_pe_psum_in_data_w),
        .pe_psum_out_valid_out(unused_pe_psum_out_valid_w),
        .pe_psum_out_ready_out(unused_pe_psum_out_ready_w),
        .pe_psum_out_data_out(unused_pe_psum_out_data_w),
        .pe_iact_addr_write_fin_out(unused_pe_iact_addr_write_fin_w),
        .pe_iact_data_write_fin_out(unused_pe_iact_data_write_fin_w),
        .pe_weight_addr_write_fin_out(unused_pe_weight_addr_write_fin_w),
        .pe_weight_data_write_fin_out(unused_pe_weight_data_write_fin_w),
        .pe_psum_acc_fin_out(unused_pe_psum_acc_fin_w),
        .pe_slide_safe_out(unused_pe_slide_safe_w),
        .pe_all_write_fin_out(unused_pe_all_write_fin_w),
        .pe_cal_fin_out(unused_pe_cal_fin_w),
        .pe_load_en_out(unused_pe_load_en_w),
        .pe_write_fin_sticky_out(unused_pe_write_fin_sticky_w),
        .pe_cal_fin_sticky_out(unused_pe_cal_fin_sticky_w),
        .dbg_do_mac_en_out(dbg_do_mac_en_out),
        .dbg_slide_commit_out(dbg_slide_commit_out),
        .dbg_iact_addr_slot_valid_out(dbg_iact_addr_slot_valid_out),
        .dbg_iact_addr_dst_mask_out(dbg_iact_addr_dst_mask_out),
        .dbg_iact_data_slot_valid_out(dbg_iact_data_slot_valid_out),
        .dbg_iact_data_dst_mask_out(dbg_iact_data_dst_mask_out),
        .dbg_current_window_idx_out(dbg_current_window_idx_out)
    );

    Router_Cluster u_router_cluster (
        .iact_data_in_sel_in(router_iact_data_in_sel_w),
        .iact_route_mask_in(router_iact_route_mask_w),
        .weight_data_in_sel_in(router_weight_data_in_sel_w),
        .weight_route_horizontal_in(router_weight_route_horizontal_w),
        .psum_data_in_sel_in(router_psum_data_in_sel_w),
        .psum_route_to_pe_in(router_psum_route_to_pe_w),

        .local_iact_addr_valid_in(router_local_iact_addr_valid_w),
        .local_iact_addr_ready_out(router_local_iact_addr_ready_w),
        .local_iact_addr_in(router_local_iact_addr_data_w),
        .local_iact_data_valid_in(router_local_iact_data_valid_w),
        .local_iact_data_ready_out(router_local_iact_data_ready_w),
        .local_iact_data_in(router_local_iact_data_w),
        .north_iact_addr_valid_in(6'b0), .north_iact_addr_ready_out(), .north_iact_addr_in(30'b0),
        .north_iact_data_valid_in(6'b0), .north_iact_data_ready_out(), .north_iact_data_in(72'b0),
        .south_iact_addr_valid_in(6'b0), .south_iact_addr_ready_out(), .south_iact_addr_in(30'b0),
        .south_iact_data_valid_in(6'b0), .south_iact_data_ready_out(), .south_iact_data_in(72'b0),
        .horizontal_iact_addr_valid_in(6'b0), .horizontal_iact_addr_ready_out(), .horizontal_iact_addr_in(30'b0),
        .horizontal_iact_data_valid_in(6'b0), .horizontal_iact_data_ready_out(), .horizontal_iact_data_in(72'b0),
        .pe_iact_addr_valid_out(router_pe_iact_addr_valid_w),
        .pe_iact_addr_ready_in(router_pe_iact_addr_ready_w),
        .pe_iact_addr_out(router_pe_iact_addr_data_w),
        .pe_iact_data_valid_out(router_pe_iact_data_valid_w),
        .pe_iact_data_ready_in(router_pe_iact_data_ready_w),
        .pe_iact_data_out(router_pe_iact_data_w),
        .north_iact_addr_valid_out(), .north_iact_addr_ready_in(6'h3f), .north_iact_addr_out(),
        .north_iact_data_valid_out(), .north_iact_data_ready_in(6'h3f), .north_iact_data_out(),
        .south_iact_addr_valid_out(), .south_iact_addr_ready_in(6'h3f), .south_iact_addr_out(),
        .south_iact_data_valid_out(), .south_iact_data_ready_in(6'h3f), .south_iact_data_out(),
        .horizontal_iact_addr_valid_out(), .horizontal_iact_addr_ready_in(6'h3f), .horizontal_iact_addr_out(),
        .horizontal_iact_data_valid_out(), .horizontal_iact_data_ready_in(6'h3f), .horizontal_iact_data_out(),

        .local_weight_addr_valid_in(router_local_weight_addr_valid_w),
        .local_weight_addr_ready_out(router_local_weight_addr_ready_w),
        .local_weight_addr_in(router_local_weight_addr_data_w),
        .local_weight_data_valid_in(router_local_weight_data_valid_w),
        .local_weight_data_ready_out(router_local_weight_data_ready_w),
        .local_weight_data_in(router_local_weight_data_w),
        .horizontal_weight_addr_valid_in(3'b0), .horizontal_weight_addr_ready_out(), .horizontal_weight_addr_in(21'b0),
        .horizontal_weight_data_valid_in(3'b0), .horizontal_weight_data_ready_out(), .horizontal_weight_data_in(72'b0),
        .pe_weight_addr_valid_out(router_pe_weight_addr_valid_w),
        .pe_weight_addr_ready_in(router_pe_weight_addr_ready_w),
        .pe_weight_addr_out(router_pe_weight_addr_data_w),
        .pe_weight_data_valid_out(router_pe_weight_data_valid_w),
        .pe_weight_data_ready_in(router_pe_weight_data_ready_w),
        .pe_weight_data_out(router_pe_weight_data_w),
        .horizontal_weight_addr_valid_out(), .horizontal_weight_addr_ready_in(3'b111), .horizontal_weight_addr_out(),
        .horizontal_weight_data_valid_out(), .horizontal_weight_data_ready_in(3'b111), .horizontal_weight_data_out(),

        .pe_psum_return_valid_in(router_pe_psum_return_valid_w),
        .pe_psum_return_ready_out(router_pe_psum_return_ready_w),
        .pe_psum_return_data_in(router_pe_psum_return_data_w),
        .local_psum_return_valid_out(router_local_psum_return_valid_w),
        .local_psum_return_ready_in(router_local_psum_return_ready_w),
        .local_psum_return_data_out(router_local_psum_return_data_w),
        .local_psum_forward_valid_in(router_local_psum_forward_valid_w),
        .local_psum_forward_ready_out(router_local_psum_forward_ready_w),
        .local_psum_forward_data_in(router_local_psum_forward_data_w),
        .north_psum_forward_valid_in(router_north_psum_forward_valid_w),
        .north_psum_forward_ready_out(router_north_psum_forward_ready_w),
        .north_psum_forward_data_in(router_north_psum_forward_data_w),
        .pe_psum_forward_valid_out(router_pe_psum_forward_valid_w),
        .pe_psum_forward_ready_in(router_pe_psum_forward_ready_w),
        .pe_psum_forward_data_out(router_pe_psum_forward_data_w),
        .south_psum_forward_valid_out(), .south_psum_forward_ready_in(4'hf), .south_psum_forward_data_out()
    );

    PE3x4_GLB_Cluster #(.AWIDTH(GLB_AW)) u_glb_cluster (
        .clk(clk),
        .rst(rst),
        .host_wr_valid_in(glb_host_wr_valid_in),
        .host_wr_ready_out(glb_host_wr_ready_out),
        .host_wr_region_in(glb_host_wr_region_in),
        .host_wr_addr_in(glb_host_wr_addr_in),
        .host_wr_data_in(glb_host_wr_data_in),
        .weight_host_load_start_in(weight_host_load_start_in),
        .weight_host_load_buf_sel_in(weight_host_load_buf_sel_in),
        .weight_host_load_done_in(weight_host_load_done_in),
        .weight_compute_acquire_in(weight_compute_acquire_in),
        .weight_compute_buf_sel_in(weight_compute_buf_sel_in),
        .weight_compute_release_in(weight_compute_release_in),
        .weight_error_clear_in(weight_error_clear_in),
        .weight_error_out(weight_error_out),
        .weight_ping_valid_out(weight_ping_valid_out),
        .weight_pong_valid_out(weight_pong_valid_out),
        .weight_ping_busy_out(weight_ping_busy_out),
        .weight_pong_busy_out(weight_pong_busy_out),
        .host_rd_valid_in(glb_host_rd_valid_in),
        .host_rd_ready_out(glb_host_rd_ready_out),
        .host_rd_region_in(glb_host_rd_region_in),
        .host_rd_addr_in(glb_host_rd_addr_in),
        .host_rd_valid_out(glb_host_rd_valid_out),
        .host_rd_ready_in(glb_host_rd_ready_in),
        .host_rd_data_out(glb_host_rd_data_out),
        .iact_addr_ctrl_rd_valid_in(glb_iact_addr_rd_valid_w),
        .iact_addr_ctrl_rd_ready_out(glb_iact_addr_rd_ready_w),
        .iact_addr_ctrl_rd_addr_in(glb_iact_addr_rd_addr_w[GLB_AW-1:0]),
        .iact_addr_ctrl_rd_valid_out(glb_iact_addr_resp_valid_w),
        .iact_addr_ctrl_rd_ready_in(glb_iact_addr_resp_ready_w),
        .iact_addr_ctrl_rd_data_out(glb_iact_addr_resp_data_w),
        .iact_data_ctrl_rd_valid_in(glb_iact_data_rd_valid_w),
        .iact_data_ctrl_rd_ready_out(glb_iact_data_rd_ready_w),
        .iact_data_ctrl_rd_addr_in(glb_iact_data_rd_addr_w[GLB_AW-1:0]),
        .iact_data_ctrl_rd_valid_out(glb_iact_data_resp_valid_w),
        .iact_data_ctrl_rd_ready_in(glb_iact_data_resp_ready_w),
        .iact_data_ctrl_rd_data_out(glb_iact_data_resp_data_w),
        .weight_addr_ctrl_rd_valid_in(glb_weight_addr_rd_valid_w),
        .weight_addr_ctrl_rd_ready_out(glb_weight_addr_rd_ready_w),
        .weight_addr_ctrl_rd_addr_in(glb_weight_addr_rd_addr_w[GLB_AW-1:0]),
        .weight_addr_ctrl_rd_valid_out(glb_weight_addr_resp_valid_w),
        .weight_addr_ctrl_rd_ready_in(glb_weight_addr_resp_ready_w),
        .weight_addr_ctrl_rd_data_out(glb_weight_addr_resp_data_w),
        .weight_data_ctrl_rd_valid_in(glb_weight_data_rd_valid_w),
        .weight_data_ctrl_rd_ready_out(glb_weight_data_rd_ready_w),
        .weight_data_ctrl_rd_addr_in(glb_weight_data_rd_addr_w[GLB_AW-1:0]),
        .weight_data_ctrl_rd_valid_out(glb_weight_data_resp_valid_w),
        .weight_data_ctrl_rd_ready_in(glb_weight_data_resp_ready_w),
        .weight_data_ctrl_rd_data_out(glb_weight_data_resp_data_w),
        .psum_wr_valid_in(glb_psum_wr_valid_w && glb_psum_wr_ready_gate_in),
        .psum_wr_ready_out(glb_psum_wr_ready_w),
        .psum_wr_addr_in(glb_psum_wr_addr_w[GLB_AW-1:0]),
        .psum_wr_data_in(glb_psum_wr_data_w),
        .psum_ctrl_rd_valid_in(glb_psum_rd_valid_w),
        .psum_ctrl_rd_ready_out(glb_psum_rd_ready_w),
        .psum_ctrl_rd_addr_in(glb_psum_rd_addr_w[GLB_AW-1:0]),
        .psum_ctrl_rd_valid_out(glb_psum_rd_resp_valid_w),
        .psum_ctrl_rd_ready_in(glb_psum_rd_resp_ready_w),
        .psum_ctrl_rd_data_out(glb_psum_rd_resp_data_w)
    );

    assign dbg_glb_iact_addr_rd_valid_out  = glb_iact_addr_rd_valid_w;
    assign dbg_glb_iact_addr_rd_ready_out  = glb_iact_addr_rd_ready_w;
    assign dbg_glb_iact_addr_rd_addr_out   = glb_iact_addr_rd_addr_w[GLB_AW-1:0];
    assign dbg_glb_iact_data_rd_valid_out  = glb_iact_data_rd_valid_w;
    assign dbg_glb_iact_data_rd_ready_out  = glb_iact_data_rd_ready_w;
    assign dbg_glb_iact_data_rd_addr_out   = glb_iact_data_rd_addr_w[GLB_AW-1:0];
    assign dbg_glb_weight_addr_rd_valid_out = glb_weight_addr_rd_valid_w;
    assign dbg_glb_weight_addr_rd_ready_out = glb_weight_addr_rd_ready_w;
    assign dbg_glb_weight_addr_rd_addr_out  = glb_weight_addr_rd_addr_w[GLB_AW-1:0];
    assign dbg_glb_weight_data_rd_valid_out = glb_weight_data_rd_valid_w;
    assign dbg_glb_weight_data_rd_ready_out = glb_weight_data_rd_ready_w;
    assign dbg_glb_weight_data_rd_addr_out  = glb_weight_data_rd_addr_w[GLB_AW-1:0];
    assign dbg_glb_psum_wr_valid_out       = glb_psum_wr_valid_w;
    assign dbg_glb_psum_wr_ready_out       = glb_psum_wr_ready_w && glb_psum_wr_ready_gate_in;
    assign dbg_glb_psum_wr_addr_out        = glb_psum_wr_addr_w[GLB_AW-1:0];
    assign dbg_glb_psum_wr_data_out        = glb_psum_wr_data_w;
    assign dbg_glb_psum_rd_valid_out       = glb_psum_rd_valid_w;
    assign dbg_glb_psum_rd_ready_out       = glb_psum_rd_ready_w;
    assign dbg_glb_psum_rd_addr_out        = glb_psum_rd_addr_w[GLB_AW-1:0];
endmodule
