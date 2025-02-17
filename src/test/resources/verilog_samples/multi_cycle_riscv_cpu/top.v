module top(
    input wire clk,
    input wire reset,
    //output wire [31:0] WriteData,   // the top module outputs the current WriteData value for debugging in the testbench
    //output wire [31:0] DataAdr,     // the top module outputs the current DataAdr value for debugging in the testbench
    //output wire MemWrite            // the top module outputs the current MemWrite value for debugging in the testbench

    // interface between the host and the master
    input wire          cmd_stb,
    input wire [33:0]   cmd_word,
    output wire         cmd_busy,
    output wire         rsp_stb,
    output wire [33:0]  rsp_word
    );

    reg [3:0] wb_sel;

    initial
    begin
        $display("Hello, World");
        $monitor("At time %t, PC = %h (%0d)", $time, PC, PC);

        // fill indexes into wb_data to show where data to be written is located
        // In this case all four bytes of the word are written
        wb_sel[0] = 1'b1;
        wb_sel[1] = 1'b1;
        wb_sel[2] = 1'b1;
        wb_sel[3] = 1'b1;
    end

    wire [31:0] PC;
    wire [31:0] Instr;
    wire [31:0] ReadData;

    // instantiate processor (contains controller and datapath)
    //riscvsingle rvsingle(clk, reset, PC, Instr, MemWrite, DataAdr, WriteData, ReadData);

    // TODO: reactivate this
    //riscv_multi rvmulti();

    // instruction memory - initial memory for simulation is loaded in imem.v
    //imem imem(PC, Instr);

    // data memory
    //dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData);





    // // interface between the host and the master
    // wire            cmd_stb;
    // wire [33:0]     cmd_word;
    // wire            cmd_busy;
    // wire            rsp_stb;
    // wire [33:0]     rsp_word;

    // interface between the master and the slave
    wire            wb_err;         // an error occured, the wishbone master has to reset
    wire            wb_stall;       // slave stalls
    wire            wb_ack;         // slave acknowledges the execution of the wishbone transaction
    wire [31:0]     wb_data;        //
    wire            wb_cyc;         //
    wire            wb_stb;         //
    wire [ 9:0]     wb_addr;        //
    wire            wb_we;          //
    wire [31:0]     wb_data_output; //



    // wishbone master
    wishbone_master master(

        // clock and reset
        clk,            // i_clk
        reset,          // i_reset,

        // interface between the host and the master
        cmd_stb,        // i_cmd_stb,
        cmd_word,       // i_cmd_word,
        cmd_busy,       // o_cmd_busy,      // the master is busy processing a command
        rsp_stb,        // o_rsp_stb,       // when this value is 1, then the master is ready to start a strobe
        rsp_word,       // o_rsp_word,      // (34 bits) data that has been read (or dummy data on a read)

        // interface between the master and the slave
        wb_err,
        wb_stall,
        wb_ack,
        wb_data,
        wb_cyc,
        wb_stb,
        wb_addr,
        wb_we,
        wb_data_output
    );

    // wishbone slave for memory
    main_memory mem(

        clk,

        // // debug interface (Access to memory without wishbone)
        // i_inst_addr,
        // o_inst_out,
        // i_stb_inst,
        // o_ack_inst,

        // wishbone interface
        wb_cyc,         // cycle
        wb_stb,         // strobe
        wb_we,          // 1 = write, 0 = read
        wb_addr,        // address to read to / write from
        wb_data_output, // data to write
        wb_sel,         // index into data to write
        wb_ack,         // slave acknowledge
        wb_stall,       // slave stall
        wb_data         // slave returns read data
    );

endmodule