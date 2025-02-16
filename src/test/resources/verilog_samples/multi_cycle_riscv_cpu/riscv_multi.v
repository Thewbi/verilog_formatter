module riscv_multi();

    // TODO: use the register and immediate offset to compute the target address
    // and encode that target address into the command for the wishbone master.
    controller ctr(
        Instr[6:0],
        Instr[14:12],
        Instr[30],
        Zero,
        ResultSrc,
        MemWrite, // this signal says wether to read or write. Build this into the command for the wishbone master. whishbone_master.i_cmd_word[33:32] == 2'b00 for read and 2'b01 for write
        PCSrc,
        ALUSrc,
        RegWrite,
        Jump,
        ImmSrc,
        ALUControl);

    datapath dp(
        clk,
        reset,
        ResultSrc,
        PCSrc,
        ALUSrc,
        RegWrite,
        ImmSrc,
        ALUControl,
        Zero,
        PC,
        Instr,
        ALUResult,
        WriteData, // how to replace this by the wishbone master??? Connect whishbone_master.i_cmd_word here. This is where the master reads the data to write from
        ReadData // how to replace this by the wishbone master??? Connect whishbone_master.o_rsp_word here! This is where the master returns data.
        );

endmodule