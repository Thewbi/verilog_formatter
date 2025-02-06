package com.mycompany.app.ast;

/**
 * Nonblocking assignment: <=
 * Blocking assignment: =
 */
public class AssignmentASTNode  extends ASTNode {

    public ASTNode expression;

    public ASTNode target;

    public boolean blocking;

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        // assignment node
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append(value).append("\n");

        // blocking
        for (int i = 0; i < indent + 1; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append("blocking: ").append(blocking).append("\n");

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

    public String toString() {

        StringBuilder stringBuilder = new StringBuilder();
        int indent = 0;
        printRecursive(stringBuilder, indent);

        return stringBuilder.toString();
    }

}
