`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2026 03:48:16 PM
// Design Name: 
// Module Name: top_or_subi
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


module top_or_subi(
    input clk,
    input rst
    );
    wire [31:0] w [12:0];
    PC uut (w[0], clk, rst, w[1]);
    
endmodule
