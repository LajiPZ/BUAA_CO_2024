`timescale 1ns / 1ps
// Signed comparison
module CMP(
    input [31:0] A1,A2,
    input CMPSigned,
    output EQ,
    output LT
    );
assign EQ = A1 == A2;
wire LT_signed = $signed(A1) < $signed(A2);
wire LT_unsigned = A1 < A2;
assign LT = (CMPSigned) ? LT_signed : LT_unsigned;
endmodule
