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
import com.mycompany.app.ast.DataTypeASTNode;
import com.mycompany.app.ast.ExpressionStatementASTNode;
import com.mycompany.app.ast.IfStatementASTNode;
import com.mycompany.app.ast.ModuleDeclaractionASTNode;
import com.mycompany.app.ast.ModuleInstantiationASTNode;
import com.mycompany.app.ast.ModuleInstantiationPortConnection;
import com.mycompany.app.ast.ModuleParameterASTNode;
import com.mycompany.app.ast.NetAssignmentASTNode;
import com.mycompany.app.ast.NetDeclarationASTNode;
import com.mycompany.app.ast.ParameterAssignmentASTNode;
import com.mycompany.app.ast.PortASTNode;
import com.mycompany.app.ast.PortDirection;
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

    //
    // Module Declaration
    //

    @Override
    public void enterModule_declaration(VerilogParser.Module_declarationContext ctx) {

        ModuleDeclaractionASTNode moduleDeclaractionASTNode = new ModuleDeclaractionASTNode();
        moduleDeclaractionASTNode.ctx = ctx;
        moduleDeclaractionASTNode.value = "module_decl";
        moduleDeclaractionASTNode.name = ctx.getChild(1).getText();

        currentNode = moduleDeclaractionASTNode;
    }

    /**
     * When ports of a module are declared in old verilog style without explicit
     * type definition.
     *
     * e.g.
     *
     * implicit:
     *
     * ```
     * module design_top(
     * o_rs2
     * );
     * ```
     *
     * explicit:
     *
     * ```
     * module design_top(
     * output wire[31:0] o_rs2
     * );
     * ```
     */
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
    public void enterPort_declaration(VerilogParser.Port_declarationContext ctx) {
        // System.out.println("[" + ctx.hashCode() + "] " + ctx.getText());

        PortASTNode portASTNode = new PortASTNode();
        portASTNode.ctx = ctx;

        // connect parent and child
        portASTNode.parent = currentNode;
        ((ModuleDeclaractionASTNode) currentNode).ports.add(portASTNode);

        // descend
        currentNode = portASTNode;
    }

    @Override
    public void exitPort_declaration(VerilogParser.Port_declarationContext ctx) {
        // ascend
        currentNode = currentNode.parent;
    }

    @Override
    public void enterInput_declaration(VerilogParser.Input_declarationContext ctx) {
    }

    @Override
    public void exitInput_declaration(VerilogParser.Input_declarationContext ctx) {
        // System.out.println("[" + ctx.hashCode() + "] " + ctx.getText() + " children:
        // " + ctx.children.size());

        if (ctx.children.size() == 2) {

            String listOfPortNames = ctx.getChild(1).getText();
            String[] listOfPortNamesSplit = listOfPortNames.split(",");

            PortASTNode portASTNode = (PortASTNode) currentNode;
            portASTNode.portDirection = PortDirection.INPUT;
            portASTNode.listOfPortNames = listOfPortNamesSplit;

            portASTNode.dataType = new DataTypeASTNode();
            portASTNode.dataType.value = "wire";
            portASTNode.dataType.rangeExpression = null;

        } else if (ctx.children.size() == 3) {

            String listOfPortNames = ctx.getChild(2).getText();
            String[] listOfPortNamesSplit = listOfPortNames.split(",");

            PortASTNode portASTNode = (PortASTNode) currentNode;
            portASTNode.portDirection = PortDirection.INPUT;
            portASTNode.listOfPortNames = listOfPortNamesSplit;
            portASTNode.dataType = new DataTypeASTNode();
            portASTNode.dataType.value = ctx.getChild(1).getText();
            portASTNode.dataType.rangeExpression = null;

        } else if (ctx.children.size() == 4) {

            String listOfPortNames = ctx.getChild(3).getText();
            String[] listOfPortNamesSplit = listOfPortNames.split(",");

            PortASTNode portASTNode = (PortASTNode) currentNode;
            portASTNode.portDirection = PortDirection.INPUT;
            portASTNode.listOfPortNames = listOfPortNamesSplit;
            portASTNode.dataType = new DataTypeASTNode();
            portASTNode.dataType.value = ctx.getChild(1).getText();
            portASTNode.dataType.rangeExpression = expressionStackPop();
        }
    }

    @Override
    public void enterOutput_declaration(VerilogParser.Output_declarationContext ctx) {
    }

    @Override
    public void exitOutput_declaration(VerilogParser.Output_declarationContext ctx) {
        // System.out.println("[" + ctx.hashCode() + "] " + ctx.getText() + " children:
        // " + ctx.children.size());

        if (ctx.children.size() == 2) {

            String listOfPortNames = ctx.getChild(1).getText();
            String[] listOfPortNamesSplit = listOfPortNames.split(",");

            PortASTNode portASTNode = (PortASTNode) currentNode;
            portASTNode.portDirection = PortDirection.OUTPUT;
            portASTNode.listOfPortNames = listOfPortNamesSplit;
            portASTNode.dataType = new DataTypeASTNode();
            portASTNode.dataType.value = "wire";
            portASTNode.dataType.rangeExpression = null;

        } else if (ctx.children.size() == 3) {

            String listOfPortNames = ctx.getChild(2).getText();
            String[] listOfPortNamesSplit = listOfPortNames.split(",");

            PortASTNode portASTNode = (PortASTNode) currentNode;
            portASTNode.portDirection = PortDirection.OUTPUT;
            portASTNode.listOfPortNames = listOfPortNamesSplit;
            portASTNode.dataType = new DataTypeASTNode();
            portASTNode.dataType.value = ctx.getChild(1).getText();
            portASTNode.dataType.rangeExpression = null;

        } else if (ctx.children.size() == 4) {

            String listOfPortNames = ctx.getChild(3).getText();
            String[] listOfPortNamesSplit = listOfPortNames.split(",");

            PortASTNode portASTNode = (PortASTNode) currentNode;
            portASTNode.portDirection = PortDirection.OUTPUT;
            portASTNode.listOfPortNames = listOfPortNamesSplit;
            portASTNode.dataType = new DataTypeASTNode();
            portASTNode.dataType.value = ctx.getChild(1).getText();
            portASTNode.dataType.rangeExpression = expressionStackPop();

        }

    }

    /**
     * Range used in explicit port declarations!
     * explicit:
     *
     * ```
     * module design_top(
     * output wire[31:0] o_rs2
     * );
     * ```
     */
    @Override
    public void enterRange_(VerilogParser.Range_Context ctx) {
    }

    /**
     * Range used in explicit port declarations!
     * explicit:
     *
     * ```
     * module design_top(
     * output wire[31:0] o_rs2
     * );
     * ```
     */
    @Override
    public void exitRange_(VerilogParser.Range_Context ctx) {
        RangeExpressionASTNode rangeExpressionASTNode = getRangeExpressionASTNode(ctx);

        expressionStackPush(rangeExpressionASTNode);
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

    //
    // Parameter
    //

    @Override
    public void exitParameter_declaration(VerilogParser.Parameter_declarationContext ctx) {

        if (!expressionStack.empty()) {
            ((ModuleParameterASTNode) currentNode).expression = expressionStackPop();
        }

        // ascend
        currentNode = currentNode.parent;
    }

    @Override
    public void enterParameter_identifier(VerilogParser.Parameter_identifierContext ctx) {
    }

    /**
     * Used during module declaration with module parameters and also during module
     * instantiation
     */
    @Override
    public void exitParameter_identifier(VerilogParser.Parameter_identifierContext ctx) {
        currentNode.value = ctx.getText();
    }

    //
    // reg declaration
    //

    @Override
    public void enterReg_declaration(VerilogParser.Reg_declarationContext ctx) {
    }

    @Override
    public void exitReg_declaration(VerilogParser.Reg_declarationContext ctx) {
        // System.out.println("[" + ctx.hashCode() + "] " + ctx.getText() + " children:
        // " + ctx.children.size());

        RegisterExpressionASTNode registerExpressionASTNode = new RegisterExpressionASTNode();
        String name = "UNKNOWN";

        if (expressionStack.empty()) {

            // register name
            name = ctx.getChild(1).getText();

        } else {

            ExpressionStatementASTNode temp = expressionStackPeek();
            if (temp instanceof RangeExpressionASTNode) {

                ExpressionStatementASTNode expressionStatementASTNode = expressionStackPop();

                // range expression
                RangeExpressionASTNode rangeExpressionASTNode = (RangeExpressionASTNode) expressionStatementASTNode;
                registerExpressionASTNode.range = rangeExpressionASTNode;

                // register name
                name = ctx.getChild(2).getText();
            }
        }

        registerExpressionASTNode.value = name;

        currentNode.children.add(registerExpressionASTNode);
    }

    //
    // Module Instantiation
    //

    @Override
    public void enterModule_instantiation(VerilogParser.Module_instantiationContext ctx) {
        // System.out.println("[" + ctx.hashCode() + "] " + ctx.getText());

        ModuleInstantiationASTNode moduleInstantiationASTNode = new ModuleInstantiationASTNode();
        moduleInstantiationASTNode.ctx = ctx;
        moduleInstantiationASTNode.value = "module_instantiation";
        // this is the type name, not the instance name
        moduleInstantiationASTNode.name = ctx.getChild(0).getText();

        // connect parent and child
        moduleInstantiationASTNode.parent = currentNode;
        currentNode.children.add(moduleInstantiationASTNode);

        // descend
        currentNode = moduleInstantiationASTNode;
    }

    @Override
    public void exitModule_instantiation(VerilogParser.Module_instantiationContext ctx) {
        // ascend
        currentNode = currentNode.parent;
    }

    @Override
    public void enterOrdered_parameter_assignment(VerilogParser.Ordered_parameter_assignmentContext ctx) {

    }

    @Override
    public void exitOrdered_parameter_assignment(VerilogParser.Ordered_parameter_assignmentContext ctx) {
    }

    @Override
    public void enterNamed_parameter_assignment(VerilogParser.Named_parameter_assignmentContext ctx) {

        ParameterAssignmentASTNode parameterAssignmentASTNode = new ParameterAssignmentASTNode();
        parameterAssignmentASTNode.value = ctx.getChild(0).getText();

        ((ModuleInstantiationASTNode) currentNode).parameterAssignments.add(parameterAssignmentASTNode);

        // connect parent and child
        parameterAssignmentASTNode.parent = currentNode;
        currentNode.children.add(parameterAssignmentASTNode);

        // descend
        currentNode = parameterAssignmentASTNode;
    }

    @Override
    public void exitNamed_parameter_assignment(VerilogParser.Named_parameter_assignmentContext ctx) {

        ((ParameterAssignmentASTNode) currentNode).expression = expressionStackPop();

        // ascend
        currentNode = currentNode.parent;
    }

    @Override
    public void enterParam_assignment(VerilogParser.Param_assignmentContext ctx) {
        // System.out.println("[" + ctx.hashCode() + "] " + ctx.getText());

        ParameterAssignmentASTNode parameterAssignmentASTNode = new ParameterAssignmentASTNode();
        parameterAssignmentASTNode.value = ctx.getChild(0).getText();

        if (currentNode instanceof ModuleDeclaractionASTNode) {
            ((ModuleDeclaractionASTNode) currentNode).parameterAssignments.add(parameterAssignmentASTNode);
        } else if (currentNode instanceof ModuleParameterASTNode) {
            ((ModuleParameterASTNode) currentNode).assignment = parameterAssignmentASTNode;
        } else {
            throw new RuntimeException();
        }

        // connect parent and child
        parameterAssignmentASTNode.parent = currentNode;
        currentNode.children.add(parameterAssignmentASTNode);

        // descend
        currentNode = parameterAssignmentASTNode;
    }

    @Override
    public void exitParam_assignment(VerilogParser.Param_assignmentContext ctx) {

        ((ParameterAssignmentASTNode) currentNode).expression = expressionStackPop();

        // ascend
        currentNode = currentNode.parent;

    }

    @Override
    public void enterModule_instance_identifier(VerilogParser.Module_instance_identifierContext ctx) {
    }

    @Override
    public void exitModule_instance_identifier(VerilogParser.Module_instance_identifierContext ctx) {
        ((ModuleInstantiationASTNode) currentNode).instanceIdentifier = ctx.getText();
    }

    @Override
    public void enterNamed_port_connection(VerilogParser.Named_port_connectionContext ctx) {
    }

    @Override
    public void exitNamed_port_connection(VerilogParser.Named_port_connectionContext ctx) {
        ModuleInstantiationPortConnection moduleInstantiationPortConnection = new ModuleInstantiationPortConnection();

        moduleInstantiationPortConnection.value = ctx.children.get(1).getText();
        if (!expressionStack.empty()) {
            moduleInstantiationPortConnection.expression = expressionStackPop();
        }

        ((ModuleInstantiationASTNode) currentNode).portConnections.add(moduleInstantiationPortConnection);
    }

    @Override
    public void enterNet_declaration(VerilogParser.Net_declarationContext ctx) {

        NetDeclarationASTNode netDeclarationASTNode = new NetDeclarationASTNode();
        netDeclarationASTNode.value = ctx.getChild(0).getText();

        // connect parent and child
        netDeclarationASTNode.parent = currentNode;
        currentNode.children.add(netDeclarationASTNode);

        // descend
        currentNode = netDeclarationASTNode;
    }

    /**
     * Complex Example (net declaration initialized with concatenation):
     * 
     * <pre>
     * wire [ DATA_NUM * 8 - 1 : 0 ] send_data = { "Tang Nano 20K", 16'h0d0a };
     * </pre>
     */
    @Override
    public void exitNet_declaration(VerilogParser.Net_declarationContext ctx) {

        NetDeclarationASTNode currentNodeAsNetDeclarationASTNode = ((NetDeclarationASTNode) currentNode);
        
        // expecting concatenation value as initialization value
        if (!expressionStack.empty()) {

            ExpressionStatementASTNode temp = expressionStackPeek();
            if (temp instanceof ConcatenationExpressionStatementASTNode) {

                ConcatenationExpressionStatementASTNode concatenationExpressionStatementASTNode = (ConcatenationExpressionStatementASTNode) expressionStackPop();
                
                // add expression into the expression property
                currentNodeAsNetDeclarationASTNode.expression = concatenationExpressionStatementASTNode;

            }
        }

        // expecting range expression
        if (!expressionStack.empty()) {
            ExpressionStatementASTNode temp = expressionStackPeek();
            if (temp instanceof RangeExpressionASTNode) {

                temp = expressionStackPop();
                
                currentNodeAsNetDeclarationASTNode.dataType = new DataTypeASTNode();
                currentNodeAsNetDeclarationASTNode.dataType.value = "wire";
                currentNodeAsNetDeclarationASTNode.dataType.rangeExpression = temp;
            }
        }

        // // DEBUG
        // StringBuilder stringBuilder = new StringBuilder();
        // currentNode.printRecursive(stringBuilder, 0);
        // System.out.println(stringBuilder);

        // ascend
        currentNode = currentNode.parent;
    }

    //
    // Statements
    //

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

        ((CaseStatementASTNode) currentNode).expression = expressionStackPop();

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
            ((CaseStatementItemASTNode) currentNode).expression = expressionStackPop();
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
            ((IfStatementASTNode) currentNode).expression = expressionStackPop();

            // ascend
            currentNode = currentNode.parent;
        }
        if (ctx.hashCode() == currentNode.ctx.hashCode()) {

            // ascend
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
            ((IfStatementASTNode) currentNode).expression = expressionStackPop();

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
    public void exitSeq_block(VerilogParser.Seq_blockContext ctx) {

        // exit if statement
        if (currentNode instanceof IfStatementASTNode) {
            ((IfStatementASTNode) currentNode).expression = expressionStackPop();

            // ascend
            currentNode = currentNode.parent;
        }
    }

    @Override
    public void exitNet_assignment(VerilogParser.Net_assignmentContext ctx) {

        NetAssignmentASTNode astNode = new NetAssignmentASTNode();
        astNode.ctx = ctx;
        astNode.expression = expressionStackPop();
        astNode.target = expressionStackPop();
        astNode.value = "net_assignment_statement (=)";

        currentNode.children.add(astNode);
    }

    @Override
    public void exitNonblocking_assignment(VerilogParser.Nonblocking_assignmentContext ctx) {

        AssignmentASTNode astNode = new AssignmentASTNode();
        astNode.ctx = ctx;
        astNode.expression = expressionStackPop();
        astNode.target = expressionStackPop();
        astNode.value = "nonblocking_assignment_statement (<=)";
        astNode.blocking = false;

        currentNode.children.add(astNode);
    }

    @Override
    public void exitBlocking_assignment(VerilogParser.Blocking_assignmentContext ctx) {

        AssignmentASTNode astNode = new AssignmentASTNode();
        astNode.ctx = ctx;
        astNode.expression = expressionStackPop();
        astNode.target = expressionStackPop();
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

        expressionStackPush(astNode);
    }

    @Override public void enterSimple_identifier(VerilogParser.Simple_identifierContext ctx) { }
	@Override public void exitSimple_identifier(VerilogParser.Simple_identifierContext ctx) { 

        if (currentNode instanceof NetDeclarationASTNode) {
            NetDeclarationASTNode netDeclarationASTNode = (NetDeclarationASTNode) currentNode;
            netDeclarationASTNode.identifiers = ctx.getText();
        }
    }
	

    @Override
    public void exitNumber(VerilogParser.NumberContext ctx) {

        ExpressionStatementASTNode astNode = new ExpressionStatementASTNode();
        astNode.ctx = ctx;
        astNode.value = ctx.getText();

        expressionStackPush(astNode);
    }

    @Override public void enterString_(VerilogParser.String_Context ctx) { }

	@Override public void exitString_(VerilogParser.String_Context ctx) {
        //System.out.println("[" + ctx.hashCode() + "] " + ctx.getText() + " children: " + ctx.children.size());

        ExpressionStatementASTNode temp = new ExpressionStatementASTNode();
        temp.value = ctx.getText();
        expressionStackPush(temp);
    }

    @Override
    public void enterRange_expression(VerilogParser.Range_expressionContext ctx) {
    }

    @Override
    public void exitRange_expression(VerilogParser.Range_expressionContext ctx) {

        RangeExpressionASTNode rangeExpressionASTNode = getRangeExpressionASTNode(ctx);

        expressionStackPush(rangeExpressionASTNode);
    }

    private RangeExpressionASTNode getRangeExpressionASTNode(ParserRuleContext ctx) {

        RangeExpressionASTNode rangeExpressionASTNode = new RangeExpressionASTNode();

        RangeExpressionSeparatorType rangeExpressionSeparator = RangeExpressionSeparatorType.UNKNOWN;

        if (ctx.children.size() == 1) {

            rangeExpressionASTNode.size = 1;
            rangeExpressionASTNode.rangeExpressionSeparatorType = rangeExpressionSeparator;
            rangeExpressionASTNode.right = expressionStackPop();

        } else if (ctx.children.size() == 3) {

            rangeExpressionSeparator = RangeExpressionSeparatorType.fromString(ctx.getChild(1).getText());

            rangeExpressionASTNode.size = 2;
            rangeExpressionASTNode.rangeExpressionSeparatorType = rangeExpressionSeparator;
            rangeExpressionASTNode.right = expressionStackPop();
            rangeExpressionASTNode.left = expressionStackPop();

        } else if (ctx.children.size() == 5) {

            rangeExpressionSeparator = RangeExpressionSeparatorType.fromString(ctx.getChild(2).getText());

            rangeExpressionASTNode.size = 2;
            rangeExpressionASTNode.rangeExpressionSeparatorType = rangeExpressionSeparator;
            rangeExpressionASTNode.right = expressionStackPop();
            rangeExpressionASTNode.left = expressionStackPop();

        }

        return rangeExpressionASTNode;
    }

    @Override
    public void enterPrimary(VerilogParser.PrimaryContext ctx) {
    }

    @Override
    public void exitPrimary(VerilogParser.PrimaryContext ctx) {
        //System.out.println("[" + ctx.hashCode() + "] " + ctx.getText() + " children: " + ctx.children.size());

        if (ctx.getChildCount() == 1) {

            // nop
            //
            // single nodes are not precessed. Instead the parse tree nodes for
            // sub types will process values

        } else if (ctx.getChildCount() == 2) {

            ExpressionStatementASTNode temp = expressionStackPop();
            if (temp instanceof RangeExpressionASTNode) {

                // range expression
                RangeExpressionASTNode rangeExpressionASTNode = (RangeExpressionASTNode) temp;

                // register name
                temp = expressionStackPop();

                RegisterExpressionASTNode registerExpressionASTNode = new RegisterExpressionASTNode();

                registerExpressionASTNode.var = temp;
                registerExpressionASTNode.range = rangeExpressionASTNode;

                expressionStackPush(registerExpressionASTNode);
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
            expressionStatementASTNode.rhs = expressionStackPop();

            expressionStackPush(expressionStatementASTNode);

        } else if (childCount == 3) {

            expressionStatementASTNode.operator = child1.getText();
            expressionStatementASTNode.rhs = expressionStackPop();
            expressionStatementASTNode.lhs = expressionStackPop();

            expressionStackPush(expressionStatementASTNode);

        } else if (childCount == 5) {

            ParseTree operatorChildParseTree = ctx.getChild(1);
            if (operatorChildParseTree.getText().equalsIgnoreCase("?")) {

                expressionStatementASTNode.operator = child1.getText();
                expressionStatementASTNode.rhs = expressionStackPop();
                expressionStatementASTNode.lhs = expressionStackPop();
                expressionStatementASTNode.predicate = expressionStackPop();

                expressionStackPush(expressionStatementASTNode);

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

        // add concatenation marker to the stack
        ExpressionStatementASTNode concatenationMarker = new ExpressionStatementASTNode();
        concatenationMarker.value = "CONCATENATION_MARKER";
        expressionStackPush(concatenationMarker);

    }

    @Override
    public void exitConcatenation(VerilogParser.ConcatenationContext ctx) {

        ConcatenationExpressionStatementASTNode concatenationExpressionStatementASTNode = new ConcatenationExpressionStatementASTNode();

        // pop all items from the stack until the CONCATENATION_MARKER is retrieved
        do {

            ExpressionStatementASTNode expressionStatementASTNode = expressionStackPop();
            if ((expressionStatementASTNode.value != null)
                    && (expressionStatementASTNode.value.equalsIgnoreCase("CONCATENATION_MARKER"))) {
                break;
            }

            // insert node into parent
            connectParentAndChildFront(concatenationExpressionStatementASTNode, expressionStatementASTNode);

        } while (true);

        // put new node onto the stack
        expressionStackPush(concatenationExpressionStatementASTNode);
    }

    @Override
    public void enterSystem_function_call(VerilogParser.System_function_callContext ctx) {

        // add concatenation marker
        ExpressionStatementASTNode systemFunctionMarker = new ExpressionStatementASTNode();
        systemFunctionMarker.value = "SYSTEM_FUNCTION_MARKER";
        expressionStackPush(systemFunctionMarker);
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

        SystemFunctionCallASTNode systemFunctionCallASTNode = new SystemFunctionCallASTNode();
        systemFunctionCallASTNode.value = ctx.getChild(0).getText();

        do {

            ExpressionStatementASTNode expressionStatementASTNode = expressionStackPop();
            if ((expressionStatementASTNode.value != null)
                    && (expressionStatementASTNode.value.equalsIgnoreCase("SYSTEM_FUNCTION_MARKER"))) {
                break;
            }

            connectParentAndChildFront(systemFunctionCallASTNode, expressionStatementASTNode);

        } while (true);

        expressionStackPush(systemFunctionCallASTNode);
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
        //System.out.println("[" + ctx.hashCode() + "] " + ctx.getText() + " children: " + ctx.children.size());

        if (!expressionStack.empty()) {
            ((ProceduralTimingControlStatementASTNode) currentNode).expression = expressionStackPop();
        }

        // ascend
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

            expressionStackPush(expressionStatementASTNode);
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

    @SuppressWarnings("unused")
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

    //
    // Expression Stack Utils
    //

    private ExpressionStatementASTNode expressionStackPop() {
        return expressionStack.pop();
    }

    private void expressionStackPush(ExpressionStatementASTNode expressionStatementASTNode) {
        
        // // DEBUG
        // StringBuilder stringBuilder = new StringBuilder();
        // expressionStatementASTNode.printRecursive(stringBuilder, 0);
        // System.out.println(stringBuilder);
        
        expressionStack.push(expressionStatementASTNode);
    }

    private ExpressionStatementASTNode expressionStackPeek() {
        return expressionStack.peek();
    }
}
