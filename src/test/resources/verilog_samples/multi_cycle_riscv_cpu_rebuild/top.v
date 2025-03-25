module top(

    // clock and reset
    input wire clk,
    //input wire resetn,

    // UART lines
    input ftdi_rx,
    output ftdi_tx,

    // LEDS
    output reg led_green,
    output reg D1,
    output reg D2,
    output reg D3,
    output reg D4
);

    //
    // clock
    //

    wire clk_divided;
    clock_divider clk_div(clk, clk_divided);

    // // DEBUG clk_divided
    // always @(posedge clk)
    // begin
    //     tx_Data = clk_divided;
    //     tx_DataValid = 1'b1;
    // end

    // //
    // // memory mapped I/O
    // //

    wire [31:0] toggle_value;

    always @(posedge clk)
    begin
        led_green = toggle_value[0];
    end

    //
    // Reset logic
    //

    // https://stackoverflow.com/questions/38030768/icestick-yosys-using-the-global-set-reset-gsr
    wire resetn;
    //reg [21:0] rststate = 0;
    reg [23:0] rststate = 0;

    always @(posedge clk)
    begin
        rststate <= rststate + !resetn; // once resetn turns to 1, rststate is not incremented any more
    end

    //assign resetn = 0;
    assign resetn = &rststate; // and all bits of rststate together which yields a 1 only after rststate reached 0x0F.

    // // DEBUG reset
    // always @(posedge clk)
    // begin
    //     if (resetn == 0)
    //     begin
    //         tx_Data = 8'h12;
    //         tx_DataValid = 1'b1;
    //     end
    //     else
    //     begin
    //         tx_Data = 8'h00;
    //         tx_DataValid = 1'b0;
    //     end
    // end

    //
    // UART
    //

    // use this for a test within this file
    //reg [7:0] tx_Data = 8'h00;
    // reg [7:0] tx_Data = 8'h41;
    //reg tx_DataValid = 1'b0;

    // use this for signals that go through several modules
    wire [7:0] tx_Data;
    wire tx_DataValid;

    wire tx_Active;
    wire tx_Done;
    reg tx_Done_reg = 1'b0;

    // reg [7:0] buffer [0:3];
    // reg [7:0] buffer_index = 8'h00;

    // input       i_Clock,     // clock
    // input       i_Tx_DV,     // data valid, pull high to start sending whatever is in i_Tx_Byte
    // input [7:0] i_Tx_Byte,   // payload bits (byte) to send
    // output      o_Tx_Active, // high during transmission
    // output reg  o_Tx_Serial, // this is the port connected to the UART TX line
    // output      o_Tx_Done    // high for a single clock cycle when transmission is done
    uart_tx #(.CLKS_PER_BIT(104)) utx(
        .i_Clock(clk),
        .i_Tx_DV(tx_DataValid),
        .i_Tx_Byte(tx_Data),
        .o_Tx_Active(tx_Active),
        .o_Tx_Serial(ftdi_tx),
        .o_Tx_Done(tx_Done)
    );

    // UART RX
    wire rx_DataValid;
    wire [7:0] rx_byte;

    // input        i_Clock,        // clock
    // input        i_Rx_Serial,    // this is the port connected to the UART TX line
    // output       o_Rx_DV,        // data valid, goes high for a single clock tick after reception
    // output [7:0] o_Rx_Byte       // data received
    uart_rx #(.CLKS_PER_BIT(104)) urx(
        .i_Clock(clk),
        .i_Rx_Serial(ftdi_rx),
        .o_Rx_DV(rx_DataValid),
        .o_Rx_Byte(rx_byte)
    );

    //
    // UART debug
    //

    // counter register
    reg [31:0] slow_clock_counter = 32'b0;
    reg [31:0] uart_tx_counter = 32'b0;

    // slow clock signal
    wire slow_clock;
    //assign slow_clock = slow_clock_counter[16]; // way to fast to see
    //assign slow_clock = slow_clock_counter[20]; // quick
    assign slow_clock = slow_clock_counter[24]; // slow

    // count up
    always @(posedge clk)
    begin
        slow_clock_counter = slow_clock_counter + 1;
    end

    // UART local file test
    // // count up
    // always @(posedge clk)
    // begin

    //     uart_tx_counter = uart_tx_counter + 1;

    //     if (tx_Done == 1'b1)
    //     begin
    //         tx_DataValid = 1'b0;
    //     end

    //     // DEBUG send by clock tick
    //     if (uart_tx_counter == 32'd9999999)
    //     begin
    //         tx_DataValid = 1'b1;
    //         uart_tx_counter = 0;
    //     end

    // end

    always @(posedge slow_clock)
    begin
        D1 = ~D1;
        D2 = 0;
        D3 = 0;
        D4 = 0;
    end

    //
    // RISCV CPU
    //

    riscv_multi rvmulti(
        // clock and reset
        //clk_divided,
        slow_clock,
        resetn, // the system should reset, when resetn is 0. The system should keep running, when resetn is 1.

        toggle_value,

        // DEBUG UART
        tx_Data,
        tx_DataValid
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