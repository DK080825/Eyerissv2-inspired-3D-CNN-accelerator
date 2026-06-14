`timescale 1ns/1ps
`default_nettype none

module PE3x4_RS_Weight_Scheduler (
    input  wire        clk,
    input  wire        rst,

    input  wire        start_in,
    input  wire [4:0]  k_in,
    input  wire [11:0] active_pe_mask_in,

    output wire        meta_valid_out,
    input  wire        meta_ready_in,
    output wire [2:0]  weight_valid_lanes_out,
    output wire [11:0] weight_row_dst_mask_out,
    output wire [3:0]  beat_index_out,
    output wire        done_out,
    output wire        error_out
);

    localparam [1:0] ST_IDLE  = 2'd0;
    localparam [1:0] ST_EMIT  = 2'd1;
    localparam [1:0] ST_DONE  = 2'd2;
    localparam [1:0] ST_ERROR = 2'd3;

    localparam [11:0] ROW0_MASK = 12'h00f;
    localparam [11:0] ROW1_MASK = 12'h0f0;
    localparam [11:0] ROW2_MASK = 12'hf00;

    reg [1:0]  state_r;
    reg [2:0]  valid_lanes_r;
    reg [11:0] row_dst_mask_r;
    reg [3:0]  beat_index_r;

    wire [11:0] row0_effective_w = ROW0_MASK & active_pe_mask_in;
    wire [11:0] row1_effective_w = ROW1_MASK & active_pe_mask_in;
    wire [11:0] row2_effective_w = ROW2_MASK & active_pe_mask_in;
    wire [2:0] valid_lanes_w = {|row2_effective_w, |row1_effective_w, |row0_effective_w};
    wire [11:0] row_dst_mask_w = row0_effective_w | row1_effective_w | row2_effective_w;
    wire unsupported_w = (k_in != 5'd3);

    always @(posedge clk) begin
        if (rst) begin
            state_r <= ST_IDLE;
            valid_lanes_r <= 3'b000;
            row_dst_mask_r <= 12'h000;
            beat_index_r <= 4'd0;
        end else begin
            case (state_r)
                ST_IDLE: begin
                    if (start_in) begin
                        if (unsupported_w) begin
                            state_r <= ST_ERROR;
                        end else begin
                            valid_lanes_r <= valid_lanes_w;
                            row_dst_mask_r <= row_dst_mask_w;
                            beat_index_r <= 4'd0;
                            if (valid_lanes_w == 3'b000)
                                state_r <= ST_DONE;
                            else
                                state_r <= ST_EMIT;
                        end
                    end
                end

                ST_EMIT: begin
                    if (meta_ready_in)
                        state_r <= ST_DONE;
                end

                ST_DONE: begin
                    if (!start_in)
                        state_r <= ST_IDLE;
                end

                ST_ERROR: begin
                    if (!start_in)
                        state_r <= ST_IDLE;
                end

                default: state_r <= ST_ERROR;
            endcase
        end
    end

    assign meta_valid_out = (state_r == ST_EMIT);
    assign weight_valid_lanes_out = (state_r == ST_EMIT) ? valid_lanes_r : 3'b000;
    assign weight_row_dst_mask_out = (state_r == ST_EMIT) ? row_dst_mask_r : 12'h000;
    assign beat_index_out = beat_index_r;
    assign done_out = (state_r == ST_DONE);
    assign error_out = (state_r == ST_ERROR);

endmodule

`default_nettype wire
