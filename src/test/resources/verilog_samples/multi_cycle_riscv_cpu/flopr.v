// FLip Flop with reset
// on posedge of the clock, will store the value d
// on posedge of the clock, will return the current value q
module flopr #(parameter WIDTH = 8) (
    input wire clk, // clock input
    input wire reset, // reset input
    input wire [WIDTH-1:0] d, // d as in data. This is the input data
    output reg [WIDTH-1:0] q // this is the value stores in the flip flop
    );

    always @(posedge clk, posedge reset)
        if (reset)
            q <= 0;
        else
            q <= d;

endmodule