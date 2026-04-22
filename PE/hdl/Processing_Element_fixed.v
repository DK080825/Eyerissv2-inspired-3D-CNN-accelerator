// ====================================================================================================== //
// This module is the Top-level of PE.
// PE module contains the FIFOs of all data types and the core PE_Pad.
// The control signals write_fin are used to control the data in from upper level module,
// which is used to determine whether the data should be reuse.
// ====================================================================================================== //

module Processing_Element (
    input                       clock,
    input                       reset,

    // =========================================================================================
    // data signals
    // =========================================================================================
    output                      psum_in_ready,
    input                       psum_in_valid,
    input   signed [20:0]       psum_in,
    input                       psum_out_ready,
    output                      psum_out_valid,
    output  signed [20:0]       psum_out,

    output                      iact_address_in_ready,
    input                       iact_address_in_valid,
    input       [7:0]           iact_address_in,

    output                      iact_data_in_ready,
    input                       iact_data_in_valid,
    input       [12:0]          iact_data_in,

    output                      weight_address_in_ready,
    input                       weight_address_in_valid,
    input       [6:0]           weight_address_in,

    output                      weight_data_in_ready,
    input                       weight_data_in_valid,
    input       [23:0]          weight_data_in,

    // =========================================================================================
    // control signals
    // =========================================================================================
    output                      iact_address_write_fin,
    output                      iact_data_write_fin,
    output                      weight_address_write_fin,
    output                      weight_data_write_fin,
    output                      psum_add_fin,

    input                       psum_enq_en,
    input                       do_load_en,
    output                      cal_fin,

    input                       iact_write_fin_clear,
    input                       weight_write_fin_clear,
    output                      all_write_fin,

    input       [4:0]           PSUM_DEPTH,
    input                       psum_spad_clear,

    // Streaming max-pool compare (see Processing_Element_core_pipeline)
    input                       pool_cmp_en,
    input                       pool_cmp_stop,
    input                       pool_elem_in_valid,
    output                      pool_elem_in_ready,
    input   signed [7:0]        pool_elem_in,
    input                       pool_win_first,
    input                       pool_win_last,
    output                      pool_out_valid,
    input                       pool_out_ready,
    output  signed [7:0]        pool_out
);

//
// ==================================================================== //
//                              Parameters                              //
// ==================================================================== //
//
parameter IACT_ADDR_DATA_WIDTH   = 8;    // iact address width
parameter IACT_DATA_DATA_WIDTH   = 13;   // iact data = 8-bit value + 5-bit count
parameter WEIGHT_ADDR_DATA_WIDTH = 7;    // weight address width
parameter WEIGHT_DATA_DATA_WIDTH = 24;   // packed 2-lane weight word

//
// ==================================================================== //
//                              Wires                                   //
// ==================================================================== //
//

// ------------------------------------
// PE ctrl module
// ------------------------------------
// signal to controller
wire                PE_ctrl_fromTop_psum_acc_fin;
//
wire                PE_ctrl_do_mac_en;
wire                PE_ctrl_fromTop_psum_enq_en;
wire                PE_ctrl_fromTop_do_load_en;
wire                PE_ctrl_fromTop_cal_fin;
wire                PE_ctrl_Top_psum_enq_en;
wire                PE_ctrl_Top_do_load_en;
wire                PE_ctrl_Top_cal_fin;
wire                PE_ctrl_Top_write_fin;

// ------------------------------------
// PE core module
// ------------------------------------
wire                PE_pad_do_mac_en;
wire                PE_pad_psum_enq_en;
wire                PE_pad_do_load_en;
wire                PE_pad_cal_fin;

wire                PE_pad_psum_in_ready;
wire                PE_pad_psum_in_valid;
wire signed [20:0]  PE_pad_psum_in;

wire                PE_pad_psum_out_ready;
wire                PE_pad_psum_out_valid;
wire signed [20:0]  PE_pad_psum_out;

wire                PE_pad_iact_address_in_valid;
wire        [7:0]   PE_pad_iact_address_in;
wire                PE_pad_iact_data_in_valid;
wire        [12:0]  PE_pad_iact_data_in;

wire                PE_pad_weight_address_in_valid;
wire        [6:0]   PE_pad_weight_address_in;
wire                PE_pad_weight_data_in_valid;
wire        [23:0]  PE_pad_weight_data_in;

wire                PE_pad_iact_address_write_fin;
wire                PE_pad_iact_data_write_fin;
wire                PE_pad_weight_address_write_fin;
wire                PE_pad_weight_data_write_fin;
wire                PE_pad_psum_add_fin;

// ------------------------------------
// FIFO - iact address
// ------------------------------------
wire                FIFO_iact_address_in_ready;
wire                FIFO_iact_address_in_valid;
wire        [7:0]   FIFO_iact_address_in;
wire                FIFO_iact_address_out_ready;
wire                FIFO_iact_address_out_valid;
wire        [7:0]   FIFO_iact_address_out;

// ------------------------------------
// FIFO - iact data
// ------------------------------------
wire                FIFO_iact_data_in_ready;
wire                FIFO_iact_data_in_valid;
wire        [12:0]  FIFO_iact_data_in;
wire                FIFO_iact_data_out_ready;
wire                FIFO_iact_data_out_valid;
wire        [12:0]  FIFO_iact_data_out;

// ------------------------------------
// FIFO - weight address
// ------------------------------------
wire                FIFO_weight_address_in_ready;
wire                FIFO_weight_address_in_valid;
wire        [6:0]   FIFO_weight_address_in;
wire                FIFO_weight_address_out_ready;
wire                FIFO_weight_address_out_valid;
wire        [6:0]   FIFO_weight_address_out;

// ------------------------------------
// FIFO - weight data
// ------------------------------------
wire                FIFO_weight_data_in_ready;
wire                FIFO_weight_data_in_valid;
wire        [23:0]  FIFO_weight_data_in;
wire                FIFO_weight_data_out_ready;
wire                FIFO_weight_data_out_valid;
wire        [23:0]  FIFO_weight_data_out;

// ------------------------------------
// FIFO - psum in
// ------------------------------------
wire                FIFO_in_psum_in_ready;
wire                FIFO_in_psum_in_valid;
wire signed [20:0]  FIFO_in_psum_in;
wire                FIFO_in_psum_out_ready;
wire                FIFO_in_psum_out_valid;
wire signed [20:0]  FIFO_in_psum_out;

// ------------------------------------
// FIFO - psum out
// ------------------------------------
wire                FIFO_out_psum_in_ready;
wire                FIFO_out_psum_in_valid;
wire signed [20:0]  FIFO_out_psum_in;
wire                FIFO_out_psum_out_ready;
wire                FIFO_out_psum_out_valid;
wire signed [20:0]  FIFO_out_psum_out;

//
// ==================================================================== //
//                              Registers                               //
// ==================================================================== //
//
reg iact_addr_write_fin_reg;
reg iact_data_write_fin_reg;
reg weight_addr_write_fin_reg;
reg weight_data_write_fin_reg;

//
// ==================================================================== //
//                              Instantiation                           //
// ==================================================================== //
//

// ------------------------------------
// PE controller
// ------------------------------------
Processing_Element_Controller Processing_Element_Controller_inst (
    .clock                  (clock),
    .reset                  (reset),
    .mac_en                 (PE_ctrl_do_mac_en),
    .from_top_psum_enq_en   (PE_ctrl_fromTop_psum_enq_en),
    .from_top_do_load_en    (PE_ctrl_fromTop_do_load_en),
    .from_top_cal_fin       (PE_ctrl_fromTop_cal_fin),
    .from_top_psum_acc_fin  (PE_ctrl_fromTop_psum_acc_fin), // NEW
    .top_psum_enq_en        (PE_ctrl_Top_psum_enq_en),
    .top_do_load_en         (PE_ctrl_Top_do_load_en),
    .top_cal_fin            (PE_ctrl_Top_cal_fin),
    .top_write_fin          (PE_ctrl_Top_write_fin)
);

// ------------------------------------
// PE core
// ------------------------------------
Processing_Element_core_pipeline Processing_Element_core_inst (
    .clock                      (clock),
    .reset                      (reset),
    .mac_en                     (PE_pad_do_mac_en),
    .psum_enq_en                (PE_pad_psum_enq_en),
    .load_en                    (PE_pad_do_load_en),
    .cal_fin                    (PE_pad_cal_fin),

    .psum_in_ready              (PE_pad_psum_in_ready),
    .psum_in_valid              (PE_pad_psum_in_valid),
    .psum_in                    (PE_pad_psum_in),

    .psum_out_ready             (PE_pad_psum_out_ready),
    .psum_out_valid             (PE_pad_psum_out_valid),
    .psum_out                   (PE_pad_psum_out),

    .iact_address_in_valid      (PE_pad_iact_address_in_valid),
    .iact_address_in            (PE_pad_iact_address_in),
    .iact_data_in_valid         (PE_pad_iact_data_in_valid),
    .iact_data_in               (PE_pad_iact_data_in),

    .weight_address_in_valid    (PE_pad_weight_address_in_valid),
    .weight_address_in          (PE_pad_weight_address_in),
    .weight_data_in_valid       (PE_pad_weight_data_in_valid),
    .weight_data_in             (PE_pad_weight_data_in),

    .iact_address_write_fin     (PE_pad_iact_address_write_fin),
    .iact_data_write_fin        (PE_pad_iact_data_write_fin),
    .weight_address_write_fin   (PE_pad_weight_address_write_fin),
    .weight_data_write_fin      (PE_pad_weight_data_write_fin),
    .psum_acc_fin               (PE_pad_psum_add_fin),

    .PSUM_DEPTH                 (PSUM_DEPTH),
    .psum_spad_clear            (psum_spad_clear),

    .pool_cmp_en                (pool_cmp_en),
    .pool_cmp_stop              (pool_cmp_stop),
    .pool_elem_in_valid         (pool_elem_in_valid),
    .pool_elem_in_ready         (pool_elem_in_ready),
    .pool_elem_in               (pool_elem_in),
    .pool_win_first             (pool_win_first),
    .pool_win_last              (pool_win_last),
    .pool_out_valid             (pool_out_valid),
    .pool_out_ready             (pool_out_ready),
    .pool_out                   (pool_out)
);

// ------------------------------------
// FIFO for iact address
// ------------------------------------
PE_data_FIFO #(
    .DATA_IN_WIDTH(IACT_ADDR_DATA_WIDTH)
) iact_addr_FIFO (
    .clock          (clock),
    .reset          (reset),
    .data_in_ready  (FIFO_iact_address_in_ready),
    .data_in_valid  (FIFO_iact_address_in_valid),
    .data_in        (FIFO_iact_address_in),
    .data_out_ready (FIFO_iact_address_out_ready),
    .data_out_valid (FIFO_iact_address_out_valid),
    .data_out       (FIFO_iact_address_out)
);

// ------------------------------------
// FIFO for iact data
// ------------------------------------
PE_data_FIFO #(
    .DATA_IN_WIDTH(IACT_DATA_DATA_WIDTH)
) iact_data_FIFO (
    .clock          (clock),
    .reset          (reset),
    .data_in_ready  (FIFO_iact_data_in_ready),
    .data_in_valid  (FIFO_iact_data_in_valid),
    .data_in        (FIFO_iact_data_in),
    .data_out_ready (FIFO_iact_data_out_ready),
    .data_out_valid (FIFO_iact_data_out_valid),
    .data_out       (FIFO_iact_data_out)
);

// ------------------------------------
// FIFO for weight address
// ------------------------------------
PE_data_FIFO #(
    .DATA_IN_WIDTH(WEIGHT_ADDR_DATA_WIDTH)
) weight_addr_FIFO (
    .clock          (clock),
    .reset          (reset),
    .data_in_ready  (FIFO_weight_address_in_ready),
    .data_in_valid  (FIFO_weight_address_in_valid),
    .data_in        (FIFO_weight_address_in),
    .data_out_ready (FIFO_weight_address_out_ready),
    .data_out_valid (FIFO_weight_address_out_valid),
    .data_out       (FIFO_weight_address_out)
);

// ------------------------------------
// FIFO for weight data
// ------------------------------------
PE_data_FIFO #(
    .DATA_IN_WIDTH(WEIGHT_DATA_DATA_WIDTH)
) weight_data_FIFO (
    .clock          (clock),
    .reset          (reset),
    .data_in_ready  (FIFO_weight_data_in_ready),
    .data_in_valid  (FIFO_weight_data_in_valid),
    .data_in        (FIFO_weight_data_in),
    .data_out_ready (FIFO_weight_data_out_ready),
    .data_out_valid (FIFO_weight_data_out_valid),
    .data_out       (FIFO_weight_data_out)
);

// ------------------------------------
// FIFO for psum in
// ------------------------------------
PE_psum_FIFO psum_in_FIFO (
    .clock          (clock),
    .reset          (reset),
    .data_in_ready  (FIFO_in_psum_in_ready),
    .data_in_valid  (FIFO_in_psum_in_valid),
    .data_in        (FIFO_in_psum_in),
    .data_out_ready (FIFO_in_psum_out_ready),
    .data_out_valid (FIFO_in_psum_out_valid),
    .data_out       (FIFO_in_psum_out)
);

// ------------------------------------
// FIFO for psum out
// ------------------------------------
PE_psum_FIFO psum_out_FIFO (
    .clock          (clock),
    .reset          (reset),
    .data_in_ready  (FIFO_out_psum_in_ready),
    .data_in_valid  (FIFO_out_psum_in_valid),
    .data_in        (FIFO_out_psum_in),
    .data_out_ready (FIFO_out_psum_out_ready),
    .data_out_valid (FIFO_out_psum_out_valid),
    .data_out       (FIFO_out_psum_out)
);

//
// ==================================================================== //
//                              Combinational                           //
// ==================================================================== //
//

// ------------------------------------
// top-level outputs
// ------------------------------------


assign all_write_fin          = iact_addr_write_fin_reg  &
                                iact_data_write_fin_reg  &
                                weight_addr_write_fin_reg &
                                weight_data_write_fin_reg;

assign psum_in_ready          = FIFO_in_psum_in_ready;
assign psum_out_valid         = FIFO_out_psum_out_valid;
assign psum_out               = FIFO_out_psum_out;

assign iact_address_in_ready  = FIFO_iact_address_in_ready;
assign iact_data_in_ready     = FIFO_iact_data_in_ready;
assign weight_address_in_ready= FIFO_weight_address_in_ready;
assign weight_data_in_ready   = FIFO_weight_data_in_ready;

// sticky finish flags
assign iact_address_write_fin   = iact_addr_write_fin_reg;
assign iact_data_write_fin      = iact_data_write_fin_reg;
assign weight_address_write_fin = weight_addr_write_fin_reg;
assign weight_data_write_fin    = weight_data_write_fin_reg;

assign psum_add_fin           = PE_pad_psum_add_fin;
assign cal_fin                = PE_ctrl_Top_cal_fin;

// ------------------------------------
// controller connections
// ------------------------------------
// add signal to controller
assign PE_ctrl_fromTop_psum_acc_fin = PE_pad_psum_add_fin;
//
assign PE_ctrl_fromTop_cal_fin = PE_pad_cal_fin;
assign PE_ctrl_Top_psum_enq_en = psum_enq_en;
assign PE_ctrl_Top_do_load_en  = do_load_en;
assign PE_ctrl_Top_write_fin   = all_write_fin;

// ------------------------------------
// PE core connections
// ------------------------------------
assign PE_pad_do_mac_en           = PE_ctrl_do_mac_en;
assign PE_pad_psum_enq_en         = PE_ctrl_fromTop_psum_enq_en;
assign PE_pad_do_load_en          = PE_ctrl_fromTop_do_load_en;

// psum path
assign PE_pad_psum_in_valid       = FIFO_in_psum_out_valid;
assign PE_pad_psum_in             = FIFO_in_psum_out;
assign PE_pad_psum_out_ready      = FIFO_out_psum_in_ready;

// iact/weight path from FIFO to core
assign PE_pad_iact_address_in_valid = FIFO_iact_address_out_valid;
assign PE_pad_iact_address_in       = FIFO_iact_address_out;

assign PE_pad_iact_data_in_valid    = FIFO_iact_data_out_valid;
assign PE_pad_iact_data_in          = FIFO_iact_data_out;

assign PE_pad_weight_address_in_valid = FIFO_weight_address_out_valid;
assign PE_pad_weight_address_in       = FIFO_weight_address_out;

assign PE_pad_weight_data_in_valid    = FIFO_weight_data_out_valid;
assign PE_pad_weight_data_in          = FIFO_weight_data_out;

// ------------------------------------
// source side into FIFOs
// ------------------------------------
assign FIFO_iact_address_in_valid   = iact_address_in_valid;
assign FIFO_iact_address_in         = iact_address_in;

assign FIFO_iact_data_in_valid      = iact_data_in_valid;
assign FIFO_iact_data_in            = iact_data_in;

assign FIFO_weight_address_in_valid = weight_address_in_valid;
assign FIFO_weight_address_in       = weight_address_in;

assign FIFO_weight_data_in_valid    = weight_data_in_valid;
assign FIFO_weight_data_in          = weight_data_in;

// psum input FIFO
assign FIFO_in_psum_in_valid        = psum_in_valid;
assign FIFO_in_psum_in              = psum_in;
assign FIFO_in_psum_out_ready       = PE_pad_psum_in_ready;

// psum output FIFO
assign FIFO_out_psum_in_valid       = PE_pad_psum_out_valid;
assign FIFO_out_psum_in             = PE_pad_psum_out;
assign FIFO_out_psum_out_ready      = psum_out_ready;

// ------------------------------------
// pop input FIFOs only during load phase
// and stop popping after each corresponding write-finish is latched
// ------------------------------------
// Core SPAD write ports keep data_in_ready tied high in normal operation; load gating matches prior behavior.
assign FIFO_iact_address_out_ready   = PE_pad_do_load_en & (~iact_addr_write_fin_reg);
assign FIFO_iact_data_out_ready      = PE_pad_do_load_en & (~iact_data_write_fin_reg);
assign FIFO_weight_address_out_ready = PE_pad_do_load_en & (~weight_addr_write_fin_reg);
assign FIFO_weight_data_out_ready    = PE_pad_do_load_en & (~weight_data_write_fin_reg);

//
// ==================================================================== //
//                              Sequential                              //
// ==================================================================== //
//

// iact finish flags
always @(posedge clock) begin
    if (reset) begin
        iact_addr_write_fin_reg <= 1'b0;
        iact_data_write_fin_reg <= 1'b0;
    end
    else if (iact_write_fin_clear) begin
        iact_addr_write_fin_reg <= 1'b0;
        iact_data_write_fin_reg <= 1'b0;
    end
    else begin
        iact_addr_write_fin_reg <= iact_addr_write_fin_reg | PE_pad_iact_address_write_fin;
        iact_data_write_fin_reg <= iact_data_write_fin_reg | PE_pad_iact_data_write_fin;
    end
end

// weight finish flags
always @(posedge clock) begin
    if (reset) begin
        weight_addr_write_fin_reg <= 1'b0;
        weight_data_write_fin_reg <= 1'b0;
    end
    else if (weight_write_fin_clear) begin
        weight_addr_write_fin_reg <= 1'b0;
        weight_data_write_fin_reg <= 1'b0;
    end
    else begin
        weight_addr_write_fin_reg <= weight_addr_write_fin_reg | PE_pad_weight_address_write_fin;
        weight_data_write_fin_reg <= weight_data_write_fin_reg | PE_pad_weight_data_write_fin;
    end
end

endmodule