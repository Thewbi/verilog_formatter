package com.mycompany.app.ast;

/**
 * Currently the ConditionalStatementASTNode is used for if statements.
 * All children of this node need to be connected via else branches!
 * They are not independent from each other, but every child is a sub branch
 * of a single, large if statement. The last statement is the else branch and
 * does not have to be of type IfStatementASTNode. It can be a general AST node.
 */
public class ConditionalStatementASTNode extends ASTNode {

    public boolean elseState;

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        // indent and name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append(value).append("\n");

        // children
        for (ASTNode child : children) {
            child.printRecursive(stringBuilder, indent + 1);
        }
    }
}
