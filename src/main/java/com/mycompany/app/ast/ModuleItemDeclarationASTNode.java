package com.mycompany.app.ast;

public class ModuleItemDeclarationASTNode extends ASTNode {

    public DataTypeASTNode dataType;

    // public ASTNode expression;

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        // indent and name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append(value).append("\n");

        // // indent and expression
        // for (int i = 0; i < indent + 1; i++) {
        //     stringBuilder.append("  ");
        // }
        // stringBuilder.append("expression:").append("\n");
        // expression.printRecursive(stringBuilder, indent + 2);

        // indent and data type
        if (dataType != null) {
            for (int i = 0; i < indent + 1; i++) {
                stringBuilder.append("  ");
            }
            stringBuilder.append("datatype:").append("\n");
            dataType.printRecursive(stringBuilder, indent + 2);
        }

        // children
        for (ASTNode child : children) {
            child.printRecursive(stringBuilder, indent + 1);
        }
    }

}
