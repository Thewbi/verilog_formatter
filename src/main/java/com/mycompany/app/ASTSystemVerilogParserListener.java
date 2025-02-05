package com.mycompany.app;

import java.util.Stack;

import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.TerminalNode;

import systemverilog.sv2017Parser;
import systemverilog.sv2017ParserBaseListener;

public class ASTSystemVerilogParserListener extends sv2017ParserBaseListener {

    public ASTNode currentNode;

    public Stack<ExpressionStatementASTNode> expressionStack = new Stack<>();

    @Override
    public void enterModule_declaration(sv2017Parser.Module_declarationContext ctx) {

        ModuleDeclaractionASTNode moduleDeclaractionASTNode = new ModuleDeclaractionASTNode();
        moduleDeclaractionASTNode.ctx = ctx;
        moduleDeclaractionASTNode.value = "module_decl";
        moduleDeclaractionASTNode.name = ctx.getChild(0).getChild(1).getText();

        // decend
        currentNode = moduleDeclaractionASTNode;
    }

    @Override
    public void enterCase_statement(sv2017Parser.Case_statementContext ctx) {

        CaseStatementASTNode astNode = new CaseStatementASTNode();
        astNode.value = "case_stmt";

        // connect parent and child
        currentNode.children.add(astNode);
        astNode.parent = currentNode;

        // decend
        currentNode = astNode;
    }

    @Override
    public void exitCase_statement(sv2017Parser.Case_statementContext ctx) {

        ((CaseStatementASTNode) currentNode).expression = expressionStack.pop();

        // ascend
        currentNode = currentNode.parent;
    }

    @Override
    public void enterCase_item(sv2017Parser.Case_itemContext ctx) {

        CaseStatementItemASTNode astNode = new CaseStatementItemASTNode();
        astNode.value = "case_item";

        // connect parent and child
        currentNode.children.add(astNode);
        astNode.parent = currentNode;

        // decend
        currentNode = astNode;
    }

    @Override
    public void exitCase_item(sv2017Parser.Case_itemContext ctx) {

        if (currentNode.value.equalsIgnoreCase("default_case_item")) {
            // nop
        } else {
            ((CaseStatementItemASTNode) currentNode).expression = expressionStack.pop();
        }

        // ascend
        currentNode = currentNode.parent;
    }

    @Override
    public void enterIf_generate_construct(sv2017Parser.If_generate_constructContext ctx) {

        if (currentNode instanceof ConditionalStatementASTNode) {
            // nop
        } else {
            ConditionalStatementASTNode astNode = new ConditionalStatementASTNode();
            astNode.ctx = ctx;
            astNode.value = "conditional_stmt";

            // connect parent and child
            currentNode.children.add(astNode);
            astNode.parent = currentNode;

            // descend
            currentNode = astNode;
        }
    }

    @Override
    public void exitIf_generate_construct(sv2017Parser.If_generate_constructContext ctx) {

        // exit if statement
        if (currentNode instanceof IfStatementASTNode) {
            ((IfStatementASTNode) currentNode).expression = expressionStack.pop();
            // ascend
            currentNode = currentNode.parent;
        }
        if (ctx.hashCode() == currentNode.ctx.hashCode()) {
            // ascend
            currentNode = currentNode.parent;
        }
    }

    @Override
    public void enterConditional_statement(sv2017Parser.Conditional_statementContext ctx) {

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

        // descend
        currentNode = astNode;
    }

    @Override
    public void exitConditional_statement(sv2017Parser.Conditional_statementContext ctx) {
        ascendFromConditionalStatementASTNode(ctx);
    }

    private void ascendFromConditionalStatementASTNode(ParserRuleContext ctx) {

        // exit if statement
        if (currentNode instanceof IfStatementASTNode) {

            ((IfStatementASTNode) currentNode).expression = expressionStack.pop();

            // ascend
            currentNode = currentNode.parent;
        }
        if (ctx.hashCode() == currentNode.ctx.hashCode()) {

            // ascend
            currentNode = currentNode.parent;
        }
    }

    /**
     * because if-statements have no explicit non-terminal, they are exited via
     * the seq_block non-terminal
     */
    @Override
    public void exitSeq_block(sv2017Parser.Seq_blockContext ctx) {

        // exit if statement
        if (currentNode instanceof IfStatementASTNode) {

            ((IfStatementASTNode) currentNode).expression = expressionStack.pop();

            // ascend
            currentNode = currentNode.parent;
        }
    }

    @Override
    public void exitNet_decl_assignment(sv2017Parser.Net_decl_assignmentContext ctx) {

        NetAssignmentASTNode astNode = new NetAssignmentASTNode();
        astNode.ctx = ctx;
        astNode.expression = expressionStack.pop();
        astNode.target = expressionStack.pop();
        astNode.value = "net_assignment_statement (=)";

        currentNode.children.add(astNode);
    }

    @Override
    public void exitNonblocking_assignment(sv2017Parser.Nonblocking_assignmentContext ctx) {

        NonblockingAssignmentASTNode astNode = new NonblockingAssignmentASTNode();
        astNode.ctx = ctx;
        astNode.expression = expressionStack.pop();
        astNode.target = expressionStack.pop();
        astNode.value = "nonblocking_assignment_statement (<=)";

        currentNode.children.add(astNode);
    }

    @Override
    public void exitConstant_expression(sv2017Parser.Constant_expressionContext ctx) {

        int childCount = ctx.getChildCount();
        String text = ctx.getText();
        ParseTree child0 = ctx.getChild(0);
        ParseTree child1 = ctx.getChild(1);

        processExpression(ctx, childCount, text, child0, child1);
    }

    @Override
    public void enterExpression(sv2017Parser.ExpressionContext ctx) {

        if (ctx.getChildCount() > 2) {

            // try to turn an elvis operator (?:) into an if-statment
            ParseTree operatorChildParseTree = ctx.getChild(1);
            if (operatorChildParseTree.getText().equalsIgnoreCase("?")) {

                System.out.println("Elvis has entered the building!");
            }
        }
    }

    @Override
    public void exitExpression(sv2017Parser.ExpressionContext ctx) {

        int childCount = ctx.getChildCount();
        String text = ctx.getText();
        ParseTree child0 = ctx.getChild(0);
        ParseTree child1 = ctx.getChild(1);

        processExpression(ctx, childCount, text, child0, child1);
    }

    @Override
    public void exitEvent_expression(sv2017Parser.Event_expressionContext ctx) {

        int childCount = ctx.getChildCount();
        String text = ctx.getText();
        ParseTree child0 = ctx.getChild(0);
        ParseTree child1 = ctx.getChild(1);

        processExpression(ctx, childCount, text, child0, child1);
    }

    @Override
    public void exitHierarchical_identifier(sv2017Parser.Hierarchical_identifierContext ctx) {

        ExpressionStatementASTNode astNode = new ExpressionStatementASTNode();
        astNode.ctx = ctx;
        astNode.value = ctx.getText();
        astNode.operator = null;

        if (currentNode instanceof ParameterListASTNode) {
            currentNode.children.add(astNode);
        } else {
            expressionStack.push(astNode);
        }
    }

    @Override
    public void exitNumber(sv2017Parser.NumberContext ctx) {

        ExpressionStatementASTNode astNode = new ExpressionStatementASTNode();
        astNode.ctx = ctx;
        astNode.value = ctx.getText();
        astNode.operator = null;

        if (currentNode instanceof ParameterListASTNode) {
            currentNode.children.add(astNode);
        } else {
            expressionStack.push(astNode);
        }
    }

    @Override
    public void exitPrimary_literal(sv2017Parser.Primary_literalContext ctx) {

        ExpressionStatementASTNode astNode = new ExpressionStatementASTNode();
        astNode.ctx = ctx;
        astNode.value = ctx.getText();
        astNode.operator = null;

        if (currentNode instanceof ParameterListASTNode) {
            currentNode.children.add(astNode);
        } else {
            expressionStack.push(astNode);
        }
    }

    private void processExpression(final ParseTree ctx, final int childCount, final String text, final ParseTree child0,
            final ParseTree child1) {

        ExpressionStatementASTNode expressionStatementASTNode = new ExpressionStatementASTNode();

        if (childCount == 1) {

            // nop
            //
            // single nodes are not precessed. The visitor sent on it's way
            // traveling to the leaves.
            // Once it arrives at a leave, a specific handler function will have
            // to take care of that leave.
            System.out.println("a");

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
    public void enterProcedural_timing_control_statement(sv2017Parser.Procedural_timing_control_statementContext ctx) {

        ProceduralTimingControlStatementASTNode astNode = new ProceduralTimingControlStatementASTNode();
        astNode.ctx = ctx;
        astNode.value = "Procedural_timing_control_statement - always";

        // connect parent and child
        currentNode.children.add(astNode);
        astNode.parent = currentNode;

        // descend
        currentNode = astNode;
    }

    @Override
    public void exitProcedural_timing_control_statement(sv2017Parser.Procedural_timing_control_statementContext ctx) {

        ((ProceduralTimingControlStatementASTNode) currentNode).expression = expressionStack.pop();

        // ascend
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

            // descend - new current node
            currentNode = astNode;

        } else if (node.getText().equalsIgnoreCase("default")) {

            ((CaseStatementItemASTNode) currentNode).value = "default_case_item";

        }
    }

    @Override
    public void enterInitial_construct(sv2017Parser.Initial_constructContext ctx) {

        ProceduralTimingControlStatementASTNode astNode = new ProceduralTimingControlStatementASTNode();
        astNode.ctx = ctx;
        astNode.value = "Procedural_timing_control_statement - initial";
        astNode.initial = true;

        // connect parent and child
        currentNode.children.add(astNode);
        astNode.parent = currentNode;

        // descend
        currentNode = astNode;
    }

    @Override
    public void exitInitial_construct(sv2017Parser.Initial_constructContext ctx) {
        // ((AlwaysConstructASTNode) currentNode).expression = expressionStack.pop();

        // ascend
        currentNode = currentNode.parent;
    }

    // @Override
    // //public void exitPrimary_literal(sv2017Parser.Primary_literalContext ctx) {
    // public void exitPrimary(sv2017Parser.PrimaryContext ctx) {

    // String primary = ctx.getChild(0).getText();
    // System.out.println(primary);
    // }

    @Override
    public void enterPrimaryTfCall(sv2017Parser.PrimaryTfCallContext ctx) {

        ConditionalStatementASTNode astNode = new ConditionalStatementASTNode();
        astNode.ctx = ctx;
        astNode.value = "primitive_stmt - tf call " + ctx.getChild(0).getText();

        // connect parent and child
        currentNode.children.add(astNode);
        astNode.parent = currentNode;

        // descend
        currentNode = astNode;
    }

    @Override
    public void exitPrimaryTfCall(sv2017Parser.PrimaryTfCallContext ctx) {

        // ascend
        currentNode = currentNode.parent;

        // ExpressionStatementASTNode expressionStatementASTNode =
        // expressionStack.pop();
        // System.out.println(expressionStatementASTNode);

        // // connect parent and child
        // currentNode.children.add(astNode);
        // astNode.parent = currentNode;

        // // descend
        // currentNode = astNode;
    }

    @Override
    public void enterList_of_arguments(sv2017Parser.List_of_argumentsContext ctx) {

        System.out.println("enterList_of_arguments");

        ParameterListASTNode astNode = new ParameterListASTNode();
        astNode.ctx = ctx;
        astNode.value = "parameter_list";

        // connect parent and child
        currentNode.children.add(astNode);
        astNode.parent = currentNode;

        // descend
        currentNode = astNode;
    }

    @Override
    public void exitList_of_arguments(sv2017Parser.List_of_argumentsContext ctx) {
        System.out.println("exitList_of_arguments");

        // ascend
        currentNode = currentNode.parent;
    }

    @Override
    public void enterProperty_list_of_arguments(sv2017Parser.Property_list_of_argumentsContext ctx) {
        System.out.println("enterProperty_list_of_arguments");
    }

    @Override
    public void exitProperty_list_of_arguments(sv2017Parser.Property_list_of_argumentsContext ctx) {
        System.out.println("exitProperty_list_of_arguments");
    }

    @Override
    public void enterTf_port_list(sv2017Parser.Tf_port_listContext ctx) {
        System.out.println("enterTf_port_list");
    }

    @Override
    public void exitTf_port_list(sv2017Parser.Tf_port_listContext ctx) {
        System.out.println("exitTf_port_list");
    }

    @Override
    public void enterTf_port_item(sv2017Parser.Tf_port_itemContext ctx) {
        System.out.println("enterTf_port_item");
    }

    @Override
    public void exitTf_port_item(sv2017Parser.Tf_port_itemContext ctx) {
        System.out.println("exitTf_port_item");
    }

    @Override
    public void enterTf_port_declaration(sv2017Parser.Tf_port_declarationContext ctx) {
        System.out.println("enterTf_port_declaration");
    }

    @Override
    public void exitTf_port_declaration(sv2017Parser.Tf_port_declarationContext ctx) {
        System.out.println("exitTf_port_declaration");
    }
}
