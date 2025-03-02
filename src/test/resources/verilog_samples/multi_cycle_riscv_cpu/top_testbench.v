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

            #30

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
        #5;
        clk <= 0;
        #5;
    end

endmodule