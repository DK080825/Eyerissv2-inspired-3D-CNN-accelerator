// ============================================================================
// Module      : PE3x4_Cluster_System
// Author      : Do Quoc Khanh
// Description : One-cluster wrapper for GLB Cluster, Router Cluster,
//               Dataflow Controller, and PE_Cluster3x4_Top.
//               GLB stores payload only.
//               Dataflow Controller controls load, MAC, slide, and PE masks.
//               Router Cluster receives source/path config from this boundary.
//               This module is the external boundary of one PE cluster.
// ============================================================================

module PE3x4_Cluster_System #(
    parameter integer GLB_AW = 8
) (
    input  wire                        clk,
    input  wire                        rst,

    // Host/testbench -> GLB Cluster: write payload.
    input  wire                        glb_host_wr_valid_in,
    output wire                        glb_host_wr_ready_out,
    input  wire [2:0]                  glb_host_wr_region_in,
    input  wire [GLB_AW-1:0]           glb_host_wr_addr_in,
    input  wire [167:0]                glb_host_wr_data_in,

    // Host/testbench -> GLB Cluster: read payload.
    input  wire                        glb_host_rd_valid_in,
    output wire                        glb_host_rd_ready_out,
    input  wire [2:0]                  glb_host_rd_region_in,
    input  wire [GLB_AW-1:0]           glb_host_rd_addr_in,
    output wire                        glb_host_rd_valid_out,
    input  wire                        glb_host_rd_ready_in,
    output wire [167:0]                glb_host_rd_data_out,
    input  wire                        glb_psum_wr_ready_gate_in,
    input  wire                        glb_weight_host_buf_sel_in,

    // Host/testbench -> Dataflow Controller: start one job.
    input  wire                        ctrl_job_start_in,
    output wire                        ctrl_job_busy_out,
    output wire                        ctrl_job_done_out,

    // System config -> Router Cluster: choose source/path.
    input  wire [5:0]                  router_iact_data_in_sel_in,
    input  wire [8:0]                  router_iact_route_mask_in,
    input  wire [2:0]                  router_weight_data_in_sel_in,
    input  wire [2:0]                  router_weight_route_horizontal_in,
    input  wire [3:0]                  router_psum_data_in_sel_in,
    input  wire [3:0]                  router_psum_route_to_pe_in,

    // Host/testbench -> Dataflow Controller: tensor and GLB locations.
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
    input  wire                        desc_weight_compute_buf_sel_in,
    input  wire [GLB_AW-1:0]           desc_psum_read_base_in,
    input  wire [15:0]                 desc_psum_read_count_in,
    input  wire [GLB_AW-1:0]           desc_psum_write_base_in,
    input  wire [5:0]                  desc_m0_in
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

    localparam [2:0] GLB_REGION_IACT_ADDR   = 3'd0;
    localparam [2:0] GLB_REGION_IACT_DATA   = 3'd1;
    localparam [2:0] GLB_REGION_WEIGHT_ADDR = 3'd2;
    localparam [2:0] GLB_REGION_WEIGHT_DATA = 3'd3;
    localparam [2:0] GLB_REGION_PSUM        = 3'd4;

    wire host_wr_iact_addr_w   = glb_host_wr_valid_in && (glb_host_wr_region_in == GLB_REGION_IACT_ADDR);
    wire host_wr_iact_data_w   = glb_host_wr_valid_in && (glb_host_wr_region_in == GLB_REGION_IACT_DATA);
    wire host_wr_weight_addr_w = glb_host_wr_valid_in && (glb_host_wr_region_in == GLB_REGION_WEIGHT_ADDR);
    wire host_wr_weight_data_w = glb_host_wr_valid_in && (glb_host_wr_region_in == GLB_REGION_WEIGHT_DATA);
    wire host_wr_psum_w        = glb_host_wr_valid_in && (glb_host_wr_region_in == GLB_REGION_PSUM);

    wire host_rd_iact_addr_w   = glb_host_rd_valid_in && (glb_host_rd_region_in == GLB_REGION_IACT_ADDR);
    wire host_rd_iact_data_w   = glb_host_rd_valid_in && (glb_host_rd_region_in == GLB_REGION_IACT_DATA);
    wire host_rd_weight_addr_w = glb_host_rd_valid_in && (glb_host_rd_region_in == GLB_REGION_WEIGHT_ADDR);
    wire host_rd_weight_data_w = glb_host_rd_valid_in && (glb_host_rd_region_in == GLB_REGION_WEIGHT_DATA);
    wire host_rd_psum_w        = glb_host_rd_valid_in && (glb_host_rd_region_in == GLB_REGION_PSUM);

    wire iact_addr_host_rd_ready_w;
    wire iact_addr_host_rd_valid_w;
    wire [29:0] iact_addr_host_rd_data_w;
    wire iact_data_host_rd_ready_w;
    wire iact_data_host_rd_valid_w;
    wire [71:0] iact_data_host_rd_data_w;
    wire weight_addr_host_rd_ready_w;
    wire weight_addr_host_rd_valid_w;
    wire [20:0] weight_addr_host_rd_data_w;
    wire weight_data_host_rd_ready_w;
    wire weight_data_host_rd_valid_w;
    wire [71:0] weight_data_host_rd_data_w;
    wire psum_host_rd_ready_w;
    wire psum_host_rd_valid_w;
    wire [167:0] psum_host_rd_data_w;

    wire psum_store_wr_valid_w = (glb_psum_wr_valid_w && glb_psum_wr_ready_gate_in) || host_wr_psum_w;
    wire [GLB_AW-1:0] psum_store_wr_addr_w =
        (glb_psum_wr_valid_w && glb_psum_wr_ready_gate_in) ? glb_psum_wr_addr_w : glb_host_wr_addr_in;
    wire [167:0] psum_store_wr_data_w =
        (glb_psum_wr_valid_w && glb_psum_wr_ready_gate_in) ? glb_psum_wr_data_w : glb_host_wr_data_in;

    assign glb_host_wr_ready_out =
        (glb_host_wr_region_in == GLB_REGION_PSUM) ? !glb_psum_wr_valid_w : 1'b1;

    assign glb_host_rd_ready_out =
        (glb_host_rd_region_in == GLB_REGION_IACT_ADDR)   ? iact_addr_host_rd_ready_w :
        (glb_host_rd_region_in == GLB_REGION_IACT_DATA)   ? iact_data_host_rd_ready_w :
        (glb_host_rd_region_in == GLB_REGION_WEIGHT_ADDR) ? weight_addr_host_rd_ready_w :
        (glb_host_rd_region_in == GLB_REGION_WEIGHT_DATA) ? weight_data_host_rd_ready_w :
        (glb_host_rd_region_in == GLB_REGION_PSUM)        ? psum_host_rd_ready_w :
                                                            1'b0;

    assign glb_host_rd_valid_out =
        iact_addr_host_rd_valid_w |
        iact_data_host_rd_valid_w |
        weight_addr_host_rd_valid_w |
        weight_data_host_rd_valid_w |
        psum_host_rd_valid_w;

    assign glb_host_rd_data_out =
        iact_addr_host_rd_valid_w   ? {138'b0, iact_addr_host_rd_data_w} :
        iact_data_host_rd_valid_w   ? {96'b0, iact_data_host_rd_data_w} :
        weight_addr_host_rd_valid_w ? {147'b0, weight_addr_host_rd_data_w} :
        weight_data_host_rd_valid_w ? {96'b0, weight_data_host_rd_data_w} :
        psum_host_rd_valid_w        ? psum_host_rd_data_w :
                                      168'b0;

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
        .GLB_AW(GLB_AW)
    ) u_pe_cluster_top (
        .clk(clk),
        .rst(rst),
        .ctrl_job_start_in(ctrl_job_start_in),
        .ctrl_job_busy_out(ctrl_job_busy_out),
        .ctrl_job_done_out(ctrl_job_done_out),
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
        .glb_psum_rd_valid_in(glb_psum_rd_resp_valid_w),
        .glb_psum_rd_ready_out(glb_psum_rd_resp_ready_w),
        .glb_psum_rd_data_in(glb_psum_rd_resp_data_w),
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
        .router_pe_psum_forward_data_in(router_pe_psum_forward_data_w)
    );

    Router_Cluster u_router_cluster (
        .iact_data_in_sel_in(router_iact_data_in_sel_in),
        .iact_route_mask_in(router_iact_route_mask_in),
        .weight_data_in_sel_in(router_weight_data_in_sel_in),
        .weight_route_horizontal_in(router_weight_route_horizontal_in),
        .psum_data_in_sel_in(router_psum_data_in_sel_in),
        .psum_route_to_pe_in(router_psum_route_to_pe_in),

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

    PE3x4_GLB_IACT_ADDR_MEM #(.AWIDTH(GLB_AW)) u_glb_iact_addr (
        .clk(clk),
        .rst(rst),
        .host_wr_valid_in(host_wr_iact_addr_w),
        .host_wr_ready_out(),
        .host_wr_addr_in(glb_host_wr_addr_in),
        .host_wr_data_in(glb_host_wr_data_in[29:0]),
        .host_rd_valid_in(host_rd_iact_addr_w),
        .host_rd_ready_out(iact_addr_host_rd_ready_w),
        .host_rd_addr_in(glb_host_rd_addr_in),
        .host_rd_valid_out(iact_addr_host_rd_valid_w),
        .host_rd_ready_in(glb_host_rd_ready_in),
        .host_rd_data_out(iact_addr_host_rd_data_w),
        .ctrl_rd_valid_in(glb_iact_addr_rd_valid_w),
        .ctrl_rd_ready_out(glb_iact_addr_rd_ready_w),
        .ctrl_rd_addr_in(glb_iact_addr_rd_addr_w[GLB_AW-1:0]),
        .ctrl_rd_valid_out(glb_iact_addr_resp_valid_w),
        .ctrl_rd_ready_in(glb_iact_addr_resp_ready_w),
        .ctrl_rd_data_out(glb_iact_addr_resp_data_w)
    );

    PE3x4_GLB_IACT_DATA_MEM #(.AWIDTH(GLB_AW)) u_glb_iact_data (
        .clk(clk),
        .rst(rst),
        .host_wr_valid_in(host_wr_iact_data_w),
        .host_wr_ready_out(),
        .host_wr_addr_in(glb_host_wr_addr_in),
        .host_wr_data_in(glb_host_wr_data_in[71:0]),
        .host_rd_valid_in(host_rd_iact_data_w),
        .host_rd_ready_out(iact_data_host_rd_ready_w),
        .host_rd_addr_in(glb_host_rd_addr_in),
        .host_rd_valid_out(iact_data_host_rd_valid_w),
        .host_rd_ready_in(glb_host_rd_ready_in),
        .host_rd_data_out(iact_data_host_rd_data_w),
        .ctrl_rd_valid_in(glb_iact_data_rd_valid_w),
        .ctrl_rd_ready_out(glb_iact_data_rd_ready_w),
        .ctrl_rd_addr_in(glb_iact_data_rd_addr_w[GLB_AW-1:0]),
        .ctrl_rd_valid_out(glb_iact_data_resp_valid_w),
        .ctrl_rd_ready_in(glb_iact_data_resp_ready_w),
        .ctrl_rd_data_out(glb_iact_data_resp_data_w)
    );

    PE3x4_GLB_WEIGHT_PINGPONG #(.AWIDTH(GLB_AW)) u_glb_weight_pingpong (
        .clk(clk),
        .rst(rst),
        .host_buf_sel_in(glb_weight_host_buf_sel_in),
        .compute_buf_sel_in(desc_weight_compute_buf_sel_in),
        .host_addr_wr_valid_in(host_wr_weight_addr_w),
        .host_addr_wr_ready_out(),
        .host_addr_wr_addr_in(glb_host_wr_addr_in),
        .host_addr_wr_data_in(glb_host_wr_data_in[20:0]),
        .host_data_wr_valid_in(host_wr_weight_data_w),
        .host_data_wr_ready_out(),
        .host_data_wr_addr_in(glb_host_wr_addr_in),
        .host_data_wr_data_in(glb_host_wr_data_in[71:0]),
        .host_addr_rd_valid_in(host_rd_weight_addr_w),
        .host_addr_rd_ready_out(weight_addr_host_rd_ready_w),
        .host_addr_rd_addr_in(glb_host_rd_addr_in),
        .host_addr_rd_valid_out(weight_addr_host_rd_valid_w),
        .host_addr_rd_ready_in(glb_host_rd_ready_in),
        .host_addr_rd_data_out(weight_addr_host_rd_data_w),
        .host_data_rd_valid_in(host_rd_weight_data_w),
        .host_data_rd_ready_out(weight_data_host_rd_ready_w),
        .host_data_rd_addr_in(glb_host_rd_addr_in),
        .host_data_rd_valid_out(weight_data_host_rd_valid_w),
        .host_data_rd_ready_in(glb_host_rd_ready_in),
        .host_data_rd_data_out(weight_data_host_rd_data_w),
        .ctrl_addr_rd_valid_in(glb_weight_addr_rd_valid_w),
        .ctrl_addr_rd_ready_out(glb_weight_addr_rd_ready_w),
        .ctrl_addr_rd_addr_in(glb_weight_addr_rd_addr_w[GLB_AW-1:0]),
        .ctrl_addr_rd_valid_out(glb_weight_addr_resp_valid_w),
        .ctrl_addr_rd_ready_in(glb_weight_addr_resp_ready_w),
        .ctrl_addr_rd_data_out(glb_weight_addr_resp_data_w),
        .ctrl_data_rd_valid_in(glb_weight_data_rd_valid_w),
        .ctrl_data_rd_ready_out(glb_weight_data_rd_ready_w),
        .ctrl_data_rd_addr_in(glb_weight_data_rd_addr_w[GLB_AW-1:0]),
        .ctrl_data_rd_valid_out(glb_weight_data_resp_valid_w),
        .ctrl_data_rd_ready_in(glb_weight_data_resp_ready_w),
        .ctrl_data_rd_data_out(glb_weight_data_resp_data_w)
    );

    PE3x4_GLB_PSUM_MEM #(.AWIDTH(GLB_AW)) u_glb_psum (
        .clk(clk),
        .rst(rst),
        .wr_valid_in(psum_store_wr_valid_w),
        .wr_ready_out(glb_psum_wr_ready_w),
        .wr_addr_in(psum_store_wr_addr_w),
        .wr_data_in(psum_store_wr_data_w),
        .ctrl_rd_valid_in(glb_psum_rd_valid_w),
        .ctrl_rd_ready_out(glb_psum_rd_ready_w),
        .ctrl_rd_addr_in(glb_psum_rd_addr_w),
        .ctrl_rd_valid_out(glb_psum_rd_resp_valid_w),
        .ctrl_rd_ready_in(glb_psum_rd_resp_ready_w),
        .ctrl_rd_data_out(glb_psum_rd_resp_data_w),
        .host_rd_valid_in(host_rd_psum_w),
        .host_rd_ready_out(psum_host_rd_ready_w),
        .host_rd_addr_in(glb_host_rd_addr_in),
        .host_rd_valid_out(psum_host_rd_valid_w),
        .host_rd_ready_in(glb_host_rd_ready_in),
        .host_rd_data_out(psum_host_rd_data_w)
    );

endmodule
