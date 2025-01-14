module dff_2bit(
    input  logic [1:0] d, 
    input logic clk,
    output logic [1:0] q
);      
    always_ff@(posedge clk) begin
        q <= d;
    end
endmodule