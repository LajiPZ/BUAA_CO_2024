`timescale 1ns / 1ps
module EXT(
    input [15:0] A,
    input EXTOp, // Signed?
    output [31:0] B
    );
    assign B = EXTOp ? {{16{A[15]}},A} : {{16{1'b0}},A};

endmodule
