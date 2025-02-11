module testbench();

    logic [31:0] a, b;
    logic [31:0] y;

    // instantiate device under test
    adder dut(a, b, y);

    initial
        begin
            a <= 0; // non-blocking, evaluation of rhs happens directly, assignment takes place in NBA region
            b <= 0; // non-blocking
            #5
            a <= 1; // non-blocking
            b <= 2; // non-blocking
        end

endmodule