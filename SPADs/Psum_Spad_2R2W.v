// ============================================================================
// Module      : Psum_Spad_2R2W
// Author      : Do Quoc Khanh
// Description : Register-style PSUM SPAD with two logical read/write ports.
//               Uses valid-bit clear so reset/clear does not fan out through
//               every stored PSUM data bit. Reads of invalid entries return 0.
//               The PE core owns the phase-exclusive read/write contract.
//               This keeps PE-visible behavior unchanged while reducing logic.
// ============================================================================

module Psum_Spad_2R2W #(
    parameter integer SPAD_DEPTH  = 32,
    parameter integer PSUM_ADDR_W = $clog2(SPAD_DEPTH),
    parameter integer PSUM_WIDTH  = 21
) (
    input  wire                          clk,
    input  wire                          rst,

    // ---------------- Write channel 0 ----------------
    input  wire                          wr_en0,
    input  wire [PSUM_ADDR_W-1:0]        wr_addr0,
    input  wire signed [PSUM_WIDTH-1:0]  wr_data0,

    // ---------------- Write channel 1 ----------------
    input  wire                          wr_en1,
    input  wire [PSUM_ADDR_W-1:0]        wr_addr1,
    input  wire signed [PSUM_WIDTH-1:0]  wr_data1,

    // ---------------- Read channel 0 -----------------
    input  wire                          rd_en0,
    input  wire [PSUM_ADDR_W-1:0]        rd_addr0,
    output reg signed [PSUM_WIDTH-1:0]   rd_data0,

    // ---------------- Read channel 1 -----------------
    input  wire                          rd_en1,
    input  wire [PSUM_ADDR_W-1:0]        rd_addr1,
    output reg signed [PSUM_WIDTH-1:0]   rd_data1,

    // ---------------- Control ------------------------
    input  wire                          psum_spad_clear
);

(* ram_style = "registers" *) reg signed [PSUM_WIDTH-1:0] mem_r0 [0:SPAD_DEPTH-1];
reg [SPAD_DEPTH-1:0] valid_r;

integer i;
initial begin
    for (i = 0; i < SPAD_DEPTH; i = i + 1)
        mem_r0[i] = {PSUM_WIDTH{1'b0}};
    valid_r = {SPAD_DEPTH{1'b0}};
end

always @(*) begin
    rd_data0 = {PSUM_WIDTH{1'b0}};
    rd_data1 = {PSUM_WIDTH{1'b0}};
    if ((rst == 1'b0) && (psum_spad_clear == 1'b0)) begin
        if (rd_en0 && valid_r[rd_addr0])
            rd_data0 = mem_r0[rd_addr0];

        if (rd_en1 && valid_r[rd_addr1])
            rd_data1 = mem_r0[rd_addr1];
    end
end

always @(posedge clk) begin
    if (rst) begin
        valid_r <= {SPAD_DEPTH{1'b0}};
    end else begin
        if (psum_spad_clear) begin
            valid_r <= {SPAD_DEPTH{1'b0}};
        end else begin
            if (wr_en0) begin
                mem_r0[wr_addr0] <= wr_data0;
                valid_r[wr_addr0] <= 1'b1;
            end

            if (wr_en1) begin
                mem_r0[wr_addr1] <= wr_data1;
                valid_r[wr_addr1] <= 1'b1;
            end
        end
    end
end

`ifndef SYNTHESIS
always @(posedge clk) begin
    if (!rst && !psum_spad_clear) begin
        if ((rd_en0 || rd_en1) && (wr_en0 || wr_en1)) begin
            $fatal(1,
                "[PSUM_SPAD_2R2W][CONTRACT_FAIL] read/write overlap is outside the PE phase-exclusive contract");
        end
        if (wr_en0 && wr_en1 && (wr_addr0 == wr_addr1)) begin
            $fatal(1,
                "[PSUM_SPAD_2R2W][CONTRACT_FAIL] same-address dual write addr=%0d",
                wr_addr0);
        end
    end
end
`endif

endmodule
