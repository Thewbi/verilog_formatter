// UART (TX only)
module uart #(
    parameter CLOCK_FREQ = 12_000_000,      // Input clock frequency
    parameter BAUD_RATE  = 9600,            // UART Baud rate
    parameter UART_TX_DATA = 8140,          // memory-mapped address for TX (write to UART)
    parameter UART_TX_BUSY = 8144,          // memory-mapped address to check if TX is busy (has ongoing request)
    parameter UART_RX_BUFFER_FULL = 8148,   // memory-mapped address  to check if a read has completed
    parameter UART_RX_DATA = 8152,          // memory-mapped address for RX (read the data)
    parameter DBIT = 8,                     // UART Data Bits
    parameter SBIT = 1                      // UART Stop Bits
    )(
        input wire clk,
        input wire rst_n,
        input wire i_wb_cyc,
        input wire i_wb_stb,
        input wire i_wb_we,
        input wire[31:0] i_wb_addr,
        input wire[DBIT - 1:0] i_wb_data,
        input wire[3:0] i_wb_sel,
        output reg o_wb_ack,
        output wire o_wb_stall,
        output reg[DBIT - 1:0] o_wb_data,
        input wire uart_rx,                 // UART RX line
        output wire uart_tx                 // UART TX line
    );

    localparam DVSR = CLOCK_FREQ/(16*BAUD_RATE);
    localparam DVSR_WIDTH = $clog2(DVSR);   // array size needed by DVSR
    localparam SB_TICK = 16*SBIT;

     // FSM state declarations
     localparam[1:0] idle=2'd0,
                    start=2'd1,
                    data=2'd2,
                    stop=2'd3;

    reg[DBIT - 1:0] uart_busy;
    reg tx_done_tick;
    reg[1:0] state_reg,state_nxt;
    reg[3:0] s_reg,s_nxt;                   // count to 16 for every data bit
    reg[2:0] n_reg,n_nxt;                   // count the number of data bits already transmitted
    reg[DBIT - 1:0] din_reg,din_nxt;        // stores the word to be transmitted
    reg tx_reg,tx_nxt;
    reg s_tick;
    reg wr_uart;
    reg[1:0] state_reg_rx,state_nxt_rx;
    reg[3:0] s_reg_rx,s_nxt_rx;             // check if number of ticks is 7(middle of start bit), or 15(middle of a data bit)
    reg[2:0] n_reg_rx,n_nxt_rx;             // checks how many data bits is already passed(value is 7 for last bit)
    reg[7:0] b_reg,b_nxt;                   // stores 8-bit binary value of received data bits
    reg[7:0] dout;                          // data read from UART
    reg rx_done_tick;                       // goes high if a read is done
    reg rx_buffer_full;                     // goes high if a read is done

    assign o_wb_stall = 0;

    // baud tick generator
    reg[DVSR_WIDTH-1:0] counter=0;
     always @(posedge clk,negedge rst_n) begin
        if(!rst_n) counter<=0;
        else begin
            s_tick=0;
            if(counter == DVSR-1) begin
                s_tick=1;
                counter<=0;
            end
            else begin
                counter<=counter+1;
            end

        end
     end
     // Read memory-mapped registers
     always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            o_wb_data <= 0;
            o_wb_ack <= 0;
        end
        else begin
            // read request to UART_TX_BUSY_ADDR (check if there is an ongoing request)
            if(i_wb_stb && i_wb_cyc && !i_wb_we && i_wb_addr == UART_TX_BUSY) begin
                o_wb_data <= uart_busy;
            end

            // read request to UART_RX_BUFFER_FULL (check if a read is completed)
            else if(i_wb_stb && i_wb_cyc && !i_wb_we && i_wb_addr == UART_RX_BUFFER_FULL) begin
                o_wb_data <= rx_buffer_full;
            end

            // read request to UART_RX_DATA (read the data)
            else if(i_wb_stb && i_wb_cyc && !i_wb_we && i_wb_addr == UART_RX_DATA) begin
                o_wb_data <= dout;
            end

            o_wb_ack <= i_wb_stb && i_wb_cyc;
        end
     end


     /******************************** UART TX ****************************************/


     //FSM register operation
     always @(posedge clk,negedge rst_n) begin
        if(!rst_n) begin
            state_reg<=idle;
            s_reg<=0;
            n_reg<=0;
            din_reg<=0;
            tx_reg<=0;
        end
        else begin
            state_reg<=state_nxt;
            s_reg<=s_nxt;
            n_reg<=n_nxt;
            din_reg<=din_nxt;
            tx_reg<=tx_nxt;
        end
     end

     //FSM next-state logic
     always @* begin
        state_nxt=state_reg;
        s_nxt=s_reg;
        n_nxt=n_reg;
        din_nxt=din_reg;
        tx_nxt=tx_reg;
        tx_done_tick=0;
        uart_busy= 1; // uart is busy unless its in idle state
         case(state_reg)
                idle: begin
                            tx_nxt=1;
                            uart_busy = 0;
                            //start transmit operation when there is a write request to UART_TX_DATA_ADDR and we are in idle
                            if(i_wb_we && i_wb_stb && i_wb_cyc && i_wb_addr == UART_TX_DATA && !uart_busy) begin
                                din_nxt=i_wb_data;
                                s_nxt=0;
                                state_nxt=start;
                                uart_busy = 1;
                            end
                        end
              start: begin   //wait to finish the start bit
                            tx_nxt=0;
                            if(s_tick==1) begin
                                if(s_reg==15) begin
                                    s_nxt=0;
                                    n_nxt=0;
                                    state_nxt=data;
                                end
                                else s_nxt=s_reg+1;
                            end
                        end
                data: begin  //wait for all data bits to be transmitted serially
                            tx_nxt=din_reg[0];
                            if(s_tick==1) begin
                                if(s_reg==15) begin
                                    din_nxt=din_reg>>1;
                                    s_nxt=0;
                                    if(n_reg==DBIT-1) state_nxt=stop;
                                    else n_nxt=n_reg+1;
                                end
                                else s_nxt=s_reg+1;
                            end
                        end
                stop: begin  //wait to finish the stop bit
                            tx_nxt=1;
                            if(s_tick==1) begin
                                if(s_reg==SB_TICK-1) begin
                                    tx_done_tick=1;
                                    state_nxt=idle;
                                end
                                else s_nxt=s_reg+1;
                            end
                        end
            default: state_nxt=idle;
         endcase
     end
     assign uart_tx=tx_reg;
    /*********************************************************************************/

    /******************************** UART RX ****************************************/

	 //FSM register operation
	 always @(posedge clk,negedge rst_n) begin
		if(!rst_n) begin
			state_reg_rx<=idle;
			s_reg_rx<=0;
			n_reg_rx<=0;
			b_reg<=0;
			dout<=0;
			rx_buffer_full<=0;
		end
		else begin
			state_reg_rx<=state_nxt_rx;
			s_reg_rx<=s_nxt_rx;
			n_reg_rx<=n_nxt_rx;
			b_reg<=b_nxt;
			if(rx_done_tick) begin
			    dout <= b_reg; //memory-mapped register storing the completed read data
			    rx_buffer_full <= 1'b1; //memory-mapped register to check if a read is done
			end
			else if(i_wb_stb && i_wb_cyc && !i_wb_we && i_wb_addr == UART_RX_DATA) begin //read request to UART_RX_DATA (read the data)
                rx_buffer_full <= 1'b0;
            end
		end
	 end

	 //FSM next-state logic
	 always @* begin
		state_nxt_rx=state_reg_rx;
		s_nxt_rx=s_reg_rx;
		n_nxt_rx=n_reg_rx;
		b_nxt=b_reg;
		rx_done_tick=0;
		case(state_reg_rx)
			 idle: if(uart_rx==0) begin //wait for start bit(rx of zero)
						s_nxt_rx=0;
						state_nxt_rx=start;
					 end
			start: if(s_tick==1) begin //wait for middle of start bit
						if(s_reg_rx==7) begin
							s_nxt_rx=0;
							n_nxt_rx=0;
							state_nxt_rx=data;
						end
						else s_nxt_rx=s_reg_rx+1;
					 end
		    data: if(s_tick==1) begin //wait to pass all middle points of every data bits
						if(s_reg_rx==15) begin
							b_nxt={uart_rx,b_reg[7:1]};
							s_nxt_rx=0;
							if(n_reg_rx==DBIT-1) state_nxt_rx=stop;
							else n_nxt_rx=n_reg_rx+1;
						end
						else s_nxt_rx=s_reg_rx+1;
					 end
			 stop: if(s_tick==1) begin  //wait to pass the required stop bits
						if(s_reg_rx==SB_TICK-1) begin
							rx_done_tick=1;
							state_nxt_rx=idle;
						end
  						else s_nxt_rx=s_reg_rx+1;
					 end
		 default: state_nxt_rx=idle;
		endcase
	 end
	 /*********************************************************************************/

endmodule