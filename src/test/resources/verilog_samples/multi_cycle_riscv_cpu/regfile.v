// RV32 register file for all 32 32-bit registers
// three ported register file
module regfile(
    input   wire        clk,    // clock
    input   wire        we3,    // write enable, register a3 is written with wd3
    input   wire [4:0]  a1,     // register 1 to read (no clock tick needed)
    input   wire [4:0]  a2,     // register 2 to read (no clock tick needed)
    input   wire [4:0]  a3,     // register to write
    input   wire [31:0] wd3,    // data value to write
    output  wire [31:0] rd1,    // the output where the value from register a1 appears
    output  wire [31:0] rd2     // the output where the value from register a2 appears
);

    reg [31:0] rf[31:0];

    // write third port on rising edge of clock (A3/WD3/WE3)
    //
    // Note: any write to register zero is actually executed.
    // Therefore, the read operation needs to return the hardcoded zero.
    always @(posedge clk)
    begin
        if (we3)
        begin
            $display("[regfile] WriteBack. a3=%d, wd3=%h", a3, wd3);
            rf[a3] <= wd3;
        end
    end

    // read two ports combinationally (= no clock edge / clock tick needed)
    // (A1/RD1, A2/RD2)
    // register 0 hardwired to 0 (if a1 or a2 or both are register 0, return a hardcoded 0)
    assign rd1 = (a1 != 0) ? rf[a1] : 0;
    assign rd2 = (a2 != 0) ? rf[a2] : 0;

endmodule