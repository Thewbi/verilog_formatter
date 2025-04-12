package com.mycompany.app.preprocessor;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.util.stream.Stream;

public class MaskingPreprocessor implements Preprocessor {

    private static final String PREPROCESSOR_PREFIX = "PREPROCESSOR_";

    /** MPPM = Masking Preprocessor Marker */
    private static final String MARKER = "MPPM";

    public void process(final File inputFile, final File outputFile) throws IOException {

        FileWriter fileWriter = new FileWriter(outputFile, false);
        BufferedWriter bufferedWriter = new BufferedWriter(fileWriter);

        try (Stream<String> linesStream = Files.lines(inputFile.toPath())) {

            linesStream.forEach(line -> {

                // DEBUG
                // System.out.println(line);

                // write method is used to write the given content into the file
                try {

                    String lineTrimmed = line.trim();

                    // MPP stands for

                    if (lineTrimmed.startsWith("`timescale")) {
                        line = "//" + MARKER + line;
                    } else if (lineTrimmed.startsWith("`default_nettype")) {
                        line = "//" + MARKER + line;
                    } else if (lineTrimmed.startsWith("`include")) {
                        line = "//" + MARKER + line;
                    } else if (lineTrimmed.startsWith("`ifdef")) {
                        line = "//" + MARKER + line;
                    } else if (lineTrimmed.startsWith("`endif")) {
                        line = "//" + MARKER + line;
                    } else if (line.contains("`")) {
                        line  = line.replaceAll("`", PREPROCESSOR_PREFIX);
                    }

                    bufferedWriter.write(line);
                    bufferedWriter.write("\n");

                } catch (IOException e) {
                    e.printStackTrace();
                }
            });
        }

        // Closes the stream, flushing it first. Once the stream has been closed,
        // further write() or flush() invocations will cause an IOException to be
        // thrown. Closing a previously closed stream has no effect.
        bufferedWriter.close();

    }

}
