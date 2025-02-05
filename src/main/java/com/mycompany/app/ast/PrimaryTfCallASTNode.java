package com.mycompany.app.ast;

import com.mycompany.app.PrimaryType;

public class PrimaryTfCallASTNode extends ASTNode {

    public PrimaryType primaryType;

    public void execute() {

        switch (primaryType) {

            case DISPLAY:
                for (ASTNode child : children.get(0).children) {
                    System.out.println(child.value);
                }
                break;

            case FINISH:
                throw new RuntimeException("Finish");

            default:
                throw new RuntimeException("Unknown primitive " + primaryType);
        }
    }

}
