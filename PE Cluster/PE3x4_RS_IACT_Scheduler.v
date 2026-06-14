`timescale 1ns/1ps
`default_nettype none

module PE3x4_RS_IACT_Scheduler (
    input  wire        clk,
    input  wire        rst,

    input  wire        start_in,
    input  wire [4:0]  k_in,
    input  wire [4:0]  stride_in,
    input  wire [11:0] active_pe_mask_in,
    input  wire [15:0] beat_count_in,
    input  wire [7:0]  slot_present_in,

    output wire        meta_valid_out,
    input  wire        meta_ready_in,
    output wire [7:0]  slot_valid_out,
    output wire [95:0] dst_mask_out,
    output wire [15:0] beat_index_out,
    output wire        done_out,
    output wire        error_out
);

    localparam [1:0] ST_IDLE  = 2'd0;
    localparam [1:0] ST_EMIT  = 2'd1;
    localparam [1:0] ST_DONE  = 2'd2;
    localparam [1:0] ST_ERROR = 2'd3;

    reg [1:0]  state_r;
    reg [11:0] active_pe_mask_r;
    reg [15:0] beat_count_r;
    reg [15:0] beat_index_r;

    reg [7:0]  slot_valid_calc_r;
    reg [95:0] dst_mask_calc_r;
    reg [11:0] effective_mask_r;
    integer lane_i;

    function automatic [11:0] s1_diagonal_mask(input integer slot_idx);
        begin
            case (slot_idx)
                0: s1_diagonal_mask = 12'h001;
                1: s1_diagonal_mask = 12'h012;
                2: s1_diagonal_mask = 12'h124;
                3: s1_diagonal_mask = 12'h248;
                4: s1_diagonal_mask = 12'h480;
                5: s1_diagonal_mask = 12'h800;
                default: s1_diagonal_mask = 12'h000;
            endcase
        end
    endfunction

    always @* begin
        slot_valid_calc_r = 8'h00;
        dst_mask_calc_r = 96'h0;
        for (lane_i = 0; lane_i < 6; lane_i = lane_i + 1) begin
            effective_mask_r = s1_diagonal_mask(lane_i) & active_pe_mask_r;
            if (slot_present_in[lane_i] && (effective_mask_r != 12'h000)) begin
                slot_valid_calc_r[lane_i] = 1'b1;
                dst_mask_calc_r[lane_i * 12 +: 12] = effective_mask_r;
            end
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            state_r <= ST_IDLE;
            active_pe_mask_r <= 12'h000;
            beat_count_r <= 16'd0;
            beat_index_r <= 16'd0;
        end else begin
            case (state_r)
                ST_IDLE: begin
                    if (start_in) begin
                        if ((k_in != 5'd3) || (stride_in != 5'd1)) begin
                            state_r <= ST_ERROR;
                        end else begin
                            active_pe_mask_r <= active_pe_mask_in;
                            beat_count_r <= beat_count_in;
                            beat_index_r <= 16'd0;
                            if (beat_count_in == 16'd0)
                                state_r <= ST_DONE;
                            else
                                state_r <= ST_EMIT;
                        end
                    end
                end

                ST_EMIT: begin
                    if (meta_ready_in) begin
                        if ((beat_index_r + 16'd1) >= beat_count_r)
                            state_r <= ST_DONE;
                        else
                            beat_index_r <= beat_index_r + 16'd1;
                    end
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
    assign slot_valid_out = (state_r == ST_EMIT) ? slot_valid_calc_r : 8'h00;
    assign dst_mask_out = (state_r == ST_EMIT) ? dst_mask_calc_r : 96'h0;
    assign beat_index_out = beat_index_r;
    assign done_out = (state_r == ST_DONE);
    assign error_out = (state_r == ST_ERROR);

endmodule

`default_nettype wire
