# Memory

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s main_memory -o riscv.vvp main_memory.v
C:\iverilog\bin\iverilog.exe -s main_memory_testbench -o riscv.vvp main_memory_testbench.v main_memory.v
C:\iverilog\bin\vvp.exe riscv.vvp
```

# Wishbone Master

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s wishbone_master -o riscv.vvp wishbone_master.v
C:\iverilog\bin\iverilog.exe -s wishbone_master_testbench -o riscv.vvp wishbone_master_testbench.v wishbone_master.v
C:\iverilog\bin\vvp.exe riscv.vvp
```

# Preprocessor

Icarus Verilog has a preprocessor build in.
To run the preprocessor only, use the -E flag.

See https://steveicarus.github.io/iverilog/usage/command_line_flags.html
```
C:\iverilog\bin\iverilog.exe -E -o preprocessed.v wishbone_master.v
```

Compile the preprocessed file:

```
C:\iverilog\bin\iverilog.exe -s preprocessed -o riscv.vvp preprocessed.v
```