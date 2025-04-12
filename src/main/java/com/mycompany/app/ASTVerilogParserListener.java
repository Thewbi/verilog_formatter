package com.mycompany.app;

import java.util.Stack;

import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.TerminalNode;

import com.mycompany.app.ast.ASTNode;
import com.mycompany.app.ast.CaseStatementASTNode;
import com.mycompany.app.ast.CaseStatementItemASTNode;
import com.mycompany.app.ast.ConcatenationExpressionStatementASTNode;
import com.mycompany.app.ast.ConditionalStatementASTNode;
import com.mycompany.app.ast.ExpressionStatementASTNode;
import com.mycompany.app.ast.IfStatementASTNode;
import com.mycompany.app.ast.ModuleDeclaractionASTNode;
import com.mycompany.app.ast.ModuleParameterASTNode;
import com.mycompany.app.ast.NetAssignmentASTNode;
import com.mycompany.app.ast.PortASTNode;
import com.mycompany.app.ast.AssignmentASTNode;
import com.mycompany.app.ast.ProceduralTimingControlStatementASTNode;
import com.mycompany.app.ast.RangeExpressionASTNode;
import com.mycompany.app.ast.RegisterExpressionASTNode;
import com.mycompany.app.ast.SystemFunctionCallASTNode;

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
    public void enterPort_implicit(VerilogParser.Port_implicitContext ctx) {
        PortASTNode portASTNode = new PortASTNode();
        portASTNode.ctx = ctx;

        // connect parent and child
        portASTNode.parent = currentNode;
        ((ModuleDeclaractionASTNode) currentNode).ports.add(portASTNode);

        // descend
        currentNode = portASTNode;
    }

    @Override
    public void exitPort_implicit(VerilogParser.Port_implicitContext ctx) {

        currentNode.value = ctx.getText();

        // ascend
        currentNode = currentNode.parent;
    }

    @Override
    public void enterParameter_declaration(VerilogParser.Parameter_declarationContext ctx) {

        ModuleParameterASTNode moduleParameterASTNode = new ModuleParameterASTNode();
        moduleParameterASTNode.ctx = ctx;

        // connect parent and child
        moduleParameterASTNode.parent = currentNode;
        ((ModuleDeclaractionASTNode) currentNode).parameters.add(moduleParameterASTNode);

        // descend
        currentNode = moduleParameterASTNode;
    }

    @Override
    public void exitParameter_declaration(VerilogParser.Parameter_declarationContext ctx) {
        // currentNode.value = ctx.getText();
        ((ModuleParameterASTNode) currentNode).expression = expressionStack.pop();

        // ascend
        currentNode = currentNode.parent;
    }

    @Override
    public void enterParameter_identifier(VerilogParser.Parameter_identifierContext ctx) {
    }

    @Override
    public void exitParameter_identifier(VerilogParser.Parameter_identifierContext ctx) {
        ((ModuleParameterASTNode) currentNode).value = ctx.getText();
    }

    @Override
    public void enterCase_statement(VerilogParser.Case_statementContext ctx) {

        CaseStatementASTNode astNode = new CaseStatementASTNode();
        astNode.value = "case_stmt";

        // connect parent and child
        currentNode.children.add(astNode);
        astNode.parent = currentNode;

        // descend
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

        // descend
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

            // descend
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

        // descend
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
    public void exitExpression(VerilogParser.ExpressionContext ctx) {

        int childCount = ctx.getChildCount();
        String text = ctx.getText();
        ParseTree child0 = ctx.getChild(0);
        ParseTree child1 = ctx.getChild(1);

        processExpression(ctx, childCount, text, child0, child1);
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

    @Override
    public void enterRange_expression(VerilogParser.Range_expressionContext ctx) {
    }

    @Override
    public void exitRange_expression(VerilogParser.Range_expressionContext ctx) {

        RangeExpressionASTNode rangeExpressionASTNode = new RangeExpressionASTNode();

        if (ctx.children.size() == 1) {

            rangeExpressionASTNode.size = 1;
            rangeExpressionASTNode.right = expressionStack.pop();

        } else if (ctx.children.size() == 3) {

            rangeExpressionASTNode.size = 2;
            rangeExpressionASTNode.right = expressionStack.pop();
            rangeExpressionASTNode.left = expressionStack.pop();

        }

        expressionStack.push(rangeExpressionASTNode);
    }

    @Override
    public void enterPrimary(VerilogParser.PrimaryContext ctx) {
    }

    @Override
    public void exitPrimary(VerilogParser.PrimaryContext ctx) {

        if (ctx.getChildCount() == 2) {

            ExpressionStatementASTNode temp = expressionStack.pop();
            if (temp instanceof RangeExpressionASTNode) {

                // range expression
                RangeExpressionASTNode rangeExpressionASTNode = (RangeExpressionASTNode) temp;

                // register name
                temp = expressionStack.pop();

                RegisterExpressionASTNode registerExpressionASTNode = new RegisterExpressionASTNode();

                registerExpressionASTNode.var = temp;
                registerExpressionASTNode.range = rangeExpressionASTNode;

                expressionStack.push(registerExpressionASTNode);
            }
        }
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
     * example
     * ```
     * y_d = { 31'b0, (a < b) };
     * ```
     */
    @Override
    public void enterConcatenation(VerilogParser.ConcatenationContext ctx) {

        // add concatenation marker
        ExpressionStatementASTNode concatenationMarker = new ExpressionStatementASTNode();
        concatenationMarker.value = "CONCATENATION_MARKER";
        expressionStack.push(concatenationMarker);

    }

    @Override
    public void exitConcatenation(VerilogParser.ConcatenationContext ctx) {

        ConcatenationExpressionStatementASTNode concatenationExpressionStatementASTNode = new ConcatenationExpressionStatementASTNode();

        do {

            ExpressionStatementASTNode expressionStatementASTNode = expressionStack.pop();
            if ((expressionStatementASTNode.value != null)
                    && (expressionStatementASTNode.value.equalsIgnoreCase("CONCATENATION_MARKER"))) {
                break;
            }

            connectParentAndChildFront(concatenationExpressionStatementASTNode, expressionStatementASTNode);

        } while (true);

        expressionStack.push(concatenationExpressionStatementASTNode);
    }

    @Override
    public void enterSystem_function_call(VerilogParser.System_function_callContext ctx) {

        // SystemFunctionCallASTNode systemFunctionCallASTNode = new SystemFunctionCallASTNode();

        // // connect parent and child
        // currentNode.children.add(systemFunctionCallASTNode);
        // systemFunctionCallASTNode.parent = currentNode;

        // // descend
        // currentNode = systemFunctionCallASTNode;

        // add concatenation marker
        ExpressionStatementASTNode systemFunctionMarker = new ExpressionStatementASTNode();
        systemFunctionMarker.value = "SYSTEM_FUNCTION_MARKER";
        expressionStack.push(systemFunctionMarker);
    }

    /**
     * Example:
     *
     * ```
     * $signed(a)
     * ```
     */
    @Override
    public void exitSystem_function_call(VerilogParser.System_function_callContext ctx) {

        // // ascend
        // currentNode = currentNode.parent;

        SystemFunctionCallASTNode systemFunctionCallASTNode = new SystemFunctionCallASTNode();
        systemFunctionCallASTNode.value = ctx.getChild(0).getText();


        do {

            ExpressionStatementASTNode expressionStatementASTNode = expressionStack.pop();
            if ((expressionStatementASTNode.value != null)
                    && (expressionStatementASTNode.value.equalsIgnoreCase("SYSTEM_FUNCTION_MARKER"))) {
                break;
            }

            connectParentAndChildFront(systemFunctionCallASTNode, expressionStatementASTNode);

        } while (true);


        expressionStack.push(systemFunctionCallASTNode);
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
    public void enterEvent_control(VerilogParser.Event_controlContext ctx) {
    }

    /**
     * example:
     *
     * ```
     * always @* begin <----- parsing this asterisk expression
     * y_d = 0;
     * end
     * ```
     */
    @Override
    public void exitEvent_control(VerilogParser.Event_controlContext ctx) {

        if ((ctx.children.size() == 2) &&
                (ctx.getChild(0).getText().equalsIgnoreCase("@")) &&
                (ctx.getChild(1).getText().equalsIgnoreCase("*"))) {

            // although the parse tree does not have an expression node here,
            // an artificial expression node is added to make
            // exitProcedural_timing_control_statement()
            // work without speific edge cases for the timing @* combination
            ExpressionStatementASTNode expressionStatementASTNode = new ExpressionStatementASTNode();
            expressionStatementASTNode.value = "*";
            expressionStatementASTNode.operator = "*";

            expressionStack.push(expressionStatementASTNode);
        }
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

    private void connectParentAndChild(ASTNode parent, ASTNode child) {

        if (parent == child) {
            throw new RuntimeException("Child is the same object as parent!");
        }
        parent.children.add(child);
        child.parent = parent;
    }

    private void connectParentAndChildFront(ASTNode parent, ASTNode child) {

        if (parent == child) {
            throw new RuntimeException("Child is the same object as parent!");
        }
        parent.children.add(0, child);
        child.parent = parent;
    }
}
