`timescale 1ns/1ps

// ============================================================================
// Module      : PE3x4_Psum_Streamer
// Description : Moves PSUM result data from the PE cluster to PSUM GLB.
//               It can also read PSUM seed words from GLB and send them
//               to the PE cluster before the result is returned.
//               The main controller decides when this block starts.
// ============================================================================

module PE3x4_Psum_Streamer #(
    parameter integer GLB_AW = 8
) (
    // clock/reset -> this block
    input  wire                        clk,
    input  wire                        rst,

    // controller -> this block
    input  wire                        start_in,
    input  wire                        active_in,
    input  wire [11:0]                 active_pe_mask_in,
    input  wire [3:0]                  active_col_mask_in,
    input  wire [5:0]                  m0_in,
    input  wire [15:0]                 completed_window_idx_in,
    input  wire [GLB_AW-1:0]           psum_read_base_in,
    input  wire [15:0]                 psum_read_count_in,
    input  wire [GLB_AW-1:0]           psum_write_base_in,

    // PE cluster -> this block
    input  wire [11:0]                 pe_psum_acc_fin_in,
    input  wire [3:0]                  psum_seed_ready_in,
    input  wire [3:0]                  psum_col_valid_in,
    input  wire signed [167:0]         psum_col_data_in,

    // this block -> PSUM GLB
    output wire                        glb_psum_wr_valid_out,
    input  wire                        glb_psum_wr_ready_in,
    output wire [GLB_AW-1:0]           glb_psum_wr_addr_out,
    output wire [167:0]                glb_psum_wr_data_out,

    // this block <- PSUM GLB: read seed
    output wire                        glb_psum_rd_valid_out,
    input  wire                        glb_psum_rd_ready_in,
    output wire [GLB_AW-1:0]           glb_psum_rd_addr_out,
    input  wire                        glb_psum_rd_valid_in,
    output wire                        glb_psum_rd_ready_out,
    input  wire [167:0]                glb_psum_rd_data_in,

    // this block -> PE cluster
    output wire [3:0]                  psum_col_ready_out,
    output wire [3:0]                  seed_valid_out,
    output wire signed [167:0]         seed_data_out,
    // this block -> controller
    output wire                        done_out
);

    reg [11:0]       acc_fin_seen_r;
    reg [5:0]        seed_count_r [0:3];
    reg [5:0]        output_count_r [0:3];
    reg [3:0]        active_col_mask_r;
    reg [3:0]        seed_pair_accepted_r;
    reg              wr_buf_valid_r;
    reg [GLB_AW-1:0] wr_buf_addr_r;
    reg [167:0]      wr_buf_data_r;
    reg              seed_rd_pending_r;
    reg              seed_buf_valid_r;
    reg [167:0]      seed_buf_data_r;
    integer          col_i;

    wire [3:0] seed_fire_w = seed_valid_out & psum_seed_ready_in;
    wire                        col_sink_ready_w;
    wire                        col_capture_ready_w;
    wire [3:0]                  output_fire_w = psum_col_valid_in & psum_col_ready_out & active_col_mask_r;
    wire [5:0] pair_count_w = (m0_in + 6'd1) >> 1;
    wire [5:0] pair_index_w = output_count_r[0] >> 1;
    wire [5:0] seed_pair_index_w = seed_count_r[0] >> 1;
    wire [15:0] seed_word_index_w = completed_window_idx_in * pair_count_w + seed_pair_index_w;
    wire seed_enabled_w = (psum_read_count_in != 16'd0);
    wire seed_needed_w =
        active_in &&
        seed_enabled_w &&
        (seed_count_r[0] < m0_in) &&
        !seed_buf_valid_r &&
        !seed_rd_pending_r &&
        (seed_word_index_w < psum_read_count_in);
    wire active_valid_w = ((psum_col_valid_in & active_col_mask_r) == active_col_mask_r);
    wire return_idle_w = ((psum_col_valid_in & active_col_mask_r) == 4'b0000);
    wire [11:0] acc_fin_seen_next_w = acc_fin_seen_r | pe_psum_acc_fin_in;
    wire acc_fin_done_w = ((acc_fin_seen_next_w & active_pe_mask_in) == active_pe_mask_in);
    wire drain_done_w =
        (!active_col_mask_r[0] || ((seed_count_r[0] >= m0_in) && (output_count_r[0] >= m0_in))) &&
        (!active_col_mask_r[1] || ((seed_count_r[1] >= m0_in) && (output_count_r[1] >= m0_in))) &&
        (!active_col_mask_r[2] || ((seed_count_r[2] >= m0_in) && (output_count_r[2] >= m0_in))) &&
        (!active_col_mask_r[3] || ((seed_count_r[3] >= m0_in) && (output_count_r[3] >= m0_in))) &&
        acc_fin_done_w;
    wire wr_buf_fire_w = wr_buf_valid_r && glb_psum_wr_ready_in;
    wire wr_buf_can_accept_w = !wr_buf_valid_r || wr_buf_fire_w;
    wire [3:0] seed_fire_mask_w = seed_fire_w & active_col_mask_r;
    wire [3:0] seed_pair_accepted_next_w = seed_pair_accepted_r | seed_fire_mask_w;
    wire seed_pair_done_w =
        active_in &&
        ((seed_pair_accepted_next_w & active_col_mask_r) == active_col_mask_r);

    assign seed_valid_out = active_in ? {
        active_col_mask_r[3] & (seed_count_r[3] < m0_in) & !seed_pair_accepted_r[3],
        active_col_mask_r[2] & (seed_count_r[2] < m0_in) & !seed_pair_accepted_r[2],
        active_col_mask_r[1] & (seed_count_r[1] < m0_in) & !seed_pair_accepted_r[1],
        active_col_mask_r[0] & (seed_count_r[0] < m0_in) & !seed_pair_accepted_r[0]
    } & {4{!seed_enabled_w || seed_buf_valid_r}} : 4'h0;
    assign seed_data_out = seed_enabled_w ? $signed(seed_buf_data_r) : 168'sd0;
    assign glb_psum_wr_valid_out = wr_buf_valid_r;
    assign glb_psum_wr_addr_out = wr_buf_addr_r;
    assign glb_psum_wr_data_out = wr_buf_data_r;
    assign glb_psum_rd_valid_out = seed_needed_w;
    assign glb_psum_rd_addr_out = psum_read_base_in + seed_word_index_w[GLB_AW-1:0];
    assign glb_psum_rd_ready_out = 1'b1;
    assign col_sink_ready_w =
        active_in &&
        active_valid_w &&
        (output_count_r[0] >= m0_in);
    assign col_capture_ready_w =
        active_in &&
        (output_count_r[0] < m0_in) &&
        wr_buf_can_accept_w;
    assign psum_col_ready_out = {4{col_capture_ready_w || col_sink_ready_w}};
    assign done_out = drain_done_w && return_idle_w && (!wr_buf_valid_r || wr_buf_fire_w);

    always @(posedge clk) begin
        if (rst) begin
            acc_fin_seen_r <= 12'h000;
            active_col_mask_r <= 4'h0;
            seed_pair_accepted_r <= 4'h0;
            wr_buf_valid_r <= 1'b0;
            wr_buf_addr_r <= {GLB_AW{1'b0}};
            wr_buf_data_r <= 168'd0;
            seed_rd_pending_r <= 1'b0;
            seed_buf_valid_r <= 1'b0;
            seed_buf_data_r <= 168'd0;
            for (col_i = 0; col_i < 4; col_i = col_i + 1) begin
                seed_count_r[col_i] <= 6'd0;
                output_count_r[col_i] <= 6'd0;
            end
        end else begin
            if (start_in) begin
                active_col_mask_r <= active_col_mask_in;
                acc_fin_seen_r <= 12'h000;
                seed_pair_accepted_r <= 4'h0;
                wr_buf_valid_r <= 1'b0;
                seed_rd_pending_r <= 1'b0;
                seed_buf_valid_r <= 1'b0;
                seed_buf_data_r <= 168'd0;
                for (col_i = 0; col_i < 4; col_i = col_i + 1) begin
                    seed_count_r[col_i] <= 6'd0;
                    output_count_r[col_i] <= 6'd0;
                end
            end else if (active_in) begin
                acc_fin_seen_r <= acc_fin_seen_next_w;

                if (seed_needed_w && glb_psum_rd_ready_in)
                    seed_rd_pending_r <= 1'b1;
                if (glb_psum_rd_valid_in) begin
                    seed_rd_pending_r <= 1'b0;
                    seed_buf_valid_r <= 1'b1;
                    seed_buf_data_r <= glb_psum_rd_data_in;
                end

                for (col_i = 0; col_i < 4; col_i = col_i + 1) begin
                    if (seed_fire_w[col_i] && (seed_count_r[col_i] < m0_in)) begin
                        seed_count_r[col_i] <= seed_count_r[col_i] + 6'd2;
                        seed_pair_accepted_r[col_i] <= 1'b1;
                    end
                    if (output_fire_w[col_i] && (output_count_r[col_i] < m0_in))
                        output_count_r[col_i] <= output_count_r[col_i] + 6'd2;
                end

                if (seed_pair_done_w) begin
                    seed_pair_accepted_r <= 4'h0;
                    seed_buf_valid_r <= 1'b0;
                end

                if (active_valid_w && (output_count_r[0] < m0_in) && wr_buf_can_accept_w) begin
                    wr_buf_valid_r <= 1'b1;
                    wr_buf_addr_r <= psum_write_base_in + (completed_window_idx_in * pair_count_w) + pair_index_w;
                    wr_buf_data_r <= {
                        active_col_mask_r[3] ? psum_col_data_in[167:126] : 42'b0,
                        active_col_mask_r[2] ? psum_col_data_in[125:84]  : 42'b0,
                        active_col_mask_r[1] ? psum_col_data_in[83:42]   : 42'b0,
                        active_col_mask_r[0] ? psum_col_data_in[41:0]    : 42'b0
                    };
                end else if (wr_buf_fire_w) begin
                    wr_buf_valid_r <= 1'b0;
                end
            end
        end
    end

endmodule
