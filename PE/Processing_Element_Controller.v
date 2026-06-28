// ============================================================================
// Module      : Processing_Element_Controller
// Author      : Do Quoc Khanh
// Description : Local PE controller for PSUM merge request tracking.
//               Captures a top-level PSUM enqueue request, holds the merge
//               state until the core reports PSUM accumulation completion, and
//               emits a clean accept pulse toward the PE core.
// ============================================================================

module Processing_Element_Controller (
    input  wire clk,
    input  wire rst,

    input  wire top_psum_enq_en_in,
    input  wire core_ctrl_status_psum_acc_fin_in,

    output wire cluster_ctrl_psum_enq_en_out
);

localparam [0:0] IDLE  = 1'b0;
localparam [0:0] MERGE = 1'b1;

reg pe_state_r, pe_state_next_w;

reg psum_req_pending_r;
reg top_psum_enq_en_d_r;

wire new_psum_req_w;
wire psum_req_seen_w;
wire accept_psum_req_w;

assign new_psum_req_w = top_psum_enq_en_in & ~top_psum_enq_en_d_r;
assign psum_req_seen_w = psum_req_pending_r | new_psum_req_w;
assign accept_psum_req_w = (pe_state_r == IDLE) && psum_req_seen_w;

// Combinational accept pulse (core merge_req must see enq same cycle as accept).
assign cluster_ctrl_psum_enq_en_out = accept_psum_req_w;

always @(*) begin
    case (pe_state_r)
        IDLE: begin
            if (accept_psum_req_w)
                pe_state_next_w = MERGE;
            else
                pe_state_next_w = IDLE;
        end

        MERGE: begin
            if (core_ctrl_status_psum_acc_fin_in)
                pe_state_next_w = IDLE;
            else
                pe_state_next_w = MERGE;
        end

        default: pe_state_next_w = IDLE;
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        pe_state_r                 <= IDLE;
        psum_req_pending_r         <= 1'b0;
        top_psum_enq_en_d_r <= 1'b0;
    end else begin
        pe_state_r <= pe_state_next_w;
        top_psum_enq_en_d_r <= top_psum_enq_en_in;
        psum_req_pending_r <= (psum_req_pending_r | new_psum_req_w) & ~accept_psum_req_w;
    end
end

endmodule
