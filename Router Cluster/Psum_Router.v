`timescale 1ns/1ps

// ============================================================================
// Module      : Psum_Router
// Author      : Do Quoc Khanh
// Description : Circuit-switched router for one PSUM column lane.
//               Forwards PSUM seeds from local GLB or north neighbor toward
//               the local PE/south path, and returns PE-produced PSUMs to the
//               local GLB-facing output path.
// ============================================================================
module Psum_Router #(
    parameter integer DATA_W = 42
) (
    input  wire                    data_in_sel_in,    // 0: north, 1: local GLB
    input  wire                    route_to_pe_in,   // 0: south, 1: local PE

    input  wire                    pe_return_valid_in,
    output wire                    pe_return_ready_out,
    input  wire signed [DATA_W-1:0] pe_return_data_in,
    output wire                    local_return_valid_out,
    input  wire                    local_return_ready_in,
    output wire signed [DATA_W-1:0] local_return_data_out,

    input  wire                    local_forward_valid_in,
    output wire                    local_forward_ready_out,
    input  wire signed [DATA_W-1:0] local_forward_data_in,
    input  wire                    north_forward_valid_in,
    output wire                    north_forward_ready_out,
    input  wire signed [DATA_W-1:0] north_forward_data_in,

    output wire                    pe_forward_valid_out,
    input  wire                    pe_forward_ready_in,
    output wire signed [DATA_W-1:0] pe_forward_data_out,
    output wire                    south_forward_valid_out,
    input  wire                    south_forward_ready_in,
    output wire signed [DATA_W-1:0] south_forward_data_out
);

    wire selected_valid_w = data_in_sel_in ? local_forward_valid_in : north_forward_valid_in;
    wire signed [DATA_W-1:0] selected_data_w =
        data_in_sel_in ? local_forward_data_in : north_forward_data_in;
    wire selected_ready_w = route_to_pe_in ? pe_forward_ready_in : south_forward_ready_in;

    assign local_forward_ready_out = data_in_sel_in & selected_ready_w;
    assign north_forward_ready_out = ~data_in_sel_in & selected_ready_w;
    assign pe_forward_valid_out = selected_valid_w & route_to_pe_in;
    assign south_forward_valid_out = selected_valid_w & ~route_to_pe_in;
    assign pe_forward_data_out = selected_data_w;
    assign south_forward_data_out = selected_data_w;

    assign pe_return_ready_out = local_return_ready_in;
    assign local_return_valid_out = pe_return_valid_in;
    assign local_return_data_out = pe_return_data_in;

endmodule
