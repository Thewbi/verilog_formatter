module dff(
    input  logic d,
    input logic clk,
    output logic q
);

    // The always_ffconstruct is used to describe synchronous logic (flip-flops or registers).
    // In the above example, the output is updated with every rising edge of the clock signal.
    // Please note that the always_ffconstruct must be always used in conjunction with a sensitivity list!
    // Only use the always_ffconstruct with the non-blockingassignment operator (<=).
    // Never use blockingassignments (=) in an always_ffblock.
    // Do not assign the same variable from more than one always_ffblock
    // (Race conditions in behavioral simulation, synthesizes incorrectly).
    always_ff@(posedge clk)
        q <= d;

endmodule