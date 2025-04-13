package com.mycompany.app.ast;

public class NetDeclarationASTNode extends ASTNode {

    public ExpressionStatementASTNode expression;

    public String identifiers;

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        // indent and name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append("[NetDecl] ").append(value).append("\n");

        if (expression != null) {
            expression.printRecursive(stringBuilder, indent + 1);
        }

        if (identifiers != null) {
            for (int i = 0; i < indent + 1; i++) {
                stringBuilder.append("  ");
            }
            stringBuilder.append("identifiers: ").append(identifiers).append("\n");
        }

    }

}
