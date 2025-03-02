module mux3 #(parameter WIDTH = 8) (
    input wire [WIDTH-1:0] d0,  // input A (selector: 00)
    input wire [WIDTH-1:0] d1,  // input B (selector: 01)
    input wire [WIDTH-1:0] d2,  // input C (selector: 1?)
    input wire [1:0] s,         // selector signal
    output wire [WIDTH-1:0] y   // output
);

    assign y = s[1] ? d2 : (s[0] ? d1 : d0);

endmodule