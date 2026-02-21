`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: Mux5_2to1
// Description: 5-bit 2-to-1 multiplexer for register destination selection
//////////////////////////////////////////////////////////////////////////////////

module Mux5_2to1(
    input [4:0] in0,       // Input 0 (rt for I-type)
    input [4:0] in1,       // Input 1 (rd for R-type)
    input select,          // Select signal (RegDst)
    output reg [4:0] out   // Output
    );
    
    always @(*) begin
        case (select)
            1'b0: out = in0;
            1'b1: out = in1;
            default: out = 5'd0;
        endcase
    end
    
endmodule
