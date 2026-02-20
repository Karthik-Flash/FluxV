`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/22/2024 04:58:57 AM
// Design Name: 
// Module Name: TEST_BENCH
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


module TEST_BENCH;

reg clk=1;
reg reset=1;
wire [31:0]wb_data;

initial forever #5 clk=~clk;

initial
#15 reset=0;



RISC_V_PROCESSOR dut(clk,reset,wb_data);
endmodule
