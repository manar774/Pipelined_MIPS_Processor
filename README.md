# Pipelined MIPS Processor

A custom **20-bit 5-stage pipelined MIPS-like processor** implemented in Verilog. The design features a classic IF → ID → EX → MEM → WB pipeline with full hazard handling — including data forwarding, load-use stall detection, and control hazard flushing — plus four custom instructions extending the base ISA.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [ISA](#isa)
- [Pipeline Stages](#pipeline-stages)
- [Hazard Handling](#hazard-handling)
- [Module Reference](#module-reference)
- [Simulation](#simulation)

---

## Architecture Overview

```
         ┌──────────┐   IF/ID   ┌──────────┐   ID/EX   ┌──────────┐   EX/MEM  ┌──────────┐  MEM/WB  ┌──────────┐
clk ────►│  FETCH   ├──────────►│  DECODE  ├──────────►│ EXECUTE  ├──────────►│  MEMORY  ├─────────►│  WRITE   │
reset───►│          │           │    +CU   │           │  + ALU   │           │          │          │   BACK   │
         └──────────┘           └──────────┘           └──────────┘           └──────────┘          └──────────┘
                  ▲                   ▲                      │  │                   │
                  │                   │◄─────────────────────┘  │◄──────────────────┘
                  │              Forwarding Unit (EX→EX, MEM→EX, MEM→ID)
                  │
              Hazard Unit (stall / flush control)
```

**Key parameters:**
- Data width: **20 bits**
- Register file: **8 registers** (3-bit address), initialized to `r[i] = i`
- Instruction memory: **20-bit instructions**, word-addressed (PC increments by 4)
- Data memory: separate, synchronous write / asynchronous read

---

## Project Structure

```
Pipelined-MIPS-Processor/
│
├── src/                        # RTL source files
│   ├── topPipelined.v          # Top-level: wires all stages together
│   ├── fetch.v                 # IF stage: PC, instruction memory, PC mux, IF/ID register
│   ├── decodingBlock.v         # ID stage: control unit, reg file, sign extend, branch, ID/EX register
│   ├── execute.v               # EX+MEM+WB stages: ALU, data memory, pipeline registers
│   ├── controlUnit.v           # Main control unit (opcode → control signals)
│   ├── ALU.v                   # 20-bit ALU (AND, OR, ADD, SUB, SLT)
│   ├── ALUctrl.v               # ALU control decoder (ALUop + funct → ALU select)
│   ├── forwardingUnit.v        # Data forwarding logic (EX hazard + MEM hazard + branch forwarding)
│   ├── hazardUnit.v            # Stall and flush generation
│   ├── IF_ID.v                 # IF/ID pipeline register
│   ├── ID_IE.v                 # ID/EX pipeline register
│   ├── EX_MEM.v                # EX/MEM pipeline register
│   ├── MEM_WB.v                # MEM/WB pipeline register
│   ├── regMemory.v             # 8×20-bit register file (async read, negedge write)
│   ├── dataMemory.v            # Data memory
│   ├── signExtend.v            # 10→20-bit sign/zero extender
│   ├── WriteRegisterSelector.v # Destination register mux (rd / rt / rs)
│   ├── mux.v                   # Generic 2-to-1 mux
│   ├── jump.v                  # Jump address assembler
│   ├── PC.v                    # Program counter register
│   ├── inst_memory.v           # Standalone instruction memory
│   └── shift_two.v             # Left-shift-by-2 unit
│
├── dv/                         # Testbenches
│   ├── toptb.v                 # Top-level simulation testbench
│   └── execute_tb.v            # Execute stage unit testbench
│
└── docs/
    └── PPT_PROJECT.pdf         # Project presentation and documentation
```

---

## ISA

The processor uses a **20-bit fixed-width instruction format**:

```
 [19:16]   [15:13]  [12:10]  [9:7]   [6:4]   [3:0]
  opcode     rs       rt      rd/imm[9:7]     funct/imm[3:0]
```

For I-type instructions the immediate is `[9:0]` (bits 15:13 = rs, 12:10 = rt, 9:0 = imm).

### Instruction Set

| Opcode | Mnemonic | Type   | Description                                      |
|--------|----------|--------|--------------------------------------------------|
| `0000` | R-type   | R      | ALU op determined by `funct[2:0]`                |
| `0001` | ADDI     | I      | `rt = rs + sign_ext(imm)`                        |
| `0011` | ANDI     | I      | `rt = rs & zero_ext(imm)`                        |
| `1001` | LW       | I      | `rt = MEM[rs + sign_ext(imm)]`                   |
| `1010` | SW       | I      | `MEM[rs + sign_ext(imm)] = rt`                   |
| `1011` | BEQ      | I      | Branch if `rs == rt`                             |
| `1100` | J        | J      | Unconditional jump                               |
| `1101` | SWI      | I      | Store with immediate; write back to rs           |
| `1110` | JMN      | I      | Jump to address loaded from memory               |
| `1111` | PMC      | I      | Post-memory copy: load + store + redirect PC     |

### R-type Function Codes (`funct[2:0]`)

| funct | Operation |
|-------|-----------|
| `000` | AND       |
| `001` | OR        |
| `010` | ADD       |
| `110` | SUB       |
| `111` | SLT       |

---

## Pipeline Stages

### IF — Instruction Fetch (`fetch.v`)

Contains the `ProgramCounter`, `PcAdder` (+4), `InstructionMemory` (128 × 20-bit, word-addressed), and the `ProgramCounterMux`. The PC mux selects the next PC in priority order:

```
JMN (memory-loaded) > JUMP > BRANCH > PC+4
```

The `IF_ID` register holds the instruction and PC+4 between stages.

### ID — Instruction Decode (`decodingBlock.v`)

Instantiates the `controlUnit`, `regMemory` (8-register file), `signExtend`, branch comparator (zero detect), branch address adder, and `jump` address assembler. The `ID_IE` register passes all control signals and operands to the execute stage.

### EX — Execute (`execute.v`)

The ALU computes results using `ALUctrl`-decoded operation codes. The `WriteRegisterSelector` mux selects the destination register among `rd` (R-type), `rt` (I-type), or `rs` (SWI). Forwarded operands from MEM and WB stages are selected via forwarding muxes before the ALU inputs.

### MEM — Memory Access (`execute.v`)

The `dataMemory` is accessed using the ALU result as the address. The `pmcSel` signal redirects the address and write data for the PMC instruction. The `EX_MEM` register holds results between EX and MEM.

### WB — Write Back (`execute.v`)

The `MEM_WB` register feeds into a final mux selecting between `readData` (LW path) and `aluResult` for register writeback. The writeback data is also fed back to the register file and to the forwarding paths.

---

## Hazard Handling

### Data Forwarding (`forwardingUnit.v`)

The forwarding unit resolves RAW hazards by detecting when a result in EX/MEM or MEM/WB matches a source register in the EX stage, and drives 2-bit `forwardA` / `forwardB` signals to select the forwarded value:

| Condition                  | Forward source |
|---------------------------|----------------|
| `rdMem == rs` and `regWrite_MEM` | EX/MEM ALU result |
| `rdWb == rs` and `regWrite_WB`   | MEM/WB write data |

Branch forwarding is also supported: if the EX/MEM result matches a register used in the ID-stage branch comparison, it is forwarded directly before the zero-detect logic.

### Load-Use Stall (`hazardUnit.v`)

When a `LW` instruction is in EX/MEM (indicated by `mem2regMem`) and either source register of the following instruction matches the load destination (detected via `forwardExrs` / `forwardExrt`), the hazard unit:

- Stalls `stallIF` and `stallID` (freezes PC and IF/ID register)
- Flushes `flushIE` (inserts a bubble into the EX stage)

### Control Hazards (`hazardUnit.v`)

| Event  | Action                                         |
|--------|------------------------------------------------|
| JUMP   | Flush IF stage (`flushIF`)                     |
| BEQ    | Flush IF stage (`flushIF`)                     |
| JMN    | Flush IF, ID, EX, MEM stages (4-cycle redirect)|
| PMC    | Flush IF, ID, EX, MEM stages (4-cycle redirect)|

---

## Module Reference

| Module                   | File                      | Description                                    |
|--------------------------|---------------------------|------------------------------------------------|
| `top`                    | `topPipelined.v`          | Top-level structural netlist                   |
| `FetchStage`             | `fetch.v`                 | Full fetch stage with sub-modules              |
| `ProgramCounter`         | `fetch.v`                 | PC register with enable and reset              |
| `ProgramCounterMux`      | `fetch.v`                 | 4-way PC select mux                            |
| `PcAdder`                | `fetch.v`                 | PC+4 adder with overflow detection             |
| `InstructionMemory`      | `fetch.v`                 | 128-entry ROM, pre-loaded with test program    |
| `IF_ID`                  | `IF_ID.v`                 | Pipeline register between IF and ID            |
| `decodingBlock`          | `decodingBlock.v`         | Full decode stage with sub-modules             |
| `controlUnit`            | `controlUnit.v`           | 4-bit opcode → 13 control signals              |
| `regMemory`              | `regMemory.v`             | 8×20-bit register file                         |
| `signExtend`             | `signExtend.v`            | 10→20-bit sign or zero extend                  |
| `jump`                   | `jump.v`                  | Concatenates upper PC bits with jump offset    |
| `ID_IE`                  | `ID_IE.v`                 | Pipeline register between ID and EX            |
| `execute`                | `execute.v`               | EX + MEM + WB stages combined                 |
| `ALU`                    | `ALU.v`                   | 20-bit ALU: AND, OR, ADD, SUB, SLT             |
| `ALUctrl`                | `ALUctrl.v`               | ALUop + funct → 3-bit ALU control              |
| `WriteRegisterSelector`  | `WriteRegisterSelector.v` | Destination register: rd / rt / rs             |
| `EX_MEM_Register`        | `EX_MEM.v`                | Pipeline register between EX and MEM          |
| `dataMemory`             | `dataMemory.v`            | Synchronous write / asynchronous read memory   |
| `MEM_WB_Register`        | `MEM_WB.v`                | Pipeline register between MEM and WB          |
| `forwardingUnit`         | `forwardingUnit.v`        | RAW hazard forwarding and branch forwarding    |
| `hazardUnit`             | `hazardUnit.v`            | Stall and flush control for all hazard types   |
| `mux`                    | `mux.v`                   | Generic 1-bit-select 20-bit 2-to-1 mux         |

---

## Simulation

### Requirements

- ModelSim / QuestaSim, or any Verilog-2001 compatible simulator
- Intel Quartus Prime (for synthesis targeting Intel FPGAs)

### Running the Top-Level Testbench

```tcl
vlog src/*.v dv/toptb.v
vsim work.toptb
add wave *
run -all
```

The testbench (`toptb.v`) asserts reset for 100 ns, then releases it and runs for 3000 ns. Internal signals (control lines, register operands, PC, ALU results) are probed directly from the top-level instance for waveform inspection.

The instruction memory is pre-loaded with a test program covering all instruction types:

| Address | Instruction | Operation              |
|---------|-------------|------------------------|
| 0       | `0x03102`   | ADD  r0, r1, r2        |
| 1       | `0x03106`   | SUB  r0, r1, r2        |
| 2       | `0x03100`   | AND  r0, r1, r2        |
| 3       | `0x03101`   | OR   r0, r1, r2        |
| 4       | `0x03107`   | SLT  r0, r1, r2        |
| 5       | `0x1508A`   | ADDI r4, r2, 10        |
| 6       | `0x3508B`   | ANDI r4, r2, 11        |
| 7       | `0xA1C04`   | SW   r7, r0+4          |
| 8       | `0x91004`   | LW   r4, r0+4          |
| 9       | `0xD3005`   | SWI  (custom)          |
| 10      | `0xB2111`   | BEQ  r1, r2, offset    |
| 11      | `0xC200D`   | J    target            |
| 13      | `0xE1014`   | JMN  (custom)          |
| 15      | `0xF0C0A`   | PMC  (custom)          |

### Running the Execute Stage Testbench

```tcl
vlog src/*.v dv/execute_tb.v
vsim work.execute_tb
run -all
```
