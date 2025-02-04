`timescale 1ns / 1ps
`include "parameters.v"
module ALU(
    input [31:0] A,B,
    input [4:0] SHAMT,
    input [3:0] ALUOp,
    output reg [31:0] C
    );

    always @(*) begin
        case(ALUOp) 
          `alu_add: C = A + B;
          `alu_sub: C = A - B;
          `alu_or: C = A | B;
          `alu_sll: C = B << SHAMT;
        endcase
    end

endmodule
