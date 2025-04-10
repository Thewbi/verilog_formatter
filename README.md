# verilog_formatter

formatter

## Build Errors

Error: Lombok can't parse this source.
Solution: Ignore that error and run the software anyways. It seems as if this is not stopping the application from working.

## System Verilog Search Rules

From "System Verilog for Design, Second Edition"

Local definitions and declarations within a module or interface take
precedence over a wildcard import. An import that specifically
names package items also takes precedence over a wildcard import.
From a designer’s point of view, a wildcard import simply adds the
package to the search rules / search path for an identifier but it does
not import all objects!

Software tools will
search for local declarations first (following Verilog search rules for
within a module), and then search in any packages that were
imported using a wildcard. Finally, tools will search in SystemVer-
ilog’s $unit declaration space. The $unit space is discussed in
section 2.2 on page 14 of this chapter.

## System Verilog Identifier Search Rules

Declarations in the compilation-unit scope can be referenced any-
where in the hierarchy of modules that are part of the compilation
unit.

SystemVerilog defines a simple and intuitive search rule for when
referencing an identifier:
1. First, search for local declarations, as defined in the IEEE 1364 Verilog standard.
2. Second, search for declarations in packages which have been wildcard imported into the current scope.
3. Third, search for declarations in the compilation-unit scope.
4. Fourth, search for declarations within the design hierarchy, following IEEE 1364 Verilog search rules.

The SystemVerilog search rules ensure that SystemVerilog is fully
backward compatible with Verilog.


# Parsing System Verilog

Use antlr4 to generate the lexer and parser.
antlr4 has example grammars for verilog.

antlr4 will produce a parse tree according to the grammar. It also generates
an interface and a empty implementation of that interface for you to derive your
parser tree visitor.

In this project, the parse tree visitor (ASTVerilogParserListener) will generate
an AST using custom nodes. The AST nodes are contained in the com.mycompany.app.ast
package.

The difference between the ParseTree and the AST is that the parse tree covers
all details of the grammar in fine detail. The AST is a condensed version that
describes the language elements in broad terms but not their structure in the
grammar in all detail including each individual syntax token required. Syntactic
detail is left out of the AST.

## Preprocessor

A big problem with parsing verilog is that verilog supports the use of a preprocessor
like in C/C++, but the verilog grammar used does not contain the preprocessor
language.

Combining a structured language such as verilog and a preprocessor language is
complicated. Therefor the grammar concentrates on verilog exclusively and assumes
that the code has already be preprocessed and that on proprocessor statements
are ever seen by the verilog parser. It assumes that only pure verilog code is
parsed.

A preprocessor is not part of this project yet.

## Building an AST

Try to parse the elements in the following order. The order goes from most
basic, essential building blocks to more exotic verilog language constructs.

### Net Assignment Statements

```
assign countdown = 1;
```

### Nonblocking Assignments

```
oe1 <= oe_shift;
```

### Assignments from Arrays

```
oe1 <= oe_shift[0];
```

### If Statements

```
if (countdown > 0) begin
    assign countdown = 1;
end
```

### Complex Expressions

```
if((ce && !stall_bit) || (stall_bit && !o_ce && ce) || i_writeback_change_pc) begin
    o_iaddr <= iaddr_d;
end
```

### Elvis Operators

```
o_pc <= stall_q ? stalled_pc : prev_pc;
o_inst <= stall_q ? stalled_inst : i_inst;
```

### Procedural Timing Statements

```
always @(posedge CLK) begin
    ...
end

always @(posedge i_clk, negedge i_rst_n) begin
    ...
end

always @* begin
    ...
end
```

### Modules

```
module uart_top	(
	wb_clk_i
);
    ...
endmodule;
```

### Modules with Parameters

```
module uart_top	(
	wb_clk_i
);

    parameter uart_data_width = /*`UART_DATA_WIDTH*/4711;

endmodule
```

```
module rv32i_fetch #(parameter PC_RESET = 32'h00_00_00_00) (
    input wire i_clk, i_rst_n,
    input wire i_flush
);
    ...
endmodule
```

### Modules with Local Parameters

See src\test\resources\verilog_samples\module_with_complex_params.v

```
localparam [(F_LGDEPTH-1):0] MAX_OUTSTANDING
						= {(F_LGDEPTH){1'b1}},
localparam	MAX_DELAY = (F_MAX_STALL > F_MAX_ACK_DELAY)
        ? F_MAX_STALL : F_MAX_ACK_DELAY,
localparam	DLYBITS= (MAX_DELAY < 4) ? 2
        : (MAX_DELAY >= 65536) ? 32
        : $clog2(MAX_DELAY+1),
```

### Primitives

See: https://vlsiverify.com/verilog/user-defined-primitives/#google_vignette

```
primitive mux (out, sel, a, b);
	output 	out;
	input 	sel, a, b;

	table
		// sel 	a 	b 		out
			0 	1 	? 	: 	1;
			0 	0 	? 	: 	0;
			1 	? 	0 	: 	0;
			1 	? 	1 	: 	1;
			x 	0 	0 	: 	0;
			x 	1 	1 	: 	1;
	endtable
endprimitive
```

### if-else statement and nested

```
always @(posedge CLK) begin
    if (do_refresh == 1) begin
        WE_A  <= 1;
        WE_B  <= 2;
    end
    else if (do_refresh == 2) begin
        RAS_N <= 3;
        if (do_refresh == 1) begin
            WE_A  <= 1;
            WE_B  <= 2;
        end
    end
    else begin
        RAS_N <= 4;
    end
end
```

### case statement

```
case(state)
    WAIT: begin
        if(rx_data_ready) begin
            tx_data <= rx_data;
            wren <= 1'b1;
            rx_data_accept <= 1'b1;
            state <= WAIT1;
        end
    end
    WAIT1: begin
        rx_data_accept <= 1'b0;
        wren <= 1'b0;
        state <= WAIT;
    end
    default: begin
        wren <= 1'b0;
        rx_data_accept <= 1'b0;
        tx_data <= 8'b0;
        state <= WAIT;
    end
endcase
```

Also parse case statements with a single statement in a case. When only
a single statement is present, the begin ... end elements are optional.

```
always @(curr_state or i_input) begin
    case (lcr[1:0])
        2'b00 : rbit_counter <= #1 3'b100;
        2'b01 : rbit_counter <= #1 3'b101;
        2'b10 : rbit_counter <= #1 3'b110;
        2'b11 : rbit_counter <= #1 3'b111;
    endcase
end
```

## Module Instantiation

```
wire [1:0]  a;
    wire        b, c;

    mydesign d0  ( .x (a[0]),    // signal "x" in mydesign should be connected to "a[0]" in this module (design_top)
                   .y (b),       // signal "y" in mydesign should be connected to "b" in this module (design_top)
                   .z (a[1]),
                   .o (c));
```

```
uart_debug_if dbg(/*AUTOINST*/
    // Outputs
    .wb_dat32_o				 (wb_dat32_o[31:0]),
    // Inputs
    .wb_adr_i				 (wb_adr_int[/*`UART_ADDR_WIDTH*/0-1:0]),
    .ier						 (ier[3:0]),
    .iir						 (iir[3:0]),
    .fcr						 (fcr[1:0]),
    .mcr						 (mcr[4:0]),
    .lcr						 (lcr[7:0]),
    .msr						 (msr[7:0]),
    .lsr						 (lsr[7:0]),
    .rf_count				 (rf_count[/*`UART_FIFO_COUNTER_W*/0-1:0]),
    .tf_count				 (tf_count[/*`UART_FIFO_COUNTER_W*/0-1:0]),
    .tstate					 (tstate[2:0]),
    .rstate					 (rstate[3:0])
);
```

### Table

```
// Output should always be the first signal in port list
primitive mux (out, sel, a, b);
	output 	out;
	input 	sel, a, b;

	table
		// sel 	a 	b 		out
			0 	1 	? 	: 	1;
			0 	0 	? 	: 	0;
			1 	? 	0 	: 	0;
			1 	? 	1 	: 	1;
			x 	0 	0 	: 	0;
			x 	1 	1 	: 	1;
	endtable
endprimitive
```