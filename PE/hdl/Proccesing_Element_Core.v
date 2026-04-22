module Processing_Element_core_pipeline #(
    parameter integer IACT_ADDR_W       = 8,
    parameter integer IACT_DATA_W       = 13,
    parameter integer IACT_COUNT_W      = 5,
    parameter integer IACT_VALUE_W      = 8,
    parameter integer IACT_SEG_IDX_W    = 5,
    parameter integer IACT_DATA_PTR_W   = 8,
    parameter integer WEIGHT_ADDR_W     = 7,
    parameter integer WEIGHT_COL_IDX_W  = 5,
    parameter integer WEIGHT_WORD_PTR_W = 7,
    parameter integer WEIGHT_COUNT_W    = 4,
    parameter integer WEIGHT_VALUE_W    = 8,
    parameter integer WEIGHT_PACKED_W   = 24,
    parameter integer PSUM_W            = 21,
    parameter integer PSUM_ADDR_W       = 5,
    parameter integer WEIGHT_MATRIX_ROW = 4
)(
    input                               clock,
    input                               reset,
    output                              psum_in_ready,
    input                               psum_in_valid,
    input  signed [PSUM_W-1:0]          psum_in,
    input                               psum_out_ready,
    output                              psum_out_valid,
    output signed [PSUM_W-1:0]          psum_out,
    input                               iact_address_in_valid,
    input        [IACT_ADDR_W-1:0]      iact_address_in,
    input                               iact_data_in_valid,
    input        [IACT_DATA_W-1:0]      iact_data_in,
    input                               weight_address_in_valid,
    input        [WEIGHT_ADDR_W-1:0]    weight_address_in,
    input                               weight_data_in_valid,
    input        [WEIGHT_PACKED_W-1:0]  weight_data_in,
    input                               mac_en,
    input                               psum_enq_en,
    input                               load_en,
    output                              cal_fin,
    output                              iact_address_write_fin,
    output                              iact_data_write_fin,
    output                              weight_address_write_fin,
    output                              weight_data_write_fin,
    output                              psum_acc_fin,
    input        [PSUM_ADDR_W-1:0]      PSUM_DEPTH,
    input                               psum_spad_clear,

    // polling signals
    input                               pool_cmp_en,
    input                               pool_cmp_stop,
    input                               pool_elem_in_valid,
    output                              pool_elem_in_ready,
    input  signed [IACT_VALUE_W-1:0]   pool_elem_in,
    input                               pool_win_first,
    input                               pool_win_last,
    output                              pool_out_valid,
    input                               pool_out_ready,
    output signed [IACT_VALUE_W-1:0]   pool_out
);

localparam [1:0] MODE_IDLE   = 2'd0;
localparam [1:0] MODE_RUN    = 2'd1;
localparam [1:0] MODE_MERGE  = 2'd2;
localparam [1:0] MODE_POOL   = 2'd3;

// -----------------------------------------------------------------------------
// coarse mode and completion pulses
// -----------------------------------------------------------------------------
reg [1:0] mode_q;
reg       cal_fin_q;
reg       psum_acc_fin_q;

// Max-pool compare engine (separate from MAC / psum datapath)
reg signed [IACT_VALUE_W-1:0] pool_max_q;
reg                           pool_out_valid_q;
reg signed [IACT_VALUE_W-1:0] pool_out_q;

wire signed [IACT_VALUE_W-1:0] pool_next_max_w;
wire                           pool_xfer_w;

assign pool_next_max_w = pool_win_first ? $signed(pool_elem_in)
       : (($signed(pool_elem_in) > $signed(pool_max_q)) ? pool_elem_in : pool_max_q);
assign pool_xfer_w     = (mode_q == MODE_POOL) && pool_elem_in_valid && pool_elem_in_ready;
assign pool_elem_in_ready = (mode_q == MODE_POOL) && (!pool_out_valid_q || pool_out_ready);
assign pool_out_valid = pool_out_valid_q;
assign pool_out       = pool_out_q;
reg [PSUM_ADDR_W-1:0] merge_idx_q;
reg psum_out_valid_q;
reg                                psum_rd_en0_q;
//wire psum_out_valid_w;
assign cal_fin      = cal_fin_q;
assign psum_acc_fin = psum_acc_fin_q;
assign psum_in_ready  = (mode_q == MODE_MERGE) ? psum_out_ready : 1'b0;
//assign psum_out_valid_w = (mode_q == MODE_MERGE) ? psum_in_valid  : 1'b0;
reg psum_in_valid_q;
assign psum_out_valid = (mode_q == MODE_MERGE) ? psum_in_valid_q : psum_out_valid_q;

//add signal fix merge
reg merge_req_pending_q;
reg                     weight_addr_loaded_q;
reg                     weight_data_loaded_q;
//

//add fix mac
reg mac_en_q;
reg mac_req_pending_q;
wire mac_start_w;

assign mac_start_w = mac_en & ~mac_en_q;
//

// -----------------------------------------------------------------------------
// load bookkeeping (kept from old strategy)
// -----------------------------------------------------------------------------
reg                            load_en_q;
reg [IACT_SEG_IDX_W:0]         iact_addr_entry_count_q;
reg [IACT_DATA_PTR_W:0]        iact_data_entry_count_q;
wire                           load_rise_w;
assign load_rise_w = load_en & ~load_en_q;

// -----------------------------------------------------------------------------
// SPad interfaces
// -----------------------------------------------------------------------------
wire                               iact_address_spad_data_in_ready;
wire                               iact_address_spad_write_fin_int;
wire  [IACT_SEG_IDX_W-1:0]          iact_address_rd_seg_idx_q;
wire [IACT_DATA_PTR_W-1:0]         iact_seg_begin_w;
wire [IACT_DATA_PTR_W-1:0]         iact_seg_end_w;

wire                               iact_data_spad_data_in_ready;
wire                               iact_data_spad_write_fin_int;
reg  [IACT_DATA_PTR_W-1:0]         iact_data_read_idx_q;
wire [IACT_DATA_W-1:0]             iact_data_spad_data_out;

wire                               weight_address_spad_data_in_ready;
wire                               weight_address_spad_write_fin_int;
wire  [WEIGHT_COL_IDX_W-1:0]       weight_address_rd_col_idx_w;
wire [WEIGHT_WORD_PTR_W-1:0]       weight_col_begin_w;
wire [WEIGHT_WORD_PTR_W-1:0]       weight_col_end_w;

wire                               weight_data_spad_data_in_ready;
wire                               weight_data_spad_write_fin_int;
reg                                weight_data_read_en_q;
reg  [WEIGHT_WORD_PTR_W-1:0]       weight_data_read_word_idx_q;
wire                               weight_lane0_valid_w;
wire [WEIGHT_COUNT_W-1:0]          weight_lane0_count_w;
wire signed [WEIGHT_VALUE_W-1:0]   weight_lane0_value_w;
wire                               weight_lane1_valid_w;
wire [WEIGHT_COUNT_W-1:0]          weight_lane1_count_w;
wire signed [WEIGHT_VALUE_W-1:0]   weight_lane1_value_w;

reg                                psum_rd_en1_q;
reg  [PSUM_ADDR_W-1:0]             psum_rd_addr0_q;
reg  [PSUM_ADDR_W-1:0]             psum_rd_addr1_q;
reg                                psum_wr_en0_q;
reg                                psum_wr_en1_q;
reg  [PSUM_ADDR_W-1:0]             psum_wr_addr0_q;
reg  [PSUM_ADDR_W-1:0]             psum_wr_addr1_q;
reg  signed [PSUM_W-1:0]           psum_wr_data0_q;
reg  signed [PSUM_W-1:0]           psum_wr_data1_q;
wire signed [PSUM_W-1:0]           psum_spad_rd_data0_w;
wire signed [PSUM_W-1:0]           psum_spad_rd_data1_w;
wire signed [PSUM_W-1:0]           psum_out_w;
reg signed  [PSUM_W-1:0]           psum_out_q;

assign psum_out = psum_out_q;

Iact_Address_Spad u_iact_address_spad (
    .clock         (clock),
    .reset         (reset),
    .data_in_ready (iact_address_spad_data_in_ready),
    .data_in_valid (iact_address_in_valid),
    .data_in       (iact_address_in),
    .write_en      (load_en),
    .write_fin     (iact_address_spad_write_fin_int),
    .rd_seg_idx    (iact_address_rd_seg_idx_q),
    .seg_begin     (iact_seg_begin_w),
    .seg_end       (iact_seg_end_w)
);

Iact_Data_Spad u_iact_data_spad (
    .clock         (clock),
    .reset         (reset),
    .data_in_ready (iact_data_spad_data_in_ready),
    .data_in_valid (iact_data_in_valid),
    .data_in       (iact_data_in),
    .write_en      (load_en),
    .write_fin     (iact_data_spad_write_fin_int),
    .read_idx      (iact_data_read_idx_q),
    .data_out      (iact_data_spad_data_out)
);

Weight_Address_Spad u_weight_address_spad (
    .clock         (clock),
    .reset         (reset),
    .data_in_ready (weight_address_spad_data_in_ready),
    .data_in_valid (weight_address_in_valid),
    .data_in       (weight_address_in),
    .write_en      (load_en),
    .write_fin     (weight_address_spad_write_fin_int),
    .rd_col_idx    (weight_address_rd_col_idx_w),
    .col_begin     (weight_col_begin_w),
    .col_end       (weight_col_end_w)
);

Weight_Data_Spad u_weight_data_spad (
    .clock         (clock),
    .reset         (reset),
    .data_in_ready (weight_data_spad_data_in_ready),
    .data_in_valid (weight_data_in_valid),
    .data_in       (weight_data_in),
    .write_en      (load_en),
    .write_fin     (weight_data_spad_write_fin_int),
    .read_en       (weight_data_read_en_q),
    .read_word_idx (weight_data_read_word_idx_q),
    .lane0_valid   (weight_lane0_valid_w),
    .lane0_count   (weight_lane0_count_w),
    .lane0_value   (weight_lane0_value_w),
    .lane1_valid   (weight_lane1_valid_w),
    .lane1_count   (weight_lane1_count_w),
    .lane1_value   (weight_lane1_value_w)
);

Psum_Spad_2R2W u_psum_spad (
    .clock           (clock),
    .reset           (reset),
    .rd_en0          (psum_rd_en0_q),
    .rd_addr0        (psum_rd_addr0_q),
    .rd_data0        (psum_spad_rd_data0_w),
    .rd_en1          (psum_rd_en1_q),
    .rd_addr1        (psum_rd_addr1_q),
    .rd_data1        (psum_spad_rd_data1_w),
    .wr_en0          (psum_wr_en0_q),
    .wr_addr0        (psum_wr_addr0_q),
    .wr_data0        (psum_wr_data0_q),
    .wr_en1          (psum_wr_en1_q),
    .wr_addr1        (psum_wr_addr1_q),
    .wr_data1        (psum_wr_data1_q),
    .psum_spad_clear (psum_spad_clear)
);

assign iact_address_write_fin   = iact_address_spad_write_fin_int;
assign iact_data_write_fin      = iact_data_spad_write_fin_int;
assign weight_address_write_fin = weight_address_spad_write_fin_int;
assign weight_data_write_fin    = weight_data_spad_write_fin_int;

// -----------------------------------------------------------------------------
// iact fetch state
// -----------------------------------------------------------------------------
reg [IACT_SEG_IDX_W-1:0]        fetch_seg_idx_q;
reg [IACT_DATA_PTR_W-1:0]       fetch_entry_ptr_q;
reg [IACT_DATA_PTR_W-1:0]       fetch_entry_end_q;
reg [IACT_COUNT_W:0]            fetch_row_base_q;
reg                             fetch_first_entry_q;
reg                             fetch_seg_open_q;
reg                             fetch_done_q;

wire [IACT_DATA_PTR_W-1:0]      fetch_next_entry_ptr_w;
wire                            fetch_has_seg_w;
wire                            fetch_seg_empty_w;
wire                            fetch_last_iact_w;
wire                            fetch_last_seg_w;

assign iact_address_rd_seg_idx_q  = fetch_seg_idx_q;


// -----------------------------------------------------------------------------
// BRAM-safe iact fetch handshake: 1 outstanding read max
// -----------------------------------------------------------------------------
reg                             fetch_read_pending_q;
reg [IACT_SEG_IDX_W-1:0]        fetch_resp_seg_q;
reg [IACT_DATA_PTR_W-1:0]       fetch_resp_entry_ptr_q;
reg [IACT_COUNT_W:0]            fetch_resp_row_base_q;
reg                             fetch_resp_first_entry_q;
reg                             fetch_resp_last_iact_q;
reg                             fetch_resp_last_seg_q;
reg                             fetch_resp_valid_q;

wire                            fetch_req_w;
wire                            fetch_resp_valid_w;
wire [IACT_COUNT_W-1:0]         fetch_resp_count_w;
wire signed [IACT_VALUE_W-1:0]  fetch_resp_value_w;
wire [IACT_COUNT_W:0]           fetch_resp_row_w;
wire [IACT_COUNT_W:0]           fetch_resp_next_row_base_w;
wire [IACT_DATA_PTR_W-1:0]      fetch_resp_next_entry_ptr_w;

assign fetch_has_seg_w             = ((fetch_seg_idx_q + {{(IACT_SEG_IDX_W-1){1'b0}},1'b1}) <
                                      iact_addr_entry_count_q[IACT_SEG_IDX_W-1:0]);
assign fetch_seg_empty_w           = (iact_seg_begin_w == iact_seg_end_w);
assign fetch_next_entry_ptr_w      = fetch_entry_ptr_q + {{(IACT_DATA_PTR_W-1){1'b0}},1'b1};
assign fetch_last_iact_w           = (fetch_next_entry_ptr_w >= fetch_entry_end_q);
assign fetch_last_seg_w            = ((fetch_seg_idx_q + {{(IACT_SEG_IDX_W-1){1'b0}},1'b1}) >=
                                      (iact_addr_entry_count_q - {{IACT_SEG_IDX_W{1'b0}},1'b1}));



// assume iact_data_spad is 1-cycle synchronous read
assign fetch_resp_valid_w          = fetch_resp_valid_q;
assign fetch_resp_count_w          = iact_data_spad_data_out[IACT_COUNT_W-1:0];
assign fetch_resp_value_w          = iact_data_spad_data_out[IACT_DATA_W-1:IACT_COUNT_W];
assign fetch_resp_row_w            = fetch_resp_first_entry_q
                                     ? {{1'b0}, fetch_resp_count_w}
                                     : (fetch_resp_row_base_q + {{1'b0}, fetch_resp_count_w});
assign fetch_resp_next_row_base_w  = fetch_resp_row_w + {{IACT_COUNT_W{1'b0}},1'b1};
assign fetch_resp_next_entry_ptr_w = fetch_resp_entry_ptr_q + {{(IACT_DATA_PTR_W-1){1'b0}},1'b1};

// -----------------------------------------------------------------------------
// 2-entry task queue to overlap front-end with the back-end without reordering
// -----------------------------------------------------------------------------
reg                              q0_valid_q, q1_valid_q;
reg signed [IACT_VALUE_W-1:0]    q0_value_q, q1_value_q;
reg [PSUM_ADDR_W-1:0]            q0_row_q,   q1_row_q;
reg [IACT_SEG_IDX_W-1:0]         q0_seg_q,   q1_seg_q;
wire                             queue_full_w;
wire                             queue_empty_w;
wire                             queue_pop_w;
wire                             front_push_req_w;
wire signed [IACT_VALUE_W-1:0]   front_push_value_w;
wire [PSUM_ADDR_W-1:0]           front_push_row_w;
wire [IACT_SEG_IDX_W-1:0]        front_push_seg_w;

// issue only when segment is open, queue has room, and there is no outstanding read
assign fetch_req_w                 = (mode_q == MODE_RUN) && fetch_seg_open_q &&
                                     !fetch_done_q && !fetch_read_pending_q && !fetch_resp_valid_q 
                                     && !queue_full_w;

// -----------------------------------------------------------------------------
// S2 (weight-address stage) registers
// -----------------------------------------------------------------------------
reg                              s2_valid_q;
reg signed [IACT_VALUE_W-1:0]    s2_iact_value_q;
reg [PSUM_ADDR_W-1:0]            s2_iact_row_q;
reg [IACT_SEG_IDX_W-1:0]         s2_iact_seg_q;

assign weight_address_rd_col_idx_w = s2_iact_row_q[WEIGHT_COL_IDX_W-1:0];

// -----------------------------------------------------------------------------
// active task and overlapped weight/MAC/writeback pipeline
// -----------------------------------------------------------------------------
reg                              active_task_valid_q;
reg signed [IACT_VALUE_W-1:0]    active_iact_value_q;
reg [PSUM_ADDR_W-1:0]            active_iact_row_q;
reg [IACT_SEG_IDX_W-1:0]         active_iact_seg_q;
reg [WEIGHT_WORD_PTR_W-1:0]      weight_word_ptr_q;
reg [WEIGHT_WORD_PTR_W-1:0]      weight_word_end_q;
reg [PSUM_ADDR_W-1:0]            weight_row_base_q;
reg                              weight_first_word_q;
reg                              weight_issue_done_q;
reg signed [PSUM_W-1:0]          psum_in_q;

reg                              s3_pending_q;
reg                              s3_delay_q;    
reg signed [IACT_VALUE_W-1:0]    s3_iact_value_q;
reg [IACT_SEG_IDX_W-1:0]         s3_iact_seg_q;
reg [PSUM_ADDR_W-1:0]            s3_weight_row_base_q;
reg                              s3_weight_first_word_q;
reg [WEIGHT_WORD_PTR_W-1:0]      s3_weight_word_ptr_q;
reg [WEIGHT_WORD_PTR_W-1:0]      s3_weight_word_end_q;

reg                              s4_valid_q;
reg                              s4_lane0_valid_q;
reg                              s4_lane1_valid_q;
reg signed [IACT_VALUE_W-1:0]    s4_iact_value_q;
reg signed [WEIGHT_VALUE_W-1:0]  s4_weight_value0_q;
reg signed [WEIGHT_VALUE_W-1:0]  s4_weight_value1_q;
reg [PSUM_ADDR_W-1:0]            s4_psum_addr0_q;
reg [PSUM_ADDR_W-1:0]            s4_psum_addr1_q;
reg [PSUM_ADDR_W-1:0]            s4_next_weight_row_base_q;
reg                              s4_last_weight_word_q;

reg                              s5_valid_q;
reg                              s5_lane0_valid_q;
reg                              s5_lane1_valid_q;
reg [PSUM_ADDR_W-1:0]            s5_psum_addr0_q;
reg [PSUM_ADDR_W-1:0]            s5_psum_addr1_q;
reg signed [PSUM_W-1:0]          s5_old_psum0_q;
reg signed [PSUM_W-1:0]          s5_old_psum1_q;
reg signed [PSUM_W-1:0]          s5_product0_q;
reg signed [PSUM_W-1:0]          s5_product1_q;
reg                              s5_last_weight_word_q;

reg                              s6_valid_q;
reg                              s6_lane0_valid_q;
reg                              s6_lane1_valid_q;
reg [PSUM_ADDR_W-1:0]            s6_psum_addr0_q;
reg [PSUM_ADDR_W-1:0]            s6_psum_addr1_q;
reg signed [PSUM_W-1:0]          s6_psum_sum0_q;
reg signed [PSUM_W-1:0]          s6_psum_sum1_q;
reg                              s6_last_weight_word_q;

wire                             issue_weight_word_w;
wire [PSUM_ADDR_W-1:0]           s4_weight_row0_calc_w;
wire [PSUM_ADDR_W-1:0]           s4_weight_base_after_lane0_w;
wire [PSUM_ADDR_W-1:0]           s4_weight_row1_calc_w;
wire [PSUM_ADDR_W-1:0]           s4_weight_next_base_w;
wire [PSUM_ADDR_W-1:0]           s4_iact_psum_base_w;
wire [PSUM_ADDR_W-1:0]           s4_psum_addr0_w;
wire [PSUM_ADDR_W-1:0]           s4_psum_addr1_w;
wire                             s4_last_weight_word_w;
wire signed [PSUM_W-1:0]         s5_product0_w;
wire signed [PSUM_W-1:0]         s5_product1_w;
wire signed [PSUM_W-1:0]         s6_psum_sum0_w;
wire signed [PSUM_W-1:0]         s6_psum_sum1_w;
wire                             run_drained_w;

wire [WEIGHT_WORD_PTR_W-1:0] weight_issue_ptr_plus1_w;
wire                         issue_this_is_last_w;
wire [PSUM_ADDR_W-1:0]       issue_row_base_w;
wire                         issue_first_word_w;

assign weight_issue_ptr_plus1_w = weight_word_ptr_q + {{(WEIGHT_WORD_PTR_W-1){1'b0}},1'b1};
assign issue_this_is_last_w     = (weight_issue_ptr_plus1_w >= weight_word_end_q);
assign issue_row_base_w   = s3_pending_q ? s4_weight_next_base_w : weight_row_base_q;
assign issue_first_word_w = s3_pending_q ? 1'b0                  : weight_first_word_q;

assign issue_weight_word_w =(mode_q == MODE_RUN) &&active_task_valid_q &&!weight_issue_done_q &&!s3_delay_q;

assign s4_weight_row0_calc_w = s3_weight_first_word_q ?
                               {{(PSUM_ADDR_W-WEIGHT_COUNT_W){1'b0}}, weight_lane0_count_w} :
                               (s3_weight_row_base_q + {{(PSUM_ADDR_W-WEIGHT_COUNT_W){1'b0}}, weight_lane0_count_w});
assign s4_weight_base_after_lane0_w = s4_weight_row0_calc_w + {{(PSUM_ADDR_W-1){1'b0}},1'b1};
assign s4_weight_row1_calc_w = s4_weight_base_after_lane0_w + {{(PSUM_ADDR_W-WEIGHT_COUNT_W){1'b0}}, weight_lane1_count_w}; //Note
assign s4_weight_next_base_w = weight_lane1_valid_w ?
                               (s4_weight_row1_calc_w + {{(PSUM_ADDR_W-1){1'b0}},1'b1}) :
                               s4_weight_base_after_lane0_w;
assign s4_iact_psum_base_w   = s3_iact_seg_q * WEIGHT_MATRIX_ROW;
assign s4_psum_addr0_w       = s4_iact_psum_base_w + s4_weight_row0_calc_w;
assign s4_psum_addr1_w       = s4_iact_psum_base_w + s4_weight_row1_calc_w;
assign s4_last_weight_word_w = ((s3_weight_word_ptr_q + {{(WEIGHT_WORD_PTR_W-1){1'b0}},1'b1}) >= s3_weight_word_end_q);
assign s5_product0_w         = s4_lane0_valid_q ? ($signed(s4_weight_value0_q) * $signed(s4_iact_value_q)) : $signed({PSUM_W{1'b0}});
assign s5_product1_w         = s4_lane1_valid_q ? ($signed(s4_weight_value1_q) * $signed(s4_iact_value_q)) : $signed({PSUM_W{1'b0}});
assign s6_psum_sum0_w        = $signed(psum_spad_rd_data0_w) + $signed(s5_product0_q);
assign s6_psum_sum1_w        = $signed(psum_spad_rd_data1_w) + $signed(s5_product1_q);

assign run_drained_w = fetch_done_q && !fetch_read_pending_q && !fetch_resp_valid_q && queue_empty_w && !s2_valid_q && !active_task_valid_q &&
                       !s3_pending_q && !s4_valid_q && !s5_valid_q && !s6_valid_q;
assign queue_pop_w   = (mode_q == MODE_RUN) && !s2_valid_q && q0_valid_q; // queue pop logic
assign psum_out_w      = (mode_q == MODE_MERGE) ? ($signed(psum_spad_rd_data0_w) + $signed(psum_in)) : $signed({PSUM_W{1'b0}});
assign front_push_req_w   = (mode_q == MODE_RUN) && fetch_resp_valid_q; // queue push logic
assign front_push_value_w = fetch_resp_value_w;
assign front_push_row_w   = fetch_resp_row_w[PSUM_ADDR_W-1:0];
assign front_push_seg_w   = fetch_resp_seg_q;
assign queue_full_w  = q0_valid_q & q1_valid_q;
assign queue_empty_w = ~q0_valid_q && ~q1_valid_q;

// -----------------------------------------------------------------------------
// load bookkeeping
// -----------------------------------------------------------------------------
always @(posedge clock) begin
    if (reset) begin
        load_en_q               <= 1'b0;
        iact_addr_entry_count_q <= {(IACT_SEG_IDX_W+1){1'b0}};
        iact_data_entry_count_q <= {(IACT_DATA_PTR_W+1){1'b0}};
    end else begin
        load_en_q <= load_en;
        if (load_rise_w) begin
            iact_addr_entry_count_q <= {(IACT_SEG_IDX_W+1){1'b0}};
            iact_data_entry_count_q <= {(IACT_DATA_PTR_W+1){1'b0}};
        end else begin
            if (load_en && iact_address_in_valid && iact_address_spad_data_in_ready)
                iact_addr_entry_count_q <= iact_addr_entry_count_q + {{IACT_SEG_IDX_W{1'b0}},1'b1};
            if (load_en && iact_data_in_valid && iact_data_spad_data_in_ready)
                iact_data_entry_count_q <= iact_data_entry_count_q + {{IACT_DATA_PTR_W{1'b0}},1'b1};
        end
    end
end

// -----------------------------------------------------------------------------
// main sequential logic
// -----------------------------------------------------------------------------
always @(posedge clock) begin
    if (reset) begin
        mode_q                  <= MODE_IDLE;
        merge_idx_q             <= {PSUM_ADDR_W{1'b0}};
        cal_fin_q               <= 1'b0;
        psum_acc_fin_q          <= 1'b0;
        //load_en_q               <= 1'b0;
        psum_out_valid_q         <= 1'b0;
        pool_max_q               <= {IACT_VALUE_W{1'b0}};
        pool_out_valid_q         <= 1'b0;
        pool_out_q               <= {IACT_VALUE_W{1'b0}};
        iact_data_read_idx_q        <= {IACT_DATA_PTR_W{1'b0}};
        weight_data_read_en_q       <= 1'b0;
        weight_data_read_word_idx_q <= {WEIGHT_WORD_PTR_W{1'b0}};

        //add signal fix merge
        merge_req_pending_q     <= 1'b0;

        //add fix mac
        mac_en_q <= 1'b0;
        mac_req_pending_q <= 1'b0;
        weight_addr_loaded_q <= 1'b0;
        weight_data_loaded_q <= 1'b0;
        //

        psum_rd_en0_q <= 1'b0;
        psum_rd_en1_q <= 1'b0;
        psum_rd_addr0_q <= {PSUM_ADDR_W{1'b0}};
        psum_rd_addr1_q <= {PSUM_ADDR_W{1'b0}};
        psum_wr_en0_q <= 1'b0;
        psum_wr_en1_q <= 1'b0;
        psum_wr_addr0_q <= {PSUM_ADDR_W{1'b0}};
        psum_wr_addr1_q <= {PSUM_ADDR_W{1'b0}};
        psum_wr_data0_q <= {PSUM_W{1'b0}};
        psum_wr_data1_q <= {PSUM_W{1'b0}};
        psum_in_q <= {PSUM_W{1'b0}};
        psum_out_q <= {PSUM_W{1'b0}};
        psum_in_valid_q <= 1'b0;

        fetch_seg_idx_q          <= {IACT_SEG_IDX_W{1'b0}};
        fetch_entry_ptr_q        <= {IACT_DATA_PTR_W{1'b0}};
        fetch_entry_end_q        <= {IACT_DATA_PTR_W{1'b0}};
        fetch_row_base_q         <= {(IACT_COUNT_W+1){1'b0}};
        fetch_first_entry_q      <= 1'b1;
        fetch_seg_open_q         <= 1'b0;
        fetch_done_q             <= 1'b0;
        fetch_read_pending_q     <= 1'b0;
        fetch_resp_seg_q         <= {IACT_SEG_IDX_W{1'b0}};
        fetch_resp_entry_ptr_q   <= {IACT_DATA_PTR_W{1'b0}};
        fetch_resp_row_base_q    <= {(IACT_COUNT_W+1){1'b0}};
        fetch_resp_first_entry_q <= 1'b1;
        fetch_resp_last_iact_q   <= 1'b0;
        fetch_resp_last_seg_q    <= 1'b0;
        fetch_resp_valid_q       <= 1'b0;
        q0_valid_q               <= 1'b0;
        q1_valid_q               <= 1'b0;
        q0_value_q               <= {IACT_VALUE_W{1'b0}};
        q1_value_q               <= {IACT_VALUE_W{1'b0}};
        q0_row_q                 <= {PSUM_ADDR_W{1'b0}};
        q1_row_q                 <= {PSUM_ADDR_W{1'b0}};
        q0_seg_q                 <= {IACT_SEG_IDX_W{1'b0}};
        q1_seg_q                 <= {IACT_SEG_IDX_W{1'b0}};

        s2_valid_q               <= 1'b0;
        s2_iact_value_q          <= {IACT_VALUE_W{1'b0}};
        s2_iact_row_q            <= {PSUM_ADDR_W{1'b0}};
        s2_iact_seg_q            <= {IACT_SEG_IDX_W{1'b0}};

        active_task_valid_q      <= 1'b0;
        active_iact_value_q      <= {IACT_VALUE_W{1'b0}};
        active_iact_row_q        <= {PSUM_ADDR_W{1'b0}};
        active_iact_seg_q        <= {IACT_SEG_IDX_W{1'b0}};
        weight_word_ptr_q        <= {WEIGHT_WORD_PTR_W{1'b0}};
        weight_word_end_q        <= {WEIGHT_WORD_PTR_W{1'b0}};
        weight_row_base_q        <= {PSUM_ADDR_W{1'b0}};
        weight_first_word_q      <= 1'b1;
        weight_issue_done_q      <= 1'b0;

        s3_pending_q             <= 1'b0;
        s3_delay_q               <= 1'b0;
        s3_iact_value_q          <= {IACT_VALUE_W{1'b0}};
        s3_iact_seg_q            <= {IACT_SEG_IDX_W{1'b0}};
        s3_weight_row_base_q     <= {PSUM_ADDR_W{1'b0}};
        s3_weight_first_word_q   <= 1'b1;
        s3_weight_word_ptr_q     <= {WEIGHT_WORD_PTR_W{1'b0}};
        s3_weight_word_end_q     <= {WEIGHT_WORD_PTR_W{1'b0}};

        s4_valid_q               <= 1'b0;
        s4_lane0_valid_q         <= 1'b0;
        s4_lane1_valid_q         <= 1'b0;
        s4_iact_value_q          <= {IACT_VALUE_W{1'b0}};
        s4_weight_value0_q       <= {WEIGHT_VALUE_W{1'b0}};
        s4_weight_value1_q       <= {WEIGHT_VALUE_W{1'b0}};
        s4_psum_addr0_q          <= {PSUM_ADDR_W{1'b0}};
        s4_psum_addr1_q          <= {PSUM_ADDR_W{1'b0}};
        s4_next_weight_row_base_q <= {PSUM_ADDR_W{1'b0}};
        s4_last_weight_word_q    <= 1'b0;

        s5_valid_q               <= 1'b0;
        s5_lane0_valid_q         <= 1'b0;
        s5_lane1_valid_q         <= 1'b0;
        s5_psum_addr0_q          <= {PSUM_ADDR_W{1'b0}};
        s5_psum_addr1_q          <= {PSUM_ADDR_W{1'b0}};
        s5_old_psum0_q           <= {PSUM_W{1'b0}};
        s5_old_psum1_q           <= {PSUM_W{1'b0}};
        s5_product0_q            <= {PSUM_W{1'b0}};
        s5_product1_q            <= {PSUM_W{1'b0}};
        s5_last_weight_word_q    <= 1'b0;

        s6_valid_q               <= 1'b0;
        s6_lane0_valid_q         <= 1'b0;
        s6_lane1_valid_q         <= 1'b0;
        s6_psum_addr0_q          <= {PSUM_ADDR_W{1'b0}};
        s6_psum_addr1_q          <= {PSUM_ADDR_W{1'b0}};
        s6_psum_sum0_q           <= {PSUM_W{1'b0}};
        s6_psum_sum1_q           <= {PSUM_W{1'b0}};
        s6_last_weight_word_q    <= 1'b0;
    end else begin

        //add fix
        mac_en_q <= mac_en;
        if (mac_start_w)
            mac_req_pending_q <= 1'b1;
        //
        if (load_rise_w) begin
            weight_addr_loaded_q <= 1'b0;
            weight_data_loaded_q <= 1'b0;
        end else begin
            if (weight_address_spad_write_fin_int)
                weight_addr_loaded_q <= 1'b1;
            if (weight_data_spad_write_fin_int)
                weight_data_loaded_q <= 1'b1;
        end
        cal_fin_q      <= 1'b0;
        psum_acc_fin_q <= 1'b0;

        // Pool compare datapath (no MAC / weight / psum use)
        if (mode_q == MODE_POOL) begin
            if (pool_xfer_w && pool_win_last) begin
                pool_out_q       <= pool_next_max_w;
                pool_out_valid_q <= 1'b1;
            end else if (pool_out_valid_q && pool_out_ready) begin
                pool_out_valid_q <= 1'b0;
            end
            if (pool_xfer_w)
                pool_max_q <= pool_next_max_w;
        end

        weight_data_read_en_q       <= 1'b0;
        weight_data_read_word_idx_q <= weight_word_ptr_q;

        psum_rd_en0_q    <= 1'b0;
        psum_rd_en1_q    <= 1'b0;
        psum_rd_addr0_q  <= {PSUM_ADDR_W{1'b0}};
        psum_rd_addr1_q  <= {PSUM_ADDR_W{1'b0}};
        psum_wr_en0_q    <= 1'b0;
        psum_wr_en1_q    <= 1'b0;
        psum_wr_addr0_q       <= s6_psum_addr0_q;
        psum_wr_addr1_q       <= s6_psum_addr1_q;
        psum_wr_data0_q       <= s6_psum_sum0_q;
        psum_wr_data1_q       <= s6_psum_sum1_q;
        psum_out_q             <= psum_out_w;
        psum_in_valid_q       <= psum_in_valid;

        // S6 commit
        if (s6_valid_q) begin
            psum_wr_en0_q <= s6_lane0_valid_q;
            psum_wr_en1_q <= s6_lane1_valid_q;
        end

        // S5 -> S6
        s6_valid_q <= s5_valid_q;
        if (s5_valid_q) begin
            s6_lane0_valid_q      <= s5_lane0_valid_q;
            s6_lane1_valid_q      <= s5_lane1_valid_q;
            s6_psum_addr0_q       <= s5_psum_addr0_q;
            s6_psum_addr1_q       <= s5_psum_addr1_q;
            s6_psum_sum0_q        <= s6_psum_sum0_w;
            s6_psum_sum1_q        <= s6_psum_sum1_w;
            s6_last_weight_word_q <= s5_last_weight_word_q;
        end else begin
            s6_lane0_valid_q      <= 1'b0;
            s6_lane1_valid_q      <= 1'b0;
            s6_last_weight_word_q <= 1'b0;
        end

        // S4 -> S5 (psum read and product latch)
        s5_valid_q <= s4_valid_q;
        if (s4_valid_q) begin
            psum_rd_en0_q         <= 1'b1;
            psum_rd_addr0_q       <= s4_psum_addr0_q;
            psum_rd_en1_q         <= 1'b1;
            psum_rd_addr1_q       <= s4_psum_addr1_q;
            s5_lane0_valid_q      <= s4_lane0_valid_q;
            s5_lane1_valid_q      <= s4_lane1_valid_q;
            s5_psum_addr0_q       <= s4_psum_addr0_q;
            s5_psum_addr1_q       <= s4_psum_addr1_q;
      //   s5_old_psum0_q        <= psum_spad_rd_data0_w;
      //   s5_old_psum1_q        <= psum_spad_rd_data1_w;
            s5_product0_q         <= s5_product0_w;
            s5_product1_q         <= s5_product1_w;
            s5_last_weight_word_q <= s4_last_weight_word_q;
        end else begin
            s5_lane0_valid_q      <= 1'b0;
            s5_lane1_valid_q      <= 1'b0;
            s5_last_weight_word_q <= 1'b0;
        end

        // returned weight word -> S4 and update next issue state
        s4_valid_q <= s3_pending_q;
        if (s3_pending_q) begin
            s4_lane0_valid_q          <= weight_lane0_valid_w;
            s4_lane1_valid_q          <= weight_lane1_valid_w;
            s4_iact_value_q           <= s3_iact_value_q;
            s4_weight_value0_q        <= weight_lane0_value_w;
            s4_weight_value1_q        <= weight_lane1_value_w;
            s4_psum_addr0_q           <= s4_psum_addr0_w;
            s4_psum_addr1_q           <= s4_psum_addr1_w;
            s4_next_weight_row_base_q <= s4_weight_next_base_w;
            s4_last_weight_word_q     <= s4_last_weight_word_w;

            if (!s4_last_weight_word_w) begin
                weight_row_base_q   <= s4_weight_next_base_w;
                weight_first_word_q <= 1'b0;
            end
        end
        s3_pending_q <= 1'b0;

        // Latch a merge request so a one-cycle pulse from the testbench is enough.
        if (psum_enq_en)
            merge_req_pending_q <= 1'b1;

        case (mode_q)
            MODE_IDLE: begin
                // start requirements: at least two address entries in address_spad and one data entry in data_spad
                //fix
                if (merge_req_pending_q) begin
                    mode_q <= MODE_MERGE;
                    merge_idx_q <= {PSUM_ADDR_W{1'b0}};
                    merge_req_pending_q <= 1'b0;
                    // Prefetch address 0 so first merge beat sees valid local psum data.
                    psum_rd_en0_q <= 1'b1;
                    psum_rd_addr0_q <= {PSUM_ADDR_W{1'b0}};
                    psum_in_q <= {PSUM_W{1'b0}};
                end else if (mac_req_pending_q &&
                    (iact_addr_entry_count_q >= {{IACT_SEG_IDX_W{1'b0}},2'b10}) &&
                    (iact_data_entry_count_q != {(IACT_DATA_PTR_W+1){1'b0}}) &&
                    weight_addr_loaded_q && weight_data_loaded_q) begin
                //
                    mode_q                   <= MODE_RUN;

                    //add fix
                    mac_req_pending_q <= 1'b0;
                    //

                    fetch_seg_idx_q          <= {IACT_SEG_IDX_W{1'b0}};
                    fetch_entry_ptr_q        <= {IACT_DATA_PTR_W{1'b0}};
                    fetch_entry_end_q        <= {IACT_DATA_PTR_W{1'b0}};
                    fetch_row_base_q         <= {(IACT_COUNT_W+1){1'b0}};
                    fetch_first_entry_q      <= 1'b1;
                    fetch_seg_open_q         <= 1'b0;
                    fetch_done_q             <= 1'b0;
                    fetch_read_pending_q     <= 1'b0;
                    fetch_resp_valid_q       <= 1'b0;
                    fetch_resp_seg_q         <= {IACT_SEG_IDX_W{1'b0}};
                    fetch_resp_entry_ptr_q   <= {IACT_DATA_PTR_W{1'b0}};
                    fetch_resp_row_base_q    <= {(IACT_COUNT_W+1){1'b0}};
                    fetch_resp_first_entry_q <= 1'b1;
                    fetch_resp_last_iact_q   <= 1'b0;
                    fetch_resp_last_seg_q    <= 1'b0;
                    iact_data_read_idx_q     <= {IACT_DATA_PTR_W{1'b0}};
                    q0_valid_q               <= 1'b0;
                    q1_valid_q               <= 1'b0;
                    s2_valid_q               <= 1'b0;
                    active_task_valid_q      <= 1'b0;
                    weight_issue_done_q      <= 1'b0;
                    s3_pending_q             <= 1'b0;
                    s4_valid_q               <= 1'b0;
                    s5_valid_q               <= 1'b0;
                    s6_valid_q               <= 1'b0;
                end else if (pool_cmp_en) begin
                    mode_q           <= MODE_POOL;
                    pool_max_q       <= {IACT_VALUE_W{1'b0}};
                    pool_out_valid_q <= 1'b0;
                end
            end

            MODE_RUN: begin

                if (fetch_resp_valid_w) begin
                    fetch_resp_valid_q <= 1'b0;

                    if (fetch_resp_last_iact_q) begin
                        fetch_seg_open_q    <= 1'b0;
                        fetch_first_entry_q <= 1'b1;
                        fetch_row_base_q    <= {(IACT_COUNT_W+1){1'b0}};
                        if (fetch_resp_last_seg_q)
                            fetch_done_q <= 1'b1;
                        else
                            fetch_seg_idx_q <=  fetch_seg_idx_q  + {{(IACT_SEG_IDX_W-1){1'b0}},1'b1};
                    end else begin
                        fetch_entry_ptr_q   <= fetch_resp_next_entry_ptr_w;
                        fetch_row_base_q    <= fetch_resp_next_row_base_w;
                        fetch_first_entry_q <= 1'b0;
                    end
                end else if (fetch_read_pending_q) begin
                    fetch_read_pending_q <= 1'b0;
                    fetch_resp_valid_q   <= 1'b1; 

                end
                 else if (!fetch_done_q && !fetch_read_pending_q && !fetch_resp_valid_q) begin
                    if (!fetch_seg_open_q) begin
                        if (!fetch_has_seg_w) begin
                            fetch_done_q <= 1'b1;
                        end else if (fetch_seg_empty_w) begin
                            if (fetch_last_seg_w)
                                fetch_done_q <= 1'b1;
                            else
                                fetch_seg_idx_q <= fetch_seg_idx_q + {{(IACT_SEG_IDX_W-1){1'b0}},1'b1};
                        end else begin
                            fetch_entry_ptr_q   <= iact_seg_begin_w;
                            fetch_entry_end_q   <= iact_seg_end_w;
                            fetch_row_base_q    <= {(IACT_COUNT_W+1){1'b0}};
                            fetch_first_entry_q <= 1'b1;
                            fetch_seg_open_q    <= 1'b1;
                        end
                    end else if (fetch_req_w) begin
                        iact_data_read_idx_q        <= fetch_entry_ptr_q;
                        fetch_read_pending_q        <= 1'b1;

                        // snapshot metadata for the returning response
                        fetch_resp_seg_q            <= fetch_seg_idx_q;
                        fetch_resp_entry_ptr_q      <= fetch_entry_ptr_q;
                        fetch_resp_row_base_q       <= fetch_row_base_q;
                        fetch_resp_first_entry_q    <= fetch_first_entry_q;
                        fetch_resp_last_iact_q      <= fetch_last_iact_w;
                        fetch_resp_last_seg_q       <= fetch_last_seg_w;
                    end
                end

                // pop queue into S2 when S2 is free
                if (queue_pop_w) begin
                    s2_valid_q      <= 1'b1;
                    s2_iact_value_q <= q0_value_q;
                    s2_iact_row_q   <= q0_row_q;
                    s2_iact_seg_q   <= q0_seg_q;
                end

                // start a new active task only when the previous task has fully drained
                if (s2_valid_q && !active_task_valid_q && !s3_delay_q && !s3_pending_q && !s4_valid_q && !s5_valid_q && !s6_valid_q) begin
                    if (weight_col_begin_w == weight_col_end_w) begin
                        s2_valid_q <= 1'b0;
                    end else begin
                        active_task_valid_q <= 1'b1;
                        active_iact_value_q <= s2_iact_value_q;
                        active_iact_row_q   <= s2_iact_row_q;
                        active_iact_seg_q   <= s2_iact_seg_q;
                        weight_word_ptr_q   <= weight_col_begin_w;
                        weight_word_end_q   <= weight_col_end_w;
                        weight_row_base_q   <= {PSUM_ADDR_W{1'b0}};
                        weight_first_word_q <= 1'b1;
                        weight_issue_done_q <= 1'b0;
                        s2_valid_q          <= 1'b0;
                    end
                end

                // issue next weight word of the active task
                if (issue_weight_word_w) begin
                    weight_data_read_en_q       <= 1'b1;
                    weight_data_read_word_idx_q <= weight_word_ptr_q;
                    s3_delay_q                  <= 1'b1;
                    s3_iact_value_q             <= active_iact_value_q;
                    s3_iact_seg_q               <= active_iact_seg_q;
                    s3_weight_row_base_q        <= issue_row_base_w;
                    s3_weight_first_word_q      <= issue_first_word_w;
                    s3_weight_word_ptr_q        <= weight_word_ptr_q;
                    s3_weight_word_end_q        <= weight_word_end_q;

                    if (issue_this_is_last_w) begin
                        weight_issue_done_q <= 1'b1;  
                    end else begin
                        weight_word_ptr_q  <= weight_issue_ptr_plus1_w;
                    end
                end

                if (s3_delay_q) begin
                    s3_pending_q <= 1'b1;
                    s3_delay_q   <= 1'b0;
                end
                
                if (run_drained_w) begin
                    mode_q    <= MODE_IDLE;
                    cal_fin_q <= 1'b1;
                end

                // task finishes only after final writeback retires
                if (s6_valid_q && s6_last_weight_word_q) begin
                    active_task_valid_q <= 1'b0;
                    weight_issue_done_q <= 1'b0;
                end
            end
            // increase merge_idx
            MODE_MERGE: begin
                psum_rd_en0_q   <= 1'b1;
                // Keep read address aligned with the next handshake beat after prefetch.
                psum_rd_addr0_q <= merge_idx_q
                                 + (((psum_in_valid && psum_out_ready) && (merge_idx_q != PSUM_DEPTH))
                                    ? {{(PSUM_ADDR_W-1){1'b0}},1'b1}
                                    : {PSUM_ADDR_W{1'b0}});
                if (psum_in_valid && psum_out_ready) begin
                    if (merge_idx_q == PSUM_DEPTH) begin
                        psum_acc_fin_q   <= 1'b1;
                        mode_q           <= MODE_IDLE;
                        merge_req_pending_q <= 1'b0;
                    end else begin
                        merge_idx_q <= merge_idx_q + {{(PSUM_ADDR_W-1){1'b0}},1'b1};
                    end
                end
            end

            MODE_POOL: begin
                if (pool_cmp_stop && !pool_out_valid_q)
                    mode_q <= MODE_IDLE;
            end

            default: begin
                mode_q <= MODE_IDLE;
            end
        endcase

        // 2-entry queue update, after push/pop decisions are known
        case ({front_push_req_w, queue_pop_w})
            2'b00: begin
                // no-op
            end
            2'b01: begin
                if (q1_valid_q) begin
                    q0_valid_q <= 1'b1;
                    q0_value_q <= q1_value_q;
                    q0_row_q   <= q1_row_q;
                    q0_seg_q   <= q1_seg_q;
                    q1_valid_q <= 1'b0;
                end else begin
                    q0_valid_q <= 1'b0;
                end
            end
            2'b10: begin
                if (!q0_valid_q) begin
                    q0_valid_q <= 1'b1;
                    q0_value_q <= front_push_value_w;
                    q0_row_q   <= front_push_row_w;
                    q0_seg_q   <= front_push_seg_w;
                end else begin
                    q1_valid_q <= 1'b1;
                    q1_value_q <= front_push_value_w;
                    q1_row_q   <= front_push_row_w;
                    q1_seg_q   <= front_push_seg_w;
                end
            end
            2'b11: begin
                if (q1_valid_q) begin
                    q0_valid_q <= 1'b1;
                    q0_value_q <= q1_value_q;
                    q0_row_q   <= q1_row_q;
                    q0_seg_q   <= q1_seg_q;
                    q1_valid_q <= 1'b1;
                    q1_value_q <= front_push_value_w;
                    q1_row_q   <= front_push_row_w;
                    q1_seg_q   <= front_push_seg_w;
                end else begin
                    q0_valid_q <= 1'b1;
                    q0_value_q <= front_push_value_w;
                    q0_row_q   <= front_push_row_w;
                    q0_seg_q   <= front_push_seg_w;
                    q1_valid_q <= 1'b0;
                end
            end
        endcase
    end
end
endmodule