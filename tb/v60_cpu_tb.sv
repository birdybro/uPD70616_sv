`timescale 1ns/1ps
`include "v60_defines.sv"

module v60_cpu_tb;

    // Clock and reset
    logic clk;
    logic rst_n;
    
    // Memory interface signals
    logic                        mem_req;
    logic                        mem_wr;
    logic [1:0]                  mem_size;
    logic [`V60_ADDR_WIDTH-1:0]  mem_addr;
    logic [`V60_DATA_WIDTH-1:0]  mem_wdata;
    logic [`V60_DATA_WIDTH-1:0]  mem_rdata;
    logic                        mem_ready;
    
    // Interrupt interface
    logic                        nmi;
    logic [7:0]                  irq;
    logic                        int_ack;
    logic [7:0]                  int_vector;
    
    // Debug interface
    logic [`V60_ADDR_WIDTH-1:0]  pc_out;
    logic [15:0]                 psw_out;
    logic                        halted;
    
    // Memory model (simplified)
    logic [7:0] memory [0:1023];  // 1KB of memory for testing
    
    // DUT instantiation
    v60_cpu dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .mem_req    (mem_req),
        .mem_wr     (mem_wr),
        .mem_size   (mem_size),
        .mem_addr   (mem_addr),
        .mem_wdata  (mem_wdata),
        .mem_rdata  (mem_rdata),
        .mem_ready  (mem_ready),
        .nmi        (nmi),
        .irq        (irq),
        .int_ack    (int_ack),
        .int_vector (int_vector),
        .pc_out     (pc_out),
        .psw_out    (psw_out),
        .halted     (halted)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock
    end
    
    // Memory model behavior
    always_ff @(posedge clk) begin
        if (mem_req && !mem_wr) begin
            // Read operation
            case (mem_size)
                2'b00: begin  // Byte
                    mem_rdata <= {24'h0, memory[mem_addr[9:0]]};
                end
                2'b01: begin  // Halfword
                    mem_rdata <= {16'h0, memory[mem_addr[9:0]+1], memory[mem_addr[9:0]]};
                end
                2'b10: begin  // Word
                    mem_rdata <= {memory[mem_addr[9:0]], memory[mem_addr[9:0]+1], 
                                 memory[mem_addr[9:0]+2], memory[mem_addr[9:0]+3]};
                end
                default: mem_rdata <= 32'hDEAD_BEEF;
            endcase
        end
        
        if (mem_req && mem_wr) begin
            // Write operation
            case (mem_size)
                2'b00: begin  // Byte
                    memory[mem_addr[9:0]] <= mem_wdata[7:0];
                end
                2'b01: begin  // Halfword
                    memory[mem_addr[9:0]] <= mem_wdata[7:0];
                    memory[mem_addr[9:0]+1] <= mem_wdata[15:8];
                end
                2'b10: begin  // Word
                    memory[mem_addr[9:0]] <= mem_wdata[7:0];
                    memory[mem_addr[9:0]+1] <= mem_wdata[15:8];
                    memory[mem_addr[9:0]+2] <= mem_wdata[23:16];
                    memory[mem_addr[9:0]+3] <= mem_wdata[31:24];
                end
            endcase
        end
    end
    
    // Memory ready signal (1 cycle delay)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_ready <= 1'b0;
        end else begin
            mem_ready <= mem_req;
        end
    end
    
    // Initialize memory with test program
    initial begin
        // Clear memory
        for (int i = 0; i < 1024; i++) begin
            memory[i] = 8'h00;
        end
        
        // Test original working program first
        // MOV R0, #0x1234  (B8 34 12 00 00)
        memory[0] = 8'hB8;  // MOV R0, imm32
        memory[1] = 8'h34;
        memory[2] = 8'h12;
        memory[3] = 8'h00;
        memory[4] = 8'h00;
        
        // MOV R1, #0x5678  (B9 78 56 00 00)
        memory[5] = 8'hB9;  // MOV R1, imm32
        memory[6] = 8'h78;
        memory[7] = 8'h56;
        memory[8] = 8'h00;
        memory[9] = 8'h00;
        
        // ADD R0, R1  (01 C1)
        memory[10] = 8'h01; // ADD r, r/m
        memory[11] = 8'hC1; // ModRM: 11 000 001 (R0 += R1)
        
        // NOP (90)
        memory[12] = 8'h90;
        
        // HLT (F4)
        memory[13] = 8'hF4;
    end
    
    // Test stimulus
    initial begin
        // Initialize signals
        rst_n = 0;
        nmi = 0;
        irq = 8'h00;
        
        // Generate waveform dump
        $dumpfile("v60_cpu_tb.vcd");
        $dumpvars(0, v60_cpu_tb);
        
        // Reset sequence
        #20 rst_n = 1;
        
        // Let the CPU run
        #1000;
        
        // Check if CPU halted
        if (halted) begin
            $display("CPU halted successfully");
            $display("PC = 0x%08x", pc_out);
            $display("PSW = 0x%04x", psw_out);
        end else begin
            $display("ERROR: CPU did not halt");
        end
        
        // Test interrupt
        #50 irq = 8'h01;
        #100 irq = 8'h00;
        
        // Run a bit more
        #500;
        
        $display("Simulation completed");
        $finish;
    end
    
    // Monitor important signals
    initial begin
        $monitor("Time=%0t PC=0x%08x State=%0d mem_req=%b mem_addr=0x%08x", 
                 $time, pc_out, dut.state, mem_req, mem_addr);
    end

endmodule