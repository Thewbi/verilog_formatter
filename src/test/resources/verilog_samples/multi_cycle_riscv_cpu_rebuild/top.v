module top(
    input wire clk,
    input wire reset
);

    initial
        begin
            $display("Hello, World");
        end

    // initial
    //     begin
    //         $monitor("[TOP.v] At time %t, clk = %0d, rsp_word = %0h", $time, clk, rsp_word);
    //     end

    riscv_multi rvmulti(
        // clock and reset
        clk,
        reset
    );

endmodule