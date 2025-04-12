module design_top;

    always @* begin
        y_d = {31'b0, (a < b)};
    end

endmodule

module design_top;

    always @* begin

        y_d = 0;

        y_d = {31'b0, (a < b)};

        o_pc <= stall_q ? stalled_pc : prev_pc;

        a = (opcode_jal || opcode_auipc) ? i_pc : i_rs1;  // a can either be pc or rs1
        b = (opcode_rtype || opcode_branch)? i_rs2 : i_imm; // b can either be rs2 or imm

        if (alu_add) y_d = a + b;
        if (alu_sub) y_d = a - b;

        if (alu_slt || alu_sltu) begin
            //y_d = a + b;
            //y_d = {31'b0, (a < b)};
            if (alu_slt)
                y_d = (a[31] ^ b[31]) ? { 31'b0, a[31] } : y_d;
        end

        if (alu_xor) y_d = a ^ b;
        if (alu_or) y_d = a | b;
        if (alu_and) y_d = a & b;
        if (alu_sll) y_d = a << b[4:0];
        if (alu_srl) y_d = a >> b[4:0];

        if (alu_sra) y_d = $signed(a) >>> b[4:0];

        if (alu_eq || alu_neq) begin
            y_d = {31'b0, (a == b)};
            if (alu_neq) y_d = { 31'b0, !y_d[0] };
        end

        if (alu_ge || alu_geu) begin
            y_d = { 31'b0, (a >= b) };
            if (alu_ge) y_d = (a[31] ^ b[31]) ? { 31'b0, b[31] } : y_d;
        end
    end

endmodule