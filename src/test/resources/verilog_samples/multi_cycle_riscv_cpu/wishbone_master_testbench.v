module wishbone_master_testbench();

    // logic [31:0] a, b;
    // logic [31:0] y;

    localparam MEMORY_DEPTH = 1024;

    reg i_clk;
    reg i_reset;
    reg i_cmd_stb;
    reg [33:0] i_cmd_word;
    wire o_cmd_busy;
    wire o_rsp_stb;
    wire [33:0] o_rsp_word;

    reg i_wb_err;
    reg i_wb_stall;
    reg i_wb_ack;
    reg [31:0] i_wb_data;
    wire o_wb_cyc;
    wire o_wb_stb;
    wire [29:0] o_wb_addr;
    wire o_wb_we;
    wire [31:0] o_wb_data;

    // // Instruction Memory
    // wire [$clog2(MEMORY_DEPTH)-1:0] i_inst_addr;
    // wire [31:0] o_inst_out;
    // wire i_stb_inst; // request for instruction
    // wire o_ack_inst; // ack (high if new instruction is now on the bus)

    // // Data Memory Wishbone Interface
    // reg i_wb_cyc;
    // reg i_wb_stb;
    // reg i_wb_we;
    // reg [$clog2(MEMORY_DEPTH)-1:0] i_wb_addr;
    // reg [31:0] i_wb_data;
    // reg [3:0] i_wb_sel;
    // wire o_wb_ack;
    // wire o_wb_stall;
    // wire [31:0] o_wb_data;

    // instantiate device under test
    wishbone_master master(
        i_clk,
        i_reset,
        i_cmd_stb,      // the host tells the master that it wants to execute a command
        i_cmd_word,     // the command to execute
        o_cmd_busy,
        o_rsp_stb,
        o_rsp_word,

        // wishbone
        i_wb_err,
        i_wb_stall,
        i_wb_ack,
        i_wb_data,
        o_wb_cyc,
        o_wb_stb,
        o_wb_addr,
        o_wb_we,
        o_wb_data
    );

    initial
    begin
        $monitor("At time %t, i_clk = %0d, o_wb_cyc = %d, o_wb_stb = %d, o_cmd_busy = %d, o_rsp_stb = %d, o_rsp_word = %0h, o_wb_addr = %0h",
            $time, i_clk, o_wb_cyc, o_wb_stb, o_cmd_busy, o_rsp_stb, o_rsp_word, o_wb_addr);
    end

    // initialize test
    initial
    begin
        $display("start");
        i_clk <= 0;

        #20;

        //
        // Perform a reset
        //

        $display("reset");

        i_reset = 1'b1;
        #30 i_reset = 1'b0;

        #100;

        //
        // Prepare a write request
        //

        $display("write");

        i_cmd_stb = 1; // without a strobe, the master will not decode the command
        i_cmd_word = { 2'b10, 1'b0, 1'b1, 30'b101010101010101010101010101010 }; // set new base address without increment feature

        #200;

        $finish;

        // // set address to write data into the memory at
        // i_wb_addr = 32'h00;
        // // set data to write into the memory
        // i_wb_data = 32'hAABBCCDD;
        // // fill indexes into wb_data to show where data to be written is located
        // i_wb_sel[0] = 1'b1;
        // i_wb_sel[1] = 1'b1;
        // i_wb_sel[2] = 1'b1;
        // i_wb_sel[3] = 1'b1;

        // // start wishbone cycle and strobe
        // i_wb_cyc = 1'b1;
        // i_wb_stb = 1'b1;

        // // write enable the wishbone slave - perform a write
        // i_wb_we = 1'b1;

        // #50;

        // // set address to read data out of the memory at
        // i_wb_addr = 32'h00;
        // // set data to write into the memory
        // i_wb_data = 32'h00;

        // // read enable the wishbone slave - perform a read
        // i_wb_we = 1'b0;

        // // start wishbone cycle and strobe
        // i_wb_cyc = 1'b1;
        // i_wb_stb = 1'b1;
    end

    // always @(posedge o_wb_ack)
    // begin
    //     $display("ack received");

    //     // // stop wishbone cycle and strobe
    //     // i_wb_cyc = 1'b0;
    //     // i_wb_stb = 1'b0;

    //     // // write disable the wishbone slave
    //     // i_wb_we = 1'b0;
    // end

    // generate clock to sequence tests
    always
    begin
        $display("tick %d", $time);
        i_clk <= 1;
        #5;
        i_clk <= 0;
        #5;
    end

    // // check results
    // always @(negedge i_clk)
    // begin
    //     if ($time >= 200)
    //     begin
    //         $display("Simulation succeeded");
    //         $stop;
    //         $finish;
    //     end
    // end

    // initial
    //     begin
    //         a <= 0; // non-blocking, evaluation of rhs happens directly, assignment takes place in NBA region
    //         b <= 0; // non-blocking
    //         #5
    //         a <= 1; // non-blocking
    //         b <= 2; // non-blocking
    //     end

endmodule