# Port 'unrecognized' removed - not in top module
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[31]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[30]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[29]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[28]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[27]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[26]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[25]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[24]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[23]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[22]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[21]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[20]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[19]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[18]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[17]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[16]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property PACKAGE_PIN Y9 [get_ports clk]

create_clock -period 13.333 -name clk -waveform {0.000 6.667} [get_ports clk]

################################################################################
# BRAM INFERENCE CONSTRAINTS - Force Block RAM Usage
################################################################################
# Added to force Vivado to use Block RAM instead of distributed RAM for memories
# Expected impact: -2,300 LUTs (~13%), +2 BRAM tiles, -27% power
# Target: Xilinx Zynq-7020 (xc7z020clg484-1)

# Force Data Memory (MEM_STAGE) to use Block RAM
# Size: 1024 bytes (8 Kbits) - Should fit in RAMB18E1 primitive
set_property RAM_STYLE BLOCK [get_cells -hierarchical -filter {NAME =~ "*MEM_STAGE*mem_reg*"}]

# Force Instruction Memory to use Block RAM (if size permits)
# Size: 20 bytes (160 bits) - May be too small for BRAM
# Vivado will use BRAM if possible, otherwise fall back to distributed RAM
set_property RAM_STYLE BLOCK [get_cells -hierarchical -filter {NAME =~ "*INSTRUCTION_MEMORY*instruction_memory_reg*"}]

# Keep Register File as Distributed RAM for single-cycle access
# Size: 32 registers x 32 bits - Critical for pipeline performance
# Must remain in LUTs for combinational read (no clock latency)
set_property RAM_STYLE DISTRIBUTED [get_cells -hierarchical -filter {NAME =~ "*REGFILE*GPP_reg*"}]

################################################################################
# ALTERNATIVE CONSTRAINTS (Try if above doesn't work)
################################################################################
# If the wildcards don't match, use these specific patterns:
# For MEM_STAGE data memory:
# set_property RAM_STYLE BLOCK [get_cells -hierarchical -filter {NAME =~ "*mr_s*mem_reg*"}]
# set_property RAM_STYLE BLOCK [get_cells -hierarchical -filter {NAME =~ "*mem_reg[*"}]

# For INSTRUCTION_MEMORY:
# set_property RAM_STYLE BLOCK [get_cells -hierarchical -filter {NAME =~ "*i_mem*instruction_memory_reg*"}]
# set_property RAM_STYLE BLOCK [get_cells -hierarchical -filter {NAME =~ "*instruction_memory_reg[*"}]

################################################################################
# VERIFICATION COMMANDS (Run in Vivado TCL Console after synthesis)
################################################################################
# After synthesis completes, run these commands to verify BRAM usage:
#
# 1. Check overall RAM utilization:
#    report_ram_utilization -detail
#
# 2. Check specific memory blocks:
#    report_utilization -hierarchical -cells {*MEM_STAGE*}
#    report_utilization -hierarchical -cells {*INSTRUCTION_MEMORY*}
#    report_utilization -hierarchical -cells {*REGFILE*}
#
# 3. Verify BRAM primitive usage:
#    get_cells -hierarchical -filter {PRIMITIVE_TYPE =~ BMEM.*.RAMB*}
#
# 4. Check synthesis messages for RAM inference:
#    Look for: "INFO: [Synth 8-3936] Found RAM"
#    Look for: "INFO: [Synth 8-3898] Implementing RAM using block memory"

################################################################################
# EXPECTED RESULTS
################################################################################
# Before optimization (v0):
#   - LUTs: 17,700
#   - BRAM: 0 tiles
#   - Power: 0.614 W
#
# After optimization (v1 with these constraints):
#   - LUTs: ~15,400 (-2,300, -13%)
#   - BRAM: 2 tiles
#   - Power: ~0.45 W (-27%)
#   - Performance: Same or better (timing maintained)

set_property -dict {RAM_STYLE BLOCK} [get_cells -hierarchical -filter {REF_NAME == MEM_STAGE}]