module wishbone_master_testbench();

    localparam MEMORY_DEPTH = 1024;

    reg         i_clk;

    // interface between the host and the master
    reg         i_reset;
    reg         i_cmd_stb;
    reg  [33:0] i_cmd_word;
    wire        o_cmd_busy;
    wire        o_rsp_stb;
    wire [33:0] o_rsp_word;

    // interface between the master and the slave
    reg         i_wb_err;
    reg         i_wb_stall;
    reg         i_wb_ack;
    reg  [31:0] i_wb_data;
    wire        o_wb_cyc;
    wire        o_wb_stb;
    wire [ 9:0] o_wb_addr;
    wire        o_wb_we;
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
        i_wb_ack,       // slave acknowledges the execution of the wishbone transaction
        i_wb_data,      // slave to master: this data has been read
        o_wb_cyc,       // activates the slave. The slave will only listen, when there is a cycle
        o_wb_stb,       // high during the strobe
        o_wb_addr,      // master to slave: this address is to read/write
        o_wb_we,        // master to slave: when 1 perform write, when 0 perform read
        o_wb_data       // master to slave: this is the data to write at the address
    );

    initial
    begin
        $monitor("At time %t, i_clk = %0d, o_wb_cyc = %d, o_wb_stb = %d, o_wb_we = %d, o_cmd_busy = %d, o_rsp_stb = %d, o_rsp_word = %h, o_wb_addr = %0h, o_wb_data = %0h",
            $time, i_clk, o_wb_cyc, o_wb_stb, o_wb_we, o_cmd_busy, o_rsp_stb, o_rsp_word, o_wb_addr, o_wb_data);
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
        #10 i_reset = 1'b0;

        //
        // To write data, first set the address via a write command.
        // The master internally transitions into the WAITING STATE.
        // Then set the data to write.
        // The master transitions into the WAITING STATE and waits for the
        // slave to answer
        //

        //
        // Prepare a write request - specify address
        //

        $display("write - set address");

        i_cmd_stb = 1; // without a strobe, the master will not decode the command
        // formulate a write command
        // set new base address without increment feature
        i_cmd_word = { 2'b10, 1'b0, 1'b1, 30'b101010101010101010101010101010 };

        #10;

        //
        // Prepare a write request - specify data
        //

        $display("write - set data");

        i_cmd_stb = 1; // without a strobe, the master will not decode the command
        i_cmd_word = { 2'b01, 32'hAABBCCDD }; // set data to write

        #10

        //
        // slave acknowledges
        //

        $display("write - slave acknowledges");

        i_wb_stall = 1'b0; // no stalls from the slave
        i_wb_ack = 1'b1; // slave acknowledges

        // slave presents data - for writes, this is the default value

        //
        // host disables all transactions, master goes into the NO-STATE state!
        //

        i_cmd_stb = 0; // without a strobe, the master will not decode the command
        i_cmd_word = 0;

        // idle for a couple if ticks before performing a read
        #30;

        //
        // To read data, first set the address via a read command.
        // The master internally transitions into the WAITING STATE.
        // Then set the data to write.
        // The master transitions into the WAITING STATE and waits for the
        // slave to answer
        //

        $display("read - set address");

        i_cmd_stb = 1; // without a strobe, the master will not decode the command
        //i_cmd_word = { 2'b00, 30'b00101010101010101010101010101010 }; // set new base address without increment feature

        i_cmd_word = { 2'b00, 10'b1010101010 }; // set new base address without increment feature

        #10

        //
        // slave acknowledges
        //

        $display("read - slave acknowledges");

        i_wb_stall = 1'b0; // no stalls from the slave
        i_wb_ack = 1'b1; // slave acknowledges

        // slave returns data that has been read
        i_wb_data = 32'h11223344;

        #10

        //
        // host disables all transactions, master goes into the NO-STATE state!
        //

        i_cmd_stb = 0; // without a strobe, the master will not decode the command
        i_cmd_word = 0;

        #50;

        $finish;

    end

    // generate clock to sequence tests
    always
    begin
        $display("tick %d", $time);
        i_clk <= 1;
        #5;
        i_clk <= 0;
        #5;
    end

endmodule