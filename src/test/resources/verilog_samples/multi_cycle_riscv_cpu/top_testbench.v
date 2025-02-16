module top_testbench();

    reg clk;
    reg reset;

    // interface between the host and the master
    // TODO: these signals are exposed for testing for now.
    // If everything works, these signals have to be produced by the CPU
    reg             cmd_stb;
    reg [33:0]      cmd_word;
    wire            cmd_busy;
    wire            rsp_stb;
    wire [33:0]     rsp_word;

    top dut(
        // clock and reset
        clk,
        reset,
        // interface between the host and the master
        cmd_stb,
        cmd_word,
        cmd_busy,
        rsp_stb,
        rsp_word
    );

    initial
        begin
            // $monitor() has to be called only a single time but does as it's name suggests from that point on.
            // $monitor() will display new output, whenever one of the monitored signals change.
            // In a sense it monitors all signals and produces output when there is any change.
            $monitor("At time %t, clk = %0d, rsp_word = %0h",
                $time, clk, rsp_word);
        end

    // run the testbench
    initial
        begin

            //
            // initialize
            //

            $display("");
            $display("[top_testbench] start");

            clk <= 0;
            reset = 1'b1;

            //
            // Perform a reset
            //

            #30

            $display("");
            $display("[top_testbench] reset");

            reset = 1'b0;

            //
            // Perform a write
            //

            #30

            $display("");
            $display("[top_testbench] write");

            //
            // address
            //

            cmd_stb = 1;
            // formulate a write command
            // set new base address without increment feature
            //cmd_word = { 2'b10, 1'b0, 1'b1, 10'b1010101010 };
            //cmd_word = { 2'b10, 1'b0, 1'b1, 30'b101010101010101010101010101010 };
              cmd_word = { 2'b10, 1'b0, 1'b1, 30'b000000000000000000000000000000 };

            #30

            //
            // data
            //

            cmd_stb = 1; // without a strobe, the master will not decode the command
            cmd_word = { 2'b01, 32'hAABBCCDD }; // set data to write

            //
            // Perform a read
            //

            #100

            $display("");
            $display("[top_testbench] reading 1");

            cmd_stb = 1; // without a strobe, the master will not decode the command
            //cmd_word = { 2'b00, 10'b1010101010 }; // set new base address without increment feature
            //cmd_word = { 2'b00, 32'b00101010101010101010101010101000 };
              cmd_word = { 2'b00, 32'b00000000000000000000000000000000 };

            //
            // Perform a second read
            //

            #100

            $display("");
            $display("[top_testbench] reading 2");

            cmd_stb = 1; // without a strobe, the master will not decode the command
            //cmd_word = { 2'b00, 10'b0000000000 }; // set new base address without increment feature
              cmd_word = { 2'b00, 32'b00000000000000000000000000000000 };

            //
            // End of test
            //

            #50;

            $display("");
            $display("[top_testbench] finish");

            $finish;

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