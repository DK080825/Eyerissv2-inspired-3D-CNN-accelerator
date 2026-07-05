// ============================================================================
// Module      : PE_Cluster3x4_Top
// Description : Top wrapper for one 3x4 PE cluster.
//               It connects the controller, router side, and local PE array.
//               GLB provides payload. The controller provides control and masks.
//               HMesh delivers data to the PEs and returns PSUM results.
// ============================================================================

module PE_Cluster3x4_Top #(
    parameter integer GLB_AW = 8
) (
    input  wire                        clk,
    input  wire                        rst,

    // Host/testbench -> controller: start one job.
    input  wire                        ctrl_job_start_in,
    // Controller -> host/testbench: job status.
    output wire                        ctrl_job_busy_out,
    output wire                        ctrl_job_done_out,

    // Host/testbench -> controller: layer and GLB layout.
    input  wire [4:0]                  desc_c_in_in,
    input  wire [11:0]                 desc_active_pe_mask_in,
    input  wire [15:0]                 desc_output_window_count_in,
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
    input  wire [GLB_AW-1:0]           desc_psum_read_base_in,
    input  wire [15:0]                 desc_psum_read_count_in,
    input  wire [GLB_AW-1:0]           desc_psum_write_base_in,
    input  wire [5:0]                  desc_m0_in,

    // Controller -> IACT_ADDR GLB: read request. GLB -> controller: payload.
    output wire                        glb_iact_addr_rd_valid_out,
    input  wire                        glb_iact_addr_rd_ready_in,
    output wire [GLB_AW-1:0]           glb_iact_addr_rd_addr_out,
    input  wire                        glb_iact_addr_resp_valid_in,
    output wire                        glb_iact_addr_resp_ready_out,
    input  wire [29:0]                 glb_iact_addr_resp_data_in,

    // Controller -> IACT_DATA GLB: read request. GLB -> controller: payload.
    output wire                        glb_iact_data_rd_valid_out,
    input  wire                        glb_iact_data_rd_ready_in,
    output wire [GLB_AW-1:0]           glb_iact_data_rd_addr_out,
    input  wire                        glb_iact_data_resp_valid_in,
    output wire                        glb_iact_data_resp_ready_out,
    input  wire [71:0]                 glb_iact_data_resp_data_in,

    // Controller -> Weight_ADDR GLB: read request. GLB -> controller: payload.
    output wire                        glb_weight_addr_rd_valid_out,
    input  wire                        glb_weight_addr_rd_ready_in,
    output wire [GLB_AW-1:0]           glb_weight_addr_rd_addr_out,
    input  wire                        glb_weight_addr_resp_valid_in,
    output wire                        glb_weight_addr_resp_ready_out,
    input  wire [20:0]                 glb_weight_addr_resp_data_in,

    // Controller -> Weight_DATA GLB: read request. GLB -> controller: payload.
    output wire                        glb_weight_data_rd_valid_out,
    input  wire                        glb_weight_data_rd_ready_in,
    output wire [GLB_AW-1:0]           glb_weight_data_rd_addr_out,
    input  wire                        glb_weight_data_resp_valid_in,
    output wire                        glb_weight_data_resp_ready_out,
    input  wire [71:0]                 glb_weight_data_resp_data_in,

    // Controller -> PSUM GLB: write output.
    output wire                        glb_psum_wr_valid_out,
    input  wire                        glb_psum_wr_ready_in,
    output wire [GLB_AW-1:0]           glb_psum_wr_addr_out,
    output wire [167:0]                glb_psum_wr_data_out,
    // Controller -> PSUM GLB: read seed.
    output wire                        glb_psum_rd_valid_out,
    input  wire                        glb_psum_rd_ready_in,
    output wire [GLB_AW-1:0]           glb_psum_rd_addr_out,
    input  wire                        glb_psum_rd_valid_in,
    output wire                        glb_psum_rd_ready_out,
    input  wire [167:0]                glb_psum_rd_data_in,

    // Controller -> router: local IACT stream. Router -> controller: ready.
    output wire [5:0]                  router_local_iact_addr_valid_out,
    input  wire [5:0]                  router_local_iact_addr_ready_in,
    output wire [29:0]                 router_local_iact_addr_data_out,
    output wire [5:0]                  router_local_iact_data_valid_out,
    input  wire [5:0]                  router_local_iact_data_ready_in,
    output wire [71:0]                 router_local_iact_data_out,
    // Router -> HMesh: selected IACT stream. HMesh -> router: ready.
    input  wire [5:0]                  router_pe_iact_addr_valid_in,
    output wire [5:0]                  router_pe_iact_addr_ready_out,
    input  wire [29:0]                 router_pe_iact_addr_data_in,
    input  wire [5:0]                  router_pe_iact_data_valid_in,
    output wire [5:0]                  router_pe_iact_data_ready_out,
    input  wire [71:0]                 router_pe_iact_data_in,

    // Controller -> router: local Weight stream. Router -> controller: ready.
    output wire [2:0]                  router_local_weight_addr_valid_out,
    input  wire [2:0]                  router_local_weight_addr_ready_in,
    output wire [20:0]                 router_local_weight_addr_data_out,
    output wire [2:0]                  router_local_weight_data_valid_out,
    input  wire [2:0]                  router_local_weight_data_ready_in,
    output wire [71:0]                 router_local_weight_data_out,
    // Router -> HMesh: selected Weight stream. HMesh -> router: ready.
    input  wire [2:0]                  router_pe_weight_addr_valid_in,
    output wire [2:0]                  router_pe_weight_addr_ready_out,
    input  wire [20:0]                 router_pe_weight_addr_data_in,
    input  wire [2:0]                  router_pe_weight_data_valid_in,
    output wire [2:0]                  router_pe_weight_data_ready_out,
    input  wire [71:0]                 router_pe_weight_data_in,

    // HMesh -> router: PSUM result from PE columns.
    output wire [3:0]                  router_pe_psum_return_valid_out,
    input  wire [3:0]                  router_pe_psum_return_ready_in,
    output wire signed [167:0]         router_pe_psum_return_data_out,
    // Router -> controller: selected PSUM result.
    input  wire [3:0]                  router_local_psum_return_valid_in,
    output wire [3:0]                  router_local_psum_return_ready_out,
    input  wire signed [167:0]         router_local_psum_return_data_in,
    // Controller -> router: local PSUM seed path.
    output wire [3:0]                  router_local_psum_forward_valid_out,
    input  wire [3:0]                  router_local_psum_forward_ready_in,
    output wire signed [167:0]         router_local_psum_forward_data_out,
    // Controller -> router: PSUM seed sent toward PE columns.
    output wire [3:0]                  router_north_psum_forward_valid_out,
    input  wire [3:0]                  router_north_psum_forward_ready_in,
    output wire signed [167:0]         router_north_psum_forward_data_out,
    // Router -> HMesh: selected PSUM seed. HMesh -> router: ready.
    input  wire [3:0]                  router_pe_psum_forward_valid_in,
    output wire [3:0]                  router_pe_psum_forward_ready_out,
    input  wire signed [167:0]         router_pe_psum_forward_data_in
);
    // Controller data/control wires.
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
    wire [3:0]                  ctrl_psum_seed_valid_out;
    wire signed [167:0]         ctrl_psum_seed_data_out;
    wire                        ctrl_glb_psum_wr_valid_w;
    wire [GLB_AW-1:0]           ctrl_glb_psum_wr_addr_w;
    wire [167:0]                ctrl_glb_psum_wr_data_w;
    wire [3:0]                  ctrl_psum_col_ready_w;
    wire [3:0]                  psum_col_valid_w;
    wire signed [167:0]         psum_col_data_w;
    wire [11:0]                 pe_iact_addr_write_fin_w;
    wire [11:0]                 pe_iact_data_write_fin_w;
    wire [11:0]                 pe_weight_addr_write_fin_w;
    wire [11:0]                 pe_weight_data_write_fin_w;
    wire [11:0]                 pe_psum_acc_fin_w;
    wire [11:0]                 pe_slide_safe_w;
    wire [11:0]                 pe_cal_fin_w;
    wire [11:0]                 ctrl_pe_disable_out;
    wire                        ctrl_psum_enq_en_out;
    wire                        ctrl_do_load_en_out;
    wire                        ctrl_do_mac_en_out;
    wire                        ctrl_iact_write_fin_clear_out;
    wire                        ctrl_weight_write_fin_clear_out;
    wire                        ctrl_psum_spad_clear_out;
    wire [4:0]                  ctrl_cfg_segment_len_out;
    wire [3:0]                  ctrl_cfg_window_seg_count_out;
    wire [5:0]                  ctrl_cfg_m0_out;
    wire                        ctrl_cfg_iact_flush_out;
    wire                        ctrl_cfg_slide_commit_out;
    wire                        ctrl_job_busy_w;
    wire                        ctrl_job_done_w;

    // Top status and PSUM GLB outputs.
    assign ctrl_job_busy_out  = ctrl_job_busy_w;
    assign ctrl_job_done_out  = ctrl_job_done_w;
    assign glb_psum_wr_valid_out = ctrl_glb_psum_wr_valid_w;
    assign glb_psum_wr_addr_out = ctrl_glb_psum_wr_addr_w;
    assign glb_psum_wr_data_out = ctrl_glb_psum_wr_data_w;
    // Controller sends payload to router. Router sends selected payload to HMesh.
    assign router_local_iact_addr_valid_out = ctrl_iact_addr_slot_valid_out;
    assign router_local_iact_addr_data_out = ctrl_iact_addr_data_out;
    assign router_local_iact_data_valid_out = ctrl_iact_data_slot_valid_out;
    assign router_local_iact_data_out = ctrl_iact_data_out;
    assign router_local_weight_addr_valid_out = ctrl_weight_addr_valid_out;
    assign router_local_weight_addr_data_out = ctrl_weight_addr_data_out;
    assign router_local_weight_data_valid_out = ctrl_weight_data_valid_out;
    assign router_local_weight_data_out = ctrl_weight_data_out;

    // PSUM result returns from HMesh through the router side.
    assign router_local_psum_return_ready_out = ctrl_psum_col_ready_w;
    assign router_local_psum_forward_valid_out = 4'h0;
    assign router_local_psum_forward_data_out = 168'sd0;
    assign router_north_psum_forward_valid_out = ctrl_psum_seed_valid_out;
    assign router_north_psum_forward_data_out = ctrl_psum_seed_data_out;
    assign psum_col_valid_w = router_local_psum_return_valid_in;
    assign psum_col_data_w = router_local_psum_return_data_in;

    // Four GLB input streams:
    // bit0=IACT_ADDR, bit1=IACT_DATA, bit2=Weight_ADDR, bit3=Weight_DATA.
    wire [3:0]                  ctrl_glb_input_rd_valid_w;
    wire [3:0]                  ctrl_glb_input_rd_ready_w;
    wire [(4*GLB_AW)-1:0]       ctrl_glb_input_rd_addr_w;
    wire [3:0]                  ctrl_glb_input_resp_valid_w;
    wire [3:0]                  ctrl_glb_input_resp_ready_w;
    wire [194:0]                ctrl_glb_input_resp_data_w;

    assign glb_iact_addr_rd_valid_out = ctrl_glb_input_rd_valid_w[0];
    assign glb_iact_data_rd_valid_out = ctrl_glb_input_rd_valid_w[1];
    assign glb_weight_addr_rd_valid_out = ctrl_glb_input_rd_valid_w[2];
    assign glb_weight_data_rd_valid_out = ctrl_glb_input_rd_valid_w[3];
    assign ctrl_glb_input_rd_ready_w = {
        glb_weight_data_rd_ready_in,
        glb_weight_addr_rd_ready_in,
        glb_iact_data_rd_ready_in,
        glb_iact_addr_rd_ready_in
    };
    assign glb_iact_addr_rd_addr_out = ctrl_glb_input_rd_addr_w[(0*GLB_AW) +: GLB_AW];
    assign glb_iact_data_rd_addr_out = ctrl_glb_input_rd_addr_w[(1*GLB_AW) +: GLB_AW];
    assign glb_weight_addr_rd_addr_out = ctrl_glb_input_rd_addr_w[(2*GLB_AW) +: GLB_AW];
    assign glb_weight_data_rd_addr_out = ctrl_glb_input_rd_addr_w[(3*GLB_AW) +: GLB_AW];
    assign ctrl_glb_input_resp_valid_w = {
        glb_weight_data_resp_valid_in,
        glb_weight_addr_resp_valid_in,
        glb_iact_data_resp_valid_in,
        glb_iact_addr_resp_valid_in
    };
    assign glb_iact_addr_resp_ready_out = ctrl_glb_input_resp_ready_w[0];
    assign glb_iact_data_resp_ready_out = ctrl_glb_input_resp_ready_w[1];
    assign glb_weight_addr_resp_ready_out = ctrl_glb_input_resp_ready_w[2];
    assign glb_weight_data_resp_ready_out = ctrl_glb_input_resp_ready_w[3];
    assign ctrl_glb_input_resp_data_w = {
        glb_weight_data_resp_data_in,
        glb_weight_addr_resp_data_in,
        glb_iact_data_resp_data_in,
        glb_iact_addr_resp_data_in
    };

    PE_Cluster3x4_Dataflow_Controller #(
        .GLB_AW(GLB_AW)
    ) u_dataflow_ctrl (
        .clk(clk),
        .rst(rst),
        .ctrl_job_start_in(ctrl_job_start_in),
        .ctrl_job_busy_out(ctrl_job_busy_w),
        .ctrl_job_done_out(ctrl_job_done_w),
        .desc_c_in_in(desc_c_in_in),
        .desc_active_pe_mask_in(desc_active_pe_mask_in),
        .desc_output_window_count_in(desc_output_window_count_in),
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
        .desc_psum_read_base_in(desc_psum_read_base_in),
        .desc_psum_read_count_in(desc_psum_read_count_in),
        .desc_psum_write_base_in(desc_psum_write_base_in),
        .desc_m0_in(desc_m0_in),
        .glb_input_rd_valid_out(ctrl_glb_input_rd_valid_w),
        .glb_input_rd_ready_in(ctrl_glb_input_rd_ready_w),
        .glb_input_rd_addr_out(ctrl_glb_input_rd_addr_w),
        .glb_input_resp_valid_in(ctrl_glb_input_resp_valid_w),
        .glb_input_resp_ready_out(ctrl_glb_input_resp_ready_w),
        .glb_input_resp_data_in(ctrl_glb_input_resp_data_w),
        .hm_pe_iact_addr_write_fin_in(pe_iact_addr_write_fin_w),
        .hm_pe_iact_data_write_fin_in(pe_iact_data_write_fin_w),
        .hm_pe_weight_addr_write_fin_in(pe_weight_addr_write_fin_w),
        .hm_pe_weight_data_write_fin_in(pe_weight_data_write_fin_w),
        .hm_pe_slide_safe_in(pe_slide_safe_w),
        .hm_pe_cal_fin_in(pe_cal_fin_w),
        .hm_pe_psum_acc_fin_in(pe_psum_acc_fin_w),
        .hm_iact_addr_ready_in(router_local_iact_addr_ready_in),
        .hm_iact_data_ready_in(router_local_iact_data_ready_in),
        .hm_weight_addr_ready_in(router_local_weight_addr_ready_in),
        .hm_weight_data_ready_in(router_local_weight_data_ready_in),
        .hm_psum_seed_ready_in(router_north_psum_forward_ready_in),
        .hm_psum_col_valid_in(psum_col_valid_w),
        .hm_psum_col_data_in(psum_col_data_w),
        .glb_psum_wr_valid_out(ctrl_glb_psum_wr_valid_w),
        .glb_psum_wr_ready_in(glb_psum_wr_ready_in),
        .glb_psum_wr_addr_out(ctrl_glb_psum_wr_addr_w),
        .glb_psum_wr_data_out(ctrl_glb_psum_wr_data_w),
        .glb_psum_rd_valid_out(glb_psum_rd_valid_out),
        .glb_psum_rd_ready_in(glb_psum_rd_ready_in),
        .glb_psum_rd_addr_out(glb_psum_rd_addr_out),
        .glb_psum_rd_valid_in(glb_psum_rd_valid_in),
        .glb_psum_rd_ready_out(glb_psum_rd_ready_out),
        .glb_psum_rd_data_in(glb_psum_rd_data_in),
        .ctrl_psum_col_ready_out(ctrl_psum_col_ready_w),
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
        .ctrl_psum_seed_valid_out(ctrl_psum_seed_valid_out),
        .ctrl_psum_seed_data_out(ctrl_psum_seed_data_out),
        .ctrl_pe_disable_out(ctrl_pe_disable_out),
        .ctrl_psum_enq_en_out(ctrl_psum_enq_en_out),
        .ctrl_do_load_en_out(ctrl_do_load_en_out),
        .ctrl_do_mac_en_out(ctrl_do_mac_en_out),
        .ctrl_iact_write_fin_clear_out(ctrl_iact_write_fin_clear_out),
        .ctrl_weight_write_fin_clear_out(ctrl_weight_write_fin_clear_out),
        .ctrl_psum_spad_clear_out(ctrl_psum_spad_clear_out),
        .ctrl_cfg_segment_len_out(ctrl_cfg_segment_len_out),
        .ctrl_cfg_window_seg_count_out(ctrl_cfg_window_seg_count_out),
        .ctrl_cfg_m0_out(ctrl_cfg_m0_out),
        .ctrl_cfg_iact_flush_out(ctrl_cfg_iact_flush_out),
        .ctrl_cfg_slide_commit_out(ctrl_cfg_slide_commit_out)
    );

    PE_Cluster3x4_HMesh u_hmesh (
        .clk(clk),
        .rst(rst),
        .iact_addr_slot_valid_in(router_pe_iact_addr_valid_in),
        .iact_addr_slot_ready_out(router_pe_iact_addr_ready_out),
        .iact_addr_data_in(router_pe_iact_addr_data_in),
        .iact_addr_dst_mask_in(ctrl_iact_addr_dst_mask_out),
        .iact_data_slot_valid_in(router_pe_iact_data_valid_in),
        .iact_data_slot_ready_out(router_pe_iact_data_ready_out),
        .iact_data_in(router_pe_iact_data_in),
        .iact_data_dst_mask_in(ctrl_iact_data_dst_mask_out),
        .weight_addr_valid_in(router_pe_weight_addr_valid_in),
        .weight_addr_ready_out(router_pe_weight_addr_ready_out),
        .weight_addr_in(router_pe_weight_addr_data_in),
        .weight_addr_row_dst_mask_in(ctrl_weight_addr_row_dst_mask_out),
        .weight_data_valid_in(router_pe_weight_data_valid_in),
        .weight_data_ready_out(router_pe_weight_data_ready_out),
        .weight_data_in(router_pe_weight_data_in),
        .weight_data_row_dst_mask_in(ctrl_weight_data_row_dst_mask_out),
        .psum_col_valid_in(router_pe_psum_forward_valid_in),
        .psum_col_ready_out(router_pe_psum_forward_ready_out),
        .psum_col_data_in(router_pe_psum_forward_data_in),
        .psum_col_valid_out(router_pe_psum_return_valid_out),
        .psum_col_ready_in(router_pe_psum_return_ready_in),
        .psum_col_data_out(router_pe_psum_return_data_out),
        .pe_disable_in(ctrl_pe_disable_out),
        .psum_enq_en_in(ctrl_psum_enq_en_out),
        .do_load_en_in(ctrl_do_load_en_out),
        .do_mac_en_in(ctrl_do_mac_en_out),
        .iact_write_fin_clear_in(ctrl_iact_write_fin_clear_out),
        .weight_write_fin_clear_in(ctrl_weight_write_fin_clear_out),
        .psum_spad_clear_in(ctrl_psum_spad_clear_out),
        .ctrl_cfg_segment_len_in(ctrl_cfg_segment_len_out),
        .ctrl_cfg_window_seg_count_in(ctrl_cfg_window_seg_count_out),
        .ctrl_cfg_m0_in(ctrl_cfg_m0_out),
        .ctrl_cfg_iact_flush_in(ctrl_cfg_iact_flush_out),
        .ctrl_cfg_slide_commit_in(ctrl_cfg_slide_commit_out),
        .pe_iact_addr_write_fin_out(pe_iact_addr_write_fin_w),
        .pe_iact_data_write_fin_out(pe_iact_data_write_fin_w),
        .pe_weight_addr_write_fin_out(pe_weight_addr_write_fin_w),
        .pe_weight_data_write_fin_out(pe_weight_data_write_fin_w),
        .pe_psum_acc_fin_out(pe_psum_acc_fin_w),
        .pe_slide_safe_out(pe_slide_safe_w),
        .pe_cal_fin_out(pe_cal_fin_w)
    );

endmodule
