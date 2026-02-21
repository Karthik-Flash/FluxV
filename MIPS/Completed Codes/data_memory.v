`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: data_memory
// Description: Data memory for MIPS processor
//              Supports read and write operations
//////////////////////////////////////////////////////////////////////////////////

module data_memory(
    input clk,                    // Clock signal
    input [31:0] address,         // Memory address
    input [31:0] write_data,      // Data to write
    input MemWrite,               // Write enable
    input MemRead,                // Read enable
    output reg [31:0] read_data   // Data read from memory
    );
    
    // Memory array: 64 words of 32 bits each
    reg [31:0] memory [0:63];
    
    // Initialize memory with some test values
    integer i;
    initial begin
        for (i = 0; i < 64; i = i + 1) begin
            memory[i] = 32'd0;
        end
    end
    
    // Write operation (synchronous)
    always @(posedge clk) begin
        if (MemWrite) begin
            memory[address[7:2]] <= write_data;  // Word-aligned addressing
        end
    end
    
    // Read operation (combinational)
    always @(*) begin
        if (MemRead) begin
            read_data = memory[address[7:2]];  // Word-aligned addressing
        end else begin
            read_data = 32'd0;
        end
    end
    
endmodule
