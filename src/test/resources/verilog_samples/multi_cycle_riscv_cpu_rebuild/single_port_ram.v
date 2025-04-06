module single_port_ram (din, addr, write_en, clk, resetn, dout); // 512x8

    parameter addr_width = 9;
    parameter data_width = 8;

    //parameter addr_width = 32;
    //parameter data_width = 32;

    input [addr_width-1:0] addr;
    input [data_width-1:0] din;
    input write_en;
    input clk;
    input resetn;
    output [data_width-1:0] dout;

    reg [data_width-1:0] dout; // register for output.
    reg [data_width-1:0] RAM [(1<<addr_width)-1:0];

    always @(posedge clk)
    begin
        if (write_en)
        begin
            RAM[(addr)] <= din;
        end
        dout = RAM[addr]; // output register controlled by clock.
    end

    always @(posedge clk, negedge resetn)
    begin
        if (resetn == 0)
        begin

            // Application
            // loop 3 times

            RAM[9'h00] = 32'h00000293; // 0x00 inita:        addi x5, x0, 0x0
            RAM[9'h04] = 32'h00000313; // 0x04              addi x6, x0, 0x0
            RAM[9'h08] = 32'h000003b7; // 0x08              lui x7, 0
            RAM[9'h0C] = 32'h00338393; // 0x0C              addi x7, x7, 3
            RAM[9'h10] = 32'h00728663; // 0x10 loop_head:    beq x5, x7, 12/0xC     # if (x5 == x7) jump to loop_end

            RAM[9'h14] = 32'h00128293; // 0x14              addi x5, x5, 1
            RAM[9'h18] = 32'hff9ff06f; // 0x18               jal x0, -8          # jal loop head
            //RAM[32'h1C] = 32'h03c02303; // 0x1C loop_end:     lw x6, 60(x0)
            RAM[9'h1C] = 32'h03402303; // 0x1C loop_end:     lw x6, 52(x0)
            RAM[9'h20] = 32'h00134313; // 0x20              xori x6, x6, 1
            RAM[8'h24] = 32'h02602e23; // 0x24              sw x6, 60(x0)

            RAM[9'h28] = 32'hfd9ff06f; // 0x28              jal x0, -40         # jal inita
            RAM[9'h2C] = 32'h00000000; // 0x2C
            RAM[9'h30] = 32'h00000000; // 0x30
            RAM[9'h34] = 32'h00000000; // toggle here.
            RAM[9'h38] = 32'h00000000;

        end
    end

endmodule