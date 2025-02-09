module dff_2bit(
    input  logic d0, d1,
    input logic clk,
    output logic q0, q1
);

    always_ff@(posedge clk) begin
        q0 <= d0;
        q1 <= d1;
    end

endmodule