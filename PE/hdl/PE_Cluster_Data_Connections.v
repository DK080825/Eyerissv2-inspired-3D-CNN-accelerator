// ====================================================================================================== //
// Packed-bus row-wise iact broadcast for a 4x4 PE cluster.
// Router lane r broadcasts its address/data stream to every PE in row r.
// ====================================================================================================== //

module PE_Cluster_Connection (
    input       [3:0]   iact_from_router_addr_valid,
    input       [31:0]  iact_from_router_addr_bits,
    input       [3:0]   iact_from_router_data_valid,
    input       [51:0]  iact_from_router_data_bits,

    output      [15:0]  iact_to_pe_addr_valid,
    output      [127:0] iact_to_pe_addr_bits,
    output      [15:0]  iact_to_pe_data_valid,
    output      [207:0] iact_to_pe_data_bits
);

localparam integer ROWS   = 4;
localparam integer COLS   = 4;
localparam integer ADDR_W = 8;
localparam integer DATA_W = 13;

genvar row_idx;
genvar col_idx;
generate
    for (row_idx = 0; row_idx < ROWS; row_idx = row_idx + 1) begin : gen_rows
        for (col_idx = 0; col_idx < COLS; col_idx = col_idx + 1) begin : gen_cols
            localparam integer PE_IDX = (row_idx * COLS) + col_idx;

            assign iact_to_pe_addr_valid[PE_IDX] = iact_from_router_addr_valid[row_idx];
            assign iact_to_pe_data_valid[PE_IDX] = iact_from_router_data_valid[row_idx];

            assign iact_to_pe_addr_bits[(PE_IDX*ADDR_W) +: ADDR_W] =
                iact_from_router_addr_bits[(row_idx*ADDR_W) +: ADDR_W];
            assign iact_to_pe_data_bits[(PE_IDX*DATA_W) +: DATA_W] =
                iact_from_router_data_bits[(row_idx*DATA_W) +: DATA_W];
        end
    end
endgenerate

endmodule