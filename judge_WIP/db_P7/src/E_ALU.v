`timescale 1ns / 1ps
`include "parameters.v"
module ALU(
    input [31:0] A,B,
    input [4:0] SHAMT,
    input [3:0] ALUOp,
    output reg [31:0] C,

    input overflow, load, store,
    output exception,
    output [4:0] exception_type
    );

    reg [32:0] _temp;

    reg _overflow;

    initial begin
        _overflow = 1'b0;
    end

    always @(*) begin
        case(ALUOp) 
          `alu_add: begin
              _temp = {A[31],A} + {B[31],B};
              C = _temp[31:0];
              _overflow = (_temp[32] != _temp[31]);
          end
          `alu_sub: begin 
              _temp = {A[31],A} - {B[31],B};
              C = _temp[31:0];
              _overflow = (_temp[32] != _temp[31]);
          end
          `alu_or: C = A | B;
          `alu_sll: C = B << SHAMT;
          `alu_and: C = A & B;
        endcase
    end

    assign exception = _overflow & (overflow | load | store);
    assign exception_type = (overflow) ? `Ov : 
                            (load) ? `AdEL : 
                            (store) ? `AdES : 
                            `Ov;


endmodule
