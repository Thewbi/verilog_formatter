package com.mycompany.app.ast;

import com.mycompany.app.ast.visitor.ASTNodeVisitor;

public class ModuleItemDeclarationASTNode extends TypedASTNode {

    public void visit(ASTNodeVisitor astNodeVisitor) {
        System.out.println("visit " + this.getClass());
        astNodeVisitor.visit(this);
        for (ASTNode child : children) {
            child.visit(astNodeVisitor);
        }
    }

}
