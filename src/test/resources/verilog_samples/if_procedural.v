// start-symbol: always_construct
// create a launch.json:
// {
//            "name": "Debug ANTLR4 grammar",
//            "type": "antlr-debug",
//            "request": "launch",
//            "grammar": "src/main/antlr4/lel/VerilogParser.g4",
//
//            //"input": "src/test/resources/verilog_samples/command.v",
//            //"startRule": "source_text",
//
//            //"input": "src/test/resources/verilog_samples/ifelse.v",
//            //"startRule": "conditional_generate_construct",
//
//            "input": "src/test/resources/verilog_samples/if_procedural.v",
//            "startRule": "always_construct",
//
//            //"actionFile": "grammars/exampleActions.js",
//
//            "printParseTree": true,
//            "visualParseTree": true
//        }
always @(posedge CLK or negedge RESET_N)
begin

    //if (RESET_N == 0) begin
	//	do_reada <= 0;
    //end

    // Refresh
	if ((REF_REQ == 1 | REFRESH == 1) & command_done == 0 & do_refresh == 0 & rp_done == 0         
	& do_reada == 0 & do_writea == 0)
	do_refresh <= 1;         
	else
	do_refresh <= 0;

    if ((READA == 1) & (command_done == 0) & (do_reada == 0) & (rp_done == 0) & (REF_REQ == 0))    // READA
	begin
	do_reada <= 1;
	ex_read <= 1;
	end
	else
	do_reada <= 0;

    if ((WRITEA == 1) & (command_done == 0) & (do_writea == 0) & (rp_done == 0) & (REF_REQ == 0))  // WRITEA
	begin
	do_writea <= 1;
	ex_write <= 1;
	end
	else
	do_writea <= 0;

    if ((do_refresh == 1) | (do_reada == 1) | (do_writea == 1) | (do_precharge == 1) | (do_load_mode == 1))
	begin
	command_delay <= 8'b11111111;
	command_done  <= 1;
	rw_flag <= do_reada;                                                  
	end
	else
	begin
	command_done        	<= command_delay[0];                // the command_delay shift operation
	command_delay			<= (command_delay>>1);
	end 

end