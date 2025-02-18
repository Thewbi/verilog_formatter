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

# Top module

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s top -o riscv.vvp top.v wishbone_master.v main_memory.v
C:\iverilog\bin\iverilog.exe -s top_testbench -o riscv.vvp top_testbench.v top.v wishbone_master.v main_memory.v
C:\iverilog\bin\vvp.exe riscv.vvp
```

# Controller module

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s controller -o riscv.vvp controller.v
C:\iverilog\bin\iverilog.exe -s controller_testbench -o riscv.vvp controller_testbench.v controller.v
C:\iverilog\bin\vvp.exe riscv.vvp
```

# Refile module

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s regfile -o riscv.vvp regfile.v
C:\iverilog\bin\iverilog.exe -s regfile_testbench -o riscv.vvp regfile_testbench.v regfile.v
C:\iverilog\bin\vvp.exe riscv.vvp
```

# Controller, Control Logic, Control Unit module

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s controller -o riscv.vvp controller.v
C:\iverilog\bin\iverilog.exe -s controller_testbench -o riscv.vvp controller_testbench.v controller.v
C:\iverilog\bin\vvp.exe riscv.vvp
```

# Datapath module

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s datapath -o riscv.vvp datapath.v flopr.v regfile.v
C:\iverilog\bin\iverilog.exe -s datapath_testbench -o riscv.vvp datapath_testbench.v datapath.v flopr.v regfile.v
C:\iverilog\bin\vvp.exe riscv.vvp
```

# RISCV Multicycle CPU

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s riscv_multi -o riscv.vvp riscv_multi.v controller.v datapath.v flopr.v regfile.v

C:\iverilog\bin\iverilog.exe -s top_testbench -o riscv.vvp top_testbench.v top.v riscv_multi.v datapath.v flopr.v regfile.v wishbone_master.v main_memory.v controller.v

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