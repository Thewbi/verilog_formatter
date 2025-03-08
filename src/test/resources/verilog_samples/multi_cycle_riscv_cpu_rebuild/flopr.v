// Flip Flop with reset
// on posedge of the clock, will store the value d
// on posedge of the clock, will return the current value q
module flopr #(parameter WIDTH = 8) (
    input wire clk,             // clock input
    input wire reset,           // reset input
    input wire [WIDTH-1:0] d,   // [in] d as in data. This is the input data
    output reg [WIDTH-1:0] q    // [out] this is the value stores in the flip flop
);

    always @(posedge clk, posedge reset)
        if (reset)
        begin
            q <= 0;
        end
        else
        begin
            $display("[FLOPR] q:%08h <- d:%08h", q, d);
            q <= d;
        end

endmodule