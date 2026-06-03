
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.12.2025 14:09:41
// Design Name: 
// Module Name: tb_sync_sram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_sync_sram;

    // ---------------- PARAMETERS ----------------
    parameter DATA_WIDTH = 16;
    parameter ADDR_WIDTH = 5;
    parameter DEPTH      = (1 << ADDR_WIDTH);

    // ---------------- TB SIGNALS ----------------
    logic clk;
    logic rst;
    logic en;
    logic we;
    logic re;
    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] din;
    logic [DATA_WIDTH-1:0] dout;

    // ---------------- DUT ----------------
    sync_sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .we(we),
        .re(re),
        .addr(addr),
        .din(din),
        .dout(dout)
    );

    // =====================================
    // FSM COVERAGE
    // =====================================
    covergroup fsm_cg @(posedge clk);

        coverpoint dut.curr_state {

            // State coverage
            bins idle  = {2'b00};
            bins write = {2'b01};
            bins read  = {2'b10};
            bins hold  = {2'b11};

            // Transition coverage
            bins idle_to_write = (2'b00 => 2'b01);
            bins idle_to_read  = (2'b00 => 2'b10);

            bins write_to_hold = (2'b01 => 2'b11);
            bins read_to_hold  = (2'b10 => 2'b11);

            bins hold_to_write = (2'b11 => 2'b01);
            bins hold_to_read  = (2'b11 => 2'b10);
            bins hold_to_idle  = (2'b11 => 2'b00);
        }

    endgroup

    fsm_cg fsm_cov = new();

    // ---------------- CLOCK ----------------
    always #5 clk = ~clk;

    // =====================================
    // TEST + RANDOM STRESS
    // =====================================
    initial begin

        // Init
        clk  = 0;
        rst  = 1;
        en   = 0;
        we   = 0;
        re   = 0;
        addr = '0;
        din  = '0;

        // Reset
        #10;
        rst = 0;
        en  = 1;

        // ==========================
        // DIRECTED TEST 1
        // WRITE 0xA5 @ addr=2
        // ==========================
        #10;
        we   = 1;
        re   = 0;
        addr = 5'd2;
        din  = 16'h00A5;

        #10;
        we = 0;

        // READ addr=2
        #10;
        re   = 1;
        addr = 5'd2;

        #10;
        re = 0;

        // ==========================
        // DIRECTED TEST 2
        // WRITE 0x3C @ addr=5
        // ==========================
        #10;
        we   = 1;
        re   = 0;
        addr = 5'd5;
        din  = 16'h003C;

        #10;
        we = 0;

        // READ addr=5
        #10;
        re   = 1;
        addr = 5'd5;

        #10;
        re = 0;

        // =====================================
        // RANDOM STRESS TEST
        // =====================================
        $display("---- Starting Random Stress Test ----");

        repeat (200) begin

            @(posedge clk);

            en = 1;

            // Randomize controls
            we = $urandom_range(0,1);
            re = $urandom_range(0,1);

            // Prevent illegal condition
            if (we && re)
                re = 0;

            // Random address/data
            addr = $urandom_range(0, DEPTH-1);
            din  = $urandom;
        end

        $display("---- Random Stress Test Completed ----");

        #20;
        $finish;

    end

    // ==================================================
    // ASSERTION 1
    // No simultaneous read & write
    // ==================================================
    property no_simultaneous_we_re;
        @(posedge clk)
        disable iff (rst)
        !(we && re);
    endproperty

    assert_no_simultaneous_we_re:
        assert property(no_simultaneous_we_re)
        else
            $error("ASSERTION FAILED: we & re both high at %0t", $time);

// ==================================================
// ASSERTION 2 (FINAL FIX)
// HOLD state stability
// ==================================================

property hold_state_stability_final;

    @(posedge clk)
    disable iff (rst)

    (
        en &&
        !we &&
        !re &&
        $past(en && !we && !re) &&
        (dut.curr_state == 2'b11) &&
        ($past(dut.curr_state) == 2'b11)
    )

    |->

    (dout == $past(dout));

endproperty


assert_hold_state_stability:
assert property(hold_state_stability_final)
else
    $error("ASSERTION FAILED: HOLD instability at %0t",$time);
// ==================================================
// ASSERTION 3 (FINAL PROFESSIONAL FIX)
// RAW correctness
// Same address + transaction aware
// ==================================================

property read_after_write_correct;

    @(posedge clk)
    disable iff (rst)

    (en && we && !re)

    ##1

    (en && re && !we &&
     (addr == $past(addr,1)))

    |->

    ##1

    (dout == $past(din,2));

endproperty


assert_read_after_write_correct:
assert property(read_after_write_correct)
else
    $error("ASSERTION FAILED: RAW mismatch at %0t",$time);
    // ==================================================
    // ASSERTION 4
    // FSM transition legality
    // WRITE->HOLD
    // READ ->HOLD
    // ==================================================
    property valid_fsm_transitions;
        @(posedge clk)
        disable iff (rst)

        (
            (dut.curr_state == 2'b01)
            |-> ##1
            (dut.curr_state == 2'b11)
        )
        and
        (
            (dut.curr_state == 2'b10)
            |-> ##1
            (dut.curr_state == 2'b11)
        );

    endproperty

    assert_valid_fsm_transitions:
        assert property(valid_fsm_transitions)
        else
            $error("ASSERTION FAILED: Invalid FSM transition at %0t", $time);

endmodule
