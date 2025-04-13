package com.mycompany.app.ast;

public class ModuleInstantiationPortConnection extends ASTNode {

    public ExpressionStatementASTNode expression;

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        // indent and name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append("PortConnection: ").append(value).append("\n");

        if (expression != null) {
            expression.printRecursive(stringBuilder, indent + 1);
        }

    }

}
