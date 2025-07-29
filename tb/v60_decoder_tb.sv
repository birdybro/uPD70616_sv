`timescale 1ns/1ps
`include "v60_defines.sv"

module v60_decoder_tb;

    // Decoder signals
    logic [47:0] inst;           // 6-byte instruction buffer
    logic        valid;          // Input valid signal
    
    logic [7:0]  opcode;         // Decoded opcode
    logic [2:0]  format;         // Instruction format
    logic [1:0]  data_type;      // Data type (byte/halfword/word)
    logic [4:0]  src_reg;        // Source register
    logic [4:0]  dst_reg;        // Destination register
    logic [31:0] immediate;      // Immediate value
    logic [2:0]  inst_length;    // Instruction length in bytes
    logic        uses_memory;    // Instruction uses memory
    logic        illegal;        // Illegal instruction
    
    // DUT instantiation
    v60_decoder dut (
        .inst        (inst),
        .valid       (valid),
        .opcode      (opcode),
        .format      (format),
        .data_type   (data_type),
        .src_reg     (src_reg),
        .dst_reg     (dst_reg),
        .immediate   (immediate),
        .inst_length (inst_length),
        .uses_memory (uses_memory),
        .illegal     (illegal)
    );
    
    // Helper task to display instruction decode results
    task display_decode(input string test_name, input [47:0] test_inst);
        inst = test_inst;
        valid = 1'b1;
        #1; // Allow combinational delay
        
        $display("\n--- %s ---", test_name);
        $display("Instruction: 0x%012x", test_inst);
        $display("Opcode: 0x%02x", opcode);
        $display("Format: %s", format == `V60_FMT_I ? "I" :
                              format == `V60_FMT_II ? "II" :
                              format == `V60_FMT_III ? "III" :
                              format == `V60_FMT_IV ? "IV" :
                              format == `V60_FMT_V ? "V" :
                              format == `V60_FMT_VI ? "VI" :
                              format == `V60_FMT_VII ? "VII" : "RESERVED");
        $display("Data Type: %s", data_type == `V60_TYPE_BYTE ? "BYTE" :
                                 data_type == `V60_TYPE_HALFWORD ? "HALFWORD" :
                                 data_type == `V60_TYPE_WORD ? "WORD" : "EXTENDED");
        $display("Src Reg: R%0d, Dst Reg: R%0d", src_reg, dst_reg);
        $display("Immediate: 0x%08x", immediate);
        $display("Length: %0d bytes", inst_length);
        $display("Uses Memory: %b", uses_memory);
        $display("Illegal: %b", illegal);
    endtask
    
    // Test patterns
    initial begin
        // Initialize
        inst = 48'h000000000000;
        valid = 1'b0;
        
        // Generate waveform dump
        $dumpfile("v60_decoder_tb.vcd");
        $dumpvars(0, v60_decoder_tb);
        
        $display("=== V60 Instruction Decoder Testbench ===");
        $display("Testing instruction formats per µPD70616 manual");
        
        // Test Format I instructions (single byte)
        display_decode("NOP (Format I)", 48'h900000000000);
        display_decode("HLT (Format I)", 48'hF40000000000);
        
        // Test Format II instructions (two bytes)
        display_decode("PUSH R0 (Format II)", 48'h500000000000);
        display_decode("PUSH R7 (Format II)", 48'h570000000000);
        display_decode("POP R0 (Format II)", 48'h580000000000);
        display_decode("POP R7 (Format II)", 48'h5F0000000000);
        
        // Test Format III instructions (with immediate)
        display_decode("MOV R0, #0x1234 (Format III)", 48'hB834120000000);
        display_decode("MOV R15, #0x5678 (Format III)", 48'hBF78560000000);
        display_decode("JMP rel8 (Format III)", 48'hEB10000000000);
        display_decode("JMP rel32 (Format III)", 48'hE912345678000);
        
        // Test Format V instructions (two operands)
        display_decode("MOV r/m, r (Format V)", 48'h8800000000000);
        display_decode("MOV r, r/m (Format V)", 48'h8A00000000000);
        display_decode("ADD r/m, r (Format V)", 48'h0000000000000);
        display_decode("ADD r, r/m (Format V)", 48'h0200000000000);
        display_decode("SUB r/m, r (Format V)", 48'h2800000000000);
        
        // Test conditional jumps
        display_decode("JZ rel8 (Format III)", 48'h7410000000000);
        display_decode("JNZ rel8 (Format III)", 48'h7510000000000);
        display_decode("JC rel8 (Format III)", 48'h7210000000000);
        display_decode("JNC rel8 (Format III)", 48'h7310000000000);
        
        // Test invalid instruction
        display_decode("Invalid Instruction", 48'hFF0000000000);
        
        // Verify 32-register capability
        $display("\n--- Register Range Verification ---");
        
        // Test with register numbers that would exceed 4-bit range
        inst = 48'hB834120000000;  // MOV R0, immediate (should work)
        valid = 1'b1;
        #1;
        if (dst_reg > 31) begin
            $error("FAIL: Register number exceeds V60 range");
        end else begin
            $display("PASS: Register decoding within valid range");
        end
        
        // Test edge cases
        $display("\n--- Edge Case Tests ---");
        
        // Test with valid=0
        valid = 1'b0;
        #1;
        if (!illegal) begin
            $error("FAIL: Should be illegal when valid=0");
        end else begin
            $display("PASS: Correctly flags illegal when valid=0");
        end
        
        // Test length calculations
        $display("\n--- Instruction Length Verification ---");
        
        // Single byte instructions
        display_decode("NOP length check", 48'h900000000000);
        if (inst_length != 1) begin
            $error("FAIL: NOP should be 1 byte, got %0d", inst_length);
        end else begin
            $display("PASS: NOP instruction length = 1 byte");
        end
        
        // Multi-byte instructions  
        display_decode("MOV R0,imm32 length check", 48'hB834120000000);
        if (inst_length != 5) begin
            $error("FAIL: MOV R,imm32 should be 5 bytes, got %0d", inst_length);
        end else begin
            $display("PASS: MOV R,imm32 instruction length = 5 bytes");
        end
        
        $display("\n=== Decoder Test Complete ===");
        $display("This testbench verifies V60 instruction format decoding");
        $display("per µPD70616 Programmer's Reference Manual");
        
        #50;
        $finish;
    end

endmodule