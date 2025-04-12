package com.mycompany.app.ast;

import com.mycompany.app.ast.visitor.ASTNodeVisitor;

public class PortASTNode extends TypedASTNode {

    public PortDirection portDirection;

    public ExpressionStatementASTNode expression;

    public String[] listOfPortNames;

    public void printRecursive(final StringBuilder stringBuilder, final int indent) {

        // indent and direction, type, name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append(portDirection).append(" " );

        // name
        if (value != null) {
            stringBuilder.append(" ").append(value).append("\n");
        }

        if ((listOfPortNames != null) && (listOfPortNames.length > 0)) {
            for (String portName : listOfPortNames) {
                stringBuilder.append(" [").append(portName).append("]");
            }
            stringBuilder.append("\n");
        }

        if (expression != null) {
            // stringBuilder.append("\n");
            expression.printRecursive(stringBuilder, 0);
        }

        // datatype
        if (dataType != null) {
            // stringBuilder.append("\n");
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
