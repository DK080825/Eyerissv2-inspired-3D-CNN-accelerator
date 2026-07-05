`timescale 1ns/1ps

// ============================================================================
// Module      : PE_Cluster3x4_Dataflow_Controller
// Description : Main controller for one 3x4 PE cluster.
//               It reads the job settings, starts GLB reads, starts PE load,
//               MAC, slide, and PSUM writeback steps, then reports done.
//               The current checked path is stride-1 row-stationary compute.
// ============================================================================

module PE_Cluster3x4_Dataflow_Controller #(
    parameter integer GLB_AW = 8
) (
    // clock/reset -> controller
    input  wire                        clk,
    input  wire                        rst,

    // host/testbench -> controller: start one job
    input  wire                        ctrl_job_start_in,
    // controller -> host/testbench: job state
    output wire                        ctrl_job_busy_out,
    output wire                        ctrl_job_done_out,

    // host/testbench -> controller: job settings
    input  wire [4:0]                  desc_c_in_in,
    input  wire [11:0]                 desc_active_pe_mask_in,
    input  wire [15:0]                 desc_output_window_count_in,
    input  wire [GLB_AW-1:0]           desc_iact_addr_base_in,
    input  wire [15:0]                 desc_iact_addr_word_count_in,
    input  wire [GLB_AW-1:0]           desc_iact_data_base_in,
    input  wire [15:0]                 desc_iact_data_word_count_in,
    input  wire [GLB_AW-1:0]           desc_iact_append_addr_base_in,
    input  wire [15:0]                 desc_iact_append_addr_word_count_in,
    input  wire [GLB_AW-1:0]           desc_iact_append_data_base_in,
    input  wire [15:0]                 desc_iact_append_data_word_count_in,
    input  wire [GLB_AW-1:0]           desc_weight_addr_base_in,
    input  wire [15:0]                 desc_weight_addr_word_count_in,
    input  wire [GLB_AW-1:0]           desc_weight_data_base_in,
    input  wire [15:0]                 desc_weight_data_word_count_in,
    input  wire                        desc_weight_load_en_in,
    input  wire [GLB_AW-1:0]           desc_psum_read_base_in,
    input  wire [15:0]                 desc_psum_read_count_in,
    input  wire [GLB_AW-1:0]           desc_psum_write_base_in,
    input  wire [5:0]                  desc_m0_in,

    // controller <-> IACT/Weight GLB
    // stream0=IACT address, stream1=IACT data, stream2=Weight address, stream3=Weight data
    output wire [3:0]                  glb_input_rd_valid_out,
    input  wire [3:0]                  glb_input_rd_ready_in,
    output wire [(4*GLB_AW)-1:0]       glb_input_rd_addr_out,
    input  wire [3:0]                  glb_input_resp_valid_in,
    output wire [3:0]                  glb_input_resp_ready_out,
    input  wire [194:0]                glb_input_resp_data_in,

    // PE cluster -> controller: PE done/ready flags
    input  wire [11:0]                 hm_pe_iact_addr_write_fin_in,
    input  wire [11:0]                 hm_pe_iact_data_write_fin_in,
    input  wire [11:0]                 hm_pe_weight_addr_write_fin_in,
    input  wire [11:0]                 hm_pe_weight_data_write_fin_in,
    input  wire [11:0]                 hm_pe_slide_safe_in,
    input  wire [11:0]                 hm_pe_cal_fin_in,
    input  wire [11:0]                 hm_pe_psum_acc_fin_in,
    input  wire [5:0]                  hm_iact_addr_ready_in,
    input  wire [5:0]                  hm_iact_data_ready_in,
    input  wire [2:0]                  hm_weight_addr_ready_in,
    input  wire [2:0]                  hm_weight_data_ready_in,
    input  wire [3:0]                  hm_psum_seed_ready_in,
    input  wire [3:0]                  hm_psum_col_valid_in,
    input  wire signed [167:0]         hm_psum_col_data_in,

    // controller -> PSUM GLB
    output wire                        glb_psum_wr_valid_out,
    input  wire                        glb_psum_wr_ready_in,
    output wire [GLB_AW-1:0]           glb_psum_wr_addr_out,
    output wire [167:0]                glb_psum_wr_data_out,
    output wire                        glb_psum_rd_valid_out,
    input  wire                        glb_psum_rd_ready_in,
    output wire [GLB_AW-1:0]           glb_psum_rd_addr_out,
    input  wire                        glb_psum_rd_valid_in,
    output wire                        glb_psum_rd_ready_out,
    input  wire [167:0]                glb_psum_rd_data_in,
    // controller -> PE cluster: PSUM return ready
    output wire [3:0]                  ctrl_psum_col_ready_out,

    // controller -> PE cluster: IACT data and target masks
    output wire [5:0]                  ctrl_iact_addr_slot_valid_out,
    output wire [29:0]                 ctrl_iact_addr_data_out,
    output wire [71:0]                 ctrl_iact_addr_dst_mask_out,
    output wire [5:0]                  ctrl_iact_data_slot_valid_out,
    output wire [71:0]                 ctrl_iact_data_out,
    output wire [71:0]                 ctrl_iact_data_dst_mask_out,
    // controller -> PE cluster: run/load controls and Weight data
    output wire                        ctrl_do_mac_en_out,
    output wire [2:0]                  ctrl_weight_addr_valid_out,
    output wire [20:0]                 ctrl_weight_addr_data_out,
    output wire [11:0]                 ctrl_weight_addr_row_dst_mask_out,
    output wire [2:0]                  ctrl_weight_data_valid_out,
    output wire [71:0]                 ctrl_weight_data_out,
    output wire [11:0]                 ctrl_weight_data_row_dst_mask_out,
    output wire [3:0]                  ctrl_psum_seed_valid_out,
    output wire signed [167:0]         ctrl_psum_seed_data_out,
    // controller -> PE cluster: PE control signals
    output wire [11:0]                 ctrl_pe_disable_out,
    output wire                        ctrl_psum_enq_en_out,
    output wire                        ctrl_do_load_en_out,
    output wire                        ctrl_iact_write_fin_clear_out,
    output wire                        ctrl_weight_write_fin_clear_out,
    output wire                        ctrl_psum_spad_clear_out,
    output wire [4:0]                  ctrl_cfg_segment_len_out,
    output wire [3:0]                  ctrl_cfg_window_seg_count_out,
    output wire [5:0]                  ctrl_cfg_m0_out,
    output wire                        ctrl_cfg_iact_flush_out,
    output wire                        ctrl_cfg_slide_commit_out
);

    localparam [4:0] ST_IDLE             = 5'd0;
    localparam [4:0] ST_LATCH_DESC       = 5'd1;
    localparam [4:0] ST_PASS_REARM       = 5'd2;
    localparam [4:0] ST_CFG_PE           = 5'd3;
    localparam [4:0] ST_WEIGHT_ADDR_READ = 5'd4;
    localparam [4:0] ST_WEIGHT_DATA_READ = 5'd5;
    localparam [4:0] ST_IACT_ADDR_READ   = 5'd6;
    localparam [4:0] ST_IACT_DATA_READ   = 5'd7;
    localparam [4:0] ST_PSUM_CLEAR       = 5'd8;
    localparam [4:0] ST_MAC_PULSE        = 5'd9;
    localparam [4:0] ST_WAIT_CAL         = 5'd10;
    localparam [4:0] ST_WAIT_SLIDE_SAFE  = 5'd11;
    localparam [4:0] ST_SLIDE_COMMIT     = 5'd12;
    localparam [4:0] ST_PSUM_ENQ         = 5'd13;
    localparam [4:0] ST_PSUM_DRAIN       = 5'd14;
    localparam [4:0] ST_APPEND_REARM     = 5'd15;
    localparam [4:0] ST_DONE             = 5'd16;

    reg [4:0]        state_r;
    reg              start_prev_r;
    reg [4:0]        c_in_r;
    reg [11:0]       active_pe_mask_r;
    reg [15:0]       output_window_count_r;
    reg [15:0]       current_window_idx_r;
    reg [GLB_AW-1:0] iact_addr_base_r;
    reg [15:0]       iact_addr_word_count_r;
    reg [GLB_AW-1:0] iact_data_base_r;
    reg [15:0]       iact_data_word_count_r;
    reg [15:0]       iact_append_addr_word_count_r;
    reg [15:0]       iact_append_data_word_count_r;
    reg [GLB_AW-1:0] iact_append_addr_cursor_r;
    reg [GLB_AW-1:0] iact_append_data_cursor_r;
    reg [GLB_AW-1:0] weight_addr_base_r;
    reg [15:0]       weight_addr_word_count_r;
    reg [GLB_AW-1:0] weight_data_base_r;
    reg [15:0]       weight_data_word_count_r;
    reg              weight_load_en_r;
    reg [GLB_AW-1:0] psum_read_base_r;
    reg [15:0]       psum_read_count_r;
    reg [GLB_AW-1:0] psum_write_base_r;
    reg [5:0]        m0_r;
    reg [11:0]       cal_fin_seen_r;
    reg [11:0]       slide_safe_seen_r;
    reg              iact_append_phase_r;
    reg              slide_after_psum_drain_r;

    wire start_pulse_w = ctrl_job_start_in & ~start_prev_r;
    wire weight_load_contract_valid_w =
        weight_load_en_r ?
            ((weight_addr_word_count_r != 16'd0) && (weight_data_word_count_r != 16'd0)) :
            ((weight_addr_word_count_r == 16'd0) && (weight_data_word_count_r == 16'd0));
    wire w0_compute_requested_w = (iact_addr_word_count_r != 16'd0) &
                                  (iact_data_word_count_r != 16'd0);
    wire valid_s1_job_w = (c_in_r != 5'd0) & (active_pe_mask_r != 12'h000) &
                            (output_window_count_r != 16'd0) &
                            (!w0_compute_requested_w || weight_load_contract_valid_w);
    wire weight_addr_seq_start_w = (state_r == ST_CFG_PE);
    wire weight_addr_seq_done_w;
    wire weight_data_seq_done_w;
    wire iact_addr_seq_done_w;
    wire iact_data_seq_done_w;
    wire weight_data_seq_start_w = (state_r == ST_WEIGHT_DATA_READ) && !weight_data_seq_done_w;
    wire iact_addr_seq_start_w = (state_r == ST_IACT_ADDR_READ) && !iact_addr_seq_done_w;
    wire iact_data_seq_start_w = (state_r == ST_IACT_DATA_READ) && !iact_data_seq_done_w;
    wire iact_addr_stage_valid_w;
    wire iact_addr_stage_load_w;
    wire iact_addr_write_fin_done_w;
    wire iact_data_stage_valid_w;
    wire iact_data_stage_load_w;
    wire iact_data_write_fin_done_w;
    wire weight_addr_stage_valid_w;
    wire weight_addr_write_fin_done_w;
    wire weight_data_stage_valid_w;
    wire weight_data_write_fin_done_w;
    wire [11:0] cal_fin_seen_next_w = cal_fin_seen_r | (hm_pe_cal_fin_in & active_pe_mask_r);
    wire cal_fin_done_w = ((cal_fin_seen_next_w & active_pe_mask_r) == active_pe_mask_r);
    wire [11:0] slide_safe_seen_next_w = slide_safe_seen_r | (hm_pe_slide_safe_in & active_pe_mask_r);
    wire slide_safe_done_w = ((slide_safe_seen_next_w & active_pe_mask_r) == active_pe_mask_r);
    wire append_loop_active_w = (output_window_count_r > 16'd1);
    wire [15:0] window_next_index_w = current_window_idx_r + 16'd1;
    wire window_more_w = (window_next_index_w < output_window_count_r);
    wire [3:0] active_col_mask_w = {
        |{active_pe_mask_r[11], active_pe_mask_r[7], active_pe_mask_r[3]},
        |{active_pe_mask_r[10], active_pe_mask_r[6], active_pe_mask_r[2]},
        |{active_pe_mask_r[9],  active_pe_mask_r[5], active_pe_mask_r[1]},
        |{active_pe_mask_r[8],  active_pe_mask_r[4], active_pe_mask_r[0]}
    };
    wire [15:0] psum_completed_window_idx_w =
        current_window_idx_r - (slide_after_psum_drain_r ? 16'd1 : 16'd0);
    wire psum_drain_done_w;
    wire load_state_w =
        (state_r == ST_PASS_REARM) ||
        (state_r == ST_CFG_PE) ||
        (state_r == ST_WEIGHT_ADDR_READ) ||
        (state_r == ST_WEIGHT_DATA_READ) ||
        (state_r == ST_APPEND_REARM) ||
        (state_r == ST_IACT_ADDR_READ) ||
        (state_r == ST_IACT_DATA_READ);
    wire [3:0] input_read_start_w = {
        weight_data_seq_start_w,
        weight_addr_seq_start_w,
        iact_data_seq_start_w,
        iact_addr_seq_start_w
    };
    wire [(4*GLB_AW)-1:0] input_read_base_w = {
        weight_data_base_r,
        weight_addr_base_r,
        iact_data_base_r,
        iact_addr_base_r
    };
    wire [63:0] input_read_count_w = {
        weight_data_word_count_r,
        weight_addr_word_count_r,
        iact_data_word_count_r,
        iact_addr_word_count_r
    };
    wire [3:0] input_read_done_w;
    wire [3:0] input_stage_valid_w;
    wire [1:0] input_iact_stage_load_w;
    wire [3:0] input_write_fin_done_w;

    assign iact_addr_seq_done_w = input_read_done_w[0];
    assign iact_data_seq_done_w = input_read_done_w[1];
    assign weight_addr_seq_done_w = input_read_done_w[2];
    assign weight_data_seq_done_w = input_read_done_w[3];
    assign iact_addr_stage_valid_w = input_stage_valid_w[0];
    assign iact_data_stage_valid_w = input_stage_valid_w[1];
    assign weight_addr_stage_valid_w = input_stage_valid_w[2];
    assign weight_data_stage_valid_w = input_stage_valid_w[3];
    assign iact_addr_stage_load_w = input_iact_stage_load_w[0];
    assign iact_data_stage_load_w = input_iact_stage_load_w[1];
    assign iact_addr_write_fin_done_w = input_write_fin_done_w[0];
    assign iact_data_write_fin_done_w = input_write_fin_done_w[1];
    assign weight_addr_write_fin_done_w = input_write_fin_done_w[2];
    assign weight_data_write_fin_done_w = input_write_fin_done_w[3];
    always @(posedge clk) begin
        if (rst) start_prev_r <= 1'b0;
        else start_prev_r <= ctrl_job_start_in;
    end

    always @(posedge clk) begin
        if (rst) begin
            state_r <= ST_IDLE;
            c_in_r <= 5'd0;
            active_pe_mask_r <= 12'h000;
            output_window_count_r <= 16'd0;
            current_window_idx_r <= 16'd0;
            iact_addr_base_r <= {GLB_AW{1'b0}};
            iact_addr_word_count_r <= 16'd0;
            iact_data_base_r <= {GLB_AW{1'b0}};
            iact_data_word_count_r <= 16'd0;
            iact_append_addr_word_count_r <= 16'd0;
            iact_append_data_word_count_r <= 16'd0;
            iact_append_addr_cursor_r <= {GLB_AW{1'b0}};
            iact_append_data_cursor_r <= {GLB_AW{1'b0}};
            weight_addr_base_r <= {GLB_AW{1'b0}};
            weight_addr_word_count_r <= 16'd0;
            weight_data_base_r <= {GLB_AW{1'b0}};
            weight_data_word_count_r <= 16'd0;
            weight_load_en_r <= 1'b0;
            psum_read_base_r <= {GLB_AW{1'b0}};
            psum_read_count_r <= 16'd0;
            psum_write_base_r <= {GLB_AW{1'b0}};
            m0_r <= 6'd0;
            cal_fin_seen_r <= 12'h000;
            slide_safe_seen_r <= 12'h000;
            iact_append_phase_r <= 1'b0;
            slide_after_psum_drain_r <= 1'b0;
        end else begin
            case (state_r)
                    ST_IDLE: begin
                        if (start_pulse_w) state_r <= ST_LATCH_DESC;
                    end

                    ST_LATCH_DESC: begin
                        c_in_r <= desc_c_in_in;
                        active_pe_mask_r <= desc_active_pe_mask_in;
                        output_window_count_r <= desc_output_window_count_in;
                        current_window_idx_r <= 16'd0;
                        iact_addr_base_r <= desc_iact_addr_base_in;
                        iact_addr_word_count_r <= desc_iact_addr_word_count_in;
                        iact_data_base_r <= desc_iact_data_base_in;
                        iact_data_word_count_r <= desc_iact_data_word_count_in;
                        iact_append_addr_word_count_r <= desc_iact_append_addr_word_count_in;
                        iact_append_data_word_count_r <= desc_iact_append_data_word_count_in;
                        iact_append_addr_cursor_r <= desc_iact_append_addr_base_in;
                        iact_append_data_cursor_r <= desc_iact_append_data_base_in;
                        weight_addr_base_r <= desc_weight_addr_base_in;
                        weight_addr_word_count_r <= desc_weight_addr_word_count_in;
                        weight_data_base_r <= desc_weight_data_base_in;
                        weight_data_word_count_r <= desc_weight_data_word_count_in;
                        weight_load_en_r <= desc_weight_load_en_in;
                        psum_read_base_r <= desc_psum_read_base_in;
                        psum_read_count_r <= desc_psum_read_count_in;
                        psum_write_base_r <= desc_psum_write_base_in;
                        m0_r <= desc_m0_in;
                        state_r <= ST_PASS_REARM;
                    end

                    ST_PASS_REARM: begin
                        if (valid_s1_job_w) state_r <= ST_CFG_PE;
                        else state_r <= ST_DONE;
                    end

                    ST_CFG_PE: begin
                        cal_fin_seen_r <= 12'h000;
                        slide_safe_seen_r <= 12'h000;
                        current_window_idx_r <= 16'd0;
                        iact_append_phase_r <= 1'b0;
                        slide_after_psum_drain_r <= 1'b0;
                        if (weight_load_en_r)
                            state_r <= ST_WEIGHT_ADDR_READ;
                        else if (iact_addr_word_count_r != 16'd0)
                            state_r <= ST_IACT_ADDR_READ;
                        else if (iact_data_word_count_r != 16'd0)
                            state_r <= ST_IACT_DATA_READ;
                        else
                            state_r <= ST_DONE;
                    end

                    ST_WEIGHT_ADDR_READ: begin
                        if (weight_addr_seq_done_w &
                            !weight_addr_stage_valid_w &
                            weight_addr_write_fin_done_w) begin
                            if (weight_data_word_count_r != 16'd0)
                                state_r <= ST_WEIGHT_DATA_READ;
                            else if (iact_addr_word_count_r != 16'd0)
                                state_r <= ST_IACT_ADDR_READ;
                            else if (iact_data_word_count_r != 16'd0)
                                state_r <= ST_IACT_DATA_READ;
                            else
                                state_r <= ST_DONE;
                        end
                    end

                    ST_WEIGHT_DATA_READ: begin
                        if (weight_data_seq_done_w &
                            !weight_data_stage_valid_w &
                            weight_data_write_fin_done_w) begin
                            if (iact_addr_word_count_r != 16'd0)
                                state_r <= ST_IACT_ADDR_READ;
                            else if (iact_data_word_count_r != 16'd0)
                                state_r <= ST_IACT_DATA_READ;
                            else
                                state_r <= ST_DONE;
                        end
                    end

                    ST_IACT_ADDR_READ: begin
                        if (iact_addr_seq_done_w &
                            !iact_addr_stage_valid_w &
                            !iact_addr_stage_load_w) begin
                            if (iact_data_word_count_r != 16'd0) begin
                                state_r <= ST_IACT_DATA_READ;
                            end
                            else if (iact_addr_write_fin_done_w) begin
                                if (w0_compute_requested_w)
                                    state_r <= ST_PSUM_CLEAR;
                                else
                                    state_r <= ST_DONE;
                            end
                        end
                    end

                    ST_IACT_DATA_READ: begin
                        if (iact_data_seq_done_w &
                            !iact_data_stage_valid_w &
                            !iact_data_stage_load_w &
                            iact_data_write_fin_done_w) begin
                            if (iact_append_phase_r) begin
                                iact_append_phase_r <= 1'b0;
                                cal_fin_seen_r <= 12'h000;
                                state_r <= ST_PSUM_CLEAR;
                            end else if (w0_compute_requested_w) begin
                                cal_fin_seen_r <= 12'h000;
                                state_r <= ST_PSUM_CLEAR;
                            end else begin
                                state_r <= ST_DONE;
                            end
                        end
                    end

                    ST_PSUM_CLEAR: begin
                        cal_fin_seen_r <= 12'h000;
                        state_r <= ST_MAC_PULSE;
                    end

                    ST_MAC_PULSE: begin
                        cal_fin_seen_r <= 12'h000;
                        slide_safe_seen_r <= 12'h000;
                        state_r <= ST_WAIT_CAL;
                    end

                    ST_WAIT_CAL: begin
                        cal_fin_seen_r <= cal_fin_seen_next_w;
                        if (cal_fin_done_w) begin
                            if (window_more_w)
                                state_r <= ST_WAIT_SLIDE_SAFE;
                            else
                                state_r <= ST_PSUM_ENQ;
                        end
                    end

                    ST_PSUM_ENQ: begin
                        state_r <= ST_PSUM_DRAIN;
                    end

                    ST_PSUM_DRAIN: begin
                        if (psum_drain_done_w) begin
                            if (slide_after_psum_drain_r) begin
                                slide_after_psum_drain_r <= 1'b0;
                                state_r <= ST_APPEND_REARM;
                            end else begin
                                state_r <= ST_DONE;
                            end
                        end
                    end

                    ST_WAIT_SLIDE_SAFE: begin
                        slide_safe_seen_r <= slide_safe_seen_next_w;
                        if (slide_safe_done_w)
                            state_r <= ST_SLIDE_COMMIT;
                    end

                    ST_SLIDE_COMMIT: begin
                        current_window_idx_r <= window_next_index_w;
                        slide_after_psum_drain_r <= 1'b1;
                        state_r <= ST_PSUM_ENQ;
                    end

                    ST_APPEND_REARM: begin
                        if (append_loop_active_w && (iact_append_addr_word_count_r != 16'd0)) begin
                            iact_append_phase_r <= 1'b1;
                            iact_addr_base_r <= iact_append_addr_cursor_r;
                            iact_addr_word_count_r <= iact_append_addr_word_count_r;
                            iact_data_base_r <= iact_append_data_cursor_r;
                            iact_data_word_count_r <= iact_append_data_word_count_r;
                            iact_append_addr_cursor_r <= iact_append_addr_cursor_r + iact_append_addr_word_count_r;
                            iact_append_data_cursor_r <= iact_append_data_cursor_r + iact_append_data_word_count_r;
                            state_r <= ST_IACT_ADDR_READ;
                        end else if (append_loop_active_w && (iact_append_data_word_count_r != 16'd0)) begin
                            iact_append_phase_r <= 1'b1;
                            iact_addr_word_count_r <= 16'd0;
                            iact_data_base_r <= iact_append_data_cursor_r;
                            iact_data_word_count_r <= iact_append_data_word_count_r;
                            iact_append_data_cursor_r <= iact_append_data_cursor_r + iact_append_data_word_count_r;
                            state_r <= ST_IACT_DATA_READ;
                        end else begin
                            state_r <= ST_PSUM_CLEAR;
                        end
                    end

                    ST_DONE: begin
                        if (!ctrl_job_start_in) state_r <= ST_IDLE;
                    end

                default: state_r <= ST_IDLE;
            endcase

        end
    end

    assign ctrl_job_busy_out = (state_r != ST_IDLE) && (state_r != ST_DONE);
    assign ctrl_job_done_out = (state_r == ST_DONE);

    assign ctrl_do_mac_en_out = (state_r == ST_MAC_PULSE);
    assign ctrl_pe_disable_out = ~active_pe_mask_r;
    assign ctrl_psum_enq_en_out = (state_r == ST_PSUM_ENQ);
    assign ctrl_do_load_en_out = load_state_w;
    assign ctrl_iact_write_fin_clear_out =
        (state_r == ST_PASS_REARM) || (state_r == ST_APPEND_REARM);
    assign ctrl_weight_write_fin_clear_out =
        (state_r == ST_PASS_REARM) &&
        weight_load_en_r;
    assign ctrl_psum_spad_clear_out = (state_r == ST_PSUM_CLEAR);
    assign ctrl_cfg_segment_len_out = valid_s1_job_w ? c_in_r : 5'd0;
    assign ctrl_cfg_window_seg_count_out = valid_s1_job_w ? 4'd3 : 4'd0;
    assign ctrl_cfg_m0_out = m0_r;
    assign ctrl_cfg_iact_flush_out = (state_r == ST_PASS_REARM);
    assign ctrl_cfg_slide_commit_out = (state_r == ST_SLIDE_COMMIT);

    PE3x4_Psum_Streamer #(
        .GLB_AW(GLB_AW)
    ) u_psum_streamer (
        .clk(clk),
        .rst(rst),
        .start_in(state_r == ST_PSUM_ENQ),
        .active_in(state_r == ST_PSUM_DRAIN),
        .active_pe_mask_in(active_pe_mask_r),
        .active_col_mask_in(active_col_mask_w),
        .m0_in(m0_r),
        .completed_window_idx_in(psum_completed_window_idx_w),
        .psum_read_base_in(psum_read_base_r),
        .psum_read_count_in(psum_read_count_r),
        .psum_write_base_in(psum_write_base_r),
        .pe_psum_acc_fin_in(hm_pe_psum_acc_fin_in),
        .psum_seed_ready_in(hm_psum_seed_ready_in),
        .psum_col_valid_in(hm_psum_col_valid_in),
        .psum_col_data_in(hm_psum_col_data_in),
        .glb_psum_wr_valid_out(glb_psum_wr_valid_out),
        .glb_psum_wr_ready_in(glb_psum_wr_ready_in),
        .glb_psum_wr_addr_out(glb_psum_wr_addr_out),
        .glb_psum_wr_data_out(glb_psum_wr_data_out),
        .glb_psum_rd_valid_out(glb_psum_rd_valid_out),
        .glb_psum_rd_ready_in(glb_psum_rd_ready_in),
        .glb_psum_rd_addr_out(glb_psum_rd_addr_out),
        .glb_psum_rd_valid_in(glb_psum_rd_valid_in),
        .glb_psum_rd_ready_out(glb_psum_rd_ready_out),
        .glb_psum_rd_data_in(glb_psum_rd_data_in),
        .psum_col_ready_out(ctrl_psum_col_ready_out),
        .seed_valid_out(ctrl_psum_seed_valid_out),
        .seed_data_out(ctrl_psum_seed_data_out),
        .done_out(psum_drain_done_w)
    );

    PE3x4_Input_Streamer #(
        .GLB_AW(GLB_AW)
    ) u_input_streamer (
        .clk(clk),
        .rst(rst),
        .active_pe_mask_in(active_pe_mask_r),
        .iact_clear_in(ctrl_iact_write_fin_clear_out),
        .weight_clear_in(ctrl_weight_write_fin_clear_out),
        .read_start_in(input_read_start_w),
        .read_base_in(input_read_base_w),
        .read_count_in(input_read_count_w),
        .read_done_out(input_read_done_w),
        .stage_valid_out(input_stage_valid_w),
        .iact_stage_load_out(input_iact_stage_load_w),
        .write_fin_done_out(input_write_fin_done_w),
        .iact_fin_track_en_in({state_r == ST_IACT_DATA_READ, state_r == ST_IACT_ADDR_READ}),
        .glb_rd_valid_out(glb_input_rd_valid_out),
        .glb_rd_ready_in(glb_input_rd_ready_in),
        .glb_rd_addr_out(glb_input_rd_addr_out),
        .glb_resp_valid_in(glb_input_resp_valid_in),
        .glb_resp_ready_out(glb_input_resp_ready_out),
        .glb_resp_data_in(glb_input_resp_data_in),
        .pe_iact_addr_write_fin_in(hm_pe_iact_addr_write_fin_in),
        .pe_iact_data_write_fin_in(hm_pe_iact_data_write_fin_in),
        .pe_weight_addr_write_fin_in(hm_pe_weight_addr_write_fin_in),
        .pe_weight_data_write_fin_in(hm_pe_weight_data_write_fin_in),
        .iact_addr_ready_in(hm_iact_addr_ready_in),
        .iact_data_ready_in(hm_iact_data_ready_in),
        .weight_addr_ready_in(hm_weight_addr_ready_in),
        .weight_data_ready_in(hm_weight_data_ready_in),
        .iact_addr_slot_valid_out(ctrl_iact_addr_slot_valid_out),
        .iact_addr_data_out(ctrl_iact_addr_data_out),
        .iact_addr_dst_mask_out(ctrl_iact_addr_dst_mask_out),
        .iact_data_slot_valid_out(ctrl_iact_data_slot_valid_out),
        .iact_data_out(ctrl_iact_data_out),
        .iact_data_dst_mask_out(ctrl_iact_data_dst_mask_out),
        .weight_addr_valid_out(ctrl_weight_addr_valid_out),
        .weight_addr_data_out(ctrl_weight_addr_data_out),
        .weight_addr_row_dst_mask_out(ctrl_weight_addr_row_dst_mask_out),
        .weight_data_valid_out(ctrl_weight_data_valid_out),
        .weight_data_out(ctrl_weight_data_out),
        .weight_data_row_dst_mask_out(ctrl_weight_data_row_dst_mask_out)
    );

endmodule
