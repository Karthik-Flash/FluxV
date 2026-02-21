`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: ALU
// Description: 32-bit ALU for MIPS processor
//              Supports ADD, SUB, AND, OR, SLT operations
//////////////////////////////////////////////////////////////////////////////////

module ALU(
    input [31:0] A,           // First operand
    input [31:0] B,           // Second operand
    input [3:0] ALU_Control,  // ALU control signal
    output reg [31:0] ALU_Result,  // Result of operation
    output Zero               // Zero flag (high if result is zero)
    );
    
    // ALU Control encoding:
    // 0000: AND
    // 0001: OR
    // 0010: ADD
    // 0110: SUB
    // 0111: SLT (Set Less Than)
    
    always @(*) begin
        case (ALU_Control)
            4'b0000: ALU_Result = A & B;      // AND
            4'b0001: ALU_Result = A | B;      // OR
            4'b0010: ALU_Result = A + B;      // ADD
            4'b0110: ALU_Result = A - B;      // SUB
            4'b0111: ALU_Result = (A < B) ? 32'd1 : 32'd0;  // SLT
            default: ALU_Result = 32'd0;
        endcase
    end
    
    // Zero flag is high when ALU result is zero (used for BEQ)
    assign Zero = (ALU_Result == 32'd0);
    
endmodule
