module mod_name;
always @(posedge CLK) begin
    o_pc <= stall_q ? stalled_pc : prev_pc;
end
endmodule