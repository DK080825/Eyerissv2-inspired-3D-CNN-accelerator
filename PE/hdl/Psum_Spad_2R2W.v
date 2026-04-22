// ====================================================================================================== //
// Psum_Spad
// - True 2R + 2W with the SAME interface
// - Read is ASYNCHRONOUS
// - Immediate clear on reset or psum_spad_clear
// - If wr_en0 and wr_en1 write the same address in the same cycle, port1 wins
// - Same-cycle read/write same-address bypass is supported for both read ports
// ====================================================================================================== //

module Psum_Spad_2R2W (
    input                       clock,
    input                       reset,

    // ---------------- Write channel 0 ----------------
    input                       wr_en0,
    input         [4:0]         wr_addr0,
    input  signed [20:0]        wr_data0,

    // ---------------- Write channel 1 ----------------
    input                       wr_en1,
    input         [4:0]         wr_addr1,
    input  signed [20:0]        wr_data1,

    // ---------------- Read channel 0 -----------------
    input                       rd_en0,
    input         [4:0]         rd_addr0,
    output reg signed [20:0]    rd_data0,

    // ---------------- Read channel 1 -----------------
    input                       rd_en1,
    input         [4:0]         rd_addr1,
    output reg signed [20:0]    rd_data1,

    // ---------------- Control ------------------------
    input                       psum_spad_clear
);

// ================================================ //
//                    Parameters                    //
// ================================================ //
localparam SPAD_DEPTH = 32;
localparam SPAD_WIDTH = 21;

// ================================================ //
//                 Internal signals                 //
// ================================================ //

// Two replicated memories:
// - mem_r0 serves read port 0
// - mem_r1 serves read port 1
// Both memories receive the same writes.
(* ram_style = "registers" *) reg signed [SPAD_WIDTH-1:0] mem_r0 [0:SPAD_DEPTH-1];
(* ram_style = "registers" *) reg signed [SPAD_WIDTH-1:0] mem_r1 [0:SPAD_DEPTH-1];

integer i;
initial begin
    for (i = 0; i < SPAD_DEPTH; i = i + 1) begin
        mem_r0[i] = {SPAD_WIDTH{1'b0}};
        mem_r1[i] = {SPAD_WIDTH{1'b0}};
    end
end

// ================================================ //
//             Effective read / write req           //
// ================================================ //
wire same_addr_write_conflict;
wire wr0_eff;
wire wr1_eff;

// if both writes hit same address: port1 wins
assign same_addr_write_conflict = wr_en0 & wr_en1 & (wr_addr0 == wr_addr1);

assign wr1_eff = wr_en1;
assign wr0_eff = wr_en0 & (~same_addr_write_conflict);

// ================================================ //
//               ASYNCHRONOUS READ PATH             //
// ================================================ //
// Priority for same-cycle bypass:
//   1) wr1 (higher priority)
//   2) wr0
//   3) stored memory value
always @(*) begin
    rd_data0 = 21'sd0;
    rd_data1 = 21'sd0;

    if (!reset && !psum_spad_clear) begin
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

// ================================================ //
//                 Main sequential logic            //
// ================================================ //
    integer i1;
always @(posedge clock) begin
    if (reset) begin
        for (i1 = 0; i1 < SPAD_DEPTH; i1 = i1 + 1) begin
            mem_r0[i1] <= {SPAD_WIDTH{1'b0}};
            mem_r1[i1] <= {SPAD_WIDTH{1'b0}};
        end
    end
    else begin
        // -----------------------------------------------------------------
        // 1) Clear control
        // -----------------------------------------------------------------
        if (psum_spad_clear) begin
            for (i1 = 0; i1 < SPAD_DEPTH; i1 = i1 + 1) begin
                mem_r0[i1] <= {SPAD_WIDTH{1'b0}};
                mem_r1[i1] <= {SPAD_WIDTH{1'b0}};
            end
        end
        else begin
            // -------------------------------------------------------------
            // 2) True 2W update: both writes can happen in the same cycle
            // -------------------------------------------------------------
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