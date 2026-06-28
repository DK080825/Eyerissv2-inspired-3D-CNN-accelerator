`timescale 1ns/1ps
`default_nettype none

// ============================================================================
// Module      : PE3x4_GLB_Banked_Sync_Memory
// Author      : Do Quoc Khanh
// Description : Reusable packed-word banked synchronous memory for GLB regions.
//               Provides host-side access and controller/datapath-side access
//               with stable read response registers.
//               Read latency is fixed to one cycle; reset does not clear memory.
// ============================================================================

module PE3x4_GLB_Banked_Sync_Memory #(
    parameter integer AWIDTH = 8,
    parameter integer BANK_COUNT = 8,
    parameter integer BANK_DW = 18,
    parameter integer TOTAL_DW = BANK_COUNT * BANK_DW,
    parameter integer READ_LATENCY = 1,
    parameter integer ENABLE_HOST_READ = 1,
    parameter integer ENABLE_DP_WRITE = 0
)(
    input  wire                  clk,
    input  wire                  rst,

    // Host Port A
    input  wire                  host_wr_valid_in,
    output wire                  host_wr_ready_out,
    input  wire [AWIDTH-1:0]     host_wr_addr_in,
    input  wire [TOTAL_DW-1:0]   host_wr_data_in,

    input  wire                  host_rd_valid_in,
    output wire                  host_rd_ready_out,
    input  wire [AWIDTH-1:0]     host_rd_addr_in,
    output wire                  host_rd_valid_out,
    input  wire                  host_rd_ready_in,
    output wire [TOTAL_DW-1:0]   host_rd_data_out,

    // Controller Port B
    input  wire                  ctrl_rd_valid_in,
    output wire                  ctrl_rd_ready_out,
    input  wire [AWIDTH-1:0]     ctrl_rd_addr_in,
    output wire                  ctrl_rd_valid_out,
    input  wire                  ctrl_rd_ready_in,
    output wire [TOTAL_DW-1:0]   ctrl_rd_data_out,

    // Optional datapath write on Port B
    input  wire                  dp_wr_valid_in,
    output wire                  dp_wr_ready_out,
    input  wire [AWIDTH-1:0]     dp_wr_addr_in,
    input  wire [TOTAL_DW-1:0]   dp_wr_data_in
);

    localparam integer DEPTH = (1 << AWIDTH);

    // Packed banked storage: mem[addr] is a packed TOTAL_DW word.
    (* ram_style = "block" *) reg [TOTAL_DW-1:0] mem_r [0:DEPTH-1];

    // Host response holding register
    reg [TOTAL_DW-1:0] host_resp_data_r;
    reg                host_resp_valid_r;

    // Controller response holding register
    reg [TOTAL_DW-1:0] ctrl_resp_data_r;
    reg                ctrl_resp_valid_r;

    // Registered read requests for 1-cycle latency
    reg                host_rd_req_valid_r;
    reg [AWIDTH-1:0]   host_rd_req_addr_r;

    reg                ctrl_rd_req_valid_r;
    reg [AWIDTH-1:0]   ctrl_rd_req_addr_r;

    // Phase-1 ready policy
    // Host Port A: write has priority over read.
    assign host_wr_ready_out = 1'b1;
    assign host_rd_ready_out  = ENABLE_HOST_READ && !host_wr_valid_in && !host_resp_valid_r;

    // Controller read is blocked if response slot is full.
    // If datapath write is enabled, it has priority over controller read.
    assign ctrl_rd_ready_out  = (!ENABLE_DP_WRITE || !dp_wr_valid_in) && !ctrl_resp_valid_r;
    assign dp_wr_ready_out    = ENABLE_DP_WRITE ? 1'b1 : 1'b0;

    assign host_rd_valid_out = host_resp_valid_r;
    assign host_rd_data_out  = host_resp_data_r;

    assign ctrl_rd_valid_out = ctrl_resp_valid_r;
    assign ctrl_rd_data_out  = ctrl_resp_data_r;

    // Note: READ_LATENCY is fixed to 1 for phase 1.
    generate
        if (READ_LATENCY != 1) begin : gen_bad_lat
            initial begin
                $fatal(1, "PE3x4_GLB_Banked_Sync_Memory supports READ_LATENCY==1 only in phase 1");
            end
        end
    endgenerate

    always @(posedge clk) begin
        if (rst) begin
            host_resp_valid_r <= 1'b0;
            ctrl_resp_valid_r <= 1'b0;
            host_rd_req_valid_r <= 1'b0;
            ctrl_rd_req_valid_r <= 1'b0;
            host_rd_req_addr_r <= {AWIDTH{1'b0}};
            ctrl_rd_req_addr_r <= {AWIDTH{1'b0}};
        end else begin
            // Default: clear completed response valid only when accepted.
            if (host_resp_valid_r && host_rd_ready_in)
                host_resp_valid_r <= 1'b0;
            if (ctrl_resp_valid_r && ctrl_rd_ready_in)
                ctrl_resp_valid_r <= 1'b0;

            // Issue reads when there is room in the response holding register.
            if (ENABLE_HOST_READ && host_rd_valid_in && !host_resp_valid_r && !host_wr_valid_in) begin
                host_rd_req_valid_r <= 1'b1;
                host_rd_req_addr_r <= host_rd_addr_in;
            end else begin
                host_rd_req_valid_r <= 1'b0;
            end

            if (ctrl_rd_valid_in && !ctrl_resp_valid_r && (!ENABLE_DP_WRITE || !dp_wr_valid_in)) begin
                ctrl_rd_req_valid_r <= 1'b1;
                ctrl_rd_req_addr_r <= ctrl_rd_addr_in;
            end else begin
                ctrl_rd_req_valid_r <= 1'b0;
            end

            // Writes happen in the same cycle as acceptance.
            // Port A priority: write over read.
            if (host_wr_valid_in) begin
                mem_r[host_wr_addr_in] <= host_wr_data_in;
            end

            if (ENABLE_DP_WRITE && dp_wr_valid_in) begin
                mem_r[dp_wr_addr_in] <= dp_wr_data_in;
            end

            // Generate read responses one cycle later.
            if (host_rd_req_valid_r) begin
                host_resp_data_r <= mem_r[host_rd_req_addr_r];
                host_resp_valid_r <= 1'b1;
            end
            if (ctrl_rd_req_valid_r) begin
                ctrl_resp_data_r <= mem_r[ctrl_rd_req_addr_r];
                ctrl_resp_valid_r <= 1'b1;
            end
        end
    end

endmodule

`default_nettype wire
