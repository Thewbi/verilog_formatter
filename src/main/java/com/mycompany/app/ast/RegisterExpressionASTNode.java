package com.mycompany.app.ast;

import com.mycompany.app.ast.visitor.ASTNodeVisitor;

public class RegisterExpressionASTNode extends ExpressionStatementASTNode {

    public ExpressionStatementASTNode var;

    public RangeExpressionASTNode range;

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append("RegisterExpression: \n");

        for (int i = 0; i < indent + 1; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append("var: ").append(var.value).append("\n");

        for (int i = 0; i < indent + 1; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append("range: \n");
        range.printRecursive(stringBuilder, indent + 2);
        stringBuilder.append("\n");
    }

    public void visit(ASTNodeVisitor astNodeVisitor) {
        System.out.println("visit " + this.getClass());
        astNodeVisitor.visit(this);
        for (ASTNode child : children) {
            child.visit(astNodeVisitor);
        }
    }

}
