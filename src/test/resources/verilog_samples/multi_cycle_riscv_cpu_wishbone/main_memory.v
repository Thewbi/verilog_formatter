`define TRACE_MEMORY 1

// This is a wishbone slave for RAM memory (instructions and data)
//
// Instruction and data memory (combined memory)
// With wishbone interface
module main_memory #(parameter MEMORY_DEPTH=1024) (

    input wire i_clk,

    // // custom interface for accessing instructions directly. I think this is some kind of debug interface
    // input   wire [$clog2(MEMORY_DEPTH)-1:0] i_inst_addr,
    // output  reg  [31:0]                     o_inst_out,
    // input   wire                            i_stb_inst, // request for instruction
    // output  reg                             o_ack_inst, // ack (high if new instruction is now on the bus)

    // wishbone interface
    input   wire                            i_wb_cyc,
    input   wire                            i_wb_stb,
    input   wire                            i_wb_we,    // write_enable, 1 = write, 0 = read
    input   wire [$clog2(MEMORY_DEPTH)-1:0] i_wb_addr,
    input   wire [31:0]                     i_wb_data,
    // wb_sel is basically an index into wb_data and shows,
    // where data inside wb_data is located to act on during write cycles
    input   wire [3:0]                      i_wb_sel, // this could be hardcoded to an array that has all elements set to 1 so all elements are indexed
    output  reg                             o_wb_ack,
    output  wire                            o_wb_stall,
    output  reg [31:0]                      o_wb_data   // this memory slave will return read memory here
);

    reg [31:0] memory_regfile[MEMORY_DEPTH/4 - 1:0]; // 1024/4 = 256

    initial
    begin
        // $display("Reading file into memory for simulation!");
        // $readmemh("progmem.txt", memory_regfile);

        // //
        // // Harris & Harris, test example code
        // //

        // memory_regfile[32'd00] = 32'h00500113;  // addi x2, x0, 5
        // memory_regfile[32'd04] = 32'h00c00193;  // addi x3, x0, 12
        // memory_regfile[32'd08] = 32'hFF718393;  // addi x7, x3, -9
        // memory_regfile[32'd12] = 32'h0023E233;  // or x4, x7, x2
        // memory_regfile[32'd16] = 32'h0041F2B3;  // and x5, x3, x4
        // memory_regfile[32'd20] = 32'h004282B3;  // add x5, x5, x4
        // memory_regfile[32'd24] = 32'h02728863;  // beq x5, x7, end      # should NOT be taken
        // memory_regfile[32'd28] = 32'h0041A233;  // slt x4, x3, x4
        // memory_regfile[32'd32] = 32'h00020463;  // beq x4, x0, around   # should be taken
        // memory_regfile[32'd36] = 32'h00000293;  // addi x5, x0, 0
        // memory_regfile[32'd40] = 32'h0023A233;  // slt x4, x7, x2
        // memory_regfile[32'd44] = 32'h005203B3;  // add x7, x4, x5
        // memory_regfile[32'd48] = 32'h402383B3;  // sub x7, x7, x2
        // memory_regfile[32'd52] = 32'h0471AA23;  // sw x7, 84(x3)
        // memory_regfile[32'd56] = 32'h06002103;  // lw x2, 96(x0)
        // memory_regfile[32'd60] = 32'h005104B3;  // add x9, x2, x5
        // memory_regfile[32'd64] = 32'h008001EF;  // jal x3, end
        // memory_regfile[32'd68] = 32'h00100113;  // addi x2, x0, 1
        // memory_regfile[32'd72] = 32'h00910133;  // add x2, x2, x9
        // memory_regfile[32'd76] = 32'h0221A023;  // sw x2, 0x20(x3)
        // memory_regfile[32'd80] = 32'h00210063;  // beq x2, x2, done

        //
        // Harris & Harris, modified sample
        //

        memory_regfile[32'd00] = 32'h00500113;  // addi x2, x0, 5
        memory_regfile[32'd04] = 32'h00c00193;  // addi x3, x0, 12
        memory_regfile[32'd08] = 32'hFF718393;  // addi x7, x3, -9
        memory_regfile[32'd12] = 32'h0023E233;  // or x4, x7, x2
        memory_regfile[32'd16] = 32'h0041F2B3;  // and x5, x3, x4
        memory_regfile[32'd20] = 32'h004282B3;  // add x5, x5, x4
        memory_regfile[32'd24] = 32'h02728863;  // beq x5, x7, end      # should NOT be taken
        memory_regfile[32'd28] = 32'h0041A233;  // slt x4, x3, x4
        memory_regfile[32'd32] = 32'h00020463;  // beq x4, x0, around   # should be taken
        memory_regfile[32'd36] = 32'h00000293;  // addi x5, x0, 0
        memory_regfile[32'd40] = 32'h0023A233;  // slt x4, x7, x2
        memory_regfile[32'd44] = 32'h005203B3;  // add x7, x4, x5
        memory_regfile[32'd48] = 32'h402383B3;  // sub x7, x7, x2
        memory_regfile[32'd52] = 32'h00000033;  // add x0, x0, x0
        memory_regfile[32'd56] = 32'h00000033;  // add x0, x0, x0
        memory_regfile[32'd60] = 32'h005104B3;  // add x9, x2, x5
        memory_regfile[32'd64] = 32'h00000033;  // add x0, x0, x0
        memory_regfile[32'd68] = 32'h00100113;  // addi x2, x0, 1
        memory_regfile[32'd72] = 32'h00910133;  // add x2, x2, x9
        memory_regfile[32'd76] = 32'h00000033;  // add x0, x0, x0
        memory_regfile[32'd80] = 32'h00210063;  // beq x2, x2, done
        memory_regfile[32'd84] = 32'h00000000;
        memory_regfile[32'd88] = 32'h00000000;

        // //
        // // beq test
        // //

        // memory_regfile[32'd00] = 32'h00940863; // beq x8, x9, 16
        // memory_regfile[32'd04] = 32'h00000033; // add x0, x0, x0
        // memory_regfile[32'd08] = 32'h00000033; // add x0, x0, x0
        // memory_regfile[32'd12] = 32'h00000033; // add x0, x0, x0
        // memory_regfile[32'd16] = 32'h00000033; // add x0, x0, x0
        // memory_regfile[32'd20] = 32'h00000033; // add x0, x0, x0
        // memory_regfile[32'd24] = 32'h00000033; // add x0, x0, x0
        // memory_regfile[32'd28] = 32'h00000033; // add x0, x0, x0
        // memory_regfile[32'd32] = 32'h00000033; // add x0, x0, x0
    end

    // never stall
    assign o_wb_stall = 0;

    // initialize memory to zero
    initial
    begin

        // debug interface
        // o_ack_inst <= 0;
        // o_inst_out <= 0;

        // wishbone interface
        o_wb_ack <= 0;
    end

//     always @(posedge i_clk)
//     begin
// `ifdef TRACE_MEMORY
//         $display("[mem] signals: i_wb_we: %d, i_wb_stb: %d, i_wb_cyc: %d", i_wb_we, i_wb_stb, i_wb_cyc);
// `endif
//     end

    // reading must be registered to be inferred as block ram
    always @(posedge i_clk)
    begin

        $display("[mem] signals: i_wb_we: %d, i_wb_stb: %d, i_wb_cyc: %d", i_wb_we, i_wb_stb, i_wb_cyc);

        // not write_enable means to read.
        if (!i_wb_we && i_wb_stb && i_wb_cyc)
            begin
`ifdef TRACE_MEMORY
                $display("[mem] reading. i_wb_addr = 0x%0h", i_wb_addr); // the i_wb_addr is generated in
`endif
                // debug interface
                // o_ack_inst  <= i_stb_inst; // go high next cycle after receiving request (data o_inst_out is also sent at next cycle)
                // o_inst_out  <= memory_regfile[{i_inst_addr >> 2}]; // read instruction

                // wishbone interface
                o_wb_ack    <= i_wb_stb && i_wb_cyc;
                o_wb_data   <= memory_regfile[i_wb_addr];
                //o_wb_data   <= memory_regfile[i_wb_addr[$clog2(MEMORY_DEPTH)-1:2]]; // read data
                //o_wb_data   <= memory_regfile[i_wb_addr[$clog2(MEMORY_DEPTH)-1:0]]; // read data
                //o_wb_data   <= memory_regfile[32'd4];

`ifdef TRACE_MEMORY
                $display("[mem] reading. o_wb_data = %08h", o_wb_data);
`endif
            end
        else
            begin
`ifdef TRACE_MEMORY
                $display("[mem] not reading");
`endif
            //o_wb_data <= 32'h12345678;
            end
    end

    // write data
    always @(posedge i_clk)
    begin

        if (i_wb_we && i_wb_stb && i_wb_cyc)
            begin
`ifdef TRACE_MEMORY
                $display("[mem] writing. i_wb_addr = %0h", i_wb_addr);
                $display("[mem] writing. A = %0h, B = %0h, C = %0h, D = %0h", i_wb_data[ 7: 0], i_wb_data[15: 8], i_wb_data[23:16], i_wb_data[31:24]);
`endif
                // wb_sel is an index into the wb_data array and is used during write cycles
                // The slave will only access data from wb_data when it is indexed by wb_sel
                if (i_wb_sel[0])
                begin
`ifdef TRACE_MEMORY
                    $display("[mem] writing A");
`endif
                    memory_regfile[i_wb_addr[$clog2(MEMORY_DEPTH)-1:2]][ 7: 0] = i_wb_data[ 7: 0];
                end
                if (i_wb_sel[1])
                begin
`ifdef TRACE_MEMORY
                    $display("[mem] writing B");
`endif
                    memory_regfile[i_wb_addr[$clog2(MEMORY_DEPTH)-1:2]][15: 8] = i_wb_data[15: 8];
                end
                if (i_wb_sel[2])
                begin
`ifdef TRACE_MEMORY
                    $display("[mem] writing C");
`endif
                    memory_regfile[i_wb_addr[$clog2(MEMORY_DEPTH)-1:2]][23:16] = i_wb_data[23:16];
                end
                if (i_wb_sel[3])
                begin
`ifdef TRACE_MEMORY
                    $display("[mem] writing D");
`endif
                    memory_regfile[i_wb_addr[$clog2(MEMORY_DEPTH)-1:2]][31:24] = i_wb_data[31:24];
                end

                $display("[mem] MEMORY CONTENT: %0h", memory_regfile[i_wb_addr[$clog2(MEMORY_DEPTH)-1:2]][31:0]);

                o_wb_ack <= 1'b1;
            end
        else
            begin
`ifdef TRACE_MEMORY
                $display("[mem] not writing");
`endif
            end

    end

endmodule