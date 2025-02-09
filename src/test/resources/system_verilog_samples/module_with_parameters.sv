module rv32i_fetch #(
    parameter PC_RESET = 32'h00_00_00_00,
    parameter CLOCK_FREQ = 12_000_000,      // Input clock frequency
    parameter BAUD_RATE  = 9600,            // UART Baud rate
    parameter UART_TX_DATA = 8140,          // memory-mapped address for TX (write to UART)
    parameter UART_TX_BUSY = 8144,          // memory-mapped address to check if TX is busy (has ongoing request)
    parameter UART_RX_BUFFER_FULL = 8148,   // memory-mapped address  to check if a read has completed
    parameter UART_RX_DATA = 8152,          // memory-mapped address for RX (read the data)
    parameter DBIT = 8,                     // UART Data Bits
    parameter SBIT = 1                      // UART Stop Bits
)
();

endmodule