package com.mycompany.app.ast;

public class ConcatenationExpressionStatementASTNode extends ExpressionStatementASTNode {

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        // indent and operator or symbol
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append("[CONCATENATION]").append("\n");

        // all children
        for (ASTNode child : children) {
            child.printRecursive(stringBuilder, indent + 1);
        }
    }

}
