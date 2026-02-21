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
    input clk,                     // Clock for write operations
    input [4:0] read_1,            // Read register 1 address (rs)
    input [4:0] read_2,            // Read register 2 address (rt)
    input [4:0] write_reg,         // Write register address
    input [31:0] write_data,       // Data to write
    input regwrite,                // Write enable
    output [31:0] read_dat_1,      // Read data 1
    output [31:0] read_dat_2       // Read data 2
    );
    
    // Register file: 32 registers of 32 bits each
    reg [31:0] register [0:31];
    
    // Initialize registers
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            register[i] = 32'd0;
        end
    end
    
    // Write operation (synchronous on clock edge)
    always @(posedge clk) begin
        if (regwrite && (write_reg != 5'd0)) begin
            register[write_reg] <= write_data;
        end
    end
    
    // Read operations (combinational - always available)
    // Register 0 always returns 0 in MIPS
    assign read_dat_1 = (read_1 == 5'd0) ? 32'd0 : register[read_1];
    assign read_dat_2 = (read_2 == 5'd0) ? 32'd0 : register[read_2];
        
endmodule
