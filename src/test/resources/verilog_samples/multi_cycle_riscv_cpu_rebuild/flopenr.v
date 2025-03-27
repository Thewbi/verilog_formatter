// flip flop with enable and reset
module flopenr #(parameter WIDTH = 32) (

    // DEBUG id of this instance
    input wire[2:0] id,

    // clock and reset
    input wire clk,
    input wire resetn,

    input wire en,
    input wire [WIDTH-1:0] d,

    // output
    output reg [WIDTH-1:0] q

);

    //always @* // using the * option causes a combinational loop with nextpnr
    always @(posedge clk, negedge resetn)
    begin

        if (resetn == 0)
        begin
            //$display("[flopenr %d] reset", id);
            q = 0;
        end
        else if (en)
        begin
            //$display("[flopenr %d] set 0x%h", id, d);

            // if (id == 3'b000)
            // begin
            //     //$display("[flopenr CurrPC] q:0x%08h <- d:0x%08h", q, d);
            // end

            // if (id == 3'b001)
            // begin
            //     //$display("[flopenr OldPC] q:0x%08h <- d:0x%08h", q, d);
            // end

            // if (id == 3'b010)
            // begin
            //     //$display("[flopenr Instr] q:0x%08h <- d:0x%08h", q, d);
            // end

            q = d;
        end
        else
        begin

            //$display("[flopenr %d] hold 0x%h", id, q);
            q = q;
        end

    end

endmodule