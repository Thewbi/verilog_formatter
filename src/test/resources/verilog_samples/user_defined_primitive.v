primitive SystemX ( output wire F,
                    input wire A, B, C);

    table
        // A B C : F
        0 0 0 : 1;
        0 0 1 : 0;
        0 1 0 : 1;
        0 1 1 : 0;
        1 0 0 : 0;
        1 0 1 : 0;
        1 1 0 : 1;
        1 1 1 : 0;
    endtable

endprimitive