package com.mycompany.app;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTreeWalker;

import com.mycompany.app.ast.ASTNode;
import com.mycompany.app.ast.ModuleDeclaractionASTNode;
import com.mycompany.app.ast.AssignmentASTNode;
import com.mycompany.app.ast.PrimaryTfCallASTNode;
import com.mycompany.app.ast.ProceduralTimingControlStatementASTNode;
import com.mycompany.app.domain.ModuleDescriptor;
import com.mycompany.app.domain.ModuleDescriptorFactory;
import com.mycompany.app.preprocessor.MaskingPreprocessor;

import simulation.EvaluationEvent;
import simulation.Event;
import simulation.Region;
import simulation.TimeSlot;
import verilog.VerilogLexer;
import verilog.VerilogParser;

import systemverilog.sv2017Lexer;
import systemverilog.sv2017Parser;
import systemverilog.sv2017Parser.Source_textContext;

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

    private static final String INTERMEDIATE_FILE = "build/preprocessed.sv";

    public static void main(String[] args) throws IOException {
        mainVerilog(args);
        //mainSystemVerilog(args);
    }

    /**
     * This is the main() for the verilog parser
     */
    public static void mainVerilog(String[] args) throws IOException {

        System.out.println("Lexing ...");

        // String file = "src/test/resources/verilog_samples/elvis_operator.v"; // test
        // String file = "src/test/resources/verilog_samples/elvis_operator_simple.v";

        // String file = "src/test/resources/verilog_samples/temporal_construct.v";
        // String file = "src/test/resources/verilog_samples/fetch_stage.v";
        // String file = "src/test/resources/verilog_samples/if_else_if_else.v";

        // String file = "src/test/resources/verilog_samples/scratchpad.v";
        // String file =
        // "src/test/resources/verilog_samples/if_else_without_begin_end_without_else.v";

        // String file = "src/test/resources/verilog_samples/case_statement.v";
        // String file = "src/test/resources/verilog_samples/case_statement_simple.v";

        // String file =
        // "src/test/resources/verilog_samples/assignment_from_array_with_index.v";
        // String file =
        // "src/test/resources/verilog_samples/if_continuous_assignment.v";
        // String file =
        // "src/test/resources/verilog_samples/if_continuous_assignment_extended.v";
        // String file =
        // "src/test/resources/verilog_samples/if_else_without_begin_end.v";
        // String file = "src/test/resources/verilog_samples/command.v";
        //String file = "src/test/resources/verilog_samples/module.v"; // very complex

        //String file = "src/test/resources/verilog_samples/if_procedural.v";
        //String file = "src/test/resources/verilog_samples/if_large.v"; // todo: contains line break that cannot be parsed
        // String file = "src/test/resources/verilog_samples/if_large_fixed.v";
        // String file = "src/test/resources/verilog_samples/if_without_else.v";
        // String file = "src/test/resources/verilog_samples/if_else_chain.v";
        // String file = "src/test/resources/verilog_samples/if_complex_expression.v";
        // String file = "src/test/resources/verilog_samples/if_else_chain_simple.v";
        // String file = "src/test/resources/verilog_samples/if_else_chain_nested_if.v";

        // String file = "src/test/resources/verilog_samples/double_click.v";
        // String file = "src/test/resources/verilog_samples/loopback_device.v";
        // String file = "src/test/resources/verilog_samples/simple_module.v";
        // String file = "src/test/resources/verilog_samples/uart_top.v";

        // String file = "src/test/resources/verilog_samples/module_with_parameters.v";
        // String file = "src/test/resources/verilog_samples/module_instantiation.v";
        // String file = "src/test/resources/verilog_samples/module_instantiation2.v";

        //String file = "src/test/resources/verilog_samples/initial_block.v"; // test

        // String file = "src/test/resources/system_verilog_samples/package.sv";

        String file = "src/test/resources/verilog_samples/region_usage.v"; // test

        System.out.println("File: \"" + file + "\"");

        final CharStream charStream = CharStreams.fromFileName(file);

        final VerilogLexer lexer = new VerilogLexer(charStream);
        lexer.removeErrorListeners();
        lexer.addErrorListener(ThrowingErrorListener.INSTANCE);
        final CommonTokenStream tokens = new CommonTokenStream(lexer);

        System.out.println("Lexing done.");

        System.out.println("Parsing ...");

        final VerilogParser parser = new VerilogParser(tokens);
        parser.removeErrorListeners();
        parser.addErrorListener(ThrowingErrorListener.INSTANCE);
        final verilog.VerilogParser.Source_textContext root = parser.source_text();
        // final lel.VerilogParser.Always_constructContext root =
        // parser.always_construct();
        // final lel.VerilogParser.Always_constructContext root =
        // parser.module_declaration();

        System.out.println("Parsing done.");

        // boolean printParseTree = true;
        boolean printParseTree = false;
        if (printParseTree) {

            System.out.println("Raw Output Traversal ...");
            System.out.println("");

            RawOutputListener printListener = new RawOutputListener();

            // Create a generic parse tree walker that can trigger callbacks
            final ParseTreeWalker walker = new ParseTreeWalker();
            walker.walk(printListener, root);

            System.out.println("Raw Output Traversal done.");
        }

        // boolean output = true;
        boolean output = false;
        if (output) {

            BufferedWriter writer = new BufferedWriter(new FileWriter("test.txt"));

            final FormattingVerilogParserVisitor formatterVisitor = new FormattingVerilogParserVisitor();
            formatterVisitor.setBufferedWriter(writer);
            formatterVisitor.visit(root);

            writer.flush();
            writer.close();
        }

        boolean buildAST = true;
        // boolean buildAST = false;
        if (buildAST) {

            System.out.println("AST Output Traversal ...");
            System.out.println("");

            ASTVerilogParserListener astVerilogParserListener = new ASTVerilogParserListener();

            // Create a generic parse tree walker that can trigger callbacks
            final ParseTreeWalker walker = new ParseTreeWalker();
            walker.walk(astVerilogParserListener, root);

            System.out.println("AST Output Traversal done.");
            System.out.println("");

            StringBuilder stringBuilder = new StringBuilder();
            astVerilogParserListener.currentNode.printRecursive(stringBuilder, 0);

            System.out.println(stringBuilder.toString());
        }

        // final SimpleVerilogParserVisitor formatterVisitor = new
        // SimpleVerilogParserVisitor();
        // formatterVisitor.visit(root);
    }

    public static void mainSystemVerilog(String[] args) throws IOException {

        System.out.println("Lexing ...");

        // String file = "src/test/resources/system_verilog_samples/package.sv";
        // String file = "src/test/resources/system_verilog_samples/test_bench.sv";
        // String file =
        // "src/test/resources/system_verilog_samples/multistage_mux_4_4bit_comb.sv";
        // String file =
        // "src/test/resources/system_verilog_samples/bus_concatenation.sv";
        // String file = "src/test/resources/system_verilog_samples/dff.sv";
        // String file = "src/test/resources/system_verilog_samples/dff_2bit.sv";
        // String file = "src/test/resources/system_verilog_samples/dff_2bit_arrays.sv";
        // String file =
        // "src/test/resources/system_verilog_samples/dff_2bit_combined.sv";
        // String file = "src/test/resources/system_verilog_samples/uart.sv";
        // String file =
        // "src/test/resources/system_verilog_samples/package_definition.sv";
        //String file = "src/test/resources/system_verilog_samples/switch.sv"; // test
        //String file = "src/test/resources/system_verilog_samples/switch_simplified.sv"; // test
        // String file =
        // "src/test/resources/system_verilog_samples/precompiler_conditional_compilation.sv";

        // String file = "src/test/resources/verilog_samples/wire_delay.v";
        // String file = "src/test/resources/verilog_samples/user_defined_primitive.v";
        // String file = "src/test/resources/verilog_samples/uart_top.v";

        //String file = "src/test/resources/system_verilog_samples/uart_2.sv";

        //String file = "src/test/resources/verilog_samples/wishbone_master.v";

        String file = "src/test/resources/verilog_samples/region_usage.v";

        // String file =
        // "src/test/resources/system_verilog_samples/harris_single_cycle_riscv_cpu/riscvsingle.sv";

        // String file =
        // "src/test/resources/system_verilog_samples/if_complex_expression.sv"; // test

        // String file =
        // "src/test/resources/system_verilog_samples/blocking_assignment.sv";

        // String file = "src/test/resources/system_verilog_samples/initial_block.sv";
        // String file =
        // "src/test/resources/system_verilog_samples/initial_block_assignment.sv"; //
        // test
        // String file =
        // "src/test/resources/system_verilog_samples/procedural_timing_delay.sv"; //
        // test

        // Next Steps. #10 is not parsed. Checked in antlr lab. delay_or_event_control
        // is missing
        // String file =
        // "src/test/resources/system_verilog_samples/clock_generation.sv"; // test

        // String file = "src/test/resources/system_verilog_samples/rv32i_fetch.sv";

        // String file =
        // "src/test/resources/system_verilog_samples/module_with_parameters.sv"; //
        // test

        // String file =
        // "src/test/resources/system_verilog_samples/display.sv";

        // String file =
        // "src/test/resources/system_verilog_samples/harris_single_cycle_riscv_cpu/adder.sv";
        // // test
        // String file =
        // "src/test/resources/system_verilog_samples/harris_single_cycle_riscv_cpu/testbench_adder.sv";
        // // test

        // String file =
        // "src/test/resources/system_verilog_samples/module_instantiation.sv"; // test

        // String file =
        // "src/test/resources/system_verilog_samples/module_with_array_port.sv"; //
        // test

        // String file = "src/test/resources/system_verilog_samples/assign.sv"; // test

        // String file =
        // "src/test/resources/system_verilog_samples/module_with_local_variable.sv";

        System.out.println("File: \"" + file + "\"");

        // create build folder
        Files.createDirectories(Paths.get("build"));

        MaskingPreprocessor maskingPreprocessor = new MaskingPreprocessor();
        maskingPreprocessor.process(new File(file), new File(INTERMEDIATE_FILE));

        //
        // Construct AST
        //

        ASTNode rootASTNode = parseSystemVerilogFileToAST(INTERMEDIATE_FILE);

        //
        // Output AST
        //

        boolean outputAST = true;
        if (outputAST) {

            System.out.println("");
            System.out.println("AST -----------------------------");
            System.out.println("");

            StringBuilder stringBuilder = new StringBuilder();
            rootASTNode.printRecursive(stringBuilder, 0);

            System.out.println(stringBuilder.toString());

        }

        boolean constructAST = false;
        if (constructAST) {

            //
            // Convert the AST of a module into a module descriptor
            //

            //
            // A module descriptor consists of:
            // -- the module name
            // -- all input and output ports to the module
            // -- all parameters (TODO)
            // -- all local variables of the module (TODO)
            // -- a list of initial processes (TODO)
            // -- a list of non-initial processes
            // ---- assign is converted to a process (TODO)
            // ---- if a module is instantiated within a module, a process for that
            // instantiated module is created
            //

            ModuleDescriptorFactory moduleDescriptorFactory = new ModuleDescriptorFactory();
            ModuleDescriptor moduleDescriptor = moduleDescriptorFactory.produce(rootASTNode);

            System.out.println(moduleDescriptor);

            //
            // Simulation
            //

            boolean simulation = false;
            if (simulation) {

                System.out.println("");
                System.out.println("Simulation -----------------------------");
                System.out.println("");

                ModuleDeclaractionASTNode module = (ModuleDeclaractionASTNode) rootASTNode.children.get(0);

                // TODO when a module is instantiated, create an instance from the
                // module definition and create a process that wraps that instance

                TimeSlot timeSlot = new TimeSlot();

                // check the module for initial blocks and create a EvaluationEvent for
                // each inital block found. Insert the events into the active region of the
                // timeslot
                module.children.stream()
                        .filter(child -> child instanceof ProceduralTimingControlStatementASTNode)
                        .filter(child -> ((ProceduralTimingControlStatementASTNode) child).initial)
                        .map(child -> {
                            EvaluationEvent event = new EvaluationEvent();
                            event.process = (ProceduralTimingControlStatementASTNode) child;
                            return event;
                        })
                        .forEach(child -> {
                            // System.out.println(child);
                            timeSlot.activeRegion.eventSet.add(child);
                        });

                // System.out.println("a");

                // while (some time slot is nonempty) {
                // move to the first nonempty time slot and set T;
                // execute_time_slot (T);
                // }

                executeTimeSlot(timeSlot);
            }
        }
    }

    private static ASTNode parseSystemVerilogFileToAST(String file) throws IOException {

        final CharStream charStream = CharStreams.fromFileName(file);

        final sv2017Lexer lexer = new sv2017Lexer(charStream);
        lexer.removeErrorListeners();
        lexer.addErrorListener(ThrowingErrorListener.INSTANCE);

        // create a buffer of tokens pulled from the lexer
        final CommonTokenStream tokens = new CommonTokenStream(lexer);

        System.out.println("Lexing done.");

        System.out.println("Parsing ...");

        final sv2017Parser parser = new sv2017Parser(tokens);
        parser.removeErrorListeners();
        parser.addErrorListener(ThrowingErrorListener.INSTANCE);

        // parse
        final Source_textContext root = parser.source_text();

        // boolean printParseTree = true;
        boolean printParseTree = false;
        if (printParseTree) {

            System.out.println("Raw Output Traversal ...");
            System.out.println("");

            SystemVerilogListener printListener = new SystemVerilogListener();

            // Create a generic parse tree walker that can trigger callbacks
            final ParseTreeWalker walker = new ParseTreeWalker();
            walker.walk(printListener, root);

            System.out.println("Raw Output Traversal done.");
        }

        System.out.println("Parsing done.");

        //
        // Convert ParseTree to AST
        //

        System.out.println("");
        System.out.println("ParseTree -----------------------------");
        System.out.println("");

        // SystemVerilogListener listener = new SystemVerilogListener();
        // DefaultStructuredTextListener listener = new DefaultStructuredTextListener();
        ASTSystemVerilogParserListener listener = new ASTSystemVerilogParserListener();

        // create a generic parse tree walker that can trigger callbacks
        final ParseTreeWalker walker = new ParseTreeWalker();

        // walk the tree created during the parse, trigger callbacks
        walker.walk(listener, root);

        System.out.println("ParseTree traversal done.");
        System.out.println("");

        return listener.currentNode;
    }

    private static void executeTimeSlot(TimeSlot timeSlot) {

        execute_region(timeSlot.preponedRegion);
        // TODO
        // execute_region(timeSlot.preActiveRegion);

        // while (any region in [Active ... Post-Observed] is nonempty) {
        boolean done = false;
        while (!done) {
            execute_region(timeSlot.activeRegion);
            done = true;
        }
    }

    private static void execute_region(Region region) {

        if (region.eventSet.isEmpty()) {
            return;
        } else {

            while (!region.eventSet.isEmpty()) {

                // consume any event (get it, remove it)
                Event event = region.eventSet.iterator().next();
                region.eventSet.remove(event);

                if (event instanceof EvaluationEvent) {

                    EvaluationEvent evalEvent = (EvaluationEvent) event;

                    for (ASTNode child : evalEvent.process.children) {

                        // System.out.println(child);

                        if (child instanceof ProceduralTimingControlStatementASTNode) {

                            ProceduralTimingControlStatementASTNode timingStatement = (ProceduralTimingControlStatementASTNode) child;

                            System.out.println(timingStatement);

                        } else if (child instanceof AssignmentASTNode) {

                            AssignmentASTNode assignmentASTNode = (AssignmentASTNode) child;

                            System.out.println(assignmentASTNode);

                            // TODO insert an update event into the current active region

                        } else if (child instanceof PrimaryTfCallASTNode) {

                            PrimaryTfCallASTNode primaryTfCallASTNode = (PrimaryTfCallASTNode) child;

                            switch (primaryTfCallASTNode.primaryType) {

                                case DISPLAY:
                                    primaryTfCallASTNode.execute();
                                    break;

                                case FINISH:
                                    primaryTfCallASTNode.execute();
                                    break;

                                default:
                                    throw new RuntimeException("Unknown primitive " + primaryTfCallASTNode.primaryType);
                            }

                        } else {

                            throw new RuntimeException("No branch for " + child.getClass());
                        }

                    }
                }
            }
        }

    }

}
