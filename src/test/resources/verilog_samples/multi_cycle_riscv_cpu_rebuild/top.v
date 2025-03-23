module top(
    input wire clk,
    //input wire resetn,
    output reg led_green
);

    wire [31:0] toggle_value;

    always @(posedge clk)
    begin
        led_green = toggle_value[0];
    end

    // https://stackoverflow.com/questions/38030768/icestick-yosys-using-the-global-set-reset-gsr
    wire resetn;
    reg [3:0] rststate = 0;

    always @(posedge clk)
    begin
        rststate <= rststate + !resetn; // once resetn turns to 1, rststate is not incremented any more
    end

    //assign resetn = 0;
    assign resetn = &rststate; // and all bits of rststate together which yields a 1 only after rststate reached 0x0F.

    riscv_multi rvmulti(
        // clock and reset
        clk,
        resetn, // the system should reset, when resetn is 0. The system should keep running, when resetn is 1.
        toggle_value
    );

endmodule





// initial
    //     begin
    //         $display("Hello, World");
    //     end

    // initial
    //     begin
    //         $monitor("[TOP.v] At time %t, clk = %0d, rsp_word = %0h", $time, clk, rsp_word);
    //     end