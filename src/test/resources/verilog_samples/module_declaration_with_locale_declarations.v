//module rv32i_core #(parameter PC_RESET = 32'h00_00_00_00, TRAP_ADDRESS = 0, ZICSR_EXTENSION = 1) (
//module rv32i_core #(PC_RESET = 32'h00_00_00_00, TRAP_ADDRESS = 0, ZICSR_EXTENSION = 1) (
module rv32i_core #(parameter PC_RESET = 32'h00_00_00_00, parameter TRAP_ADDRESS = 0, parameter ZICSR_EXTENSION = 1) (
    input wire i_clk, i_rst_n
);

    // wires for basereg
    wire[31:0] rs1_orig,rs2_orig;
    wire[31:0] rs1,rs2;
    wire ce_read;

endmodule