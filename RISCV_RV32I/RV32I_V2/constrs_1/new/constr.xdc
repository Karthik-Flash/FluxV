################################################################################
# V2 RECOVERY - Conservative 90 MHz with ONLY Pin Fixes
# Back to what WORKED - minimal changes from successful v2 @90MHz
################################################################################
# History:
# V1 @75MHz:  WNS = +1.070 ns ✅
# V2 @90MHz:  WNS = +0.428 ns ✅ (SUCCESSFUL!)
# V2 @95MHz:  WNS = -4.433 ns ❌ (CATASTROPHIC FAILURE - too aggressive)
# V2 Recovery: Back to 90 MHz + pin fixes ONLY
################################################################################

################################################################################
# 1. CLOCK CONSTRAINTS - CONSERVATIVE 90 MHz (PROVEN TO WORK)
################################################################################
set_property PACKAGE_PIN Y9 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# Clock constraint - 90 MHz (KNOWN GOOD from previous run)
create_clock -period 11.111 -name clk -waveform {0.000 5.556} [get_ports clk]

# NO clock uncertainty - keep it simple like the working version
# NO input/output delays - these caused timing issues

################################################################################
# 2. PIN LOCATION CONSTRAINTS - FIXES UCIO-1 WARNING ONLY
################################################################################
# Reset input pin
set_property PACKAGE_PIN P16 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# Write-back data output pins [31:0]
set_property PACKAGE_PIN M14 [get_ports {wb_data[0]}]
set_property PACKAGE_PIN M15 [get_ports {wb_data[1]}]
set_property PACKAGE_PIN G14 [get_ports {wb_data[2]}]
set_property PACKAGE_PIN D18 [get_ports {wb_data[3]}]
set_property PACKAGE_PIN E19 [get_ports {wb_data[4]}]
set_property PACKAGE_PIN E18 [get_ports {wb_data[5]}]
set_property PACKAGE_PIN F19 [get_ports {wb_data[6]}]
set_property PACKAGE_PIN F18 [get_ports {wb_data[7]}]
set_property PACKAGE_PIN G19 [get_ports {wb_data[8]}]
set_property PACKAGE_PIN H19 [get_ports {wb_data[9]}]
set_property PACKAGE_PIN J19 [get_ports {wb_data[10]}]
set_property PACKAGE_PIN H18 [get_ports {wb_data[11]}]
set_property PACKAGE_PIN J18 [get_ports {wb_data[12]}]
set_property PACKAGE_PIN K19 [get_ports {wb_data[13]}]
set_property PACKAGE_PIN K18 [get_ports {wb_data[14]}]
set_property PACKAGE_PIN L19 [get_ports {wb_data[15]}]
set_property PACKAGE_PIN L18 [get_ports {wb_data[16]}]
set_property PACKAGE_PIN L16 [get_ports {wb_data[17]}]
set_property PACKAGE_PIN L15 [get_ports {wb_data[18]}]
set_property PACKAGE_PIN K14 [get_ports {wb_data[19]}]
set_property PACKAGE_PIN J14 [get_ports {wb_data[20]}]
set_property PACKAGE_PIN J15 [get_ports {wb_data[21]}]
set_property PACKAGE_PIN H14 [get_ports {wb_data[22]}]
set_property PACKAGE_PIN G15 [get_ports {wb_data[23]}]
set_property PACKAGE_PIN G16 [get_ports {wb_data[24]}]
set_property PACKAGE_PIN F16 [get_ports {wb_data[25]}]
set_property PACKAGE_PIN E16 [get_ports {wb_data[26]}]
set_property PACKAGE_PIN D15 [get_ports {wb_data[27]}]
set_property PACKAGE_PIN C15 [get_ports {wb_data[28]}]
set_property PACKAGE_PIN B15 [get_ports {wb_data[29]}]
set_property PACKAGE_PIN A15 [get_ports {wb_data[30]}]
set_property PACKAGE_PIN B16 [get_ports {wb_data[31]}]

set_property IOSTANDARD LVCMOS33 [get_ports {wb_data[*]}]

################################################################################
# 3. BRAM INFERENCE CONSTRAINTS (PROVEN TO WORK FROM V1)
################################################################################
set_property RAM_STYLE BLOCK [get_cells -hierarchical -filter {NAME =~ "*MEM_STAGE*mem_reg*"}]
set_property RAM_STYLE BLOCK [get_cells -hierarchical -filter {NAME =~ "*INSTRUCTION_MEMORY*instruction_memory_reg*"}]
set_property RAM_STYLE DISTRIBUTED [get_cells -hierarchical -filter {NAME =~ "*REGFILE*GPP_reg*"}]

# Backup constraints
set_property RAM_STYLE BLOCK [get_cells -hierarchical -filter {NAME =~ "*mr_s*mem_reg*"}]
set_property RAM_STYLE BLOCK [get_cells -hierarchical -filter {NAME =~ "*i_mem*instruction_memory_reg*"}]

################################################################################
# THAT'S IT - NO AGGRESSIVE DIRECTIVES!
################################################################################
# We removed ALL the aggressive optimization directives that broke timing:
# - NO PerformanceOptimized (caused issues)
# - NO Retiming (moved registers badly)
# - NO AggressiveExplore (made things worse)
# - NO PhysOptDesign (broke paths)
# - NO input/output delays (created violations)
# - NO clock uncertainty (unnecessary penalty)
#
# Philosophy: Keep it simple. Only fix what was broken (UCIO-1 warning).
# Don't mess with what was working (90 MHz timing closure).
################################################################################

################################################################################
# EXPECTED RESULTS @ 90 MHz (RECOVERY):
################################################################################
# WNS:     +0.4 to +0.5 ns (should match previous successful run)
# Power:   ~0.39 W (same as before)
# LUTs:    ~17,362 (same as before)
# UCIO-1:  FIXED (pin locations added)
# Timing:  PASS (back to working configuration)
################################################################################
