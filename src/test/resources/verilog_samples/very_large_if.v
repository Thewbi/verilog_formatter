always @(posedge clk or posedge wb_rst_i)
begin

  if (wb_rst_i)
    begin
        rstate 			    <= #1 sr_idle;
        rbit_in 				<= #1 1'b0;
        rcounter16 			<= #1 0;
        rbit_counter 		    <= #1 0;
        rparity_xor 		    <= #1 1'b0;
        rframing_error 	    <= #1 1'b0;
        rparity_error 		<= #1 1'b0;
        rparity 				<= #1 1'b0;
        rshift 				<= #1 0;
        rf_push 				<= #1 1'b0;
        rf_data_in 			<= #1 0;
    end

  else if (enable)
    begin

	case (rstate)

	sr_idle : begin
			rf_push 			<= #1 1'b0;
			rf_data_in 	        <= #1 0;
			rcounter16 	        <= #1 4'b1110;
			if (srx_pad_i==1'b0 & ~break_error)   // detected a pulse (start bit?)
			begin
				rstate 		  <= #1 sr_rec_start;
			end
		end

	sr_rec_start :	begin
  			rf_push 			  <= #1 1'b0;
				if (rcounter16_eq_7)    // check the pulse
					if (srx_pad_i==1'b1)   // no start bit
						rstate <= #1 sr_idle;
					else            // start bit detected
						rstate <= #1 sr_rec_prepare;
				rcounter16 <= #1 rcounter16_minus_1;
			end

	sr_rec_prepare:begin
				case (lcr[/*`UART_LC_BITS*/1:0])  // number of bits in a word
				2'b00 : rbit_counter <= #1 3'b100;
				2'b01 : rbit_counter <= #1 3'b101;
				2'b10 : rbit_counter <= #1 3'b110;
				2'b11 : rbit_counter <= #1 3'b111;
				endcase
				if (rcounter16_eq_0)
				begin
					rstate		<= #1 sr_rec_bit;
					rcounter16	<= #1 4'b1110;
					rshift		<= #1 0;
				end
				else
					rstate <= #1 sr_rec_prepare;
				rcounter16 <= #1 rcounter16_minus_1;
			end

	sr_rec_bit :	begin
				if (rcounter16_eq_0)
					rstate <= #1 sr_end_bit;
				if (rcounter16_eq_7) // read the bit
					case (lcr[/*`UART_LC_BITS*/1:0])  // number of bits in a word
					2'b00 : rshift[4:0]  <= #1 {srx_pad_i, rshift[4:1]};
					2'b01 : rshift[5:0]  <= #1 {srx_pad_i, rshift[5:1]};
					2'b10 : rshift[6:0]  <= #1 {srx_pad_i, rshift[6:1]};
					2'b11 : rshift[7:0]  <= #1 {srx_pad_i, rshift[7:1]};
					endcase
				rcounter16 <= #1 rcounter16_minus_1;
			end

	sr_end_bit :   begin
				if (rbit_counter==3'b0) // no more bits in word
					if (lcr[`UART_LC_PE]) // choose state based on parity
						rstate <= #1 sr_rec_parity;
					else
					begin
						rstate <= #1 sr_rec_stop;
						rparity_error <= #1 1'b0;  // no parity - no error :)
					end
				else		// else we have more bits to read
				begin
					rstate <= #1 sr_rec_bit;
					rbit_counter <= #1 rbit_counter - 1'b1;
				end
				rcounter16 <= #1 4'b1110;
			end

	sr_rec_parity: begin
				if (rcounter16_eq_7)	// read the parity
				begin
					rparity <= #1 srx_pad_i;
					rstate <= #1 sr_ca_lc_parity;
				end
				rcounter16 <= #1 rcounter16_minus_1;
			end

	sr_ca_lc_parity : begin    // rcounter equals 6
				rcounter16  <= #1 rcounter16_minus_1;
				rparity_xor <= #1 ^{rshift,rparity}; // calculate parity on all incoming data
				rstate      <= #1 sr_check_parity;
			  end

	sr_check_parity: begin	  // rcounter equals 5
				case ({lcr[`UART_LC_EP],lcr[`UART_LC_SP]})
					2'b00: rparity_error <= #1  rparity_xor == 0;  // no error if parity 1
					2'b01: rparity_error <= #1 ~rparity;      // parity should sticked to 1
					2'b10: rparity_error <= #1  rparity_xor == 1;   // error if parity is odd
					2'b11: rparity_error <= #1  rparity;	  // parity should be sticked to 0
				endcase
				rcounter16 <= #1 rcounter16_minus_1;
				rstate <= #1 sr_wait1;
			  end

	sr_wait1 :	if (rcounter16_eq_0)
			begin
				rstate <= #1 sr_rec_stop;
				rcounter16 <= #1 4'b1110;
			end
			else
				rcounter16 <= #1 rcounter16_minus_1;

	sr_rec_stop :	begin
				if (rcounter16_eq_7)	// read the parity
				begin
					rframing_error <= #1 !srx_pad_i; // no framing error if input is 1 (stop bit)
					rstate <= #1 sr_push;
				end
				rcounter16 <= #1 rcounter16_minus_1;
			end

	sr_push :	begin
///////////////////////////////////////
//				$display($time, ": received: %b", rf_data_in);
        if (srx_pad_i | break_error)
          begin
            if (break_error)
        		  rf_data_in 	<= #1 {8'b0, 3'b100}; // break input (empty character) to receiver FIFO
            else
        			rf_data_in  <= #1 {rshift, 1'b0, rparity_error, rframing_error};
      		  rf_push 		  <= #1 1'b1;
    				rstate        <= #1 sr_idle;
          end
        else if (~rframing_error)  // There's always a framing before break_error -> wait for break or srx_pad_i
          begin
       			rf_data_in      <= #1 {rshift, 1'b0, rparity_error, rframing_error};
      		    rf_push         <= #1 1'b1;
      			rcounter16 	    <= #1 4'b1110;
    			rstate 		    <= #1 sr_rec_start;
          end

			end
	default : rstate <= #1 sr_idle;
	endcase
  end  // if (enable)
end // always of receiver