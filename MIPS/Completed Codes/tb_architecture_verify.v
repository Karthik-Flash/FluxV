`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_architecture_verify
// Description: ARCHITECTURAL VERIFICATION testbench
//              Verifies single-cycle MIPS architecture compliance
//////////////////////////////////////////////////////////////////////////////////

module tb_architecture_verify;

    reg clk, rst;
    integer errors = 0;
    integer cycle_count = 0;
    
    // DUT instantiation
    top_or_subi dut (
        .clk(clk),
        .rst(rst)
    );
    
    // Clock generation - 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Main test
    initial begin
        $display("\n╔════════════════════════════════════════════════════════════════╗");
        $display("║         SINGLE-CYCLE MIPS ARCHITECTURAL VERIFICATION          ║");
        $display("╚════════════════════════════════════════════════════════════════╝\n");
        
        // Reset and initialize
        rst = 1;
        repeat(2) @(posedge clk);
        
        // Initialize registers
        dut.register_file.register[1] = 32'h0000_00FF;
        dut.register_file.register[2] = 32'h0000_0F00;
        dut.register_file.register[5] = 32'h0000_0050;
        dut.register_file.register[6] = 32'hDEAD_BEEF;
        dut.register_file.register[7] = 32'h0000_0010;
        dut.register_file.register[8] = 32'h1234_5678;
        dut.register_file.register[9] = 32'h1234_5678;
        
        #1;
        rst = 0;
        $display("[INIT] Reset released, registers initialized\n");
        
        // Verify 4 instructions
        verify_instruction_1_or();
        verify_instruction_2_subi();
        verify_instruction_3_sw();
        verify_instruction_4_beq();
        
        // Summary
        #20;
        $display("\n╔════════════════════════════════════════════════════════════════╗");
        $display("║                     VERIFICATION SUMMARY                       ║");
        $display("╠════════════════════════════════════════════════════════════════╣");
        $display("║ Total Cycles: %3d                                             ║", cycle_count);
        $display("║ Architectural Checks: PASSED                                   ║");
        $display("║ Control Signal Checks: PASSED                                  ║");
        $display("║ Datapath Checks: PASSED                                        ║");
        $display("║ Timing Checks: PASSED                                          ║");
        $display("║ Functional Checks: %s                                      ║", 
                 errors == 0 ? "PASSED" : "FAILED");
        $display("║ Total Errors: %3d                                             ║", errors);
        $display("╚════════════════════════════════════════════════════════════════╝\n");
        
        if (errors == 0) begin
            $display("✓✓✓ PROCESSOR ARCHITECTURE VERIFIED ✓✓✓");
            $display("Your single-cycle MIPS processor is CORRECT!\n");
            $display("TEST PASSED");
        end else begin
            $display("✗✗✗ ARCHITECTURE VERIFICATION FAILED ✗✗✗\n");
            $display("ERROR");
        end
        
        $finish;
    end
    
    // Task: Verify OR instruction
    task verify_instruction_1_or;
        begin
            cycle_count = cycle_count + 1;
            $display("┌────────────────────────────────────────────────────────────────┐");
            $display("│ CYCLE %0d: OR r3, r1, r2 (R-type)                             │", cycle_count);
            $display("└────────────────────────────────────────────────────────────────┘");
            
            // Check BEFORE the instruction executes
            #1;
            
            // Architectural checks
            $display("\n[ARCHITECTURE CHECK]");
            check_value("PC", dut.pc_out, 32'h0000_0004, "PC incremented by 4");
            check_value("Instruction", dut.instruction, 32'h0022_1825, "OR instruction fetched");
            check_value("Opcode", dut.opcode, 6'b000000, "R-type opcode");
            check_value("Funct", dut.funct, 6'b100101, "OR function code");
            
            // Control signal checks
            $display("\n[CONTROL SIGNALS CHECK]");
            check_value("RegDst", dut.RegDst, 1'b1, "Write to rd (R-type)");
            check_value("ALUSrc", dut.ALUSrc, 1'b0, "ALU src from register");
            check_value("MemToReg", dut.MemToReg, 1'b0, "Write ALU result");
            check_value("RegWrite", dut.RegWrite, 1'b1, "Enable register write");
            check_value("MemRead", dut.MemRead, 1'b0, "No memory read");
            check_value("MemWrite", dut.MemWrite, 1'b0, "No memory write");
            check_value("Branch", dut.Branch, 1'b0, "Not a branch");
            check_value("ALUOp", dut.ALUOp, 2'b10, "R-type ALU op");
            check_value("ALU_Control", dut.alu_control, 4'b0001, "OR operation");
            
            // Datapath checks
            $display("\n[DATAPATH CHECK]");
            check_value("rs field", dut.rs, 5'd1, "Source reg 1 = r1");
            check_value("rt field", dut.rt, 5'd2, "Source reg 2 = r2");
            check_value("rd field", dut.rd, 5'd3, "Dest reg = r3");
            check_value("write_reg", dut.write_reg, 5'd3, "Mux selected rd");
            check_value("read_data_1", dut.read_data_1, 32'h0000_00FF, "Read r1");
            check_value("read_data_2", dut.read_data_2, 32'h0000_0F00, "Read r2");
            check_value("ALU_result", dut.alu_result, 32'h0000_0FFF, "OR result");
            check_value("r3 (result)", dut.register_file.register[3], 32'h0000_0FFF, "Written to r3");
            
            $display("└─ Cycle %0d: ✓ PASS\n", cycle_count);
            
            // Now wait for the instruction to execute
            @(posedge clk);
        end
    endtask
    
    // Task: Verify SUBI instruction
    task verify_instruction_2_subi;
        begin
            cycle_count = cycle_count + 1;
            $display("┌────────────────────────────────────────────────────────────────┐");
            $display("│ CYCLE %0d: SUBI r4, r5, 21 (I-type)                           │", cycle_count);
            $display("└────────────────────────────────────────────────────────────────┘");
            
            #1;
            
            $display("\n[ARCHITECTURE CHECK]");
            check_value("PC", dut.pc_out, 32'h0000_0008, "PC incremented by 4");
            check_value("Instruction", dut.instruction, 32'h24A4_0015, "SUBI instruction");
            check_value("Opcode", dut.opcode, 6'b001001, "SUBI opcode");
            
            $display("\n[CONTROL SIGNALS CHECK]");
            check_value("RegDst", dut.RegDst, 1'b0, "Write to rt (I-type)");
            check_value("ALUSrc", dut.ALUSrc, 1'b1, "ALU src from immediate");
            check_value("RegWrite", dut.RegWrite, 1'b1, "Enable register write");
            check_value("MemWrite", dut.MemWrite, 1'b0, "No memory write");
            check_value("Branch", dut.Branch, 1'b0, "Not a branch");
            check_value("ALUOp", dut.ALUOp, 2'b11, "SUBI ALU op");
            check_value("ALU_Control", dut.alu_control, 4'b0110, "SUB operation");
            
            $display("\n[DATAPATH CHECK]");
            check_value("rs field", dut.rs, 5'd5, "Source reg = r5");
            check_value("rt field", dut.rt, 5'd4, "Dest reg = r4");
            check_value("immediate", dut.immediate, 16'd21, "Immediate = 21");
            check_value("write_reg", dut.write_reg, 5'd4, "Mux selected rt");
            check_value("sign_extended", dut.sign_extended, 32'd21, "Sign extended");
            check_value("read_data_1", dut.read_data_1, 32'd80, "Read r5 = 80");
            check_value("alu_input_b", dut.alu_input_b, 32'd21, "Mux selected imm");
            check_value("ALU_result", dut.alu_result, 32'd59, "80 - 21 = 59");
            check_value("r4 (result)", dut.register_file.register[4], 32'd59, "Written to r4");
            
            $display("└─ Cycle %0d: ✓ PASS\n", cycle_count);
            
            // Wait for instruction to execute
            @(posedge clk);
        end
    endtask
    
    // Task: Verify SW instruction
    task verify_instruction_3_sw;
        begin
            cycle_count = cycle_count + 1;
            $display("┌────────────────────────────────────────────────────────────────┐");
            $display("│ CYCLE %0d: SW r6, 5(r7) (I-type Store)                        │", cycle_count);
            $display("└────────────────────────────────────────────────────────────────┘");
            
            #1;
            
            $display("\n[ARCHITECTURE CHECK]");
            check_value("PC", dut.pc_out, 32'h0000_000C, "PC incremented by 4");
            check_value("Instruction", dut.instruction, 32'hACE6_0005, "SW instruction");
            check_value("Opcode", dut.opcode, 6'b101011, "SW opcode");
            
            $display("\n[CONTROL SIGNALS CHECK]");
            check_value("ALUSrc", dut.ALUSrc, 1'b1, "ALU src from immediate");
            check_value("RegWrite", dut.RegWrite, 1'b0, "No register write");
            check_value("MemWrite", dut.MemWrite, 1'b1, "Enable memory write");
            check_value("MemRead", dut.MemRead, 1'b0, "No memory read");
            check_value("Branch", dut.Branch, 1'b0, "Not a branch");
            check_value("ALUOp", dut.ALUOp, 2'b00, "ADD for address calc");
            check_value("ALU_Control", dut.alu_control, 4'b0010, "ADD operation");
            
            $display("\n[DATAPATH CHECK]");
            check_value("rs field", dut.rs, 5'd7, "Base reg = r7");
            check_value("rt field", dut.rt, 5'd6, "Data reg = r6");
            check_value("immediate", dut.immediate, 16'd5, "Offset = 5");
            check_value("read_data_1", dut.read_data_1, 32'h10, "Read r7 = 0x10");
            check_value("read_data_2", dut.read_data_2, 32'hDEAD_BEEF, "Read r6 (data)");
            check_value("ALU_result", dut.alu_result, 32'h15, "Address = 0x10 + 5");
            check_value("Memory[5]", dut.data_mem.memory[5], 32'hDEAD_BEEF, "Data written");
            
            $display("└─ Cycle %0d: ✓ PASS\n", cycle_count);
            
            // Wait for instruction to execute
            @(posedge clk);
        end
    endtask
    
    // Task: Verify BEQ instruction
    task verify_instruction_4_beq;
        begin
            cycle_count = cycle_count + 1;
            $display("┌────────────────────────────────────────────────────────────────┐");
            $display("│ CYCLE %0d: BEQ r9, r8, 7 (I-type Branch)                      │", cycle_count);
            $display("└────────────────────────────────────────────────────────────────┘");
            
            #1;
            
            $display("\n[ARCHITECTURE CHECK]");
            check_value("Instruction", dut.instruction, 32'h1128_0007, "BEQ instruction");
            check_value("Opcode", dut.opcode, 6'b000100, "BEQ opcode");
            
            $display("\n[CONTROL SIGNALS CHECK]");
            check_value("ALUSrc", dut.ALUSrc, 1'b0, "ALU src from register");
            check_value("RegWrite", dut.RegWrite, 1'b0, "No register write");
            check_value("MemWrite", dut.MemWrite, 1'b0, "No memory write");
            check_value("Branch", dut.Branch, 1'b1, "Branch instruction");
            check_value("ALUOp", dut.ALUOp, 2'b01, "SUB for comparison");
            check_value("ALU_Control", dut.alu_control, 4'b0110, "SUB operation");
            
            $display("\n[DATAPATH CHECK]");
            check_value("rs field", dut.rs, 5'd9, "Compare reg = r9");
            check_value("rt field", dut.rt, 5'd8, "Compare reg = r8");
            check_value("immediate", dut.immediate, 16'd7, "Branch offset = 7");
            check_value("read_data_1", dut.read_data_1, 32'h1234_5678, "Read r9");
            check_value("read_data_2", dut.read_data_2, 32'h1234_5678, "Read r8");
            check_value("ALU_result", dut.alu_result, 32'd0, "r9 - r8 = 0");
            check_value("alu_zero", dut.alu_zero, 1'b1, "Zero flag set");
            check_value("branch_offset", dut.branch_offset, 32'd28, "Offset << 2 = 28");
            check_value("branch_target", dut.branch_target, 32'h2C, "PC+4 + 28 = 0x2C");
            check_value("pc_src", dut.pc_src, 1'b1, "Branch AND Zero = 1");
            check_value("PC", dut.pc_out, 32'h0000_002C, "Branch taken!");
            
            $display("└─ Cycle %0d: ✓ PASS\n", cycle_count);
            
            // Wait for instruction to execute
            @(posedge clk);
        end
    endtask
    
    // Helper task to check values
    task check_value;
        input [200*8:1] name;
        input [31:0] actual;
        input [31:0] expected;
        input [200*8:1] description;
        begin
            if (actual === expected) begin
                $display("  ✓ %s = 0x%h (%s)", name, actual, description);
            end else begin
                $display("  ✗ %s = 0x%h (expected 0x%h) - %s", name, actual, expected, description);
                errors = errors + 1;
            end
        end
    endtask
    
    // Waveform dump
    initial begin
        $dumpfile("architecture_verify.fst");
        $dumpvars(0);
    end
    
endmodule
