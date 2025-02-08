package com.mycompany.app.ast;

public class DataTypeASTNode extends ASTNode {

    /** If the datatype is an arry, this range expression is present. */
    public ExpressionStatementASTNode rangeExpression;

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        // indent and name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append(value).append("\n");

        // indent and expression
        if (rangeExpression != null) {
            for (int i = 0; i < indent + 1; i++) {
                stringBuilder.append("  ");
            }
            stringBuilder.append("expression:").append("\n");

            // for (int i = 0; i < indent + 1; i++) {
            //     stringBuilder.append("  ");
            // }
            rangeExpression.printRecursive(stringBuilder, indent + 2);
            // stringBuilder.append("\n");
        }

        // children
        for (ASTNode child : children) {
            child.printRecursive(stringBuilder, indent + 1);
        }
    }

}
