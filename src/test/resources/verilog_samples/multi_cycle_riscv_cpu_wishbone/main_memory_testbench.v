module main_memory_testbench();

    // logic [31:0] a, b;
    // logic [31:0] y;

    localparam MEMORY_DEPTH = 1024;

    reg i_clk;

    // // custom interface to memory for direct access of instructions
    // wire [$clog2(MEMORY_DEPTH)-1:0] i_inst_addr;
    // wire [31:0]                     o_inst_out;
    // wire                            i_stb_inst; // request for instruction
    // wire                            o_ack_inst; // ack (high if new instruction is now on the bus)

    // wishbone Interface
    reg                             i_wb_cyc;
    reg                             i_wb_stb;
    reg                             i_wb_we;
    reg [$clog2(MEMORY_DEPTH)-1:0]  i_wb_addr;
    reg [31:0]                      i_wb_data;
    reg [3:0]                       i_wb_sel;
    wire                            o_wb_ack;
    wire                            o_wb_stall;
    wire [31:0]                     o_wb_data;

    // instantiate device under test
    main_memory mem(
        i_clk,

        // // custom interface to memory for direct access of instructions
        // i_inst_addr,
        // o_inst_out,
        // i_stb_inst,
        // o_ack_inst,

        // wishbone interface
        i_wb_cyc,   // cycle
        i_wb_stb,   // strobe
        i_wb_we,    // i_wb_we = 1 is a write operation, i_wb_we = 0 is a read operation
        i_wb_addr,  // address to read or write
        i_wb_data,  // data to write
        i_wb_sel,   // indexes into the data to write
        o_wb_ack,   // slave acknowledges operation
        o_wb_stall, // slave stalls the transaction
        o_wb_data   // data from the slave (the read data during a read operation)
    );

    initial
    begin
        //$monitor("At time %t, i_clk = %0d, o_wb_data = %0h, o_inst_out = %0d", $time, i_clk, o_wb_data, o_inst_out);
        $monitor("At time %t, i_clk = %0d, o_wb_data = %0h", $time, i_clk, o_wb_data);
    end

    // initialize test
    initial
    begin

        $display("start");
        i_clk <= 0;

        #10;
        $display("");

        //
        // Write
        //

        // set address to write data into the memory at
        i_wb_addr = 32'h00;
        // set data to write into the memory
        i_wb_data = 32'hAABBCCDD;
        // fill indexes into wb_data to show where data to be written is located
        i_wb_sel[0] = 1'b1;
        i_wb_sel[1] = 1'b1;
        i_wb_sel[2] = 1'b1;
        i_wb_sel[3] = 1'b1;

        // start wishbone cycle and strobe
        i_wb_cyc = 1'b1;
        i_wb_stb = 1'b1;

        // write enable the wishbone slave - perform a write
        i_wb_we = 1'b1;

        #10;
        $display("");

        //
        // read
        //

        // set address to read data out of the memory at
        i_wb_addr = 32'h00;
        // set data to write into the memory
        i_wb_data = 32'h00;

        // read enable the wishbone slave - perform a read
        i_wb_we = 1'b0;

        // start wishbone cycle and strobe
        i_wb_cyc = 1'b1;
        i_wb_stb = 1'b1;

        #10
        $display("");

        //
        // stop transaction
        //

        // start wishbone cycle and strobe
        i_wb_cyc = 1'b0;
        i_wb_stb = 1'b0;

        #10
        $display("");
        $display("finish");

        $finish;

    end

    always @(posedge o_wb_ack)
    begin
        $display("ack received");

        // stop wishbone cycle and strobe
        i_wb_cyc = 1'b0;
        i_wb_stb = 1'b0;

        // write disable the wishbone slave
        i_wb_we = 1'b0;
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

    // check results
    always @(negedge i_clk)
    begin
        if ($time >= 200)
        begin
            $display("Simulation succeeded");
            $stop;
            $finish;
        end
    end

    // initial
    //     begin
    //         a <= 0; // non-blocking, evaluation of rhs happens directly, assignment takes place in NBA region
    //         b <= 0; // non-blocking
    //         #5
    //         a <= 1; // non-blocking
    //         b <= 2; // non-blocking
    //     end

endmodule