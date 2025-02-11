// component alu
// port(a, b: in STD_LOGIC_VECTOR(31 downto 0);
// ALUControl: in STD_LOGIC_VECTOR(2 downto 0);
// ALUResult: buffer STD_LOGIC_VECTOR(31 downto 0);
// Zero: out STD_LOGIC);
// end component;

module alu(
    input   wire    [31:0]      a,
    input   wire    [31:0]      b,
    input   wire    [2:0]       ALUControl,
    input   wire    [31:0]      ALUResult,
    output   wire               Zero);

endmodule