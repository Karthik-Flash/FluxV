`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2024 04:04:51 AM
// Design Name: 
// Module Name: REGFILE
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


module REGFILE(
input clk,
input reset,

input [4:0]s1,
input [4:0]s2,

input reg_write,
input [4:0]rd,
input [31:0]wb_data,

output [31:0]RS1,
output [31:0]RS2
    );
    
   integer i;
  
  (* ram_style = "distributed" *)  reg [31:0]GPP[31:0];  //general purpose registers
    
    assign RS1=GPP[s1];
    assign RS2=GPP[s2];
    
    // ========================================================================
    // V3 POWER OPTIMIZATION: Enhanced Write Gating (Phase 1)
    // Target: -2 to -3% power reduction
    // ========================================================================
    // Combine reg_write and rd!=0 check at the clock enable level
    // This prevents unnecessary register bank switching when writing to x0
    wire rf_write_enable;
    assign rf_write_enable = reg_write && (rd != 5'b0);
    
    always @(negedge clk)
    begin
        if(reset)
        begin
        for(i=0;i<32;i=i+1)
        begin
            GPP[i]<=0;
        end
        end
        else
        begin
            if(rf_write_enable)
            begin
                GPP[rd] = wb_data;
            end
        end
    end
    
endmodule
