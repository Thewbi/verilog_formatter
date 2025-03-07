```
cd C:\Users\wolfg\dev\Java\verilog_formatter\src\test\resources\verilog_samples\multi_cycle_riscv_cpu_rebuild

C:\iverilog\bin\iverilog.exe -s top_testbench -o riscv.vvp top_testbench.v top.v riscv_multi.v datapath.v flopenr.v flopr.v regfile.v controller.v mux2.v mux3.v alu.v extend.v imem.v dmem.v

clear && C:\iverilog\bin\vvp.exe riscv.vvp

gtkwave test.vcd

C:\iverilog\bin\vvp.exe riscv.vvp -lxt2
```