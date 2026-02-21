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
    input [5:0] Inst,
    output reg [1:0] ALU_C,
    output reg regwrite
    
    );
    always @(*) begin
    case(Inst) 
    6'd0: begin 
    regwrite <= 1;
    ALU_C <= 2'b01;
    end
    6'd1: begin     
    regwrite <= 1;
    ALU_C <= 2'b10;
    end
    endcase
    end
endmodule
