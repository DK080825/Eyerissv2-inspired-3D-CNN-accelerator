// ====================================================================================================== //
// PE controller
// - Keep pending requests while PE is busy
// - LOAD has higher priority than PSUM_ENQ
// - MERGE waits for psum accumulator completion
// ====================================================================================================== //

module Processing_Element_Controller (
    input  wire clk,
    input  wire rst,

    input  wire top_psum_enq_en_in,
    input  wire top_do_load_en_in,
    input  wire core_ctrl_status_cal_fin_in,
    input  wire core_ctrl_status_psum_acc_fin_in,
    input  wire top_all_write_fin_in,

    output wire cluster_ctrl_mac_en_out,
    output wire cluster_ctrl_psum_enq_en_out,
    output wire cluster_ctrl_load_en_out,
    output wire top_cal_fin_out
);

// ================================================ //
//                     Parameters                   //
// ================================================ //
localparam [1:0] IDLE  = 2'b00;
localparam [1:0] LOAD  = 2'b01;
localparam [1:0] CAL   = 2'b10;
localparam [1:0] MERGE = 2'b11;

// ================================================ //
//                 Registers & Wires                //
// ================================================ //
reg [1:0] pe_state_r, pe_state_next_w;

reg load_req_pending_r;
reg psum_req_pending_r;
reg top_do_load_en_d_r;
reg top_psum_enq_en_d_r;
reg cluster_ctrl_mac_en_r;
reg cluster_ctrl_psum_enq_en_r;
reg cal_done_seen_r;

wire new_load_req_w;
wire new_psum_req_w;
wire load_req_seen_w;
wire psum_req_seen_w;
wire accept_load_req_w;
wire accept_psum_req_w;

// ================================================ //
//                   Combinational                  //
// ================================================ //
assign new_load_req_w = top_do_load_en_in & ~top_do_load_en_d_r;
assign new_psum_req_w = top_psum_enq_en_in & ~top_psum_enq_en_d_r;

assign load_req_seen_w = load_req_pending_r | new_load_req_w;
assign psum_req_seen_w = psum_req_pending_r | new_psum_req_w;

assign accept_load_req_w = (pe_state_r == IDLE) && load_req_seen_w;
assign accept_psum_req_w = (pe_state_r == IDLE) && !load_req_seen_w && psum_req_seen_w;

assign cluster_ctrl_mac_en_out      = cluster_ctrl_mac_en_r;
assign cluster_ctrl_psum_enq_en_out = cluster_ctrl_psum_enq_en_r;
assign cluster_ctrl_load_en_out     = (pe_state_r == LOAD) || ((pe_state_r == CAL) && !top_all_write_fin_in);
assign top_cal_fin_out              = (pe_state_r == CAL) && top_all_write_fin_in && cal_done_seen_r;

// next-state logic
always @(*) begin
    case (pe_state_r)
        IDLE: begin
            if (accept_load_req_w)
                pe_state_next_w = LOAD;
            else if (accept_psum_req_w)
                pe_state_next_w = MERGE;
            else
                pe_state_next_w = IDLE;
        end

        LOAD: begin
            pe_state_next_w = CAL;
        end

        CAL: begin
            if (top_all_write_fin_in && cal_done_seen_r)
                pe_state_next_w = IDLE;
            else
                pe_state_next_w = CAL;
        end

        MERGE: begin
            if (core_ctrl_status_psum_acc_fin_in)
                pe_state_next_w = IDLE;
            else
                pe_state_next_w = MERGE;
        end

        default: begin
            pe_state_next_w = IDLE;
        end
    endcase
end

// ================================================ //
//                     Sequential                   //
// ================================================ //
always @(posedge clk) begin
    if (rst) begin
        pe_state_r              <= IDLE;
        load_req_pending_r      <= 1'b0;
        psum_req_pending_r      <= 1'b0;
        top_do_load_en_d_r      <= 1'b0;
        top_psum_enq_en_d_r     <= 1'b0;
        cluster_ctrl_mac_en_r   <= 1'b0;
        cluster_ctrl_psum_enq_en_r <= 1'b0;
        cal_done_seen_r         <= 1'b0;
    end else begin
        pe_state_r <= pe_state_next_w;
        cluster_ctrl_mac_en_r <= accept_load_req_w;
        cluster_ctrl_psum_enq_en_r <= accept_psum_req_w;

        if (pe_state_r != CAL)
            cal_done_seen_r <= 1'b0;
        else if (core_ctrl_status_cal_fin_in)
            cal_done_seen_r <= 1'b1;

        top_do_load_en_d_r  <= top_do_load_en_in;
        top_psum_enq_en_d_r <= top_psum_enq_en_in;
        load_req_pending_r <= (load_req_pending_r | new_load_req_w) & ~accept_load_req_w;
        psum_req_pending_r <= (psum_req_pending_r | new_psum_req_w) & ~accept_psum_req_w;
    end
end

endmodule