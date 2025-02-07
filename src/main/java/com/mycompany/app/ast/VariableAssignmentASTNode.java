package com.mycompany.app.ast;

/**
 * This is a Continuous assignment (used output a process and takes place as soon as the signals
 * on the right-hand side change.)
 *
 * assign y = a + b; // explicit
 * y = a + b; // implicit
 *
 * Example file: src\test\resources\system_verilog_samples\harris_single_cycle_riscv_cpu\adder.sv
 */
public class VariableAssignmentASTNode extends ASTNode {

    public ASTNode expression;

    public ASTNode target;

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        // assignment node
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append(value).append("\n");

        // target
        for (int i = 0; i < indent + 1; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append("target: ").append(target.value).append("\n");

        // expression
        for (int i = 0; i < indent + 1; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append("expression:").append("\n");
        expression.printRecursive(stringBuilder, indent + 2);

        // children
        for (ASTNode child : children) {
            child.printRecursive(stringBuilder, indent + 2);
        }
    }

}
