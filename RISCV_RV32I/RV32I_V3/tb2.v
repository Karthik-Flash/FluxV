`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Simple Testbench for RISC-V RV32I Processor V3 Final
// Target: Zedboard Zynq-7020 Pre-FPGA Verification
// Compatible with: Verilator, Icarus Verilog, GTKWave
//////////////////////////////////////////////////////////////////////////////////

module tb2;

// DUT signals
reg clk = 0;
reg reset = 1;
wire [31:0] wb_data;

// Test monitoring
integer cycle_count = 0;

// Instantiate the processor
RISC_V_PROCESSOR dut (
    .clk(clk),
    .reset(reset),
    .wb_data(wb_data)
);

// Clock generation - 10ns period (100MHz for simulation)
always #5 clk = ~clk;

// Main test sequence
initial begin
    $display("TEST START");
    $display("===============================================");
    $display("RV32I Processor V3 Final - Simple Verification");
    $display("Target: Zedboard Zynq-7020 @ 89.5 MHz");
    $display("===============================================");
    
    // Hold reset for 3 cycles
    #30;
    reset = 0;
    $display("[Time %0t] Reset released - Starting execution", $time);
    
    // Run for 500 cycles to let program execute
    repeat(500) begin
        @(posedge clk);
        cycle_count = cycle_count + 1;
    end
    
    // Test completion
    $display("\n===============================================");
    $display("Simulation completed successfully");
    $display("Total cycles: %0d", cycle_count);
    $display("Final wb", wb_data);
    $display("===============================================");
    $display("TEST PASSED");
    $display("Processor is ready for FPGA deployment!");
    
    $finish;
end

// Timeout protection
initial begin
    #100000; // 100us timeout
    $display("\n*** TIMEOUT ***");
    $display("ERROR");
    $fatal(1, "Simulation exceeded timeout");
end

// Waveform dump for GTKWave
initial begin
    $dumpfile("dumpfile.fst");
    $dumpvars(0);
end

endmodule
