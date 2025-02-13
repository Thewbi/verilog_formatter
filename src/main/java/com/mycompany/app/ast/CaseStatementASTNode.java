package com.mycompany.app.ast;

import com.mycompany.app.ast.visitor.ASTNodeVisitor;

/**
 * Represents a case statement. Contains the case and default branches as
 * children.
 */
public class CaseStatementASTNode extends ASTNode {

    public ExpressionStatementASTNode expression;

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        stringBuilder.append("\n");

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
            stringBuilder.append("\n");
            child.printRecursive(stringBuilder, indent + 1);
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
