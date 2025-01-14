module bus_concatenation(
input logic [3:0] a,b,c,d,
output logic [3:0] q
);

// --- logic function implementation
assign q = {a[2],a[1],b[2],c[2]};

endmodule