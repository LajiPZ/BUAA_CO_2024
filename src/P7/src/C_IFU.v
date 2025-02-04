`timescale 1ns / 1ps
`include "parameters.v"
module IFU(
        input [31:0] NPC,
        input clk,rst,
        output [31:0] INS,
        output [31:0] PC,

        output [31:0] ins_addr,
        input [31:0] ins_rd,

        output exception,
        output [4:0] exception_type,
        output eret
    );

    // ! Exception
    wire _AdEL;
    assign _AdEL = (PC_reg[1:0] != 2'b0) | 
            ( (PC_reg > 32'h0000_6fff) | (PC_reg < 32'h0000_3000) );

    assign exception = _AdEL;
    assign exception_type = (_AdEL) ? `AdEL : `AdEL;

    // ! eret Special
    wire _eret =  (ins_rd[31:26] == 6'b010000) & (ins_rd[25]) & (ins_rd[5:0] == 6'b011000);
    assign eret = (_AdEL) ? 32'b0 : _eret;

    reg [31:0] PC_reg;
    initial begin
        PC_reg = 32'h0000_3000;
    end

    always @(posedge clk) begin
        if(rst) begin
            PC_reg = 32'h0000_3000;
        end else begin
            PC_reg <= NPC;
        end
    end
    assign PC = PC_reg;

    assign ins_addr = PC_reg;
    assign INS = (_AdEL) ? 32'b0 : ins_rd;


endmodule
