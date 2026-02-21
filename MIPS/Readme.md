# 🧠 Cognichip MIPS Processor  
### Single-Cycle Architecture from Fragmented Modules

---

## 📌 Project Overview

This project demonstrates the reconstruction of a **Single-Cycle MIPS Processor** using Cognichip by providing fragmented and incomplete RTL modules and obtaining a fully functional processor.

### 🎯 Objective
To design and validate a **single-cycle processor** that correctly executes four specified instructions using AI-assisted hardware completion.

The system successfully integrates:
- Incomplete datapath fragments  
- Partial control logic  
- Missing module interconnections  

Into a fully synthesizable processor.

---

## ✅ Supported Instructions

The processor supports the following four instructions:

```assembly
OR   reg3, reg1, reg2
SUBI reg4, reg5, 21
SW   reg6, 5(reg7)
BEQ  reg9, reg8, 7
```

These instructions represent:

| Instruction | Type | Operation Category |
|-------------|------|--------------------|
| OR | R-format | Logical |
| SUBI | I-format | Arithmetic |
| SW | I-format | Memory |
| BEQ | I-format | Branch |

---

# 🏗️ Single-Cycle Processor Basics

- Each instruction executes in **one clock cycle**
- Clock period equals the execution time of the **slowest instruction**
- Separate **Instruction Memory** and **Data Memory** (Harvard architecture)
- Simple combinational control logic
- No pipelining or multi-cycle stages

⚠️ Limitation: Performance is constrained by the slowest instruction.

---

# 🔄 Instruction Execution Flow

Every instruction follows these stages:

### 1️⃣ Instruction Fetch (IF)
- PC provides address
- Instruction memory returns instruction

### 2️⃣ Instruction Decode (ID)
- Opcode extracted
- Source and destination registers identified

### 3️⃣ Execute (EX)
- ALU performs required operation

### 4️⃣ PC Update
- PC increments by 4 (word-aligned instructions)
- For branch, PC may update to computed branch target

---

# 🧩 Datapath Design Details

---

## 🔹 R-Format: `OR reg3, reg1, reg2`

**Steps:**
1. Fetch instruction
2. Decode rs, rt, rd
3. Read reg1 and reg2
4. ALU performs OR operation
5. Result written back to reg3
6. PC ← PC + 4

---

## 🔹 I-Format Arithmetic: `SUBI reg4, reg5, 21`

**Steps:**
1. Fetch instruction
2. Decode rs and destination register
3. Read reg5
4. Sign-extend immediate (21 → 32-bit)
5. ALU performs subtraction
6. Result written to reg4
7. PC ← PC + 4

---

## 🔹 Store Word: `SW reg6, 5(reg7)`

**Steps:**
1. Fetch instruction
2. Decode base register (reg7) and data register (reg6)
3. Sign-extend offset (5)
4. Compute effective address = reg7 + offset
5. Write reg6 value to Data Memory
6. PC ← PC + 4

---

## 🔹 Branch Equal: `BEQ reg9, reg8, 7`

Branch requires:
- Register comparison
- Branch target computation

**Steps:**
1. Fetch instruction
2. Read reg9 and reg8
3. ALU compares values
4. Sign-extend offset
5. Shift offset left by 2
6. Compute branch target = PC+4 + shifted offset
7. If Zero flag = 1 → PC = branch target  
   Else → PC = PC + 4

---

# 🧠 Control Logic Summary

| Signal | Purpose |
|--------|----------|
| RegWrite | Enables register file write |
| ALUSrc | Selects register/immediate |
| MemWrite | Enables memory write |
| Branch | Enables branch decision |
| ALUOp | Selects ALU operation |
| PCSrc | Selects next PC value |

Control unit is fully combinational.

---

# 🏛️ Architectural Summary

| Feature | Implementation |
|----------|---------------|
| Architecture | Single-Cycle |
| Memory Model | Separate Instruction & Data Memory |
| Supported Formats | R-type, I-type |
| ALU Operations | OR, SUB |
| Branch Handling | Zero flag + PC multiplexer |
| Control Type | Combinational |
| Synthesis | Fully synthesizable |

---

# 🚀 Cognichip Contribution

Initially provided:
- Fragmented datapath blocks
- Missing interconnections
- Partial ALU logic
- Incomplete control signals

Cognichip successfully:
- Completed missing RTL modules
- Generated consistent control logic
- Connected datapath elements correctly
- Ensured correct instruction-level behavior
- Produced a fully functional processor

---

# 🎯 Key Outcome

This work demonstrates that AI-assisted hardware completion can:

- Recover incomplete processor designs
- Preserve architectural correctness
- Maintain synthesizability
- Satisfy strict instruction-level specifications

The final processor executes all required instructions correctly within a single-cycle architecture.
