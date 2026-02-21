`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_top_or_subi
// Description: Comprehensive testbench for single-cycle MIPS processor
//              Tests: OR, SUBI, SW, BEQ instructions
//////////////////////////////////////////////////////////////////////////////////

module tb_top_or_subi;

    // ===== Testbench Signals =====
    reg clk;
    reg rst;
    
    // Test control
    integer test_num;
    integer errors;
    
    // ===== Instantiate DUT =====
    top_or_subi dut (
        .clk(clk),
        .rst(rst)
    );
    
    // ===== Clock Generation =====
    // 10ns period = 100MHz clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // ===== Test Initialization =====
    initial begin
        $display("========================================");
        $display("MIPS Single-Cycle Processor Testbench");
        $display("Testing: OR, SUBI, SW, BEQ");
        $display("========================================\n");
        
        // Initialize
        rst = 1;
        errors = 0;
        test_num = 0;
        
        // Hold reset for 2 clock cycles
        repeat(2) @(posedge clk);
        
        // Initialize registers WHILE IN RESET (before processor starts)
        dut.register_file.register[1] = 32'h0000_00FF;  // r1 = 0xFF
        dut.register_file.register[2] = 32'h0000_0F00;  // r2 = 0x0F00
        dut.register_file.register[5] = 32'h0000_0050;  // r5 = 80 decimal
        dut.register_file.register[6] = 32'hDEAD_BEEF;  // r6 = data to store
        dut.register_file.register[7] = 32'h0000_0010;  // r7 = base addr 16
        dut.register_file.register[8] = 32'h1234_5678;  // r8 = test value
        dut.register_file.register[9] = 32'h1234_5678;  // r9 = same as r8 (for BEQ)
        
        $display("Register File Initialized:");
        $display("  r1 = 0x%h", dut.register_file.register[1]);
        $display("  r2 = 0x%h", dut.register_file.register[2]);
        $display("  r5 = 0x%h (Decimal: %0d)", dut.register_file.register[5], dut.register_file.register[5]);
        $display("  r6 = 0x%h", dut.register_file.register[6]);
        $display("  r7 = 0x%h", dut.register_file.register[7]);
        $display("  r8 = 0x%h", dut.register_file.register[8]);
        $display("  r9 = 0x%h", dut.register_file.register[9]);
        $display("========================================\n");
        
        // Small delay
        #1;
        
        // NOW release reset - processor will start with initialized registers
        rst = 0;
        $display("[%0t] Reset released, starting execution\n", $time);
        
        // Test each instruction with proper timing
        test_or_instruction();
        test_subi_instruction();
        test_sw_instruction();
        test_beq_instruction();
        
        // Final results
        #20;
        $display("\n========================================");
        $display("TEST SUMMARY");
        $display("========================================");
        $display("Total Tests: %0d", test_num);
        $display("Errors: %0d", errors);
        
        if (errors == 0) begin
            $display("\n*** ALL TESTS PASSED ***");
            $display("TEST PASSED");
        end else begin
            $display("\n*** TESTS FAILED ***");
            $display("ERROR");
        end
        
        $display("========================================\n");
        $finish;
    end
    
    
    // ===== Test Task: OR Instruction =====
    task test_or_instruction;
        reg [31:0] expected_result;
        begin
            test_num = test_num + 1;
            $display("[Test %0d] Testing OR r3, r1, r2", test_num);
            $display("  Instruction at PC=0x00");
            
            expected_result = 32'h0000_0FFF;  // 0xFF | 0x0F00 = 0x0FFF
            
            $display("  Expected: r3 = r1 | r2 = 0x%h | 0x%h = 0x%h", 
                     32'h0000_00FF, 32'h0000_0F00, expected_result);
            
            // Wait for the instruction to execute
            @(posedge clk);
            #1;
            
            $display("  [Debug] PC = 0x%h, Instruction = 0x%h", dut.pc_out, dut.instruction);
            $display("  [Debug] RegDst=%b, ALUSrc=%b, RegWrite=%b, ALUOp=%b", 
                     dut.RegDst, dut.ALUSrc, dut.RegWrite, dut.ALUOp);
            $display("  [Debug] write_reg=%d, ALU_result=0x%h", dut.write_reg, dut.alu_result);
            
            // Check the result in r3
            if (dut.register_file.register[3] !== expected_result) begin
                $display("  ERROR: r3 expected 0x%h, got 0x%h", expected_result, dut.register_file.register[3]);
                errors = errors + 1;
            end else begin
                $display("  ✓ PASS: r3 = 0x%h", dut.register_file.register[3]);
            end
            
            // PC should now be at 4
            if (dut.pc_out !== 32'h0000_0004) begin
                $display("  ERROR: PC expected 0x00000004, got 0x%h", dut.pc_out);
                errors = errors + 1;
            end else begin
                $display("  ✓ PASS: PC = 0x%h", dut.pc_out);
            end
            
            $display("");
        end
    endtask
    
    
    // ===== Test Task: SUBI Instruction =====
    task test_subi_instruction;
        reg [31:0] expected_result;
        begin
            test_num = test_num + 1;
            $display("[Test %0d] Testing SUBI r4, r5, 21", test_num);
            $display("  Instruction at PC=0x04");
            
            expected_result = 32'h0000_003B;  // 80 - 21 = 59 = 0x3B
            
            $display("  Expected: r4 = r5 - 21 = %0d - 21 = %0d (0x%h)", 
                     80, 59, expected_result);
            
            // Wait for instruction to execute
            @(posedge clk);
            #1;
            
            $display("  [Debug] PC = 0x%h, Instruction = 0x%h", dut.pc_out, dut.instruction);
            $display("  [Debug] RegDst=%b, ALUSrc=%b, RegWrite=%b, ALUOp=%b", 
                     dut.RegDst, dut.ALUSrc, dut.RegWrite, dut.ALUOp);
            $display("  [Debug] sign_extended=0x%h, ALU_result=0x%h", dut.sign_extended, dut.alu_result);
            
            // Check result in r4
            if (dut.register_file.register[4] !== expected_result) begin
                $display("  ERROR: r4 expected 0x%h, got 0x%h", expected_result, dut.register_file.register[4]);
                errors = errors + 1;
            end else begin
                $display("  ✓ PASS: r4 = 0x%h (Decimal: %0d)", dut.register_file.register[4], dut.register_file.register[4]);
            end
            
            // Check PC incremented to 8
            if (dut.pc_out !== 32'h0000_0008) begin
                $display("  ERROR: PC expected 0x00000008, got 0x%h", dut.pc_out);
                errors = errors + 1;
            end else begin
                $display("  ✓ PASS: PC = 0x%h", dut.pc_out);
            end
            
            $display("");
        end
    endtask
    
    
    // ===== Test Task: SW Instruction =====
    task test_sw_instruction;
        reg [31:0] expected_addr;
        reg [31:0] expected_data;
        begin
            test_num = test_num + 1;
            $display("[Test %0d] Testing SW r6, 5(r7)", test_num);
            $display("  Instruction at PC=0x08");
            
            expected_addr = 32'h0000_0015;  // r7(16) + 5 = 21 = 0x15
            expected_data = 32'hDEAD_BEEF;
            
            $display("  Expected: Mem[r7+5] = Mem[0x%h] = r6 = 0x%h", expected_addr, expected_data);
            
            // Wait for instruction to execute
            @(posedge clk);
            #1;
            
            $display("  [Debug] PC = 0x%h, Instruction = 0x%h", dut.pc_out, dut.instruction);
            $display("  [Debug] MemWrite=%b, RegWrite=%b", dut.MemWrite, dut.RegWrite);
            $display("  [Debug] ALU_result (address) = 0x%h", dut.alu_result);
            $display("  [Debug] write_data (from r6) = 0x%h", dut.read_data_2);
            
            // Check memory contents (word-aligned addressing: address[7:2] = 0x15[7:2] = 5)
            if (dut.data_mem.memory[expected_addr[7:2]] !== expected_data) begin
                $display("  ERROR: Memory[%0d] expected 0x%h, got 0x%h", 
                         expected_addr[7:2], expected_data, dut.data_mem.memory[expected_addr[7:2]]);
                errors = errors + 1;
            end else begin
                $display("  ✓ PASS: Memory[0x%h] (index %0d) = 0x%h", 
                         expected_addr, expected_addr[7:2], dut.data_mem.memory[expected_addr[7:2]]);
            end
            
            // Check PC incremented to 12
            if (dut.pc_out !== 32'h0000_000C) begin
                $display("  ERROR: PC expected 0x0000000C, got 0x%h", dut.pc_out);
                errors = errors + 1;
            end else begin
                $display("  ✓ PASS: PC = 0x%h", dut.pc_out);
            end
            
            $display("");
        end
    endtask
    
    
    // ===== Test Task: BEQ Instruction =====
    task test_beq_instruction;
        reg [31:0] expected_branch_target;
        reg expected_branch_taken;
        begin
            test_num = test_num + 1;
            $display("[Test %0d] Testing BEQ r9, r8, 7", test_num);
            $display("  Instruction at PC=0x0C");
            $display("  r8 = 0x%h, r9 = 0x%h", 32'h1234_5678, 32'h1234_5678);
            
            // Branch offset: 7 << 2 = 28 = 0x1C
            // Branch target: PC+4 + offset = 0x10 + 0x1C = 0x2C
            expected_branch_target = 32'h0000_002C;
            expected_branch_taken = 1'b1;  // r8 == r9
            
            $display("  Expected branch target: 0x%h", expected_branch_target);
            $display("  Expected branch taken: YES (r8 == r9)");
            
            // Wait for instruction to execute
            @(posedge clk);
            #1;
            
            $display("  [Debug] PC = 0x%h, Instruction = 0x%h", dut.pc_out, dut.instruction);
            $display("  [Debug] Branch=%b, ALU_zero=%b, pc_src=%b", dut.Branch, dut.alu_zero, dut.pc_src);
            $display("  [Debug] branch_offset=0x%h, branch_target=0x%h", dut.branch_offset, dut.branch_target);
            $display("  [Debug] pc_plus_4=0x%h", dut.pc_plus_4);
            
            // Check PC
            if (expected_branch_taken) begin
                if (dut.pc_out !== expected_branch_target) begin
                    $display("  ERROR: PC expected 0x%h (branch taken), got 0x%h", expected_branch_target, dut.pc_out);
                    errors = errors + 1;
                end else begin
                    $display("  ✓ PASS: Branch taken, PC = 0x%h", dut.pc_out);
                end
            end else begin
                if (dut.pc_out !== 32'h0000_0010) begin
                    $display("  ERROR: PC expected 0x00000010 (branch not taken), got 0x%h", dut.pc_out);
                    errors = errors + 1;
                end else begin
                    $display("  ✓ PASS: Branch not taken, PC = 0x%h", dut.pc_out);
                end
            end
            
            $display("");
        end
    endtask
    
    
    // ===== Waveform Dump =====
    initial begin
        $dumpfile("dump.fst");
        $dumpvars(0);
    end
    
endmodule
