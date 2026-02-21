`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/11/2026 03:22:47 PM
// Design Name: 
// Module Name: inst_mem
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
//parameter r0 = 5'd0, r1 = 5'd1, r2 = 5'd2, r3 = 5'd3, r4 = 5'd4, r5 = 5'd5;
// destination = r2 for or
//source for or = r0, r1
//parameter funct_or = 6'd0; //decide what this should be later
module inst_mem(
    input [31:0] read_address,
    output reg [31:0] inst_out
    );
    reg [31:0] inst [3:0];
    always @(*) begin
    inst[0] <= 32'b00000000010000010000000000000000; //{6'b000000, r2, r1, r0, 5'd0, funct_or }; 
    inst[1] <= 32'b00000100100000110000000000010100; //{6'd1, r4, r3, 16'd5};
    //inst[2] <= 32'b00001000101001100000000000000101;
    //inst[3] <= 32'b000011
    case (read_address) 
    32'd0: inst_out = inst[0];
    32'd4: inst_out = inst[1] ; //sub immediate 
    //32'd8: inst_out = inst[2] ;                         //sw
    //32'd12: inst_out = inst[3];                       //beq
    endcase 
    end
endmodule
