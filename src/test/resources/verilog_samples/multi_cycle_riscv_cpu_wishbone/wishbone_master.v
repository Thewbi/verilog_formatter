// source:
// https://zipcpu.com/blog/2017/06/08/simple-wb-master.html
// https://zipcpu.com/zipcpu/2017/05/29/simple-wishbone.html
// https://zipcpu.com/zipcpu/2017/11/07/wb-formal.html
//
// # (i_cmd_word) 34 bit Command Format
//
// | 33 | 32 | Type                                 | 31 - 0 |
// | -- | -- | ------------------------------------ | ------ |
// |  0 |  0 | Read request                         | ignore the rest of the 32-bits, ACK on output |
// |  0 |  1 | Write request - Set data             | the 32-bit data contains the word to be written |
// |  1 |  0 | Read/Write request - Set an address  | If bit 31 is set, we’ll add this value to the current bus address.
//                                                    If bit 30 is set, the address will be incremented upon each bus access.
//                                                    bits 29 to 0 contain the actual address |
// |  1 |  1 | Bus Reset                            | 4’h0, 28’hxx,  |
//
// # (o_rsp_word) 34 bit Command Format
//
// | 33 | 32 | Type                                     | 31 - 0 |
// | -- | -- | ---------------------------------------- | ------ |
// |  0 |  0 | Acknowledge a write                      | The 32-bit value contains number of writes to acknowledge |
// |  0 |  1 | Read response                            | the 32 data bits are the word that was read |
// |  1 |  0 | Acknowledge an address that has been set | with two zero bits and 30 address bits |
// |  1 |  1 |                                          | ??? |
// |  1 |  1 | Bus Reset acknowledgement                | 3’h0, 29’hxx, |
// |  1 |  1 | Bus Error                                | 3’h1, 29’hxx, |

`define RSP_WRITE_ACKNOWLEDGEMENT   34'b0000000000000000000000000000000001
`define RSP_SUB_ADDR                 2'b10
`define RSP_SUB_DATA                 2'b01
`define RSP_RESET                   34'b11xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
`define RSP_BUS_ERROR               34'b11111xxxxxxxxxxxxxxxxxxxxxxxxxxxxx

module wishbone_master (
    input               i_clk,          // clock signal
    input               i_reset,        // wishbone master performs a reset

    // interface between the host and the master
    input               i_cmd_stb,      // the host tells the master that it has provided address and data and that the strobe can begin
    input   [33:0]      i_cmd_word,     // (34 bits) data to write wrapped in a command
    output  reg	        o_cmd_busy,     // the client stalls the master, the master forwards the stall signal to the host here
    output  reg         o_rsp_stb,      // when this value is 1, then the master is ready to start a strobe
    output  reg [33:0]  o_rsp_word,     // (34 bits) data that has been read (or dummy data on a read)

    // interface between the master and the slave
    input               i_wb_err,       // an error occured, the wishbone master has to reset
    input               i_wb_stall,     // slave stalls
    input               i_wb_ack,       // slave acknowledges the execution of the wishbone transaction
    input   wire [31:0] i_wb_data,      // slave returns read data here
    output  reg         o_wb_cyc,       //
    output  reg         o_wb_stb,       // without strobe, the slave is disabled
    output  reg [ 9:0]  o_wb_addr,      // this is the address that the slave has to read from or write to
    output  reg         o_wb_we,        //
    output  reg [31:0]  o_wb_data       // data for the slave to process is output here
);

    reg newaddr;
    reg inc;

    // We'll use i_cmd_bus to capture whether we have a read or write request
    assign	i_cmd_rd        = (i_cmd_stb) && (i_cmd_word[33:32] == 2'b00);
    assign	i_cmd_wr        = (i_cmd_stb) && (i_cmd_word[33:32] == 2'b01);
    assign	i_cmd_bus       = (i_cmd_stb) && (i_cmd_word[33]    == 1'b0);
    assign	i_cmd_addr      = (i_cmd_stb) && (i_cmd_word[33:32] == 2'b10);
    assign	i_cmd_special   = (i_cmd_stb) && (i_cmd_word[33:32] == 2'b11);

    initial	o_wb_cyc    = 1'b0;
    initial	o_wb_stb    = 1'b0;
    initial	newaddr     = 1'b0;
    initial	o_rsp_stb   = 1'b0; // to host: ???

    initial
    begin
        // cmd_stb = 0;
        // cmd_word = 0;
        o_cmd_busy = 0;
        o_rsp_stb = 0;
        o_rsp_word = 0;
    end

    always @(posedge i_clk)
    begin

        $display("");
        $display("[WISHBONE MASTER] i_cmd_word: %b, i_cmd_stb: %d, o_rsp_word: %h", i_cmd_word, i_cmd_stb, o_rsp_word);

        // reset
        if ((i_reset) || (i_wb_err))
        begin

            //
            // Reset state - during reset or error
            //

            $display("[WISHBONE MASTER] RESET STATE");

            o_wb_we     <= 1'b0;
            o_wb_cyc    <= 1'b0; // to slave: no cycle (= transaction) takes place
            o_wb_stb    <= 1'b0; // to slave: no strobe takes place
            o_cmd_busy  <= 1'b0; // to host: master is not busy
            o_rsp_stb   <= 1'b1; // to host: ???

            // reset internal flag to NOT acknowledge the address back to the host initially
            // This internal signal is asserted as soon as the wishbone master has latched
            // the host's address. This internal signal is used to assert output lines
            // that are connected to the external host
            newaddr <= 1'b0;

            // Return over the command interface that we just had an error,
            // or a bus reset
            if (i_reset)
                begin
                    // to host: output code for Reset as data (For read requests,
                    // the host receives the read data here). For write requests,
                    // this is abused to return status code about the outcome of the write
                    o_rsp_word <= `RSP_RESET;
                end
            else
                begin
                    // to host: output error code
                    o_rsp_word <= `RSP_BUS_ERROR;
                end

        end
        // from host: i_cmd_stb - the command word is valid
        // to host: !o_cmd_busy - the wishbone bus master is not busy
        else if ((i_cmd_stb) && (!o_cmd_busy))
        begin

            //
            // In the idle state
            //

            $display("[WISHBONE MASTER] IDLE STATE");

            // reset internal flag to NOT acknowledge the address back to the host initially
            newaddr <= 0;

            // from host: if this is a command with an address, latch that address
            if (i_cmd_addr)
            begin

                $display("[WISHBONE MASTER] IDLE STATE - i_cmd_addr");

                // check the auto-increment feature
                if (!i_cmd_word[31])
                begin
                    $display("[WISHBONE MASTER] IDLE STATE - no_auto increment");

                    // no auto-increment mode enabled
                    // just use the base address to read data from
                    o_wb_addr<= i_cmd_word[29:0];

                    $display("[WISHBONE MASTER] IDLE STATE - no_auto increment - o_wb_addr = 0x%h", i_cmd_word[29:0]);
                end
                else
                begin
                    $display("[WISHBONE MASTER] IDLE STATE - auto increment");

                    // auto-increment mode enabled
                    //
                    // the wishbone interface has a feature where the wishbone
                    // bus can increment to the next address automatically.
                    // i_cmd_word[29:0] is used as a base using o_wb_addr as
                    // an incremented offset. o_wb_addr is incremented in the
                    // wait state
                    o_wb_addr = i_cmd_word[29:0] + o_wb_addr;
                end

                // inc is used to increment o_wb_addr.
                // This happens in the BUS REQUEST / idle phase
                inc <= !i_cmd_word[30];

                // the wishbone master has latched the host's address
                // The wishbone master will signal this state to the host
                //
                // Acknowledge the new address by asserting o_rsp_stb to the host -- on the next clock
                // (after the add has completed)
                newaddr <= 1'b1; // set newaddr to acknowledge to the host

            end

            // acknowledge to the host
            if (newaddr)
            begin
                //$display("[WISHBONE MASTER] newaddr o_wb_addr = %b", o_wb_addr);
                $display("[WISHBONE MASTER] newaddr o_wb_addr = %d", o_wb_addr);

                o_rsp_stb   <= 1'b1;
                o_rsp_word  <= { `RSP_SUB_ADDR, o_wb_addr, 1'b0, !inc };

                //$display("[WISHBONE MASTER] newaddr o_rsp_word = %b", o_rsp_word);
                $display("[WISHBONE MASTER] newaddr o_rsp_word = %h", o_rsp_word);
            end

            // to slave: this is a write request or not
            $display("[WISHBONE MASTER -- TO_SLAVE:] i_cmd_stb = %b, i_cmd_wr = %b, i_cmd_rd = %b, i_cmd_bus = %d",
                i_cmd_stb, i_cmd_wr, i_cmd_rd, i_cmd_bus);
            o_wb_we <= i_cmd_wr;

            // on a read or write request, activate the bus and go to the bus
            // request state (= master has the strobe line asserted and is
            // waiting for the slave to acknowledge, stall or err-out)
            if (i_cmd_bus)
            begin
                $display("[MASTER] start a transaction");
                o_wb_cyc    <= 1'b1; // to slave: start a cycle
                o_wb_stb    <= 1'b1; // to slave: start a strobe
                o_cmd_busy  <= 1'b1; // to host: master is busy
            end

            if (i_cmd_wr)
            begin
                $display("[MASTER] presenting data to slave: %h", i_cmd_word[31:0]);
                o_wb_data <= i_cmd_word[31:0]; // to slave: data to write
            end
        end
        // the host keeps the strobe active until it sees a i_wb_ack from the slave
        // When the slave asserts i_wb_ack, the host will deassert o_wb_stb.
        //
        // In this specific implementation, the master will not wait
        // for i_wb_ack, instead if it does not see a stall from the slave,
        // it will deassert o_wb_stb
        else if (o_wb_stb)
        begin

            //
            // In the waiting state
            //

            $display("[WISHBONE MASTER] WAITING STATE");

            // reset newaddr to NOT acknowledge to the host when the idle
            // state is entered again.
            newaddr <= 1'b0;

            //
            // BUS REQUEST state
            //
            // In the state where we are commanding the bus, and waiting for
            // the bus request to be accepted
            //
            // o_wb_cyc will also be true here, since we cannot allow
            // o_wb_stb to be true if o_wb_cyc is not true. (Too many
            // peripherals depend upon this bus simplification ...)
            // Note: this is defined in the wishbone b4 specification.
            // A strobe is nested within a cycle.
            //
            if (!i_wb_stall) // the slave does not stall. Error terminating signals are not considered here!
            begin

                // the request has been accepted by the slave, do not request again.
                o_wb_stb <= 1'b0;   // to slave: master does not drive the strobe line any more
                                    // this makes the state machine go to the next state on the next clock cycle

                // increment the address for the auto increment feature
                o_wb_addr <= o_wb_addr + inc;

                // if we get an ack from the slave on the same cycle as the request,
                // quietly transition back to idle.
                if (i_wb_ack)
                begin

                    $display("[WISHBONE MASTER] SLAVE ACK DURING WAITING STATE. o_wb_we = %d, i_wb_data = %h", o_wb_we, i_wb_data);

                    o_wb_cyc    <= 1'b0; // to slave: cycle is over
                    o_wb_stb    <= 1'b0; // to slave: stb is over
                    o_cmd_busy  <= 1'b0; // to host: not busy any more
                    o_rsp_stb   <= 1'b1; // to host: ???

                    if (o_wb_we)
                    begin
                        // to host: write has been performed, do not answer with real data since this is not a read request
                        o_rsp_word <= `RSP_WRITE_ACKNOWLEDGEMENT;
                    end
                    else
                    begin
                        // to host: read has been performed, here is the read data
                        o_rsp_word <= { `RSP_SUB_DATA, i_wb_data };
                    end

                    // back to idle state
                end

                // o_wb_we = 0;
                // o_wb_cyc = 0;
                // o_wb_stb = 0;
            end
        end
        else if (o_wb_cyc) // state to wait for the slave responding with the data read
        begin

            //
            // In the cycle end state
            //

            $display("[WISHBONE MASTER] CYCLE END STATE");

            // reset newaddr to NOT acknowledge to the host when the idle
            // state is entered again
            newaddr <= 1'b0;

            // slave answers with an ack
            if (i_wb_ack)
            begin

                $display("[WISHBONE MASTER] SLAVE ACK DURING CYCLE END STATE");

                o_wb_cyc    <= 1'b0; // to slave: cycle is over
                o_cmd_busy  <= 1'b0; // to host: not busy any more
                o_rsp_stb   <= 1'b1; // to host: ???

                if (o_wb_we)
                begin
                    // to host: write has been performed,
                    // do not answer with real data since this is not a read request and hence no real data has been read
                    o_rsp_word <= `RSP_WRITE_ACKNOWLEDGEMENT;
                end
                else
                begin
                    // to host: read has been performed, here is the read data
                    o_rsp_word <= { `RSP_SUB_DATA, i_wb_data };
                end
            end

            o_wb_we <= 0;
            o_wb_cyc <= 0;
            o_wb_stb <= 0;

        end
        else
        begin
            $display("[MASTER] NO STATE!");
        end
    end

endmodule