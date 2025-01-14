 module dff_areset(
 input  logic d, clk, reset_n,
 output logic q
 );      
always_ff@(posedge clk, negedge reset_n)
 if(reset_n == 0)
 q <= 0;
 else
 q <= d; 
endmodule