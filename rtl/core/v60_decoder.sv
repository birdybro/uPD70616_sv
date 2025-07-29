`include "v60_defines.sv"

module v60_decoder (
    input  logic [47:0]  inst,           // 6-byte instruction buffer
    input  logic         valid,          // Input valid signal
    
    output logic [7:0]   opcode,         // Decoded opcode
    output logic [2:0]   format,         // Instruction format
    output logic [1:0]   data_type,      // Data type (byte/halfword/word)
    output logic [4:0]   src_reg,        // Source register
    output logic [4:0]   dst_reg,        // Destination register
    output logic [31:0]  immediate,      // Immediate value
    output logic [2:0]   inst_length,    // Instruction length in bytes
    output logic         uses_memory,    // Instruction uses memory
    output logic         illegal         // Illegal instruction
);

    // Internal signals
    logic [7:0]  opcode_byte;
    logic [2:0]  addr_mode_src;
    logic [2:0]  addr_mode_dst;
    logic        has_modrm;
    logic        has_sib;
    logic [1:0]  displacement_size;
    logic [1:0]  immediate_size;
    
    // ModR/M decoding signals
    logic [7:0]  modrm;
    logic [1:0]  mod_field;
    logic [2:0]  reg_field;
    logic [2:0]  rm_field;
    
    // Extract first opcode byte
    assign opcode_byte = inst[47:40];
    
    // Decode main opcode groups
    always_comb begin
        // Default values
        opcode = opcode_byte;
        format = `V60_FMT_I;
        data_type = `V60_TYPE_WORD;
        src_reg = 5'h0;
        dst_reg = 5'h0;
        immediate = 32'h0;
        inst_length = 3'd1;
        uses_memory = 1'b0;
        illegal = 1'b0;
        has_modrm = 1'b0;
        has_sib = 1'b0;
        displacement_size = 2'd0;
        immediate_size = 2'd0;
        
        if (!valid) begin
            illegal = 1'b1;
        end else begin
            // Decode based on opcode patterns
            casez (opcode_byte)
                // MOV instructions
                8'b1000_10??: begin  // MOV r/m, r (88-8B)
                    format = `V60_FMT_V;
                    data_type = opcode_byte[0] ? `V60_TYPE_WORD : `V60_TYPE_BYTE;
                    has_modrm = 1'b1;
                    uses_memory = 1'b1;
                end
                
                8'b1000_11??: begin  // MOV r, r/m (8A-8D)
                    format = `V60_FMT_V;
                    data_type = opcode_byte[0] ? `V60_TYPE_WORD : `V60_TYPE_BYTE;
                    has_modrm = 1'b1;
                    uses_memory = 1'b1;
                end
                
                8'b1011_????: begin  // MOV r, imm (B0-BF)
                    format = `V60_FMT_III;
                    dst_reg = {1'b0, opcode_byte[3:0]}; // Extend to 5 bits
                    data_type = opcode_byte[3] ? `V60_TYPE_WORD : `V60_TYPE_BYTE;
                    immediate_size = opcode_byte[3] ? 2'd2 : 2'd0; // 4 bytes or 1 byte
                    inst_length = opcode_byte[3] ? 3'd5 : 3'd2;
                end
                
                // ALU instructions
                8'b0000_00??: begin  // ADD r/m, r
                    format = `V60_FMT_V;
                    data_type = opcode_byte[0] ? `V60_TYPE_WORD : `V60_TYPE_BYTE;
                    has_modrm = 1'b1;
                end
                
                8'b0000_10??: begin  // ADD r, r/m
                    format = `V60_FMT_V;
                    data_type = opcode_byte[0] ? `V60_TYPE_WORD : `V60_TYPE_BYTE;
                    has_modrm = 1'b1;
                end
                
                8'b0010_10??: begin  // SUB r/m, r
                    format = `V60_FMT_V;
                    data_type = opcode_byte[0] ? `V60_TYPE_WORD : `V60_TYPE_BYTE;
                    has_modrm = 1'b1;
                end
                
                // Jump/Branch instructions
                8'b1110_1011: begin  // JMP rel8
                    format = `V60_FMT_III;
                    immediate_size = 2'd0; // 1 byte
                    inst_length = 3'd2;
                end
                
                8'b1110_1001: begin  // JMP rel32
                    format = `V60_FMT_III;
                    immediate_size = 2'd2; // 4 bytes
                    inst_length = 3'd5;
                end
                
                8'b0111_????: begin  // Jcc rel8 (conditional jumps)
                    format = `V60_FMT_III;
                    immediate_size = 2'd0; // 1 byte
                    inst_length = 3'd2;
                end
                
                // Stack operations
                8'b0101_0???: begin  // PUSH r
                    format = `V60_FMT_II;
                    src_reg = {2'b00, opcode_byte[2:0]}; // Extend to 5 bits
                    uses_memory = 1'b1;
                end
                
                8'b0101_1???: begin  // POP r
                    format = `V60_FMT_II;
                    dst_reg = {2'b00, opcode_byte[2:0]}; // Extend to 5 bits
                    uses_memory = 1'b1;
                end
                
                // NOP
                8'b1001_0000: begin  // NOP
                    format = `V60_FMT_I;
                    inst_length = 3'd1;
                end
                
                // HALT
                8'b1111_0100: begin  // HLT
                    format = `V60_FMT_I;
                    inst_length = 3'd1;
                end
                
                default: begin
                    illegal = 1'b1;
                end
            endcase
            
            // Handle ModR/M byte decoding
            if (has_modrm && inst_length == 3'd1) begin
                modrm = inst[39:32];
                mod_field = modrm[7:6];
                reg_field = modrm[5:3];
                rm_field = modrm[2:0];
                
                inst_length = 3'd2; // At least 2 bytes with ModR/M
                
                // Decode addressing mode
                case (mod_field)
                    2'b00: begin // No displacement (except special cases)
                        if (rm_field == 3'b101) begin
                            displacement_size = 2'd2; // 32-bit displacement
                            inst_length = 3'd6;
                        end else if (rm_field == 3'b100) begin
                            has_sib = 1'b1;
                            inst_length = 3'd3;
                        end
                    end
                    2'b01: begin // 8-bit displacement
                        displacement_size = 2'd0;
                        inst_length = has_sib ? 3'd4 : 3'd3;
                    end
                    2'b10: begin // 32-bit displacement
                        displacement_size = 2'd2;
                        inst_length = has_sib ? 3'd7 : 3'd6;
                    end
                    2'b11: begin // Register direct
                        uses_memory = 1'b0;
                        src_reg = rm_field;
                        dst_reg = reg_field;
                    end
                endcase
            end
            
            // Extract immediate value
            case (immediate_size)
                2'd0: immediate = {{24{inst[31]}}, inst[31:24]}; // Sign-extend 8-bit
                2'd1: immediate = {{16{inst[23]}}, inst[23:8]};  // Sign-extend 16-bit
                2'd2: immediate = inst[15:0];                     // 32-bit
                default: immediate = 32'h0;
            endcase
        end
    end

endmodule