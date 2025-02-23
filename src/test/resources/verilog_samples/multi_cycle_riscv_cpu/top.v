module top(
    input wire clk,
    input wire reset
    //output wire [31:0] WriteData,   // the top module outputs the current WriteData value for debugging in the testbench
    //output wire [31:0] DataAdr,     // the top module outputs the current DataAdr value for debugging in the testbench
    //output wire MemWrite            // the top module outputs the current MemWrite value for debugging in the testbench

    // // interface between the host and the master
    // // TODO: these signals are exposed for testing for now so that the testbenach can send stimuli in.
    // // If everything works, these signals have to be produced by the CPU
    // input wire          cmd_stb,
    // input wire [33:0]   cmd_word,
    // output wire         cmd_busy,
    // output wire         rsp_stb,
    // output wire [33:0]  rsp_word
);

    // reg [3:0] wb_sel;

    initial
        begin
            $display("Hello, World");
            $monitor("[TOP.v] At time %t, PC = %h (%0d)", $time, PC, PC);

            // // fill indexes into wb_data to show where data to be written is located
            // // In this case all four bytes of the word are written
            // wb_sel[0] = 1'b1;
            // wb_sel[1] = 1'b1;
            // wb_sel[2] = 1'b1;
            // wb_sel[3] = 1'b1;
        end

    initial
        begin
            // $monitor() has to be called only a single time but does as it's name suggests from that point on.
            // $monitor() will display new output, whenever one of the monitored signals change.
            // In a sense it monitors all signals and produces output when there is any change.
            $monitor("[TOP.v] At time %t, clk = %0d, rsp_word = %0h",
                $time, clk, rsp_word);
        end

    wire [31:0] PC;
    wire [31:0] Instr;

    wire [31:0] WriteData;
    wire [31:0] ReadData;

    wire        cmd_stb;
    wire [33:0] cmd_word;
    wire        cmd_busy;
    wire        rsp_stb;
    wire [33:0] rsp_word;

    // instantiate processor (contains controller and datapath)
    //riscvsingle rvsingle(clk, reset, PC, Instr, MemWrite, DataAdr, WriteData, ReadData);

    riscv_multi rvmulti(
        PC,
        // // memory access
        // cmd_stb,
        // cmd_word,
        // cmd_busy,
        // rsp_stb,
        // rsp_word,    // [in] data read from memory (this might be the next instruction or data)

        WriteData,
        ReadData
    );

endmodule