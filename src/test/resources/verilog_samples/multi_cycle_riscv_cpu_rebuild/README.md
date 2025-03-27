# Simulation with Icarus Verilog

```
cd C:\Users\wolfg\dev\Java\verilog_formatter\src\test\resources\verilog_samples\multi_cycle_riscv_cpu_rebuild

// separate instruction memory (imem) and data memory (dmem)
C:\iverilog\bin\iverilog.exe -s top_testbench -o build/aout.vvp top_testbench.v top.v riscv_multi.v datapath.v flopenr.v flopr.v regfile.v controller.v mux2.v mux3.v mux4.v alu.v extend.v imem.v dmem.v clock_divider.v

// for data and code in a single RAM module (ram.v)
C:\iverilog\bin\iverilog.exe -s top_testbench -o build/aout.vvp top_testbench.v top.v riscv_multi.v datapath.v flopenr.v flopr.v regfile.v controller.v mux2.v mux3.v mux4.v alu.v extend.v ram.v uart_rx.v uart_tx.v clock_divider.v > build/compile.log

clear && C:\iverilog\bin\vvp.exe build/aout.vvp

gtkwave build/aout.vcd

C:\iverilog\bin\vvp.exe build/riscv.vvp -lxt2
```

# Synthesis using Yosys

Yosys does not allow non-synthesizable items (initial-blocks, ...). So first prepare the design for synthesis:
1. controller.v - remove the initial block
2. In the top module, remove the reset port and insert a custom reset logic since the IceStick will not provide a button that can be used to reset the design
3. In ram.v, the machine code is inserted using an initial block. Remove that initial block. Make sure your machine code is inserted using the resetn block.
4. regfilve.v contains an initial block. remove it.

```
cd <your_project_folder>
mkdir build

set PATH=%PATH%;C:\Users\wolfg\Downloads\oss-cad-suite\lib\
C:\Users\wolfg\Downloads\oss-cad-suite\environment.bat

// synthesis - including top_testbench
yosys.exe -p "synth_ice40 -top top -blif build/aout.blif -json build/aout.json" top_testbench.v top.v riscv_multi.v datapath.v flopenr.v flopr.v regfile.v controller.v mux2.v mux3.v mux4.v alu.v extend.v ram.v uart_rx.v uart_tx.v clock_divider.v

// synthesis - without top_testbench
yosys.exe -p "synth_ice40 -top top -blif build/aout.blif -json build/aout.json" top.v riscv_multi.v datapath.v flopenr.v flopr.v regfile.v controller.v mux2.v mux3.v mux4.v alu.v extend.v ram.v uart_rx.v uart_tx.v clock_divider.v C:\Users\wolfg\Downloads\oss-cad-suite\share\yosys\ice40\cells_sim.v > build/compile.log

// routing
nextpnr-ice40 --hx1k --package tq144 --json build/aout.json --asc build/aout.asc --pcf icestick.pcf -q

icepack build/aout.asc build/aout.bin

iceprog -d i:0x0403:0x6010:0 build/aout.bin

```

# Lessons Learned

* Do not ever use uninitialized memory (RAM for instructions or data)! You will hunt non-existent bugs in your CPU for hours! Instead, initialize all cells to zero.
* Prevent out of bounds memory. It is possible to access a memory cell that has not been defined/reserved! You design will read undefined (x) values and it will break.
* Every if needs an else. Every switch needs a case for all possibilities. The value space has to be covered!
* Check modules using testbenches. Go bottom up. Check the lower modules first before you use them in larger modules!
* Simulation with Icarus Verilog and the synthesized design using yosys may differ from each other! It is possible to generate a design that performs correctly in simulation and fails on the hardware after flashing the bitstream! This is a huge problem!
* When writing combinational logic like this think about what are the inputs and outputs of the block. If it's an output you should only write to it if it's an input only read from it. Anything you want to read and write should be some internal signal to that block (i.e. not accessed anywhere else) and must be written first (otherwise you end up with this kind of situation with some kind of latching behaviour).
* Verilog is capable of all kinds of weird and wonderful behaviours due to it's many event regions and scheduling semantics. Don't play tricks with them it's likely to end badly as they're poorly specified and each synthesis tool will have it's own spin on how to deal with odd cases. Generally people follow a strict style guide to keep things simple and avoid issues like this and many of the possible race conditions that exist.
* yosys has horrible error output or output in general. It will output so much to the console that you can almost not see any errors or warnings! Better use Icarus Verilog first for linting. Icarus Verilog will abort when undefined signals are used for example. Such errors are completely buried by the pages of output that yosys produces.
* Only a single process should change a register. Sometimes yosys will abort the compilation if this rule is violated but sometimes it will finish without errors and output warnings instead! Pipe the output of yosys into a log file and search for all warnings for the register you are interested in! Make sure that there are no warnings!

# Errors

If nextpnr detects combinational loops, check if a value to the same register variable is set by to processes that have the same signal in their sensitivity list. (Example a reset signal is used in two different processes that set the same variable to different values)





# Checking pre vs. post synthesis to hunt down bugs in synthesized designs

## Quickstart

```
set PATH=%PATH%;C:\Users\wolfg\Downloads\oss-cad-suite\lib\
C:\Users\wolfg\Downloads\oss-cad-suite\environment.bat
```

```
C:\iverilog\bin\iverilog.exe -o build/test_pre.vvp test.v test_tb.v

yosys.exe -p "synth_ice40 -top test -blif build/test.blif -json build/test.json" test.v

yosys.exe -o build/test_syn.v build/test.blif

C:\iverilog\bin\iverilog.exe -o build/test_post.vvp -D NO_ICE40_DEFAULT_ASSIGNMENTS -D POST_SYNTHESIS test_tb.v build/test_syn.v C:\Users\wolfg\Downloads\oss-cad-suite\share\yosys\ice40\cells_sim.v

C:\iverilog\bin\vvp.exe build/test_pre.vvp
C:\iverilog\bin\vvp.exe build/test_post.vvp

gtkwave build/test_post.vcd
```

```
// normal simulation (pre synthesis)
C:\iverilog\bin\iverilog.exe -o build/alu_pre.vvp alu.v alu_tb.v
clear & C:\iverilog\bin\vvp.exe build/alu_pre.vvp



// build .blif and .json files
yosys.exe -p "synth_ice40 -top alu -blif build/alu.blif -json build/alu.json" alu.v

// perform synthesis and store result in alu_syn.v
//
// this step might fail. It has to produce a build/alu_syn.v file.
// You have to see "End of script." on the console. Otherwise it failed!
yosys.exe -o build/alu_syn.v build/alu.blif

// build alu_post.vvp
C:\iverilog\bin\iverilog.exe -o build/alu_post.vvp -D NO_ICE40_DEFAULT_ASSIGNMENTS -D POST_SYNTHESIS alu_tb.v build/alu_syn.v C:\Users\wolfg\Downloads\oss-cad-suite\share\yosys\ice40\cells_sim.v


clear & C:\iverilog\bin\vvp.exe build/alu_post.vvp

gtkwave build/alu_post.vcd
```



```
yosys.exe -p "synth_ice40 -top top -blif build/top.blif -json build/top.json" top.v riscv_multi.v uart_rx.v uart_tx.v clock_divider.v datapath.v controller.v mux2.v mux3.v mux4.v alu.v extend.v ram.v flopenr.v flopr.v regfile.v

yosys.exe -p "synth_ice40 -top riscv_multi -blif build/riscv_multi.blif -json build/riscv_multi.json" riscv_multi.v datapath.v controller.v mux2.v mux3.v mux4.v alu.v extend.v ram.v flopenr.v flopr.v regfile.v

yosys.exe -p "synth_ice40 -top datapath -blif build/datapath.blif -json build/datapath.json" datapath.v mux2.v mux3.v mux4.v alu.v extend.v ram.v flopenr.v flopr.v regfile.v

yosys.exe -p "synth_ice40 -top flopenr -blif build/flopenr.blif -json build/flopenr.json" flopenr.v

yosys.exe -p "synth_ice40 -top flopr -blif build/flopr.blif -json build/flopr.json" flopr.v

yosys.exe -p "synth_ice40 -top regfile -blif build/regfile.blif -json build/regfile.json" regfile.v

yosys.exe -p "synth_ice40 -top controller -blif build/controller.blif -json build/controller.json" controller.v

yosys.exe -p "synth_ice40 -top mux2 -blif build/mux2.blif -json build/mux2.json" mux2.v

yosys.exe -p "synth_ice40 -top mux3 -blif build/mux3.blif -json build/mux3.json" mux3.v

yosys.exe -p "synth_ice40 -top mux4 -blif build/mux4.blif -json build/mux4.json" mux4.v

yosys.exe -p "synth_ice40 -top alu -blif build/alu.blif -json build/alu.json" alu.v

yosys.exe -p "synth_ice40 -top extend -blif build/extend.blif -json build/extend.json" extend.v

yosys.exe -p "synth_ice40 -top ram -blif build/ram.blif -json build/ram.json" ram.v

yosys.exe -p "synth_ice40 -top uart_rx -blif build/uart_rx.blif -json build/uart_rx.json" uart_rx.v

yosys.exe -p "synth_ice40 -top uart_tx -blif build/uart_tx.blif -json build/uart_tx.json" uart_tx.v

yosys.exe -p "synth_ice40 -top clock_divider -blif build/clock_divider.blif -json build/clock_divider.json" clock_divider.v


yosys.exe -o build/top_syn.v build/top.blif
yosys.exe -o build/riscv_multi_syn.v build/riscv_multi.blif
yosys.exe -o build/datapath_syn.v build/datapath.blif
yosys.exe -o build/flopenr_syn.v build/flopenr.blif
yosys.exe -o build/flopr_syn.v build/flopr.blif
yosys.exe -o build/regfile_syn.v build/regfile.blif
yosys.exe -o build/controller_syn.v build/controller.blif
yosys.exe -o build/mux2_syn.v build/mux2.blif
yosys.exe -o build/mux3_syn.v build/mux3.blif
yosys.exe -o build/mux4_syn.v build/mux4.blif
yosys.exe -o build/alu_syn.v build/alu.blif
yosys.exe -o build/extend_syn.v build/extend.blif
yosys.exe -o build/ram_syn.v build/ram.blif
yosys.exe -o build/uart_rx_syn.v build/uart_rx.blif
yosys.exe -o build/uart_tx_syn.v build/uart_tx.blif
yosys.exe -o build/clock_divider_syn.v build/clock_divider.blif



C:\iverilog\bin\iverilog.exe -o build/top_post.vvp -D NO_ICE40_DEFAULT_ASSIGNMENTS -D POST_SYNTHESIS top_testbench.v build/top_syn.v build/riscv_multi_syn.v build/datapath_syn.v build/flopenr_syn.v build/flopr_syn.v build/regfile_syn.v build/controller_syn.v build/mux2_syn.v build/mux3_syn.v build/mux4_syn.v build/alu_syn.v build/extend_syn.v build/ram_syn.v build/uart_rx_syn.v build/uart_tx_syn.v build/clock_divider_syn.v C:\Users\wolfg\Downloads\oss-cad-suite\share\yosys\ice40\cells_sim.v


clear & C:\iverilog\bin\vvp.exe build/top_post.vvp

gtkwave build/aout.vcd
```





## BLIF (Berkeley Logic Interchange Format)

https://neilturley.dev/netlistsvg/

## Original Forum Post

Source: https://stackoverflow.com/questions/35927650/is-it-possible-to-create-a-simulation-waveform-from-yosys-output

So you want to run post-synthesis simulation of iCE40 BLIF netlists.

Consider the following simple example design (test.v):

```
module test(input clk, resetn, output reg [3:0] y);
  always @(posedge clk)
    y <= resetn ? y + 1 : 0;
endmodule
```

And its testbench (test_tb.v):

```
module testbench;
  reg clk = 1, resetn = 0;
  wire [3:0] y;

  always #5 clk = ~clk;

  initial begin
    repeat (10) @(posedge clk);
    resetn <= 1;
    repeat (20) @(posedge clk);
    $finish;
  end

  always @(posedge clk) begin
    $display("%b", y);
  end

  test uut (
    .clk(clk),
    .resetn(resetn),
`ifdef POST_SYNTHESIS
    . \y[0] (y[0]),
    . \y[1] (y[1]),
    . \y[2] (y[2]),
    . \y[3] (y[3])
`else
    .y(y)
`endif
  );
endmodule
```

Running pre-synthesis simulation is of course simple:

```
$ iverilog -o test_pre test.v test_tb.v
$ ./test_pre
```

For post-synthesis simulation we must first run synthesis:

```
$ yosys -p 'synth_ice40 -top test -blif test.blif' test.v
```

Then we must convert the BLIF netlist to a verilog netlist so it can be read by Icarus Verilog:

```
$ yosys -o test_syn.v test.blif
```

Now we can build the simulation binary from the test bench, the synthesized design, and the iCE40 simulation models, and run it:

```
$ iverilog -o test_post -D POST_SYNTHESIS test_tb.v test_syn.v \
                        `yosys-config --datdir/ice40/cells_sim.v`
$ ./test_post
```

[..] won't synthesize with iverilog for simulation.

This is most likely because Yosys is not as strict as iverilog when it comes to enforcing the Verilog standard. For example, in many cases Yosys will except Verilog files with the reg keyword missing from wires that would require the reg keyword according to the Verilog standard. For example, yosys will accept the following input, even though it is not valid Verilog code:

```
module test(input a, output y);
  always @* y = !a;
endmodule
```

For Icarus Verilog you have to add the missing reg:

```
module test(input a, output reg y);
  always @* y = !a;
endmodule
```