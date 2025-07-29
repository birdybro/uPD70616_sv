`ifndef V60_DEFINES_SV
`define V60_DEFINES_SV

// V60 Architecture Constants
`define V60_DATA_WIDTH      32
`define V60_ADDR_WIDTH      32
`define V60_REG_WIDTH       32
`define V60_NUM_REGS        32

// General Purpose Registers (R0-R31)
`define V60_REG_R0          5'd0
`define V60_REG_R1          5'd1
`define V60_REG_R2          5'd2
`define V60_REG_R3          5'd3
`define V60_REG_R4          5'd4
`define V60_REG_R5          5'd5
`define V60_REG_R6          5'd6
`define V60_REG_R7          5'd7
`define V60_REG_R8          5'd8
`define V60_REG_R9          5'd9
`define V60_REG_R10         5'd10
`define V60_REG_R11         5'd11
`define V60_REG_R12         5'd12
`define V60_REG_R13         5'd13
`define V60_REG_R14         5'd14
`define V60_REG_R15         5'd15
`define V60_REG_R16         5'd16
`define V60_REG_R17         5'd17
`define V60_REG_R18         5'd18
`define V60_REG_R19         5'd19
`define V60_REG_R20         5'd20
`define V60_REG_R21         5'd21
`define V60_REG_R22         5'd22
`define V60_REG_R23         5'd23
`define V60_REG_R24         5'd24
`define V60_REG_R25         5'd25
`define V60_REG_R26         5'd26
`define V60_REG_R27         5'd27
`define V60_REG_R28         5'd28
`define V60_REG_R29         5'd29
`define V60_REG_R30         5'd30
`define V60_REG_R31         5'd31

// Special Purpose Registers (implicitly selected by instructions)
`define V60_REG_AP          5'd29   // Argument Pointer (R29)
`define V60_REG_FP          5'd30   // Frame Pointer (R30)
`define V60_REG_SP          5'd31   // Stack Pointer (R31)

// Program Status Word (PSW) bits
`define V60_PSW_V           0   // Overflow
`define V60_PSW_C           1   // Carry
`define V60_PSW_Z           2   // Zero
`define V60_PSW_S           3   // Sign
`define V60_PSW_TB          4   // Trap on Branch
`define V60_PSW_TP          5   // Trap Pending
`define V60_PSW_FPT         6   // Floating Point Trap
`define V60_PSW_PRNG        9:7 // Privilege Ring (0-7)
`define V60_PSW_IS          10  // Interrupt State
`define V60_PSW_FUD         11  // FPU Disable
`define V60_PSW_AT          12  // Address Translation
`define V60_PSW_DB          13  // Debug
`define V60_PSW_IM          14  // Interrupt Mask
`define V60_PSW_I           15  // Interrupt Enable

// Instruction Format Types (from V60 manual)
`define V60_FMT_I           3'd0   // Format I: One-byte instructions
`define V60_FMT_II          3'd1   // Format II: Two-byte instructions
`define V60_FMT_III         3'd2   // Format III: Instructions with immediate
`define V60_FMT_IV          3'd3   // Format IV: Instructions with displacement
`define V60_FMT_V           3'd4   // Format V: Two-operand instructions
`define V60_FMT_VI          3'd5   // Format VI: Three-operand instructions
`define V60_FMT_VII         3'd6   // Format VII: Special format instructions
`define V60_FMT_RESERVED    3'd7   // Reserved format

// Data Types
`define V60_TYPE_BYTE       2'd0   // 8-bit
`define V60_TYPE_HALFWORD   2'd1   // 16-bit
`define V60_TYPE_WORD       2'd2   // 32-bit
`define V60_TYPE_EXTENDED   2'd3   // 64-bit (FPU)

// Addressing Modes
`define V60_AM_REGISTER     3'd0   // Register direct
`define V60_AM_IMMEDIATE    3'd1   // Immediate
`define V60_AM_MEMORY       3'd2   // Memory direct
`define V60_AM_INDEXED      3'd3   // Register indirect with index
`define V60_AM_AUTOINCR     3'd4   // Auto-increment
`define V60_AM_AUTODECR     3'd5   // Auto-decrement
`define V60_AM_DISPLACED    3'd6   // Register indirect with displacement
`define V60_AM_PCRELATIVE   3'd7   // PC-relative

// Memory Access Types
`define V60_MEM_IDLE        2'd0
`define V60_MEM_READ        2'd1
`define V60_MEM_WRITE       2'd2
`define V60_MEM_RMW         2'd3   // Read-Modify-Write

// Exception Vectors
`define V60_VEC_RESET       8'h00
`define V60_VEC_NMI         8'h01
`define V60_VEC_INVALID_OP  8'h06
`define V60_VEC_DIV_ZERO    8'h07
`define V60_VEC_OVERFLOW    8'h08
`define V60_VEC_BOUNDS      8'h09
`define V60_VEC_DEBUG       8'h0D
`define V60_VEC_PAGE_FAULT  8'h0E
`define V60_VEC_ALIGNMENT   8'h11

`endif // V60_DEFINES_SV