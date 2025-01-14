module dff_2bit(
    input  logic [1:0] d, 
    input logic clk,
    output logic [1:0] q
);      
    always_ff@(posedge clk) begin
        q[0] <= d[0];
        q[1] <= d[1];
    end
endmodule