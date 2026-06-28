`timescale 1ns/1ps

// ============================================================================
// Module      : Iact_Router
// Author      : Do Quoc Khanh
// Description : Circuit-switched router for one IACT physical lane.
//               Each physical lane carries two independently handshaken
//               logical packets for IACT address/data traffic.
//               Source selection is performed before route selection.
// ============================================================================
module Iact_Router #(
    parameter integer ADDR_W = 10,
    parameter integer DATA_W = 24,
    parameter integer PACKET_N = 2
) (
    input  wire [1:0]              data_in_sel_in,
    input  wire [2:0]              route_mask_in, // {horizontal, south, north}; local PE is always selected

    input  wire [PACKET_N-1:0]     local_addr_valid_in,
    output wire [PACKET_N-1:0]     local_addr_ready_out,
    input  wire [ADDR_W-1:0]       local_addr_in,
    input  wire [PACKET_N-1:0]     local_data_valid_in,
    output wire [PACKET_N-1:0]     local_data_ready_out,
    input  wire [DATA_W-1:0]       local_data_in,

    input  wire [PACKET_N-1:0]     north_addr_valid_in,
    output wire [PACKET_N-1:0]     north_addr_ready_out,
    input  wire [ADDR_W-1:0]       north_addr_in,
    input  wire [PACKET_N-1:0]     north_data_valid_in,
    output wire [PACKET_N-1:0]     north_data_ready_out,
    input  wire [DATA_W-1:0]       north_data_in,

    input  wire [PACKET_N-1:0]     south_addr_valid_in,
    output wire [PACKET_N-1:0]     south_addr_ready_out,
    input  wire [ADDR_W-1:0]       south_addr_in,
    input  wire [PACKET_N-1:0]     south_data_valid_in,
    output wire [PACKET_N-1:0]     south_data_ready_out,
    input  wire [DATA_W-1:0]       south_data_in,

    input  wire [PACKET_N-1:0]     horizontal_addr_valid_in,
    output wire [PACKET_N-1:0]     horizontal_addr_ready_out,
    input  wire [ADDR_W-1:0]       horizontal_addr_in,
    input  wire [PACKET_N-1:0]     horizontal_data_valid_in,
    output wire [PACKET_N-1:0]     horizontal_data_ready_out,
    input  wire [DATA_W-1:0]       horizontal_data_in,

    output wire [PACKET_N-1:0]     pe_addr_valid_out,
    input  wire [PACKET_N-1:0]     pe_addr_ready_in,
    output wire [ADDR_W-1:0]       pe_addr_out,
    output wire [PACKET_N-1:0]     pe_data_valid_out,
    input  wire [PACKET_N-1:0]     pe_data_ready_in,
    output wire [DATA_W-1:0]       pe_data_out,

    output wire [PACKET_N-1:0]     north_addr_valid_out,
    input  wire [PACKET_N-1:0]     north_addr_ready_in,
    output wire [ADDR_W-1:0]       north_addr_out,
    output wire [PACKET_N-1:0]     north_data_valid_out,
    input  wire [PACKET_N-1:0]     north_data_ready_in,
    output wire [DATA_W-1:0]       north_data_out,

    output wire [PACKET_N-1:0]     south_addr_valid_out,
    input  wire [PACKET_N-1:0]     south_addr_ready_in,
    output wire [ADDR_W-1:0]       south_addr_out,
    output wire [PACKET_N-1:0]     south_data_valid_out,
    input  wire [PACKET_N-1:0]     south_data_ready_in,
    output wire [DATA_W-1:0]       south_data_out,

    output wire [PACKET_N-1:0]     horizontal_addr_valid_out,
    input  wire [PACKET_N-1:0]     horizontal_addr_ready_in,
    output wire [ADDR_W-1:0]       horizontal_addr_out,
    output wire [PACKET_N-1:0]     horizontal_data_valid_out,
    input  wire [PACKET_N-1:0]     horizontal_data_ready_in,
    output wire [DATA_W-1:0]       horizontal_data_out
);

    localparam [1:0] SRC_LOCAL      = 2'd0;
    localparam [1:0] SRC_NORTH      = 2'd1;
    localparam [1:0] SRC_SOUTH      = 2'd2;
    localparam [1:0] SRC_HORIZONTAL = 2'd3;

    wire route_north_w = route_mask_in[0];
    wire route_south_w = route_mask_in[1];
    wire route_horizontal_w = route_mask_in[2];

    reg [PACKET_N-1:0] selected_addr_valid_w;
    reg [PACKET_N-1:0] selected_data_valid_w;
    reg [ADDR_W-1:0] selected_addr_w;
    reg [DATA_W-1:0] selected_data_w;

    wire [PACKET_N-1:0] addr_atomic_ready_w =
        pe_addr_ready_in &
        ({PACKET_N{~route_north_w}} | north_addr_ready_in) &
        ({PACKET_N{~route_south_w}} | south_addr_ready_in) &
        ({PACKET_N{~route_horizontal_w}} | horizontal_addr_ready_in);

    wire [PACKET_N-1:0] data_atomic_ready_w =
        pe_data_ready_in &
        ({PACKET_N{~route_north_w}} | north_data_ready_in) &
        ({PACKET_N{~route_south_w}} | south_data_ready_in) &
        ({PACKET_N{~route_horizontal_w}} | horizontal_data_ready_in);

    wire [PACKET_N-1:0] pe_addr_enable_w =
        ({PACKET_N{~route_north_w}} | north_addr_ready_in) &
        ({PACKET_N{~route_south_w}} | south_addr_ready_in) &
        ({PACKET_N{~route_horizontal_w}} | horizontal_addr_ready_in);
    wire [PACKET_N-1:0] north_addr_enable_w =
        pe_addr_ready_in &
        ({PACKET_N{~route_south_w}} | south_addr_ready_in) &
        ({PACKET_N{~route_horizontal_w}} | horizontal_addr_ready_in);
    wire [PACKET_N-1:0] south_addr_enable_w =
        pe_addr_ready_in &
        ({PACKET_N{~route_north_w}} | north_addr_ready_in) &
        ({PACKET_N{~route_horizontal_w}} | horizontal_addr_ready_in);
    wire [PACKET_N-1:0] horizontal_addr_enable_w =
        pe_addr_ready_in &
        ({PACKET_N{~route_north_w}} | north_addr_ready_in) &
        ({PACKET_N{~route_south_w}} | south_addr_ready_in);

    wire [PACKET_N-1:0] pe_data_enable_w =
        ({PACKET_N{~route_north_w}} | north_data_ready_in) &
        ({PACKET_N{~route_south_w}} | south_data_ready_in) &
        ({PACKET_N{~route_horizontal_w}} | horizontal_data_ready_in);
    wire [PACKET_N-1:0] north_data_enable_w =
        pe_data_ready_in &
        ({PACKET_N{~route_south_w}} | south_data_ready_in) &
        ({PACKET_N{~route_horizontal_w}} | horizontal_data_ready_in);
    wire [PACKET_N-1:0] south_data_enable_w =
        pe_data_ready_in &
        ({PACKET_N{~route_north_w}} | north_data_ready_in) &
        ({PACKET_N{~route_horizontal_w}} | horizontal_data_ready_in);
    wire [PACKET_N-1:0] horizontal_data_enable_w =
        pe_data_ready_in &
        ({PACKET_N{~route_north_w}} | north_data_ready_in) &
        ({PACKET_N{~route_south_w}} | south_data_ready_in);

    always @(*) begin
        selected_addr_valid_w = {PACKET_N{1'b0}};
        selected_data_valid_w = {PACKET_N{1'b0}};
        selected_addr_w = {ADDR_W{1'b0}};
        selected_data_w = {DATA_W{1'b0}};
        case (data_in_sel_in)
            SRC_LOCAL: begin
                selected_addr_valid_w = local_addr_valid_in;
                selected_data_valid_w = local_data_valid_in;
                selected_addr_w = local_addr_in;
                selected_data_w = local_data_in;
            end
            SRC_NORTH: begin
                selected_addr_valid_w = north_addr_valid_in;
                selected_data_valid_w = north_data_valid_in;
                selected_addr_w = north_addr_in;
                selected_data_w = north_data_in;
            end
            SRC_SOUTH: begin
                selected_addr_valid_w = south_addr_valid_in;
                selected_data_valid_w = south_data_valid_in;
                selected_addr_w = south_addr_in;
                selected_data_w = south_data_in;
            end
            SRC_HORIZONTAL: begin
                selected_addr_valid_w = horizontal_addr_valid_in;
                selected_data_valid_w = horizontal_data_valid_in;
                selected_addr_w = horizontal_addr_in;
                selected_data_w = horizontal_data_in;
            end
        endcase
    end

    assign local_addr_ready_out = (data_in_sel_in == SRC_LOCAL) ? addr_atomic_ready_w : {PACKET_N{1'b0}};
    assign north_addr_ready_out = (data_in_sel_in == SRC_NORTH) ? addr_atomic_ready_w : {PACKET_N{1'b0}};
    assign south_addr_ready_out = (data_in_sel_in == SRC_SOUTH) ? addr_atomic_ready_w : {PACKET_N{1'b0}};
    assign horizontal_addr_ready_out = (data_in_sel_in == SRC_HORIZONTAL) ? addr_atomic_ready_w : {PACKET_N{1'b0}};

    assign local_data_ready_out = (data_in_sel_in == SRC_LOCAL) ? data_atomic_ready_w : {PACKET_N{1'b0}};
    assign north_data_ready_out = (data_in_sel_in == SRC_NORTH) ? data_atomic_ready_w : {PACKET_N{1'b0}};
    assign south_data_ready_out = (data_in_sel_in == SRC_SOUTH) ? data_atomic_ready_w : {PACKET_N{1'b0}};
    assign horizontal_data_ready_out = (data_in_sel_in == SRC_HORIZONTAL) ? data_atomic_ready_w : {PACKET_N{1'b0}};

    assign pe_addr_valid_out = selected_addr_valid_w & pe_addr_enable_w;
    assign pe_data_valid_out = selected_data_valid_w & pe_data_enable_w;
    assign north_addr_valid_out = selected_addr_valid_w & {PACKET_N{route_north_w}} & north_addr_enable_w;
    assign north_data_valid_out = selected_data_valid_w & {PACKET_N{route_north_w}} & north_data_enable_w;
    assign south_addr_valid_out = selected_addr_valid_w & {PACKET_N{route_south_w}} & south_addr_enable_w;
    assign south_data_valid_out = selected_data_valid_w & {PACKET_N{route_south_w}} & south_data_enable_w;
    assign horizontal_addr_valid_out = selected_addr_valid_w & {PACKET_N{route_horizontal_w}} & horizontal_addr_enable_w;
    assign horizontal_data_valid_out = selected_data_valid_w & {PACKET_N{route_horizontal_w}} & horizontal_data_enable_w;

    assign pe_addr_out = selected_addr_w;
    assign north_addr_out = selected_addr_w;
    assign south_addr_out = selected_addr_w;
    assign horizontal_addr_out = selected_addr_w;
    assign pe_data_out = selected_data_w;
    assign north_data_out = selected_data_w;
    assign south_data_out = selected_data_w;
    assign horizontal_data_out = selected_data_w;

endmodule
