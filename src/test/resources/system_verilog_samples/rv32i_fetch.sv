/*
The rv32i_fetch module is primarily for fetching instructions from the memory
and preparing them for the decode stage of the pipeline.

The module is responsible for managing
- the Program Counter (PC),
- fetching instructions,
- and controlling the pipeline.

Below are the key functions of the rv32i_fetch module:
 - Program Counter (PC) management: The module maintains a Program Counter (PC)
    that holds the address of the current instruction in memory. The PC is
    initialized at the reset vector address (specified by the parameter PC_RESET),
    and it is incremented or updated based on the instruction flow control,
    such as branches, jumps, or traps.
 - Instruction fetching: The module fetches the instruction from memory based on
    the current PC value. It sends a request for a new instruction (o_stb_inst)
    when the fetch stage is enabled (ce), and waits for an acknowledgment
    (i_ack_inst) from the memory. The fetched instruction (i_inst) is then sent
    to the pipeline (o_inst).
 - Pipeline control: The rv32i_fetch module manages the pipeline by controlling
    clock enable (o_ce) signals for the next stage. It can stall the fetch stage
    (stall_fetch) when the next stages are stalled (i_stall), a requested
    instruction has not yet been acknowledged, or when there is no request for a
    new instruction. Moreover, it can create pipeline bubbles when the PC needs
    to be changed, disabling clock enable signals for the next stages, ensuring
    no instructions are executed during this period.
 - PC control: The module updates the PC based on the control signals received
    from other stages in the pipeline. It can update the PC with a new address
    (i_writeback_next_pc) when handling traps, or with the address of a taken
    branch or jump (i_alu_next_pc). The fetch stage can be stalled during this
    process to prevent instructions from being executed in the pipeline.
  - Handling stalls and flushes: The rv32i_fetch module can stall the fetch
    stage based on different conditions and store the current PC and instruction
    values. When the stall condition is resolved, it can return to the stored
    values and continue fetching instructions. The module can also flush the
    fetch stage when required (i_flush), disabling the clock enable signal
    for the next stage, effectively clearing any pending instructions.
*/
//`timescale 1ns / 1ps
//`default_nettype none
//`include "rv32i_header.vh"

module rv32i_fetch #(parameter PC_RESET = 32'h00_00_00_00) (

    input wire i_clk, i_rst_n,

    output reg[31:0] o_iaddr,   // instruction memory address (the retrieved instruction will appear on i_inst)
    output reg[31:0] o_pc,      // PC value of current instruction (which external component does need the PC?)
    input wire[31:0] i_inst,    // retrieved instruction from Memory
    output reg[31:0] o_inst,    // instruction sent to pipeline
    output wire o_stb_inst,     // request for instruction. stb stands for the wishbone strobe. wishbone is part of the picture sind it controls access to the instruction memory.
    input wire i_ack_inst,      // ack (high if new instruction is now on the bus, when the memory has loaded the data)

    // PC Control
    input wire i_writeback_change_pc,       // high when PC needs to change when going to trap or returning from trap
    input wire[31:0] i_writeback_next_pc,   // next PC due to trap
    input wire i_alu_change_pc,             // high when PC needs to change for taken branches and jumps
    input wire[31:0] i_alu_next_pc,         // next PC due to branch or jump

    // Pipeline Control
    output reg o_ce,        // output clk enable for pipeline stalling of next stage. This signal is connected to the next stage.
                            // This stage has the power to stall the next stage (bubbling a stall through the pipeline)
                            // If this stage wants to stall the next stage, it sets this output low.
    input wire i_stall,     // stall logic for whole pipeline
    input wire i_flush      // flush this stage
);

    reg[31:0] iaddr_d, prev_pc, stalled_inst, stalled_pc;
    reg ce, ce_d;
    reg stall_fetch;
    reg stall_q;

    // stall this stage when:
    // - next stages are stalled
    // - you have requested the instruction but no ack yet from memory (stb == strobe, see wishbone bus signals and protocol)
    // - you dont have a request at all (no request then no instruction to execute for this stage)
    wire stall_bit = stall_fetch || i_stall || (o_stb_inst && !i_ack_inst) || !o_stb_inst;

    // request for new instruction if this stage is enabled
    assign o_stb_inst = ce;

    // ce (clock enable) logic for fetch stage
    always @(posedge i_clk, negedge i_rst_n) begin
         if (!i_rst_n)
            ce <= 0;
         else if ((i_alu_change_pc || i_writeback_change_pc) && !(i_stall || stall_fetch))
            ce <= 0;    // do pipeline bubble when need to change PC so that next stages will be disabled
                        // and will not execute the instructions already inside the pipeline
                        // For branch instructions, when the branch is taken the PC now is at a completely different
                        // location and the originally fetched instruction might not be accurate any more. The pipeline
                        // now hast to perform a complete refresh so it starts processing anew at the jump destination.
                        // Part of that refresh is to wait in the fetch stage until the jump is done.
         else
            ce <= 1;
    end

    // this is the pipeline control. This stalls the entire pipeline and performs pipeline bubbling
    always @(posedge i_clk, negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_ce <= 0;
            o_iaddr <= PC_RESET;
            prev_pc <= PC_RESET;
            stalled_inst <= 0;
            o_pc <= 0;
        end
        else begin

            // update registers only if this stage is enabled and next stages are not stalled
            if ((ce && !stall_bit) || (stall_bit && !o_ce && ce) || i_writeback_change_pc) begin

                // use the new pc (= iaddr_d) to fetch the next instruction
                // some external circuitry will resolve o_iaddr into an instruction
                //
                // Question: does the addressed instruction resolve immediately or
                // is i_inst holding the instruction of a previous instruction resolution?
                o_iaddr <= iaddr_d;
                o_pc <= stall_q ? stalled_pc : prev_pc;
                o_inst <= stall_q ? stalled_inst : i_inst; // the instruction i_inst has been resolved from o_iaddr

            end

            // flush this stage (only when not stalled) so that clock-enable of next stage is disabled at next clock cycle
            if (i_flush && !stall_bit) begin
                o_ce <= 0;
            end
            // clock-enable will change only when not stalled
            else if (!stall_bit) begin
                o_ce <= ce_d;
            end
            // if this stage is stalled but next stage is not, disable
            // clock enable of next stage at next clock cycle (pipeline bubble)
            else if (stall_bit && !i_stall)
                o_ce <= 0;

            // raise stall when any of 5 stages is stalled
            stall_q <= i_stall || stall_fetch;

            // store both instruction and PC before stalling so that we can
            // come back to these values when we need to return from stall
            if (stall_bit && !stall_q) begin
                stalled_pc <= prev_pc;
                stalled_inst <= i_inst;
            end

            // this is the first delay to align the PC to the pipeline
            prev_pc <= o_iaddr;
        end
    end

    // logic for PC and pipeline clock_enable control
    always @* begin
        iaddr_d = 0;
        ce_d = 0;
        stall_fetch = i_stall; // stall when retrieving instructions need wait time

        // prepare next PC.
        // when changing pc, then do a pipeline bubble
        // to disable the ce of next stage
        if (i_writeback_change_pc) begin
            iaddr_d = i_writeback_next_pc;
            ce_d = 0;
        end
        else if (i_alu_change_pc) begin
            iaddr_d  = i_alu_next_pc;
            ce_d = 0;
        end
        else begin
            iaddr_d = o_iaddr + 32'd4;
            ce_d = ce;
        end
    end

endmodule