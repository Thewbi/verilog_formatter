package com.mycompany.app.ast;

import com.mycompany.app.ast.visitor.ASTNodeVisitor;

public class RangeExpressionASTNode extends ExpressionStatementASTNode {

    public ExpressionStatementASTNode left;

    public ExpressionStatementASTNode right;

    public int size;

    public void printRecursive(final StringBuilder stringBuilder, final int indent) {

        // indent and direction, type, name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }

        if (size == 1) {
            stringBuilder.append("[").append(right.value).append("] ");
        } else if (size == 2) {
            stringBuilder.append("[").append(left.value).append(", " ).append(right.value).append("] ");
        }
    }

    public void visit(ASTNodeVisitor astNodeVisitor) {
        System.out.println("visit " + this.getClass());
        astNodeVisitor.visit(this);
        for (ASTNode child : children) {
            child.visit(astNodeVisitor);
        }
    }

    public String toString() {

        StringBuilder stringBuilder = new StringBuilder();

        if (size == 1) {
            right.printRecursive(stringBuilder, 0);
        } else if (size == 2) {
            left.printRecursive(stringBuilder, 0);
            right.printRecursive(stringBuilder, 0);
        }

        return stringBuilder.toString();
    }
}
