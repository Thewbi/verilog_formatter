package com.mycompany.app;

public class ExpressionStatementASTNode extends ASTNode {

    public String operator;

    public ExpressionStatementASTNode lhs;

    public ExpressionStatementASTNode rhs;

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        if ((lhs == null) && (rhs == null)) {
            for (int i = 0; i < indent; i++) {
                stringBuilder.append("  ");
            }
            stringBuilder.append(value).append("\n");
        } else {
            if (lhs != null) {
                lhs.printRecursive(stringBuilder, indent + 1);
            }
            for (int i = 0; i < indent; i++) {
                stringBuilder.append("  ");
            }
            stringBuilder.append(operator).append("\n");
            if (rhs != null) {
                rhs.printRecursive(stringBuilder, indent + 1);
            }
        }
    }

}
