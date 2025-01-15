package com.mycompany.app;

import java.io.BufferedWriter;
import java.io.IOException;

import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.TerminalNode;

import lel.VerilogLexer;
import lel.VerilogParser;
import lel.VerilogParser.Module_identifierContext;
import lel.VerilogParser.Module_instanceContext;
import lel.VerilogParser.Module_instantiationContext;
import lel.VerilogParser.Name_of_module_instanceContext;
import lel.VerilogParser.Named_port_connectionContext;
import lel.VerilogParserBaseVisitor;

public class FormattingVerilogParserVisitor extends VerilogParserBaseVisitor<String> {

    private static final String INDENT = "    ";
    private int indent = 0;
    private boolean preventNewLine;
    private boolean displaceBeginEnd;
    private boolean firstTokenInRow = true;

    private BufferedWriter bufferedWriter;

    public void prntIndt(final TerminalNode terminalNode) {
        prntIndt(terminalNode.toString());
    }

    public void prntIndt(final String data) {
        for (int i = 0; i < indent; i++) {
            prnt(INDENT);
        }
        prntln(data);
    }

    public void prnt(final String data) {
        // System.out.print(data);
        try {
            bufferedWriter.write(data);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void prntln(final String data) {
        prnt(data);
    }

    private void newLine() {
        firstTokenInRow = true;
    }

    public void newLineWidthIndent() {
        prntln("");
        for (int i = 0; i < indent; i++) {
            prnt(INDENT);
        }
        firstTokenInRow = true;
    }

    private void incIndent(final String label) {
        indent++;
        System.out.println("inc " + label + " " + indent);
    }

    private void decIndent(final String label) {
        indent--;
        System.out.println("dec " + label + " " + indent);
    }

    @Override
    public String visitIf_generate_construct(VerilogParser.If_generate_constructContext ctx) {
        return visitChildren(ctx);
    }

    @Override
    public String visitSeq_block(VerilogParser.Seq_blockContext ctx) {

        // begin
        prnt(ctx.BEGIN().toString());

        if (displaceBeginEnd) {
            displaceBeginEnd = false;
            newLine();
        }

        incIndent("visitSeq_block");

        String result = this.defaultResult();
        int n = ctx.getChildCount();

        for (int i = 1; (i < n - 1) && this.shouldVisitNextChild(ctx, result); ++i) {
            ParseTree c = ctx.getChild(i);
            String childResult = c.accept(this);
            result = this.aggregateResult(result, childResult);
        }

        decIndent("visitSeq_block");

        newLineWidthIndent();

        // end
        prnt(ctx.END().toString());

        return result;
    }

    @Override
    public String visitConditional_statement(VerilogParser.Conditional_statementContext ctx) {

        String result = this.defaultResult();

        // if
        prnt(ctx.IF().toString());

        // '(' (LP = left paranthesis)
        prnt(" " + ctx.LP().toString());

        // output the condition
        ParseTree c = ctx.getChild(2);
        String childResult = c.accept(this);
        result = this.aggregateResult(result, childResult);

        // ')' (RP = right paranthesis)
        prnt(ctx.RP().toString());

        incIndent("visitConditional");

        // output if-branch statements
        ParseTree ifBranchStatements = ctx.getChild(4);
        childResult = ifBranchStatements.accept(this);
        result = this.aggregateResult(result, childResult);

        if (ctx.ELSE() != null) {

            decIndent("visitConditional");
            newLineWidthIndent();

            prnt(ctx.ELSE().toString());

            // incIndent("visitConditional");

            // output else-branch statements
            ParseTree elseBranchStatements = ctx.getChild(6);
            if (elseBranchStatements != null) {
                childResult = elseBranchStatements.accept(this);
                result = this.aggregateResult(result, childResult);

            }

        }

        decIndent("visitConditional");

        return result;
    }

    @Override
    public String visitAlways_construct(VerilogParser.Always_constructContext ctx) {
        newLineWidthIndent();

        preventNewLine = true;
        return visitChildren(ctx);
    }

    @Override
    public String visitStatement(VerilogParser.StatementContext ctx) {

        if (!preventNewLine) {
            newLineWidthIndent();
        }
        preventNewLine = false;

        String result = this.defaultResult();
        int n = ctx.getChildCount();

        for (int i = 0; (i < n) && this.shouldVisitNextChild(ctx, result); ++i) {
            ParseTree c = ctx.getChild(i);
            String childResult = c.accept(this);
            result = this.aggregateResult(result, childResult);
        }

        return result;
    }

    @Override
    public String visitList_of_port_declarations(VerilogParser.List_of_port_declarationsContext ctx) {

        firstTokenInRow = true;

        incIndent("visitList_of_port_declarations");

        String result = this.defaultResult();
        int n = ctx.getChildCount();

        for (int i = 0; (i < n - 1) && this.shouldVisitNextChild(ctx, result); ++i) {
            ParseTree c = ctx.getChild(i);
            String childResult = c.accept(this);
            result = this.aggregateResult(result, childResult);
        }

        prnt("\n)");

        return result;
    }

    @Override
    public String visitModule_instantiation(Module_instantiationContext ctx) {

        // incIndent("visitModule_instantiation");

        newLineWidthIndent();

        String result = this.defaultResult();
        int n = ctx.getChildCount();

        for (int i = 0; (i < n) && this.shouldVisitNextChild(ctx, result); ++i) {

            ParseTree c = ctx.getChild(i);

            if (c instanceof Module_identifierContext) {

                prntln(c.getText() + " ");

            } else {

                String childResult = c.accept(this);
                // result = this.aggregateResult(result, childResult);

            }
        }

        // decIndent("visitModule_instantiation");

        return this.defaultResult();
    }

    @Override
    public String visitModule_instance(Module_instanceContext ctx) {

        incIndent("visitModule_instance");

        newLineWidthIndent();

        String result = this.defaultResult();
        int n = ctx.getChildCount();

        for (int i = 0; (i < n) && this.shouldVisitNextChild(ctx, result); ++i) {

            ParseTree c = ctx.getChild(i);

            if (c instanceof TerminalNode) {

                TerminalNode terminalNode = (TerminalNode) c;

                if (terminalNode.getText().equalsIgnoreCase("(")) {
                    newLineWidthIndent();
                    prntln("(");
                } else if (terminalNode.getText().equalsIgnoreCase(")")) {
                    decIndent("visitModule_instance");
                    newLineWidthIndent();
                    prntln(")");
                } else if (terminalNode.getText().equalsIgnoreCase(";")) {
                    // nothing
                }

            } else {

                String childResult = c.accept(this);
                // result = this.aggregateResult(result, childResult);

            }
        }

        // decIndent("visitModule_instance");

        return this.defaultResult();
    }

    @Override
    public String visitPort(VerilogParser.PortContext ctx) {
        newLineWidthIndent();
        return visitChildren(ctx);
    }

    @Override
    public String visitPort_declaration(VerilogParser.Port_declarationContext ctx) {
        newLineWidthIndent();
        return visitChildren(ctx);
    }

    /**
     * e.g.
     * .ier   (ier[3:0]),
     */
    @Override
    public String visitNamed_port_connection(Named_port_connectionContext ctx) {
        newLineWidthIndent();
        prntln(ctx.getText());
        return this.defaultResult();
    }

    @Override
    public String visitReg_declaration(VerilogParser.Reg_declarationContext ctx) {
        newLineWidthIndent();
        return visitChildren(ctx);
    }

    /**
     * wire
     */
    @Override
    public String visitNet_declaration(VerilogParser.Net_declarationContext ctx) {
        newLineWidthIndent();
        return visitChildren(ctx);
    }

    @Override
    public String visitLine_comment(VerilogParser.Line_commentContext ctx) {
        newLineWidthIndent();
        visitChildren(ctx);
        return defaultResult();
    }

    @Override
    public String visitProcedural_continuous_assignments(VerilogParser.Procedural_continuous_assignmentsContext ctx) {
        return visitChildren(ctx);
    }

    @Override
    public String visitNonblocking_assignment(VerilogParser.Nonblocking_assignmentContext ctx) {
        return visitChildren(ctx);
    }

    @Override
    public String visitList_of_net_assignments(VerilogParser.List_of_net_assignmentsContext ctx) {
        return visitChildren(ctx);
    }

    @Override
    public String visitContinuous_assignment(VerilogParser.Continuous_assignmentContext ctx) {
        newLineWidthIndent();
        return visitChildren(ctx);
    }

    @Override
    public String visitNew_line(VerilogParser.New_lineContext ctx) {
        return visitChildren(ctx);
    }

    public String visitTerminal(TerminalNode node) {

        if (node.getSymbol().getType() == VerilogLexer.LINE_COMMENT) {
            prnt(node.toString());
            return this.defaultResult();
        }
        if (node.getSymbol().getType() == VerilogLexer.BLOCK_COMMENT) {
            //prnt(node.toString() + "\n");
            prnt(node.toString());
            return this.defaultResult();
        }

        String data = node.toString();

        if (data.equals("endmodule")) {

            // decIndent("visitTerminal");
            newLineWidthIndent();

            prntln(node.toString());

        } else if (data.equals(",")) {

            prnt(node.toString());

        } else if (data.equals(";")) {

            prnt(node.toString());

        } else {

            // only prefix a space if this
            // token is not the first in the row
            if (!firstTokenInRow) {
                prnt(" ");
            }
            prnt(node.toString());

        }

        firstTokenInRow = false;

        return this.defaultResult();
    }

    public BufferedWriter getBufferedWriter() {
        return bufferedWriter;
    }

    public void setBufferedWriter(BufferedWriter bufferedWriter) {
        this.bufferedWriter = bufferedWriter;
    }

}
