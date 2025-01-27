module mod_name;

always @(posedge CLK) begin

if((ce && !stall_bit) || (stall_bit && !o_ce && ce) || i_writeback_change_pc) begin //update registers only if this stage is enabled and next stages are not stalled
                o_iaddr <= iaddr_d;
                o_pc <= stall_q? stalled_pc:prev_pc;
                o_inst <= stall_q? stalled_inst:i_inst;
            end

end

endmodule