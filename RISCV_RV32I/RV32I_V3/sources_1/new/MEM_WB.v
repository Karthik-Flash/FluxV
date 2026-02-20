`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2024 10:46:58 PM
// Design Name: 
// Module Name: MEM_WB
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


module MEM_WB(
input clk,
input reset,

input [4:0]mem_rd,
input [1:0]mem_wb_control,

input [31:0]mem_result,
input [31:0]read_data,

output reg [4:0] wb_rd,
output reg [1:0] wb_control,

output reg [31:0]wb_result,
output reg [31:0]wb_read_data
    );
    
    // ========================================================================
    // V3 POWER OPTIMIZATION: Pipeline Register Gating (Phase 1)
    // Target: -1 to -2% power reduction
    // ========================================================================
    // Detect NOP instructions and gate register updates
    wire instruction_active;
    assign instruction_active = |mem_wb_control;
    
    always @(posedge clk)
    begin
    
    if(reset)
    begin
        wb_rd<=0;     
        wb_control<=0;  
                 
        wb_result<=0;
        wb_read_data<=0;
    end
    else if(instruction_active)  // V3: Only update for valid instructions
    begin
        wb_rd<=mem_rd;     
        wb_control<=mem_wb_control;
                 
        wb_result<=mem_result;
        wb_read_data<=read_data;
    end
    // else: NOP/bubble - hold current values
    
    end
    
    
endmodule
