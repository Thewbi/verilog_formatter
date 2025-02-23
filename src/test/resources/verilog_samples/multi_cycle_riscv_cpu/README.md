# Code Structure

The top_testbench.v instantiate top.v

top.v instantiates riscv_multi.v

riscv_multi.v instatiates the control logic controller.v and the datapath.v

The datapath.v contains a wishbone_master.v and a wishbone slave for the memory (main_memory.v)



# ALU

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s alu -o riscv.vvp alu.v
C:\iverilog\bin\iverilog.exe -s alu_testbench -o riscv.vvp alu_testbench.v alu.v
clear && C:\iverilog\bin\vvp.exe riscv.vvp
```

# Controller module

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s controller -o riscv.vvp controller.v
C:\iverilog\bin\iverilog.exe -s controller_testbench -o riscv.vvp controller_testbench.v controller.v
clear && C:\iverilog\bin\vvp.exe riscv.vvp
```

# Datapath module

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s datapath -o riscv.vvp datapath.v flopr.v flopenr.v mux2.v mux3.v alu.v regfile.v wishbone_master.v main_memory.v extend.v
C:\iverilog\bin\iverilog.exe -s datapath_testbench -o riscv.vvp datapath_testbench.v datapath.v flopr.v regfile.v
clear && C:\iverilog\bin\vvp.exe riscv.vvp
```

# extend module

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s extend -o riscv.vvp extend.v
C:\iverilog\bin\iverilog.exe -s extend_testbench -o riscv.vvp extend_testbench.v extend.v
clear && C:\iverilog\bin\vvp.exe riscv.vvp
```

# flopenr module

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s flopenr -o riscv.vvp flopenr.v
C:\iverilog\bin\iverilog.exe -s flopenr_testbench -o riscv.vvp flopenr_testbench.v flopenr.v
clear && C:\iverilog\bin\vvp.exe riscv.vvp
```

# flopr module

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s flopr -o riscv.vvp flopr.v
C:\iverilog\bin\iverilog.exe -s flopr_testbench -o riscv.vvp flopr_testbench.v flopr.v
clear && C:\iverilog\bin\vvp.exe riscv.vvp
```

# Memory

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s main_memory -o riscv.vvp main_memory.v
C:\iverilog\bin\iverilog.exe -s main_memory_testbench -o riscv.vvp main_memory_testbench.v main_memory.v
clear && C:\iverilog\bin\vvp.exe riscv.vvp
```

# mux2 module

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s mux2 -o riscv.vvp mux2.v
C:\iverilog\bin\iverilog.exe -s mux2_testbench -o riscv.vvp mux2_testbench.v mux2.v
clear && C:\iverilog\bin\vvp.exe riscv.vvp
```

# mux3 module

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s mux3 -o riscv.vvp mux3.v
C:\iverilog\bin\iverilog.exe -s mux3_testbench -o riscv.vvp mux3_testbench.v mux3.v
clear && C:\iverilog\bin\vvp.exe riscv.vvp
```

# Regfile module

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s regfile -o riscv.vvp regfile.v
C:\iverilog\bin\iverilog.exe -s regfile_testbench -o riscv.vvp regfile_testbench.v regfile.v
clear && C:\iverilog\bin\vvp.exe riscv.vvp
```

# RISCV Multicycle CPU

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s riscv_multi -o riscv.vvp riscv_multi.v controller.v datapath.v flopr.v regfile.v alu.v extend.v flopenr.v main_memory.v mux2.v mux3.v wishbone_master.v

C:\iverilog\bin\iverilog.exe -s top_testbench -o riscv.vvp top_testbench.v top.v riscv_multi.v datapath.v flopr.v regfile.v wishbone_master.v main_memory.v controller.v

clear && C:\iverilog\bin\vvp.exe riscv.vvp
```

# Top module

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s top -o riscv.vvp top.v wishbone_master.v main_memory.v riscv_multi.v controller.v datapath.v alu.v extend.v flopenr.v flopr.v regfile.v mux2.v mux3.v
C:\iverilog\bin\iverilog.exe -s top_testbench -o riscv.vvp top_testbench.v top.v wishbone_master.v main_memory.v riscv_multi.v controller.v datapath.v alu.v extend.v flopenr.v flopr.v regfile.v mux2.v mux3.v
clear && C:\iverilog\bin\vvp.exe riscv.vvp
```

# Wishbone Master

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s wishbone_master -o riscv.vvp wishbone_master.v
C:\iverilog\bin\iverilog.exe -s wishbone_master_testbench -o riscv.vvp wishbone_master_testbench.v wishbone_master.v
clear && C:\iverilog\bin\vvp.exe riscv.vvp
```





# Controller, Control Logic, Control Unit module

```
del riscv.vpp
C:\iverilog\bin\iverilog.exe -s controller -o riscv.vvp controller.v
C:\iverilog\bin\iverilog.exe -s controller_testbench -o riscv.vvp controller_testbench.v controller.v
clear && C:\iverilog\bin\vvp.exe riscv.vvp
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