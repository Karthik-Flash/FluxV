#!/bin/bash
# Verilator Simulation Script for RISC-V RV32I

echo "========================================"
echo "RISC-V RV32I - Verilator Simulation"
echo "========================================"

# Create output directory
mkdir -p verilator_sim

# Check if testbench exists
if [ ! -f "RV32I_V0/sim_1/new/TEST_BENCH.v" ]; then
    echo "ERROR: Testbench not found at RV32I_V0/sim_1/new/TEST_BENCH.v"
    exit 1
fi

# Create a wrapper C++ file for Verilator
cat > verilator_sim/sim_main.cpp << 'EOF'
#include <verilated.h>
#include "VTEST_BENCH.h"
#include <iostream>
#include <verilated_vcd_c.h>

// Maximum simulation time
#define MAX_SIM_TIME 100000

int main(int argc, char** argv) {
    // Initialize Verilator
    Verilated::commandArgs(argc, argv);
    
    // Create instance of our module under test
    VTEST_BENCH* tb = new VTEST_BENCH;
    
    // Enable waveform tracing
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    tb->trace(tfp, 99);
    tfp->open("verilator_sim/waveform.vcd");
    
    // Simulation time counter
    vluint64_t sim_time = 0;
    vluint64_t clock_count = 0;
    
    std::cout << "Starting Verilator simulation..." << std::endl;
    std::cout << "Maximum simulation time: " << MAX_SIM_TIME << " cycles" << std::endl;
    
    // Run simulation
    while (sim_time < MAX_SIM_TIME && !Verilated::gotFinish()) {
        // Evaluate model
        tb->eval();
        
        // Dump waveform
        tfp->dump(sim_time);
        
        // Advance time
        sim_time++;
        
        // Count clock edges (assuming 10ns period)
        if (sim_time % 10 == 0) {
            clock_count++;
        }
        
        // Progress indicator
        if (sim_time % 10000 == 0) {
            std::cout << "Simulation time: " << sim_time << " Clock cycles: " << clock_count << std::endl;
        }
    }
    
    // Final stats
    std::cout << std::endl;
    std::cout << "=== SIMULATION COMPLETE ===" << std::endl;
    std::cout << "Total simulation time: " << sim_time << " time units" << std::endl;
    std::cout << "Total clock cycles: " << clock_count << std::endl;
    std::cout << "VCD waveform saved: verilator_sim/waveform.vcd" << std::endl;
    
    // Cleanup
    tfp->close();
    delete tfp;
    delete tb;
    
    return 0;
}
EOF

echo ""
echo "Step 1: Running Verilator (lint and compile)..."
echo ""

# Run Verilator with all design files
verilator --cc --exe --build \
    --trace \
    -Wall \
    -Wno-fatal \
    --no-timing \
    --top-module TEST_BENCH \
    RV32I_V0/sources_1/new/ALU.v \
    RV32I_V0/sources_1/new/ALU_CONTROL.v \
    RV32I_V0/sources_1/new/BRANCH_CONDITION_CHECKER.v \
    RV32I_V0/sources_1/new/CONTROL_UNIT.v \
    RV32I_V0/sources_1/new/DECODE.v \
    RV32I_V0/sources_1/new/EXECUTE_STAGE.v \
    RV32I_V0/sources_1/new/EX_MEM.v \
    RV32I_V0/sources_1/new/FORWARDING_MUXES.v \
    RV32I_V0/sources_1/new/FORWARDING_UNIT.v \
    RV32I_V0/sources_1/new/ID_EX.v \
    RV32I_V0/sources_1/new/IF_ID.v \
    "RV32I_V0/sources_1/new/INSTRUCTION MEMORY.v" \
    RV32I_V0/sources_1/new/INSTRUCTION_FETCH.v \
    RV32I_V0/sources_1/new/jump_detector.v \
    RV32I_V0/sources_1/new/MEM_STAGE.v \
    RV32I_V0/sources_1/new/MEM_WB.v \
    RV32I_V0/sources_1/new/MUX_3_TO_1.v \
    RV32I_V0/sources_1/new/PC_MUX.v \
    RV32I_V0/sources_1/new/REGFILE.v \
    RV32I_V0/sources_1/new/RISC_V_PROCESSOR.v \
    RV32I_V0/sources_1/new/SIGN_EXTEND.v \
    "RV32I_V0/sources_1/new/STALLING UNIT.v" \
    RV32I_V0/sources_1/new/stalling_mux.v \
    RV32I_V0/sources_1/new/main.v \
    RV32I_V0/sim_1/new/TEST_BENCH.v \
    verilator_sim/sim_main.cpp \
    2>&1 | tee verilator_sim/verilator_build.log

# Check if verilator succeeded
if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Verilator compilation failed!"
    echo "Check verilator_sim/verilator_build.log for details"
    exit 1
fi

echo ""
echo "Step 2: Running simulation executable..."
echo ""

# Run the simulation
if [ -f "./obj_dir/VTEST_BENCH" ]; then
    ./obj_dir/VTEST_BENCH 2>&1 | tee verilator_sim/simulation.log
else
    echo "ERROR: Simulation executable not found!"
    exit 1
fi

# Generate simulation summary report
echo ""
echo "Step 3: Generating Simulation Summary..."
echo ""

cat > verilator_sim/SIMULATION_SUMMARY.txt << 'EOF'
================================================================================
              RISC-V RV32I - VERILATOR SIMULATION SUMMARY
================================================================================
Generated: $(date)

EOF

echo "=== COMPILATION STATUS ===" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "" >> verilator_sim/SIMULATION_SUMMARY.txt

if grep -q "Error" verilator_sim/verilator_build.log; then
    echo "Status: FAILED - Check verilator_build.log" >> verilator_sim/SIMULATION_SUMMARY.txt
else
    echo "Status: SUCCESS" >> verilator_sim/SIMULATION_SUMMARY.txt
fi

echo "" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "=== LINT WARNINGS ===" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "" >> verilator_sim/SIMULATION_SUMMARY.txt

# Count warnings
WARNING_COUNT=$(grep -c "Warning" verilator_sim/verilator_build.log 2>/dev/null || echo "0")
echo "Total Warnings: $WARNING_COUNT" >> verilator_sim/SIMULATION_SUMMARY.txt

if [ $WARNING_COUNT -gt 0 ]; then
    echo "" >> verilator_sim/SIMULATION_SUMMARY.txt
    echo "Top Warnings (see verilator_build.log for all):" >> verilator_sim/SIMULATION_SUMMARY.txt
    grep "Warning" verilator_sim/verilator_build.log | head -10 >> verilator_sim/SIMULATION_SUMMARY.txt
fi

echo "" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "=== SIMULATION RESULTS ===" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "" >> verilator_sim/SIMULATION_SUMMARY.txt

if [ -f "verilator_sim/simulation.log" ]; then
    grep -E "simulation time|clock cycles|COMPLETE" verilator_sim/simulation.log >> verilator_sim/SIMULATION_SUMMARY.txt
else
    echo "Simulation log not found" >> verilator_sim/SIMULATION_SUMMARY.txt
fi

echo "" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "=== WAVEFORM ===" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "" >> verilator_sim/SIMULATION_SUMMARY.txt

if [ -f "verilator_sim/waveform.vcd" ]; then
    VCD_SIZE=$(ls -lh verilator_sim/waveform.vcd | awk '{print $5}')
    echo "VCD File: verilator_sim/waveform.vcd" >> verilator_sim/SIMULATION_SUMMARY.txt
    echo "VCD Size: $VCD_SIZE" >> verilator_sim/SIMULATION_SUMMARY.txt
    echo "" >> verilator_sim/SIMULATION_SUMMARY.txt
    echo "View waveform with: gtkwave verilator_sim/waveform.vcd" >> verilator_sim/SIMULATION_SUMMARY.txt
else
    echo "VCD waveform not generated" >> verilator_sim/SIMULATION_SUMMARY.txt
fi

echo "" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "=== PERFORMANCE METRICS ===" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "Note: Detailed performance analysis requires signal monitoring in testbench" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "  - Instructions executed" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "  - CPI (Cycles Per Instruction)" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "  - Pipeline stalls/hazards" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "  - Branch prediction accuracy" >> verilator_sim/SIMULATION_SUMMARY.txt

echo "" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "=== FILE LOCATIONS ===" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "Build Log: verilator_sim/verilator_build.log" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "Simulation Log: verilator_sim/simulation.log" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "Waveform: verilator_sim/waveform.vcd" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "C++ Source: verilator_sim/sim_main.cpp" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "Verilated Objects: obj_dir/" >> verilator_sim/SIMULATION_SUMMARY.txt

echo "" >> verilator_sim/SIMULATION_SUMMARY.txt
echo "================================================================================" >> verilator_sim/SIMULATION_SUMMARY.txt

# Display the summary
cat verilator_sim/SIMULATION_SUMMARY.txt

echo ""
echo "========================================"
echo "Verilator Simulation Complete!"
echo "Reports saved in: verilator_sim/"
echo "========================================"
