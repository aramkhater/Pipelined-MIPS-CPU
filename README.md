# Pipelined MIPS CPU 

## Overview

This project is a VHDL implementation of a **32-bit Pipelined MIPS CPU** architecture. It aims to create a high-performance processor that executes instructions through five pipeline stages—**IF, ID, EX, MEM, and WB**—to optimize instruction throughput. The system includes robust logic for **Forwarding** and **Data Hazard Detection** to handle dependencies and control flow changes in real hardware.

---

## Table of Contents

* [System Design](#system-design)
* [Control Unit](#control-unit)
* [Data Path & Pipeline Stages](#data-path--pipeline-stages)
* [Hazard Management](#hazard-management)
* [Verification & Performance](#verification--performance)

---

## System Design

The design encapsulates all necessary modules for pipelined MIPS operation, integrating memory components and specialized hazard units.

### File Descriptions

**`aux_package.vhd`**
* Defines all component declarations, enabling interconnections between the various stages and control modules.

**`MIPS.vhd`**
* Serves as the top-level structural model, integrating all pipeline stages and the hazard/forwarding units.
* **Inputs/Outputs:**
    * Reset and clock inputs, including PLL integration for hardware deployment.
    * `BPADDR_i` for hardware breakpoint support.
    * Performance counters: `mclk_cnt_o` (clock cycles), `inst_cnt_o` (instructions), and `STCNT_o` (stalls).

**`IFETCH.VHD`**
* Manages the Program Counter (PC) and retrieves instructions from the Instruction TCM (ITCM).
* Supports PC increments, branch targets, and jump addresses while allowing for pipeline stalls via `pc_write_i`.

**`IDECODE.VHD`**
* Implements the Register File consisting of 32 registers of 32-bit width.
* Decodes instructions, performs sign-extension, and handles branch condition evaluation at the ID stage to reduce branch penalties.

**`EXECUTE.VHDL`**
* Performs arithmetic and logical operations using the ALU.
* Handles operand selection from the Register File or forwarded data from MEM/WB stages.

**`DMEMORY.VHD`**
* Implements the Data TCM (DTCM) for load and store operations.
* Interfaces with the pipeline to read data for `lw` or write data for `sw` instructions.

**`WB.vhd`**
* The Write Back stage, which selects between the ALU result and memory data to be written back to the Register File.

---

## Control Unit

**`CONTROL.VHD`**
* Implements the main combinatorial control logic.
* Generates signals such as `RegWrite`, `MemtoReg`, `ALUSrc`, and `Branch` based on the 6-bit opcode and function code.
* Supports R-type, I-type (e.g., `addi`, `lw`), and J-type (e.g., `jmp`, `jal`, `jr`) instructions.

---

## Data Path & Pipeline Stages



The datapath is divided into registers that coordinate data flow between cycles:
* **`IF_ID.vhd`**: Captures fetched instructions and $PC+4$.
* **`ID_EX.vhd`**: Passes decoded register values, control signals, and immediates to the execution stage.
* **`EX_MEM.vhd`**: Carries ALU results and store data to the memory stage.
* **`MEM_WB.vhd`**: Routes memory data or ALU results to the final write-back logic.

---

## Hazard Management

This processor includes dedicated hardware to resolve dependencies that arise in pipelined architectures:

**`Forwarding_Unit.vhd`**
* Resolves data hazards by routing data directly from the EX/MEM or MEM/WB stages back to the ALU inputs.
* Improves performance by allowing the CPU to use a result before it is officially written to the Register File.

**`Datahazard_Unit.vhd`**
* Detects Load-Use hazards where an instruction requires data immediately after a `lw` instruction.
* Stalls the pipeline by disabling PC and IF/ID updates and inserting a "nope" (no-op) into control signals.
* Manages Control Hazards by flushing the pipeline (clearing IF/ID) when a branch or jump is taken.

---

## Verification & Performance

The system was verified through a comprehensive process:
* **ModelSim Simulation:** Functional correctness was tested using a Matrix Addition program. Waveforms verified correct forwarding, stall insertion on hazards, and flush behavior.
* **Hardware Validation:** The design was synthesized using Quartus and deployed on a DE10-Standard FPGA.
* **SignalTap Analysis:** Real-time execution was captured to confirm instruction flow and breakpoint triggers at address `0x030`.
* **Performance Results:** The Matrix Addition test achieved an **IPC of 0.83** with a restricted $F_{max}$ for the system clock of **32.79 MHz**.
