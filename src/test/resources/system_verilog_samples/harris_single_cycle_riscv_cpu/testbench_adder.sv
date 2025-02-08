module testbench();
    logic [31:0] a, b;
    logic [31:0] y;

    // instantiate device to be tested
    adder dut(a, b, y);

    initial
        begin
            a <= 0; // non-blocking, evaluation directly, assignment in
            b <= 0; // non-blocking

            #5

            a <= 1; // non-blocking
            b <= 2; // non-blocking
        end

endmodule