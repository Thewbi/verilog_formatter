package com.mycompany.app.ast;

import com.mycompany.app.ast.visitor.ASTNodeVisitor;

public class DataTypeASTNode extends ASTNode {

    /** If the datatype is an array, this range expression is present. */
    public ExpressionStatementASTNode rangeExpression;

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        // indent and name
        for (int i = 0; i < indent + 1; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append("type: ");
        stringBuilder.append(value);

        // indent and expression
        if (rangeExpression != null) {
            stringBuilder.append("\n");
            for (int i = 0; i < indent + 1; i++) {
                stringBuilder.append("  ");
            }
            stringBuilder.append("range-expression: ").append("\n");
            rangeExpression.printRecursive(stringBuilder, indent + 2);
            //rangeExpression.printRecursive(stringBuilder, 0);
        }

        // children
        for (ASTNode child : children) {
            child.printRecursive(stringBuilder, indent + 2);
        }
    }

    public void visit(ASTNodeVisitor astNodeVisitor) {
        System.out.println("visit " + this.getClass());
        astNodeVisitor.visit(this);
        for (ASTNode child : children) {
            child.visit(astNodeVisitor);
        }
    }
}
