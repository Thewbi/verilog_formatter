module uart (   output logic [7:0] data,
                output logic       data_rdy,
                input              serial_in);

    enum {WAITE, LOAD, READY} State, NextState;
    logic [2:0] bit_cnt;
    logic       cntr_rst, shift_en;

    always_ff @(posedge clock, negedge resetN) begin: shifter
        if (!resetN)
            data <= 8'h0; // reset (active low)
    else if (shift_en)
        data <= {serial_in, data[7:1]}; // shift right
    end: shifter

endmodule