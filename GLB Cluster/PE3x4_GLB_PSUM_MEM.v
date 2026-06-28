`timescale 1ns/1ps
`default_nettype none

// ============================================================================
// Module      : PE3x4_GLB_PSUM_MEM
// Author      : Do Quoc Khanh
// Description : Payload-only PSUM/output memory for four 42-bit column lanes.
//               Each lane packs two 21-bit PSUM values for seed/readback or
//               cluster drain storage.
//               It stores no valid bits, route metadata, or HMesh-native fields.
// ============================================================================

module PE3x4_GLB_PSUM_MEM #(
    parameter integer AWIDTH = 8
)(
    input  wire                 clk,
    input  wire                 rst,

    // Port A write
    input  wire                 wr_valid_in,
    output wire                 wr_ready_out,
    input  wire [AWIDTH-1:0]    wr_addr_in,
    input  wire [167:0]         wr_data_in,

    // Port B controller read
    input  wire                 ctrl_rd_valid_in,
    output wire                 ctrl_rd_ready_out,
    input  wire [AWIDTH-1:0]    ctrl_rd_addr_in,
    output wire                 ctrl_rd_valid_out,
    input  wire                 ctrl_rd_ready_in,
    output wire [167:0]         ctrl_rd_data_out,

    // Port B host/debug read (lower priority than controller read)
    input  wire                 host_rd_valid_in,
    output wire                 host_rd_ready_out,
    input  wire [AWIDTH-1:0]    host_rd_addr_in,
    output wire                 host_rd_valid_out,
    input  wire                 host_rd_ready_in,
    output wire [167:0]         host_rd_data_out
);

    localparam integer BANK_COUNT = 4;
    localparam integer BANK_DW = 42;
    localparam integer TOTAL_DW = 168;
    localparam integer DEPTH = (1 << AWIDTH);
    
    // infer SRAM
    (* ram_style = "block" *) reg [TOTAL_DW-1:0] mem_r [0:DEPTH-1];

    reg [TOTAL_DW-1:0] ctrl_resp_data_r;
    reg                ctrl_resp_valid_r;
    reg [TOTAL_DW-1:0] host_resp_data_r;
    reg                host_resp_valid_r;

    reg                ctrl_rd_req_valid_r;
    reg [AWIDTH-1:0]   ctrl_rd_req_addr_r;
    reg                host_rd_req_valid_r;
    reg [AWIDTH-1:0]   host_rd_req_addr_r;

    wire port_b_busy_w = ctrl_resp_valid_r | host_resp_valid_r;
    wire ctrl_read_accept_w = ctrl_rd_valid_in && !ctrl_resp_valid_r;
    wire host_read_accept_w = host_rd_valid_in && !ctrl_resp_valid_r && !host_resp_valid_r && !ctrl_rd_valid_in;
    wire same_addr_illegal_w = wr_valid_in && ((ctrl_read_accept_w && (wr_addr_in == ctrl_rd_addr_in)) ||
                                               (host_read_accept_w && (wr_addr_in == host_rd_addr_in)));

    assign wr_ready_out = 1'b1;
    assign ctrl_rd_ready_out = !ctrl_resp_valid_r;
    assign host_rd_ready_out = !ctrl_resp_valid_r && !ctrl_rd_valid_in && !host_resp_valid_r;

    assign ctrl_rd_valid_out = ctrl_resp_valid_r;
    assign ctrl_rd_data_out  = ctrl_resp_data_r;
    assign host_rd_valid_out = host_resp_valid_r;
    assign host_rd_data_out  = host_resp_data_r;

    always @(posedge clk) begin
        if (rst) begin
            ctrl_resp_valid_r <= 1'b0;
            host_resp_valid_r <= 1'b0;
            ctrl_rd_req_valid_r <= 1'b0;
            host_rd_req_valid_r <= 1'b0;
            ctrl_rd_req_addr_r <= {AWIDTH{1'b0}};
            host_rd_req_addr_r <= {AWIDTH{1'b0}};
        end else begin
            if (ctrl_resp_valid_r && ctrl_rd_ready_in)
                ctrl_resp_valid_r <= 1'b0;
            if (host_resp_valid_r && host_rd_ready_in)
                host_resp_valid_r <= 1'b0;

            ctrl_rd_req_valid_r <= 1'b0;
            host_rd_req_valid_r <= 1'b0;

            if (ctrl_rd_valid_in && !ctrl_resp_valid_r) begin
                ctrl_rd_req_valid_r <= 1'b1;
                ctrl_rd_req_addr_r <= ctrl_rd_addr_in;
            end else if (host_rd_valid_in && !ctrl_resp_valid_r && !ctrl_rd_valid_in && !host_resp_valid_r) begin
                host_rd_req_valid_r <= 1'b1;
                host_rd_req_addr_r <= host_rd_addr_in;
            end

            if (wr_valid_in) begin
                mem_r[wr_addr_in] <= wr_data_in;
            end

            if (ctrl_rd_req_valid_r) begin
                ctrl_resp_data_r <= mem_r[ctrl_rd_req_addr_r];
                ctrl_resp_valid_r <= 1'b1;
            end else if (host_rd_req_valid_r) begin
                host_resp_data_r <= mem_r[host_rd_req_addr_r];
                host_resp_valid_r <= 1'b1;
            end
        end
    end

endmodule

`default_nettype wire
