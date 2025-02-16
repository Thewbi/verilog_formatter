# Introduction

This folder contains a modified version of the single cycle RISCV CPU
as outlined in the book Digital Design and Computer Architecture: RISC-V Edition
Sarah L. Harris and David Harris

https://pages.hmc.edu/harris/ddca/ddcarv.html

The modifications are
- support the lw instruction to read from memory
- if the address is the address of a memory mapped peripheral, then the wishbone master
will talk to the peripheral because the memory mapper will multiplex the lines between
the wishbone master and the respective perihperal.
- if the address points to memory outside a memory mapped region, the lines are
multiplexed to the memory wishbone slave which stands for normal RAM.

This approach is used in Angelo Jacobo's RISCV core: https://github.com/AngeloJacobo/RISC-V

- if the wishbone slave stalls the master, then the master will stall the host.
The host in this case is the RISCV CPU. The RISV C CPU Is stalled by disabling the
datapath, in other words the datapath will ignore the clock ticks and only
the wishbone master will be run.

1. [TODO] format the file src\test\resources\verilog_samples\wishbone_master.v
2. [TODO] write a testbench for wishbone_master.v
3. [OK] Copy the memory wishbone slave from Angelo Jacobo and convert it to verilog
4. [OK] Write a testbench for that memory wishbone slave
5. [TODO] Copy the memory wrapper
6. [TODO] Extend the RISV CPU with the wishbone master
   I think in order to implement number 6, the riscv CPU has to be pipelined
   (See also 7.4 MULTICYCLE PROCESSOR, page 415, and also 7 . 4 . 1 Multicycle Datapath
   on page 416,
   in Harris & Harris RiscV edition which underlines this theory).
   Currently the single cycle CPU has separate instruction and data memory.
   Combining both into a single wishbone slave memory for instructions and data needs
   to break the single cycle into two phases for fetching the instruction and a second
   cycle for accessing (read / write) the memory. When the single cycle CPU is
   broken into stages anyways, maybe build a five stage pipeline right away.
7. [TODO] Run the example progmem.txt using code that is loaded from the memory slave
8. [TODO] Implement the lw instruction
9. [TODO] Add a UART wishbone slave
10. [TODO] Write an example that loads a single character from the wishbone slave.

# Compiling

cd into this folder

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s top -o riscv.vvp top.v
C:\iverilog\bin\vvp.exe riscv.vvp
```

```
cd C:\Users\wolfg\dev\Java\verilog_formatter\src\test\resources\verilog_samples\harris_single_cycle_riscv_cpu
del riscv.vpp

C:\iverilog\bin\iverilog.exe -s adder -o riscv.vvp adder.v

C:\iverilog\bin\iverilog.exe -s aludec -o riscv.vvp aludec.v

C:\iverilog\bin\iverilog.exe -s maindec -o riscv.vvp maindec.v

C:\iverilog\bin\iverilog.exe -s controller -o riscv.vvp controller.v maindec.v aludec.v

C:\iverilog\bin\iverilog.exe -s dmem -o riscv.vvp dmem.v

C:\iverilog\bin\iverilog.exe -s extend -o riscv.vvp extend.v

C:\iverilog\bin\iverilog.exe -s flopenr -o riscv.vvp flopenr.v

C:\iverilog\bin\iverilog.exe -s flopr -o riscv.vvp flopr.v

C:\iverilog\bin\iverilog.exe -s imem -o riscv.vvp imem.v

C:\iverilog\bin\iverilog.exe -s mux2 -o riscv.vvp mux2.v

C:\iverilog\bin\iverilog.exe -s mux3 -o riscv.vvp mux3.v

C:\iverilog\bin\iverilog.exe -s regfile -o riscv.vvp regfile.v

C:\iverilog\bin\iverilog.exe -s alu -o riscv.vvp alu.v

C:\iverilog\bin\iverilog.exe -s datapath -o riscv.vvp datapath.v flopr.v aludec.v alu.v adder.v mux2.v mux3.v regfile.v extend.v

C:\iverilog\bin\iverilog.exe -s riscvsingle -o riscv.vvp riscvsingle.v controller.v datapath.v maindec.v flopr.v aludec.v alu.v adder.v mux2.v mux3.v regfile.v extend.v

C:\iverilog\bin\iverilog.exe -s top -o riscv.vvp top.v riscvsingle.v imem.v dmem.v controller.v datapath.v maindec.v flopr.v aludec.v alu.v adder.v mux2.v mux3.v regfile.v extend.v

C:\iverilog\bin\iverilog.exe -s testbench -o riscv.vvp testbench.v top.v riscvsingle.v imem.v dmem.v controller.v datapath.v maindec.v flopr.v aludec.v alu.v adder.v mux2.v mux3.v regfile.v extend.v

C:\iverilog\bin\vvp.exe riscv.vvp
```

In order to run the simulation with Icarus Verilog, run the testbench.s file as top-level module.
You have to execute the following statements to run the simulation:

```
cd C:\Users\wolfg\dev\Java\verilog_formatter\src\test\resources\verilog_samples\harris_single_cycle_riscv_cpu
del riscv.vpp

C:\iverilog\bin\iverilog.exe -s testbench -o riscv.vvp testbench.v top.v riscvsingle.v imem.v dmem.v controller.v datapath.v maindec.v flopr.v aludec.v alu.v adder.v mux2.v mux3.v regfile.v extend.v

C:\iverilog\bin\vvp.exe riscv.vvp
```

# Memory

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s main_memory -o riscv.vvp main_memory.v
C:\iverilog\bin\iverilog.exe -s testbench -o riscv.vvp main_memory_testbench.v main_memory.v
C:\iverilog\bin\vvp.exe riscv.vvp
```