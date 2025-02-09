package com.mycompany.app.ast;

import com.mycompany.app.ast.visitor.ASTNodeVisitor;

public class PortASTNode extends TypedASTNode {

    public PortDirection portDirection;

    public ExpressionStatementASTNode expression;

    // public DataTypeASTNode dataType;

    public void printRecursive(final StringBuilder stringBuilder, final int indent) {

        // indent and direction, type, name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append(portDirection).append(" " );
        // name
        stringBuilder.append(" ").append(value).append("\n");

        if (expression != null) {
            expression.printRecursive(stringBuilder, 0);
        }

        // datatype
        // for (int i = 0; i < indent; i++) {
        //     stringBuilder.append("  ");
        // }
        if (dataType != null) {
            dataType.printRecursive(stringBuilder, indent);
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
