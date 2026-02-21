`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: shift_left_2
// Description: Shift left by 2 bits for branch address calculation
//////////////////////////////////////////////////////////////////////////////////

module shift_left_2(
    input [31:0] in,       // Input value
    output [31:0] out      // Output shifted by 2 bits
    );
    
    // Shift left by 2 is equivalent to multiplying by 4
    // Used for word-aligned branch address calculation
    assign out = {in[29:0], 2'b00};
    
endmodule
