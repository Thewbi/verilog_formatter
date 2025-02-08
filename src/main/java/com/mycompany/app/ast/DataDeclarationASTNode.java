package com.mycompany.app.ast;

public class DataDeclarationASTNode extends TypedASTNode {

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        // indent and name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append(value).append("\n");

        // indent and data type
        if (dataType != null) {
            for (int i = 0; i < indent + 1; i++) {
                stringBuilder.append("  ");
            }
            stringBuilder.append("datatype:").append("\n");
            dataType.printRecursive(stringBuilder, indent + 1);
        }

        stringBuilder.append("\n");

        // children
        for (ASTNode child : children) {
            child.printRecursive(stringBuilder, indent + 1);
        }
    }
}
