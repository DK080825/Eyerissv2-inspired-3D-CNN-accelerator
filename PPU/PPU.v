`timescale 1ns/1ps

// ====================================================================================================== //
// PPU
// Datapath:
//   x_bias = psum + bias
//   x_relu = max(x_bias, 0)
//   x_mul  = x_relu * M0_in
//   shift_amt = (M0_W - 1) + n_in
//   x_rq   = round_to_nearest_tie_away_from_zero(x_mul / 2^shift_amt)
//          = (x_mul + 2^(shift_amt-1)) >> shift_amt    because x_mul >= 0
//   x_zp   = x_rq + z_out
//   out    = clamp(x_zp, -128, 127)
//
// Notes:
// - ReLU is before requant, so x_mul is non-negative if M0_in is non-negative.
// - pipeline-gated: each stage only updates data regs when previous-stage valid is 1.
// ====================================================================================================== //

module PPU #(
    parameter integer PSUM_W   = 21,
    parameter integer BIAS_W   = 21,
    parameter integer ADD_W    = 22,
    parameter integer M0_W     = 32,
    parameter integer SHIFT_W  = 6
)(
    input  wire                      clock,
    input  wire                      reset,

    input  wire                      valid_in,
    input  wire signed [PSUM_W-1:0]  psum_in,
    input  wire signed [BIAS_W-1:0]  bias_in,
    input  wire        [M0_W-1:0]    M0_in,
    input  wire        [SHIFT_W-1:0] n_in,
    input  wire signed [7:0]         z_out,

    output reg                       valid_out,
    output reg  signed [7:0]         out_int8
);

// ================================================ //
//                  Localparams                      //
// ================================================ //
localparam integer FRAC_BITS   = M0_W - 1;
localparam integer MUL_W       = ADD_W + M0_W;
localparam integer RAW_W       = MUL_W + 1;

// enough to represent 0 .. (MUL_W-1)
localparam integer SHIFT_AMT_W = (MUL_W <= 2) ? 1 : $clog2(MUL_W);

// enough to represent FRAC_BITS + n_in max
localparam integer SH_FULL_W   = ((FRAC_BITS + ((1 << SHIFT_W) - 1)) <= 1) ?
                                 1 : $clog2(FRAC_BITS + (1 << SHIFT_W));

localparam [SHIFT_AMT_W-1:0] SHIFT_AMT_MAX = MUL_W - 1;

localparam signed [RAW_W-1:0] INT8_MAX_EXT = {{(RAW_W-8){1'b0}}, 8'sd127};
localparam signed [RAW_W-1:0] INT8_MIN_EXT = {{(RAW_W-8){1'b1}}, 8'sh80}; // -128

// ================================================ //
//               Stage 1 Registers                  //
// ================================================ //
reg                      valid_s1;
reg signed [ADD_W-1:0]   s1_bias_out;
reg        [M0_W-1:0]    s1_M0;
reg        [SHIFT_W-1:0] s1_n;
reg signed [7:0]         s1_z_out;

// ================================================ //
//               Stage 2 Registers                  //
// ================================================ //
reg                      valid_s2;
reg signed [ADD_W-1:0]   s2_relu_out;
reg        [M0_W-1:0]    s2_M0;
reg        [SHIFT_W-1:0] s2_n;
reg signed [7:0]         s2_z_out;

// ================================================ //
//               Stage 3 Registers                  //
// ================================================ //
reg                      valid_s3;
reg        [MUL_W-1:0]   s3_mul_out;   // non-negative
reg        [SHIFT_W-1:0] s3_n;
reg signed [7:0]         s3_z_out;

// ================================================ //
//               Stage 4 Registers                  //
// ================================================ //
reg                      valid_s4;
reg        [MUL_W-1:0]   s4_scaled_out;  // non-negative after rounding+shift
reg signed [7:0]         s4_z_out;

// ================================================ //
//        Reference-style rounding combinational    //
// ================================================ //
wire [SH_FULL_W-1:0]     sh_full;
wire [SHIFT_AMT_W-1:0]   shift_amt;
wire [MUL_W-1:0]         round_add;
wire [MUL_W-1:0]         scaled_u;
wire signed [RAW_W-1:0]  raw_result;

assign sh_full =
    FRAC_BITS + {{(SH_FULL_W-SHIFT_W){1'b0}}, s3_n};

assign shift_amt =
    (sh_full > SHIFT_AMT_MAX) ? SHIFT_AMT_MAX : sh_full[SHIFT_AMT_W-1:0];

// ReLU is before requant, so x_mul >= 0.
// Therefore only the positive branch from the reference module is needed.
assign round_add =
    (shift_amt == {SHIFT_AMT_W{1'b0}}) ? {MUL_W{1'b0}} :
                                         ({{(MUL_W-1){1'b0}}, 1'b1} << (shift_amt - 1'b1));

assign scaled_u =
    (shift_amt == {SHIFT_AMT_W{1'b0}}) ? s3_mul_out :
                                         ((s3_mul_out + round_add) >> shift_amt);

assign raw_result =
    $signed({1'b0, s4_scaled_out}) +
    $signed({{(RAW_W-8){s4_z_out[7]}}, s4_z_out});

// ================================================ //
//                  Sequential                      //
// ================================================ //
always @(posedge clock) begin
    if (reset) begin
        valid_s1      <= 1'b0;
        valid_s2      <= 1'b0;
        valid_s3      <= 1'b0;
        valid_s4      <= 1'b0;
        valid_out     <= 1'b0;

        s1_bias_out   <= {ADD_W{1'b0}};
        s1_M0         <= {M0_W{1'b0}};
        s1_n          <= {SHIFT_W{1'b0}};
        s1_z_out      <= 8'sd0;

        s2_relu_out   <= {ADD_W{1'b0}};
        s2_M0         <= {M0_W{1'b0}};
        s2_n          <= {SHIFT_W{1'b0}};
        s2_z_out      <= 8'sd0;

        s3_mul_out    <= {MUL_W{1'b0}};
        s3_n          <= {SHIFT_W{1'b0}};
        s3_z_out      <= 8'sd0;

        s4_scaled_out <= {MUL_W{1'b0}};
        s4_z_out      <= 8'sd0;

        out_int8      <= 8'sd0;
    end
    else begin
        // valid pipeline
        valid_s1  <= valid_in;
        valid_s2  <= valid_s1;
        valid_s3  <= valid_s2;
        valid_s4  <= valid_s3;
        valid_out <= valid_s4;

        // ----------------------------------------------------------------------------------------------
        // Stage 1: Bias Add
        // ----------------------------------------------------------------------------------------------
        if (valid_in) begin
            s1_bias_out <= $signed({psum_in[PSUM_W-1], psum_in}) +
                           $signed({bias_in[BIAS_W-1], bias_in});
            s1_M0    <= M0_in;
            s1_n     <= n_in;
            s1_z_out <= z_out;
        end

        // ----------------------------------------------------------------------------------------------
        // Stage 2: ReLU
        // ----------------------------------------------------------------------------------------------
        if (valid_s1) begin
            if (s1_bias_out[ADD_W-1])
                s2_relu_out <= {ADD_W{1'b0}};
            else
                s2_relu_out <= s1_bias_out;

            s2_M0    <= s1_M0;
            s2_n     <= s1_n;
            s2_z_out <= s1_z_out;
        end

        // ----------------------------------------------------------------------------------------------
        // Stage 3: Multiply
        // ----------------------------------------------------------------------------------------------
        if (valid_s2) begin
            s3_mul_out <= $unsigned(s2_relu_out) * $unsigned(s2_M0);
            s3_n       <= s2_n;
            s3_z_out   <= s2_z_out;
        end

        // ----------------------------------------------------------------------------------------------
        // Stage 4: Reference-style rounding + shift
        // ----------------------------------------------------------------------------------------------
        if (valid_s3) begin
            s4_scaled_out <= scaled_u;
            s4_z_out      <= s3_z_out;
        end

        // ----------------------------------------------------------------------------------------------
        // Stage 5: Add zero-point and clamp to signed INT8
        // ----------------------------------------------------------------------------------------------
        if (valid_s4) begin
            if (raw_result > INT8_MAX_EXT)
                out_int8 <= 8'sd127;
            else if (raw_result < INT8_MIN_EXT)
                out_int8 <= -8'sd128;
            else
                out_int8 <= raw_result[7:0];
        end
    end
end

endmodule