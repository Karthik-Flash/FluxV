# RISC-V RV32I Analysis Scripts

This package contains scripts to analyze your RISC-V RV32I processor design using Yosys (synthesis) and Verilator (simulation) in WSL Ubuntu.

## Prerequisites

Make sure you have the following tools installed in your WSL Ubuntu environment:

```bash
# Update package list
sudo apt update

# Install Yosys (synthesis tool)
sudo apt install yosys

# Install Verilator (simulation tool)
sudo apt install verilator

# Install build essentials (for Verilator C++ compilation)
sudo apt install build-essential

# Optional: Install GTKWave (waveform viewer)
sudo apt install gtkwave
```

## Quick Start

### Option 1: Run Complete Analysis (Recommended)

This runs both Yosys synthesis and Verilator simulation, then generates a comprehensive report:

```bash
# Navigate to your project directory in WSL
cd /mnt/c/KarDRIVE/Projects/Cognichip/RISCV_RV32I/v0_baseline

# Make scripts executable
chmod +x run_complete_analysis.sh run_yosys_analysis.sh run_verilator_sim.sh

# Run complete analysis
./run_complete_analysis.sh
```

### Option 2: Run Individual Tools

**Run Yosys Synthesis Only:**
```bash
chmod +x run_yosys_analysis.sh
./run_yosys_analysis.sh
```

**Run Verilator Simulation Only:**
```bash
chmod +x run_verilator_sim.sh
./run_verilator_sim.sh
```

## Output Files

### Master Report
- **COMPLETE_ANALYSIS_REPORT.txt** - Comprehensive analysis combining all results

### Yosys Synthesis Reports (synthesis_reports/)
- **PPA_SUMMARY.txt** - Power, Performance, Area summary
- **synthesis_stats.txt** - Detailed synthesis statistics
- **cell_usage.txt** - Cell breakdown and utilization
- **yosys_full_log.txt** - Complete Yosys output log
- **synthesized_netlist.v** - Gate-level netlist
- **design.json** - Design in JSON format for further analysis

### Verilator Simulation Reports (verilator_sim/)
- **SIMULATION_SUMMARY.txt** - Simulation results summary
- **verilator_build.log** - Compilation and lint messages
- **simulation.log** - Runtime simulation output
- **waveform.vcd** - Signal waveform (view with GTKWave)
- **sim_main.cpp** - C++ testbench wrapper

## Viewing Results

### View Summary Reports
```bash
# Master report
cat COMPLETE_ANALYSIS_REPORT.txt

# Synthesis summary
cat synthesis_reports/PPA_SUMMARY.txt

# Simulation summary
cat verilator_sim/SIMULATION_SUMMARY.txt
```

### View Waveforms
```bash
# Using GTKWave
gtkwave verilator_sim/waveform.vcd

# Or from Windows, navigate to the VCD file
# File location: \\wsl$\Ubuntu\path\to\project\verilator_sim\waveform.vcd
```

## What Each Tool Analyzes

### Yosys Synthesis Analysis
- **Area**: Number and types of logic cells, gates, flip-flops, multiplexers
- **Performance**: Critical path analysis (requires technology library for accurate timing)
- **Power**: Static power estimates (requires technology library for accurate power)
- **Resources**: Total wires, combinational vs sequential logic breakdown

### Verilator Simulation
- **Functional Verification**: Tests design correctness
- **Lint Checking**: Identifies coding issues and warnings
- **Waveform Generation**: Creates VCD for signal visualization
- **Performance Metrics**: Simulation time, clock cycles executed

## Understanding the Reports

### Area Metrics (from Yosys)
- **Flip-Flops**: Sequential elements (pipeline registers, state)
- **Logic Gates**: Combinational logic (AND, OR, XOR, etc.)
- **Multiplexers**: Data path selection logic
- **Total Wires**: Interconnect count

### Performance Notes
- Yosys provides relative timing without a technology library
- For accurate timing: Use with FPGA toolchain (Vivado, Quartus) or ASIC tools
- Critical path typically through: ALU → Forwarding → Register File

### Power Notes
- Accurate power requires:
  - Specific technology library (FPGA or ASIC)
  - Activity factors from simulation (VCD file)
  - Power analysis tools (Vivado Power, PrimeTime PX, etc.)

## Troubleshooting

### "Command not found: yosys" or "verilator"
Install the tools:
```bash
sudo apt update
sudo apt install yosys verilator build-essential
```

### "Permission denied" when running scripts
Make scripts executable:
```bash
chmod +x *.sh
```

### Verilator compilation errors
Check the log:
```bash
cat verilator_sim/verilator_build.log
```

Common issues:
- Mixed Verilog/SystemVerilog syntax
- Undefined modules or signals
- Port connection mismatches

### File not found errors
Make sure you're in the correct directory:
```bash
pwd  # Should show: .../v0_baseline
ls RV32I_V0/sources_1/new/  # Should list all .v files
```

## Advanced Usage

### Modify Simulation Time
Edit `run_verilator_sim.sh`, change:
```cpp
#define MAX_SIM_TIME 100000  // Increase for longer simulation
```

### Change Synthesis Target
Edit `run_yosys_analysis.sh` to add your technology library:
```tcl
# In synth_script.ys, replace dummy_lib.lib with your actual library
abc -liberty /path/to/your/tech_lib.lib
```

### Add Performance Counters
Modify testbench to track:
- Instructions executed
- Pipeline stalls
- Branch mispredictions
- CPI (Cycles Per Instruction)

## Next Steps

1. **Review Reports**: Check COMPLETE_ANALYSIS_REPORT.txt
2. **Verify Simulation**: View waveforms in GTKWave
3. **Optimize Design**: Address synthesis warnings and optimize critical paths
4. **Run Benchmarks**: Add RISC-V test programs to testbench
5. **FPGA Implementation**: Use Vivado/Quartus for actual FPGA build

## Support

For issues with:
- **Scripts**: Check log files in synthesis_reports/ and verilator_sim/
- **Tools**: Refer to Yosys/Verilator documentation
- **Design**: Review Verilog files for syntax/semantic errors

---

**Generated for**: RISC-V RV32I Baseline Model  
**Tool Chain**: Yosys + Verilator  
**Target**: WSL Ubuntu on Windows 11
