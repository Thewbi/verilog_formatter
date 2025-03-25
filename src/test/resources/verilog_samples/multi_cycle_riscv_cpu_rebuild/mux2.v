module mux2 #(parameter WIDTH = 8) (
    input wire [WIDTH-1:0] d0,  // input A
    input wire [WIDTH-1:0] d1,  // input B
    input wire s,               // selector
    output wire [WIDTH-1:0] y   // output
);

    //assign y = s ? d1 : d0;


    always @(d0, d1, s)
    begin

        if (s == 1'b0)
        begin
            y = d0;
        end
        else
        begin
           y = d1;
        end
    end

endmodule