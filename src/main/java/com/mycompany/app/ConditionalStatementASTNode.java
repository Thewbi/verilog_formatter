package com.mycompany.app;

public class ConditionalStatementASTNode extends ASTNode {

    public boolean elseState;

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        // indent and name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append(value).append("\n");

        // children
        for (ASTNode child : children) {
            child.printRecursive(stringBuilder, indent + 1);
        }
    }
}
