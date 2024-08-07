package com.mycompany.app;

import java.io.IOException;
import java.io.BufferedWriter;
import java.io.FileWriter;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTreeWalker;

// import lel.VerilogLexer;
// import lel.VerilogParser;

import lul.sv2017Lexer;
import lul.sv2017Parser;

import lul.sv2017Parser.Source_textContext;

/**
 * Created with:
 * 
 * <pre>
 * mvn archetype:generate -DgroupId=com.mycompany.app -DartifactId=my-app -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4 -DinteractiveMode=false
 * </pre>
 * 
 * Antlr extensions:
 * 
 * open a .g4 file > CTRL + SHIFT + P > antlr.call-graph
 * 
 * Clean java language server workspace:
 * Ctrl + Shift + P > Clean java language server workspace > Clean and Restart
 * 
 *
 */
public class App {

    // /**
    // * This is the main() for the verilog parser
    // */
    // public static void main(String[] args) throws IOException {

    // System.out.println("Lexing ...");

    // //String testFile = "src/test/resources/verilog_samples/command.v";
    // //String testFile = "src/test/resources/verilog_samples/module.v";
    // //String testFile = "src/test/resources/verilog_samples/if_procedural.v";
    // //String testFile = "src/test/resources/verilog_samples/if_large.v";
    // //String testFile = "src/test/resources/verilog_samples/if_else_chain.v";
    // //String testFile = "src/test/resources/verilog_samples/double_click.v";
    // //String testFile = "src/test/resources/verilog_samples/loopback_device.v";
    // //String testFile = "src/test/resources/verilog_samples/simple_module.v";

    // String testFile = "src/test/resources/system_verilog_samples/package.sv";

    // final CharStream charStream = CharStreams.fromFileName(testFile);

    // final VerilogLexer lexer = new VerilogLexer(charStream);
    // final CommonTokenStream tokens = new CommonTokenStream(lexer);

    // System.out.println("Parsing ...");
    // System.out.println("");

    // final VerilogParser parser = new VerilogParser(tokens);
    // final lel.VerilogParser.Source_textContext root = parser.source_text();
    // //final lel.VerilogParser.Always_constructContext root =
    // parser.always_construct();
    // //final lel.VerilogParser.Always_constructContext root =
    // parser.module_declaration();

    // boolean print = false;
    // //boolean print = true;
    // if (print) {

    // RawOutputListener printListener = new RawOutputListener();

    // // Create a generic parse tree walker that can trigger callbacks
    // final ParseTreeWalker walker = new ParseTreeWalker();
    // walker.walk(printListener, root);
    // }

    // BufferedWriter writer = new BufferedWriter(new FileWriter("test.txt"));

    // final FormattingVerilogParserVisitor formatterVisitor = new
    // FormattingVerilogParserVisitor();
    // formatterVisitor.setBufferedWriter(writer);
    // formatterVisitor.visit(root);

    // writer.flush();
    // writer.close();

    // // final SimpleVerilogParserVisitor formatterVisitor = new
    // SimpleVerilogParserVisitor();
    // // formatterVisitor.visit(root);
    // }

    public static void main(String[] args) throws IOException {
        System.out.println("Lexing ...");

        //String file = "src/test/resources/system_verilog_samples/package.sv";
        String file = "src/test/resources/system_verilog_samples/test_bench.sv";

        final CharStream charStream = CharStreams.fromFileName(file);

        final sv2017Lexer lexer = new sv2017Lexer(charStream);

        // System.out.println("assignment");

        // final CharStream charStream = CharStreams
        // .fromFileName("src/test/resources/iec61131_structuredtext/assignment.st");

        // final StructuredTextLexer lexer = new StructuredTextLexer(charStream);

        // create a buffer of tokens pulled from the lexer
        final CommonTokenStream tokens = new CommonTokenStream(lexer);

        System.out.println("Parsing ...");

        final sv2017Parser parser = new sv2017Parser(tokens);

        // parse
        //Function_block_declarationContext root = parser.function_block_declaration();
        final Source_textContext root = parser.source_text();

        SystemVerilogListener listener = new SystemVerilogListener();
        // DefaultStructuredTextListener listener = new DefaultStructuredTextListener();

        // create a generic parse tree walker that can trigger callbacks
        final ParseTreeWalker walker = new ParseTreeWalker();
        
        // walk the tree created during the parse, trigger callbacks
        walker.walk(listener, root);

        // // dump output
        // Node rootNode = listener.getRootNode();
        // rootNode.print(0);

        System.out.println();

    }

}
