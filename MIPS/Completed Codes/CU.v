`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2026 03:36:25 PM
// Design Name: 
// Module Name: CU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CU(
    input [5:0] opcode,        // Instruction opcode (bits [31:26])
    output reg RegDst,         // Register destination (0=rt, 1=rd)
    output reg Branch,         // Branch enable
    output reg MemRead,        // Memory read enable
    output reg MemToReg,       // Memory to register (0=ALU, 1=Mem)
    output reg [1:0] ALUOp,    // ALU operation code
    output reg MemWrite,       // Memory write enable
    output reg ALUSrc,         // ALU source (0=register, 1=immediate)
    output reg RegWrite        // Register write enable
    );
    
    // Instruction opcodes:
    // OR:   opcode = 6'b000000 (R-type, funct = 0x25)
    // SUBI: opcode = 6'b001001 (I-type, custom - similar to ADDI but subtract)
    // SW:   opcode = 6'b101011 (I-type, store word)
    // BEQ:  opcode = 6'b000100 (I-type, branch if equal)
    
    always @(*) begin
        // Default values (prevent latches)
        RegDst = 1'b0;
        ALUSrc = 1'b0;
        MemToReg = 1'b0;
        RegWrite = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        Branch = 1'b0;
        ALUOp = 2'b00;
        
        case (opcode)
            // R-type instructions (OR)
            6'b000000: begin
                RegDst = 1'b1;     // Destination is rd
                ALUSrc = 1'b0;     // Second operand from register
                MemToReg = 1'b0;   // Write ALU result to register
                RegWrite = 1'b1;   // Enable register write
                MemRead = 1'b0;    // No memory read
                MemWrite = 1'b0;   // No memory write
                Branch = 1'b0;     // Not a branch
                ALUOp = 2'b10;     // R-type ALU operation (use funct field)
            end
            
            // SUBI (Subtract Immediate) - Custom opcode 6'b001001 (9)
            6'b001001: begin
                RegDst = 1'b0;     // Destination is rt
                ALUSrc = 1'b1;     // Second operand is immediate
                MemToReg = 1'b0;   // Write ALU result to register
                RegWrite = 1'b1;   // Enable register write
                MemRead = 1'b0;    // No memory read
                MemWrite = 1'b0;   // No memory write
                Branch = 1'b0;     // Not a branch
                ALUOp = 2'b11;     // Subtract operation
            end
            
            // SW (Store Word) - opcode 6'b101011 (43)
            6'b101011: begin
                RegDst = 1'b0;     // Don't care (not writing to register)
                ALUSrc = 1'b1;     // Second operand is immediate (offset)
                MemToReg = 1'b0;   // Don't care (not writing to register)
                RegWrite = 1'b0;   // No register write
                MemRead = 1'b0;    // No memory read
                MemWrite = 1'b1;   // Enable memory write
                Branch = 1'b0;     // Not a branch
                ALUOp = 2'b00;     // ADD (for address calculation)
            end
            
            // BEQ (Branch if Equal) - opcode 6'b000100 (4)
            6'b000100: begin
                RegDst = 1'b0;     // Don't care (not writing to register)
                ALUSrc = 1'b0;     // Second operand from register
                MemToReg = 1'b0;   // Don't care (not writing to register)
                RegWrite = 1'b0;   // No register write
                MemRead = 1'b0;    // No memory read
                MemWrite = 1'b0;   // No memory write
                Branch = 1'b1;     // Enable branch
                ALUOp = 2'b01;     // Subtract (for comparison)
            end
            
            default: begin
                // All control signals remain at default (0)
            end
        endcase
    end
    
endmodule
