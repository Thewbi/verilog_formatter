# verilog_formatter
formatter

## System Verilog Search Rules

From "System Verilog for Design, Second Edition"

Local definitions and declarations within a module or interface take
precedence over a wildcard import. An import that specifically
names package items also takes precedence over a wildcard import.
From a designer’s point of view, a wildcard import simply adds the
package to the search rules / search path for an identifier but it does
not import all objects!

Software tools will
search for local declarations first (following Verilog search rules for
within a module), and then search in any packages that were
imported using a wildcard. Finally, tools will search in SystemVer-
ilog’s $unit declaration space. The $unit space is discussed in
section 2.2 on page 14 of this chapter.

## System Verilog Identifier Search Rules

Declarations in the compilation-unit scope can be referenced any-
where in the hierarchy of modules that are part of the compilation
unit.

SystemVerilog defines a simple and intuitive search rule for when
referencing an identifier:
1. First, search for local declarations, as defined in the IEEE 1364 Verilog standard.
2. Second, search for declarations in packages which have been wildcard imported into the current scope.
3. Third, search for declarations in the compilation-unit scope.
4. Fourth, search for declarations within the design hierarchy, following IEEE 1364 Verilog search rules.

The SystemVerilog search rules ensure that SystemVerilog is fully
backward compatible with Verilog.

# IVerilog on Windows

Icarus Verilog is a simulator that is available on Windows free of charge.
It comes in the form of a Windows Installer which is very small in size.

Download Icarus Verilog from https://bleyer.org/icarus/

After installation (with default settings), the executable is located here:

```
C:\iverilog\bin\iverilog.exe
```

iverilog.exe is a command line tool and it does not have a graphical UI.

## The Icarus Verilog workflow on Windows

In a first step, verilog code is written to verilog source files.
Then the iverilog.exe binary is used to tranlate the verilog code to vvp code.
Then, that vvp code is executed using the vvp.exe.

```
C:\iverilog\bin\iverilog.exe
```

It is possible to execute modules directly or execute testbenches on modules.

Compiling only a single module:

```
C:\iverilog\bin\iverilog.exe -o hello.vpp hello.v
C:\iverilog\bin\vvp.exe hello.vpp
```

Compiling a testbench and a module:

```
C:\iverilog\bin\iverilog.exe -o my_design counter_tb.v counter.v
C:\iverilog\bin\vvp.exe my_design.vpp
```

Icarus Verilog parses all modules from all input files. It will then figure out
which modules are not instantiated within other modules. In other words Icarus
Verilog produces a set of top-level modules which are not instantiated anywhere.

Icarus Verilog will then simulate all top-level modules.

If you only want to simulate a specific module, then you have to use the -s
command line parameter and specify the name of the top-level module you want
to simulate.

## Getting started

A getting started tutorial is located here: https://steveicarus.github.io/iverilog/usage/getting_started.html

## Loading data into memory

https://projectf.io/posts/initialize-memory-in-verilog/
https://stackoverflow.com/questions/66824196/icarus-verilog-warning-readmemh-standard-inconsistency-following-1364-2005

It seems that Icarus Verilog supports the $readmemh() primitive which can be used
to load data into memory.

```
module readmemh_tb();
    reg [7:0] test_memory [0:15];
    initial begin
        $display("Loading rom.");
        $readmemh("rom_image.mem", test_memory);
    end
endmodule
```









