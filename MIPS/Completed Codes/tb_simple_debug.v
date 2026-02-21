`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Simple debug testbench - just run and observe
//////////////////////////////////////////////////////////////////////////////////

module tb_simple_debug;

    reg clk;
    reg rst;
    
    // Instantiate DUT
    top_or_subi dut (
        .clk(clk),
        .rst(rst)
    );
    
    // Clock generation - 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        $display("\n===== SIMPLE DEBUG TESTBENCH =====\n");
        
        // Reset
        rst = 1;
        #20;
        rst = 0;
        $display("[%0t] Reset released", $time);
        
        // Initialize registers
        #5;
        dut.register_file.register[1] = 32'h0000_00FF;
        dut.register_file.register[2] = 32'h0000_0F00;
        dut.register_file.register[5] = 32'h0000_0050;
        dut.register_file.register[6] = 32'hDEAD_BEEF;
        dut.register_file.register[7] = 32'h0000_0010;
        dut.register_file.register[8] = 32'h1234_5678;
        dut.register_file.register[9] = 32'h1234_5678;
        $display("[%0t] Registers initialized\n", $time);
        
        // Run for several cycles and observe
        repeat(10) begin
            @(posedge clk);
            #1;
            $display("========================================");
            $display("Time: %0t", $time);
            $display("PC = 0x%h", dut.pc_out);
            $display("Instruction = 0x%h", dut.instruction);
            $display("Opcode = 0x%h", dut.opcode);
            $display("Control Signals:");
            $display("  RegDst=%b ALUSrc=%b MemToReg=%b RegWrite=%b", 
                     dut.RegDst, dut.ALUSrc, dut.MemToReg, dut.RegWrite);
            $display("  MemRead=%b MemWrite=%b Branch=%b ALUOp=%b", 
                     dut.MemRead, dut.MemWrite, dut.Branch, dut.ALUOp);
            $display("Register File:");
            $display("  rs=%d rt=%d rd=%d write_reg=%d", 
                     dut.rs, dut.rt, dut.rd, dut.write_reg);
            $display("  read_data_1=0x%h read_data_2=0x%h", 
                     dut.read_data_1, dut.read_data_2);
            $display("ALU:");
            $display("  A=0x%h B=0x%h", dut.alu.A, dut.alu.B);
            $display("  ALU_Control=%b ALU_Result=0x%h Zero=%b", 
                     dut.alu_control, dut.alu_result, dut.alu_zero);
            $display("Write back:");
            $display("  write_data=0x%h", dut.write_data);
            $display("Registers r1-r9:");
            $display("  r1=0x%h r2=0x%h r3=0x%h", 
                     dut.register_file.register[1], 
                     dut.register_file.register[2],
                     dut.register_file.register[3]);
            $display("  r4=0x%h r5=0x%h r6=0x%h", 
                     dut.register_file.register[4],
                     dut.register_file.register[5],
                     dut.register_file.register[6]);
            $display("  r7=0x%h r8=0x%h r9=0x%h", 
                     dut.register_file.register[7],
                     dut.register_file.register[8],
                     dut.register_file.register[9]);
            $display("========================================\n");
        end
        
        $display("\nFinal Register Values:");
        $display("r3 (OR result) = 0x%h (expected 0x00000FFF)", dut.register_file.register[3]);
        $display("r4 (SUBI result) = 0x%h (expected 0x0000003B = %0d)", 
                 dut.register_file.register[4], dut.register_file.register[4]);
        
        $display("\nMemory location 5 (address 0x15):");
        $display("Memory[5] = 0x%h (expected 0xDEADBEEF)", dut.data_mem.memory[5]);
        
        $finish;
    end
    
    // Waveform dump
    initial begin
        $dumpfile("dump.fst");
        $dumpvars(0);
    end
    
endmodule
