package com.mycompany.app.ast;

public class PortASTNode extends ASTNode {

    public PortDirection portDirection;

    public ExpressionStatementASTNode expression;

    public void printRecursive(final StringBuilder stringBuilder, final int indent) {

        // indent and direction, type, name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append(portDirection).append(" " );
        if (expression != null) {
            expression.printRecursive(stringBuilder, 0);
        }
        stringBuilder.append(" ").append(value);
    }

}
