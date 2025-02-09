package com.mycompany.app.ast;

import java.util.ArrayList;
import java.util.List;

import com.mycompany.app.ast.visitor.ASTNodeVisitor;

public class ModuleDeclaractionASTNode extends ASTNode {

    public String name;

    public List<PortASTNode> ports = new ArrayList<>();

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        // indent and name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append("ModuleDecl: ").append(name).append("\n");

        // indent and ports
        if (ports.size() > 0) {
            for (int i = 0; i < indent; i++) {
                stringBuilder.append("  ");
            }
            stringBuilder.append("Ports: ").append("\n");
            for (ASTNode port : ports) {
                port.printRecursive(stringBuilder, indent + 1);
                stringBuilder.append("\n");
            }
        }

        // all children
        for (ASTNode child : children) {
            child.printRecursive(stringBuilder, indent + 1);
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
