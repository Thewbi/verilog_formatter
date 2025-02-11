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
