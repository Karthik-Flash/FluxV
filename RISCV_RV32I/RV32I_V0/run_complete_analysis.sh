#!/bin/bash
# Complete RISC-V RV32I Analysis: Yosys + Verilator

echo "================================================================================"
echo "        RISC-V RV32I COMPLETE ANALYSIS - YOSYS + VERILATOR"
echo "================================================================================"
echo ""
echo "This script will:"
echo "  1. Run Yosys synthesis for PPA (Power, Performance, Area) analysis"
echo "  2. Run Verilator for simulation and verification"
echo "  3. Generate comprehensive summary reports"
echo ""
echo "================================================================================"
echo ""

# Check if tools are installed
echo "Checking tool availability..."
echo ""

# Check Yosys
if command -v yosys &> /dev/null; then
    echo "✓ Yosys found: $(yosys -V | head -1)"
else
    echo "✗ Yosys NOT found. Please install: sudo apt install yosys"
    exit 1
fi

# Check Verilator
if command -v verilator &> /dev/null; then
    echo "✓ Verilator found: $(verilator --version | head -1)"
else
    echo "✗ Verilator NOT found. Please install: sudo apt install verilator"
    exit 1
fi

echo ""
echo "================================================================================"
echo ""

# Run Yosys Analysis
echo "PHASE 1: YOSYS SYNTHESIS ANALYSIS"
echo "================================================================================"
echo ""

bash run_yosys_analysis.sh

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Yosys analysis failed!"
    exit 1
fi

echo ""
echo "================================================================================"
echo ""

# Run Verilator Simulation
echo "PHASE 2: VERILATOR SIMULATION"
echo "================================================================================"
echo ""

bash run_verilator_sim.sh

if [ $? -ne 0 ]; then
    echo ""
    echo "WARNING: Verilator simulation had issues (check logs)"
fi

echo ""
echo "================================================================================"
echo ""

# Generate Combined Report
echo "PHASE 3: GENERATING COMBINED REPORT"
echo "================================================================================"
echo ""

cat > COMPLETE_ANALYSIS_REPORT.txt << 'EOF'
################################################################################
#                                                                              #
#         RISC-V RV32I BASELINE MODEL - COMPLETE ANALYSIS REPORT              #
#                                                                              #
################################################################################

Generated: $(date)
Design: RISC-V RV32I 5-Stage Pipelined Processor
Tool Chain: Yosys (Synthesis) + Verilator (Simulation)

################################################################################
# PART 1: SYNTHESIS RESULTS (YOSYS)
################################################################################

EOF

if [ -f "synthesis_reports/PPA_SUMMARY.txt" ]; then
    cat synthesis_reports/PPA_SUMMARY.txt >> COMPLETE_ANALYSIS_REPORT.txt
else
    echo "ERROR: Synthesis summary not found!" >> COMPLETE_ANALYSIS_REPORT.txt
fi

cat >> COMPLETE_ANALYSIS_REPORT.txt << 'EOF'

################################################################################
# PART 2: SIMULATION RESULTS (VERILATOR)
################################################################################

EOF

if [ -f "verilator_sim/SIMULATION_SUMMARY.txt" ]; then
    cat verilator_sim/SIMULATION_SUMMARY.txt >> COMPLETE_ANALYSIS_REPORT.txt
else
    echo "ERROR: Simulation summary not found!" >> COMPLETE_ANALYSIS_REPORT.txt
fi

cat >> COMPLETE_ANALYSIS_REPORT.txt << 'EOF'

################################################################################
# PART 3: DESIGN OVERVIEW
################################################################################

=== MODULE HIERARCHY ===

Top Module: main
  └─ RISC_V_PROCESSOR (cpu)
      ├─ INSTRUCTION_FETCH
      │   ├─ INSTRUCTION_MEMORY
      │   └─ PC_MUX
      ├─ IF_ID (Pipeline Register)
      ├─ DECODE
      │   ├─ CONTROL_UNIT
      │   ├─ REGFILE
      │   └─ SIGN_EXTEND
      ├─ ID_EX (Pipeline Register)
      ├─ EXECUTE_STAGE
      │   ├─ ALU
      │   ├─ ALU_CONTROL
      │   ├─ BRANCH_CONDITION_CHECKER
      │   ├─ FORWARDING_MUXES
      │   └─ jump_detector
      ├─ EX_MEM (Pipeline Register)
      ├─ MEM_STAGE (Data Memory)
      ├─ MEM_WB (Pipeline Register)
      ├─ FORWARDING_UNIT
      └─ STALLING_UNIT

=== DESIGN FEATURES ===

Architecture: RV32I Base Integer Instruction Set
Pipeline: 5-Stage (IF, ID, EX, MEM, WB)
Register File: 32 x 32-bit registers
Hazard Handling: 
  - Data hazards: Forwarding unit
  - Control hazards: Branch prediction/stalling
  - Structural hazards: Stalling unit

=== INSTRUCTION SET SUPPORT ===

- Arithmetic: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
- Immediate: ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU
- Load/Store: LW, SW, LH, SH, LB, SB, LHU, LBU
- Branch: BEQ, BNE, BLT, BGE, BLTU, BGEU
- Jump: JAL, JALR
- Upper Immediate: LUI, AUIPC

################################################################################
# PART 4: RECOMMENDATIONS
################################################################################

=== FOR FPGA IMPLEMENTATION ===

1. Clock Frequency: Start with 50 MHz, optimize based on timing analysis
2. Memory: Implement instruction/data memory with BRAM
3. I/O: Add peripherals (UART, GPIO) for external communication
4. Debug: Include debug port or JTAG interface
5. Verification: Test with RISC-V compliance test suite

=== FOR ASIC IMPLEMENTATION ===

1. Technology Library: Use with specific PDK for accurate PPA
2. Clock Tree: Implement proper clock tree synthesis
3. Power Optimization: Add power gating, clock gating
4. DFT: Add scan chains for manufacturing test
5. Timing Closure: Use STA tools for timing verification

=== NEXT STEPS ===

1. Run formal verification (e.g., with Yosys formal or SymbiYosys)
2. Add more comprehensive test programs
3. Measure actual CPI (Cycles Per Instruction) with benchmarks
4. Optimize critical paths identified in synthesis
5. Add performance counters for profiling

################################################################################
# END OF REPORT
################################################################################

REPORT FILES:
  - This report: COMPLETE_ANALYSIS_REPORT.txt
  - Yosys reports: synthesis_reports/
  - Verilator reports: verilator_sim/

View waveform: gtkwave verilator_sim/waveform.vcd

################################################################################
EOF

# Display the combined report
cat COMPLETE_ANALYSIS_REPORT.txt

echo ""
echo "================================================================================"
echo "                      ✓ COMPLETE ANALYSIS FINISHED"
echo "================================================================================"
echo ""
echo "Generated Reports:"
echo "  • Master Report: COMPLETE_ANALYSIS_REPORT.txt"
echo "  • Synthesis (Yosys): synthesis_reports/"
echo "  • Simulation (Verilator): verilator_sim/"
echo ""
echo "Quick View Commands:"
echo "  • cat COMPLETE_ANALYSIS_REPORT.txt"
echo "  • cat synthesis_reports/PPA_SUMMARY.txt"
echo "  • cat verilator_sim/SIMULATION_SUMMARY.txt"
echo "  • gtkwave verilator_sim/waveform.vcd"
echo ""
echo "================================================================================"
