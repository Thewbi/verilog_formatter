package com.mycompany.app;

import java.util.Stack;

import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.TerminalNode;

import com.mycompany.app.ast.ASTNode;
import com.mycompany.app.ast.AlwaysConstructASTNode;
import com.mycompany.app.ast.AssignmentASTNode;
import com.mycompany.app.ast.CaseStatementASTNode;
import com.mycompany.app.ast.CaseStatementItemASTNode;
import com.mycompany.app.ast.ConditionalStatementASTNode;
import com.mycompany.app.ast.DataTypeASTNode;
import com.mycompany.app.ast.ExpressionStatementASTNode;
import com.mycompany.app.ast.IfStatementASTNode;
import com.mycompany.app.ast.ModuleDeclaractionASTNode;
import com.mycompany.app.ast.ModuleItemDeclarationASTNode;
import com.mycompany.app.ast.NetAssignmentASTNode;
import com.mycompany.app.ast.ParameterListASTNode;
import com.mycompany.app.ast.PortASTNode;
import com.mycompany.app.ast.PortDirection;
import com.mycompany.app.ast.PrimaryTfCallASTNode;
import com.mycompany.app.ast.ProceduralTimingControlStatementASTNode;
import com.mycompany.app.ast.RangeExpressionASTNode;
import com.mycompany.app.ast.TypedASTNode;
import com.mycompany.app.ast.VariableAssignmentASTNode;

import systemverilog.sv2017Parser;
import systemverilog.sv2017ParserBaseListener;

public class ASTSystemVerilogParserListener extends sv2017ParserBaseListener {

    /** When there is no explicit datatype is specified, the default datatype is used. */
    public static final String DEFAULT_DATA_TYPE = "logic";

    public ASTNode currentNode = new ASTNode("root");

    public Stack<ExpressionStatementASTNode> expressionStack = new Stack<>();

    public void pushExpression(ExpressionStatementASTNode astNode) {
        expressionStack.push(astNode);
    }

    @Override
    public void enterModule_declaration(sv2017Parser.Module_declarationContext ctx) {

        ModuleDeclaractionASTNode moduleDeclaractionASTNode = new ModuleDeclaractionASTNode();
        moduleDeclaractionASTNode.ctx = ctx;
        moduleDeclaractionASTNode.value = "module_decl";
        moduleDeclaractionASTNode.name = ctx.getChild(0).getChild(1).getText();

        // connect parent and child
        currentNode.children.add(moduleDeclaractionASTNode);
        moduleDeclaractionASTNode.parent = currentNode;

        // descend
        currentNode = moduleDeclaractionASTNode;
    }

    @Override
    public void exitModule_declaration(sv2017Parser.Module_declarationContext ctx) {

        ModuleDeclaractionASTNode moduleDeclaractionASTNode = (ModuleDeclaractionASTNode) currentNode;

        moduleDeclaractionASTNode.name = expressionStack.pop().value;

        // ascend
        currentNode = currentNode.parent;
    }

    // @Override
    // public void
    // enterList_of_port_declarations(sv2017Parser.List_of_port_declarationsContext
    // ctx) {
    // }

    // @Override
    // public void
    // exitList_of_port_declarations(sv2017Parser.List_of_port_declarationsContext
    // ctx) {
    // }

    @Override
    public void enterAnsi_port_declaration(sv2017Parser.Ansi_port_declarationContext ctx) {

        PortASTNode portASTNode = new PortASTNode();
        portASTNode.ctx = ctx;
        portASTNode.value = "port";

        // port direction
        portASTNode.portDirection = PortDirection.fromString(ctx.getChild(0).getText());

        // connect parent and child
        ((ModuleDeclaractionASTNode) currentNode).ports.add(portASTNode);
        portASTNode.parent = currentNode;

        // descend
        currentNode = portASTNode;
    }

    @Override
    public void exitAnsi_port_declaration(sv2017Parser.Ansi_port_declarationContext ctx) {

        PortASTNode portASTNode = (PortASTNode) currentNode;

        // name
        portASTNode.value = expressionStack.pop().value;

        // // type / expression
        // //
        // // if several ports are defined using comma separated list, then in the
        // // parse tree, there will be a ansi_port node for every subsequent port
        // // declaration
        // // having no explicit type / expression and no explicit direction. The
        // // type / expression and direction have to be taken from the first port in
        // the
        // // comma separated list!
        // if ((ctx.children.size() > 1) && (ctx.children.get(1) instanceof
        // sv2017Parser.Net_or_var_data_typeContext)) {
        // portASTNode.expression = expressionStack.pop();
        // }

        // ascend
        currentNode = currentNode.parent;
    }

    @Override
    public void enterData_declaration(sv2017Parser.Data_declarationContext ctx) {

        ModuleItemDeclarationASTNode moduleItemDeclarationASTNode = new ModuleItemDeclarationASTNode();
        moduleItemDeclarationASTNode.ctx = ctx;

        // connect parent and child
        currentNode.children.add(moduleItemDeclarationASTNode);
        moduleItemDeclarationASTNode.parent = currentNode;

        // descend
        currentNode = moduleItemDeclarationASTNode;
    }

    /**
     * example:
     *
     * <pre>
     * module main;
     *   logic a;
     * endmodule
     * </pre>
     *
     * <pre>
     * module testbench();
     *   logic [31:0] a;
     * endmodule
     * </pre>
     */
    @Override
    public void exitData_declaration(sv2017Parser.Data_declarationContext ctx) {

        // ModuleItemDeclarationASTNode moduleItemDeclarationASTNode = new
        // ModuleItemDeclarationASTNode();
        // moduleItemDeclarationASTNode.ctx = ctx;
        // moduleItemDeclarationASTNode.expression = expressionStack.pop();
        // moduleItemDeclarationASTNode.value = expressionStack.pop().value;

        // ModuleDeclaractionASTNode moduleDeclaractionASTNode =
        // (ModuleDeclaractionASTNode) currentNode;
        // moduleDeclaractionASTNode.children.add(moduleItemDeclarationASTNode);

        currentNode.value = expressionStack.pop().value;

        // ascend
        currentNode = currentNode.parent;
    }

    /**
     * This node appears in the parse tree, when the data type (her: logic) is
     * specified explicitly.
     *
     * <pre>
     * module adder(
     *   input logic [31:0] a
     * );
     * endmodule
     * </pre>
     */
    @Override
    public void exitData_type(sv2017Parser.Data_typeContext ctx) {

        DataTypeASTNode dataTypeASTNode = new DataTypeASTNode();

        if (ctx.children.size() == 1) {

            dataTypeASTNode.value = expressionStack.pop().value;

        } else if (ctx.children.size() == 2) {

            dataTypeASTNode.rangeExpression = expressionStack.pop();
            dataTypeASTNode.value = expressionStack.pop().value;

        } else {

            throw new RuntimeException("unknown type of children");

        }

        TypedASTNode typedASTNode = (TypedASTNode) currentNode;
        typedASTNode.dataType = dataTypeASTNode;
    }

    @Override
    public void enterImplicit_data_type(sv2017Parser.Implicit_data_typeContext ctx) {
    }

    @Override
    public void exitImplicit_data_type(sv2017Parser.Implicit_data_typeContext ctx) {

        DataTypeASTNode dataTypeASTNode = new DataTypeASTNode();

        if (ctx.children.size() == 1) {

            dataTypeASTNode.rangeExpression = expressionStack.pop();
            dataTypeASTNode.value = DEFAULT_DATA_TYPE;

        } else {

            throw new RuntimeException("unknown type of children");

        }

        TypedASTNode typedASTNode = (TypedASTNode) currentNode;
        typedASTNode.dataType = dataTypeASTNode;
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

    /**
     * A assignment located within a process so it is a sequential assignment.
     * The assignment is done using the = operator which makes it blocking.
     * This is a blocking assignment.
     *
     * Do not confuse this assignment with non-blocking sequential assignment.
     *
     * Do not confuse this assignment with an assign-keyword assignment which
     * is a standard assignment and which is used outside of processes.
     */
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

        AssignmentASTNode astNode = new AssignmentASTNode();
        astNode.ctx = ctx;
        astNode.expression = expressionStack.pop();
        astNode.target = expressionStack.pop();
        astNode.value = "nonblocking_assignment_statement (<=)";
        astNode.blocking = false;

        currentNode.children.add(astNode);
    }

    @Override
    public void exitBlocking_assignment(sv2017Parser.Blocking_assignmentContext ctx) {

        AssignmentASTNode astNode = new AssignmentASTNode();
        astNode.ctx = ctx;
        astNode.expression = expressionStack.pop();
        astNode.target = expressionStack.pop();
        astNode.value = "blocking_assignment_statement (=)";
        astNode.blocking = true;

        currentNode.children.add(astNode);
    }

    @Override
    public void enterVariable_assignment(sv2017Parser.Variable_assignmentContext ctx) {
    }

    @Override
    public void exitVariable_assignment(sv2017Parser.Variable_assignmentContext ctx) {

        VariableAssignmentASTNode variableAssignmentASTNode = new VariableAssignmentASTNode();
        variableAssignmentASTNode.value = "VariableAssignment";
        variableAssignmentASTNode.expression = expressionStack.pop();
        variableAssignmentASTNode.target = expressionStack.pop();

        currentNode.children.add(variableAssignmentASTNode);
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
            // expressionStack.push(astNode);
            pushExpression(astNode);
        }
    }

    @Override
    public void exitIdentifier(sv2017Parser.IdentifierContext ctx) {

        ExpressionStatementASTNode astNode = new ExpressionStatementASTNode();
        astNode.ctx = ctx;
        astNode.value = ctx.getText();
        astNode.operator = null;

        if (currentNode instanceof ParameterListASTNode) {
            currentNode.children.add(astNode);
        } else {
            // expressionStack.push(astNode);
            pushExpression(astNode);
        }
    }

    @Override
    public void exitInteger_type(sv2017Parser.Integer_typeContext ctx) {

        ExpressionStatementASTNode astNode = new ExpressionStatementASTNode();
        astNode.ctx = ctx;
        astNode.value = ctx.getText();
        astNode.operator = null;

        if (currentNode instanceof ParameterListASTNode) {
            currentNode.children.add(astNode);
        } else {
            pushExpression(astNode);
        }
    }

    @Override
    public void exitReal_number(sv2017Parser.Real_numberContext ctx) {

        ExpressionStatementASTNode astNode = new ExpressionStatementASTNode();
        astNode.ctx = ctx;
        astNode.value = ctx.getText();
        astNode.operator = null;

        if (currentNode instanceof ParameterListASTNode) {
            currentNode.children.add(astNode);
        } else {
            pushExpression(astNode);
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
            // expressionStack.push(astNode);
            pushExpression(astNode);
        }
    }

    @Override
    public void enterRange_expression(sv2017Parser.Range_expressionContext ctx) {
    }

    @Override
    public void exitRange_expression(sv2017Parser.Range_expressionContext ctx) {

        RangeExpressionASTNode astNode = new RangeExpressionASTNode();
        astNode.ctx = ctx;
        astNode.value = ctx.getText();
        astNode.operator = null;
        astNode.right = expressionStack.pop();
        astNode.left = expressionStack.pop();

        if (currentNode instanceof ParameterListASTNode) {
            currentNode.children.add(astNode);
        } else {
            pushExpression(astNode);
        }
    }

    @Override
    public void enterArray_range_expression(sv2017Parser.Array_range_expressionContext ctx) {
    }

    @Override
    public void exitArray_range_expression(sv2017Parser.Array_range_expressionContext ctx) {

        RangeExpressionASTNode astNode = new RangeExpressionASTNode();
        astNode.ctx = ctx;
        astNode.value = ctx.getText();
        astNode.operator = null;
        astNode.right = expressionStack.pop();
        astNode.left = expressionStack.pop();

        if (currentNode instanceof ParameterListASTNode) {
            currentNode.children.add(astNode);
        } else {
            pushExpression(astNode);
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
            // System.out.println("a");

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

    @Override
    public void enterAlways_construct(sv2017Parser.Always_constructContext ctx) {

        AlwaysConstructASTNode astNode = new AlwaysConstructASTNode();
        astNode.ctx = ctx;
        astNode.value = "always";

        // connect parent and child
        currentNode.children.add(astNode);
        astNode.parent = currentNode;

        // descend
        currentNode = astNode;
    }

    @Override
    public void exitAlways_construct(sv2017Parser.Always_constructContext ctx) {

        // ascend
        currentNode = currentNode.parent;
    }

    /**
     * for @always (example file: ???)
     */
    @Override
    public void enterProcedural_timing_control_statement(sv2017Parser.Procedural_timing_control_statementContext ctx) {

        ProceduralTimingControlStatementASTNode astNode = new ProceduralTimingControlStatementASTNode();
        astNode.ctx = ctx;
        astNode.value = "procedural_timing_control_statement";

        // connect parent and child
        currentNode.children.add(astNode);
        astNode.parent = currentNode;

        // descend
        currentNode = astNode;
    }

    @Override
    public void exitProcedural_timing_control_statement(sv2017Parser.Procedural_timing_control_statementContext ctx) {

        // if this is an always statement, then the always statement has a expression as
        // a sensitivity list
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

        // ascend
        currentNode = currentNode.parent;
    }

    @Override
    public void enterPrimaryTfCall(sv2017Parser.PrimaryTfCallContext ctx) {

        PrimaryTfCallASTNode astNode = new PrimaryTfCallASTNode();
        astNode.ctx = ctx;
        astNode.value = "primitive_stmt - tf call " + ctx.getChild(0).getText();

        String primaryTfCall = ctx.getChild(0).getText().toLowerCase();
        if (primaryTfCall.contains("$display")) {
            astNode.primaryType = PrimaryType.DISPLAY;
        } else if (primaryTfCall.contains("$finish")) {
            astNode.primaryType = PrimaryType.FINISH;
        }

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
}
