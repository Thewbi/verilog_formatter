# Hint
Sadly Icarus Verilog does not understand SystemVerilog and hence this
CPU cannot be compiled and / or simulated using Icarus Verilog.

# Compiling
cd into this folder

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s top -o riscv.vvp top.sv
C:\iverilog\bin\vvp.exe riscv.vvp
```