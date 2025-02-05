package com.mycompany.app.ast;

public class ModuleDeclaractionASTNode extends ASTNode {

    public String name;

    public void printRecursive(StringBuilder stringBuilder, int indent) {
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append("ModuleDecl: ").append(name).append("\n");
        for (ASTNode child : children) {
            child.printRecursive(stringBuilder, indent + 1);
        }
    }

}
