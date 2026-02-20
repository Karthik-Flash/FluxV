`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2024 05:09:52 AM
// Design Name: 
// Module Name: INSTRUCTION MEMORY
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


module INSTRUCTION_MEMORY(
input clk, //clk is taken as input cause asynchrous reset is reported to cause problems
input reset,
input [31:0]pc,
output [31:0]instruction
    );
    
(* ram_style = "block" *) reg [7:0]instruction_memory[2047:0]; // 2KB

integer i=0;

assign instruction={instruction_memory[pc+3],instruction_memory[pc+2],instruction_memory[pc+1],instruction_memory[pc]} ; //big endian



//initialize memory using reset --helpful in fpga implementation
always @(posedge clk)
begin
if(reset)
begin
instruction_memory[3]<=8'h02;instruction_memory[2]<=8'h80;instruction_memory[1]<=8'h02;instruction_memory[0]<=8'h13;
instruction_memory[7]<=8'h00;instruction_memory[6]<=8'h40;instruction_memory[5]<=8'h80;instruction_memory[4]<=8'h93;
instruction_memory[11]<=8'h00;instruction_memory[10]<=8'h00;instruction_memory[9]<=8'ha1;instruction_memory[8]<=8'h83;
instruction_memory[15]<=8'h00;instruction_memory[14]<=8'h30;instruction_memory[13]<=8'ha2;instruction_memory[12]<=8'h23;
instruction_memory[19]<=8'hfe;instruction_memory[18]<=8'h40;instruction_memory[17]<=8'h9a;instruction_memory[16]<=8'he3;



end
end        
endmodule

//addi x4,x0,40
//loop:addi x1,x1,4
//lw x3,0(x1)
//sw x3,4(x1)
//bne x1,x4,loop
