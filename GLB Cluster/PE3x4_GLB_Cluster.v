`timescale 1ns/1ps
`default_nettype none

// ============================================================================
// Module      : PE3x4_GLB_Cluster
// Author      : Do Quoc Khanh
// Description : Cluster-local payload storage for IACT, Weight, and PSUM data.
//               Provides host preload/readback access and controller-side read
//               ports for compute-time payload supply.
//               Weight storage includes ping-pong control for tile reuse.
//               Scheduling and destination metadata are generated outside GLB.
// ============================================================================

module PE3x4_GLB_Cluster #(
    parameter integer AWIDTH = 8
)(
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 host_wr_valid_in,
    output wire                 host_wr_ready_out,
    input  wire [2:0]           host_wr_region_in,
    input  wire [AWIDTH-1:0]    host_wr_addr_in,
    input  wire [167:0]         host_wr_data_in,

    input  wire                 weight_host_load_start_in,
    input  wire                 weight_host_load_buf_sel_in,
    input  wire                 weight_host_load_done_in,
    input  wire                 weight_compute_acquire_in,
    input  wire                 weight_compute_buf_sel_in,
    input  wire                 weight_compute_release_in,
    input  wire                 weight_error_clear_in,
    output wire                 weight_error_out,
    output wire                 weight_ping_valid_out,
    output wire                 weight_pong_valid_out,
    output wire                 weight_ping_busy_out,
    output wire                 weight_pong_busy_out,

    input  wire                 host_rd_valid_in,
    output wire                 host_rd_ready_out,
    input  wire [2:0]           host_rd_region_in,
    input  wire [AWIDTH-1:0]    host_rd_addr_in,
    output wire                 host_rd_valid_out,
    input  wire                 host_rd_ready_in,
    output wire [167:0]         host_rd_data_out,

    input  wire                 iact_addr_ctrl_rd_valid_in,
    output wire                 iact_addr_ctrl_rd_ready_out,
    input  wire [AWIDTH-1:0]    iact_addr_ctrl_rd_addr_in,
    output wire                 iact_addr_ctrl_rd_valid_out,
    input  wire                 iact_addr_ctrl_rd_ready_in,
    output wire [29:0]          iact_addr_ctrl_rd_data_out,
    input  wire                 iact_data_ctrl_rd_valid_in,
    output wire                 iact_data_ctrl_rd_ready_out,
    input  wire [AWIDTH-1:0]    iact_data_ctrl_rd_addr_in,
    output wire                 iact_data_ctrl_rd_valid_out,
    input  wire                 iact_data_ctrl_rd_ready_in,
    output wire [71:0]          iact_data_ctrl_rd_data_out,

    input  wire                 weight_addr_ctrl_rd_valid_in,
    output wire                 weight_addr_ctrl_rd_ready_out,
    input  wire [AWIDTH-1:0]    weight_addr_ctrl_rd_addr_in,
    output wire                 weight_addr_ctrl_rd_valid_out,
    input  wire                 weight_addr_ctrl_rd_ready_in,
    output wire [20:0]          weight_addr_ctrl_rd_data_out,
    input  wire                 weight_data_ctrl_rd_valid_in,
    output wire                 weight_data_ctrl_rd_ready_out,
    input  wire [AWIDTH-1:0]    weight_data_ctrl_rd_addr_in,
    output wire                 weight_data_ctrl_rd_valid_out,
    input  wire                 weight_data_ctrl_rd_ready_in,
    output wire [71:0]          weight_data_ctrl_rd_data_out,

    input  wire                 psum_wr_valid_in,
    output wire                 psum_wr_ready_out,
    input  wire [AWIDTH-1:0]    psum_wr_addr_in,
    input  wire [167:0]         psum_wr_data_in,
    input  wire                 psum_ctrl_rd_valid_in,
    output wire                 psum_ctrl_rd_ready_out,
    input  wire [AWIDTH-1:0]    psum_ctrl_rd_addr_in,
    output wire                 psum_ctrl_rd_valid_out,
    input  wire                 psum_ctrl_rd_ready_in,
    output wire [167:0]         psum_ctrl_rd_data_out
);

    localparam [2:0] REGION_IACT_ADDR  = 3'd0;
    localparam [2:0] REGION_IACT_DATA  = 3'd1;
    localparam [2:0] REGION_WEIGHT_ADDR = 3'd2;
    localparam [2:0] REGION_WEIGHT_DATA = 3'd3;
    localparam [2:0] REGION_PSUM       = 3'd4;

    wire host_wr_region_valid_w = (host_wr_region_in == REGION_IACT_ADDR) || (host_wr_region_in == REGION_IACT_DATA) || (host_wr_region_in == REGION_WEIGHT_ADDR) || (host_wr_region_in == REGION_WEIGHT_DATA) || (host_wr_region_in == REGION_PSUM);
    wire host_rd_region_valid_w = (host_rd_region_in == REGION_IACT_ADDR) || (host_rd_region_in == REGION_IACT_DATA) || (host_rd_region_in == REGION_PSUM);

    wire iact_addr_wr_ready_w, iact_data_wr_ready_w, weight_addr_wr_ready_w, weight_data_wr_ready_w, psum_wr_ready_w;
    wire iact_addr_host_rd_ready_w, iact_data_host_rd_ready_w, psum_host_rd_ready_w;
    wire iact_addr_host_rd_valid_w, iact_data_host_rd_valid_w, psum_host_rd_valid_w;
    
    wire [29:0] iact_addr_host_rd_data_w;
    wire [71:0] iact_data_host_rd_data_w;
    wire [167:0] psum_host_rd_data_w;
    
    wire iact_addr_ctrl_rd_ready_w, iact_data_ctrl_rd_ready_w, weight_addr_ctrl_rd_ready_w, weight_data_ctrl_rd_ready_w, psum_ctrl_rd_ready_w;
    wire iact_addr_ctrl_rd_valid_w, iact_data_ctrl_rd_valid_w, weight_addr_ctrl_rd_valid_w, weight_data_ctrl_rd_valid_w, psum_ctrl_rd_valid_w;
    
    wire [29:0] iact_addr_ctrl_rd_data_w;
    wire [71:0] iact_data_ctrl_rd_data_w;
    wire [20:0] weight_addr_ctrl_rd_data_w;
    wire [71:0] weight_data_ctrl_rd_data_w;
    wire [167:0] psum_ctrl_rd_data_w;
   
    wire iact_addr_host_rd_capture_ready_w;
    wire iact_data_host_rd_capture_ready_w;
    
    wire psum_host_rd_capture_ready_w;
    wire host_psum_wr_valid_w = host_wr_valid_in && (host_wr_region_in == REGION_PSUM) && !psum_wr_valid_in;
    wire psum_mem_wr_valid_w = psum_wr_valid_in || host_psum_wr_valid_w;
    wire [AWIDTH-1:0] psum_mem_wr_addr_w = psum_wr_valid_in ? psum_wr_addr_in : host_wr_addr_in;
    wire [167:0] psum_mem_wr_data_w = psum_wr_valid_in ? psum_wr_data_in : host_wr_data_in;

    PE3x4_GLB_IACT_ADDR_MEM #(.AWIDTH(AWIDTH)) u_iact_addr (.clk(clk), .rst(rst), .host_wr_valid_in(host_wr_valid_in && host_wr_region_in == REGION_IACT_ADDR), .host_wr_ready_out(iact_addr_wr_ready_w), .host_wr_addr_in(host_wr_addr_in), .host_wr_data_in(host_wr_data_in[29:0]), .host_rd_valid_in(host_rd_valid_in && host_rd_region_in == REGION_IACT_ADDR), .host_rd_ready_out(iact_addr_host_rd_ready_w), .host_rd_addr_in(host_rd_addr_in), .host_rd_valid_out(iact_addr_host_rd_valid_w), .host_rd_ready_in(iact_addr_host_rd_capture_ready_w), .host_rd_data_out(iact_addr_host_rd_data_w), .ctrl_rd_valid_in(iact_addr_ctrl_rd_valid_in), .ctrl_rd_ready_out(iact_addr_ctrl_rd_ready_w), .ctrl_rd_addr_in(iact_addr_ctrl_rd_addr_in), .ctrl_rd_valid_out(iact_addr_ctrl_rd_valid_w), .ctrl_rd_ready_in(iact_addr_ctrl_rd_ready_in), .ctrl_rd_data_out(iact_addr_ctrl_rd_data_w));
    PE3x4_GLB_IACT_DATA_MEM #(.AWIDTH(AWIDTH)) u_iact_data (.clk(clk), .rst(rst), .host_wr_valid_in(host_wr_valid_in && host_wr_region_in == REGION_IACT_DATA), .host_wr_ready_out(iact_data_wr_ready_w), .host_wr_addr_in(host_wr_addr_in), .host_wr_data_in(host_wr_data_in[71:0]), .host_rd_valid_in(host_rd_valid_in && host_rd_region_in == REGION_IACT_DATA), .host_rd_ready_out(iact_data_host_rd_ready_w), .host_rd_addr_in(host_rd_addr_in), .host_rd_valid_out(iact_data_host_rd_valid_w), .host_rd_ready_in(iact_data_host_rd_capture_ready_w), .host_rd_data_out(iact_data_host_rd_data_w), .ctrl_rd_valid_in(iact_data_ctrl_rd_valid_in), .ctrl_rd_ready_out(iact_data_ctrl_rd_ready_w), .ctrl_rd_addr_in(iact_data_ctrl_rd_addr_in), .ctrl_rd_valid_out(iact_data_ctrl_rd_valid_w), .ctrl_rd_ready_in(iact_data_ctrl_rd_ready_in), .ctrl_rd_data_out(iact_data_ctrl_rd_data_w));
    
    PE3x4_GLB_WEIGHT_PINGPONG #(.AWIDTH(AWIDTH)) u_weight_pingpong (
        .clk(clk), .rst(rst),
        .host_load_start_in(weight_host_load_start_in),
        .host_load_buf_sel_in(weight_host_load_buf_sel_in),
        .host_load_done_in(weight_host_load_done_in),
        .host_weight_addr_wr_valid_in(host_wr_valid_in && host_wr_region_in == REGION_WEIGHT_ADDR),
        .host_weight_addr_wr_ready_out(weight_addr_wr_ready_w),
        .host_weight_addr_wr_addr_in(host_wr_addr_in),
        .host_weight_addr_wr_data_in(host_wr_data_in[20:0]),
        .host_weight_data_wr_valid_in(host_wr_valid_in && host_wr_region_in == REGION_WEIGHT_DATA),
        .host_weight_data_wr_ready_out(weight_data_wr_ready_w),
        .host_weight_data_wr_addr_in(host_wr_addr_in),
        .host_weight_data_wr_data_in(host_wr_data_in[71:0]),
        .compute_acquire_in(weight_compute_acquire_in),
        .compute_buf_sel_in(weight_compute_buf_sel_in),
        .compute_release_in(weight_compute_release_in),
        .ctrl_weight_addr_rd_valid_in(weight_addr_ctrl_rd_valid_in),
        .ctrl_weight_addr_rd_ready_out(weight_addr_ctrl_rd_ready_w),
        .ctrl_weight_addr_rd_addr_in(weight_addr_ctrl_rd_addr_in),
        .ctrl_weight_addr_rd_valid_out(weight_addr_ctrl_rd_valid_w),
        .ctrl_weight_addr_rd_ready_in(weight_addr_ctrl_rd_ready_in),
        .ctrl_weight_addr_rd_data_out(weight_addr_ctrl_rd_data_w),
        .ctrl_weight_data_rd_valid_in(weight_data_ctrl_rd_valid_in),
        .ctrl_weight_data_rd_ready_out(weight_data_ctrl_rd_ready_w),
        .ctrl_weight_data_rd_addr_in(weight_data_ctrl_rd_addr_in),
        .ctrl_weight_data_rd_valid_out(weight_data_ctrl_rd_valid_w),
        .ctrl_weight_data_rd_ready_in(weight_data_ctrl_rd_ready_in),
        .ctrl_weight_data_rd_data_out(weight_data_ctrl_rd_data_w),
        .error_clear_in(weight_error_clear_in),
        .error_out(weight_error_out),
        .ping_valid_out(weight_ping_valid_out),
        .pong_valid_out(weight_pong_valid_out),
        .ping_busy_out(weight_ping_busy_out),
        .pong_busy_out(weight_pong_busy_out),
        .load_active_out(),
        .load_buf_sel_out(),
        .compute_active_out(),
        .compute_buf_sel_out()
    );
    PE3x4_GLB_PSUM_MEM #(.AWIDTH(AWIDTH)) u_psum (.clk(clk), .rst(rst), .wr_valid_in(psum_mem_wr_valid_w), .wr_ready_out(psum_wr_ready_w), .wr_addr_in(psum_mem_wr_addr_w), .wr_data_in(psum_mem_wr_data_w), .ctrl_rd_valid_in(psum_ctrl_rd_valid_in), .ctrl_rd_ready_out(psum_ctrl_rd_ready_w), .ctrl_rd_addr_in(psum_ctrl_rd_addr_in), .ctrl_rd_valid_out(psum_ctrl_rd_valid_w), .ctrl_rd_ready_in(psum_ctrl_rd_ready_in), .ctrl_rd_data_out(psum_ctrl_rd_data_w), .host_rd_valid_in(host_rd_valid_in && host_rd_region_in == REGION_PSUM), .host_rd_ready_out(psum_host_rd_ready_w), .host_rd_addr_in(host_rd_addr_in), .host_rd_valid_out(psum_host_rd_valid_w), .host_rd_ready_in(psum_host_rd_capture_ready_w), .host_rd_data_out(psum_host_rd_data_w));

    reg [2:0] host_rd_region_r;
    reg [167:0] host_rd_data_r;
    reg host_rd_valid_r;
    reg host_rd_pending_r;

    wire host_rd_accept_w = host_rd_valid_in && host_rd_ready_out;
    wire host_capture_enable_w = host_rd_pending_r && !host_rd_valid_r;
    
     assign iact_addr_host_rd_capture_ready_w = host_capture_enable_w && (host_rd_region_r == REGION_IACT_ADDR);
    assign iact_data_host_rd_capture_ready_w = host_capture_enable_w && (host_rd_region_r == REGION_IACT_DATA);
    assign psum_host_rd_capture_ready_w = host_capture_enable_w && (host_rd_region_r == REGION_PSUM);

    assign host_wr_ready_out = host_wr_region_valid_w && ((host_wr_region_in == REGION_IACT_ADDR) ? iact_addr_wr_ready_w : (host_wr_region_in == REGION_IACT_DATA) ? iact_data_wr_ready_w : (host_wr_region_in == REGION_WEIGHT_ADDR) ? weight_addr_wr_ready_w : (host_wr_region_in == REGION_WEIGHT_DATA) ? weight_data_wr_ready_w : (host_wr_region_in == REGION_PSUM) ? (!psum_wr_valid_in && psum_wr_ready_w) : 1'b0);
    assign host_rd_ready_out = host_rd_region_valid_w && !host_rd_valid_r && !host_rd_pending_r && ((host_rd_region_in == REGION_IACT_ADDR) ? iact_addr_host_rd_ready_w : (host_rd_region_in == REGION_IACT_DATA) ? iact_data_host_rd_ready_w : (host_rd_region_in == REGION_PSUM) ? psum_host_rd_ready_w : 1'b0);

    assign host_rd_valid_out = host_rd_valid_r;
    assign host_rd_data_out = host_rd_data_r;
    
    assign iact_addr_ctrl_rd_ready_out = iact_addr_ctrl_rd_ready_w;
    assign iact_data_ctrl_rd_ready_out = iact_data_ctrl_rd_ready_w;
    assign weight_addr_ctrl_rd_ready_out = weight_addr_ctrl_rd_ready_w;
    assign weight_data_ctrl_rd_ready_out = weight_data_ctrl_rd_ready_w;
    assign psum_ctrl_rd_ready_out = psum_ctrl_rd_ready_w;
    assign psum_wr_ready_out = psum_wr_ready_w && !host_psum_wr_valid_w;
   
    assign iact_addr_ctrl_rd_valid_out = iact_addr_ctrl_rd_valid_w;
    assign iact_data_ctrl_rd_valid_out = iact_data_ctrl_rd_valid_w;
    assign weight_addr_ctrl_rd_valid_out = weight_addr_ctrl_rd_valid_w;
    assign weight_data_ctrl_rd_valid_out = weight_data_ctrl_rd_valid_w;
    assign psum_ctrl_rd_valid_out = psum_ctrl_rd_valid_w;
  
    assign iact_addr_ctrl_rd_data_out = iact_addr_ctrl_rd_data_w;
    assign iact_data_ctrl_rd_data_out = iact_data_ctrl_rd_data_w;
    assign weight_addr_ctrl_rd_data_out = weight_addr_ctrl_rd_data_w;
    assign weight_data_ctrl_rd_data_out = weight_data_ctrl_rd_data_w;
    assign psum_ctrl_rd_data_out = psum_ctrl_rd_data_w;

   // Sequential logics
    always @(posedge clk) begin
        if (rst) begin
            host_rd_region_r <= 3'b000;
            host_rd_data_r <= 168'b0;
            host_rd_valid_r <= 1'b0;
            host_rd_pending_r <= 1'b0;
        end else begin
            if (host_rd_valid_r && host_rd_ready_in) begin
                host_rd_valid_r <= 1'b0;
            end

            if (host_rd_accept_w) begin
                host_rd_region_r <= host_rd_region_in;
                host_rd_pending_r <= 1'b1;
            end

            if (host_capture_enable_w) begin
                case (host_rd_region_r)
                    REGION_IACT_ADDR: if (iact_addr_host_rd_valid_w) begin
                        host_rd_data_r <= {138'b0, iact_addr_host_rd_data_w};
                        host_rd_valid_r <= 1'b1;
                        host_rd_pending_r <= 1'b0;
                    end
                    REGION_IACT_DATA: if (iact_data_host_rd_valid_w) begin
                        host_rd_data_r <= {96'b0, iact_data_host_rd_data_w};
                        host_rd_valid_r <= 1'b1;
                        host_rd_pending_r <= 1'b0;
                    end
                    REGION_PSUM: if (psum_host_rd_valid_w) begin
                        host_rd_data_r <= psum_host_rd_data_w;
                        host_rd_valid_r <= 1'b1;
                        host_rd_pending_r <= 1'b0;
                    end
                    default: host_rd_pending_r <= 1'b0;
                endcase
            end
        end
    end
endmodule

`default_nettype wire
