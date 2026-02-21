`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: top_or_subi
// Description: Top-level single-cycle MIPS processor datapath
//              Supports: OR, SUBI, SW, BEQ instructions
//////////////////////////////////////////////////////////////////////////////////

module top_or_subi(
    input clk,
    input rst
    );
    
    // ===== Internal Wires =====
    
    // PC-related
    wire [31:0] pc_out;           // Current PC value
    wire [31:0] pc_in;            // Next PC value
    wire [31:0] pc_plus_4;        // PC + 4
    
    // Instruction and fields
    wire [31:0] instruction;      // Current instruction
    wire [5:0] opcode;            // Instruction opcode
    wire [4:0] rs;                // Source register 1
    wire [4:0] rt;                // Source register 2 (or destination for I-type)
    wire [4:0] rd;                // Destination register (R-type)
    wire [5:0] funct;             // Function field (R-type)
    wire [15:0] immediate;        // Immediate value (I-type)
    
    // Control signals
    wire RegDst;                  // Register destination select
    wire Branch;                  // Branch signal
    wire MemRead;                 // Memory read enable
    wire MemToReg;                // Memory to register select
    wire [1:0] ALUOp;             // ALU operation type
    wire MemWrite;                // Memory write enable
    wire ALUSrc;                  // ALU source select
    wire RegWrite;                // Register write enable
    
    // Register file
    wire [4:0] write_reg;         // Write register address (selected by RegDst)
    wire [31:0] read_data_1;      // Register read data 1 (rs)
    wire [31:0] read_data_2;      // Register read data 2 (rt)
    wire [31:0] write_data;       // Data to write to register
    
    // ALU-related
    wire [31:0] sign_extended;    // Sign-extended immediate
    wire [31:0] alu_input_b;      // Second ALU input (register or immediate)
    wire [3:0] alu_control;       // ALU control signal
    wire [31:0] alu_result;       // ALU result
    wire alu_zero;                // ALU zero flag
    
    // Branch-related
    wire [31:0] branch_offset;    // Sign-extended and shifted branch offset
    wire [31:0] branch_target;    // Branch target address
    wire pc_src;                  // PC source select (branch taken or not)
    
    // Memory
    wire [31:0] mem_read_data;    // Data read from memory
    
    
    // ===== Instruction Decode =====
    assign opcode = instruction[31:26];
    assign rs = instruction[25:21];
    assign rt = instruction[20:16];
    assign rd = instruction[15:11];
    assign funct = instruction[5:0];
    assign immediate = instruction[15:0];
    
    
    // ===== Program Counter =====
    PC program_counter (
        .in(pc_in),
        .clk(clk),
        .rst(rst),
        .out(pc_out)
    );
    
    
    // ===== PC + 4 Adder =====
    adder pc_adder (
        .in_1(pc_out),
        .in_2(32'd4),
        .out(pc_plus_4)
    );
    
    
    // ===== Instruction Memory =====
    inst_mem instruction_memory (
        .read_address(pc_out),
        .inst_out(instruction)
    );
    
    
    // ===== Main Control Unit =====
    CU control_unit (
        .opcode(opcode),
        .RegDst(RegDst),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemToReg(MemToReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite)
    );
    
    
    // ===== Register Destination Mux (rt vs rd) =====
    Mux5_2to1 reg_dst_mux (
        .in0(rt),           // I-type: destination is rt
        .in1(rd),           // R-type: destination is rd
        .select(RegDst),
        .out(write_reg)
    );
    
    
    // ===== Register File =====
    reg_file register_file (
        .clk(clk),
        .read_1(rs),
        .read_2(rt),
        .write_reg(write_reg),
        .write_data(write_data),
        .regwrite(RegWrite),
        .read_dat_1(read_data_1),
        .read_dat_2(read_data_2)
    );
    
    
    // ===== Sign Extend =====
    sign_extend sign_extender (
        .In(immediate),
        .Out(sign_extended)
    );
    
    
    // ===== ALU Source Mux (register vs immediate) =====
    Mux32_2to1 alu_src_mux (
        .in0(read_data_2),      // Use register value (rt)
        .in1(sign_extended),    // Use sign-extended immediate
        .select(ALUSrc),
        .out(alu_input_b)
    );
    
    
    // ===== ALU Control Unit =====
    ALU_CU alu_control_unit (
        .ALUOp(ALUOp),
        .funct(funct),
        .ALU_Control(alu_control)
    );
    
    
    // ===== ALU =====
    ALU alu (
        .A(read_data_1),
        .B(alu_input_b),
        .ALU_Control(alu_control),
        .ALU_Result(alu_result),
        .Zero(alu_zero)
    );
    
    
    // ===== Data Memory =====
    data_memory data_mem (
        .clk(clk),
        .address(alu_result),
        .write_data(read_data_2),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .read_data(mem_read_data)
    );
    
    
    // ===== Memory to Register Mux =====
    Mux32_2to1 mem_to_reg_mux (
        .in0(alu_result),       // Use ALU result
        .in1(mem_read_data),    // Use data from memory
        .select(MemToReg),
        .out(write_data)
    );
    
    
    // ===== Branch Logic =====
    // Shift left by 2 for word-aligned branch offset
    shift_left_2 branch_shifter (
        .in(sign_extended),
        .out(branch_offset)
    );
    
    // Calculate branch target: PC+4 + (offset << 2)
    adder branch_adder (
        .in_1(pc_plus_4),
        .in_2(branch_offset),
        .out(branch_target)
    );
    
    // Branch decision: take branch if (Branch AND Zero)
    assign pc_src = Branch & alu_zero;
    
    // PC Source Mux (PC+4 vs branch target)
    Mux32_2to1 pc_src_mux (
        .in0(pc_plus_4),        // Normal: PC + 4
        .in1(branch_target),    // Branch taken
        .select(pc_src),
        .out(pc_in)
    );
    
endmodule
