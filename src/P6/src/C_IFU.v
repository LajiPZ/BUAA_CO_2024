`timescale 1ns / 1ps
module IFU(
        input [31:0] NPC,
        input clk,rst,
        output [31:0] INS,
        output [31:0] PC,

        output [31:0] ins_addr,
        input [31:0] ins_rd
    );

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
    assign INS = ins_rd;
endmodule
