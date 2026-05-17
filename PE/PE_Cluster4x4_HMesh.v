// ================================================================================================ //
// 4x4 PE cluster top with heterogeneous intra-cluster NoC:
// - iact:   flexible 4-router -> 16-PE fabric
// - weight: row-restricted 4-router -> 16-PE fabric
// - psum:   4 column-wise vertical reduction paths
// ================================================================================================ //

module PE_Cluster4x4_HMesh (
    input  wire                        clock,
    input  wire                        reset,

    // -------------------------------
    // Layer / NoC mode control
    // -------------------------------
    input  wire [1:0]                  layer_mode,
    input  wire [1:0]                  iact_router_prio,

    // -------------------------------
    // IACT routers (4)
    // -------------------------------
    input  wire [3:0]                  iact_addr_in_valid,
    output wire [3:0]                  iact_addr_in_ready,
    input  wire [31:0]                 iact_addr_in_bits,
    input  wire [63:0]                 iact_addr_dst_mask,

    input  wire [3:0]                  iact_data_in_valid,
    output wire [3:0]                  iact_data_in_ready,
    input  wire [51:0]                 iact_data_in_bits,
    input  wire [63:0]                 iact_data_dst_mask,

    // -------------------------------
    // WEIGHT routers (4 rows)
    // -------------------------------
    input  wire [3:0]                  weight_addr_in_valid,
    output wire [3:0]                  weight_addr_in_ready,
    input  wire [27:0]                 weight_addr_in_bits,
    input  wire [15:0]                 weight_addr_row_dst_mask,

    input  wire [3:0]                  weight_data_in_valid,
    output wire [3:0]                  weight_data_in_ready,
    input  wire [95:0]                 weight_data_in_bits,
    input  wire [15:0]                 weight_data_row_dst_mask,

    // -------------------------------
    // PSUM routers (4 columns)
    // -------------------------------
    // Select psum input source for the cluster:
    // 1'b1: take psums from the 4 local psum routers
    // 1'b0: take psums from the 4 south-facing lanes (south router/neighbor cluster)
    input  wire                        psum_col_in_sel,

    // From local psum routers (4 lanes)
    input  wire [3:0]                  psum_col_in_from_router_valid,
    output wire [3:0]                  psum_col_in_from_router_ready,
    input  wire signed [83:0]          psum_col_in_from_router_data,

    // From south router lanes / south neighbor (4 lanes)
    input  wire [3:0]                  psum_col_in_from_south_valid,
    output wire [3:0]                  psum_col_in_from_south_ready,
    input  wire signed [83:0]          psum_col_in_from_south_data,

    output wire [3:0]                  psum_col_out_valid,
    input  wire [3:0]                  psum_col_out_ready,
    output wire signed [83:0]          psum_col_out_data,

    // -------------------------------
    // Cluster PE controls
    // -------------------------------
    input  wire [15:0]                 pe_disable,
    input  wire                        psum_enq_en,
    input  wire                        do_load_en,
    input  wire                        iact_write_fin_clear,
    input  wire                        weight_write_fin_clear,
    input  wire [4:0]                  PSUM_DEPTH,
    input  wire                        psum_spad_clear,
    output wire                        all_write_fin,
    output wire                        all_cal_fin,

    // Optional pool controls per PE (pass-through)
    input  wire [15:0]                 pool_cmp_en,
    input  wire [15:0]                 pool_cmp_stop,
    input  wire [15:0]                 pool_elem_in_valid,
    output wire [15:0]                 pool_elem_in_ready,
    input  wire signed [127:0]         pool_elem_in,
    input  wire [15:0]                 pool_win_first,
    input  wire [15:0]                 pool_win_last,
    output wire [15:0]                 pool_out_valid,
    input  wire [15:0]                 pool_out_ready,
    output wire signed [127:0]         pool_out
);
    localparam integer PE_COUNT       = 16;
    localparam integer IACT_ADDR_W    = 8;
    localparam integer IACT_DATA_W    = 13;
    localparam integer WEIGHT_ADDR_W  = 7;
    localparam integer WEIGHT_DATA_W  = 24;
    localparam integer PSUM_W         = 21;
    localparam integer POOL_W         = 8;

    // -------------------------------
    // PE-side iact buses
    // -------------------------------
    wire [15:0]               pe_iact_addr_valid;
    wire [15:0]               pe_iact_addr_ready;
    wire [16*IACT_ADDR_W-1:0] pe_iact_addr_bits;

    wire [15:0]               pe_iact_data_valid;
    wire [15:0]               pe_iact_data_ready;
    wire [16*IACT_DATA_W-1:0] pe_iact_data_bits;

    // -------------------------------
    // PE-side weight buses
    // -------------------------------
    wire [15:0]                 pe_weight_addr_valid;
    wire [15:0]                 pe_weight_addr_ready;
    wire [16*WEIGHT_ADDR_W-1:0] pe_weight_addr_bits;

    wire [15:0]                 pe_weight_data_valid;
    wire [15:0]                 pe_weight_data_ready;
    wire [16*WEIGHT_DATA_W-1:0] pe_weight_data_bits;

    // -------------------------------
    // PE-side psum buses
    // -------------------------------
    wire [15:0]                pe_psum_in_valid;
    wire [15:0]                pe_psum_in_ready;
    wire signed [16*PSUM_W-1:0] pe_psum_in_data;
    wire [15:0]                pe_psum_out_valid;
    wire [15:0]                pe_psum_out_ready;
    wire signed [16*PSUM_W-1:0] pe_psum_out_data;

    // -------------------------------
    // PSUM input selection mux/demux
    // -------------------------------
    wire [3:0]         psum_col_in_valid;
    wire [3:0]         psum_col_in_ready;
    wire signed [83:0] psum_col_in_data;

    assign psum_col_in_valid = (psum_col_in_sel)
        ? psum_col_in_from_router_valid
        : psum_col_in_from_south_valid;

    assign psum_col_in_data  = (psum_col_in_sel)
        ? psum_col_in_from_router_data
        : psum_col_in_from_south_data;

    // Route ready back only to the selected source.
    assign psum_col_in_from_router_ready = (psum_col_in_sel) ? psum_col_in_ready : 4'b0;
    assign psum_col_in_from_south_ready  = (psum_col_in_sel) ? 4'b0 : psum_col_in_ready;

    // -------------------------------
    // PE finish signals
    // -------------------------------
    wire [15:0] pe_write_fin_w;
    wire [15:0] pe_cal_fin_w;
    reg  [15:0] write_fin_reg;
    reg  [15:0] cal_fin_reg;

    assign all_write_fin = &write_fin_reg;
    assign all_cal_fin   = &cal_fin_reg;

    // IACT addr uses same fabric as iact data but DATA_W = 8.
    PE4x4_IACT_Fabric #(
        .DATA_W(IACT_ADDR_W)
    ) u_iact_addr_fabric (
        .clk         (clock),
        .rst_n       (~reset),
        .router_prio (iact_router_prio),
        .in_valid    (iact_addr_in_valid),
        .in_ready    (iact_addr_in_ready),
        .in_data     (iact_addr_in_bits),
        .in_dst_mask (iact_addr_dst_mask),
        .pe_valid    (pe_iact_addr_valid),
        .pe_ready    (pe_iact_addr_ready),
        .pe_data     (pe_iact_addr_bits)
    );

    PE4x4_IACT_Fabric #(
        .DATA_W(IACT_DATA_W)
    ) u_iact_data_fabric (
        .clk         (clock),
        .rst_n       (~reset),
        .router_prio (iact_router_prio),
        .in_valid    (iact_data_in_valid),
        .in_ready    (iact_data_in_ready),
        .in_data     (iact_data_in_bits),
        .in_dst_mask (iact_data_dst_mask),
        .pe_valid    (pe_iact_data_valid),
        .pe_ready    (pe_iact_data_ready),
        .pe_data     (pe_iact_data_bits)
    );

    PE4x4_WEIGHT_RowFabric #(
        .DATA_W(WEIGHT_ADDR_W)
    ) u_weight_addr_fabric (
        .in_valid     (weight_addr_in_valid),
        .in_ready     (weight_addr_in_ready),
        .in_data      (weight_addr_in_bits),
        .row_dst_mask (weight_addr_row_dst_mask),
        .pe_valid     (pe_weight_addr_valid),
        .pe_ready     (pe_weight_addr_ready),
        .pe_data      (pe_weight_addr_bits)
    );

    PE4x4_WEIGHT_RowFabric #(
        .DATA_W(WEIGHT_DATA_W)
    ) u_weight_data_fabric (
        .in_valid     (weight_data_in_valid),
        .in_ready     (weight_data_in_ready),
        .in_data      (weight_data_in_bits),
        .row_dst_mask (weight_data_row_dst_mask),
        .pe_valid     (pe_weight_data_valid),
        .pe_ready     (pe_weight_data_ready),
        .pe_data      (pe_weight_data_bits)
    );

    PE4x4_PSUM_ColumnReduce #(
        .DATA_W(PSUM_W)
    ) u_psum_column_reduce (
        .col_in_valid      (psum_col_in_valid),
        .col_in_ready      (psum_col_in_ready),
        .col_in_data       (psum_col_in_data),
        .col_out_valid     (psum_col_out_valid),
        .col_out_ready     (psum_col_out_ready),
        .col_out_data      (psum_col_out_data),
        .pe_psum_in_valid  (pe_psum_in_valid),
        .pe_psum_in_ready  (pe_psum_in_ready),
        .pe_psum_in_data   (pe_psum_in_data),
        .pe_psum_out_valid (pe_psum_out_valid),
        .pe_psum_out_ready (pe_psum_out_ready),
        .pe_psum_out_data  (pe_psum_out_data)
    );

    genvar pe_idx;
    generate
        for (pe_idx = 0; pe_idx < PE_COUNT; pe_idx = pe_idx + 1) begin : gen_pe
            Processing_Element pe_inst (
                .clock                  (clock),
                .reset                  (reset),
                .psum_in_ready          (pe_psum_in_ready[pe_idx]),
                .psum_in_valid          (pe_psum_in_valid[pe_idx]),
                .psum_in                (pe_psum_in_data[(pe_idx*PSUM_W) +: PSUM_W]),
                .psum_out_ready         (pe_psum_out_ready[pe_idx]),
                .psum_out_valid         (pe_psum_out_valid[pe_idx]),
                .psum_out               (pe_psum_out_data[(pe_idx*PSUM_W) +: PSUM_W]),

                .iact_address_in_ready  (pe_iact_addr_ready[pe_idx]),
                .iact_address_in_valid  (pe_iact_addr_valid[pe_idx]),
                .iact_address_in        (pe_iact_addr_bits[(pe_idx*IACT_ADDR_W) +: IACT_ADDR_W]),
                .iact_data_in_ready     (pe_iact_data_ready[pe_idx]),
                .iact_data_in_valid     (pe_iact_data_valid[pe_idx]),
                .iact_data_in           (pe_iact_data_bits[(pe_idx*IACT_DATA_W) +: IACT_DATA_W]),

                .weight_address_in_ready(pe_weight_addr_ready[pe_idx]),
                .weight_address_in_valid(pe_weight_addr_valid[pe_idx]),
                .weight_address_in      (pe_weight_addr_bits[(pe_idx*WEIGHT_ADDR_W) +: WEIGHT_ADDR_W]),
                .weight_data_in_ready   (pe_weight_data_ready[pe_idx]),
                .weight_data_in_valid   (pe_weight_data_valid[pe_idx]),
                .weight_data_in         (pe_weight_data_bits[(pe_idx*WEIGHT_DATA_W) +: WEIGHT_DATA_W]),

                .iact_address_write_fin (),
                .iact_data_write_fin    (),
                .weight_address_write_fin(),
                .weight_data_write_fin  (),
                .psum_add_fin           (),

                .psum_enq_en            (psum_enq_en),
                .do_load_en             (do_load_en & ~cal_fin_reg[pe_idx]),
                .cal_fin                (pe_cal_fin_w[pe_idx]),
                .iact_write_fin_clear   (iact_write_fin_clear),
                .weight_write_fin_clear (weight_write_fin_clear),
                .all_write_fin          (pe_write_fin_w[pe_idx]),
                .PSUM_DEPTH             (PSUM_DEPTH),
                .psum_spad_clear        (psum_spad_clear),

                .pool_cmp_en            (pool_cmp_en[pe_idx]),
                .pool_cmp_stop          (pool_cmp_stop[pe_idx]),
                .pool_elem_in_valid     (pool_elem_in_valid[pe_idx]),
                .pool_elem_in_ready     (pool_elem_in_ready[pe_idx]),
                .pool_elem_in           (pool_elem_in[(pe_idx*POOL_W) +: POOL_W]),
                .pool_win_first         (pool_win_first[pe_idx]),
                .pool_win_last          (pool_win_last[pe_idx]),
                .pool_out_valid         (pool_out_valid[pe_idx]),
                .pool_out_ready         (pool_out_ready[pe_idx]),
                .pool_out               (pool_out[(pe_idx*POOL_W) +: POOL_W])
            );
        end
    endgenerate

    always @(posedge clock) begin
        if (reset)
            write_fin_reg <= 16'b0;
        else if (all_cal_fin)
            write_fin_reg <= 16'b0;
        else
            write_fin_reg <= write_fin_reg | pe_write_fin_w | pe_disable;
    end

    always @(posedge clock) begin
        if (reset)
            cal_fin_reg <= 16'b0;
        else if (all_cal_fin)
            cal_fin_reg <= 16'b0;
        else
            cal_fin_reg <= cal_fin_reg | pe_cal_fin_w | pe_disable;
    end

    // layer_mode currently consumed by software/runtime mapping and mask programming.
    wire _unused_mode_keep = layer_mode[0] ^ layer_mode[1];

endmodule

