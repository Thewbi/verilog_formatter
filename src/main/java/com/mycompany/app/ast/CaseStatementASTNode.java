package com.mycompany.app.ast;

/**
 * Represents a case statement. Contains the case and default branches as
 * children.
 */
public class CaseStatementASTNode extends ASTNode {

    public ExpressionStatementASTNode expression;

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        // indent and name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append(value).append("\n");

        // indent and optional expression
        for (int i = 0; i < indent + 1; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append("expression:").append("\n");
        expression.printRecursive(stringBuilder, indent + 2);

        // children
        for (ASTNode child : children) {
            child.printRecursive(stringBuilder, indent + 1);
        }
    }

}
