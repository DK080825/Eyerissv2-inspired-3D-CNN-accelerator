// ====================================================================================================== //
// Psum_Spad
// - True 2R + 2W with the SAME interface
// - Read is ASYNCHRONOUS
// - Immediate clear on reset or psum_spad_clear
// - If wr_en0 and wr_en1 write the same address in the same cycle, port1 wins
// - Same-cycle read/write same-address bypass is supported for both read ports
// ====================================================================================================== //

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
(* ram_style = "registers" *) reg signed [PSUM_WIDTH-1:0] mem_r1 [0:SPAD_DEPTH-1];

integer i;
initial begin
    for (i = 0; i < SPAD_DEPTH; i = i + 1) begin
        mem_r0[i] = {PSUM_WIDTH{1'b0}};
        mem_r1[i] = {PSUM_WIDTH{1'b0}};
    end
end

wire same_addr_write_conflict;
wire wr0_eff;
wire wr1_eff;

assign same_addr_write_conflict = (wr_en0 == 1'b1) && (wr_en1 == 1'b1) && (wr_addr0 == wr_addr1);

assign wr1_eff = wr_en1;
assign wr0_eff = (wr_en0 == 1'b1) && (same_addr_write_conflict == 1'b0);

always @(*) begin
    rd_data0 = {PSUM_WIDTH{1'b0}};
    rd_data1 = {PSUM_WIDTH{1'b0}};
    if ((rst == 1'b0) && (psum_spad_clear == 1'b0)) begin
        if (rd_en0) begin
            if (wr1_eff && (wr_addr1 == rd_addr0))
                rd_data0 = wr_data1;
            else if (wr0_eff && (wr_addr0 == rd_addr0))
                rd_data0 = wr_data0;
            else
                rd_data0 = mem_r0[rd_addr0];
        end

        if (rd_en1) begin
            if (wr1_eff && (wr_addr1 == rd_addr1))
                rd_data1 = wr_data1;
            else if (wr0_eff && (wr_addr0 == rd_addr1))
                rd_data1 = wr_data0;
            else
                rd_data1 = mem_r1[rd_addr1];
        end
    end
end

integer i1;
always @(posedge clk) begin
    if (rst) begin
        for (i1 = 0; i1 < SPAD_DEPTH; i1 = i1 + 1) begin
            mem_r0[i1] <= {PSUM_WIDTH{1'b0}};
            mem_r1[i1] <= {PSUM_WIDTH{1'b0}};
        end
    end else begin
        if (psum_spad_clear) begin
            for (i1 = 0; i1 < SPAD_DEPTH; i1 = i1 + 1) begin
                mem_r0[i1] <= {PSUM_WIDTH{1'b0}};
                mem_r1[i1] <= {PSUM_WIDTH{1'b0}};
            end
        end else begin
            if (wr0_eff) begin
                mem_r0[wr_addr0] <= wr_data0;
                mem_r1[wr_addr0] <= wr_data0;
            end

            if (wr1_eff) begin
                mem_r0[wr_addr1] <= wr_data1;
                mem_r1[wr_addr1] <= wr_data1;
            end
        end
    end
end

endmodule
