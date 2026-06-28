`timescale 1ns/1ps
`default_nettype none

// ============================================================================
// Module      : PE3x4_GLB_WEIGHT_PINGPONG
// Author      : Do Quoc Khanh
// Description : Ownership wrapper for paired Weight ADDR/DATA ping-pong buffers.
//               A load session owns one complete ADDR/DATA buffer pair, while
//               a compute session reads one complete valid pair.
//               Buffer selection is sampled when each session starts.
// ============================================================================

module PE3x4_GLB_WEIGHT_PINGPONG #(
    parameter integer AWIDTH = 8
)(
    input  wire                 clk,
    input  wire                 rst,

    input  wire                 host_load_start_in,
    input  wire                 host_load_buf_sel_in,
    input  wire                 host_load_done_in,

    input  wire                 host_weight_addr_wr_valid_in,
    output wire                 host_weight_addr_wr_ready_out,
    input  wire [AWIDTH-1:0]    host_weight_addr_wr_addr_in,
    input  wire [20:0]          host_weight_addr_wr_data_in,

    input  wire                 host_weight_data_wr_valid_in,
    output wire                 host_weight_data_wr_ready_out,
    input  wire [AWIDTH-1:0]    host_weight_data_wr_addr_in,
    input  wire [71:0]          host_weight_data_wr_data_in,

    input  wire                 compute_acquire_in,
    input  wire                 compute_buf_sel_in,
    input  wire                 compute_release_in,

    input  wire                 ctrl_weight_addr_rd_valid_in,
    output wire                 ctrl_weight_addr_rd_ready_out,
    input  wire [AWIDTH-1:0]    ctrl_weight_addr_rd_addr_in,
    output wire                 ctrl_weight_addr_rd_valid_out,
    input  wire                 ctrl_weight_addr_rd_ready_in,
    output wire [20:0]          ctrl_weight_addr_rd_data_out,

    input  wire                 ctrl_weight_data_rd_valid_in,
    output wire                 ctrl_weight_data_rd_ready_out,
    input  wire [AWIDTH-1:0]    ctrl_weight_data_rd_addr_in,
    output wire                 ctrl_weight_data_rd_valid_out,
    input  wire                 ctrl_weight_data_rd_ready_in,
    output wire [71:0]          ctrl_weight_data_rd_data_out,

    input  wire                 error_clear_in,
    output wire                 error_out,
    output wire                 ping_valid_out,
    output wire                 pong_valid_out,
    output wire                 ping_busy_out,
    output wire                 pong_busy_out,
    output wire                 load_active_out,
    output wire                 load_buf_sel_out,
    output wire                 compute_active_out,
    output wire                 compute_buf_sel_out
);

    reg ping_valid_r;
    reg pong_valid_r;
    reg load_active_r;
    reg load_buf_sel_r;
    reg compute_active_r;
    reg compute_buf_sel_r;
    reg error_r;

    wire ping_load_busy_w = load_active_r && (load_buf_sel_r == 1'b0);
    wire pong_load_busy_w = load_active_r && (load_buf_sel_r == 1'b1);
    wire ping_compute_busy_w = compute_active_r && (compute_buf_sel_r == 1'b0);
    wire pong_compute_busy_w = compute_active_r && (compute_buf_sel_r == 1'b1);

    wire load_start_conflict_w =
        (host_load_buf_sel_in == 1'b0) ? ping_compute_busy_w : pong_compute_busy_w;
    wire compute_acquire_valid_w =
        (compute_buf_sel_in == 1'b0) ? ping_valid_r : pong_valid_r;
    wire compute_acquire_conflict_w =
        (compute_buf_sel_in == 1'b0) ? ping_load_busy_w : pong_load_busy_w;

    wire load_start_accept_w =
        host_load_start_in && !load_active_r && !load_start_conflict_w;
    wire compute_acquire_accept_w =
        compute_acquire_in && !compute_active_r &&
        compute_acquire_valid_w && !compute_acquire_conflict_w;

    wire ctrl_read_enable_w = compute_active_r;

    wire ping_addr_host_wr_ready_w;
    wire pong_addr_host_wr_ready_w;
    wire ping_data_host_wr_ready_w;
    wire pong_data_host_wr_ready_w;

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
    
    wire selected_addr_resp_valid_w = (compute_buf_sel_r == 1'b0) ? ping_addr_ctrl_rd_valid_w : pong_addr_ctrl_rd_valid_w;
    wire selected_data_resp_valid_w = (compute_buf_sel_r == 1'b0) ? ping_data_ctrl_rd_valid_w : pong_data_ctrl_rd_valid_w;
    wire compute_release_accept_w =
        compute_release_in && compute_active_r &&
        !selected_addr_resp_valid_w && !selected_data_resp_valid_w;

    assign host_weight_addr_wr_ready_out =
        load_active_r && !((load_buf_sel_r == 1'b0) ? ping_compute_busy_w : pong_compute_busy_w) &&
        ((load_buf_sel_r == 1'b0) ? ping_addr_host_wr_ready_w : pong_addr_host_wr_ready_w);
    assign host_weight_data_wr_ready_out =
        load_active_r && !((load_buf_sel_r == 1'b0) ? ping_compute_busy_w : pong_compute_busy_w) &&
        ((load_buf_sel_r == 1'b0) ? ping_data_host_wr_ready_w : pong_data_host_wr_ready_w);

    assign ctrl_weight_addr_rd_ready_out =
        ctrl_read_enable_w &&
        ((compute_buf_sel_r == 1'b0) ? ping_addr_ctrl_rd_ready_w : pong_addr_ctrl_rd_ready_w);
    assign ctrl_weight_data_rd_ready_out =
        ctrl_read_enable_w &&
        ((compute_buf_sel_r == 1'b0) ? ping_data_ctrl_rd_ready_w : pong_data_ctrl_rd_ready_w);

    assign ctrl_weight_addr_rd_valid_out =
        (compute_buf_sel_r == 1'b0) ? ping_addr_ctrl_rd_valid_w : pong_addr_ctrl_rd_valid_w;
    assign ctrl_weight_addr_rd_data_out =
        (compute_buf_sel_r == 1'b0) ? ping_addr_ctrl_rd_data_w : pong_addr_ctrl_rd_data_w;
    assign ctrl_weight_data_rd_valid_out =
        (compute_buf_sel_r == 1'b0) ? ping_data_ctrl_rd_valid_w : pong_data_ctrl_rd_valid_w;
    assign ctrl_weight_data_rd_data_out =
        (compute_buf_sel_r == 1'b0) ? ping_data_ctrl_rd_data_w : pong_data_ctrl_rd_data_w;

    assign ping_valid_out = ping_valid_r;
    assign pong_valid_out = pong_valid_r;
    assign ping_busy_out = ping_load_busy_w || ping_compute_busy_w;
    assign pong_busy_out = pong_load_busy_w || pong_compute_busy_w;
    assign load_active_out = load_active_r;
    assign load_buf_sel_out = load_buf_sel_r;
    assign compute_active_out = compute_active_r;
    assign compute_buf_sel_out = compute_buf_sel_r;
    assign error_out = error_r;

    PE3x4_GLB_WEIGHT_ADDR_MEM #(.AWIDTH(AWIDTH)) u_ping_addr (
        .clk(clk), .rst(rst),
        .host_wr_valid_in(host_weight_addr_wr_valid_in && load_active_r && (load_buf_sel_r == 1'b0)),
        .host_wr_ready_out(ping_addr_host_wr_ready_w),
        .host_wr_addr_in(host_weight_addr_wr_addr_in),
        .host_wr_data_in(host_weight_addr_wr_data_in),
        .host_rd_valid_in(1'b0), .host_rd_ready_out(), .host_rd_addr_in({AWIDTH{1'b0}}),
        .host_rd_valid_out(), .host_rd_ready_in(1'b0), .host_rd_data_out(),
        .ctrl_rd_valid_in(ctrl_weight_addr_rd_valid_in && ctrl_read_enable_w && (compute_buf_sel_r == 1'b0)),
        .ctrl_rd_ready_out(ping_addr_ctrl_rd_ready_w),
        .ctrl_rd_addr_in(ctrl_weight_addr_rd_addr_in),
        .ctrl_rd_valid_out(ping_addr_ctrl_rd_valid_w),
        .ctrl_rd_ready_in(ctrl_weight_addr_rd_ready_in && (compute_buf_sel_r == 1'b0)),
        .ctrl_rd_data_out(ping_addr_ctrl_rd_data_w)
    );

    PE3x4_GLB_WEIGHT_DATA_MEM #(.AWIDTH(AWIDTH)) u_ping_data (
        .clk(clk), .rst(rst),
        .host_wr_valid_in(host_weight_data_wr_valid_in && load_active_r && (load_buf_sel_r == 1'b0)),
        .host_wr_ready_out(ping_data_host_wr_ready_w),
        .host_wr_addr_in(host_weight_data_wr_addr_in),
        .host_wr_data_in(host_weight_data_wr_data_in),
        .host_rd_valid_in(1'b0), .host_rd_ready_out(), .host_rd_addr_in({AWIDTH{1'b0}}),
        .host_rd_valid_out(), .host_rd_ready_in(1'b0), .host_rd_data_out(),
        .ctrl_rd_valid_in(ctrl_weight_data_rd_valid_in && ctrl_read_enable_w && (compute_buf_sel_r == 1'b0)),
        .ctrl_rd_ready_out(ping_data_ctrl_rd_ready_w),
        .ctrl_rd_addr_in(ctrl_weight_data_rd_addr_in),
        .ctrl_rd_valid_out(ping_data_ctrl_rd_valid_w),
        .ctrl_rd_ready_in(ctrl_weight_data_rd_ready_in && (compute_buf_sel_r == 1'b0)),
        .ctrl_rd_data_out(ping_data_ctrl_rd_data_w)
    );

    PE3x4_GLB_WEIGHT_ADDR_MEM #(.AWIDTH(AWIDTH)) u_pong_addr (
        .clk(clk), .rst(rst),
        .host_wr_valid_in(host_weight_addr_wr_valid_in && load_active_r && (load_buf_sel_r == 1'b1)),
        .host_wr_ready_out(pong_addr_host_wr_ready_w),
        .host_wr_addr_in(host_weight_addr_wr_addr_in),
        .host_wr_data_in(host_weight_addr_wr_data_in),
        .host_rd_valid_in(1'b0), .host_rd_ready_out(), .host_rd_addr_in({AWIDTH{1'b0}}),
        .host_rd_valid_out(), .host_rd_ready_in(1'b0), .host_rd_data_out(),
        .ctrl_rd_valid_in(ctrl_weight_addr_rd_valid_in && ctrl_read_enable_w && (compute_buf_sel_r == 1'b1)),
        .ctrl_rd_ready_out(pong_addr_ctrl_rd_ready_w),
        .ctrl_rd_addr_in(ctrl_weight_addr_rd_addr_in),
        .ctrl_rd_valid_out(pong_addr_ctrl_rd_valid_w),
        .ctrl_rd_ready_in(ctrl_weight_addr_rd_ready_in && (compute_buf_sel_r == 1'b1)),
        .ctrl_rd_data_out(pong_addr_ctrl_rd_data_w)
    );

    PE3x4_GLB_WEIGHT_DATA_MEM #(.AWIDTH(AWIDTH)) u_pong_data (
        .clk(clk), .rst(rst),
        .host_wr_valid_in(host_weight_data_wr_valid_in && load_active_r && (load_buf_sel_r == 1'b1)),
        .host_wr_ready_out(pong_data_host_wr_ready_w),
        .host_wr_addr_in(host_weight_data_wr_addr_in),
        .host_wr_data_in(host_weight_data_wr_data_in),
        .host_rd_valid_in(1'b0), .host_rd_ready_out(), .host_rd_addr_in({AWIDTH{1'b0}}),
        .host_rd_valid_out(), .host_rd_ready_in(1'b0), .host_rd_data_out(),
        .ctrl_rd_valid_in(ctrl_weight_data_rd_valid_in && ctrl_read_enable_w && (compute_buf_sel_r == 1'b1)),
        .ctrl_rd_ready_out(pong_data_ctrl_rd_ready_w),
        .ctrl_rd_addr_in(ctrl_weight_data_rd_addr_in),
        .ctrl_rd_valid_out(pong_data_ctrl_rd_valid_w),
        .ctrl_rd_ready_in(ctrl_weight_data_rd_ready_in && (compute_buf_sel_r == 1'b1)),
        .ctrl_rd_data_out(pong_data_ctrl_rd_data_w)
    );

    always @(posedge clk) begin
        if (rst) begin
            ping_valid_r <= 1'b0;
            pong_valid_r <= 1'b0;
            load_active_r <= 1'b0;
            load_buf_sel_r <= 1'b0;
            compute_active_r <= 1'b0;
            compute_buf_sel_r <= 1'b0;
            error_r <= 1'b0;
        end else begin
            if (error_clear_in)
                error_r <= 1'b0;

            if (load_start_accept_w) begin
                load_active_r <= 1'b1;
                load_buf_sel_r <= host_load_buf_sel_in;
                if (host_load_buf_sel_in == 1'b0)
                    ping_valid_r <= 1'b0;
                else
                    pong_valid_r <= 1'b0;
            end

            if (host_load_done_in && load_active_r) begin
                load_active_r <= 1'b0;
                if (load_buf_sel_r == 1'b0)
                    ping_valid_r <= 1'b1;
                else
                    pong_valid_r <= 1'b1;
            end

            if (compute_acquire_accept_w) begin
                compute_active_r <= 1'b1;
                compute_buf_sel_r <= compute_buf_sel_in;
            end

            if (compute_release_accept_w)
                compute_active_r <= 1'b0;

            if ((host_load_start_in && !load_start_accept_w) ||
                (host_load_done_in && !load_active_r) ||
                (compute_acquire_in && !compute_acquire_accept_w) ||
                (compute_release_in && !compute_release_accept_w) ||
                (host_weight_addr_wr_valid_in && !load_active_r) ||
                (host_weight_data_wr_valid_in && !load_active_r) ||
                (ctrl_weight_addr_rd_valid_in && !compute_active_r) ||
                (ctrl_weight_data_rd_valid_in && !compute_active_r))
                error_r <= 1'b1;
        end
    end

endmodule

`default_nettype wire
