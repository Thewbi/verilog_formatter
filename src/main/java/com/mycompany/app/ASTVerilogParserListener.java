package com.mycompany.app;

import java.util.Stack;

import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.TerminalNode;

import lel.VerilogParser;
import lel.VerilogParserBaseListener;

public class ASTVerilogParserListener extends VerilogParserBaseListener {

    public ASTNode currentNode;

    public Stack<ExpressionStatementASTNode> expressionStack = new Stack<>();

    @Override
    public void enterModule_declaration(VerilogParser.Module_declarationContext ctx) {
        ModuleDeclaractionASTNode moduleDeclaractionASTNode = new ModuleDeclaractionASTNode();
        moduleDeclaractionASTNode.ctx = ctx;
        moduleDeclaractionASTNode.value = "module_decl";
        moduleDeclaractionASTNode.name = ctx.getChild(1).getText();
        currentNode = moduleDeclaractionASTNode;
    }

    @Override
    public void enterIf_generate_construct(VerilogParser.If_generate_constructContext ctx) {
        if (currentNode instanceof ConditionalStatementASTNode) {

        } else {
            ConditionalStatementASTNode astNode = new ConditionalStatementASTNode();
            astNode.ctx = ctx;
            astNode.value = "conditional_stmt";

            // connect parent and child
            currentNode.children.add(astNode);
            astNode.parent = currentNode;

            // decend
            currentNode = astNode;
        }
    }

    @Override
    public void exitIf_generate_construct(VerilogParser.If_generate_constructContext ctx) {
        // exit if statement
        if (currentNode instanceof IfStatementASTNode) {
            ((IfStatementASTNode) currentNode).expression = expressionStack.pop();
            currentNode = currentNode.parent;
        }
        if (ctx.hashCode() == currentNode.ctx.hashCode()) {
            currentNode = currentNode.parent;
        }
    }

    @Override
    public void enterConditional_statement(VerilogParser.Conditional_statementContext ctx) {
        if (currentNode instanceof ConditionalStatementASTNode) {

        } else {
            ConditionalStatementASTNode astNode = new ConditionalStatementASTNode();
            astNode.value = "conditional_stmt";
            astNode.ctx = ctx;

            // connect parent and child
            currentNode.children.add(astNode);
            astNode.parent = currentNode;

            // decend
            currentNode = astNode;
        }
    }

    @Override
    public void exitConditional_statement(VerilogParser.Conditional_statementContext ctx) {
        // exit if statement
        if (currentNode instanceof IfStatementASTNode) {
            ((IfStatementASTNode) currentNode).expression = expressionStack.pop();
            currentNode = currentNode.parent;
        }
        if (ctx.hashCode() == currentNode.ctx.hashCode()) {
            currentNode = currentNode.parent;
        }
    }

    /**
     * because if-statements have no explicit non-terminal, they are exited via
     * the seq_block non-terminal
     */
    @Override
    public void exitSeq_block(VerilogParser.Seq_blockContext ctx) {
        // exit if statement
        if (currentNode instanceof IfStatementASTNode) {
            ((IfStatementASTNode) currentNode).expression = expressionStack.pop();
            currentNode = currentNode.parent;
        }
    }

    @Override
    public void exitNet_assignment(VerilogParser.Net_assignmentContext ctx) {
        // ParseTree child0 = ctx.getChild(0);
        NetAssignmentASTNode astNode = new NetAssignmentASTNode();
        astNode.ctx = ctx;

        astNode.expression = expressionStack.pop();

        //astNode.target = child0.getText();
        astNode.target = expressionStack.pop();

        astNode.value = "net_assignment_statement (=)";

        currentNode.children.add(astNode);
    }

    @Override
    public void exitNonblocking_assignment(VerilogParser.Nonblocking_assignmentContext ctx) {
        // ParseTree child0 = ctx.getChild(0);
        NonblockingAssignmentASTNode astNode = new NonblockingAssignmentASTNode();
        astNode.ctx = ctx;

        astNode.expression = expressionStack.pop();

        //astNode.target = child0.getText();
        astNode.target = expressionStack.pop();

        astNode.value = "nonblocking_assignment_statement (<=)";

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

    @Override
    public void exitEvent_expression(VerilogParser.Event_expressionContext ctx) {
        int childCount = ctx.getChildCount();
        String text = ctx.getText();
        ParseTree child0 = ctx.getChild(0);
        ParseTree child1 = ctx.getChild(1);
        processExpression(childCount, text, child0, child1);
    }

    // @Override
    // public void exitConstant_primary(VerilogParser.Constant_primaryContext ctx) {

    //     ExpressionStatementASTNode astNode = new ExpressionStatementASTNode();
    //     astNode.ctx = ctx;
    //     astNode.value = ctx.getText();
    //     astNode.operator = null;

    //     expressionStack.push(astNode);
    // }

    // @Override
    // public void exitPrimary(VerilogParser.PrimaryContext ctx) {

    //     ExpressionStatementASTNode astNode = new ExpressionStatementASTNode();
    //     astNode.ctx = ctx;
    //     astNode.value = ctx.getText();
    //     astNode.operator = null;

    //     expressionStack.push(astNode);
    // }

    @Override
    public
    void exitHierarchical_identifier(VerilogParser.Hierarchical_identifierContext ctx) {

        ExpressionStatementASTNode astNode = new ExpressionStatementASTNode();
        astNode.ctx = ctx;
        astNode.value = ctx.getText();
        astNode.operator = null;

        expressionStack.push(astNode);
    }

    @Override
    public void exitNumber(VerilogParser.NumberContext ctx) {

        ExpressionStatementASTNode astNode = new ExpressionStatementASTNode();
        astNode.ctx = ctx;
        astNode.value = ctx.getText();
        astNode.operator = null;

        expressionStack.push(astNode);
     }

    private void processExpression(int childCount, String text, ParseTree child0, ParseTree child1) {

        ExpressionStatementASTNode astNode = new ExpressionStatementASTNode();

        if (childCount == 2) {

            //
            // child 0
            //
            astNode.operator = child0.getText();

            //
            // child 1
            //
            astNode.rhs = expressionStack.pop();

            expressionStack.push(astNode);

        } else if (childCount == 3) {

            astNode.operator = child1.getText();
            astNode.rhs = expressionStack.pop();
            astNode.lhs = expressionStack.pop();

            expressionStack.push(astNode);

        }
    }

    /**
     * for @always
     */
    @Override
    public void enterProcedural_timing_control_statement(VerilogParser.Procedural_timing_control_statementContext ctx) {
        AlwaysConstructASTNode astNode = new AlwaysConstructASTNode();
        astNode.ctx = ctx;
        astNode.value = "Procedural_timing_control_statement - always";
        currentNode.children.add(astNode);
        astNode.parent = currentNode;
        currentNode = astNode;
    }

    @Override
    public void exitProcedural_timing_control_statement(VerilogParser.Procedural_timing_control_statementContext ctx) {
        ((AlwaysConstructASTNode) currentNode).expression = expressionStack.pop();
        currentNode = currentNode.parent;
    }

    @Override
    public void visitTerminal(TerminalNode node) {

        // because if-statements have no explicit node, they are detected via the terminal
        if (node.getText().equalsIgnoreCase("if")) {

            IfStatementASTNode astNode = new IfStatementASTNode();
            astNode.value = "if_stmt";

            // connect parent and child
            currentNode.children.add(astNode);
            astNode.parent = currentNode;

            // new current node
            currentNode = astNode;

        }

    }
}
