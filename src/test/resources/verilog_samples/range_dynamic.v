module design_top;
    always@(*)
        // not a typo! left border is left undefined! This is a dynamic range!
	    tx_str <= send_data[(DATA_NUM - 1 - tx_cnt) * 8 +: 8];
endmodule