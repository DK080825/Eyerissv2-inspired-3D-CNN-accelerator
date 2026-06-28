`timescale 1ns/1ps
`default_nettype none

// ============================================================================
// Module      : PE3x4_GLB_WEIGHT_ADDR_MEM
// Author      : Do Quoc Khanh
// Description : Payload-only GLB leaf memory for three Weight address row lanes.
//               Stores packed 7-bit address payloads for physical rows 0..2.
//               It does not store valid bits, row masks, routing metadata, or
//               Row-Stationary scheduling decisions.
// ============================================================================
//
// This leaf wrapper intentionally contains no valid bits, row_dst masks,
// routing, Row-Stationary scheduling, ky/lane mapping, ping-pong control,
// or HMesh ports.
// =============================================================================

module PE3x4_GLB_WEIGHT_ADDR_MEM #(
    parameter integer AWIDTH = 8
)(
    input  wire                 clk,
    input  wire                 rst,

    input  wire                 host_wr_valid_in,
    output wire                 host_wr_ready_out,
    input  wire [AWIDTH-1:0]    host_wr_addr_in,
    input  wire [20:0]          host_wr_data_in,

    input  wire                 host_rd_valid_in,
    output wire                 host_rd_ready_out,
    input  wire [AWIDTH-1:0]    host_rd_addr_in,
    output wire                 host_rd_valid_out,
    input  wire                 host_rd_ready_in,
    output wire [20:0]          host_rd_data_out,

    input  wire                 ctrl_rd_valid_in,
    output wire                 ctrl_rd_ready_out,
    input  wire [AWIDTH-1:0]    ctrl_rd_addr_in,
    output wire                 ctrl_rd_valid_out,
    input  wire                 ctrl_rd_ready_in,
    output wire [20:0]          ctrl_rd_data_out
);

    localparam integer BANK_COUNT = 3;
    localparam integer BANK_DW = 7;
    localparam integer TOTAL_DW = 21;

    PE3x4_GLB_Banked_Sync_Memory #(
        .AWIDTH(AWIDTH),
        .BANK_COUNT(BANK_COUNT),
        .BANK_DW(BANK_DW),
        .TOTAL_DW(TOTAL_DW),
        .READ_LATENCY(1),
        .ENABLE_HOST_READ(1),
        .ENABLE_DP_WRITE(0)
    ) u_mem (
        .clk(clk),
        .rst(rst),
        .host_wr_valid_in(host_wr_valid_in),
        .host_wr_ready_out(host_wr_ready_out),
        .host_wr_addr_in(host_wr_addr_in),
        .host_wr_data_in(host_wr_data_in),
        .host_rd_valid_in(host_rd_valid_in),
        .host_rd_ready_out(host_rd_ready_out),
        .host_rd_addr_in(host_rd_addr_in),
        .host_rd_valid_out(host_rd_valid_out),
        .host_rd_ready_in(host_rd_ready_in),
        .host_rd_data_out(host_rd_data_out),
        .ctrl_rd_valid_in(ctrl_rd_valid_in),
        .ctrl_rd_ready_out(ctrl_rd_ready_out),
        .ctrl_rd_addr_in(ctrl_rd_addr_in),
        .ctrl_rd_valid_out(ctrl_rd_valid_out),
        .ctrl_rd_ready_in(ctrl_rd_ready_in),
        .ctrl_rd_data_out(ctrl_rd_data_out),
        .dp_wr_valid_in(1'b0),
        .dp_wr_ready_out(),
        .dp_wr_addr_in({AWIDTH{1'b0}}),
        .dp_wr_data_in({TOTAL_DW{1'b0}})
    );

endmodule

`default_nettype wire
