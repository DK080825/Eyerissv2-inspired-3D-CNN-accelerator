// ============================================================================
// Module      : Weight_Data_Spad
// Author      : Do Quoc Khanh
// Description : Local Weight data storage inside one PE.
//               Each 24-bit word stores two 12-bit count/value entries.
//               The PE core reads one packed word and uses the non-zero
//               entries for MAC. The memory is written during Weight load.
// ============================================================================

module Weight_Data_Spad
#(
    parameter integer SPAD_DEPTH        = 96,
    parameter integer WEIGHT_PACKED_W   = 24,   // two 12b data packed in one 24b word
    parameter integer WEIGHT_WORD_PTR_W = $clog2(SPAD_DEPTH),
    parameter integer WEIGHT_COUNT_W    = 4,
    parameter integer WEIGHT_VALUE_W    = 8
)
(
    input  wire                         clk,
    input  wire                         rst,
    // Fabric -> SPAD: packed Weight data word.
    output wire                         data_in_ready,
    input  wire                         data_in_valid,
    input  wire [WEIGHT_PACKED_W-1:0]   data_in,
    // SPAD -> PE core: two unpacked Weight entries.
    output wire [WEIGHT_VALUE_W-1:0]    lane0_value,
    output wire [WEIGHT_COUNT_W-1:0]    lane0_count,
    output wire [WEIGHT_VALUE_W-1:0]    lane1_value,
    output wire [WEIGHT_COUNT_W-1:0]    lane1_count,
    // PE core -> SPAD: load and read control.
    input  wire                         write_en,
    output wire                         write_fin,
    input  wire                         read_en,
    input  wire [WEIGHT_WORD_PTR_W-1:0] read_word_idx,
    output wire                         lane0_valid,
    output wire                         lane1_valid
);

// ================================================ //
//                    Parameters                    //
// ================================================ //
// ================================================ //
//                    Registers                     //
// ================================================ //
(* ram_style = "block", ramstyle = "M10K" *)
reg [WEIGHT_PACKED_W-1:0] mem [0:SPAD_DEPTH-1];

reg [WEIGHT_WORD_PTR_W-1:0] spad_write_addr;
reg                         rd_fire_d;
reg [WEIGHT_PACKED_W-1:0]   mem_data_out;

// packed lane split
wire [WEIGHT_VALUE_W+WEIGHT_COUNT_W-1:0] lane0_packed;
wire [WEIGHT_VALUE_W+WEIGHT_COUNT_W-1:0] lane1_packed;

wire data_in_shake;
wire rd_fire;

// ================================================ //
//                 Basic handshake                  //
// ================================================ //
assign data_in_ready = (rst == 1'b0);
assign data_in_shake = (data_in_ready == 1'b1) && (data_in_valid == 1'b1) && (write_en == 1'b1);

// write finished when sentinel 0 word is written
assign write_fin = (data_in == {WEIGHT_PACKED_W{1'b0}}) && (data_in_shake == 1'b1);

// If a write happens this cycle, the read side waits.
assign rd_fire = (read_en == 1'b1) && (data_in_shake == 1'b0);

// ================================================ //
//              Memory / pointer control            //
// ================================================ //
always @(posedge clk) begin
    if (rst) begin
        spad_write_addr <= {WEIGHT_WORD_PTR_W{1'b0}};
        rd_fire_d       <= 1'b0;
        mem_data_out    <= {WEIGHT_PACKED_W{1'b0}};
    end
    else begin
        // Store incoming Weight word.
        if (data_in_shake) begin
            mem[spad_write_addr] <= data_in;

            if (write_fin) begin
                spad_write_addr <= {WEIGHT_WORD_PTR_W{1'b0}};
            end
            else begin
                spad_write_addr <= spad_write_addr + {{(WEIGHT_WORD_PTR_W-1){1'b0}}, 1'b1};
            end
        end

        // Read one Weight word with one-cycle registered output.
        if (rd_fire) begin
            mem_data_out <= mem[read_word_idx];
        end
        else begin
            mem_data_out <= {WEIGHT_PACKED_W{1'b0}};
        end

        // Read-valid delayed by one cycle.
        rd_fire_d <= rd_fire;
    end
end

// ================================================ //
//                   Output unpack                  //
// ================================================ //
// Weight word packing:
//   lane0 = data_out[11:0]  = {value[11:4], count[3:0]}
//   lane1 = data_out[23:12] = {value[11:4], count[3:0]}
assign lane0_packed = mem_data_out[WEIGHT_VALUE_W+WEIGHT_COUNT_W-1:0];
assign lane1_packed = mem_data_out[2*(WEIGHT_VALUE_W+WEIGHT_COUNT_W)-1 : (WEIGHT_VALUE_W+WEIGHT_COUNT_W)];

assign lane0_count = lane0_packed[WEIGHT_COUNT_W-1:0];
assign lane0_value = lane0_packed[WEIGHT_VALUE_W+WEIGHT_COUNT_W-1 : WEIGHT_COUNT_W];

assign lane1_count = lane1_packed[WEIGHT_COUNT_W-1:0];
assign lane1_value = lane1_packed[WEIGHT_VALUE_W+WEIGHT_COUNT_W-1 : WEIGHT_COUNT_W];

// Valid in the cycle after a read request.
// A lane is invalid if its value field is zero.
assign lane0_valid = (rd_fire_d == 1'b1) && (lane0_value != {WEIGHT_VALUE_W{1'b0}});
assign lane1_valid = (rd_fire_d == 1'b1) && (lane1_value != {WEIGHT_VALUE_W{1'b0}});

endmodule
