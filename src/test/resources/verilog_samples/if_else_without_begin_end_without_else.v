module design_top;
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            i2c_stop <= 0;
            o_wb_ack <= 0;
        end
        else begin
            if(i_wb_stb && i_wb_cyc && i_wb_we && i_wb_addr == I2C_STOP) i2c_stop <= i_wb_data; //write to i2c_stop to stop transaction
            if(i_wb_stb && i_wb_cyc && !i_wb_we && i_wb_addr == I2C_ACK) o_wb_data <= i2c_ack; //read i2c_ack to know if last access request has been ack by slave
            if(i_wb_stb && i_wb_cyc && !i_wb_we && i_wb_addr == I2C_READ_DATA_READY) o_wb_data <= i2c_read_data_ready;//read this to know if data is ready to be read
            if(i_wb_stb && i_wb_cyc && !i_wb_we && i_wb_addr == I2C_BUSY) o_wb_data <= i2c_busy; //read this to know if i2c is still busy
            if(i_wb_stb && i_wb_cyc && !i_wb_we && i_wb_addr == I2C_READ) o_wb_data <= rd_data_q; //read this to know what has been read from slave (make sure I2C_READ_DATA_READY is already high)

            o_wb_ack <= i_wb_stb && i_wb_cyc;
        end
    end
endmodule