// ============================================================================
// Module      : Psum_Spad_2R2W
// Author      : Do Quoc Khanh
// Description : Local PSUM storage inside one PE.
//               It keeps partial sums between MAC windows.
//               The PE core can read two values and write two updated values.
//               Clear sets all stored PSUM values to zero.
//               Same-address dual writes are checked in simulation.
// ============================================================================

module Psum_Spad_2R2W #(
    parameter integer SPAD_DEPTH  = 32,
    parameter integer PSUM_ADDR_W = $clog2(SPAD_DEPTH),
    parameter integer PSUM_WIDTH  = 21
) (
    input  wire                          clk,
    input  wire                          rst,

    // PE core -> SPAD: write channel 0.
    input  wire                          wr_en0,
    input  wire [PSUM_ADDR_W-1:0]        wr_addr0,
    input  wire signed [PSUM_WIDTH-1:0]  wr_data0,

    // PE core -> SPAD: write channel 1.
    input  wire                          wr_en1,
    input  wire [PSUM_ADDR_W-1:0]        wr_addr1,
    input  wire signed [PSUM_WIDTH-1:0]  wr_data1,

    // SPAD -> PE core: read channel 0.
    input  wire                          rd_en0,
    input  wire [PSUM_ADDR_W-1:0]        rd_addr0,
    output wire signed [PSUM_WIDTH-1:0]  rd_data0,

    // SPAD -> PE core: read channel 1.
    input  wire                          rd_en1,
    input  wire [PSUM_ADDR_W-1:0]        rd_addr1,
    output wire signed [PSUM_WIDTH-1:0]  rd_data1,

    // PE core -> SPAD: clear all PSUM values.
    input  wire                          psum_spad_clear
);

(* ram_style = "registers" *) reg signed [PSUM_WIDTH-1:0] mem_r0 [0:SPAD_DEPTH-1];

integer i;
initial begin
    for (i = 0; i < SPAD_DEPTH; i = i + 1)
        mem_r0[i] = {PSUM_WIDTH{1'b0}};
end

assign rd_data0 = rd_en0 ? mem_r0[rd_addr0] : {PSUM_WIDTH{1'b0}};
assign rd_data1 = rd_en1 ? mem_r0[rd_addr1] : {PSUM_WIDTH{1'b0}};

always @(posedge clk) begin
    if (rst) begin
        for (i = 0; i < SPAD_DEPTH; i = i + 1)
            mem_r0[i] <= {PSUM_WIDTH{1'b0}};
    end else begin
        if (psum_spad_clear) begin
            for (i = 0; i < SPAD_DEPTH; i = i + 1)
                mem_r0[i] <= {PSUM_WIDTH{1'b0}};
        end else begin
            if (wr_en0) begin
                mem_r0[wr_addr0] <= wr_data0;
            end

            if (wr_en1) begin
                mem_r0[wr_addr1] <= wr_data1;
            end
        end
    end
end


endmodule
