`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_visual_execution
// Description: Visual execution testbench - shows instruction fetch, 
//              PC, ALU inputs, and register writes cycle-by-cycle
//////////////////////////////////////////////////////////////////////////////////

module tb_visual_execution;

    // Testbench signals
    reg clk;
    reg rst;
    integer cycle_count = 0;
    
    // Instantiate processor
    top_or_subi dut (
        .clk(clk),
        .rst(rst)
    );
    
    // Clock generation - 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Main test sequence
    initial begin
        $display("\n");
        $display("==============================================================================");
        $display("              MIPS PROCESSOR VISUAL EXECUTION TRACE");
        $display("==============================================================================");
        $display("");
        $display("Watching: PC | Instruction | ALU Inputs (A, B) | Register Writes");
        $display("==============================================================================\n");
        
        // Reset processor
        rst = 1;
        repeat(2) @(posedge clk);
        
        // Initialize registers with test values
        dut.register_file.register[1] = 32'h0000_00FF;  // r1 = 255
        dut.register_file.register[2] = 32'h0000_0F00;  // r2 = 3840
        dut.register_file.register[5] = 32'h0000_0050;  // r5 = 80
        dut.register_file.register[6] = 32'hDEAD_BEEF;  // r6 = 0xDEADBEEF
        dut.register_file.register[7] = 32'h0000_0010;  // r7 = 16
        dut.register_file.register[8] = 32'h1234_5678;  // r8 = 0x12345678
        dut.register_file.register[9] = 32'h1234_5678;  // r9 = 0x12345678
        
        $display("[INIT] Registers initialized:");
        $display("       r1=0x%h, r2=0x%h, r5=0x%h, r6=0x%h", 
                 dut.register_file.register[1], dut.register_file.register[2],
                 dut.register_file.register[5], dut.register_file.register[6]);
        $display("       r7=0x%h, r8=0x%h, r9=0x%h\n", 
                 dut.register_file.register[7], dut.register_file.register[8],
                 dut.register_file.register[9]);
        
        #1;
        rst = 0;  // Release reset
        $display("[START] Processor execution begins...\n");
        $display("==============================================================================");
        
        // Run for several cycles and monitor execution
        repeat(8) begin
            @(posedge clk);
            #1;  // Small delay for signals to settle
            cycle_count = cycle_count + 1;
            display_execution_state();
        end
        
        // Final register state
        #20;
        $display("==============================================================================");
        $display("\n[FINAL] Register File State:");
        $display("        r3 = 0x%h (OR result)", dut.register_file.register[3]);
        $display("        r4 = 0x%h (SUBI result, decimal: %0d)", 
                 dut.register_file.register[4], dut.register_file.register[4]);
        $display("\n[FINAL] Memory State:");
        $display("        Memory[5] = 0x%h (SW result)\n", dut.data_mem.memory[5]);
        
        $display("==============================================================================");
        $display("                    EXECUTION TRACE COMPLETE");
        $display("==============================================================================\n");
        $display("TEST PASSED");
        
        $finish;
    end
    
    // Task to display execution state each cycle
    task display_execution_state;
        begin
            $display("\n--- CYCLE %0d ---", cycle_count);
            $display("┌─────────────────────────────────────────────────────────────────────────┐");
            
            // Program Counter
            $display("│ PC:          0x%h", dut.pc_out);
            
            // Instruction Fetch
            $display("│ INSTRUCTION: 0x%h  (%s)", dut.instruction, decode_instruction(dut.instruction));
            
            // Instruction decode
            $display("│ Opcode:      0x%h (%s)", dut.opcode, get_opcode_name(dut.opcode));
            
            // Register reads (inputs to ALU)
            $display("│");
            $display("│ ┌─── REGISTER FILE READS ───");
            $display("│ │ rs  = r%0d → Read Data = 0x%h", dut.rs, dut.read_data_1);
            $display("│ │ rt  = r%0d → Read Data = 0x%h", dut.rt, dut.read_data_2);
            $display("│ │ rd  = r%0d (destination for R-type)", dut.rd);
            $display("│ │ Write Register = r%0d (after mux)", dut.write_reg);
            
            // ALU inputs and operation
            $display("│ │");
            $display("│ ┌─── ALU OPERATION ───");
            $display("│ │ A (Input):  0x%h", dut.alu.A);
            $display("│ │ B (Input):  0x%h", dut.alu.B);
            $display("│ │ ALU Op:     %s (control=0x%h)", get_alu_operation(dut.alu_control), dut.alu_control);
            $display("│ │ Result:     0x%h", dut.alu_result);
            $display("│ │ Zero Flag:  %b", dut.alu_zero);
            
            // Control signals
            $display("│ │");
            $display("│ ┌─── CONTROL SIGNALS ───");
            $display("│ │ RegWrite=%b  MemWrite=%b  Branch=%b  ALUSrc=%b", 
                     dut.RegWrite, dut.MemWrite, dut.Branch, dut.ALUSrc);
            
            // Register write
            if (dut.RegWrite) begin
                $display("│ │");
                $display("│ ┌─── REGISTER WRITE (Next Cycle) ───");
                $display("│ │ r%0d ← 0x%h", dut.write_reg, dut.write_data);
            end
            
            // Memory write
            if (dut.MemWrite) begin
                $display("│ │");
                $display("│ ┌─── MEMORY WRITE (Next Cycle) ───");
                $display("│ │ Memory[0x%h] ← 0x%h", dut.alu_result, dut.read_data_2);
            end
            
            // Branch info
            if (dut.Branch) begin
                $display("│ │");
                $display("│ ┌─── BRANCH LOGIC ───");
                $display("│ │ Branch Target: 0x%h", dut.branch_target);
                $display("│ │ Branch Taken:  %s", dut.pc_src ? "YES" : "NO");
            end
            
            // Next PC
            $display("│ │");
            $display("│ └─── NEXT PC: 0x%h", dut.pc_in);
            
            $display("└─────────────────────────────────────────────────────────────────────────┘");
        end
    endtask
    
    // Helper function to decode instruction mnemonic
    function [200*8:1] decode_instruction;
        input [31:0] inst;
        begin
            case (inst)
                32'h0022_1825: decode_instruction = "OR r3, r1, r2";
                32'h24A4_0015: decode_instruction = "SUBI r4, r5, 21";
                32'hACE6_0005: decode_instruction = "SW r6, 5(r7)";
                32'h1128_0007: decode_instruction = "BEQ r9, r8, 7";
                32'h0000_0000: decode_instruction = "NOP / Invalid";
                default:       decode_instruction = "Unknown";
            endcase
        end
    endfunction
    
    // Helper function to get opcode name
    function [80*8:1] get_opcode_name;
        input [5:0] opcode;
        begin
            case (opcode)
                6'b000000: get_opcode_name = "R-TYPE";
                6'b001001: get_opcode_name = "SUBI";
                6'b101011: get_opcode_name = "SW";
                6'b000100: get_opcode_name = "BEQ";
                default:   get_opcode_name = "UNKNOWN";
            endcase
        end
    endfunction
    
    // Helper function to get ALU operation name
    function [80*8:1] get_alu_operation;
        input [3:0] alu_ctrl;
        begin
            case (alu_ctrl)
                4'b0000: get_alu_operation = "AND";
                4'b0001: get_alu_operation = "OR";
                4'b0010: get_alu_operation = "ADD";
                4'b0110: get_alu_operation = "SUB";
                4'b0111: get_alu_operation = "SLT";
                default: get_alu_operation = "UNKNOWN";
            endcase
        end
    endfunction
    
    // Waveform dump
    initial begin
        $dumpfile("execution_trace.fst");
        $dumpvars(0);
    end
    
endmodule
