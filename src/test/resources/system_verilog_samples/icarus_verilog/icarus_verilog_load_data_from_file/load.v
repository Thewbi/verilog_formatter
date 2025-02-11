module load;

    reg [7:0] progmem [0:3];

    initial begin
        $readmemh("progmem.txt", progmem);
    end

endmodule