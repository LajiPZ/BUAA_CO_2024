`timescale 1ns / 1ps
module IFU(
        input [31:0] NPC,
        input clk,rst,
        output [31:0] INS,
        output [31:0] PC
    );

    integer i;
    reg [31:0] IM_REG [0:4095]; // 3072 + 1024; 0x00000000 - 0x00002ffff + 0x00003000 - 0x00003fff
    reg [31:0] PC_relative;
    initial begin
        PC_relative = 32'b0;
        $readmemh("code.txt",IM_REG);
    end

    always @(posedge clk) begin
        if(rst) begin
		  PC_relative <= 32'b0;
        end else begin
            PC_relative <= NPC - 32'h0000_3000;
        end
    end
    assign INS = IM_REG[PC_relative[13:2]];
    assign PC = PC_relative + 32'h0000_3000;
endmodule
