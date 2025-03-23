module top_testbench();

    reg clk;
    // reg resetn;
    wire led_green;

    // the source code is loaded in imem.v or ram.v depending on which memory concept you want to use
    top dut(
        // clock and reset
        clk,
        // resetn,
        led_green
    );

    initial
         begin
            $dumpfile("test.vcd");

            $dumpvars(0, clk);
            // $dumpvars(0, resetn);
            $dumpvars(0, dut);

            #500 $finish();
            //#4000 $finish();
         end

    // initial
    // begin

    //     //
    //     // initialize
    //     // Perform a reset
    //     //

    //     $display("");
    //     $display("-----------------------------------------------------------------");
    //     $display("[top_testbench] reset");

    //     //clk <= 0;
    //     resetn = 1'b0;

    //     #2

    //     //
    //     // Reset is over
    //     //

    //     $display("");
    //     $display("-----------------------------------------------------------------");
    //     $display("[top_testbench] reset done");

    //     resetn = 1'b1;

    // end

    // generate clock to sequence tests
    always
    begin
        $display("tick %d", $time);
        clk <= 1;
        #1;
        clk <= 0;
        #1;
    end

endmodule