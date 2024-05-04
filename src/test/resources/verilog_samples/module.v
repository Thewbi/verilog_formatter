module command(
CLK,
RESET_N,
SADDR,
NOP,
READA,
WRITEA,
REFRESH,
PRECHARGE,
LOAD_MODE,
REF_REQ,
INIT_REQ,
PM_STOP,
PM_DONE,
REF_ACK,
CM_ACK,
OE,
SA,
BA,
CS_N,
CKE,
RAS_N,
CAS_N,
WE_N
);

input                           	CLK;                    // System Clock
input                           	RESET_N;                // System Reset
input   [`ASIZE-1:0]            	SADDR;                  // Address
input                           	NOP;                    // Decoded NOP command
input                           	READA;                  // Decoded READA command
input                           	WRITEA;                 // Decoded WRITEA command
input                           	REFRESH;                // Decoded REFRESH command
input                           	PRECHARGE;              // Decoded PRECHARGE command
input                           	LOAD_MODE;              // Decoded LOAD_MODE command
input                           	REF_REQ;                // Hidden refresh request
input										INIT_REQ;					// Hidden initial request
input										PM_STOP;						// Page mode stop
input										PM_DONE;						// Page mode done
output                          	REF_ACK;                // Refresh request acknowledge
output                          	CM_ACK;                 // Command acknowledge
output                          	OE;                     // OE signal for data path module
output  [`SASIZE-1:0]				SA;                     // SDRAM address
output  [1:0]                   	BA;                     // SDRAM bank address
output  [1:0]                   	CS_N;                   // SDRAM chip selects
output                          	CKE;                    // SDRAM clock enable
output                          	RAS_N;                  // SDRAM RAS, Row Address Strobe Command
output                          	CAS_N;                  // SDRAM CAS, Column Address Strobe Command
output                          	WE_N;                   // SDRAM WE_N, Write Enable

            
reg                             	CM_ACK;
reg                             	REF_ACK;
reg                             	OE;
reg     [`SASIZE-1:0]           	SA;
reg     [1:0]                   	BA;
reg     [1:0]                   	CS_N;
reg                             	CKE;
reg                             	RAS_N;
reg                             	CAS_N;
reg                            	WE_N;



// Internal signals
reg                             	do_reada;
reg                             	do_writea;
reg                             	do_refresh;
reg                             	do_precharge;
reg                             	do_load_mode;
reg										do_initial;
reg                             	command_done;
reg     [7:0]                   	command_delay;
reg     [1:0]                   	rw_shift;
reg                             	do_act;
reg                             	rw_flag;
reg                             	do_rw;
reg     [6:0]                   	oe_shift;
reg                             	oe1;
reg                             	oe2;
reg                             	oe3;
reg                             	oe4;
reg     [3:0]                   	rp_shift;
reg                             	rp_done;
reg										ex_read;
reg										ex_write;

wire    [`ROWSIZE - 1:0]        	rowaddr;
wire    [`COLSIZE - 1:0]        	coladdr;
wire    [`BANKSIZE - 1:0]       	bankaddr;


//assign   rowaddr   = SADDR[`ROWSTART + `ROWSIZE - 1: `ROWSTART];          // assignment of the row address bits from SADDR
//assign   coladdr   = SADDR[`COLSTART + `COLSIZE - 1:`COLSTART];           // assignment of the column address bits
//assign   bankaddr  = SADDR[`BANKSTART + `BANKSIZE - 1:`BANKSTART];        // assignment of the bank address bits


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


endmodule