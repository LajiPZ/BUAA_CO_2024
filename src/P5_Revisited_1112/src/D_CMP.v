`timescale 1ns / 1ps
// Signed comparison
module CMP(
    input [31:0] A1,A2,
    output EQ,
    output LT
    );
assign EQ = A1 == A2;
assign LT = $signed(A1) < $signed(A2);
endmodule
