module top_testbench();

    reg clk;
    reg reset;

    top dut(
        // clock and reset
        clk,
        reset
    );

    initial
         begin
            $dumpfile("test.vcd");

            $dumpvars(0, clk);
            $dumpvars(0, reset);
            $dumpvars(0, dut);

            #1000 $finish();
            //#4000 $finish();
         end

    initial
        begin

            //
            // initialize
            // Perform a reset
            //

            $display("");
            $display("-----------------------------------------------------------------");
            $display("[top_testbench] reset");

            //clk <= 0;
            reset = 1'b1;

            #2

            //
            // Reset is over
            //

            $display("");
            $display("-----------------------------------------------------------------");
            $display("[top_testbench] reset done");

            reset = 1'b0;

        end

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