package com.mycompany.app.ast;

public class NetDeclarationASTNode extends TypedASTNode {

    public ExpressionStatementASTNode expression;

    public String identifiers;

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        // indent and name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append("[NetDecl] ").append(value).append("\n");

        // datatype
        if (dataType != null) {
            dataType.printRecursive(stringBuilder, indent + 1);
        }

        // identifiers = name
        if (identifiers != null) {
            stringBuilder.append("\n");
            for (int i = 0; i < indent + 1; i++) {
                stringBuilder.append("  ");
            }
            stringBuilder.append("identifiers: ").append(identifiers).append("\n");
        }

        // expression is the value the wire is initialized with. 
        // It might be a scalar value, a tree of expression nodes or a concatenation
        if (expression != null) {
            // stringBuilder.append("\n");
            for (int i = 0; i < indent + 1; i++) {
                stringBuilder.append("  ");
            }
            stringBuilder.append("init-expression: \n");
            expression.printRecursive(stringBuilder, indent + 2);
        }

    }

}
