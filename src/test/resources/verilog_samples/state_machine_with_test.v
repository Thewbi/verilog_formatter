`timescale 1ns/1ns
`define WIDTH 4
module FSM_Detect_Stream_Top();

    reg in_clk;
    reg in_rst_n;
    reg [`WIDTH-1:0] in_input;

    wire out_ouput;

    FSM Test (.i_clk(in_clk), .i_rst_n(in_rst_n), .i_input(in_input), .o_output(out_output));

    initial
        begin
            in_clk = 1'b0; // clk at t=0
            #1 in_rst_n = 1'b1;
            #2 in_rst_n = 1'b0;
            #5 in_rst_n = 1'b1;
            @ (negedge in_clk)
                in_input = 2'b01;
            @ (posedge in_clk)
                $display("output:%b ", out_output);
            @ (negedge in_clk)
                in_input = 2'b01;
            @ (posedge in_clk)
                $display("output:%b ", out_output);
            @ (negedge in_clk)
                in_input = 2'b01;
            @ (posedge in_clk)
                $display("output:%b ", out_output);
            @ (negedge in_clk)
                in_input = 2'b01;
            @ (posedge in_clk)
                $display("output:%b ", out_output);
            @ (negedge in_clk)
                in_input = 2'b01;
            @ (posedge in_clk)
                $display("output:%b ", out_output);
            @ (negedge in_clk)
                in_input = 2'b00;
            @ (posedge in_clk)
                $display("output:%b ", out_output);
            @ (negedge in_clk)
                in_rst_n = 1'b0;
            @ (posedge in_clk)
                $display("output:%b ", out_output);
            @ (negedge in_clk)
                in_input = 2'b00; in_rst_n = 1'b1;
            @ (posedge in_clk)
                $display("output:%b ", out_output);
            $finish;
        end


    // Generating a 20ns width clock pulse with 50% duty cycle
    always
        #10 in_clk = ~in_clk;

endmodule // FSM_Detect_Stream_Top

//*********************************************************************************************
module FSM(input i_clk, input i_rst_n, input [`WIDTH-1:0] i_input, output reg o_output);
//*********************************************************************************************

    parameter S0 = 2'b00;   //FIRST STATE or DEFAULT
    parameter S1 = 2'b01;   //SECOND STATE
    parameter S2 = 2'b10;   //THIRD STATE
    parameter S3 = 2'b11;   //FOURTH STATE

    reg [`WIDTH-3:0] curr_state;
    reg [`WIDTH-3:0] next_state;

    //Sequential Logic for Storing Current State
    always @ (posedge i_clk or negedge i_rst_n) begin
        if(~i_rst_n)
            curr_state <= S0;
        else
            curr_state <= next_state;
        end

    //Combinational Logic for Next State
    always @ (curr_state or i_input)    begin
        case(curr_state)
            S0: begin
                if (i_input == 2'b01)
                    next_state <= S1;
                else
                    next_state <= S0;
            end
            S1: begin
                if (i_input == 2'b01)
                    next_state <= S2;
                else
                    next_state <= S1;
            end
            S2: begin
                if (i_input == 2'b01)
                    next_state <= S3;
                else
                    next_state <= S2;
            end
            S3: begin
                if (i_input == 2'b01)
                    next_state <= S0;
                else
                    next_state <= S3;
            end
            default: next_state <= S0;
        endcase // curr_state
    end

    // Output Logic
    always @(posedge i_clk) begin
        if (~i_rst_n)
            o_output <= 1'b0;
        else begin
            case(curr_state)
                S0: begin
                    if (i_input == 2'b01)
                        o_output <= 1'b1;
                    else
                        o_output <= 1'b1;
                    end
                S1: begin
                    if (i_input == 2'b01)
                        o_output <= 1'b1;
                    else
                        o_output <= 1'b0;
                    end
                S2: begin
                    if (i_input == 2'b01)
                        o_output <= 1'b1;
                    else
                        o_output <= 1'b0;
                    end
                S3: begin
                    if (i_input == 2'b01)
                        o_output <= 1'b1;
                    else
                        o_output <= 1'b0;
                    end
                default: o_output <= 1'b0;
            endcase
        end
    end

endmodule