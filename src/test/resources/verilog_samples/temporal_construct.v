module design_top;

always @(posedge i_clk, negedge i_rst_n) begin

        if(!i_rst_n) begin
            o_ce <= 0;
            o_iaddr <= PC_RESET;
            prev_pc <= PC_RESET;
            stalled_inst <= 0;
            o_pc <= 0;
        end


        else begin


            if((ce && !stall_bit) || (stall_bit && !o_ce && ce) || i_writeback_change_pc) begin //update registers only if this stage is enabled and next stages are not stalled
                o_iaddr <= iaddr_d;
                o_pc <= stall_q? stalled_pc:prev_pc;
                o_inst <= stall_q? stalled_inst:i_inst;
            end

            /*
            if(i_flush && !stall_bit) begin //flush this stage(only when not stalled) so that clock-enable of next stage is disabled at next clock cycle
                o_ce <= 0;
            end
            else if(!stall_bit) begin //clock-enable will change only when not stalled
                o_ce <= ce_d;
            end
            //if this stage is stalled but next stage is not, disable
            //clock enable of next stage at next clock cycle (pipeline bubble)
            else if(stall_bit && !i_stall) o_ce <= 0;


            stall_q <= i_stall || stall_fetch; //raise stall when any of 5 stages is stalled

            //store both instruction and PC before stalling so that we can
            //come back to these values when we need to return from stall
            if(stall_bit && !stall_q) begin
                stalled_pc <= prev_pc;
                stalled_inst <= i_inst;
            end
            prev_pc <= o_iaddr; //this is the first delay to align the PC to the pipeline

            */
        end

    end

endmodule