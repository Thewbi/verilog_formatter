module top(
    input wire clk, reset,
    output wire [31:0] WriteData, DataAdr,
    output wire MemWrite);

    initial
    begin
      $display("Hello, World");
      $monitor("At time %t, PC = %h (%0d)", $time, PC, PC);
    end

    wire [31:0] PC, Instr, ReadData;

    // instantiate processor
    riscvsingle rvsingle(clk, reset, PC, Instr, MemWrite, DataAdr, WriteData, ReadData);

    // instruction and data memory
    imem imem(PC, Instr);
    dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData);

    // initial begin
    //     $readmemh("progmem.txt", progmem);
    // end



endmodule