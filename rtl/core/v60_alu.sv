`include "v60_defines.sv"

module v60_alu (
    input  logic [31:0]  a,          // Operand A
    input  logic [31:0]  b,          // Operand B
    input  logic [3:0]   op,         // ALU operation
    output logic [31:0]  result,     // Result
    output logic         c_out,      // Carry out
    output logic         v_out,      // Overflow out
    output logic         z_out,      // Zero out
    output logic         s_out       // Sign out
);

    // ALU operation encoding
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_NOT  = 4'b0101;
    localparam ALU_SHL  = 4'b0110;
    localparam ALU_SHR  = 4'b0111;
    localparam ALU_SAR  = 4'b1000;
    localparam ALU_ROL  = 4'b1001;
    localparam ALU_ROR  = 4'b1010;
    localparam ALU_INC  = 4'b1011;
    localparam ALU_DEC  = 4'b1100;
    localparam ALU_NEG  = 4'b1101;
    localparam ALU_PASS = 4'b1110;
    localparam ALU_CMP  = 4'b1111;
    
    // Internal signals
    logic [32:0] add_result;
    logic [32:0] sub_result;
    logic [4:0]  shift_amount;
    
    // Shift amount limited to 5 bits for 32-bit operations
    assign shift_amount = b[4:0];
    
    // Perform operations
    always_comb begin
        // Default values
        result = 32'h0;
        c_out = 1'b0;
        v_out = 1'b0;
        
        case (op)
            ALU_ADD: begin
                add_result = {1'b0, a} + {1'b0, b};
                result = add_result[31:0];
                c_out = add_result[32];
                v_out = (a[31] == b[31]) && (result[31] != a[31]);
            end
            
            ALU_SUB: begin
                sub_result = {1'b0, a} - {1'b0, b};
                result = sub_result[31:0];
                c_out = sub_result[32];
                v_out = (a[31] != b[31]) && (result[31] != a[31]);
            end
            
            ALU_AND: begin
                result = a & b;
            end
            
            ALU_OR: begin
                result = a | b;
            end
            
            ALU_XOR: begin
                result = a ^ b;
            end
            
            ALU_NOT: begin
                result = ~a;
            end
            
            ALU_SHL: begin
                result = a << shift_amount;
                c_out = (shift_amount != 0) ? a[32 - shift_amount] : 1'b0;
            end
            
            ALU_SHR: begin
                result = a >> shift_amount;
                c_out = (shift_amount != 0) ? a[shift_amount - 1] : 1'b0;
            end
            
            ALU_SAR: begin
                result = $signed(a) >>> shift_amount;
                c_out = (shift_amount != 0) ? a[shift_amount - 1] : 1'b0;
            end
            
            ALU_ROL: begin
                result = (a << shift_amount) | (a >> (32 - shift_amount));
                c_out = result[0];
            end
            
            ALU_ROR: begin
                result = (a >> shift_amount) | (a << (32 - shift_amount));
                c_out = result[31];
            end
            
            ALU_INC: begin
                add_result = {1'b0, a} + 33'd1;
                result = add_result[31:0];
                c_out = add_result[32];
                v_out = (a == 32'h7FFF_FFFF);
            end
            
            ALU_DEC: begin
                sub_result = {1'b0, a} - 33'd1;
                result = sub_result[31:0];
                c_out = sub_result[32];
                v_out = (a == 32'h8000_0000);
            end
            
            ALU_NEG: begin
                sub_result = 33'd0 - {1'b0, a};
                result = sub_result[31:0];
                c_out = (a != 32'h0);
                v_out = (a == 32'h8000_0000);
            end
            
            ALU_PASS: begin
                result = a;
            end
            
            ALU_CMP: begin
                sub_result = {1'b0, a} - {1'b0, b};
                result = sub_result[31:0];
                c_out = sub_result[32];
                v_out = (a[31] != b[31]) && (result[31] != a[31]);
            end
            
            default: begin
                result = 32'h0;
            end
        endcase
        
        // Flag calculations
        z_out = (result == 32'h0);
        s_out = result[31];
    end

endmodule