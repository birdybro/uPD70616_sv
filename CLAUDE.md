# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a SystemVerilog implementation of the NEC V60 processor (μPD70616). The project is in its initial stages.

## Architecture

The μPD70616 is a 32-bit CISC microprocessor from NEC's V60 family. Key architectural features include:
- 32-bit data and address buses
- Variable-length instruction encoding
- Complex addressing modes
- Virtual memory support with segmentation and paging

## Development Resources

The primary reference document is `UPD70616ProgrammersReferenceManual.pdf` which contains:
- Instruction set architecture details
- Register definitions
- Memory management unit specifications
- Timing diagrams
- Programming model

## Common Development Tasks

As this is a hardware description project in SystemVerilog, typical tasks will include:
- Creating SystemVerilog modules for processor components
- Implementing instruction decoder and execution units
- Setting up testbenches for verification
- Running simulations with tools like ModelSim, VCS, or Verilator

Note: No build system or SystemVerilog files are currently present in the repository.

## μPD70616 Processor Implementation Checklist

This checklist is derived from the processor architecture described in the programmer's reference manual and represents the major components needed for a complete processor implementation.

### 1. Core Architecture Components

#### 1.1 Register File Implementation
- [ ] Implement 32 general-purpose registers (R0-R31)
- [ ] Implement Program Counter (PC) register
- [ ] Implement Program Status Word (PSW) register with all status bits
- [ ] Implement Stack Pointer (SP) with multiple execution level support
- [ ] Implement Frame Pointer (FP) and Argument Pointer (AP)
- [ ] Create privileged register set for system-level operations
- [ ] Implement LDPR/STPR instructions for privileged register access
- [ ] Implement stack pointer selection based on PSW IS and EL fields
- [ ] Implement System Base Register (SBR) for system table access

#### 1.2 Execution Pipeline
- [ ] Pre-fetch Unit (PFU) - 16-byte instruction queue
- [ ] Instruction Decode Unit (IDU) - variable-length instruction decoding
- [ ] Effective Address Generator (EAG) - address calculation
- [ ] Memory Management Unit (MMU) - virtual to physical address translation
- [ ] Bus Control Unit (BCU) - memory and I/O interface
- [ ] Execution Unit (EXU) - arithmetic and logic operations
- [ ] Implement instruction format decoders for all 7 formats (Format I-VII)
  - [ ] Format I: Fixed length data instructions using register/register and register/memory addressing modes
  - [ ] Format II: Fixed length data instructions using memory/memory addressing modes and floating point instructions
  - [ ] Format III: Single operand instructions 
  - [ ] Format IV: Conditional branch instructions
  - [ ] Format V: Zero operand instructions
  - [ ] Format VI: Loop instructions
  - [ ] Format VII: Variable length data instructions (character string, bit string, decimal arithmetic)
- [ ] Support variable-length instruction encoding (1-7 bytes)
- [ ] Support for instruction format field (mod field) encoding and decoding
- [ ] Implement all addressing mode encodings from Appendix C (71 different combinations)

#### 1.3 ALU and Functional Units
- [ ] 32-bit arithmetic logic unit
- [ ] Barrel shifter for shift/rotate operations
- [ ] Integer arithmetic operations (add, subtract, multiply, divide)
- [ ] Logical operations (AND, OR, XOR, NOT)
- [ ] Bit manipulation operations
  - [ ] Bit test and clear (CLR1)
  - [ ] Bit field comparison (CMPBF)
- [ ] Floating-point unit for IEEE 754 operations
  - [ ] Short real (32-bit) and long real (64-bit) support
  - [ ] Floating-point comparison (CMPF)
  - [ ] Floating-point conversion (CVT)
- [ ] Character and string processing unit
  - [ ] Character comparison with various modes
  - [ ] String length calculation and manipulation

### 2. Memory Management System

#### 2.1 Virtual Memory Architecture
- [ ] 4GB virtual address space support
- [ ] Memory segmentation (4 sections of 1GB each)
- [ ] Page-based memory management (4KB pages)
- [ ] Area-based memory organization (1MB areas)
- [ ] Address translation tables (Area Table, Page Table)
- [ ] Translation Lookaside Buffer (TLB) implementation
- [ ] Area Table Entry (ATE) format implementation with protection bits
- [ ] Page Table Entry (PTE) format implementation with validity bits
- [ ] Task Control Block (TCB) structure and access mechanisms

#### 2.2 Memory Protection
- [ ] Execution level-based access control (4 levels: 0-3)
- [ ] Read/write/execute permission checking
- [ ] Memory management exceptions
- [ ] Address trap functionality for debugging

### 3. Instruction Set Architecture

#### 3.1 Data Types Support
- [ ] Bit data (1-bit)
- [ ] Byte data (8-bit)
- [ ] Halfword data (16-bit)
- [ ] Word data (32-bit)
- [ ] Doubleword data (64-bit)
- [ ] Floating-point data (32-bit and 64-bit)
- [ ] Decimal data (BCD format)
- [ ] Character strings (byte and halfword)
- [ ] Bit fields and bit strings

#### 3.2 Addressing Modes
- [ ] Register addressing
- [ ] Register indirect addressing
- [ ] Register indirect indexed addressing
- [ ] Autoincrement/autodecrement addressing ([Rn+], [-Rn])
- [ ] Displacement addressing (8-bit, 16-bit, 32-bit) (disp[Rn])
- [ ] PC-relative addressing (disp[PC])
- [ ] Direct addressing (/addr)
- [ ] Immediate addressing (#value)
- [ ] Complex displacement modes with indexing (disp[Rn](Rx))
- [ ] Double displacement addressing (disp1[disp2[Rn]])
- [ ] Direct address indexed (/addr(Rx))
- [ ] Direct address deferred ([/addr])
- [ ] Direct address deferred indexed ([/addr](Rx))
- [ ] Immediate quick addressing mode (#value with 4-bit values)
- [ ] Implement all 21 byte addressing modes with proper encoding
- [ ] Implement all 18 bit addressing modes with proper encoding
- [ ] Implement addressing mode restrictions for autoincrement/autodecrement operations

#### 3.3 Instruction Categories
- [ ] Data transfer instructions
  - [ ] MOV (move data)
  - [ ] MOVEA (move effective address)
  - [ ] MOVF (move floating-point)
  - [ ] MOVS (move string)
  - [ ] MOVT (move top)
  - [ ] MOVZ (move with zero extension)
  - [ ] MOVBS (move bit string)
  - [ ] MOVC (move characters)
  - [ ] MOVCF (move characters with filler)
  - [ ] MOVCS (move characters with stopper)
- [ ] Arithmetic instructions (integer and floating-point)
  - [ ] ADD/ADDC/ADDDC (with carry and decimal)
  - [ ] SUB/SUBC/SUBDC (with borrow and decimal)
  - [ ] MUL/MULU (multiply signed/unsigned)
  - [ ] MULX/MULUX (extended multiply signed/unsigned)
  - [ ] MULF (floating-point multiply)
  - [ ] DIV/DIVU (divide signed/unsigned)
  - [ ] DIVX/DIVUX (extended divide signed/unsigned)
  - [ ] DIVF (floating-point divide)
  - [ ] INC/DEC (increment/decrement)
  - [ ] NEG/NEGF (negate integer/floating-point)
  - [ ] ADDF (floating-point add)
  - [ ] ABSF (absolute value floating-point)
  - [ ] CVTD.PZ/CVTD.ZP (decimal conversion packed-to-zoned, zoned-to-packed)
- [ ] Logic and bit manipulation instructions
  - [ ] AND, OR, XOR, NOT operations
  - [ ] ANDBS, ANDNBS (bit string operations)
  - [ ] ORBS, ORNBS (bit string OR operations)
  - [ ] XORBS, XORNBS (bit string XOR operations)
  - [ ] NOTBS (bit string NOT operation)
  - [ ] NOT1 (invert bit)
  - [ ] SET1 (set bit)
  - [ ] CLR1 (clear bit)
  - [ ] EXTBF (extract bit field)
  - [ ] INSBF (insert bit field)
- [ ] Control transfer instructions (branches, jumps, calls)
  - [ ] Bcc (conditional branch) with 32 condition codes
  - [ ] DBcc (decrement and branch conditionally)
  - [ ] JMP (unconditional jump)
  - [ ] JSR (jump to subroutine)
  - [ ] BRK (breakpoint trap)
  - [ ] BRKV (break on overflow)
  - [ ] BSR (branch to subroutine)
  - [ ] CALL (call procedure)
- [ ] Stack manipulation instructions
  - [ ] POP (pop from stack)
  - [ ] POPM (pop multiple registers)
  - [ ] PUSH (push to stack)
  - [ ] PUSHM (push multiple registers)
  - [ ] DISPOSE (dispose stack frame)
  - [ ] PREPARE (prepare stack frame)
  - [ ] RET (return from procedure)
  - [ ] RETIS (return from interrupt - system)
  - [ ] RETIU (return from interrupt - user)
  - [ ] RSR (return from subroutine)
- [ ] String processing instructions
  - [ ] CMPC (compare character strings)
  - [ ] CMPCF (compare character with filler)
  - [ ] CMPCS (compare character with stopper)
  - [ ] SCHC (search character)
  - [ ] SKPC (skip character)
  - [ ] SCH0BS (search bit string for 0)
  - [ ] SCH1BS (search bit string for 1)
- [ ] System control instructions
  - [ ] CAXI (compare and exchange interlocked)
  - [ ] CHKA (check access permission)
  - [ ] CHLVL (change execution level)
  - [ ] CLRTLB/CLRTLBA (clear TLB entries)
  - [ ] GETATE (get area table entry)
  - [ ] GETPSW (get program status word)
  - [ ] GETPTE (get page table entry)
  - [ ] GETRA (get ring address)
  - [ ] HALT (halt processor)
  - [ ] LDPR (load privileged register)
  - [ ] LDTASK (load task)
  - [ ] STTASK (store task)
  - [ ] IN/OUT (input/output operations)
  - [ ] NOP (no operation)
  - [ ] TEST (test operand)
  - [ ] GETPSW (get program status word)
  - [ ] UPDPSW.W (update program status word)
  - [ ] UPDATE (update page table entry)
  - [ ] UPDPTE (update page table entry)
  - [ ] RETIS (return from interrupt - system)
  - [ ] RETIU (return from interrupt - user)
  - [ ] CHKAR (check array)
  - [ ] CHKAW (check array word)
  - [ ] CHKAE (check array element)
  - [ ] TASI (test and set interlocked)
  - [ ] SETF (set flag)

### 4. Control and Status Systems

#### 4.1 Exception and Interrupt Handling
- [ ] System Base Table (SBT) implementation with 256 interrupt/exception vectors
- [ ] Interrupt controller with priority levels
- [ ] Multiple stack pointers for different execution levels
- [ ] Exception vector table with proper alignment (word boundary)
- [ ] Context switching mechanism
- [ ] Interrupt masking and enabling (IE bit in PSW)
- [ ] System call interface
- [ ] Breakpoint trap exception (BRK instruction)
- [ ] Integer overflow exception (BRKV instruction)
- [ ] Privileged instruction exception
- [ ] Illegal data field exception
- [ ] Reserved addressing mode exception
- [ ] Decimal format exception
- [ ] Floating-point exceptions (zero divide, overflow, underflow, precision)
- [ ] Software trap exception (TRAP instruction)
- [ ] Floating-point trap exception (TRAPFL instruction)
- [ ] Bus error and serious system fault handling
- [ ] Invalid interrupt exception handling
- [ ] Stack invalid exceptions and double exception handling
- [ ] Memory management exceptions (area/page not present, access violations)
- [ ] Instruction exceptions (reserved opcode, illegal addressing mode, illegal format)
- [ ] Exception nesting and priority handling
- [ ] Multiple interrupt/exception processing with proper priority order
- [ ] Exception detection sequence implementation
- [ ] Change execution level exceptions (0-3 levels)
- [ ] Asynchronous traps (AST/ATT) implementation
- [ ] Software traps (0-15) implementation
- [ ] Emulation mode exception handling
- [ ] Reserved floating-point operand exceptions
- [ ] Invalid floating-point operation exceptions
- [ ] Floating-point precision exceptions with TKCW.FPT control
- [ ] Address trap exception implementation with TRMOD register
- [ ] Exception codes table implementation (Table 8-1 format)
- [ ] Interrupt/exception stack format handling (Figure 8-5 formats)
- [ ] Bus freeze interrupt support for fault detection

#### 4.2 System Control Features
- [ ] Execution level management (privileged/user modes)
- [ ] Task switching support
- [ ] System base register implementation
- [ ] Processor ID register
- [ ] System control word functionality
- [ ] Task Control Word (TKCW) with floating-point trap controls
- [ ] System Control Word (SYCW) with VM mode and stack pointer switching
- [ ] Virtual memory mode control and implementation

### 5. Advanced Features

#### 5.1 Pipeline Control
- [ ] Instruction prefetch and queueing
- [ ] Pipeline hazard detection and resolution
- [ ] Branch prediction (if applicable)
- [ ] Pipeline flush mechanisms

#### 5.2 Debug and Development Support
- [ ] Instruction trace functionality
- [ ] Address trap registers and logic
- [ ] Breakpoint support
- [ ] Software debug exceptions
- [ ] Single-step execution capability
- [ ] Instruction trace control (TE bit in PSW)
- [ ] Instruction trace pending (TP bit in PSW) 
- [ ] Instruction trace exception handling with proper stack format
- [ ] UPDPSW.W instruction for trace control
- [ ] Address trap registers (ADTR0/ADTR1) implementation
- [ ] Address trap mask registers (ADTMR0/ADTMR1) implementation
- [ ] Trap mode register (TRMOD) with read/write/execute access control
- [ ] Address trap generation for memory accesses
- [ ] Address trap exception code format (Figure 9-2)
- [ ] Virtual/physical mode address trap support
- [ ] Memory indirect addressing mode trap support
- [ ] Infinite address trap prevention
- [ ] TLBNF access trap disabling for system base table accesses

#### 5.3 Emulation Mode
- [ ] V20/V30 compatibility mode
- [ ] Mode switching between native and emulation
- [ ] Register allocation for emulation mode
- [ ] Instruction set compatibility layer
- [ ] Emulation mode flag (EM) in PSW register implementation
- [ ] Program Status Word 2 (PSW2) for emulation mode
- [ ] Emulation mode program counter (16-bit) implementation
- [ ] Emulation mode register mapping (R0-R16 to V30 registers)
- [ ] Emulation mode segment registers (DS1, PS, SS, DS0)
- [ ] V20/V30 instruction set implementation (Table 10-1)
- [ ] Emulation mode privileged instruction handling
- [ ] I/O emulation option (CTL bit in PSW2)
- [ ] Emulation mode exception handling (privileged, reserved, zero divide, etc.)
- [ ] Emulation mode address generation (segment + effective address)
- [ ] RETIS instruction for emulation mode transitions
- [ ] Emulation mode memory address space mapping (1MB)
- [ ] V20/V30 interrupt processing in emulation mode
- [ ] Emulation mode instruction length restrictions (31 bytes max)
- [ ] μPD8080AF emulation mode exclusion
- [ ] Address wrap-around handling for 64KB segments
- [ ] Emulation mode single step support
- [ ] Native ↔ Emulation mode transition mechanisms

### 6. Fault Tolerance and Reliability

#### 6.1 Functional Redundancy Monitor (FRM)
- [ ] FRM dual processor configuration support
- [ ] Master/checker processor implementation
- [ ] FRM pin functions (BMODE, BLOCR, BFREZ, RT/EP)
- [ ] Bus freeze interrupt handling for fault detection
- [ ] Fault detection logic implementation
- [ ] Fault isolation mechanisms
- [ ] Fault recovery procedures (instruction continuation vs. bus freeze interrupt)
- [ ] MSMAT signal generation for mismatch detection
- [ ] Duplex system implementation support
- [ ] N-modular redundancy system support
- [ ] Triple modular redundant (TMR) system support
- [ ] Majority vote logic interface
- [ ] Fault tolerant system configuration
- [ ] MTBF (Mean Time Between Failure) optimization
- [ ] Transient fault handling and retry mechanisms

### 7. Interface and I/O

#### 7.1 External Bus Interface
- [ ] 32-bit address bus implementation
- [ ] 32-bit data bus implementation
- [ ] Bus control signals (read/write, byte enables)
- [ ] Bus arbitration logic
- [ ] Wait state generation

#### 7.2 Memory Interface
- [ ] Cache memory interface (if implementing cache)
- [ ] External memory controller interface
- [ ] DMA controller interface
- [ ] Memory-mapped I/O support

### 8. Verification and Testing

#### 8.1 Testbench Development
- [ ] CPU core testbench
- [ ] Individual module testbenches
- [ ] Memory system testbench
- [ ] Instruction decoder testbench
- [ ] Register file testbench
- [ ] Addressing mode testbench (all 21 byte + 18 bit modes)
- [ ] Floating-point unit testbench
- [ ] Character string processing testbench
- [ ] Interrupt and exception handling testbench
- [ ] System Base Table (SBT) testbench
- [ ] Stack frame management testbench
- [ ] Bit string operation testbench
- [ ] Decimal arithmetic testbench
- [ ] Software debug support testbench (instruction trace, address traps)
- [ ] V20/V30 emulation mode testbench
- [ ] Functional redundancy monitor testbench

#### 8.2 Test Programs
- [ ] Basic instruction execution tests
  - [ ] All arithmetic instructions (ADD, ADDC, ADDDC, SUB, SUBC, SUBDC)
  - [ ] All multiply/divide instructions (MUL, MULU, MULX, MULUX, DIV, DIVU, DIVX, DIVUX)
  - [ ] All floating-point instructions (ADDF, ABSF, MULF, DIVF, NEGF)
  - [ ] All logic instructions (AND, OR, XOR, NOT, ANDBS, ANDNBS, ORBS, ORNBS, NOTBS)
  - [ ] All bit manipulation instructions (CLR1, NOT1, SET1, EXTBF, INSBF)
  - [ ] All shift/rotate instructions (ROT, ROTC, SHA, SHL)
  - [ ] All bit reversal instructions (RVBIT, RVBYT)
  - [ ] All control flow instructions (BC, BE, BGE, BGT, BH, BL, BLE, BLT, BN, BNC, BNE, BNH, BNL, BNV, BNZ, BP, BR, DBcc variants, TB, JMP, JSR, BRK, BRKV, BSR, CALL, RET)
  - [ ] All data movement instructions (MOV, MOVEA, MOVF, MOVS, MOVT, MOVZ, MOVBS, MOVC, MOVCF, MOVCS)
  - [ ] All stack instructions (POP, POPM, PUSH, PUSHM, DISPOSE, PREPARE, RET, RETIS, RETIU, RSR)
  - [ ] All comparison instructions (CMP, CMPBF, CMPC, CMPCF, CMPCS, CMPF)
  - [ ] All conversion instructions (CVT variants, CVTD.PZ, CVTD.ZP)
  - [ ] All system instructions (CAXI, CHKA, CHLVL, CLR1, CLRTLB, GETATE, GETPSW, GETPTE, GETRA, HALT, LDPR, LDTASK, STPR, STTASK, UPDATE, UPDPSW, UPDPTE)
  - [ ] All interrupt/trap instructions (TRAP, TRAPFL)
  - [ ] All string search instructions (SCH0BS, SCH1BS, SCHC, SKPC)
  - [ ] All floating-point scaling instructions (SCLF)
  - [ ] All condition setting instructions (SETF)
  - [ ] All atomic operations (TASI)
  - [ ] All test and branch instructions (TB, TEST1)
  - [ ] All remainder instructions (REM, REMU)
  - [ ] All exchange instructions (XCH)
  - [ ] All decimal arithmetic instructions (SUBDC, SUBRDC)
  - [ ] All floating-point subtraction instructions (SUBF)
  - [ ] All I/O instructions (IN, OUT)
  - [ ] Special instructions (INC, DEC, NEG, NOP, TEST)
- [ ] Memory management tests
- [ ] Exception handling tests
- [ ] Interrupt handling tests
- [ ] Performance benchmarks
- [ ] Addressing mode comprehensive tests
- [ ] Floating-point precision and exception tests
- [ ] Character string processing tests
- [ ] Decimal arithmetic and conversion tests
- [ ] Software debug functionality tests
- [ ] V20/V30 emulation mode compatibility tests
- [ ] Functional redundancy monitor fault injection tests

### 9. Documentation and Integration

#### 9.1 Design Documentation
- [ ] Module interface specifications
- [ ] Timing diagrams
- [ ] State machine descriptions
- [ ] Memory map documentation

#### 9.2 Integration Testing
- [ ] Full system integration tests
- [ ] Compatibility testing with reference behavior
- [ ] Performance analysis
- [ ] Power consumption analysis (if applicable)

### Implementation Priority

**Phase 1 (Core Functionality):**
1. Basic register file and ALU
2. Simple instruction decoder for basic operations
3. Memory interface (without virtual memory)
4. Basic control flow

**Phase 2 (Enhanced Features):**
1. Complete instruction set implementation
2. Virtual memory management
3. Exception and interrupt handling
4. Pipeline implementation

**Phase 3 (Advanced Features):**
1. Debug and trace functionality
2. Emulation mode support
3. Performance optimizations
4. Complete verification suite

This checklist provides a roadmap for implementing a complete μPD70616 processor core in SystemVerilog, based on the architectural specifications in the programmer's reference manual.