`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: Mux32_2to1
// Description: 32-bit 2-to-1 multiplexer
//////////////////////////////////////////////////////////////////////////////////

module Mux32_2to1(
    input [31:0] in0,      // Input 0
    input [31:0] in1,      // Input 1
    input select,          // Select signal
    output reg [31:0] out  // Output
    );
    
    always @(*) begin
        case (select)
            1'b0: out = in0;
            1'b1: out = in1;
            default: out = 32'd0;
        endcase
    end
    
endmodule
