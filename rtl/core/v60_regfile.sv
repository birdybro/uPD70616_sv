`include "v60_defines.sv"

module v60_regfile (
    input  logic                       clk,
    input  logic                       rst_n,
    
    // Read port 1
    input  logic [4:0]                 raddr1,
    output logic [`V60_REG_WIDTH-1:0]  rdata1,
    
    // Read port 2
    input  logic [4:0]                 raddr2,
    output logic [`V60_REG_WIDTH-1:0]  rdata2,
    
    // Write port
    input  logic [4:0]                 waddr,
    input  logic [`V60_REG_WIDTH-1:0]  wdata,
    input  logic                       wen
);

    // Register file storage
    logic [`V60_REG_WIDTH-1:0] registers [0:`V60_NUM_REGS-1];
    
    // Read operations (combinational)
    always_comb begin
        rdata1 = registers[raddr1];
        rdata2 = registers[raddr2];
    end
    
    // Write operation (sequential)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Initialize all registers to 0
            for (int i = 0; i < `V60_NUM_REGS; i++) begin
                registers[i] <= 32'h0000_0000;
            end
        end else begin
            if (wen) begin
                registers[waddr] <= wdata;
            end
        end
    end
    
    // Synthesis optimization attributes
    // synthesis syn_ramstyle = "registers"
    // synthesis syn_keep = 1

endmodule