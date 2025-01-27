module design_top;
    always @(posedge i_clk, negedge i_rst_n) begin
         if(!i_rst_n) ce <= 0;
         else if((i_alu_change_pc || i_writeback_change_pc) && !(i_stall || stall_fetch)) ce <= 0; //do pipeline bubble when need to change pc so that next stages will be disabled
         else ce <= 1;                                                  //and will not execute the instructions already inside the pipeline
     end
endmodule