package com.mycompany.app.ast;

public class ModuleParameterASTNode extends ASTNode {

    public ExpressionStatementASTNode expression;

    public ParameterAssignmentASTNode assignment;

    public void printRecursive(final StringBuilder stringBuilder, final int indent) {

        // indent and direction, type, name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        // name
        stringBuilder.append(" ").append(value).append("\n");

        if (expression != null) {
            expression.printRecursive(stringBuilder, indent+1);
        }

        if (assignment != null)
        {
            assignment.printRecursive(stringBuilder, indent+1);
        }

        // // datatype
        // if (dataType != null) {
        //     dataType.printRecursive(stringBuilder, indent);
        // }
    }

}
