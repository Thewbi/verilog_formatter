module design_top;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            o_wb_data <= 0;
            o_wb_ack <= 0;
        end
        else begin
            if(i_wb_stb && i_wb_cyc && !i_wb_we && i_wb_addr == UART_TX_BUSY) begin //read request to UART_TX_BUSY_ADDR (check if there is an ongoing request)
                o_wb_data <= uart_busy;
            end
            else if(i_wb_stb && i_wb_cyc && !i_wb_we && i_wb_addr == UART_RX_BUFFER_FULL) begin //read request to UART_RX_BUFFER_FULL (check if a read is completed)
                o_wb_data <= rx_buffer_full;
            end
            else if(i_wb_stb && i_wb_cyc && !i_wb_we && i_wb_addr == UART_RX_DATA) begin //read request to UART_RX_DATA (read the data)
                o_wb_data <= dout;
            end
            o_wb_ack <= i_wb_stb && i_wb_cyc;
        end
     end

endmodule