module counter_tb;

    /* Make a reset that pulses once. */
    reg reset = 0;

    /* Make a regular pulsing clock. */
    reg clk = 0;

    wire [7:0] value;
    counter c1 (value, clk, reset);

    always #5 clk = !clk;

    initial begin
        #17 reset = 1;
        #11 reset = 0;
        #29 reset = 1;
        #11 reset = 0;
        #100 $stop;
    end

    // initial begin
    //     #200 $stop;
    // end

    initial
        $monitor("At time %t, value = %h (%0d)", $time, value, value);
        //$monitor("At time %t, clock %d, value = %h (%0d)", $time, clk, value, value);

endmodule