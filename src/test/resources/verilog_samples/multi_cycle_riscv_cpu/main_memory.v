// This is a wishbone slave for RAM memory (instructions and data)
//
// Instruction and data memory (combined memory)
// With wishbone interface
module main_memory #(parameter MEMORY_DEPTH=1024) (
    input wire i_clk,
    // Instruction Memory
    input wire[$clog2(MEMORY_DEPTH)-1:0] i_inst_addr,
    output reg[31:0] o_inst_out,
    input wire i_stb_inst, // request for instruction
    output reg o_ack_inst, // ack (high if new instruction is now on the bus)
    // Data Memory
    input wire i_wb_cyc,
    input wire i_wb_stb,
    input wire i_wb_we,
    input wire[$clog2(MEMORY_DEPTH)-1:0] i_wb_addr,
    input wire[31:0] i_wb_data,
    input wire[3:0] i_wb_sel, // wb_sel is basically an index into wb_data and shows,
                              // where data inside wb_data is located to act on during write cycles
    output reg o_wb_ack,
    output wire o_wb_stall,
    output reg[31:0] o_wb_data
);
    reg[31:0] memory_regfile[MEMORY_DEPTH/4 - 1:0];

    // never stall
    assign o_wb_stall = 0;

    // initialize memory to zero
    initial
    begin
        o_ack_inst <= 0;
        o_wb_ack <= 0;
        o_inst_out <= 0;
    end

    // reading must be registered to be inferred as block ram
    always @(posedge i_clk)
    begin

        $display("[mem] reading");

        o_ack_inst <= i_stb_inst; // go high next cycle after receiving request (data o_inst_out is also sent at next cycle)
        o_wb_ack <= i_wb_stb && i_wb_cyc;
        o_inst_out <= memory_regfile[{i_inst_addr>>2}]; // read instruction
        o_wb_data <= memory_regfile[i_wb_addr[$clog2(MEMORY_DEPTH)-1:2]]; // read data
    end

    // write data
    always @(posedge i_clk)
    begin

        if (i_wb_we && i_wb_stb && i_wb_cyc) begin

            $display("[mem] writing");

            // wb_sel is an index into the wb_data array and is used during write cycles
            // The slave will only access data from wb_data when it is indexed by wb_sel
            if(i_wb_sel[0])
                memory_regfile[i_wb_addr[$clog2(MEMORY_DEPTH)-1:2]][7:0] <= i_wb_data[7:0];
            if(i_wb_sel[1])
                memory_regfile[i_wb_addr[$clog2(MEMORY_DEPTH)-1:2]][15:8] <= i_wb_data[15:8];
            if(i_wb_sel[2])
                memory_regfile[i_wb_addr[$clog2(MEMORY_DEPTH)-1:2]][23:16] <= i_wb_data[23:16];
            if(i_wb_sel[3])
                memory_regfile[i_wb_addr[$clog2(MEMORY_DEPTH)-1:2]][31:24] <= i_wb_data[31:24];
        end
    end

endmodule