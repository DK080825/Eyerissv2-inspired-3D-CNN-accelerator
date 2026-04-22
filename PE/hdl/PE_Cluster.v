
module PE_Cluster(
    input                       clock,
    input                       reset,
    // iact signals: from 4 routers, each iact is 13b
    input       [3:0]           iact_addr_in_valid,
    input       [31:0]          iact_addr_in_bits,
    output      [3:0]           iact_addr_in_ready,
    input       [3:0]           iact_data_in_valid,
    input       [51:0]          iact_data_in_bits,
    output      [3:0]           iact_data_in_ready,
    // weight signals: from 4 weight routers, each is 24b
    input       [15:0]          weight_addr_in_valid,
    input       [111:0]         weight_addr_in_bits,
    input       [15:0]          weight_data_in_valid,
    input       [191:0]         weight_data_in_bits,

    // Psums from routers
    input       [3:0]           psum_in_valid,
    input signed [83:0]         psum_in,
    output      [3:0]           psum_in_ready,
    input       [3:0]           psum_out_ready,
    output      [3:0]           psum_out_valid,
    output signed [83:0]        psum_out,
    
    // Psums from south Cluster
    input       [3:0]           psum_in_from_south_valid,
    input signed [83:0]         psum_in_from_south,
    output      [3:0]           psum_in_from_south_ready,

    // Controler signals
    input       [15:0]          pe_disable,
    input                       psum_load_en,
    input                       iact_data_in_sel,
    input       [1:0]           iact_data_out_sel,
    input                       psum_data_in_sel,
    input                       do_en,
    input                       iact_write_fin_clear,
    input                       weight_write_fin_clear,
    output                      all_write_fin,
    output                      all_cal_fin,
    input       [4:0]           PSUM_DEPTH,
    input                       psum_spad_clear,

    input       [15:0]          pool_cmp_en,
    input       [15:0]          pool_cmp_stop,
    input       [15:0]          pool_elem_in_valid,
    output      [15:0]          pool_elem_in_ready,
    input signed [127:0]        pool_elem_in,
    input       [15:0]          pool_win_first,
    input       [15:0]          pool_win_last,
    output      [15:0]          pool_out_valid,
    input       [15:0]          pool_out_ready,
    output signed [127:0]       pool_out
);

localparam integer CLUSTER_ROWS = 4;
localparam integer CLUSTER_COLS = 4;
localparam integer PE_COUNT     = 16;
localparam integer PSUM_W       = 21;
localparam integer IACT_ADDR_W  = 8;
localparam integer IACT_DATA_W  = 13;
localparam integer WEIGHT_ADDR_W = 7;
localparam integer WEIGHT_DATA_W = 12;
localparam integer CORE_WEIGHT_DATA_W = 24;
localparam integer POOL_DATA_W  = 8;

localparam PSUM_FROM_SOUTH  = 1'b0;
localparam PSUM_FROM_ROUTER = 1'b1;

wire [PE_COUNT-1:0] pe_psum_in_ready_w;
wire [PE_COUNT-1:0] pe_psum_out_valid_w;
wire [PE_COUNT*PSUM_W-1:0] pe_psum_out_w;
wire [PE_COUNT-1:0] pe_iact_addr_valid_w;
wire [PE_COUNT*IACT_ADDR_W-1:0] pe_iact_addr_w;
wire [PE_COUNT-1:0] pe_iact_data_valid_w;
wire [PE_COUNT*IACT_DATA_W-1:0] pe_iact_data_w;
wire [PE_COUNT-1:0] pe_write_fin_w;
wire [PE_COUNT-1:0] pe_cal_fin_w;
wire [PE_COUNT-1:0] pe_psum_add_fin_w;
reg  [PE_COUNT-1:0] write_fin_reg;
reg  [PE_COUNT-1:0] cal_fin_reg;

assign all_write_fin = &write_fin_reg;
assign all_cal_fin   = &cal_fin_reg;

genvar lane_idx;
generate
    for (lane_idx = 0; lane_idx < CLUSTER_COLS; lane_idx = lane_idx + 1) begin : gen_ext_psum_lanes
        localparam integer TOP_IDX    = lane_idx;
        localparam integer BOTTOM_IDX = ((CLUSTER_ROWS-1) * CLUSTER_COLS) + lane_idx;

        assign psum_in_ready[lane_idx] = (psum_data_in_sel == PSUM_FROM_ROUTER) && pe_psum_in_ready_w[BOTTOM_IDX];
        assign psum_in_from_south_ready[lane_idx] = (psum_data_in_sel == PSUM_FROM_ROUTER) ? 1'b0 : pe_psum_in_ready_w[BOTTOM_IDX];

        // output externally for Top PEs only
        assign psum_out_valid[lane_idx] = pe_psum_out_valid_w[TOP_IDX];
        assign psum_out[(lane_idx*PSUM_W) +: PSUM_W] = pe_psum_out_w[(TOP_IDX*PSUM_W) +: PSUM_W];
    end
endgenerate

PE_Cluster_controller PE_Cluster_controller_inst (
    .iact_data_in_sel   (iact_data_in_sel),
    .iact_data_out_sel  (iact_data_out_sel),
    .iact_addr_in_ready (iact_addr_in_ready),
    .iact_addr_in_valid (iact_addr_in_valid),
    .iact_addr_in_bits  (iact_addr_in_bits),
    .iact_data_in_ready (iact_data_in_ready),
    .iact_data_in_valid (iact_data_in_valid),
    .iact_data_in_bits  (iact_data_in_bits),
    .iact_to_pe_addr_valid(pe_iact_addr_valid_w),
    .iact_to_pe_addr_bits (pe_iact_addr_w),
    .iact_to_pe_data_valid(pe_iact_data_valid_w),
    .iact_to_pe_data_bits (pe_iact_data_w)
);

genvar row_idx;
genvar col_idx;
generate
    for (row_idx = 0; row_idx < CLUSTER_ROWS; row_idx = row_idx + 1) begin : gen_rows
        for (col_idx = 0; col_idx < CLUSTER_COLS; col_idx = col_idx + 1) begin : gen_cols
            localparam integer PE_IDX = (row_idx * CLUSTER_COLS) + col_idx;
            localparam integer BELOW_IDX = ((row_idx + 1) * CLUSTER_COLS) + col_idx;
            localparam integer ABOVE_IDX = ((row_idx - 1) * CLUSTER_COLS) + col_idx;

            wire                       pe_psum_in_valid_w;
            wire signed [PSUM_W-1:0]   pe_psum_in_w;
            wire                       pe_psum_out_ready_w;

            // for top rows of PE
            if (row_idx == CLUSTER_ROWS-1) begin : gen_bottom_row
                assign pe_psum_in_valid_w = (psum_data_in_sel == PSUM_FROM_ROUTER)
                    ? psum_in_valid[col_idx]
                    : psum_in_from_south_valid[col_idx];
                assign pe_psum_in_w = (psum_data_in_sel == PSUM_FROM_ROUTER)
                    ? psum_in[(col_idx*PSUM_W) +: PSUM_W]
                    : psum_in_from_south[(col_idx*PSUM_W) +: PSUM_W];
            // for middle row of PE
            end else begin : gen_internal_in
                assign pe_psum_in_valid_w = pe_psum_out_valid_w[BELOW_IDX];
                assign pe_psum_in_w       = pe_psum_out_w[(BELOW_IDX*PSUM_W) +: PSUM_W];
            end
            // for top row of PEs
            if (row_idx == 0) begin : gen_top_row
                assign pe_psum_out_ready_w = psum_out_ready[col_idx];
            end else begin : gen_internal_out
                assign pe_psum_out_ready_w = pe_psum_in_ready_w[ABOVE_IDX];
            end

            Processing_Element pe_inst (
                .clock                  (clock),
                .reset                  (reset),
                .psum_in_ready          (pe_psum_in_ready_w[PE_IDX]),
                .psum_in_valid          (pe_psum_in_valid_w),
                .psum_in                (pe_psum_in_w),
                .psum_out_ready         (pe_psum_out_ready_w),
                .psum_out_valid         (pe_psum_out_valid_w[PE_IDX]),
                .psum_out               (pe_psum_out_w[(PE_IDX*PSUM_W) +: PSUM_W]),
                .iact_address_in_ready  (),
                .iact_address_in_valid  (pe_iact_addr_valid_w[PE_IDX]),
                .iact_address_in        (pe_iact_addr_w[(PE_IDX*IACT_ADDR_W) +: IACT_ADDR_W]),
                .iact_data_in_ready     (),
                .iact_data_in_valid     (pe_iact_data_valid_w[PE_IDX]),
                .iact_data_in           (pe_iact_data_w[(PE_IDX*IACT_DATA_W) +: IACT_DATA_W]),
                .weight_address_in_ready(),
                .weight_address_in_valid(weight_addr_in_valid[PE_IDX]),
                .weight_address_in      (weight_addr_in_bits[(PE_IDX*WEIGHT_ADDR_W) +: WEIGHT_ADDR_W]),
                .weight_data_in_ready   (),
                .weight_data_in_valid   (weight_data_in_valid[PE_IDX]),
                .weight_data_in         ({12'd0, weight_data_in_bits[(PE_IDX*WEIGHT_DATA_W) +: WEIGHT_DATA_W]}),
                .iact_address_write_fin (),
                .iact_data_write_fin    (),
                .weight_address_write_fin(),
                .weight_data_write_fin  (),
                .psum_add_fin           (pe_psum_add_fin_w[PE_IDX]),
                .psum_enq_en            (psum_load_en),
                .do_load_en             (do_en & ~cal_fin_reg[PE_IDX]),
                .cal_fin                (pe_cal_fin_w[PE_IDX]),
                .iact_write_fin_clear   (iact_write_fin_clear),
                .weight_write_fin_clear (weight_write_fin_clear),
                .all_write_fin          (pe_write_fin_w[PE_IDX]),
                .PSUM_DEPTH             (PSUM_DEPTH),
                .psum_spad_clear        (psum_spad_clear),
                .pool_cmp_en            (pool_cmp_en[PE_IDX]),
                .pool_cmp_stop          (pool_cmp_stop[PE_IDX]),
                .pool_elem_in_valid     (pool_elem_in_valid[PE_IDX]),
                .pool_elem_in_ready     (pool_elem_in_ready[PE_IDX]),
                .pool_elem_in           (pool_elem_in[(PE_IDX*POOL_DATA_W) +: POOL_DATA_W]),
                .pool_win_first         (pool_win_first[PE_IDX]),
                .pool_win_last          (pool_win_last[PE_IDX]),
                .pool_out_valid         (pool_out_valid[PE_IDX]),
                .pool_out_ready         (pool_out_ready[PE_IDX]),
                .pool_out               (pool_out[(PE_IDX*POOL_DATA_W) +: POOL_DATA_W])
            );
        end
    end
endgenerate

always @(posedge clock) begin
    if (reset)
        write_fin_reg <= {PE_COUNT{1'b0}};
    else if (all_cal_fin)
        write_fin_reg <= {PE_COUNT{1'b0}};
    else
        write_fin_reg <= write_fin_reg | pe_write_fin_w | pe_disable;
end

always @(posedge clock) begin
    if (reset)
        cal_fin_reg <= {PE_COUNT{1'b0}};
    else if (all_cal_fin)
        cal_fin_reg <= {PE_COUNT{1'b0}};
    else
        cal_fin_reg <= cal_fin_reg | pe_cal_fin_w | pe_disable;
end

endmodule
