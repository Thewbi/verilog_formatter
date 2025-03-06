```
C:\iverilog\bin\iverilog.exe -s top_testbench -o riscv.vvp top_testbench.v top.v riscv_multi.v datapath.v flopenr.v flopr.v regfile.v controller.v mux2.v mux3.v alu.v aludec.v extend.v imem.v

clear && C:\iverilog\bin\vvp.exe riscv.vvp
```

```
C:\iverilog\bin\iverilog.exe -s aludec -o riscv.vvp aludec.v

clear && C:\iverilog\bin\vvp.exe riscv.vvp
```