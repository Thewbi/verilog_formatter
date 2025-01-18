module design_top;
    if (countdown1 == 0) begin
        assign test1 = 1;
    end
    if (countdown2 > 0 || x < y) begin
        assign test2 = 2;
    end
    if (countdown3 > 0 || x < y && !z) begin
        assign test3 = 3;
    end
    if (!z) begin
        assign test4 = 4;
    end
endmodule