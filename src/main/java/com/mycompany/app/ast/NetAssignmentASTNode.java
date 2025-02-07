package com.mycompany.app.ast;

/**
 * A assignment located within a process so it is a sequential assignment.
 * The assignment is done using the = operator which makes it blocking.
 * This is a blocking assignment.
 *
 * Do not confuse this assignment with non-blocking sequential assignment.
 *
 * Do not confuse this assignment with an assign-keyword assignment which
 * is a standard assignment and which is used outside of processes.
 */
public class NetAssignmentASTNode extends ASTNode {

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
