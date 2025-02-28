module top_testbench();

    reg clk;
    reg reset;

    // interface between the host and the master
    // TODO: these signals are exposed for testing for now so that the testbenach can send stimuli in.
    // If everything works, these signals have to be produced by the CPU
    reg             cmd_stb;
    reg [33:0]      cmd_word;
    wire            cmd_busy;
    wire            rsp_stb;
    wire [33:0]     rsp_word;

    top dut(
        // clock and reset
        clk,
        reset
        // // interface between the host and the master
        // cmd_stb,
        // cmd_word,
        // cmd_busy,
        // rsp_stb,
        // rsp_word
    );

    initial
         begin
            #400 $finish();
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

            //
            // Perform a read
            //

            //#30

            // cmd_stb = 1; // without a strobe, the master will not decode the command

            // $display("");
            // $display("-----------------------------------------------------------------");
            // $display("[top_testbench] reading 1");

            // //
            // // address
            // //

            // $display("[top_testbench] ADDRESS ADDRESS ADDRESS");

            // cmd_stb = 1;
            // // formulate a read command
            // // set new base address without increment feature
            // cmd_word = { 2'b10, 1'b0, 1'b1, 30'b000000000000000000000000001100 };

            // #10

            // $display("");
            // $display("[top_testbench] READ READ READ");

            // cmd_stb = 1;
            // cmd_word = { 2'b00, 32'b00000000000000000000000000000000 };

            // #10 cmd_stb = 0;

        end

    // // run the testbench
    // initial
    //     begin

    //         //
    //         // initialize
    //         //

    //         $display("");
    //         $display("-----------------------------------------------------------------");
    //         $display("[top_testbench] start");

    //         clk <= 0;
    //         reset = 1'b1;

    //         //
    //         // Perform a reset
    //         //

    //         #30

    //         $display("");
    //         $display("-----------------------------------------------------------------");
    //         $display("[top_testbench] reset");

    //         reset = 1'b0;

    //         //
    //         // Perform a write
    //         //

    //         #30

    //         $display("");
    //         $display("-----------------------------------------------------------------");
    //         $display("[top_testbench] write");

    //         //
    //         // address
    //         //

    //         $display("[top_testbench] ADDRESS ADDRESS ADDRESS");

    //         cmd_stb = 1;
    //         // formulate a write command
    //         // set new base address without increment feature
    //         //cmd_word = { 2'b10, 1'b0, 1'b1, 10'b1010101010 };
    //         //cmd_word = { 2'b10, 1'b0, 1'b1, 30'b101010101010101010101010101010 };
    //           cmd_word = { 2'b10, 1'b0, 1'b1, 30'b000000000000000000000000000000 };

    //         #10

    //         //
    //         // data
    //         //

    //         $display("[top_testbench] DATA DATA DATA");

    //         cmd_stb = 1; // without a strobe, the master will not decode the command
    //         cmd_word = { 2'b01, 32'hAABBCCDD }; // set data to write

    //         #10 cmd_stb = 0;

    //         //
    //         // Perform a read
    //         //

    //         #30 cmd_stb = 1; // without a strobe, the master will not decode the command

    //         $display("");
    //         $display("-----------------------------------------------------------------");
    //         $display("[top_testbench] reading 1");

    //         //
    //         // address
    //         //

    //         $display("[top_testbench] ADDRESS ADDRESS ADDRESS");

    //         cmd_stb = 1;
    //         // formulate a read command
    //         // set new base address without increment feature
    //         cmd_word = { 2'b10, 1'b0, 1'b1, 30'b000000000000000000000000001100 };

    //         #10

    //         $display("");
    //         $display("[top_testbench] READ READ READ");

    //         cmd_stb = 1;
    //         cmd_word = { 2'b00, 32'b00000000000000000000000000000000 };

    //         #10 cmd_stb = 0;

    //         //
    //         // Perform a read
    //         //

    //         #30 cmd_stb = 1; // without a strobe, the master will not decode the command

    //         $display("");
    //         $display("-----------------------------------------------------------------");
    //         $display("[top_testbench] reading 2");

    //         //
    //         // address
    //         //

    //         $display("[top_testbench] ADDRESS ADDRESS ADDRESS");

    //         cmd_stb = 1;
    //         // formulate a read command
    //         // set new base address without increment feature
    //         cmd_word = { 2'b10, 1'b0, 1'b1, 30'b000000000000000000000000000000 };

    //         #10

    //         $display("");
    //         $display("[top_testbench] READ READ READ");

    //         cmd_stb = 1;
    //         cmd_word = { 2'b00, 32'b00000000000000000000000000000000 };

    //         #10 cmd_stb = 0;

    //         //
    //         // End of test
    //         //

    //         #50;

    //         $display("");
    //         $display("-----------------------------------------------------------------");
    //         $display("[top_testbench] finish");

    //         $finish;

    //     end

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