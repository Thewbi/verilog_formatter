package com.mycompany.app;

import java.util.ArrayList;
import java.util.List;

public class ASTNode {

    public ASTNode parent;

    public List<ASTNode> children = new ArrayList<>();

    public String value;

    public void printRecursive(StringBuilder stringBuilder, int indent) {
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append(value).append("\n");
        for (ASTNode child : children) {
            child.printRecursive(stringBuilder, indent + 1);
        }
    }

}
