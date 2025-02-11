package com.mycompany.app.preprocessor;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.util.stream.Stream;

public class MaskingPreprocessor implements Preprocessor {

    public void process(final File inputFile, final File outputFile) throws IOException {

        FileWriter fileWriter = new FileWriter(outputFile, false);
        BufferedWriter bufferedWriter = new BufferedWriter(fileWriter);

        try (Stream<String> linesStream = Files.lines(inputFile.toPath())) {
            linesStream.forEach(line -> {

                System.out.println(line);

                if (line.contains("`")) {
                    line  = line.replaceAll("`", "PREPROCESSOR_");
                }

                // write method is used to write the given content into the file
                try {
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
