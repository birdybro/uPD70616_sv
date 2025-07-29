`timescale 1ns/1ps
`include "v60_defines.sv"

module v60_regfile_tb;

    // Clock and reset
    logic clk;
    logic rst_n;
    
    // Register file signals
    logic [4:0]                 raddr1;
    logic [`V60_REG_WIDTH-1:0]  rdata1;
    logic [4:0]                 raddr2;
    logic [`V60_REG_WIDTH-1:0]  rdata2;
    logic [4:0]                 waddr;
    logic [`V60_REG_WIDTH-1:0]  wdata;
    logic                       wen;
    
    // DUT instantiation
    v60_regfile dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .raddr1     (raddr1),
        .rdata1     (rdata1),
        .raddr2     (raddr2),
        .rdata2     (rdata2),
        .waddr      (waddr),
        .wdata      (wdata),
        .wen        (wen)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock
    end
    
    // Test patterns
    initial begin
        // Initialize signals
        rst_n = 0;
        raddr1 = 5'h00;
        raddr2 = 5'h00;
        waddr = 5'h00;
        wdata = 32'h00000000;
        wen = 1'b0;
        
        // Generate waveform dump
        $dumpfile("v60_regfile_tb.vcd");
        $dumpvars(0, v60_regfile_tb);
        
        // Reset sequence
        #20 rst_n = 1;
        #10;
        
        $display("=== V60 Register File Testbench ===");
        $display("Testing 32-register implementation per V60 manual");
        
        // Test 1: Verify all registers reset to 0
        $display("\n--- Test 1: Reset state verification ---");
        for (int i = 0; i < 32; i++) begin
            raddr1 = i;
            #1;  // Allow combinational delay
            if (rdata1 !== 32'h00000000) begin
                $error("FAIL: Register R%0d not reset to 0, got 0x%08x", i, rdata1);
            end else begin
                $display("PASS: Register R%0d = 0x%08x", i, rdata1);
            end
        end
        
        // Test 2: Write to all registers
        $display("\n--- Test 2: Write test to all 32 registers ---");
        for (int i = 0; i < 32; i++) begin
            @(posedge clk);
            waddr = i;
            wdata = 32'hA5A5A5A5 + i;  // Unique pattern per register
            wen = 1'b1;
            @(posedge clk);
            wen = 1'b0;
            
            // Verify write
            raddr1 = i;
            #1;
            if (rdata1 !== (32'hA5A5A5A5 + i)) begin
                $error("FAIL: Register R%0d write failed, expected 0x%08x, got 0x%08x", 
                       i, 32'hA5A5A5A5 + i, rdata1);
            end else begin
                $display("PASS: Register R%0d = 0x%08x", i, rdata1);
            end
        end
        
        // Test 3: Dual-port read test
        $display("\n--- Test 3: Dual-port read test ---");
        for (int i = 0; i < 16; i++) begin
            raddr1 = i;
            raddr2 = 31-i;
            #1;
            $display("Port1: R%0d = 0x%08x, Port2: R%0d = 0x%08x", 
                     i, rdata1, 31-i, rdata2);
            
            if (rdata1 !== (32'hA5A5A5A5 + i)) begin
                $error("FAIL: Port1 read R%0d failed", i);
            end
            if (rdata2 !== (32'hA5A5A5A5 + (31-i))) begin
                $error("FAIL: Port2 read R%0d failed", 31-i);
            end
        end
        
        // Test 4: Special register aliases (AP, FP, SP)
        $display("\n--- Test 4: Special register verification ---");
        
        // Test AP (R29)
        raddr1 = `V60_REG_AP;
        #1;
        $display("AP (R29) = 0x%08x", rdata1);
        if (rdata1 !== (32'hA5A5A5A5 + 29)) begin
            $error("FAIL: AP register access failed");
        end
        
        // Test FP (R30)
        raddr1 = `V60_REG_FP;
        #1;
        $display("FP (R30) = 0x%08x", rdata1);
        if (rdata1 !== (32'hA5A5A5A5 + 30)) begin
            $error("FAIL: FP register access failed");
        end
        
        // Test SP (R31)
        raddr1 = `V60_REG_SP;
        #1;
        $display("SP (R31) = 0x%08x", rdata1);
        if (rdata1 !== (32'hA5A5A5A5 + 31)) begin
            $error("FAIL: SP register access failed");
        end
        
        // Test 5: Write enable functionality
        $display("\n--- Test 5: Write enable test ---");
        @(posedge clk);
        waddr = 5'd15;
        wdata = 32'hDEADBEEF;
        wen = 1'b0;  // Write disabled
        @(posedge clk);
        
        raddr1 = 5'd15;
        #1;
        if (rdata1 === 32'hDEADBEEF) begin
            $error("FAIL: Write occurred when wen=0");
        end else begin
            $display("PASS: Write correctly disabled when wen=0");
        end
        
        // Test 6: Boundary conditions
        $display("\n--- Test 6: Boundary condition tests ---");
        
        // Test register 0
        @(posedge clk);
        waddr = 5'd0;
        wdata = 32'h12345678;
        wen = 1'b1;
        @(posedge clk);
        wen = 1'b0;
        
        raddr1 = 5'd0;
        #1;
        if (rdata1 !== 32'h12345678) begin
            $error("FAIL: Register 0 boundary test failed");
        end else begin
            $display("PASS: Register 0 boundary test passed");
        end
        
        // Test register 31 (highest)
        @(posedge clk);
        waddr = 5'd31;
        wdata = 32'h87654321;
        wen = 1'b1;
        @(posedge clk);
        wen = 1'b0;
        
        raddr1 = 5'd31;
        #1;
        if (rdata1 !== 32'h87654321) begin
            $error("FAIL: Register 31 boundary test failed");
        end else begin
            $display("PASS: Register 31 boundary test passed");
        end
        
        $display("\n=== Register File Test Complete ===");
        $display("This testbench verifies the V60 register file has 32 registers");
        $display("as specified in the µPD70616 Programmer's Reference Manual");
        
        #50;
        $finish;
    end

endmodule