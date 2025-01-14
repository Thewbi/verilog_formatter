module dff_sreset(
 input  logic d, clk, reset_n,
 output logic q
 );      
always_ff@(posedge clk)
 if(reset_n == 1'b0)
 q <= 1'b0;
 else
 q <= d; 
endmodule