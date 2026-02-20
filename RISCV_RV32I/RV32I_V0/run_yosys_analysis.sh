#!/bin/bash
# Yosys Synthesis Analysis Script for RISC-V RV32I

echo "========================================"
echo "RISC-V RV32I - Yosys Synthesis Analysis"
echo "========================================"

# Create output directory
mkdir -p synthesis_reports

# Create Yosys synthesis script
cat > synthesis_reports/synth_script.ys << 'EOF'
# Read all design files
read_verilog RV32I_V0/sources_1/new/ALU.v
read_verilog RV32I_V0/sources_1/new/ALU_CONTROL.v
read_verilog RV32I_V0/sources_1/new/BRANCH_CONDITION_CHECKER.v
read_verilog RV32I_V0/sources_1/new/CONTROL_UNIT.v
read_verilog RV32I_V0/sources_1/new/DECODE.v
read_verilog RV32I_V0/sources_1/new/EXECUTE_STAGE.v
read_verilog RV32I_V0/sources_1/new/EX_MEM.v
read_verilog RV32I_V0/sources_1/new/FORWARDING_MUXES.v
read_verilog RV32I_V0/sources_1/new/FORWARDING_UNIT.v
read_verilog RV32I_V0/sources_1/new/ID_EX.v
read_verilog RV32I_V0/sources_1/new/IF_ID.v
read_verilog "RV32I_V0/sources_1/new/INSTRUCTION MEMORY.v"
read_verilog RV32I_V0/sources_1/new/INSTRUCTION_FETCH.v
read_verilog RV32I_V0/sources_1/new/jump_detector.v
read_verilog RV32I_V0/sources_1/new/MEM_STAGE.v
read_verilog RV32I_V0/sources_1/new/MEM_WB.v
read_verilog RV32I_V0/sources_1/new/MUX_3_TO_1.v
read_verilog RV32I_V0/sources_1/new/PC_MUX.v
read_verilog RV32I_V0/sources_1/new/REGFILE.v
read_verilog RV32I_V0/sources_1/new/RISC_V_PROCESSOR.v
read_verilog RV32I_V0/sources_1/new/SIGN_EXTEND.v
read_verilog "RV32I_V0/sources_1/new/STALLING UNIT.v"
read_verilog RV32I_V0/sources_1/new/stalling_mux.v
read_verilog RV32I_V0/sources_1/new/main.v

# Hierarchy check
hierarchy -check -top main

# High-level synthesis
proc; opt; fsm; opt; memory; opt

# Technology mapping to standard cells
techmap; opt

# ABC optimization for area and timing
abc -g AND,OR,XOR

# Generate statistics
tee -o synthesis_reports/synthesis_stats.txt stat

# Generate detailed cell statistics
tee -o synthesis_reports/cell_usage.txt stat

# Print timing analysis
tee -o synthesis_reports/timing_analysis.txt stat -top main

# Write synthesized netlist
write_verilog synthesis_reports/synthesized_netlist.v

# Write JSON for further analysis
write_json synthesis_reports/design.json

EOF

# Run Yosys synthesis
echo ""
echo "Running Yosys synthesis..."
yosys -s synthesis_reports/synth_script.ys 2>&1 | tee synthesis_reports/yosys_full_log.txt

# Extract and create summary report
echo ""
echo "Generating PPA Summary Report..."

cat > synthesis_reports/PPA_SUMMARY.txt << 'EOF'
================================================================================
        RISC-V RV32I - POWER, PERFORMANCE, AREA (PPA) SUMMARY REPORT
================================================================================
Generated: $(date)

EOF

# Extract key metrics from synthesis stats
echo "=== AREA METRICS ===" >> synthesis_reports/PPA_SUMMARY.txt
echo "" >> synthesis_reports/PPA_SUMMARY.txt

grep -A 50 "Printing statistics" synthesis_reports/synthesis_stats.txt | \
    grep -E "Number of cells|Chip area" >> synthesis_reports/PPA_SUMMARY.txt 2>/dev/null || \
    echo "See synthesis_stats.txt for detailed cell counts" >> synthesis_reports/PPA_SUMMARY.txt

echo "" >> synthesis_reports/PPA_SUMMARY.txt
echo "=== CELL BREAKDOWN ===" >> synthesis_reports/PPA_SUMMARY.txt
echo "" >> synthesis_reports/PPA_SUMMARY.txt

grep -E "\$_|cells" synthesis_reports/cell_usage.txt | head -30 >> synthesis_reports/PPA_SUMMARY.txt

echo "" >> synthesis_reports/PPA_SUMMARY.txt
echo "=== RESOURCE UTILIZATION ===" >> synthesis_reports/PPA_SUMMARY.txt
echo "" >> synthesis_reports/PPA_SUMMARY.txt

# Count different cell types
echo "Flip-Flops: $(grep -o '$_DFF_' synthesis_reports/synthesized_netlist.v | wc -l)" >> synthesis_reports/PPA_SUMMARY.txt
echo "Logic Gates: $(grep -E '\$_(AND|OR|XOR|NOT|NAND|NOR)_' synthesis_reports/synthesized_netlist.v | wc -l)" >> synthesis_reports/PPA_SUMMARY.txt
echo "Multiplexers: $(grep -E '\$_(MUX|PMUX)_' synthesis_reports/synthesized_netlist.v | wc -l)" >> synthesis_reports/PPA_SUMMARY.txt
echo "Total Wires: $(grep 'wire' synthesis_reports/synthesized_netlist.v | wc -l)" >> synthesis_reports/PPA_SUMMARY.txt

echo "" >> synthesis_reports/PPA_SUMMARY.txt
echo "=== PERFORMANCE ESTIMATE ===" >> synthesis_reports/PPA_SUMMARY.txt
echo "" >> synthesis_reports/PPA_SUMMARY.txt
echo "Note: Accurate timing requires specific technology library and constraints" >> synthesis_reports/PPA_SUMMARY.txt
echo "Critical Path Elements: See yosys_full_log.txt for detailed analysis" >> synthesis_reports/PPA_SUMMARY.txt

echo "" >> synthesis_reports/PPA_SUMMARY.txt
echo "=== POWER ESTIMATE ===" >> synthesis_reports/PPA_SUMMARY.txt
echo "" >> synthesis_reports/PPA_SUMMARY.txt
echo "Note: Accurate power analysis requires activity factors and technology library" >> synthesis_reports/PPA_SUMMARY.txt
echo "Dynamic Power: Depends on switching activity (use simulation VCD)" >> synthesis_reports/PPA_SUMMARY.txt
echo "Static Power: Depends on technology node and cell library" >> synthesis_reports/PPA_SUMMARY.txt
echo "" >> synthesis_reports/PPA_SUMMARY.txt
echo "For detailed power analysis, use:" >> synthesis_reports/PPA_SUMMARY.txt
echo "  - Yosys with specific tech library + power analysis tools" >> synthesis_reports/PPA_SUMMARY.txt
echo "  - VCD file from simulation for activity-based power estimation" >> synthesis_reports/PPA_SUMMARY.txt

echo "" >> synthesis_reports/PPA_SUMMARY.txt
echo "=== FILE LOCATIONS ===" >> synthesis_reports/PPA_SUMMARY.txt
echo "" >> synthesis_reports/PPA_SUMMARY.txt
echo "Detailed Statistics: synthesis_reports/synthesis_stats.txt" >> synthesis_reports/PPA_SUMMARY.txt
echo "Cell Usage: synthesis_reports/cell_usage.txt" >> synthesis_reports/PPA_SUMMARY.txt
echo "Full Yosys Log: synthesis_reports/yosys_full_log.txt" >> synthesis_reports/PPA_SUMMARY.txt
echo "Synthesized Netlist: synthesis_reports/synthesized_netlist.v" >> synthesis_reports/PPA_SUMMARY.txt
echo "Design JSON: synthesis_reports/design.json" >> synthesis_reports/PPA_SUMMARY.txt

echo "" >> synthesis_reports/PPA_SUMMARY.txt
echo "================================================================================" >> synthesis_reports/PPA_SUMMARY.txt

# Display the summary
cat synthesis_reports/PPA_SUMMARY.txt

echo ""
echo "========================================"
echo "Yosys Analysis Complete!"
echo "Reports saved in: synthesis_reports/"
echo "========================================"
