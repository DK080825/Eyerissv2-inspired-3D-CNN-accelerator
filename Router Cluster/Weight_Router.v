`timescale 1ns/1ps

// ============================================================================
// Module      : Weight_Router
// Author      : Do Quoc Khanh
// Description : Router for one Weight row lane.
//               It chooses Weight data from the local cluster or horizontal neighbor.
//               It sends the selected data to the PE row and optionally onward.
//               It does not decide which PE row uses the Weight data.
// ============================================================================
module Weight_Router #(
    parameter integer ADDR_W = 7,
    parameter integer DATA_W = 24
) (
    // Config -> router: input source and optional horizontal output.
    input  wire                 data_in_sel_in,  // 0: local, 1: horizontal neighbor
    input  wire                 route_horizontal_in,

    // Local cluster -> router.
    input  wire                 local_addr_valid_in,
    output wire                 local_addr_ready_out,
    input  wire [ADDR_W-1:0]    local_addr_in,
    input  wire                 local_data_valid_in,
    output wire                 local_data_ready_out,
    input  wire [DATA_W-1:0]    local_data_in,

    // Horizontal neighbor -> router.
    input  wire                 horizontal_addr_valid_in,
    output wire                 horizontal_addr_ready_out,
    input  wire [ADDR_W-1:0]    horizontal_addr_in,
    input  wire                 horizontal_data_valid_in,
    output wire                 horizontal_data_ready_out,
    input  wire [DATA_W-1:0]    horizontal_data_in,

    // Router -> local PE row.
    output wire                 pe_addr_valid_out,
    input  wire                 pe_addr_ready_in,
    output wire [ADDR_W-1:0]    pe_addr_out,
    output wire                 pe_data_valid_out,
    input  wire                 pe_data_ready_in,
    output wire [DATA_W-1:0]    pe_data_out,

    // Router -> horizontal neighbor.
    output wire                 horizontal_addr_valid_out,
    input  wire                 horizontal_addr_ready_in,
    output wire [ADDR_W-1:0]    horizontal_addr_out,
    output wire                 horizontal_data_valid_out,
    input  wire                 horizontal_data_ready_in,
    output wire [DATA_W-1:0]    horizontal_data_out
);

    wire selected_addr_valid_w = data_in_sel_in ? horizontal_addr_valid_in : local_addr_valid_in;
    wire selected_data_valid_w = data_in_sel_in ? horizontal_data_valid_in : local_data_valid_in;
    wire [ADDR_W-1:0] selected_addr_w = data_in_sel_in ? horizontal_addr_in : local_addr_in;
    wire [DATA_W-1:0] selected_data_w = data_in_sel_in ? horizontal_data_in : local_data_in;

    wire addr_atomic_ready_w = pe_addr_ready_in &
        (~route_horizontal_in | horizontal_addr_ready_in);
    wire data_atomic_ready_w = pe_data_ready_in &
        (~route_horizontal_in | horizontal_data_ready_in);

    assign local_addr_ready_out = ~data_in_sel_in & addr_atomic_ready_w;
    assign local_data_ready_out = ~data_in_sel_in & data_atomic_ready_w;
    assign horizontal_addr_ready_out = data_in_sel_in & addr_atomic_ready_w;
    assign horizontal_data_ready_out = data_in_sel_in & data_atomic_ready_w;

    assign pe_addr_valid_out = selected_addr_valid_w &
        (~route_horizontal_in | horizontal_addr_ready_in);
    assign pe_data_valid_out = selected_data_valid_w &
        (~route_horizontal_in | horizontal_data_ready_in);
    assign horizontal_addr_valid_out = selected_addr_valid_w &
        route_horizontal_in & pe_addr_ready_in;
    assign horizontal_data_valid_out = selected_data_valid_w &
        route_horizontal_in & pe_data_ready_in;

    assign pe_addr_out = selected_addr_w;
    assign horizontal_addr_out = selected_addr_w;
    assign pe_data_out = selected_data_w;
    assign horizontal_data_out = selected_data_w;

endmodule
