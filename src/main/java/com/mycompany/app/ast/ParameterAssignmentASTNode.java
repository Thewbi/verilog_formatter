package com.mycompany.app.ast;

public class ParameterAssignmentASTNode extends ASTNode {

    public ExpressionStatementASTNode expression;

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        // indent and name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append("ParameterAssignment: ").append(value).append("\n");

        expression.printRecursive(stringBuilder, indent + 1);

    }

}
