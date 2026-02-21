`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/11/2026 03:12:54 PM
// Design Name: 
// Module Name: reg_file
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


module reg_file(
    input [4:0] read_1,
    input [4:0] read_2,
    input [4:0] write_reg, 
    input [31:0] write_data,
    output reg[31:0] read_dat_1,
    output reg [31:0] read_dat_2,
    input regwrite
    );
    reg [31:0] register [4:0];
    always @(*) begin
    if(~regwrite) begin
    case(read_1)
    5'd0: read_dat_1 <= register[0];
    5'd1:  read_dat_1 <= register[1];
    5'd2:  read_dat_1 <= register[2];
    5'd3:  read_dat_1 <= register[3];
    5'd4:  read_dat_1 <= register[4];
    endcase
    case(read_2) 
        5'd0:  read_dat_2 <= register[0];
        5'd1:  read_dat_2 <= register[1];
        5'd2:  read_dat_2 <= register[2];
        5'd3:  read_dat_2 <= register[3];
        5'd4:  read_dat_2 <= register[4];
    endcase
    end
    else begin
    case(write_reg) 
     5'd0: register[0] <= write_data;
     5'd1: register[1]<= write_data;
     5'd2:  register[2]<= write_data;
     5'd3:  register[3]<= write_data;
     5'd4:  register[4]<= write_data;
    endcase
    end
    end
        
endmodule
