// decodes ALU control signals from the instruction
module aludec(

    // // input
    // input   wire                opb5,       // opcode, bit 5 from RISCV instruction
    // input   wire    [2:0]       funct3,     // funct3 from RISCV instruction
    // input   wire                funct7b5,   // funct7, bit 5 from RISCV instruction
    // // input   wire    [1:0]       ALUOp,

    // input
    input   wire [6:0] opcode,
    input   wire [2:0] funct3,
    input   wire [6:0] funct7,

    // output
    output  reg [2:0] ALUControl

);

    always @(opcode, funct3, funct7)
    begin

        case (opcode)

            7'b0010011:
            begin

                case (funct3)

                    3'b000:
                    begin
                        // addi
                        //$display("[ALU_DEC] addi");
                        ALUControl = 3'b000; // add, addi
                    end

                    3'b010:
                    begin
                        // slti
                        $display("[ALU_DEC] slti");
                        ALUControl = 3'b101; // slt, slti
                    end

                    3'b011:
                    begin
                        // sltiu
                    end

                    3'b100:
                    begin
                        // xori
                    end

                    3'b110:
                    begin
                        // ori
                        $display("[ALU_DEC] ori");
                        ALUControl = 3'b011; // or, ori
                    end

                    3'b111:
                    begin
                        // andi
                        $display("[ALU] andi");
                        ALUControl = 3'b010; // and, andi
                    end

                    3'b001:
                    begin
                        // slli
                    end

                    3'b101:
                    begin
                        case (funct7)

                            7'b0000000:
                            begin
                                // srli
                            end

                            7'b0100000:
                            begin
                                // srai
                            end

                        endcase
                    end

                endcase
            end

            7'b0110011:
            begin

                case (funct3)

                    3'b000:
                    begin

                        case (funct7)

                            7'b0000000:
                            begin
                                // add
                                $display("[ALU] add");
                                ALUControl = 3'b000; // addition
                            end

                            7'b0100000:
                            begin
                                // sub
                                $display("[ALU] sub");
                                ALUControl = 3'b001; // addition
                            end

                        endcase

                    end

                    3'b001:
                    begin
                        // sll
                    end

                    3'b010:
                    begin
                        // slt
                        $display("[ALU] slt");
                        ALUControl = 3'b101; // slt, slti
                    end

                    3'b011:
                    begin
                        // sltu
                    end

                    3'b100:
                    begin
                        // xor
                    end

                    3'b101:
                    begin

                        case (funct7)

                            7'b0000000:
                            begin
                                // srl
                            end

                            7'b0100000:
                            begin
                                // sra
                            end

                        endcase

                    end

                    3'b110:
                    begin
                        // or
                        $display("[ALU] or");
                        ALUControl = 3'b011; // or, ori
                    end

                    3'b111:
                    begin
                        // and
                        $display("[ALU] and");
                        ALUControl = 3'b010; // and, andi
                    end

                endcase
            end

            default:
            begin
                $display("[ALU] default");
                ALUControl = 3'bxxx;
            end

        endcase

    end

    // wire  RtypeSub;

    // assign RtypeSub = funct7b5 & opb5; // TRUE for R–type subtract

    // always @*

    //     case (ALUOp)

    //         2'b00: begin ALUControl = 3'b000; end // addition
    //         2'b01: begin ALUControl = 3'b001; end // subtraction

    //         default: begin

    //             case (funct3) // R–type or I–type ALU
    //                 3'b000: begin
    //                     if (RtypeSub)
    //                         ALUControl = 3'b001; // sub
    //                     else
    //                         ALUControl = 3'b000; // add, addi
    //                 end
    //                 3'b010: begin ALUControl = 3'b101; end // slt, slti
    //                 3'b110: begin ALUControl = 3'b011; end // or, ori
    //                 3'b111: begin ALUControl = 3'b010; end // and, andi
    //                 default: begin ALUControl = 3'bxxx; end // ???
    //             endcase
    //         end
    //     endcase



endmodule