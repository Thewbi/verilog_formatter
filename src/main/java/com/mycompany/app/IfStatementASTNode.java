package com.mycompany.app;

public class IfStatementASTNode extends ASTNode {

    public ASTNode expression;

    public void printRecursive(StringBuilder stringBuilder, int indent) {
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append(value).append("\n");

        for (int i = 0; i < indent + 1; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append("expression:").append("\n");
        expression.printRecursive(stringBuilder, indent + 2);
        for (ASTNode child : children) {
            child.printRecursive(stringBuilder, indent + 2);
        }
    }

}
