package com.mycompany.app.ast;

import java.util.ArrayList;
import java.util.List;

public class ASTNode {

    public ASTNode parent;

    public List<ASTNode> children = new ArrayList<>();

    public String value;

    public Object ctx;

    public ASTNode() {
    }

    public ASTNode(String value) {
        this.value = value;
    }

    public void printRecursive(final StringBuilder stringBuilder, final int indent) {

        // indent and operator or symbol
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append(value).append("\n");

        // all children
        for (ASTNode child : children) {
            child.printRecursive(stringBuilder, indent + 1);
        }
    }

}
