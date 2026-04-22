`timescale 1ns/1ps

module tb_Weight_Data_Spad;

    localparam integer WEIGHT_PACKED_W   = 24;
    localparam integer WEIGHT_WORD_PTR_W = 7;
    localparam integer WEIGHT_COUNT_W    = 4;
    localparam integer WEIGHT_VALUE_W    = 8;
    localparam integer SPAD_DEPTH        = 100;

    localparam [WEIGHT_PACKED_W-1:0] ZERO_WORD = {WEIGHT_PACKED_W{1'b0}};

    reg                             clock;
    reg                             reset;

    wire                            data_in_ready;
    reg                             data_in_valid;
    reg  [WEIGHT_PACKED_W-1:0]      data_in;

    wire [WEIGHT_VALUE_W-1:0]       lane0_value;
    wire [WEIGHT_COUNT_W-1:0]       lane0_count;
    wire [WEIGHT_VALUE_W-1:0]       lane1_value;
    wire [WEIGHT_COUNT_W-1:0]       lane1_count;

    reg                             write_en;
    wire                            write_fin;

    reg                             read_en;
    reg  [WEIGHT_WORD_PTR_W-1:0]    read_word_idx;
    wire                            lane0_valid;
    wire                            lane1_valid;

    integer errors;

    // ============================================================
    // DUT
    // ============================================================
    Weight_Data_Spad #(
        .WEIGHT_PACKED_W   (WEIGHT_PACKED_W),
        .WEIGHT_WORD_PTR_W (WEIGHT_WORD_PTR_W),
        .WEIGHT_COUNT_W    (WEIGHT_COUNT_W),
        .WEIGHT_VALUE_W    (WEIGHT_VALUE_W)
    ) dut (
        .clock        (clock),
        .reset        (reset),
        .data_in_ready(data_in_ready),
        .data_in_valid(data_in_valid),
        .data_in      (data_in),
        .lane0_value  (lane0_value),
        .lane0_count  (lane0_count),
        .lane1_value  (lane1_value),
        .lane1_count  (lane1_count),
        .write_en     (write_en),
        .write_fin    (write_fin),
        .read_en      (read_en),
        .read_word_idx(read_word_idx),
        .lane0_valid  (lane0_valid),
        .lane1_valid  (lane1_valid)
    );

    // ============================================================
    // Golden model
    // ============================================================
    reg [WEIGHT_PACKED_W-1:0] golden_mem [0:SPAD_DEPTH-1];
    integer golden_wr_ptr;

    // ============================================================
    // Helpers
    // ============================================================
    function [WEIGHT_PACKED_W-1:0] pack_word;
        input [WEIGHT_VALUE_W-1:0] lane1_v;
        input [WEIGHT_COUNT_W-1:0] lane1_c;
        input [WEIGHT_VALUE_W-1:0] lane0_v;
        input [WEIGHT_COUNT_W-1:0] lane0_c;
        begin
            pack_word = {lane1_v, lane1_c, lane0_v, lane0_c};
        end
    endfunction

    function [WEIGHT_VALUE_W-1:0] exp_lane0_value;
        input [WEIGHT_PACKED_W-1:0] word;
        begin
            exp_lane0_value = word[WEIGHT_VALUE_W+WEIGHT_COUNT_W-1 : WEIGHT_COUNT_W];
        end
    endfunction

    function [WEIGHT_COUNT_W-1:0] exp_lane0_count;
        input [WEIGHT_PACKED_W-1:0] word;
        begin
            exp_lane0_count = word[WEIGHT_COUNT_W-1:0];
        end
    endfunction

    function [WEIGHT_VALUE_W-1:0] exp_lane1_value;
        input [WEIGHT_PACKED_W-1:0] word;
        begin
            exp_lane1_value = word[2*(WEIGHT_VALUE_W+WEIGHT_COUNT_W)-1 :
                                   WEIGHT_VALUE_W+WEIGHT_COUNT_W+WEIGHT_COUNT_W];
        end
    endfunction

    function [WEIGHT_COUNT_W-1:0] exp_lane1_count;
        input [WEIGHT_PACKED_W-1:0] word;
        begin
            exp_lane1_count = word[WEIGHT_VALUE_W+2*WEIGHT_COUNT_W-1 :
                                   WEIGHT_VALUE_W+WEIGHT_COUNT_W];
        end
    endfunction

    function exp_lane0_valid_fn;
        input [WEIGHT_PACKED_W-1:0] word;
        begin
            exp_lane0_valid_fn = (word[WEIGHT_VALUE_W+WEIGHT_COUNT_W-1:0] != {(WEIGHT_VALUE_W+WEIGHT_COUNT_W){1'b0}});
        end
    endfunction

    function exp_lane1_valid_fn;
        input [WEIGHT_PACKED_W-1:0] word;
        begin
            exp_lane1_valid_fn = (word[2*(WEIGHT_VALUE_W+WEIGHT_COUNT_W)-1 : (WEIGHT_VALUE_W+WEIGHT_COUNT_W)] != {(WEIGHT_VALUE_W+WEIGHT_COUNT_W){1'b0}});
        end
    endfunction

    // ============================================================
    // Clock
    // ============================================================
    initial begin
        clock = 1'b0;
        forever #5 clock = ~clock;
    end

    // ============================================================
    // Tasks
    // ============================================================
    task golden_reset;
        integer k;
        begin
            for (k = 0; k < SPAD_DEPTH; k = k + 1)
                golden_mem[k] = ZERO_WORD;
            golden_wr_ptr = 0;
        end
    endtask

    task automatic golden_accept_write;
        input [WEIGHT_PACKED_W-1:0] din;
        begin
            golden_mem[golden_wr_ptr] = din;

            if (din == ZERO_WORD)
                golden_wr_ptr = 0;
            else if (golden_wr_ptr < SPAD_DEPTH-1)
                golden_wr_ptr = golden_wr_ptr + 1;
            else
                golden_wr_ptr = 0;
        end
    endtask

    task automatic check_signal;
        input condition;
        input [1023:0] msg;
        begin
            if (!condition) begin
                $display("[ERROR] %0t : %0s", $time, msg);
                errors = errors + 1;
            end
        end
    endtask

    task automatic wait_clear_done;
        integer cycle_cnt;
        begin
            cycle_cnt = 0;
            while (dut.Weight_DATA_Spad_BRAM_inst.clear_flag) begin
                @(posedge clock);
                cycle_cnt = cycle_cnt + 1;

                #1;
                if ((lane0_valid !== 1'b0) || (lane1_valid !== 1'b0)) begin
                    $display("[ERROR] %0t : lane valid must stay 0 during clear", $time);
                    errors = errors + 1;
                end

                if (cycle_cnt > (SPAD_DEPTH + 20)) begin
                    $display("[ERROR] %0t : clear_flag did not drop as expected", $time);
                    errors = errors + 1;
                    disable wait_clear_done;
                end
            end

            $display("[INFO ] %0t : clear phase finished after %0d cycles", $time, cycle_cnt);
        end
    endtask

    task automatic drive_write;
        input [WEIGHT_PACKED_W-1:0] din;
        input en;
        reg exp_write_fin;
        integer exp_ptr_after;
        begin
            @(negedge clock);
            data_in       = din;
            data_in_valid = 1'b1;
            write_en      = en;
            read_en       = 1'b0;
            read_word_idx = {WEIGHT_WORD_PTR_W{1'b0}};
            #1;

            exp_write_fin = en && (din == ZERO_WORD);
            if (write_fin !== exp_write_fin) begin
                $display("[ERROR] %0t : write_fin mismatch before clk. din=0x%0h en=%0b exp=%0b got=%0b",
                         $time, din, en, exp_write_fin, write_fin);
                errors = errors + 1;
            end

            @(posedge clock);
            #1;

            if (en)
                golden_accept_write(din);

            exp_ptr_after = golden_wr_ptr;
            if (dut.spad_write_addr !== exp_ptr_after[WEIGHT_WORD_PTR_W-1:0]) begin
                $display("[ERROR] %0t : spad_write_addr mismatch. exp=%0d got=%0d",
                         $time, exp_ptr_after, dut.spad_write_addr);
                errors = errors + 1;
            end

            // write cycle should not generate read valid
            if ((lane0_valid !== 1'b0) || (lane1_valid !== 1'b0)) begin
                $display("[ERROR] %0t : lane valid must be 0 during write cycle", $time);
                errors = errors + 1;
            end

            @(negedge clock);
            data_in_valid = 1'b0;
            write_en      = 1'b0;
            data_in       = ZERO_WORD;
        end
    endtask

    task automatic read_and_check_word;
        input integer addr;
        input [WEIGHT_PACKED_W-1:0] exp_word;

        reg [WEIGHT_VALUE_W-1:0] exp_l0_v;
        reg [WEIGHT_COUNT_W-1:0] exp_l0_c;
        reg [WEIGHT_VALUE_W-1:0] exp_l1_v;
        reg [WEIGHT_COUNT_W-1:0] exp_l1_c;
        reg exp_l0_valid;
        reg exp_l1_valid;
        begin
            exp_l0_v     = exp_lane0_value(exp_word);
            exp_l0_c     = exp_lane0_count(exp_word);
            exp_l1_v     = exp_lane1_value(exp_word);
            exp_l1_c     = exp_lane1_count(exp_word);
            exp_l0_valid = exp_lane0_valid_fn(exp_word);
            exp_l1_valid = exp_lane1_valid_fn(exp_word);

            @(negedge clock);
            read_word_idx = addr[WEIGHT_WORD_PTR_W-1:0];
            read_en       = 1'b1;
            write_en      = 1'b0;
            data_in_valid = 1'b0;
            data_in       = ZERO_WORD;

            @(posedge clock);
            #1;

            if ((lane0_value !== exp_l0_v) ||
                (lane0_count !== exp_l0_c) ||
                (lane1_value !== exp_l1_v) ||
                (lane1_count !== exp_l1_c) ||
                (lane0_valid !== exp_l0_valid) ||
                (lane1_valid !== exp_l1_valid)) begin

                $display("[ERROR] %0t : read_idx=%0d exp_word=0x%0h", $time, addr, exp_word);
                $display("        exp lane0: value=0x%0h count=0x%0h valid=%0b",
                         exp_l0_v, exp_l0_c, exp_l0_valid);
                $display("        got lane0: value=0x%0h count=0x%0h valid=%0b",
                         lane0_value, lane0_count, lane0_valid);
                $display("        exp lane1: value=0x%0h count=0x%0h valid=%0b",
                         exp_l1_v, exp_l1_c, exp_l1_valid);
                $display("        got lane1: value=0x%0h count=0x%0h valid=%0b",
                         lane1_value, lane1_count, lane1_valid);
                errors = errors + 1;
            end
            else begin
                $display("[OK]    %0t : read_idx=%0d word=0x%0h", $time, addr, exp_word);
            end

            @(negedge clock);
            read_en = 1'b0;
        end
    endtask

    task automatic read_and_check_golden;
        input integer addr;
        begin
            read_and_check_word(addr, golden_mem[addr]);
        end
    endtask

    task automatic read_write_same_cycle_check;
        input integer rd_addr;
        input [WEIGHT_PACKED_W-1:0] wr_word;
        begin
            @(negedge clock);
            read_word_idx = rd_addr[WEIGHT_WORD_PTR_W-1:0];
            read_en       = 1'b1;
            write_en      = 1'b1;
            data_in_valid = 1'b1;
            data_in       = wr_word;

            @(posedge clock);
            #1;

            // Because data_in_shake=1, rd_fire=0 -> no read valid
            if ((lane0_valid !== 1'b0) || (lane1_valid !== 1'b0)) begin
                $display("[ERROR] %0t : read must be blocked when write happens in same cycle", $time);
                errors = errors + 1;
            end
            else begin
                $display("[OK]    %0t : read blocked correctly during simultaneous write", $time);
            end

            // write still occurs
            golden_accept_write(wr_word);

            @(negedge clock);
            read_en       = 1'b0;
            write_en      = 1'b0;
            data_in_valid = 1'b0;
            data_in       = ZERO_WORD;
        end
    endtask

    // ============================================================
    // Test sequence
    // ============================================================
    reg [WEIGHT_PACKED_W-1:0] W0;
    reg [WEIGHT_PACKED_W-1:0] W1;
    reg [WEIGHT_PACKED_W-1:0] W2;
    reg [WEIGHT_PACKED_W-1:0] W3;

    initial begin
        errors = 0;

        reset         = 1'b0;
        data_in_valid = 1'b0;
        data_in       = ZERO_WORD;
        write_en      = 1'b0;
        read_en       = 1'b0;
        read_word_idx = {WEIGHT_WORD_PTR_W{1'b0}};

        golden_reset();

        W0 = pack_word(8'h34, 4'h2, 8'h12, 4'h1); // both lanes valid
        W1 = pack_word(8'h00, 4'h0, 8'h50, 4'h3); // lane0 valid only
        W2 = pack_word(8'h78, 4'h4, 8'h00, 4'h0); // lane1 valid only
        W3 = pack_word(8'hBC, 4'hA, 8'h9A, 4'h5); // overwrite test

        // --------------------------------------------------------
        // 1) Reset + clear
        // --------------------------------------------------------
        @(negedge clock);
        reset = 1'b1;
        @(posedge clock);
        @(posedge clock);
        #1;

        golden_reset();
        check_signal(data_in_ready === 1'b1, "data_in_ready should always be 1");

        @(negedge clock);
        reset = 1'b0;

        wait_clear_done();

        $display("\n--- After clean reset ---");
        read_and_check_golden(0);
        read_and_check_golden(1);
        read_and_check_golden(2);

        // --------------------------------------------------------
        // 2) First vector load: [W0, W1, W2, 0]
        // --------------------------------------------------------
        drive_write(W0, 1'b1);
        drive_write(W1, 1'b1);
        drive_write(W2, 1'b1);
        drive_write(ZERO_WORD, 1'b1);

        $display("\n--- After first vector load [W0,W1,W2,0] ---");
        read_and_check_golden(0);
        read_and_check_golden(1);
        read_and_check_golden(2);
        read_and_check_golden(3);
        read_and_check_golden(4);

        // --------------------------------------------------------
        // 3) write_en=0 -> no write
        // --------------------------------------------------------
        drive_write(pack_word(8'hEE,4'hF,8'hDD,4'hE), 1'b0);

        $display("\n--- After no-write case (write_en=0) ---");
        read_and_check_golden(0);
        read_and_check_golden(1);
        read_and_check_golden(2);

        // --------------------------------------------------------
        // 4) Read and write same cycle -> read must be blocked
        // --------------------------------------------------------
        read_write_same_cycle_check(0, W3);

        $display("\n--- After simultaneous read/write cycle ---");
        read_and_check_golden(0); // should now be W3
        read_and_check_golden(1); // old W1
        read_and_check_golden(2); // old W2

        // --------------------------------------------------------
        // 5) Second vector load without reset: [W1, 0]
        // tail should remain old if not overwritten
        // --------------------------------------------------------
        drive_write(W1, 1'b1);
        drive_write(ZERO_WORD, 1'b1);

        $display("\n--- After second vector load [W1,0] without reset ---");
        read_and_check_golden(0); // W1
        read_and_check_golden(1); // 0
        read_and_check_golden(2); // old W2 remains
        read_and_check_golden(3); // old 0 remains

        // --------------------------------------------------------
        // Summary
        // --------------------------------------------------------
        if (errors == 0)
            $display("\nTEST PASSED: all golden checks matched DUT.");
        else
            $display("\nTEST FAILED: %0d mismatches found.", errors);

        #20;
        $finish;
    end

endmodule