module top(
    input wire clk,
    input wire reset,
    output wire [31:0] WriteData,
    output wire [31:0] DataAdr,
    output wire MemWrite
    );

    initial
    begin
      $display("Hello, World");
      $monitor("At time %t, PC = %h (%0d)", $time, PC, PC);
    end

    wire [31:0] PC;
    wire [31:0] Instr;
    wire [31:0] ReadData;

    // instantiate processor (contains controller and datapath)
    //riscvsingle rvsingle(clk, reset, PC, Instr, MemWrite, DataAdr, WriteData, ReadData);
    riscv_multi rvmulti();

    // instruction memory - initial memory for simulation is loaded in imem.v
    //imem imem(PC, Instr);

    // data memory
    //dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData);

    // wishbone master
    wishbone_master master();

    // wishbone slave for memory
    main_memory mem();

endmodule