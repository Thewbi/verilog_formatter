// https://www.digikey.de/en/maker/blogs/2024/assign-statement-and-its-examples-part-9-of-our-verilog-series
//
// Introducing signal delay using assign
assign delayed_signal = #1 input_signal; // Delays 'input_signal' by one time ‎unit