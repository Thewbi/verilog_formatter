package com.mycompany.app;

import org.antlr.v4.runtime.tree.TerminalNode;

import lel.VerilogLexer;
import lel.VerilogParser;
import lel.VerilogParserBaseVisitor;
import lel.VerilogParser.Net_typeContext;
import lel.VerilogParser.ExpressionContext;
import lel.VerilogParser.Named_port_connectionContext;

/**
 * During the output phase, it is valid to collaps several, consecutive empty
 * lines into a single one
 */
public class SimpleVerilogParserVisitor extends VerilogParserBaseVisitor<String> {

    private int indent;

    @Override
    public String visitModule_declaration(VerilogParser.Module_declarationContext ctx) {
        System.out.println("visitModule_declaration: " + ctx.module_identifier().getText());
        return visitChildren(ctx);
    }

    /**
     * ports of a module
     */
    @Override
    public String visitPort(VerilogParser.PortContext ctx) {
        System.out.println("visitPort: " + ctx.getText());
        return visitChildren(ctx);
    }

    /**
     * ports are furthered described within the module
     */
    @Override
    public String visitPort_declaration(VerilogParser.Port_declarationContext ctx) {
        System.out.println("visitPort_declaration: ");
        return visitChildren(ctx);
    }

    @Override
    public String visitPort_identifier(VerilogParser.Port_identifierContext ctx) {
        System.out.println("visitPort_identifier: " + ctx.getText());
        return visitChildren(ctx);
    }

    @Override
    public String visitInput_declaration(VerilogParser.Input_declarationContext ctx) {
        System.out.println("visitInput_declaration: ");
        return visitChildren(ctx);
    }

    @Override
    public String visitOutput_declaration(VerilogParser.Output_declarationContext ctx) {
        System.out.println("visitOutput_declaration: ");
        return visitChildren(ctx);
    }

    /**
     * <pre>
     * parameter WAIT_WIDTH = 19;
     * </pre>
     */
    @Override
    public String visitParameter_declaration(VerilogParser.Parameter_declarationContext ctx) {
        System.out.println("visitParameter_declaration " + ctx.getText());
        return visitChildren(ctx);
    }

    /**
     * e.g.
     *
     * <pre>
     * reg btn_now, btn_last, collect;
     * </pre>
     */
    @Override
    public String visitReg_declaration(VerilogParser.Reg_declarationContext ctx) {
        System.out.println("visitReg_declaration");
        return visitChildren(ctx);
    }

    /**
     * every declared reg variable is a variable_identifier
     */
    @Override
    public String visitVariable_identifier(VerilogParser.Variable_identifierContext ctx) {
        System.out.println("visitVariable_identifier " + ctx.getText());
        return visitChildren(ctx);
    }

    /**
     * a reg can have a range
     */
    @Override
    public String visitRange_(VerilogParser.Range_Context ctx) {
        System.out.println("visitRange_ " + ctx.getText());
        return visitChildren(ctx);
    }

    /**
     * <pre>
     * assign single = (!dbl_click_cnt & (click_cnt == 3'b001)) ? 1'b1 : 1'b0;
     * assign double = (!dbl_click_cnt & (click_cnt != 3'b001)) ? 1'b1 : 1'b0;
     * </pre>
     */
    @Override
    public String visitContinuous_assignment(VerilogParser.Continuous_assignmentContext ctx) {
        System.out.println("visitContinuous_assignment: assign ");
        return visitChildren(ctx);
    }

    @Override
    public String visitNet_assignment(VerilogParser.Net_assignmentContext ctx) {
        System.out.println("visitNet_assignment: " + ctx.getText());
        return visitChildren(ctx);
    }

    /**
     * Declaration of a wire
     *
     * <pre>
     * wire btn_down = btn_now & ~btn_last;
     * </pre>
     */
    @Override
    public String visitNet_declaration(VerilogParser.Net_declarationContext ctx) {

        Net_typeContext netType = ctx.net_type();

        System.out.println("visitNet_declaration: " + netType.getText());

        return visitChildren(ctx);
    }

    @Override
    public String visitNet_decl_assignment(VerilogParser.Net_decl_assignmentContext ctx) {
        System.out.println("visitNet_decl_assignment: " + ctx.getText());
        return visitChildren(ctx);
    }

    /**
     * always construct
     */
    @Override
    public String visitAlways_construct(VerilogParser.Always_constructContext ctx) {
        System.out.println("visitAlways_construct: always");
        return visitChildren(ctx);
    }

    /**
     * event of always construct
     */
    @Override
    public String visitEvent_control(VerilogParser.Event_controlContext ctx) {
        System.out.println("visitEvent_control: " + ctx.getText());
        return visitChildren(ctx);
    }

    /**
     * <pre>
     * if (~rst_n) ... else ...
     * </pre>
     */
    @Override
    public String visitConditional_statement(VerilogParser.Conditional_statementContext ctx) {
        System.out.println("visitConditional_statement: ");

        ExpressionContext expressionContext = ctx.expression();
        System.out.println("expressionContext: " + expressionContext.getText());

        System.out.println("IF-BRANCH");
        // System.out.println(ctx.statement_or_null(0).getText());
        visitChildren(ctx.statement_or_null(0));

        System.out.println("ELSE-BRANCH");
        // System.out.println(ctx.statement_or_null(1).getText());
        visitChildren(ctx.statement_or_null(1));

        // return visitChildren(ctx);

        return this.defaultResult();
    }

    @Override
    public String visitSeq_block(VerilogParser.Seq_blockContext ctx) {

        indent++;
        System.out.println("visitSeq_block: BEGIN indent: " + indent);

        String result = visitChildren(ctx);

        indent--;
        System.out.println("visitSeq_block: END indent: " + indent);

        return result;
    }

    @Override
    public String visitNonblocking_assignment(VerilogParser.Nonblocking_assignmentContext ctx) {
        System.out.println("visitNonblocking_assignment: " + ctx.getText());
        return visitChildren(ctx);
    }

    /**
     * New line
     */
    @Override
    public String visitNew_line(VerilogParser.New_lineContext ctx) {
        System.out.println("<>");
        return visitChildren(ctx);
    }

    public void visitSingleLineComment(TerminalNode node) {
        System.out.println(node.toString());
    }

    private void visitBlockComment(TerminalNode node) {
        System.out.println(node.toString());
    }

    public String visitTerminal(TerminalNode node) {

        if (node.getSymbol().getType() == VerilogLexer.LINE_COMMENT) {
            visitSingleLineComment(node);
            return this.defaultResult();
        }
        if (node.getSymbol().getType() == VerilogLexer.BLOCK_COMMENT) {
            visitBlockComment(node);
            return this.defaultResult();
        }

        return this.defaultResult();

    }

}
