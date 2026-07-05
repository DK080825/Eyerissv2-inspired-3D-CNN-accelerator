// ============================================================================
// Module      : PE_psum_FIFO
// Author      : Do Quoc Khanh
// Description : Small ready/valid FIFO for signed PSUM streams.
//               It keeps PSUM data until the next side can accept it.
//               The FIFO is used on PE PSUM input and output paths.
// ============================================================================

module PE_psum_FIFO #(
    parameter DATA_WIDTH   = 21,
    parameter BUFFER_DEPTH = 4
)(
    input  wire                     clk,
    input  wire                     rst,

    // Source -> FIFO.
    output wire                     data_in_ready,
    input  wire                     data_in_valid,
    input  wire signed [DATA_WIDTH-1:0] data_in,

    // FIFO -> destination.
    input  wire                     data_out_ready,
    output wire                     data_out_valid,
    output wire signed [DATA_WIDTH-1:0] data_out
);

localparam ADDR_WIDTH = (BUFFER_DEPTH <= 1) ? 1 : $clog2(BUFFER_DEPTH);

reg signed [DATA_WIDTH-1:0] buffer_r [0:BUFFER_DEPTH-1];
reg [ADDR_WIDTH-1:0]          wr_ptr_r;
reg [ADDR_WIDTH-1:0]          rd_ptr_r;
reg [ADDR_WIDTH:0]            fifo_count_r;

wire empty_w;
wire full_w;
wire write_fire_w;
wire read_fire_w;

assign empty_w = (fifo_count_r == 0);
assign full_w  = (fifo_count_r == BUFFER_DEPTH);

// Source can write when FIFO is not full.
assign data_in_ready = ~full_w;

// Destination sees valid when FIFO is not empty.
assign data_out_valid = ~empty_w;

// Current front element.
assign data_out = buffer_r[rd_ptr_r];

// Transfer events.
assign write_fire_w = data_in_valid  && data_in_ready;
assign read_fire_w  = data_out_valid && data_out_ready;

always @(posedge clk) begin
    if (rst) begin
        wr_ptr_r     <= {ADDR_WIDTH{1'b0}};
        rd_ptr_r     <= {ADDR_WIDTH{1'b0}};
        fifo_count_r <= {(ADDR_WIDTH+1){1'b0}};

    end
    else begin
        // Store one input PSUM.
        if (write_fire_w) begin
            buffer_r[wr_ptr_r] <= data_in;

            if (wr_ptr_r == BUFFER_DEPTH-1)
                wr_ptr_r <= {ADDR_WIDTH{1'b0}};
            else
                wr_ptr_r <= wr_ptr_r + 1'b1;
        end

        // Remove one output PSUM.
        if (read_fire_w) begin
            if (rd_ptr_r == BUFFER_DEPTH-1)
                rd_ptr_r <= {ADDR_WIDTH{1'b0}};
            else
                rd_ptr_r <= rd_ptr_r + 1'b1;
        end

        // Track how many PSUM words are stored.
        case ({write_fire_w, read_fire_w})
            2'b10: fifo_count_r <= fifo_count_r + 1'b1; // write only
            2'b01: fifo_count_r <= fifo_count_r - 1'b1; // read only
            default: fifo_count_r <= fifo_count_r;      // idle or simultaneous read+write
        endcase
    end
end

endmodule
