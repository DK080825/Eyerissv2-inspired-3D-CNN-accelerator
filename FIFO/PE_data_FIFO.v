// ============================================================================
// Module      : PE_data_FIFO
// Author      : Do Quoc Khanh
// Description : Small ready/valid FIFO for PE address/data streams.
//               It keeps incoming data until the PE side can consume it.
//               The FIFO is used between the local fabric and one PE.
// ============================================================================

module PE_data_FIFO #(
    parameter DATA_IN_WIDTH = 4,
    parameter BUFFER_DEPTH  = 4
)(
    input  wire                     clk,
    input  wire                     rst,

    // Source -> FIFO.
    output wire                     data_in_ready,
    input  wire                     data_in_valid,
    input  wire [DATA_IN_WIDTH-1:0] data_in,

    // FIFO -> PE.
    input  wire                     data_out_ready,
    output wire                     data_out_valid,
    output wire [DATA_IN_WIDTH-1:0] data_out
);

localparam ADDR_WIDTH = (BUFFER_DEPTH <= 1) ? 1 : $clog2(BUFFER_DEPTH);

reg [DATA_IN_WIDTH-1:0] buffer_r [0:BUFFER_DEPTH-1];
reg [ADDR_WIDTH-1:0]    wr_ptr_r;
reg [ADDR_WIDTH-1:0]    rd_ptr_r;
reg [ADDR_WIDTH:0]      fifo_count_r;

wire empty_w;
wire full_w;
wire write_fire_w;
wire read_fire_w;

assign empty_w = (fifo_count_r == 0);
assign full_w  = (fifo_count_r == BUFFER_DEPTH);

// Source can write when FIFO is not full.
assign data_in_ready = ~full_w;

// PE can read when FIFO is not empty.
assign data_out_valid = ~empty_w;

// Current front element.
assign data_out = buffer_r[rd_ptr_r];

// Transfer events.
assign write_fire_w = data_in_valid  && data_in_ready;
assign read_fire_w  = data_out_valid && data_out_ready;

integer i;
always @(posedge clk) begin
    if (rst) begin
        wr_ptr_r     <= {ADDR_WIDTH{1'b0}};
        rd_ptr_r     <= {ADDR_WIDTH{1'b0}};
        fifo_count_r <= {(ADDR_WIDTH+1){1'b0}};
        for (i = 0; i < BUFFER_DEPTH; i = i + 1) begin
            buffer_r[i] <= {DATA_IN_WIDTH{1'b0}};
        end
    end
    else begin
        // Store one input word.
        if (write_fire_w) begin
            buffer_r[wr_ptr_r] <= data_in;
            if (wr_ptr_r == BUFFER_DEPTH-1)
                wr_ptr_r <= {ADDR_WIDTH{1'b0}};
            else
                wr_ptr_r <= wr_ptr_r + 1'b1;
        end

        // Remove one output word.
        if (read_fire_w) begin
            if (rd_ptr_r == BUFFER_DEPTH-1)
                rd_ptr_r <= {ADDR_WIDTH{1'b0}};
            else
                rd_ptr_r <= rd_ptr_r + 1'b1;
        end

        // Track how many words are stored.
        case ({write_fire_w, read_fire_w})
            2'b10: fifo_count_r <= fifo_count_r + 1'b1; // write only
            2'b01: fifo_count_r <= fifo_count_r - 1'b1; // read only
            default: fifo_count_r <= fifo_count_r;      // same cycle read+write or idle
        endcase
    end
end

endmodule
