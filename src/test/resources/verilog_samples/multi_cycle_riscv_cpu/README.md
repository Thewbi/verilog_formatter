# Sample Code

```
# riscvtest.s
# Sarah.Harris@unlv.edu
# David_Harris@hmc.edu
#
# 27 Oct 2020
# Test the RISC-V processor:
# add, sub, and, or, slt, addi, lw, sw, beq, jal
#
# If successful, it should write the value 25 to address 100
#       RISC-V Assembly         Description                 Address     Machine Code
main:   addi x2, x0, 5          # x2 = 5                    0           00500113
        addi x3, x0, 12         # x3 = 12                   4           00C00193
        addi x7, x3, -9         # x7 = (12 - 9) = 3         8           FF718393
        or x4, x7, x2           # x4 = (3 OR 5) = 7         C           0023E233
        and x5, x3, x4          # x5 = (12 AND 7) = 4       10          0041F2B3
        add x5, x5, x4          # x5 = 4 + 7 = 11           14          004282B3
        beq x5, x7, end         # shouldn't be taken        18          02728863
        slt x4, x3, x4          # x4 = (12 < 7) = 0         1C          0041A233
        beq x4, x0, around      # should be taken           20          00020463
        addi x5, x0, 0          # shouldn't execute         24          00000293
around: slt x4, x7, x2          # x4 = (3 < 5) = 1          28          0023A233
        add x7, x4, x5          # x7 = (1 + 11) = 12        2C          005203B3
        sub x7, x7, x2          # x7 = (12 - 5) = 7         30          402383B3
        sw x7, 84(x3)           # [96] = 7                  34          0471AA23
        lw x2, 96(x0)           # x2 = [96] = 7             38          06002103
        add x9, x2, x5          # x9 = (7 + 11) = 18        3C          005104B3
        jal x3, end             # jump to end, x3 = 0x44    40          008001EF
        addi x2, x0, 1          # shouldn't execute         44          00100113
end:    add x2, x2, x9          # x2 = (7 + 18) = 25        48          00910133
        sw x2, 0x20(x3)         # [100] = 25                4C          0221A023
done:   beq x2, x2, done        # infinite loop             50          00210063
```



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