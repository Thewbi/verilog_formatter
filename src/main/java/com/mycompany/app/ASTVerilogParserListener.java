package com.mycompany.app;

import java.util.Stack;

import org.antlr.v4.runtime.tree.ParseTree;

import lel.VerilogParser;
import lel.VerilogParserBaseListener;

public class ASTVerilogParserListener extends VerilogParserBaseListener {

    public ASTNode currentNode;

    public Stack<ExpressionStatementASTNode> expressionStack = new Stack<>();

    @Override
    public void enterModule_declaration(VerilogParser.Module_declarationContext ctx) {
        ModuleDeclaractionASTNode moduleDeclaractionASTNode = new ModuleDeclaractionASTNode();
        moduleDeclaractionASTNode.value = "module_decl";
        moduleDeclaractionASTNode.name = ctx.getChild(1).getText();
        currentNode = moduleDeclaractionASTNode;
    }

    @Override
    public void enterIf_generate_construct(VerilogParser.If_generate_constructContext ctx) {
        IfStatementASTNode astNode = new IfStatementASTNode();
        currentNode.children.add(astNode);
        astNode.parent = currentNode;
        currentNode = astNode;
    }

    @Override
    public void enterConditional_statement(VerilogParser.Conditional_statementContext ctx) {
        IfStatementASTNode astNode = new IfStatementASTNode();
        currentNode.children.add(astNode);
        astNode.parent = currentNode;
        currentNode = astNode;
    }

    @Override
    public void exitIf_generate_construct(VerilogParser.If_generate_constructContext ctx) {
        getAstNode();
    }

    @Override
    public void exitConditional_statement(VerilogParser.Conditional_statementContext ctx) {
        getAstNode();
    }

    private void getAstNode() {
        currentNode.value = "if_statement";
        ((IfStatementASTNode) currentNode).expression = expressionStack.pop();
        currentNode = currentNode.parent;
    }

    @Override
    public void exitNet_assignment(VerilogParser.Net_assignmentContext ctx) {
        ParseTree child0 = ctx.getChild(0);
        NetAssignmentASTNode astNode = new NetAssignmentASTNode();
        astNode.target = child0.getText();
        astNode.value = "net_assignment_statement (=)";
        astNode.expression = expressionStack.pop();
        currentNode.children.add(astNode);
    }

    @Override
    public void exitNonblocking_assignment(VerilogParser.Nonblocking_assignmentContext ctx) {
        ParseTree child0 = ctx.getChild(0);
        NonblockingAssignmentASTNode astNode = new NonblockingAssignmentASTNode();
        astNode.target = child0.getText();
        astNode.value = "nonblocking_assignment_statement (<=)";
        astNode.expression = expressionStack.pop();
        currentNode.children.add(astNode);
    }

    @Override
    public void exitConstant_expression(VerilogParser.Constant_expressionContext ctx) {
        int childCount = ctx.getChildCount();
        String text = ctx.getText();
        ParseTree child0 = ctx.getChild(0);
        ParseTree child1 = ctx.getChild(1);
        processExpression(childCount, text, child0, child1);
    }

    @Override
    public void exitExpression(VerilogParser.ExpressionContext ctx) {
        int childCount = ctx.getChildCount();
        String text = ctx.getText();
        ParseTree child0 = ctx.getChild(0);
        ParseTree child1 = ctx.getChild(1);
        processExpression(childCount, text, child0, child1);
    }

    private void processExpression(int childCount, String text, ParseTree child0, ParseTree child1) {

        ExpressionStatementASTNode astNode = new ExpressionStatementASTNode();

        if (childCount == 1) {

            astNode.value = text;
            astNode.operator = null;

        } else if (childCount == 2) {

            astNode.operator = child0.getText();

            ExpressionStatementASTNode operand = new ExpressionStatementASTNode();
            operand.value = child1.getText();
            astNode.rhs = operand;

        } else if (childCount == 3) {

            astNode.operator = child1.getText();
            astNode.rhs = expressionStack.pop();
            astNode.lhs = expressionStack.pop();

        }

        expressionStack.push(astNode);
    }

}
