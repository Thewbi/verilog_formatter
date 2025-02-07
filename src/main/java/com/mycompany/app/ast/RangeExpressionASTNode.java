package com.mycompany.app.ast;

public class RangeExpressionASTNode extends ExpressionStatementASTNode {

    public ExpressionStatementASTNode left;

    public ExpressionStatementASTNode right;

    public void printRecursive(final StringBuilder stringBuilder, final int indent) {

        // indent and direction, type, name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append("[").append(left.value).append(", " ).append(right.value).append("] ");
    }

}
