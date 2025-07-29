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