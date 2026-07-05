`timescale 1ns/1ps
`default_nettype none

// ============================================================================
// Module      : PE3x4_GLB_IACT_ADDR_MEM
// Author      : Do Quoc Khanh
// Description : Payload-only GLB memory for IACT address payloads.
//               Stores three physical IACT lanes, each lane carrying two
//               5-bit address packets. This module is storage only: it does not
//               generate valid bits, masks, routes, schedules, or descriptors.
// ============================================================================

module PE3x4_GLB_IACT_ADDR_MEM #(
    parameter integer AWIDTH = 8
)(
    input  wire                 clk,
    input  wire                 rst,

    input  wire                 host_wr_valid_in,
    output wire                 host_wr_ready_out,
    input  wire [AWIDTH-1:0]    host_wr_addr_in,
    input  wire [29:0]          host_wr_data_in,

    input  wire                 host_rd_valid_in,
    output wire                 host_rd_ready_out,
    input  wire [AWIDTH-1:0]    host_rd_addr_in,
    output wire                 host_rd_valid_out,
    input  wire                 host_rd_ready_in,
    output wire [29:0]          host_rd_data_out,

    input  wire                 ctrl_rd_valid_in,
    output wire                 ctrl_rd_ready_out,
    input  wire [AWIDTH-1:0]    ctrl_rd_addr_in,
    output wire                 ctrl_rd_valid_out,
    input  wire                 ctrl_rd_ready_in,
    output wire [29:0]          ctrl_rd_data_out
);

    localparam integer DEPTH = (1 << AWIDTH);

    (* ram_style = "block" *) reg [29:0] mem_r [0:DEPTH-1];

    reg        ctrl_rd_valid_r;
    reg [29:0] ctrl_rd_data_r;

    reg        host_rd_valid_r;
    reg [29:0] host_rd_data_r;

    wire ctrl_rd_accept_w;
    wire host_rd_accept_w;

    assign host_wr_ready_out = 1'b1;

    assign ctrl_rd_ready_out = !ctrl_rd_valid_r || ctrl_rd_ready_in;
    assign ctrl_rd_accept_w = ctrl_rd_valid_in && ctrl_rd_ready_out;

    assign host_rd_ready_out = (!host_rd_valid_r || host_rd_ready_in) && !ctrl_rd_accept_w;
    assign host_rd_accept_w = host_rd_valid_in && host_rd_ready_out;

    assign ctrl_rd_valid_out = ctrl_rd_valid_r;
    assign ctrl_rd_data_out  = ctrl_rd_data_r;
    assign host_rd_valid_out = host_rd_valid_r;
    assign host_rd_data_out  = host_rd_data_r;

    always @(posedge clk) begin
        if (rst) begin
            ctrl_rd_valid_r <= 1'b0;
            ctrl_rd_data_r  <= 30'b0;
            host_rd_valid_r <= 1'b0;
            host_rd_data_r  <= 30'b0;
        end else begin
            if (host_wr_valid_in)
                mem_r[host_wr_addr_in] <= host_wr_data_in;

            if (!ctrl_rd_valid_r || ctrl_rd_ready_in) begin
                ctrl_rd_valid_r <= ctrl_rd_accept_w;
                if (ctrl_rd_accept_w)
                    ctrl_rd_data_r <= mem_r[ctrl_rd_addr_in];
            end

            if (!host_rd_valid_r || host_rd_ready_in) begin
                host_rd_valid_r <= host_rd_accept_w;
                if (host_rd_accept_w)
                    host_rd_data_r <= mem_r[host_rd_addr_in];
            end
        end
    end

endmodule

`default_nettype wire
