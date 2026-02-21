`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2026 03:57:54 PM
// Design Name: 
// Module Name: ALU_CU
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


module ALU_CU(
    input [1:0] ALUOp,       // ALU operation from main control
    input [5:0] funct,       // Function field from instruction
    output reg [3:0] ALU_Control  // ALU control signal
    );
    
    // ALU Control encoding:
    // 0000: AND
    // 0001: OR
    // 0010: ADD
    // 0110: SUB
    // 0111: SLT (Set Less Than)
    
    // ALUOp encoding:
    // 00: ADD (for load/store address calculation)
    // 01: SUB (for branch comparison)
    // 10: R-type (determined by funct field)
    // 11: SUB (for SUBI immediate)
    
    always @(*) begin
        case (ALUOp)
            2'b00: begin
                // ADD for load/store (SW)
                ALU_Control = 4'b0010;
            end
            
            2'b01: begin
                // SUB for branch (BEQ)
                ALU_Control = 4'b0110;
            end
            
            2'b10: begin
                // R-type - decode using funct field
                case (funct)
                    6'b100000: ALU_Control = 4'b0010;  // ADD
                    6'b100010: ALU_Control = 4'b0110;  // SUB
                    6'b100100: ALU_Control = 4'b0000;  // AND
                    6'b100101: ALU_Control = 4'b0001;  // OR
                    6'b101010: ALU_Control = 4'b0111;  // SLT
                    default:   ALU_Control = 4'b0000;  // Default to AND
                endcase
            end
            
            2'b11: begin
                // SUB for SUBI
                ALU_Control = 4'b0110;
            end
            
            default: begin
                ALU_Control = 4'b0000;
            end
        endcase
    end
    
endmodule
