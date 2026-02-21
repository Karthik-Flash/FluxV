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
    input A0,
    input A1,
    input [5:0] F,
    output reg [3:0] op
    );
    always @(*) begin
    case({A1, A0}) 
    2'b00: op = 4'b0010;
    2'b01: op = 4'b0110;
    default: begin
    case(F[3:0])
    4'b0000: op = 4'b0010;
    4'b0010: op = 4'b0110;
    4'b0100: op = 4'b0000;
    4'b0101: op = 4'b0001;
    4'b1010: op = 4'b0111;
    default: op = 4'b0000;
    endcase
    end
    endcase 
    end
endmodule
