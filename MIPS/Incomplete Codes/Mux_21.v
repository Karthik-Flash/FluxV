`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2026 03:46:20 PM
// Design Name: 
// Module Name: Mux_21
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


module Mux_21(
    input [1:0] in,
    input s,
    output reg o
    );
    always @(*) begin
    case (s)
    1'd0: o <= in[0];
    1'd1: o <= in[1];
    endcase
    end
endmodule
