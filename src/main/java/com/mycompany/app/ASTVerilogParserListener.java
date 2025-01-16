package com.mycompany.app;

import java.util.ArrayList;
import java.util.List;
import java.util.Stack;

import lel.VerilogParser;
import lel.VerilogParserBaseListener;

public class ASTVerilogParserListener extends VerilogParserBaseListener {

    public ASTNode currentNode;

    //public List<ExpressionStatementASTNode> expressionList = new ArrayList<>();
    public Stack<ExpressionStatementASTNode> expressionStack = new Stack<>();

    @Override
    public void enterModule_declaration(VerilogParser.Module_declarationContext ctx) {

        ModuleDeclaractionASTNode moduleDeclaractionASTNode = new ModuleDeclaractionASTNode();
        moduleDeclaractionASTNode.value = "module_decl";
        moduleDeclaractionASTNode.name = ctx.getChild(1).getText();

        currentNode = moduleDeclaractionASTNode;
    }

    // @Override
    // public void enterModule_identifier(VerilogParser.Module_identifierContext ctx) {

    //     ASTNode astNode = new ASTNode();
    //     astNode.value = ctx.getText();

    //     currentNode.children.add(astNode);
    // }

    @Override
    public void exitIf_generate_construct(VerilogParser.If_generate_constructContext ctx) {

        IfStatementASTNode astNode = new IfStatementASTNode();
        astNode.value = "if_statement";

        astNode.expression = expressionStack.pop();
        expressionStack.clear();

        currentNode.children.add(astNode);
    }

    @Override public void exitConstant_expression(VerilogParser.Constant_expressionContext ctx) {

        ExpressionStatementASTNode astNode = new ExpressionStatementASTNode();

        if (ctx.getChildCount() == 1) {

            astNode.value = ctx.getText();
            astNode.operator = null;

            //expressionList.add(astNode);

        } else if (ctx.getChildCount() == 2) {

            astNode.operator = ctx.getChild(0).getText();

            ExpressionStatementASTNode operand = new ExpressionStatementASTNode();
            operand.value = ctx.getChild(1).getText();
            astNode.rhs = operand;

            // expressionStack.clear();

        } else if (ctx.getChildCount() == 3) {

            astNode.operator = ctx.getChild(1).getText();
            astNode.rhs = expressionStack.pop();
            astNode.lhs = expressionStack.pop();

            // expressionList.clear();

        }

        expressionStack.push(astNode);

     }

}
