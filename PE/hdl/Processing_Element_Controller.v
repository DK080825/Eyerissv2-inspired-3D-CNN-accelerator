// ====================================================================================================== //
// PE controller
// - Keep pending requests while PE is busy
// - Deduplicate stretched requests by rising-edge capture
// - LOAD has higher priority than PSUM_ENQ
// - Add MERGE state so psum merge is treated as a busy phase
// ====================================================================================================== //

module Processing_Element_Controller (
    input   clock,
    input   reset,

    output  mac_en,
    output  from_top_psum_enq_en,
    output  from_top_do_load_en,

    input   from_top_cal_fin,
    input   from_top_psum_acc_fin,   // NEW: core reports psum-merge finished

    input   top_psum_enq_en,
    input   top_do_load_en,
    output  top_cal_fin,
    input   top_write_fin
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
reg [1:0] PE_state, next_PE_state;

// keep request until accepted
reg load_req_pending;
reg psum_req_pending;

// previous sampled request level
reg top_do_load_en_d;
reg top_psum_enq_en_d;

// registered 1-cycle pulse to core
reg start_merge_pulse_q;
reg start_mac_pulse_q;
reg cal_done_seen_q;

// rising-edge detect
wire new_load_req;
wire new_psum_req;

// request present
wire load_req_seen;
wire psum_req_seen;

// accept in IDLE only
wire accept_load_req;
wire accept_psum_req;

// ================================================ //
//                   Combinational                  //
// ================================================ //
assign new_load_req = top_do_load_en  & ~top_do_load_en_d;
assign new_psum_req = top_psum_enq_en & ~top_psum_enq_en_d;

assign load_req_seen = load_req_pending | new_load_req;
assign psum_req_seen = psum_req_pending | new_psum_req;

// priority: LOAD > PSUM_ENQ
assign accept_load_req =
    (PE_state == IDLE) && load_req_seen;

assign accept_psum_req =
    (PE_state == IDLE) && !load_req_seen && psum_req_seen;

// outputs
assign mac_en               = start_mac_pulse_q;
// keep feeding load stream through CAL until all write-fin flags are latched
assign from_top_do_load_en  = (PE_state == LOAD) || ((PE_state == CAL) && !top_write_fin);

// one-cycle pulse to start merge in core
assign from_top_psum_enq_en = start_merge_pulse_q;

// report completion only when both compute and load are complete
assign top_cal_fin          = (PE_state == CAL) && top_write_fin && cal_done_seen_q;

// next-state logic
always @(*) begin
    case (PE_state)
        IDLE: begin
            if (accept_load_req)
                next_PE_state = LOAD;
            else if (accept_psum_req)
                next_PE_state = MERGE;
            else
                next_PE_state = IDLE;
        end

        // enter CAL as soon as possible; core itself gates actual RUN start
        LOAD: begin
            next_PE_state = CAL;
        end

        CAL: begin
            if (top_write_fin && cal_done_seen_q)
                next_PE_state = IDLE;
            else
                next_PE_state = CAL;
        end

        MERGE: begin
            if (from_top_psum_acc_fin)
                next_PE_state = IDLE;
            else
                next_PE_state = MERGE;
        end

        default: begin
            next_PE_state = IDLE;
        end
    endcase
end

// ================================================ //
//                     Sequential                   //
// ================================================ //
always @(posedge clock) begin
    if (reset) begin
        PE_state           <= IDLE;

        load_req_pending   <= 1'b0;
        psum_req_pending   <= 1'b0;

        top_do_load_en_d   <= 1'b0;
        top_psum_enq_en_d  <= 1'b0;

        start_merge_pulse_q <= 1'b0;
        start_mac_pulse_q   <= 1'b0;
        cal_done_seen_q     <= 1'b0;
    end
    else begin
        PE_state <= next_PE_state;

        // registered 1-cycle pulse to core
        start_merge_pulse_q <= accept_psum_req;
        // issue a single early MAC request when leaving LOAD
        start_mac_pulse_q   <= (PE_state == LOAD);

        if (PE_state != CAL)
            cal_done_seen_q <= 1'b0;
        else if (from_top_cal_fin)
            cal_done_seen_q <= 1'b1;

        // sample previous input levels
        top_do_load_en_d  <= top_do_load_en;
        top_psum_enq_en_d <= top_psum_enq_en;

        // keep request until accepted
        load_req_pending <= (load_req_pending | new_load_req) & ~accept_load_req;
        psum_req_pending <= (psum_req_pending | new_psum_req) & ~accept_psum_req;
    end
end

endmodule