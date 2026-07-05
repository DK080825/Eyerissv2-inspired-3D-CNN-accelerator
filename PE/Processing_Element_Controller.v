// ============================================================================
// Module      : Processing_Element_Controller
// Author      : Do Quoc Khanh
// Description : Small controller inside one PE wrapper.
//               It receives a PSUM output request from the cluster.
//               It sends one clean request pulse to the PE core.
//               It waits until the core reports PSUM output done.
// ============================================================================

module Processing_Element_Controller (
    input  wire clk,
    input  wire rst,

    // Cluster controller -> PE wrapper: request PSUM output.
    input  wire top_psum_enq_en_in,
    // PE core -> PE wrapper: PSUM output is done.
    input  wire core_ctrl_status_psum_acc_fin_in,

    // PE wrapper -> PE core: one-cycle PSUM output request.
    output wire cluster_ctrl_psum_enq_en_out
);

localparam [0:0] IDLE  = 1'b0;
localparam [0:0] MERGE = 1'b1;

reg pe_state_r;

reg psum_req_pending_r;
reg top_psum_enq_en_d_r;

wire new_psum_req_w;
wire psum_req_seen_w;
wire accept_psum_req_w;

assign new_psum_req_w = top_psum_enq_en_in & ~top_psum_enq_en_d_r;
assign psum_req_seen_w = psum_req_pending_r | new_psum_req_w;
assign accept_psum_req_w = (pe_state_r == IDLE) && psum_req_seen_w;

// One-cycle pulse sent to the core when the request is accepted.
assign cluster_ctrl_psum_enq_en_out = accept_psum_req_w;

always @(posedge clk) begin
    if (rst) begin
        pe_state_r                 <= IDLE;
        psum_req_pending_r         <= 1'b0;
        top_psum_enq_en_d_r <= 1'b0;
    end else begin
        top_psum_enq_en_d_r <= top_psum_enq_en_in;
        psum_req_pending_r <= (psum_req_pending_r | new_psum_req_w) & ~accept_psum_req_w;

        if (pe_state_r == IDLE) begin
            if (accept_psum_req_w)
                pe_state_r <= MERGE;
        end else if (core_ctrl_status_psum_acc_fin_in) begin
            pe_state_r <= IDLE;
        end
    end
end

endmodule
