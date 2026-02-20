# RV32I Processor - FPGA Verification Guide
## Pre-deployment testing for Zedboard Zynq-7020

---

## 📋 Overview

This guide helps you verify your optimized RV32I processor (V3 Final) before deploying to the **Zedboard (xc7z020clg484-1)** FPGA.

**What's included:**
- `tb_RISC_V_PROCESSOR.v` - Focused testbench with essential test cases
- `run_verilator_sim.sh` - Automated Verilator simulation script
- This guide - Step-by-step verification instructions

---

## 🎯 Test Cases Included

The testbench includes **4 essential tests** to verify FPGA readiness:

### Test 1: Built-in Program Execution
- **What it tests:** Core instruction execution (ADDI, LW, SW, BNE)
- **Program:** Memory copy loop (40 iterations)
- **Duration:** ~200 clock cycles
- **Pass criteria:** Program completes without errors

### Test 2: Pipeline Flush on Reset
- **What it tests:** Proper reset behavior
- **Pass criteria:** All pipeline stages clear when reset asserted

### Test 3: Processor Restart
- **What it tests:** Clean restart after reset release
- **Pass criteria:** Processor begins execution from PC=0

### Test 4: Extended Execution
- **What it tests:** Long-term stability
- **Duration:** 150 additional cycles
- **Pass criteria:** No hangs, no errors

---

## 🚀 Quick Start (WSL Ubuntu)

### Step 1: Install Required Tools

```bash
# Install Verilator
sudo apt-get update
sudo apt-get install -y verilator

# Install GTKWave for waveform viewing
sudo apt-get install -y gtkwave

# Verify installation
verilator --version
gtkwave --version
```

### Step 2: Navigate to Project Directory

```bash
# From Windows, your project is likely at:
cd /mnt/c/KarDRIVE/Projects/Cognichip/RISCV_RV32I/v3_final_optimization

# Or wherever your project is located
```

### Step 3: Run the Simulation

```bash
# Make the script executable
chmod +x run_verilator_sim.sh

# Run the simulation
./run_verilator_sim.sh
```

---

## ✅ Expected Output

### Successful Run Output:

```
=================================================
RV32I Processor Verification with Verilator
=================================================
Step 1: Setting up directories...
Step 2: Running Verilator (Lint + Compile)...
Step 3: Running simulation...
TEST START
===============================================
RV32I Processor Testbench - V3 Final
Target: Zedboard Zynq-7020 @ 89.5 MHz
===============================================
[50] Reset released - Processor starting...

[TEST 1] Executing built-in program (40 iterations)
Expected: Processor completes loop without errors
LOG: 100 : INFO : tb_RISC_V_PROCESSOR : dut.wb_data : expected_value: valid_data actual_value: 32'h00000028
[... more log entries ...]
[TEST 1] PASSED - Program executed for 200 cycles

[TEST 2] Testing pipeline flush on reset
[TEST 2] PASSED - Pipeline properly flushed

[TEST 3] Verifying processor restart after reset
[TEST 3] PASSED - Processor restarted successfully

[TEST 4] Extended execution test (150 more cycles)
[TEST 4] PASSED - Extended execution completed

===============================================
TEST SUMMARY
===============================================
Total cycles executed: 200
Test errors: 0

*** ALL TESTS PASSED ***
Processor is ready for FPGA deployment!
TEST PASSED
===============================================
Step 4: Simulation completed successfully!
Waveform saved to: waveforms/dumpfile.fst

=================================================
To view waveforms, run:
gtkwave waveforms/dumpfile.fst
=================================================

Verification Complete!
If all tests passed, your design is ready for FPGA deployment.
```

---

## 🔍 Analyzing Waveforms with GTKWave

After successful simulation, view the waveforms:

```bash
gtkwave waveforms/dumpfile.fst
```

### Key Signals to Monitor:

#### 1. Top-Level Signals
- `clock` - System clock
- `reset` - Reset signal
- `wb_data[31:0]` - Writeback data (final results)

#### 2. Program Counter (PC)
- `dut.if_pc[31:0]` - Instruction fetch PC
- Should increment: 0 → 4 → 8 → 12 → 16 → 20 → (branch back) → 4 → ...

#### 3. Pipeline Stage Signals
- `dut.if_instruction[31:0]` - Fetched instruction
- `dut.id_instruction[31:0]` - Decoded instruction
- `dut.ex_result[31:0]` - Execution result
- `dut.mem_result[31:0]` - Memory stage result

#### 4. Control Signals
- `dut.stall` - Pipeline stall indicator
- `dut.mem_branch` - Branch taken signal
- `dut.ex_branch` - Branch condition in execute stage

#### 5. Register File (if needed)
- `dut.dc_s.reg_file.registers[1]` - x1 (loop counter)
- `dut.dc_s.reg_file.registers[3]` - x3 (loaded data)
- `dut.dc_s.reg_file.registers[4]` - x4 (constant 40)

### Expected Waveform Behavior:

1. **Reset Phase (0-50ns):**
   - `reset` = 1
   - `if_pc` = 0
   - All pipeline registers clear

2. **Normal Execution (50ns+):**
   - `if_pc` increments: 0, 4, 8, 12, 16, then branches back to 4
   - `wb_data` shows various values as instructions complete
   - `stall` occasionally asserts (for load-use hazards)
   - `mem_branch` pulses when branch taken

3. **Register Updates:**
   - x1 increments: 4, 8, 12, 16, 20, 24, 28, 32, 36, 40
   - x4 stays constant at 40
   - Loop exits when x1 == x4

---

## 🔧 Manual Verification (Alternative)

If you prefer manual control:

### Compile Only:
```bash
verilator --cc --exe --build --trace-fst \
    -Wall \
    --top-module tb_RISC_V_PROCESSOR \
    tb_RISC_V_PROCESSOR.v \
    sources_1/new/*.v
```

### Run Simulation:
```bash
./obj_dir/Vtb_RISC_V_PROCESSOR
```

### View Waveforms:
```bash
gtkwave dumpfile.fst
```

---

## 📊 Verification Checklist for FPGA Deployment

Before deploying to Zedboard, ensure:

- [ ] ✅ All 4 tests PASS
- [ ] ✅ "TEST PASSED" appears at end of simulation
- [ ] ✅ No ERROR messages in output
- [ ] ✅ PC increments correctly in waveforms
- [ ] ✅ Pipeline stages show valid data flow
- [ ] ✅ Branch instructions work correctly
- [ ] ✅ Stall logic activates appropriately
- [ ] ✅ Reset properly flushes pipeline
- [ ] ✅ No X (unknown) values after reset release
- [ ] ✅ Simulation completes in expected time

---

## 🐛 Troubleshooting

### Issue: Verilator not found
**Solution:**
```bash
sudo apt-get update
sudo apt-get install verilator
```

### Issue: File not found errors
**Solution:**
```bash
# Ensure you're in the correct directory
pwd
# Should show: /mnt/c/.../v3_final_optimization

# Check files exist
ls sources_1/new/*.v
```

### Issue: Permission denied on script
**Solution:**
```bash
chmod +x run_verilator_sim.sh
```

### Issue: Simulation hangs
**Solution:**
- Testbench has 100us timeout protection
- Check waveforms to see where it stopped
- Verify instruction memory initialization

### Issue: X (unknown) values in waveforms
**Solution:**
- Check reset duration (should be 5+ cycles)
- Verify all registers initialize on reset
- Some X values early in simulation are normal

---

## 🎓 Understanding the Built-in Program

The instruction memory is initialized with this program:

```assembly
      addi x4, x0, 40    # x4 = 40 (loop limit)
loop: addi x1, x1, 4     # x1 += 4 (counter)
      lw   x3, 0(x1)     # Load word from memory[x1]
      sw   x3, 4(x1)     # Store word to memory[x1+4]
      bne  x1, x4, loop  # Branch if x1 != 40
```

**What it does:**
- Copies memory contents in a loop
- Increments x1 from 0 to 40 in steps of 4
- Tests: arithmetic, load/store, branches
- Total iterations: 10 (0→40 in steps of 4)
- Expected cycles: ~50-60 cycles

---

## 📦 Next Steps After Verification

Once all tests pass:

1. ✅ **Synthesis in Vivado**
   - Open your V3 project
   - Run Synthesis
   - Check for no errors

2. ✅ **Implementation**
   - Run Implementation
   - Verify WNS > 0 (positive slack)
   - Check power report (~0.217W total)

3. ✅ **Generate Bitstream**
   - Tools → Generate Bitstream
   - Creates `.bit` file for FPGA

4. ✅ **Deploy to Zedboard**
   - Program FPGA with bitstream
   - Connect external interfaces (if any)
   - Test on hardware

---

## 📝 Notes

- **Clock Frequency:** Testbench uses 100MHz for simulation (10ns period)
  - FPGA target is 89.5MHz (11.173ns period)
  - Timing difference won't affect functionality testing

- **Waveform Format:** Uses FST (Fast Signal Trace)
  - Smaller files than VCD
  - Faster to generate and load
  - Fully compatible with GTKWave

- **Test Duration:** Simulation runs for ~4000ns total
  - Sufficient to verify core functionality
  - Not exhaustive (full verification would need more tests)
  - Focused on FPGA deployment readiness

---

## 🏆 Success Criteria

**Your design is FPGA-ready when:**
1. Verilator compiles with no errors
2. All 4 tests show PASSED
3. Final output shows "TEST PASSED"
4. Waveforms show correct PC progression
5. No X (unknown) values after reset
6. Pipeline stalls work correctly
7. Branches execute properly

**Then you can confidently:**
- Generate bitstream in Vivado
- Program the Zedboard
- Test on real hardware

---

## 📧 Support

If you encounter issues:
1. Check the waveforms first - they tell the story
2. Review the log messages for specific failures
3. Verify all source files are present
4. Ensure Verilator version is recent (4.0+)

Good luck with your FPGA deployment! 🚀
