// flip flop with enable and reset
module flopenr #(parameter WIDTH = 8) (
    input wire clk,
    input wire reset,
    input wire en,
    input wire [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q);

    always @(posedge clk, posedge reset)
    begin
        if (reset)
        begin
            $display("[flopenr] reset");
            q <= 0;
        end
        else if (en)
        begin
            $display("[flopenr] set %d", d);
            q <= d;
        end
    end

endmodule