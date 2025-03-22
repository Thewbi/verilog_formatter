# Simulation with Icarus Verilog

```
cd C:\Users\wolfg\dev\Java\verilog_formatter\src\test\resources\verilog_samples\multi_cycle_riscv_cpu_rebuild

// sepearate instruction memory (imem) and data memory (dmem)
C:\iverilog\bin\iverilog.exe -s top_testbench -o riscv.vvp top_testbench.v top.v riscv_multi.v datapath.v flopenr.v flopr.v regfile.v controller.v mux2.v mux3.v mux4.v alu.v extend.v imem.v dmem.v

// for data and code in a single RAM module (ram.v)
C:\iverilog\bin\iverilog.exe -s top_testbench -o riscv.vvp top_testbench.v top.v riscv_multi.v datapath.v flopenr.v flopr.v regfile.v controller.v mux2.v mux3.v mux4.v alu.v extend.v ram.v

clear && C:\iverilog\bin\vvp.exe riscv.vvp

gtkwave test.vcd

C:\iverilog\bin\vvp.exe riscv.vvp -lxt2
```

# Quickstart

```
cd <your_project_folder>
mkdir build

set PATH=%PATH%;C:\Users\wolfg\Downloads\oss-cad-suite\lib\
C:\Users\wolfg\Downloads\oss-cad-suite\environment.bat

yosys.exe -p "synth_ice40 -top top -blif build/aout.blif -json build/aout.json" top_testbench.v top.v riscv_multi.v datapath.v flopenr.v flopr.v regfile.v controller.v mux2.v mux3.v alu.v extend.v ram.v

yosys.exe -p "synth_ice40 -top top -blif build/aout.blif -json build/aout.json" top.v riscv_multi.v datapath.v flopenr.v flopr.v regfile.v controller.v mux2.v mux3.v alu.v extend.v ram.v

nextpnr-ice40 --hx1k --package tq144 --json build/aout.json --asc build/aout.asc --pcf icestick.pcf -q
icepack build/aout.asc build/aout.bin
iceprog -d i:0x0403:0x6010:0 build/aout.bin
```

# Lessons Learned

* Do not ever use initialized memory (RAM for instructions or data)! You will hunt non-existent bugs in your CPU for hours!
* Check modules using testbenches. Go bottom up. Check the lower modules first befor you use them in larger modules!