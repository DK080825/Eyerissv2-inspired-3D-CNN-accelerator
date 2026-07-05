// ============================================================================
// Module      : Weight_Address_Spad
// Author      : Do Quoc Khanh
// Description : Local Weight address storage inside one PE.
//               It stores CSC column boundaries for Weight data.
//               Each boundary points to a range in Weight_Data_Spad.
//               The sentinel word marks the end of one Weight load.
// ============================================================================

module Weight_Address_Spad
#(
    parameter integer SPAD_DEPTH       = 16,
    parameter integer WEIGHT_ADDR_W    = $clog2(96),
    parameter integer WEIGHT_COL_IDX_W = $clog2(SPAD_DEPTH)
)
(
    input  wire                         clk,
    input  wire                         rst,
    // Fabric -> SPAD: Weight boundary word.
    output wire                         data_in_ready,
    input  wire                         data_in_valid,
    input  wire [WEIGHT_ADDR_W-1:0]     data_in,
    // PE core -> SPAD: read one Weight column boundary pair.
    output wire [WEIGHT_ADDR_W-1:0]     col_begin,
    output wire [WEIGHT_ADDR_W-1:0]     col_end,
    input  wire [WEIGHT_COL_IDX_W-1:0]  rd_col_idx,
    // PE core -> SPAD: load control.
    input  wire                         write_en,
    output wire                         write_fin
);

// ================================================ //
//                    Parameters                    //
// ================================================ //
// Local boundary storage for Weight CSC columns.
localparam [WEIGHT_ADDR_W-1:0] WEIGHT_ADDR_SENTINEL = {WEIGHT_ADDR_W{1'b1}};
localparam integer WRITE_ADDR_W = $clog2(SPAD_DEPTH);

// ================================================ //
//                    Registers                     //
// ================================================ //
// Small PE-local storage: keep as registers.
(* ram_style = "registers", ramstyle = "logic" *)
reg [WEIGHT_ADDR_W-1:0] weight_address_spad [0:SPAD_DEPTH-1];
reg [WRITE_ADDR_W-1:0] spad_write_addr;

reg [WEIGHT_ADDR_W-1:0] col_begin_reg;
reg [WEIGHT_ADDR_W-1:0] col_end_reg;

// ================================================ //
//                      Wires                       //
// ================================================ //
wire data_in_shake;
wire [WEIGHT_COL_IDX_W:0] rd_col_idx_ext;
wire [WEIGHT_COL_IDX_W:0] rd_col_idx_p1;

// ================================================ //
//                 Basic handshake                  //
// ================================================ //
assign data_in_ready = 1'b1;
assign data_in_shake = (data_in_ready == 1'b1) && (data_in_valid == 1'b1) && (write_en == 1'b1);
assign write_fin     = (data_in == WEIGHT_ADDR_SENTINEL) && (data_in_shake == 1'b1);

assign rd_col_idx_ext = {1'b0, rd_col_idx};
assign rd_col_idx_p1  = rd_col_idx_ext + 1'b1;

assign col_begin = col_begin_reg;
assign col_end   = col_end_reg;

// ================================================ //
//                   Sequential write               //
// ================================================ //
integer i;
always @(posedge clk) begin
    if (rst) begin
        for (i = 0; i < SPAD_DEPTH; i = i + 1) begin
            weight_address_spad[i] <= WEIGHT_ADDR_SENTINEL;
        end
    end
    else if (data_in_shake) begin
        weight_address_spad[spad_write_addr] <= data_in;
    end
end

// write address
always @(posedge clk) begin
    if (rst) begin
        spad_write_addr <= 'd0;
    end
    else if (data_in_shake) begin
        if (write_fin) begin
            spad_write_addr <= 'd0;
        end
        else begin
            if (spad_write_addr < SPAD_DEPTH-1)
                spad_write_addr <= spad_write_addr + 'd1;
            else
                spad_write_addr <= 'd0;
        end
    end
end

// ================================================ //
//                 Combinational read               //
// ================================================ //
always @(*) begin
    col_begin_reg = WEIGHT_ADDR_SENTINEL;
    col_end_reg   = WEIGHT_ADDR_SENTINEL;

    if (rd_col_idx_ext < SPAD_DEPTH)
        col_begin_reg = weight_address_spad[rd_col_idx];

    if (rd_col_idx_p1 < SPAD_DEPTH)
        col_end_reg = weight_address_spad[rd_col_idx_p1[WEIGHT_COL_IDX_W-1:0]];
end

endmodule
