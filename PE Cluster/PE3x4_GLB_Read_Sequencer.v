`timescale 1ns/1ps
`default_nettype none

// ============================================================================
// Module      : PE3x4_GLB_Read_Sequencer
// Description : Reusable sequential read sequencer for GLB payload regions.
//               Latches start/base/count, issues ordered read requests, and
//               presents stable payload words to downstream logic.
//               It contains no dataflow, routing, MAC, or payload-generation
//               behavior.
// ============================================================================

module PE3x4_GLB_Read_Sequencer #(
    parameter integer AWIDTH = 8,
    parameter integer DATA_WIDTH = 72,
    parameter integer COUNT_WIDTH = 16
)(
    input  wire                         clk,
    input  wire                         rst,

    input  wire                         start_valid_in,
    output wire                         start_ready_out,
    input  wire [AWIDTH-1:0]            base_addr_in,
    input  wire [COUNT_WIDTH-1:0]       word_count_in,

    output wire                         rd_valid_out,
    input  wire                         rd_ready_in,
    output wire [AWIDTH-1:0]            rd_addr_out,

    input  wire                         resp_valid_in,
    output wire                         resp_ready_out,
    input  wire [DATA_WIDTH-1:0]        resp_data_in,

    output wire                         word_valid_out,
    input  wire                         word_ready_in,
    output wire [DATA_WIDTH-1:0]        word_data_out,
    output wire [COUNT_WIDTH-1:0]       word_index_out,

    output wire                         busy_out,
    output wire                         done_out
);

    reg                         busy_r;
    reg                         done_r;

    reg [AWIDTH-1:0]            base_addr_r;
    reg [COUNT_WIDTH-1:0]       total_count_r;
    reg [COUNT_WIDTH-1:0]       issued_count_r;
    reg [COUNT_WIDTH-1:0]       delivered_count_r;

    reg                         rd_valid_r;
    reg [AWIDTH-1:0]            rd_addr_r;
    reg                         outstanding_r;

    reg                         word_valid_r;
    reg [DATA_WIDTH-1:0]        word_data_r;
    reg [COUNT_WIDTH-1:0]       word_index_r;

    wire start_fire_w = start_valid_in && start_ready_out;
    wire rd_fire_w    = rd_valid_r && rd_ready_in;
    wire resp_fire_w  = resp_valid_in && resp_ready_out;
    wire word_fire_w  = word_valid_r && word_ready_in;

    assign start_ready_out = !busy_r && !rd_valid_r && !outstanding_r && !word_valid_r;

    assign rd_valid_out = rd_valid_r;
    assign rd_addr_out  = rd_addr_r;

    assign resp_ready_out = busy_r && outstanding_r && !word_valid_r;

    assign word_valid_out = word_valid_r;
    assign word_data_out  = word_data_r;
    assign word_index_out = word_index_r;

    assign busy_out = busy_r;
    assign done_out = done_r;

    always @(posedge clk) begin
        if (rst) begin
            busy_r <= 1'b0;
            done_r <= 1'b0;
            base_addr_r <= {AWIDTH{1'b0}};
            total_count_r <= {COUNT_WIDTH{1'b0}};
            issued_count_r <= {COUNT_WIDTH{1'b0}};
            delivered_count_r <= {COUNT_WIDTH{1'b0}};
            rd_valid_r <= 1'b0;
            rd_addr_r <= {AWIDTH{1'b0}};
            outstanding_r <= 1'b0;
            word_valid_r <= 1'b0;
            word_data_r <= {DATA_WIDTH{1'b0}};
            word_index_r <= {COUNT_WIDTH{1'b0}};
        end else begin
            done_r <= 1'b0;

            if (start_fire_w) begin
                base_addr_r <= base_addr_in;
                total_count_r <= word_count_in;
                issued_count_r <= {COUNT_WIDTH{1'b0}};
                delivered_count_r <= {COUNT_WIDTH{1'b0}};
                outstanding_r <= 1'b0;
                word_valid_r <= 1'b0;
                word_data_r <= {DATA_WIDTH{1'b0}};
                word_index_r <= {COUNT_WIDTH{1'b0}};

                if (word_count_in == {COUNT_WIDTH{1'b0}}) begin
                    busy_r <= 1'b0;
                    rd_valid_r <= 1'b0;
                    rd_addr_r <= base_addr_in;
                    done_r <= 1'b1;
                end else begin
                    busy_r <= 1'b1;
                    rd_valid_r <= 1'b1;
                    rd_addr_r <= base_addr_in;
                end
            end else begin
                if (rd_fire_w) begin
                    rd_valid_r <= 1'b0;
                    outstanding_r <= 1'b1;
                    issued_count_r <= issued_count_r + {{(COUNT_WIDTH-1){1'b0}}, 1'b1};
                end

                if (resp_fire_w) begin
                    outstanding_r <= 1'b0;
                    word_valid_r <= 1'b1;
                    word_data_r <= resp_data_in;
                    word_index_r <= delivered_count_r;
                end

                if (word_fire_w) begin
                    word_valid_r <= 1'b0;
                    delivered_count_r <= delivered_count_r + {{(COUNT_WIDTH-1){1'b0}}, 1'b1};

                    if ((delivered_count_r + {{(COUNT_WIDTH-1){1'b0}}, 1'b1}) == total_count_r) begin
                        busy_r <= 1'b0;
                        done_r <= 1'b1;
                    end else begin
                        rd_valid_r <= 1'b1;
                        rd_addr_r <= base_addr_r + (delivered_count_r + {{(COUNT_WIDTH-1){1'b0}}, 1'b1});
                    end
                end
            end
        end
    end

endmodule

`default_nettype wire
