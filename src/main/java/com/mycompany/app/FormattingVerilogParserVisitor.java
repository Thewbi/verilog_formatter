package com.mycompany.app;

import java.io.BufferedWriter;
import java.io.IOException;

import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.TerminalNode;

import lel.VerilogLexer;
import lel.VerilogParser;
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
        System.out.print(data);
        try {
            bufferedWriter.write(data);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void prntln(final String data) {
        prnt(data);
    }

    // // public void prntln(final String data) {
    //     System.out.println(data);
    //     try {
    //         bufferedWriter.write(data + "\n");
    //     } catch (IOException e) {
    //         e.printStackTrace();
    //     }
    // }

    private void newLine() {
        // System.out.println("");
        // try {
        //     bufferedWriter.write("\n");
        // } catch (IOException e) {
        //     e.printStackTrace();
        // }
        firstTokenInRow = true;
    }

    public void newLineWidthIndent() {
        prntln("");
        for (int i = 0; i < indent; i++) {
            prnt(INDENT);
        }
        firstTokenInRow = true;
    }

    private void incIndent() {
        indent++;
    }

    private void decIndent() {
        indent--;
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

        incIndent();

        String result = this.defaultResult();
        int n = ctx.getChildCount();

        for (int i = 1; (i < n - 1) && this.shouldVisitNextChild(ctx, result); ++i) {
            ParseTree c = ctx.getChild(i);
            String childResult = c.accept(this);
            result = this.aggregateResult(result, childResult);
        }

        decIndent();
        newLineWidthIndent();

        // end
        prnt(ctx.END().toString());

        return result;
    }

    @Override
    public String visitConditional_statement(VerilogParser.Conditional_statementContext ctx) {

        String result = this.defaultResult();

        // newLineWidthIndent();

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

        incIndent();

        // output if-branch statements
        ParseTree ifBranchStatements = ctx.getChild(4);
        childResult = ifBranchStatements.accept(this);
        result = this.aggregateResult(result, childResult);

        if (ctx.ELSE() != null) {

            decIndent();
            newLineWidthIndent();

            prnt(ctx.ELSE().toString());

            incIndent();

            // output else-branch statements
            ParseTree elseBranchStatements = ctx.getChild(6);
            if (elseBranchStatements != null) {
                childResult = elseBranchStatements.accept(this);
                result = this.aggregateResult(result, childResult);

            }

        }

        decIndent();

        return result;
    }

    @Override
    public String visitAlways_construct(VerilogParser.Always_constructContext ctx) {

        // newLineWidthIndent();
        newLineWidthIndent();

        preventNewLine = true;
        // displaceBeginEnd = true;
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

        incIndent();

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
    public String visitPort(VerilogParser.PortContext ctx) {
        newLineWidthIndent();
        return visitChildren(ctx);
    }

    @Override
    public String visitPort_declaration(VerilogParser.Port_declarationContext ctx) {
        newLineWidthIndent();
        return visitChildren(ctx);
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
        return visitChildren(ctx);
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
        //prnt("%%");
        return visitChildren(ctx);
    }

    public String visitTerminal(TerminalNode node) {

        if (node.getSymbol().getType() == VerilogLexer.LINE_COMMENT) {
            prnt(node.toString());
            return this.defaultResult();
        }
        if (node.getSymbol().getType() == VerilogLexer.BLOCK_COMMENT) {
            prnt(node.toString() + "\n");
            return this.defaultResult();
        }

        String data = node.toString();

        if (data.equals("endmodule")) {

            decIndent();
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
