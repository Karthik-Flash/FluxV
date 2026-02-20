# VIVADO BRAM SYNTHESIS GUIDE
## Step-by-Step Instructions to Force BRAM Inference

---

## 🎯 **OBJECTIVE**

Force Vivado to use Block RAM (BRAM) instead of distributed RAM for memories to achieve:
- **-2,300 LUTs (-13% reduction)**
- **+2 BRAM tiles**
- **-27% power savings (0.614 W → 0.45 W)**

---

## 📋 **WHAT WAS CHANGED**

### **File Modified:** `constrs_1/new/constr.xdc`

**Added BRAM Constraints:**
```tcl
# Force Data Memory to Block RAM
set_property RAM_STYLE BLOCK [get_cells -hierarchical -filter {NAME =~ "*MEM_STAGE*mem_reg*"}]

# Force Instruction Memory to Block RAM
set_property RAM_STYLE BLOCK [get_cells -hierarchical -filter {NAME =~ "*INSTRUCTION_MEMORY*instruction_memory_reg*"}]

# Keep Register File as Distributed RAM (for performance)
set_property RAM_STYLE DISTRIBUTED [get_cells -hierarchical -filter {NAME =~ "*REGFILE*GPP_reg*"}]
```

---

## 🚀 **STEP-BY-STEP VIVADO SYNTHESIS**

### **Step 1: Open Your Vivado Project**
```
File → Open Project → Navigate to v1_bram_optimization/RV32I_V1
```

### **Step 2: Verify Constraints File is Loaded**
- Check "Sources" window → "Constraints" section
- Ensure `constr.xdc` is present and enabled (checkbox checked)
- If missing, right-click "Constraints" → Add Sources → Add constraint file

### **Step 3: Reset Synthesis Runs**
```tcl
# In TCL Console at bottom of Vivado:
reset_run synth_1
```
Or: Right-click `synth_1` in Design Runs → Reset Run

### **Step 4: Launch Synthesis**
```tcl
# In TCL Console:
launch_runs synth_1
wait_on_run synth_1
```
Or: Click "Run Synthesis" button in Flow Navigator

### **Step 5: Wait for Completion**
- Synthesis will take 3-5 minutes
- Watch Messages window for progress
- Look for "Synthesis completed successfully" message

---

## 🔍 **VERIFICATION STEPS**

### **After Synthesis Completes:**

### **1. Check Utilization Report**
```
Open Synthesized Design → Report Utilization
```

**Look for:**
```
+-------------------------+------+-------+
| Site Type               | Used | Avail |
+-------------------------+------+-------+
| Slice LUTs              | 15.4K| 53200 | ← Should be ~15,400 (down from 17,246)
| Block RAM Tile          |    2 |  140  | ← Should be 2 (up from 0)
+-------------------------+------+-------+
```

### **2. Check RAM Utilization Detail**
```tcl
# In TCL Console:
report_ram_utilization -detail
```

**Expected Output:**
```
RAM inference:
  Found Block RAM: MEM_STAGE/mem_reg (1024 bytes) → RAMB18E1
  Found Block RAM: INSTRUCTION_MEMORY/instruction_memory_reg (20 bytes) → RAMB18E1 or Distributed
  Found Distributed RAM: REGFILE/GPP_reg (1024 bits) → LUT RAM
```

### **3. Verify BRAM Primitives**
```tcl
# Count BRAM primitives:
llength [get_cells -hierarchical -filter {PRIMITIVE_TYPE =~ BMEM.*.RAMB*}]
```
**Expected:** Should return `2` or `1` (depending on instruction memory size)

### **4. Check Synthesis Messages**
```
View → Messages
Filter by: Synth 8-3936, Synth 8-3898
```

**Look for:**
```
INFO: [Synth 8-3936] Found RAM Reg "MEM_STAGE/mem_reg" for signal 'mem'
INFO: [Synth 8-3898] Implementing RAM 'MEM_STAGE/mem_reg' using block memory
```

---

## ⚠️ **TROUBLESHOOTING**

### **Problem 1: Still 0 BRAM After Synthesis**

**Cause:** Constraints not applied or wildcards didn't match cell names

**Solution A - Check Cell Names:**
```tcl
# After opening synthesized design:
get_cells -hierarchical -filter {NAME =~ "*mem_reg*"}
```
This shows actual cell names. Adjust wildcards in XDC to match.

**Solution B - Try Alternative Patterns:**
Edit `constr.xdc` and replace with:
```tcl
# More specific patterns:
set_property RAM_STYLE BLOCK [get_cells -hier -filter {NAME =~ "*mr_s*mem_reg*"}]
set_property RAM_STYLE BLOCK [get_cells -hier -filter {NAME =~ "*i_mem*instruction_memory_reg*"}]
```

**Solution C - Direct Cell Targeting:**
```tcl
# After finding exact names with get_cells above:
set_property RAM_STYLE BLOCK [get_cells {cpu/mr_s/mem_reg[0]}]
set_property RAM_STYLE BLOCK [get_cells {cpu/mr_s/mem_reg[1]}]
# ... continue for all memory cells
```

### **Problem 2: BRAM Used But LUTs Not Reduced**

**Cause:** Only small memory converted to BRAM, not enough savings

**Check:** Which memory was inferred as BRAM?
```tcl
report_ram_utilization -detail
```

**If only instruction memory (20 bytes):** Not enough for significant LUT savings
**Expected:** Data memory (1024 bytes) MUST be BRAM for major savings

### **Problem 3: Timing Failures After BRAM**

**Cause:** BRAM has 1 cycle read latency vs combinational distributed RAM

**Solution:** This shouldn't happen because your design already registers memory accesses.

**If it does happen:**
```tcl
# Check critical paths:
report_timing_summary
```
Look for paths through memory. If critical, you may need pipeline adjustments.

---

## 📊 **SUCCESS CRITERIA**

After successful synthesis, you should see:

| Metric | Before (v0) | After (v1 with BRAM) | ✓ Success? |
|--------|-------------|----------------------|------------|
| **LUTs** | 17,246 | ~15,400 | ✓ -1,800+ LUTs |
| **BRAM** | 0 | 1-2 tiles | ✓ >0 BRAM |
| **FFs** | 9,818 | ~9,800-9,900 | ✓ Unchanged |
| **WNS** | 0.536 ns | >0 ns | ✓ Still positive |
| **Power** | 0.614 W | <0.50 W | ✓ Reduced |

---

## 🎯 **WHAT TO DO IF IT WORKS**

### **1. Generate Reports**
```tcl
report_utilization -file utilization_v1_bram.txt
report_power -file power_v1_bram.txt
report_timing_summary -file timing_v1_bram.txt
report_ram_utilization -detail -file ram_v1_bram.txt
```

### **2. Compare with Baseline (v0)**
Create comparison table:

```
                v0          v1        Improvement
LUTs:         17,700     15,400      -2,300 (-13%)
BRAM:              0          2             +2
Power:        0.614W     0.45W       -0.16W (-27%)
WNS:          0.536ns    (check)     (maintained)
```

### **3. Proceed to Implementation**
```tcl
launch_runs impl_1
wait_on_run impl_1
```

---

## 🛠️ **ALTERNATIVE: MANUAL SYNTHESIS IN GUI**

If constraints don't work, try manual approach:

### **Option 1: Synthesis Settings**
```
Synthesis Settings → More Options → add:
-max_bram 140
```

### **Option 2: RTL Attributes (Already Done)**
Your Verilog code already has:
```verilog
(* ram_style = "block" *) reg [7:0]mem[1023:0];
```
But Vivado may need constraint reinforcement.

### **Option 3: XDC Direct Assignment**
If wildcards fail, after synthesis:
1. Open Synthesized Design
2. Find exact memory cell names:
   ```tcl
   get_cells -hier -filter {PRIMITIVE_TYPE =~ BMEM.*}
   ```
3. Apply properties directly:
   ```tcl
   set_property RAM_STYLE BLOCK [get_cells {exact_path_to_mem_reg}]
   ```

---

## 📞 **WHAT TO REPORT BACK**

After running synthesis, share:

1. **Utilization Summary:**
   - LUT count
   - BRAM count
   - FF count

2. **Synthesis Messages:**
   - Any warnings about RAM
   - BRAM inference messages

3. **RAM Utilization Report:**
   ```tcl
   report_ram_utilization -detail
   ```

4. **If Still 0 BRAM:**
   - Output of: `get_cells -hier -filter {NAME =~ "*mem_reg*"}`
   - This shows actual cell names for pattern matching

---

## ✅ **READY TO RUN**

Your constraints file is updated and ready. Now:

1. Open Vivado
2. Reset synthesis run
3. Launch synthesis
4. Check results
5. Report back!

**Expected time:** 3-5 minutes for synthesis

**Good luck! You should see 2 BRAM tiles and ~15,400 LUTs after this run.** 🚀
