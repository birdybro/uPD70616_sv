`include "../core/v60_defines.sv"

module v60_memory_interface (
    input  logic                        clk,
    input  logic                        rst_n,
    
    // CPU interface
    input  logic                        cpu_req,
    input  logic                        cpu_wr,
    input  logic [1:0]                  cpu_size,     // 00=byte, 01=halfword, 10=word
    input  logic [`V60_ADDR_WIDTH-1:0]  cpu_addr,
    input  logic [`V60_DATA_WIDTH-1:0]  cpu_wdata,
    output logic [`V60_DATA_WIDTH-1:0]  cpu_rdata,
    output logic                        cpu_ready,
    
    // MiSTer-compatible external memory interface
    output logic                        mem_clk,
    output logic                        mem_ce_n,     // Chip enable (active low)
    output logic                        mem_oe_n,     // Output enable (active low)
    output logic                        mem_we_n,     // Write enable (active low)
    output logic [3:0]                  mem_be_n,     // Byte enables (active low)
    output logic [`V60_ADDR_WIDTH-1:0]  mem_addr,
    inout  wire  [`V60_DATA_WIDTH-1:0]  mem_data,     // Bidirectional data bus
    input  logic                        mem_wait      // Wait state input
);

    // State machine for memory access
    typedef enum logic [2:0] {
        IDLE,
        READ_SETUP,
        READ_ACCESS,
        READ_HOLD,
        WRITE_SETUP,
        WRITE_ACCESS,
        WRITE_HOLD
    } mem_state_t;
    
    mem_state_t state, next_state;
    
    // Internal registers
    logic [`V60_DATA_WIDTH-1:0] read_data_reg;
    logic [`V60_DATA_WIDTH-1:0] write_data_reg;
    logic [3:0]                 byte_enables;
    logic                       data_oe;  // Output enable for data bus
    
    // Generate byte enables based on size and address
    always_comb begin
        byte_enables = 4'b1111;  // Default all enabled (active low -> 0000)
        
        case (cpu_size)
            2'b00: begin  // Byte access
                case (cpu_addr[1:0])
                    2'b00: byte_enables = 4'b1110;
                    2'b01: byte_enables = 4'b1101;
                    2'b10: byte_enables = 4'b1011;
                    2'b11: byte_enables = 4'b0111;
                endcase
            end
            2'b01: begin  // Halfword access
                case (cpu_addr[1])
                    1'b0: byte_enables = 4'b1100;
                    1'b1: byte_enables = 4'b0011;
                endcase
            end
            2'b10: begin  // Word access
                byte_enables = 4'b0000;  // All bytes enabled
            end
            default: byte_enables = 4'b1111;  // No access
        endcase
    end
    
    // State machine
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // Next state logic
    always_comb begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (cpu_req) begin
                    if (cpu_wr) begin
                        next_state = WRITE_SETUP;
                    end else begin
                        next_state = READ_SETUP;
                    end
                end
            end
            
            READ_SETUP: begin
                next_state = READ_ACCESS;
            end
            
            READ_ACCESS: begin
                if (!mem_wait) begin
                    next_state = READ_HOLD;
                end
            end
            
            READ_HOLD: begin
                next_state = IDLE;
            end
            
            WRITE_SETUP: begin
                next_state = WRITE_ACCESS;
            end
            
            WRITE_ACCESS: begin
                if (!mem_wait) begin
                    next_state = WRITE_HOLD;
                end
            end
            
            WRITE_HOLD: begin
                next_state = IDLE;
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end
    
    // Output logic
    always_comb begin
        // Default values
        mem_ce_n = 1'b1;
        mem_oe_n = 1'b1;
        mem_we_n = 1'b1;
        mem_be_n = 4'b1111;
        mem_addr = cpu_addr;
        data_oe = 1'b0;
        cpu_ready = 1'b0;
        
        case (state)
            IDLE: begin
                cpu_ready = 1'b1;
            end
            
            READ_SETUP, READ_ACCESS: begin
                mem_ce_n = 1'b0;
                mem_oe_n = 1'b0;
                mem_be_n = byte_enables;
            end
            
            READ_HOLD: begin
                cpu_ready = 1'b1;
            end
            
            WRITE_SETUP, WRITE_ACCESS: begin
                mem_ce_n = 1'b0;
                mem_we_n = 1'b0;
                mem_be_n = byte_enables;
                data_oe = 1'b1;
            end
            
            WRITE_HOLD: begin
                cpu_ready = 1'b1;
            end
        endcase
    end
    
    // Data bus handling
    assign mem_data = data_oe ? write_data_reg : 32'hZZZZ_ZZZZ;
    
    // Capture read data
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_data_reg <= 32'h0;
        end else if (state == READ_ACCESS && !mem_wait) begin
            read_data_reg <= mem_data;
        end
    end
    
    // Prepare write data with proper byte alignment
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_data_reg <= 32'h0;
        end else if (state == IDLE && cpu_req && cpu_wr) begin
            case (cpu_size)
                2'b00: begin  // Byte
                    case (cpu_addr[1:0])
                        2'b00: write_data_reg <= {24'h0, cpu_wdata[7:0]};
                        2'b01: write_data_reg <= {16'h0, cpu_wdata[7:0], 8'h0};
                        2'b10: write_data_reg <= {8'h0, cpu_wdata[7:0], 16'h0};
                        2'b11: write_data_reg <= {cpu_wdata[7:0], 24'h0};
                    endcase
                end
                2'b01: begin  // Halfword
                    case (cpu_addr[1])
                        1'b0: write_data_reg <= {16'h0, cpu_wdata[15:0]};
                        1'b1: write_data_reg <= {cpu_wdata[15:0], 16'h0};
                    endcase
                end
                2'b10: begin  // Word
                    write_data_reg <= cpu_wdata;
                end
                default: write_data_reg <= cpu_wdata;
            endcase
        end
    end
    
    // Extract read data with proper byte alignment
    always_comb begin
        cpu_rdata = read_data_reg;
        
        case (cpu_size)
            2'b00: begin  // Byte
                case (cpu_addr[1:0])
                    2'b00: cpu_rdata = {{24{read_data_reg[7]}}, read_data_reg[7:0]};
                    2'b01: cpu_rdata = {{24{read_data_reg[15]}}, read_data_reg[15:8]};
                    2'b10: cpu_rdata = {{24{read_data_reg[23]}}, read_data_reg[23:16]};
                    2'b11: cpu_rdata = {{24{read_data_reg[31]}}, read_data_reg[31:24]};
                endcase
            end
            2'b01: begin  // Halfword
                case (cpu_addr[1])
                    1'b0: cpu_rdata = {{16{read_data_reg[15]}}, read_data_reg[15:0]};
                    1'b1: cpu_rdata = {{16{read_data_reg[31]}}, read_data_reg[31:16]};
                endcase
            end
            2'b10: begin  // Word
                cpu_rdata = read_data_reg;
            end
            default: cpu_rdata = read_data_reg;
        endcase
    end
    
    // Memory clock (can be same as system clock or divided)
    assign mem_clk = clk;

endmodule