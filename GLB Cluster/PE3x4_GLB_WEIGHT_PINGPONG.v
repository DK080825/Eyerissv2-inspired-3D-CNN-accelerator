`timescale 1ns/1ps
`default_nettype none

// ============================================================================
// Module      : PE3x4_GLB_WEIGHT_PINGPONG
// Author      : Do Quoc Khanh
// Description : Lightweight ping-pong wrapper for Weight GLB storage.
//               Each buffer contains one Weight ADDR memory and one Weight DATA
//               memory. Host/DMA writes one buffer while the controller may read
//               the other buffer. This module does not generate schedule,
//               masks, or PE delivery metadata.
// ============================================================================

module PE3x4_GLB_WEIGHT_PINGPONG #(
    parameter integer AWIDTH = 8
) (
    input  wire                 clk,
    input  wire                 rst,

    input  wire                 host_buf_sel_in,
    input  wire                 compute_buf_sel_in,

    input  wire                 host_addr_wr_valid_in,
    output wire                 host_addr_wr_ready_out,
    input  wire [AWIDTH-1:0]    host_addr_wr_addr_in,
    input  wire [20:0]          host_addr_wr_data_in,

    input  wire                 host_data_wr_valid_in,
    output wire                 host_data_wr_ready_out,
    input  wire [AWIDTH-1:0]    host_data_wr_addr_in,
    input  wire [71:0]          host_data_wr_data_in,

    input  wire                 host_addr_rd_valid_in,
    output wire                 host_addr_rd_ready_out,
    input  wire [AWIDTH-1:0]    host_addr_rd_addr_in,
    output wire                 host_addr_rd_valid_out,
    input  wire                 host_addr_rd_ready_in,
    output wire [20:0]          host_addr_rd_data_out,

    input  wire                 host_data_rd_valid_in,
    output wire                 host_data_rd_ready_out,
    input  wire [AWIDTH-1:0]    host_data_rd_addr_in,
    output wire                 host_data_rd_valid_out,
    input  wire                 host_data_rd_ready_in,
    output wire [71:0]          host_data_rd_data_out,

    input  wire                 ctrl_addr_rd_valid_in,
    output wire                 ctrl_addr_rd_ready_out,
    input  wire [AWIDTH-1:0]    ctrl_addr_rd_addr_in,
    output wire                 ctrl_addr_rd_valid_out,
    input  wire                 ctrl_addr_rd_ready_in,
    output wire [20:0]          ctrl_addr_rd_data_out,

    input  wire                 ctrl_data_rd_valid_in,
    output wire                 ctrl_data_rd_ready_out,
    input  wire [AWIDTH-1:0]    ctrl_data_rd_addr_in,
    output wire                 ctrl_data_rd_valid_out,
    input  wire                 ctrl_data_rd_ready_in,
    output wire [71:0]          ctrl_data_rd_data_out
);

    wire ping_addr_host_wr_ready_w;
    wire pong_addr_host_wr_ready_w;
    wire ping_data_host_wr_ready_w;
    wire pong_data_host_wr_ready_w;

    wire ping_addr_host_rd_ready_w;
    wire pong_addr_host_rd_ready_w;
    wire ping_data_host_rd_ready_w;
    wire pong_data_host_rd_ready_w;

    wire ping_addr_host_rd_valid_w;
    wire pong_addr_host_rd_valid_w;
    wire ping_data_host_rd_valid_w;
    wire pong_data_host_rd_valid_w;
    wire [20:0] ping_addr_host_rd_data_w;
    wire [20:0] pong_addr_host_rd_data_w;
    wire [71:0] ping_data_host_rd_data_w;
    wire [71:0] pong_data_host_rd_data_w;

    wire ping_addr_ctrl_rd_ready_w;
    wire pong_addr_ctrl_rd_ready_w;
    wire ping_data_ctrl_rd_ready_w;
    wire pong_data_ctrl_rd_ready_w;

    wire ping_addr_ctrl_rd_valid_w;
    wire pong_addr_ctrl_rd_valid_w;
    wire ping_data_ctrl_rd_valid_w;
    wire pong_data_ctrl_rd_valid_w;
    wire [20:0] ping_addr_ctrl_rd_data_w;
    wire [20:0] pong_addr_ctrl_rd_data_w;
    wire [71:0] ping_data_ctrl_rd_data_w;
    wire [71:0] pong_data_ctrl_rd_data_w;

    assign host_addr_wr_ready_out = host_buf_sel_in ? pong_addr_host_wr_ready_w : ping_addr_host_wr_ready_w;
    assign host_data_wr_ready_out = host_buf_sel_in ? pong_data_host_wr_ready_w : ping_data_host_wr_ready_w;
    assign host_addr_rd_ready_out = host_buf_sel_in ? pong_addr_host_rd_ready_w : ping_addr_host_rd_ready_w;
    assign host_data_rd_ready_out = host_buf_sel_in ? pong_data_host_rd_ready_w : ping_data_host_rd_ready_w;

    assign host_addr_rd_valid_out = host_buf_sel_in ? pong_addr_host_rd_valid_w : ping_addr_host_rd_valid_w;
    assign host_data_rd_valid_out = host_buf_sel_in ? pong_data_host_rd_valid_w : ping_data_host_rd_valid_w;
    assign host_addr_rd_data_out  = host_buf_sel_in ? pong_addr_host_rd_data_w  : ping_addr_host_rd_data_w;
    assign host_data_rd_data_out  = host_buf_sel_in ? pong_data_host_rd_data_w  : ping_data_host_rd_data_w;

    assign ctrl_addr_rd_ready_out = compute_buf_sel_in ? pong_addr_ctrl_rd_ready_w : ping_addr_ctrl_rd_ready_w;
    assign ctrl_data_rd_ready_out = compute_buf_sel_in ? pong_data_ctrl_rd_ready_w : ping_data_ctrl_rd_ready_w;
    assign ctrl_addr_rd_valid_out = compute_buf_sel_in ? pong_addr_ctrl_rd_valid_w : ping_addr_ctrl_rd_valid_w;
    assign ctrl_data_rd_valid_out = compute_buf_sel_in ? pong_data_ctrl_rd_valid_w : ping_data_ctrl_rd_valid_w;
    assign ctrl_addr_rd_data_out  = compute_buf_sel_in ? pong_addr_ctrl_rd_data_w  : ping_addr_ctrl_rd_data_w;
    assign ctrl_data_rd_data_out  = compute_buf_sel_in ? pong_data_ctrl_rd_data_w  : ping_data_ctrl_rd_data_w;

    PE3x4_GLB_WEIGHT_ADDR_MEM #(.AWIDTH(AWIDTH)) u_ping_addr (
        .clk(clk), .rst(rst),
        .host_wr_valid_in(host_addr_wr_valid_in && !host_buf_sel_in),
        .host_wr_ready_out(ping_addr_host_wr_ready_w),
        .host_wr_addr_in(host_addr_wr_addr_in),
        .host_wr_data_in(host_addr_wr_data_in),
        .host_rd_valid_in(host_addr_rd_valid_in && !host_buf_sel_in),
        .host_rd_ready_out(ping_addr_host_rd_ready_w),
        .host_rd_addr_in(host_addr_rd_addr_in),
        .host_rd_valid_out(ping_addr_host_rd_valid_w),
        .host_rd_ready_in(host_addr_rd_ready_in && !host_buf_sel_in),
        .host_rd_data_out(ping_addr_host_rd_data_w),
        .ctrl_rd_valid_in(ctrl_addr_rd_valid_in && !compute_buf_sel_in),
        .ctrl_rd_ready_out(ping_addr_ctrl_rd_ready_w),
        .ctrl_rd_addr_in(ctrl_addr_rd_addr_in),
        .ctrl_rd_valid_out(ping_addr_ctrl_rd_valid_w),
        .ctrl_rd_ready_in(ctrl_addr_rd_ready_in && !compute_buf_sel_in),
        .ctrl_rd_data_out(ping_addr_ctrl_rd_data_w)
    );

    PE3x4_GLB_WEIGHT_ADDR_MEM #(.AWIDTH(AWIDTH)) u_pong_addr (
        .clk(clk), .rst(rst),
        .host_wr_valid_in(host_addr_wr_valid_in && host_buf_sel_in),
        .host_wr_ready_out(pong_addr_host_wr_ready_w),
        .host_wr_addr_in(host_addr_wr_addr_in),
        .host_wr_data_in(host_addr_wr_data_in),
        .host_rd_valid_in(host_addr_rd_valid_in && host_buf_sel_in),
        .host_rd_ready_out(pong_addr_host_rd_ready_w),
        .host_rd_addr_in(host_addr_rd_addr_in),
        .host_rd_valid_out(pong_addr_host_rd_valid_w),
        .host_rd_ready_in(host_addr_rd_ready_in && host_buf_sel_in),
        .host_rd_data_out(pong_addr_host_rd_data_w),
        .ctrl_rd_valid_in(ctrl_addr_rd_valid_in && compute_buf_sel_in),
        .ctrl_rd_ready_out(pong_addr_ctrl_rd_ready_w),
        .ctrl_rd_addr_in(ctrl_addr_rd_addr_in),
        .ctrl_rd_valid_out(pong_addr_ctrl_rd_valid_w),
        .ctrl_rd_ready_in(ctrl_addr_rd_ready_in && compute_buf_sel_in),
        .ctrl_rd_data_out(pong_addr_ctrl_rd_data_w)
    );

    PE3x4_GLB_WEIGHT_DATA_MEM #(.AWIDTH(AWIDTH)) u_ping_data (
        .clk(clk), .rst(rst),
        .host_wr_valid_in(host_data_wr_valid_in && !host_buf_sel_in),
        .host_wr_ready_out(ping_data_host_wr_ready_w),
        .host_wr_addr_in(host_data_wr_addr_in),
        .host_wr_data_in(host_data_wr_data_in),
        .host_rd_valid_in(host_data_rd_valid_in && !host_buf_sel_in),
        .host_rd_ready_out(ping_data_host_rd_ready_w),
        .host_rd_addr_in(host_data_rd_addr_in),
        .host_rd_valid_out(ping_data_host_rd_valid_w),
        .host_rd_ready_in(host_data_rd_ready_in && !host_buf_sel_in),
        .host_rd_data_out(ping_data_host_rd_data_w),
        .ctrl_rd_valid_in(ctrl_data_rd_valid_in && !compute_buf_sel_in),
        .ctrl_rd_ready_out(ping_data_ctrl_rd_ready_w),
        .ctrl_rd_addr_in(ctrl_data_rd_addr_in),
        .ctrl_rd_valid_out(ping_data_ctrl_rd_valid_w),
        .ctrl_rd_ready_in(ctrl_data_rd_ready_in && !compute_buf_sel_in),
        .ctrl_rd_data_out(ping_data_ctrl_rd_data_w)
    );

    PE3x4_GLB_WEIGHT_DATA_MEM #(.AWIDTH(AWIDTH)) u_pong_data (
        .clk(clk), .rst(rst),
        .host_wr_valid_in(host_data_wr_valid_in && host_buf_sel_in),
        .host_wr_ready_out(pong_data_host_wr_ready_w),
        .host_wr_addr_in(host_data_wr_addr_in),
        .host_wr_data_in(host_data_wr_data_in),
        .host_rd_valid_in(host_data_rd_valid_in && host_buf_sel_in),
        .host_rd_ready_out(pong_data_host_rd_ready_w),
        .host_rd_addr_in(host_data_rd_addr_in),
        .host_rd_valid_out(pong_data_host_rd_valid_w),
        .host_rd_ready_in(host_data_rd_ready_in && host_buf_sel_in),
        .host_rd_data_out(pong_data_host_rd_data_w),
        .ctrl_rd_valid_in(ctrl_data_rd_valid_in && compute_buf_sel_in),
        .ctrl_rd_ready_out(pong_data_ctrl_rd_ready_w),
        .ctrl_rd_addr_in(ctrl_data_rd_addr_in),
        .ctrl_rd_valid_out(pong_data_ctrl_rd_valid_w),
        .ctrl_rd_ready_in(ctrl_data_rd_ready_in && compute_buf_sel_in),
        .ctrl_rd_data_out(pong_data_ctrl_rd_data_w)
    );

endmodule

`default_nettype wire
