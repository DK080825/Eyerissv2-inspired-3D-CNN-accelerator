// ====================================================================================================== //
// Packed-bus PE_Cluster_controller for a 4x4 PE cluster.
// - 4 router lanes on the input side
// - 16 PE destinations on the output side
// - Optional broadcast of one selected router onto all 4 router lanes
// ====================================================================================================== //

module PE_Cluster_controller (
    input               iact_data_in_sel,
    input       [1:0]   iact_data_out_sel,

    output      [3:0]   iact_addr_in_ready,
    input       [3:0]   iact_addr_in_valid,
    input       [31:0]  iact_addr_in_bits,

    output      [3:0]   iact_data_in_ready,
    input       [3:0]   iact_data_in_valid,
    input       [51:0]  iact_data_in_bits,

    output      [15:0]  iact_to_pe_addr_valid,
    output      [127:0] iact_to_pe_addr_bits,
    output      [15:0]  iact_to_pe_data_valid,
    output      [207:0] iact_to_pe_data_bits
);

localparam integer ROUTER_COUNT = 4;
localparam integer PE_COUNT     = 16;
localparam integer ADDR_W       = 8;
localparam integer DATA_W       = 13;
localparam BROADCAST            = 1'b1;

wire                     sel_addr_valid_w;
wire                     sel_data_valid_w;
wire [ADDR_W-1:0]        sel_addr_bits_w;
wire [DATA_W-1:0]        sel_data_bits_w;
wire [ROUTER_COUNT-1:0]  conn_router_addr_valid_w;
wire [ROUTER_COUNT-1:0]  conn_router_data_valid_w;
wire [ROUTER_COUNT*ADDR_W-1:0] conn_router_addr_bits_w;
wire [ROUTER_COUNT*DATA_W-1:0] conn_router_data_bits_w;

assign sel_addr_valid_w = iact_addr_in_valid[iact_data_out_sel];
assign sel_data_valid_w = iact_data_in_valid[iact_data_out_sel];
assign sel_addr_bits_w  = iact_addr_in_bits[(iact_data_out_sel*ADDR_W) +: ADDR_W];
assign sel_data_bits_w  = iact_data_in_bits[(iact_data_out_sel*DATA_W) +: DATA_W];

genvar router_idx;
generate
    for (router_idx = 0; router_idx < ROUTER_COUNT; router_idx = router_idx + 1) begin : gen_router_lanes
        assign iact_addr_in_ready[router_idx] = (iact_data_in_sel == BROADCAST) ? (iact_data_out_sel == router_idx[1:0]) : 1'b1;
        assign iact_data_in_ready[router_idx] = (iact_data_in_sel == BROADCAST) ? (iact_data_out_sel == router_idx[1:0]) : 1'b1;

        assign conn_router_addr_valid_w[router_idx] = (iact_data_in_sel == BROADCAST)
            ? sel_addr_valid_w
            : iact_addr_in_valid[router_idx];
        assign conn_router_data_valid_w[router_idx] = (iact_data_in_sel == BROADCAST)
            ? sel_data_valid_w
            : iact_data_in_valid[router_idx];

        assign conn_router_addr_bits_w[(router_idx*ADDR_W) +: ADDR_W] = (iact_data_in_sel == BROADCAST)
            ? sel_addr_bits_w
            : iact_addr_in_bits[(router_idx*ADDR_W) +: ADDR_W];
        assign conn_router_data_bits_w[(router_idx*DATA_W) +: DATA_W] = (iact_data_in_sel == BROADCAST)
            ? sel_data_bits_w
            : iact_data_in_bits[(router_idx*DATA_W) +: DATA_W];
    end
endgenerate

PE_Cluster_Connection PE_Cluster_Connection_inst (
    .iact_from_router_addr_valid(conn_router_addr_valid_w),
    .iact_from_router_addr_bits (conn_router_addr_bits_w),
    .iact_from_router_data_valid(conn_router_data_valid_w),
    .iact_from_router_data_bits (conn_router_data_bits_w),
    .iact_to_pe_addr_valid      (iact_to_pe_addr_valid),
    .iact_to_pe_addr_bits       (iact_to_pe_addr_bits),
    .iact_to_pe_data_valid      (iact_to_pe_data_valid),
    .iact_to_pe_data_bits       (iact_to_pe_data_bits)
);

endmodule