module top(
    input wire clk, reset,
    output wire [31:0] WriteData, DataAdr,
    output wire MemWrite);

    initial
    begin
        PC = 32'h00;
        $display("Hello, World");
        $monitor("At time %t, PC = %h (%0d)", $time, PC, PC);
    end

    wire [31:0] PC, Instr, ReadData;

    // instantiate processor
    riscvsingle rvsingle(clk, reset, PC, Instr, MemWrite, DataAdr, WriteData, ReadData);

    // instruction memory - initial memory for simulation is loaded in imem.v
    imem imem(PC, Instr);

    // data memory
    dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData);

endmodule