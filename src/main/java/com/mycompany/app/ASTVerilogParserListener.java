package com.mycompany.app;

import java.util.Stack;

import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.TerminalNode;

import com.mycompany.app.ast.ASTNode;
import com.mycompany.app.ast.CaseStatementASTNode;
import com.mycompany.app.ast.CaseStatementItemASTNode;
import com.mycompany.app.ast.ConditionalStatementASTNode;
import com.mycompany.app.ast.ExpressionStatementASTNode;
import com.mycompany.app.ast.IfStatementASTNode;
import com.mycompany.app.ast.ModuleDeclaractionASTNode;
import com.mycompany.app.ast.NetAssignmentASTNode;
import com.mycompany.app.ast.AssignmentASTNode;
import com.mycompany.app.ast.ProceduralTimingControlStatementASTNode;

import verilog.VerilogParser;
import verilog.VerilogParserBaseListener;

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
    public void enterCase_statement(VerilogParser.Case_statementContext ctx) {

        CaseStatementASTNode astNode = new CaseStatementASTNode();
        astNode.value = "case_stmt";

        // connect parent and child
        currentNode.children.add(astNode);
        astNode.parent = currentNode;

        // decend
        currentNode = astNode;
    }

    @Override
    public void exitCase_statement(VerilogParser.Case_statementContext ctx) {

        ((CaseStatementASTNode) currentNode).expression = expressionStack.pop();

        // ascend
        currentNode = currentNode.parent;
    }

    @Override
    public void enterCase_item(VerilogParser.Case_itemContext ctx) {
        CaseStatementItemASTNode astNode = new CaseStatementItemASTNode();
        astNode.value = "case_item";

        // connect parent and child
        currentNode.children.add(astNode);
        astNode.parent = currentNode;

        // decend
        currentNode = astNode;
    }

    @Override
    public void exitCase_item(VerilogParser.Case_itemContext ctx) {

        if (currentNode.value.equalsIgnoreCase("default_case_item")) {
            // nop
        } else {
            ((CaseStatementItemASTNode) currentNode).expression = expressionStack.pop();
        }

        // ascend
        currentNode = currentNode.parent;
    }

    @Override
    public void enterIf_generate_construct(VerilogParser.If_generate_constructContext ctx) {
        if (currentNode instanceof ConditionalStatementASTNode) {
            // nop
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
            // nop
        } else {
            descendIntoConditionalStatementASTNode(ctx);
        }
    }

    private void descendIntoConditionalStatementASTNode(ParserRuleContext ctx) {

        ConditionalStatementASTNode astNode = new ConditionalStatementASTNode();
        astNode.value = "conditional_stmt";
        astNode.ctx = ctx;

        // connect parent and child
        currentNode.children.add(astNode);
        astNode.parent = currentNode;

        // decend
        currentNode = astNode;
    }

    @Override
    public void exitConditional_statement(VerilogParser.Conditional_statementContext ctx) {
        ascendFromConditionalStatementASTNode(ctx);
    }

    private void ascendFromConditionalStatementASTNode(ParserRuleContext ctx) {
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
        NetAssignmentASTNode astNode = new NetAssignmentASTNode();
        astNode.ctx = ctx;

        astNode.expression = expressionStack.pop();
        astNode.target = expressionStack.pop();
        astNode.value = "net_assignment_statement (=)";

        currentNode.children.add(astNode);
    }

    @Override
    public void exitNonblocking_assignment(VerilogParser.Nonblocking_assignmentContext ctx) {

        AssignmentASTNode astNode = new AssignmentASTNode();
        astNode.ctx = ctx;
        astNode.expression = expressionStack.pop();
        astNode.target = expressionStack.pop();
        astNode.value = "nonblocking_assignment_statement (<=)";
        astNode.blocking = false;

        currentNode.children.add(astNode);
    }

    @Override
    public void exitBlocking_assignment(VerilogParser.Blocking_assignmentContext ctx) {

        AssignmentASTNode astNode = new AssignmentASTNode();
        astNode.ctx = ctx;
        astNode.expression = expressionStack.pop();
        astNode.target = expressionStack.pop();
        astNode.value = "blocking_assignment_statement (=)";
        astNode.blocking = true;

        currentNode.children.add(astNode);
    }

    @Override
    public void exitConstant_expression(VerilogParser.Constant_expressionContext ctx) {
        int childCount = ctx.getChildCount();
        String text = ctx.getText();
        ParseTree child0 = ctx.getChild(0);
        ParseTree child1 = ctx.getChild(1);
        processExpression(ctx, childCount, text, child0, child1);
    }

    @Override
    public void enterExpression(VerilogParser.ExpressionContext ctx) {

        if (ctx.getChildCount() > 2) {

            // try to turn an elvis operator (?:) into an if-statment
            ParseTree operatorChildParseTree = ctx.getChild(1);
            if (operatorChildParseTree.getText().equalsIgnoreCase("?")) {

                System.out.println("Elvis has entered the building!");

                // descendIntoConditionalStatementASTNode(ctx);
            }

        }

    }

    @Override
    public void exitExpression(VerilogParser.ExpressionContext ctx) {
        int childCount = ctx.getChildCount();
        String text = ctx.getText();
        ParseTree child0 = ctx.getChild(0);
        ParseTree child1 = ctx.getChild(1);
        processExpression(ctx, childCount, text, child0, child1);

        // ascendFromConditionalStatementASTNode(ctx);
    }

    @Override
    public void exitEvent_expression(VerilogParser.Event_expressionContext ctx) {

        int childCount = ctx.getChildCount();
        String text = ctx.getText();
        ParseTree child0 = ctx.getChild(0);
        ParseTree child1 = ctx.getChild(1);

        processExpression(ctx, childCount, text, child0, child1);
    }

    @Override
    public void exitHierarchical_identifier(VerilogParser.Hierarchical_identifierContext ctx) {

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

    private void processExpression(ParseTree ctx, int childCount, String text, ParseTree child0, ParseTree child1) {

        ExpressionStatementASTNode expressionStatementASTNode = new ExpressionStatementASTNode();

        if (childCount == 1) {

            // nop
            //
            // single nodes are not precessed. The visitor sent on it's way
            // traveling to the leaves.
            // Once it arrives at a leave, a specific handler function will have
            // to take care of that leave.

        } else if (childCount == 2) {

            //
            // child 0
            //
            expressionStatementASTNode.operator = child0.getText();

            //
            // child 1
            //
            expressionStatementASTNode.rhs = expressionStack.pop();

            expressionStack.push(expressionStatementASTNode);

        } else if (childCount == 3) {

            expressionStatementASTNode.operator = child1.getText();
            expressionStatementASTNode.rhs = expressionStack.pop();
            expressionStatementASTNode.lhs = expressionStack.pop();

            expressionStack.push(expressionStatementASTNode);

        } else if (childCount == 5) {

            ParseTree operatorChildParseTree = ctx.getChild(1);
            if (operatorChildParseTree.getText().equalsIgnoreCase("?")) {

                expressionStatementASTNode.operator = child1.getText();
                expressionStatementASTNode.rhs = expressionStack.pop();
                expressionStatementASTNode.lhs = expressionStack.pop();
                expressionStatementASTNode.predicate = expressionStack.pop();

                expressionStack.push(expressionStatementASTNode);

            } else {
                throw new RuntimeException("Not implemented yet!");
            }

        }
    }

    /**
     * for @always
     */
    @Override
    public void enterProcedural_timing_control_statement(VerilogParser.Procedural_timing_control_statementContext ctx) {

        ProceduralTimingControlStatementASTNode astNode = new ProceduralTimingControlStatementASTNode();
        astNode.ctx = ctx;
        astNode.value = "procedural_timing_control_statement";
        currentNode.children.add(astNode);
        astNode.parent = currentNode;
        currentNode = astNode;
    }

    @Override
    public void exitProcedural_timing_control_statement(VerilogParser.Procedural_timing_control_statementContext ctx) {

        ((ProceduralTimingControlStatementASTNode) currentNode).expression = expressionStack.pop();
        currentNode = currentNode.parent;
    }

    @Override
    public void visitTerminal(TerminalNode node) {

        // because if-statements have no explicit node, they are detected via the
        // terminal
        if (node.getText().equalsIgnoreCase("if")) {

            IfStatementASTNode astNode = new IfStatementASTNode();
            astNode.value = "if_stmt";

            // connect parent and child
            currentNode.children.add(astNode);
            astNode.parent = currentNode;

            // new current node
            currentNode = astNode;

        } else if (node.getText().equalsIgnoreCase("default")) {

            ((CaseStatementItemASTNode) currentNode).value = "default_case_item";

        }

    }
}
