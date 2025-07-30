`include "v60_defines.sv"

module v60_cpu (
    input  logic                        clk,
    input  logic                        rst_n,
    
    // Memory Interface
    output logic                        mem_req,
    output logic                        mem_wr,
    output logic [1:0]                  mem_size,     // 00=byte, 01=halfword, 10=word
    output logic [`V60_ADDR_WIDTH-1:0]  mem_addr,
    output logic [`V60_DATA_WIDTH-1:0]  mem_wdata,
    input  logic [`V60_DATA_WIDTH-1:0]  mem_rdata,
    input  logic                        mem_ready,
    
    // Interrupt Interface
    input  logic                        nmi,
    input  logic [7:0]                  irq,
    output logic                        int_ack,
    output logic [7:0]                  int_vector,
    
    // Debug Interface
    output logic [`V60_ADDR_WIDTH-1:0]  pc_out,
    output logic [15:0]                 psw_out,
    output logic                        halted
);

    // Internal registers
    logic [`V60_ADDR_WIDTH-1:0] pc;           // Program Counter
    logic [`V60_ADDR_WIDTH-1:0] pc_next;
    logic [15:0]                psw;          // Program Status Word
    logic [15:0]                psw_next;
    
    // Pipeline registers
    logic [`V60_ADDR_WIDTH-1:0] fetch_pc;
    logic [47:0]                inst_buffer;  // 6-byte instruction buffer
    logic [2:0]                 inst_length;
    logic [2:0]                 inst_length_reg;  // Registered version
    logic                       inst_valid;
    
    // Control signals
    typedef enum logic [3:0] {
        S_RESET,
        S_FETCH,
        S_DECODE,
        S_EXECUTE,
        S_MEMORY,
        S_WRITEBACK,
        S_EXCEPTION,
        S_HALT
    } cpu_state_t;
    
    cpu_state_t state, state_next;
    
    // Decoded instruction fields
    logic [7:0]  opcode;
    logic [2:0]  format;
    logic [1:0]  data_type;
    logic [4:0]  src_reg;
    logic [4:0]  dst_reg;
    logic [31:0] immediate;
    logic        uses_memory;
    
    // Exception handling
    logic        exception_pending;
    logic [7:0]  exception_vector;
    
    // Register file instance
    logic [4:0]  rf_raddr1, rf_raddr2;
    logic [4:0]  rf_waddr;
    logic [31:0] rf_rdata1, rf_rdata2;
    logic [31:0] rf_wdata;
    logic        rf_wen;
    
    v60_regfile regfile (
        .clk        (clk),
        .rst_n      (rst_n),
        .raddr1     (rf_raddr1),
        .raddr2     (rf_raddr2),
        .rdata1     (rf_rdata1),
        .rdata2     (rf_rdata2),
        .waddr      (rf_waddr),
        .wdata      (rf_wdata),
        .wen        (rf_wen)
    );
    
    // Instruction decoder instance
    logic        decode_valid;
    logic [47:0] decode_inst;
    logic [2:0]  decode_length;
    logic        decode_illegal;
    
    v60_decoder decoder (
        .inst       (decode_inst),
        .valid      (decode_valid),
        .opcode     (opcode),
        .format     (format),
        .data_type  (data_type),
        .src_reg    (src_reg),
        .dst_reg    (dst_reg),
        .immediate  (immediate),
        .inst_length(decode_length),
        .uses_memory(uses_memory),
        .illegal    (decode_illegal)
    );
    
    // ALU instance
    logic [31:0] alu_a, alu_b;
    logic [31:0] alu_result;
    logic [3:0]  alu_op;
    logic        alu_c_out, alu_v_out, alu_z_out, alu_s_out;
    
    v60_alu alu (
        .a          (alu_a),
        .b          (alu_b),
        .op         (alu_op),
        .result     (alu_result),
        .c_out      (alu_c_out),
        .v_out      (alu_v_out),
        .z_out      (alu_z_out),
        .s_out      (alu_s_out)
    );
    
    // State machine
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_RESET;
            pc <= 32'h0000_0000;
            psw <= 16'h0000;
            inst_buffer <= 48'h0;
            inst_valid <= 1'b0;
            inst_length_reg <= 3'b0;
            exception_pending <= 1'b0;
            exception_vector <= 8'h00;
        end else begin
            state <= state_next;
            pc <= pc_next;
            psw <= psw_next;
            
            // Update instruction buffer based on state
            case (state)
                S_FETCH: begin
                    if (mem_ready) begin
                        inst_buffer <= {mem_rdata, inst_buffer[47:32]};
                        inst_valid <= 1'b1;
                    end
                end
                S_DECODE: begin
                    if (decode_illegal) begin
                        exception_pending <= 1'b1;
                        exception_vector <= `V60_VEC_INVALID_OP;
                    end else begin
                        inst_length_reg <= decode_length;
                    end
                end
                default: ;
            endcase
        end
    end
    
    // Next state logic
    always_comb begin
        state_next = state;
        pc_next = pc;
        psw_next = psw;
        
        // Default outputs
        mem_req = 1'b0;
        mem_wr = 1'b0;
        mem_size = 2'b10; // Word
        mem_addr = 32'h0;
        mem_wdata = 32'h0;
        rf_wen = 1'b0;
        
        case (state)
            S_RESET: begin
                state_next = S_FETCH;
                pc_next = 32'h0000_0000; // Reset vector
                psw_next = 16'h0000;
            end
            
            S_FETCH: begin
                mem_req = 1'b1;
                mem_addr = pc;
                if (mem_ready) begin
                    state_next = S_DECODE;
                end
            end
            
            S_DECODE: begin
                decode_inst = inst_buffer;
                decode_valid = inst_valid;
                
                if (decode_illegal) begin
                    state_next = S_EXCEPTION;
                end else if (inst_valid) begin
                    state_next = S_EXECUTE;
                end
            end
            
            S_EXECUTE: begin
                // Check for HALT instruction
                if (opcode == 8'hF4) begin
                    state_next = S_HALT;
                end else begin
                    // Setup ALU inputs
                    rf_raddr1 = src_reg;
                    rf_raddr2 = dst_reg;
                    alu_a = rf_rdata1;
                    alu_b = (format == `V60_FMT_III) ? immediate : rf_rdata2;
                    
                    if (uses_memory) begin
                        state_next = S_MEMORY;
                    end else begin
                        state_next = S_WRITEBACK;
                    end
                end
            end
            
            S_MEMORY: begin
                mem_req = 1'b1;
                mem_addr = alu_result;
                if (mem_ready) begin
                    state_next = S_WRITEBACK;
                end
            end
            
            S_WRITEBACK: begin
                rf_wen = 1'b1;
                rf_waddr = dst_reg;
                rf_wdata = uses_memory ? mem_rdata : alu_result;
                
                // Update PC
                pc_next = pc + {29'b0, inst_length_reg};
                
                // Update PSW flags
                psw_next[`V60_PSW_C] = alu_c_out;
                psw_next[`V60_PSW_V] = alu_v_out;
                psw_next[`V60_PSW_Z] = alu_z_out;
                psw_next[`V60_PSW_S] = alu_s_out;
                
                // Check for interrupts
                if (nmi || (irq != 8'h00 && psw[`V60_PSW_I])) begin
                    state_next = S_EXCEPTION;
                    exception_pending = 1'b1;
                    exception_vector = nmi ? `V60_VEC_NMI : {5'b0, irq[2:0]};
                end else begin
                    state_next = S_FETCH;
                end
            end
            
            S_EXCEPTION: begin
                // Save context and jump to exception handler
                // This is simplified - real implementation needs stack ops
                pc_next = {24'h0, exception_vector, 2'b00}; // Vector table at 0x0
                psw_next[`V60_PSW_I] = 1'b0; // Disable interrupts
                exception_pending = 1'b0;
                state_next = S_FETCH;
            end
            
            S_HALT: begin
                state_next = S_HALT;
            end
        endcase
    end
    
    // ALU operation selection
    always_comb begin
        case (opcode[7:4])
            4'b0000: alu_op = 4'b0000; // ADD (0x00-0x0F)
            4'b0010: alu_op = 4'b0001; // SUB (0x20-0x2F) 
            default: alu_op = 4'b0000; // Default to ADD
        endcase
    end
    
    // Output assignments
    assign pc_out = pc;
    assign psw_out = psw;
    assign halted = (state == S_HALT);
    assign int_ack = (state == S_EXCEPTION) && exception_pending;
    assign int_vector = exception_vector;

endmodule