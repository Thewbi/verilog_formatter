package com.mycompany.app.ast;

/**
 * Maybe needs to be renamed to ProceduralTimingControlStatementASTNode
 */
public class ProceduralTimingControlStatementASTNode extends ASTNode {

    public ExpressionStatementASTNode expression;

    /** This node is a initial block in a module! */
    public boolean initial;

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        // indent and name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append(value).append("\n");

        if (expression != null) {
            // indent and expression
            for (int i = 0; i < indent + 1; i++) {
                stringBuilder.append("  ");
            }
            stringBuilder.append("expression:").append("\n");
            expression.printRecursive(stringBuilder, indent + 2);
        }

        // all children
        for (ASTNode child : children) {
            child.printRecursive(stringBuilder, indent + 1);
        }
    }

}
