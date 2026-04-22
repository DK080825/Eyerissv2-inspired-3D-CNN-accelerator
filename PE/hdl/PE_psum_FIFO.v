// ====================================================================================================== //
// PE psum FIFO
// Standard ready/valid FIFO
// For FPGA implementation, Vivado FIFO IP is still preferred for synthesis.
// ====================================================================================================== //

module PE_psum_FIFO #(
    parameter DATA_WIDTH   = 21,
    parameter BUFFER_DEPTH = 4
)(
    input                           clock,
    input                           reset,

    // input side
    output                          data_in_ready,
    input                           data_in_valid,
    input  signed [DATA_WIDTH-1:0]  data_in,

    // output side
    input                           data_out_ready,
    output                          data_out_valid,
    output signed [DATA_WIDTH-1:0]  data_out
);

localparam ADDR_WIDTH = (BUFFER_DEPTH <= 1) ? 1 : $clog2(BUFFER_DEPTH);

reg signed [DATA_WIDTH-1:0] buffer [0:BUFFER_DEPTH-1];
reg [ADDR_WIDTH-1:0] wr_ptr;
reg [ADDR_WIDTH-1:0] rd_ptr;
reg [ADDR_WIDTH:0]   fifo_count;

wire empty;
wire full;
wire write_fire;
wire read_fire;

assign empty = (fifo_count == 0);
assign full  = (fifo_count == BUFFER_DEPTH);

// upstream can write when FIFO is not full
assign data_in_ready = ~full;

// downstream sees valid when FIFO is not empty
assign data_out_valid = ~empty;

// front element of FIFO
assign data_out = buffer[rd_ptr];

// handshake events
assign write_fire = data_in_valid  && data_in_ready;
assign read_fire  = data_out_valid && data_out_ready;

integer i;
always @(posedge clock) begin
    if (reset) begin
        wr_ptr     <= {ADDR_WIDTH{1'b0}};
        rd_ptr     <= {ADDR_WIDTH{1'b0}};
        fifo_count <= {(ADDR_WIDTH+1){1'b0}};

        for (i = 0; i < BUFFER_DEPTH; i = i + 1) begin
            buffer[i] <= {DATA_WIDTH{1'b0}};
        end
    end
    else begin
        // write side
        if (write_fire) begin
            buffer[wr_ptr] <= data_in;

            if (wr_ptr == BUFFER_DEPTH-1)
                wr_ptr <= {ADDR_WIDTH{1'b0}};
            else
                wr_ptr <= wr_ptr + 1'b1;
        end

        // read side
        if (read_fire) begin
            if (rd_ptr == BUFFER_DEPTH-1)
                rd_ptr <= {ADDR_WIDTH{1'b0}};
            else
                rd_ptr <= rd_ptr + 1'b1;
        end

        // occupancy counter
        case ({write_fire, read_fire})
            2'b10: fifo_count <= fifo_count + 1'b1; // write only
            2'b01: fifo_count <= fifo_count - 1'b1; // read only
            default: fifo_count <= fifo_count;      // idle or simultaneous read+write
        endcase
    end
end

endmodule