package com.mycompany.app.ast;

import com.mycompany.app.ast.visitor.ASTNodeVisitor;

public class ExpressionStatementASTNode extends ASTNode {

    public String operator;

    public ExpressionStatementASTNode lhs;

    public ExpressionStatementASTNode rhs;

    /**
     * For the elvis operator (predicate ? lhs : rhs), the expression consists of a
     * predict, a left-hand side and a right-hand side. This is the predicate.
     */
    public ExpressionStatementASTNode predicate;

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        if ((lhs == null) && (rhs == null)) {

            for (int i = 0; i < indent; i++) {
                stringBuilder.append("  ");
            }
            stringBuilder.append(value).append(" "); //.append("\n");

        } else {

            // elvis expressions do have an additional predicate
            if (predicate != null) {
                for (int i = 0; i < indent; i++) {
                    stringBuilder.append("  ");
                }
                stringBuilder.append("elvis-predicate: \n");
                predicate.printRecursive(stringBuilder, indent + 1);
            }

            // lhs
            if (lhs != null) {
                lhs.printRecursive(stringBuilder, indent + 1);
            }

            // indent and operator
            for (int i = 0; i < indent; i++) {
                stringBuilder.append("  ");
            }
            stringBuilder.append(operator).append("\n");

            // rhs
            if (rhs != null) {
                rhs.printRecursive(stringBuilder, indent + 1);
            }
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
