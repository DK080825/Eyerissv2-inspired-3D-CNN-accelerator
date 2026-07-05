`timescale 1ns/1ps

// ============================================================================
// Module      : PE3x4_Input_Streamer
// Author      : Do Quoc Khanh
// Description : Reads IACT and Weight words from GLB and sends them to the PE
//               cluster. One GLB read engine is shared by the four streams
//               because the controller starts one stream at a time. Each GLB
//               word still carries all lanes in parallel.
// ============================================================================

module PE3x4_Input_Streamer #(
    parameter integer GLB_AW = 8
) (
    // clock/reset -> this block
    input  wire                        clk,
    input  wire                        rst,

    // controller -> this block
    input  wire [11:0]                 active_pe_mask_in,
    input  wire                        iact_clear_in,
    input  wire                        weight_clear_in,

    // controller -> this block: stream0=IACT_ADDR, stream1=IACT_DATA,
    // stream2=WEIGHT_ADDR, stream3=WEIGHT_DATA
    input  wire [3:0]                  read_start_in,
    input  wire [(4*GLB_AW)-1:0]       read_base_in,
    input  wire [63:0]                 read_count_in,
    output wire [3:0]                  read_done_out,
    output wire [3:0]                  stage_valid_out,
    output wire [1:0]                  iact_stage_load_out,
    output wire [3:0]                  write_fin_done_out,
    input  wire [1:0]                  iact_fin_track_en_in,

    // this block <-> GLB
    output wire [3:0]                  glb_rd_valid_out,
    input  wire [3:0]                  glb_rd_ready_in,
    output wire [(4*GLB_AW)-1:0]       glb_rd_addr_out,
    input  wire [3:0]                  glb_resp_valid_in,
    output wire [3:0]                  glb_resp_ready_out,
    input  wire [194:0]                glb_resp_data_in,

    // PE cluster -> this block
    input  wire [11:0]                 pe_iact_addr_write_fin_in,
    input  wire [11:0]                 pe_iact_data_write_fin_in,
    input  wire [11:0]                 pe_weight_addr_write_fin_in,
    input  wire [11:0]                 pe_weight_data_write_fin_in,
    input  wire [5:0]                  iact_addr_ready_in,
    input  wire [5:0]                  iact_data_ready_in,
    input  wire [2:0]                  weight_addr_ready_in,
    input  wire [2:0]                  weight_data_ready_in,

    // this block -> PE cluster
    output wire [5:0]                  iact_addr_slot_valid_out,
    output wire [29:0]                 iact_addr_data_out,
    output wire [71:0]                 iact_addr_dst_mask_out,
    output wire [5:0]                  iact_data_slot_valid_out,
    output wire [71:0]                 iact_data_out,
    output wire [71:0]                 iact_data_dst_mask_out,
    output wire [2:0]                  weight_addr_valid_out,
    output wire [20:0]                 weight_addr_data_out,
    output wire [11:0]                 weight_addr_row_dst_mask_out,
    output wire [2:0]                  weight_data_valid_out,
    output wire [71:0]                 weight_data_out,
    output wire [11:0]                 weight_data_row_dst_mask_out
);

    localparam [1:0] STREAM_IACT_ADDR   = 2'd0;
    localparam [1:0] STREAM_IACT_DATA   = 2'd1;
    localparam [1:0] STREAM_WEIGHT_ADDR = 2'd2;
    localparam [1:0] STREAM_WEIGHT_DATA = 2'd3;

    function [GLB_AW-1:0] stream_base_f;
        input [1:0] stream;
        begin
            case (stream)
                STREAM_IACT_ADDR:   stream_base_f = read_base_in[(0*GLB_AW) +: GLB_AW];
                STREAM_IACT_DATA:   stream_base_f = read_base_in[(1*GLB_AW) +: GLB_AW];
                STREAM_WEIGHT_ADDR: stream_base_f = read_base_in[(2*GLB_AW) +: GLB_AW];
                default:            stream_base_f = read_base_in[(3*GLB_AW) +: GLB_AW];
            endcase
        end
    endfunction

    function [15:0] stream_count_f;
        input [1:0] stream;
        begin
            case (stream)
                STREAM_IACT_ADDR:   stream_count_f = read_count_in[(0*16) +: 16];
                STREAM_IACT_DATA:   stream_count_f = read_count_in[(1*16) +: 16];
                STREAM_WEIGHT_ADDR: stream_count_f = read_count_in[(2*16) +: 16];
                default:            stream_count_f = read_count_in[(3*16) +: 16];
            endcase
        end
    endfunction

    function [1:0] start_stream_f;
        input [3:0] start;
        begin
            if (start[0])
                start_stream_f = STREAM_IACT_ADDR;
            else if (start[1])
                start_stream_f = STREAM_IACT_DATA;
            else if (start[2])
                start_stream_f = STREAM_WEIGHT_ADDR;
            else
                start_stream_f = STREAM_WEIGHT_DATA;
        end
    endfunction

    reg        read_active_r;
    reg        read_wait_resp_r;
    reg [1:0]  read_stream_r;
    reg [GLB_AW-1:0] read_base_r;
    reg [15:0] read_count_r;
    reg [15:0] read_index_r;
    reg [3:0]  read_done_r;

    reg        iact_addr_stage_valid_r;
    reg [29:0] iact_addr_stage_payload_r;
    reg [5:0]  iact_addr_stage_slot_valid_r;
    reg [71:0] iact_addr_stage_dst_mask_r;

    reg        iact_data_stage_valid_r;
    reg [71:0] iact_data_stage_payload_r;
    reg [5:0]  iact_data_stage_slot_valid_r;
    reg [71:0] iact_data_stage_dst_mask_r;

    reg        weight_addr_stage_valid_r;
    reg [20:0] weight_addr_stage_payload_r;
    reg [2:0]  weight_addr_stage_valid_lanes_r;
    reg [11:0] weight_addr_stage_row_dst_mask_r;

    reg        weight_data_stage_valid_r;
    reg [71:0] weight_data_stage_payload_r;
    reg [2:0]  weight_data_stage_valid_lanes_r;
    reg [11:0] weight_data_stage_row_dst_mask_r;

    reg [11:0] iact_addr_write_fin_seen_r;
    reg [11:0] iact_data_write_fin_seen_r;

    wire [1:0]  start_stream_w = start_stream_f(read_start_in);
    wire [15:0] start_count_w = stream_count_f(start_stream_w);
    wire        start_fire_w = (|read_start_in) && !read_active_r && !read_wait_resp_r;

    wire [29:0] glb_iact_addr_word_w = glb_resp_data_in[0 +: 30];
    wire [71:0] glb_iact_data_word_w = glb_resp_data_in[30 +: 72];
    wire [20:0] glb_weight_addr_word_w = glb_resp_data_in[102 +: 21];
    wire [71:0] glb_weight_data_word_w = glb_resp_data_in[123 +: 72];

    wire [11:0] weight_row0_mask_w = active_pe_mask_in & 12'h00f;
    wire [11:0] weight_row1_mask_w = active_pe_mask_in & 12'h0f0;
    wire [11:0] weight_row2_mask_w = active_pe_mask_in & 12'hf00;
    wire [2:0]  weight_valid_lanes_w = {|weight_row2_mask_w, |weight_row1_mask_w, |weight_row0_mask_w};
    wire [11:0] weight_row_dst_mask_w = weight_row0_mask_w | weight_row1_mask_w | weight_row2_mask_w;

    wire [11:0] s1_slot0_mask_w = active_pe_mask_in & 12'h001;
    wire [11:0] s1_slot1_mask_w = active_pe_mask_in & 12'h012;
    wire [11:0] s1_slot2_mask_w = active_pe_mask_in & 12'h124;
    wire [11:0] s1_slot3_mask_w = active_pe_mask_in & 12'h248;
    wire [11:0] s1_slot4_mask_w = active_pe_mask_in & 12'h480;
    wire [11:0] s1_slot5_mask_w = active_pe_mask_in & 12'h800;

    wire [5:0] iact_addr_slot_valid_w = {
        (s1_slot5_mask_w != 12'h000),
        (s1_slot4_mask_w != 12'h000),
        (s1_slot3_mask_w != 12'h000),
        (s1_slot2_mask_w != 12'h000),
        (s1_slot1_mask_w != 12'h000),
        (s1_slot0_mask_w != 12'h000)
    };

    wire [5:0] iact_data_slot_present_w = {
        (glb_iact_data_word_w[60 +: 12] != 12'h000),
        (glb_iact_data_word_w[48 +: 12] != 12'h000),
        (glb_iact_data_word_w[36 +: 12] != 12'h000),
        (glb_iact_data_word_w[24 +: 12] != 12'h000),
        (glb_iact_data_word_w[12 +: 12] != 12'h000),
        (glb_iact_data_word_w[0 +: 12] != 12'h000)
    };

    wire [5:0] iact_data_slot_valid_w = {
        iact_data_slot_present_w[5] && (s1_slot5_mask_w != 12'h000),
        iact_data_slot_present_w[4] && (s1_slot4_mask_w != 12'h000),
        iact_data_slot_present_w[3] && (s1_slot3_mask_w != 12'h000),
        iact_data_slot_present_w[2] && (s1_slot2_mask_w != 12'h000),
        iact_data_slot_present_w[1] && (s1_slot1_mask_w != 12'h000),
        iact_data_slot_present_w[0] && (s1_slot0_mask_w != 12'h000)
    };

    wire [71:0] iact_addr_dst_mask_w = {
        iact_addr_slot_valid_w[5] ? s1_slot5_mask_w : 12'h000,
        iact_addr_slot_valid_w[4] ? s1_slot4_mask_w : 12'h000,
        iact_addr_slot_valid_w[3] ? s1_slot3_mask_w : 12'h000,
        iact_addr_slot_valid_w[2] ? s1_slot2_mask_w : 12'h000,
        iact_addr_slot_valid_w[1] ? s1_slot1_mask_w : 12'h000,
        iact_addr_slot_valid_w[0] ? s1_slot0_mask_w : 12'h000
    };

    wire [71:0] iact_data_dst_mask_w = {
        iact_data_slot_valid_w[5] ? s1_slot5_mask_w : 12'h000,
        iact_data_slot_valid_w[4] ? s1_slot4_mask_w : 12'h000,
        iact_data_slot_valid_w[3] ? s1_slot3_mask_w : 12'h000,
        iact_data_slot_valid_w[2] ? s1_slot2_mask_w : 12'h000,
        iact_data_slot_valid_w[1] ? s1_slot1_mask_w : 12'h000,
        iact_data_slot_valid_w[0] ? s1_slot0_mask_w : 12'h000
    };

    wire iact_addr_ready_w =
        ((iact_addr_ready_in & iact_addr_stage_slot_valid_r) == iact_addr_stage_slot_valid_r);
    wire iact_data_ready_w =
        ((iact_data_ready_in & iact_data_stage_slot_valid_r) == iact_data_stage_slot_valid_r);
    wire weight_addr_ready_w =
        ((weight_addr_ready_in & weight_addr_stage_valid_lanes_r) == weight_addr_stage_valid_lanes_r);
    wire weight_data_ready_w =
        ((weight_data_ready_in & weight_data_stage_valid_lanes_r) == weight_data_stage_valid_lanes_r);

    wire iact_addr_fire_w = iact_addr_stage_valid_r && iact_addr_ready_w;
    wire iact_data_fire_w = iact_data_stage_valid_r && iact_data_ready_w;
    wire weight_addr_fire_w = weight_addr_stage_valid_r && weight_addr_ready_w;
    wire weight_data_fire_w = weight_data_stage_valid_r && weight_data_ready_w;

    wire iact_addr_can_load_w = !iact_addr_stage_valid_r || iact_addr_fire_w;
    wire iact_data_can_load_w = !iact_data_stage_valid_r || iact_data_fire_w;
    wire weight_addr_can_load_w = !weight_addr_stage_valid_r || weight_addr_fire_w;
    wire weight_data_can_load_w = !weight_data_stage_valid_r || weight_data_fire_w;

    reg stream_can_load_w;
    always @(*) begin
        case (read_stream_r)
            STREAM_IACT_ADDR:   stream_can_load_w = iact_addr_can_load_w;
            STREAM_IACT_DATA:   stream_can_load_w = iact_data_can_load_w;
            STREAM_WEIGHT_ADDR: stream_can_load_w = weight_addr_can_load_w;
            default:            stream_can_load_w = weight_data_can_load_w;
        endcase
    end

    wire [GLB_AW-1:0] read_addr_w = read_base_r + read_index_r[GLB_AW-1:0];
    wire [3:0] read_stream_mask_w = 4'b0001 << read_stream_r;
    wire read_req_valid_w = read_active_r && !read_wait_resp_r;
    wire read_req_fire_w = read_req_valid_w && glb_rd_ready_in[read_stream_r];
    wire read_resp_fire_w =
        read_active_r && read_wait_resp_r &&
        glb_resp_valid_in[read_stream_r] && stream_can_load_w;

    wire iact_addr_load_w = read_resp_fire_w && (read_stream_r == STREAM_IACT_ADDR);
    wire iact_data_load_w = read_resp_fire_w && (read_stream_r == STREAM_IACT_DATA);
    wire weight_addr_load_w = read_resp_fire_w && (read_stream_r == STREAM_WEIGHT_ADDR);
    wire weight_data_load_w = read_resp_fire_w && (read_stream_r == STREAM_WEIGHT_DATA);

    wire [11:0] iact_addr_write_fin_seen_next_w =
        iact_addr_write_fin_seen_r | (pe_iact_addr_write_fin_in & active_pe_mask_in);
    wire [11:0] iact_data_write_fin_seen_next_w =
        iact_data_write_fin_seen_r | (pe_iact_data_write_fin_in & active_pe_mask_in);

    assign read_done_out = read_done_r;
    assign stage_valid_out = {
        weight_data_stage_valid_r,
        weight_addr_stage_valid_r,
        iact_data_stage_valid_r,
        iact_addr_stage_valid_r
    };
    assign iact_stage_load_out = {iact_data_load_w, iact_addr_load_w};

    assign glb_rd_valid_out = read_req_valid_w ? read_stream_mask_w : 4'h0;
    assign glb_rd_addr_out = {
        (read_stream_r == STREAM_WEIGHT_DATA) ? read_addr_w : {GLB_AW{1'b0}},
        (read_stream_r == STREAM_WEIGHT_ADDR) ? read_addr_w : {GLB_AW{1'b0}},
        (read_stream_r == STREAM_IACT_DATA) ? read_addr_w : {GLB_AW{1'b0}},
        (read_stream_r == STREAM_IACT_ADDR) ? read_addr_w : {GLB_AW{1'b0}}
    };
    assign glb_resp_ready_out =
        (read_active_r && read_wait_resp_r && stream_can_load_w) ? read_stream_mask_w : 4'h0;

    assign write_fin_done_out = {
        ((pe_weight_data_write_fin_in & active_pe_mask_in) == active_pe_mask_in),
        ((pe_weight_addr_write_fin_in & active_pe_mask_in) == active_pe_mask_in),
        ((iact_data_write_fin_seen_next_w & active_pe_mask_in) == active_pe_mask_in),
        ((iact_addr_write_fin_seen_next_w & active_pe_mask_in) == active_pe_mask_in)
    };

    assign iact_addr_slot_valid_out = iact_addr_stage_valid_r ? iact_addr_stage_slot_valid_r : 6'h00;
    assign iact_addr_data_out = iact_addr_stage_payload_r;
    assign iact_addr_dst_mask_out = iact_addr_stage_valid_r ? iact_addr_stage_dst_mask_r : 72'h0;

    assign iact_data_slot_valid_out = iact_data_stage_valid_r ? iact_data_stage_slot_valid_r : 6'h00;
    assign iact_data_out = iact_data_stage_payload_r;
    assign iact_data_dst_mask_out = iact_data_stage_valid_r ? iact_data_stage_dst_mask_r : 72'h0;

    assign weight_addr_valid_out = weight_addr_stage_valid_r ? weight_addr_stage_valid_lanes_r : 3'b000;
    assign weight_addr_data_out = weight_addr_stage_payload_r;
    assign weight_addr_row_dst_mask_out =
        weight_addr_stage_valid_r ? weight_addr_stage_row_dst_mask_r : 12'h000;

    assign weight_data_valid_out = weight_data_stage_valid_r ? weight_data_stage_valid_lanes_r : 3'b000;
    assign weight_data_out = weight_data_stage_payload_r;
    assign weight_data_row_dst_mask_out =
        weight_data_stage_valid_r ? weight_data_stage_row_dst_mask_r : 12'h000;

    always @(posedge clk) begin
        if (rst) begin
            read_active_r <= 1'b0;
            read_wait_resp_r <= 1'b0;
            read_stream_r <= STREAM_IACT_ADDR;
            read_base_r <= {GLB_AW{1'b0}};
            read_count_r <= 16'd0;
            read_index_r <= 16'd0;
            read_done_r <= 4'h0;
        end else begin
            if (iact_clear_in || weight_clear_in) begin
                read_done_r <= 4'h0;
            end

            if (start_fire_w) begin
                read_stream_r <= start_stream_w;
                read_base_r <= stream_base_f(start_stream_w);
                read_count_r <= start_count_w;
                read_index_r <= 16'd0;
                read_wait_resp_r <= 1'b0;
                read_done_r <= 4'h0;

                if (start_count_w == 16'd0) begin
                    read_active_r <= 1'b0;
                    read_done_r <= 4'b0001 << start_stream_w;
                end else begin
                    read_active_r <= 1'b1;
                end
            end else begin
                if (read_req_fire_w)
                    read_wait_resp_r <= 1'b1;

                if (read_resp_fire_w) begin
                    read_wait_resp_r <= 1'b0;
                    if ((read_index_r + 16'd1) >= read_count_r) begin
                        read_active_r <= 1'b0;
                        read_done_r <= read_stream_mask_w;
                    end else begin
                        read_index_r <= read_index_r + 16'd1;
                    end
                end
            end
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            iact_addr_stage_valid_r <= 1'b0;
            iact_addr_stage_payload_r <= 30'h0;
            iact_addr_stage_slot_valid_r <= 6'h00;
            iact_addr_stage_dst_mask_r <= 72'h0;
            iact_data_stage_valid_r <= 1'b0;
            iact_data_stage_payload_r <= 72'h0;
            iact_data_stage_slot_valid_r <= 6'h00;
            iact_data_stage_dst_mask_r <= 72'h0;
            weight_addr_stage_valid_r <= 1'b0;
            weight_addr_stage_payload_r <= 21'h0;
            weight_addr_stage_valid_lanes_r <= 3'b000;
            weight_addr_stage_row_dst_mask_r <= 12'h000;
            weight_data_stage_valid_r <= 1'b0;
            weight_data_stage_payload_r <= 72'h0;
            weight_data_stage_valid_lanes_r <= 3'b000;
            weight_data_stage_row_dst_mask_r <= 12'h000;
            iact_addr_write_fin_seen_r <= 12'h000;
            iact_data_write_fin_seen_r <= 12'h000;
        end else begin
            if (iact_clear_in)
                iact_addr_write_fin_seen_r <= 12'h000;
            else if (iact_fin_track_en_in[0])
                iact_addr_write_fin_seen_r <= iact_addr_write_fin_seen_next_w;

            if (iact_clear_in)
                iact_data_write_fin_seen_r <= 12'h000;
            else if (iact_fin_track_en_in[1])
                iact_data_write_fin_seen_r <= iact_data_write_fin_seen_next_w;

            if (weight_clear_in) begin
                weight_addr_stage_valid_r <= 1'b0;
                weight_data_stage_valid_r <= 1'b0;
            end

            if (iact_addr_load_w) begin
                iact_addr_stage_valid_r <= 1'b1;
                iact_addr_stage_payload_r <= glb_iact_addr_word_w;
                iact_addr_stage_slot_valid_r <= iact_addr_slot_valid_w;
                iact_addr_stage_dst_mask_r <= iact_addr_dst_mask_w;
            end else if (iact_addr_fire_w) begin
                iact_addr_stage_valid_r <= 1'b0;
            end

            if (iact_data_load_w) begin
                iact_data_stage_valid_r <= 1'b1;
                iact_data_stage_payload_r <= glb_iact_data_word_w;
                iact_data_stage_slot_valid_r <= iact_data_slot_valid_w;
                iact_data_stage_dst_mask_r <= iact_data_dst_mask_w;
            end else if (iact_data_fire_w) begin
                iact_data_stage_valid_r <= 1'b0;
            end

            if (weight_addr_load_w) begin
                weight_addr_stage_valid_r <= 1'b1;
                weight_addr_stage_payload_r <= glb_weight_addr_word_w;
                weight_addr_stage_valid_lanes_r <= weight_valid_lanes_w;
                weight_addr_stage_row_dst_mask_r <= weight_row_dst_mask_w;
            end else if (weight_addr_fire_w) begin
                weight_addr_stage_valid_r <= 1'b0;
            end

            if (weight_data_load_w) begin
                weight_data_stage_valid_r <= 1'b1;
                weight_data_stage_payload_r <= glb_weight_data_word_w;
                weight_data_stage_valid_lanes_r <= weight_valid_lanes_w;
                weight_data_stage_row_dst_mask_r <= weight_row_dst_mask_w;
            end else if (weight_data_fire_w) begin
                weight_data_stage_valid_r <= 1'b0;
            end
        end
    end

endmodule
