`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.02.2026 13:21:10
// Design Name: 
// Module Name: main
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


module main(
    input clk,
    input reset,
    output [31:0] wb_data  // Make wb_data an output port
);
  
// RISC-V Processor
    RISC_V_PROCESSOR cpu (
        .clk(clk),
        .reset(reset),
        .wb_data(wb_data)
    );

    // VIO removed - reset is now an input port


endmodule