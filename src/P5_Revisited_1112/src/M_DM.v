`timescale 1ns / 1ps
module DM(
    input DMWe,
    input clk,rst,
    input [31:0] ADDR,WD,
    input [31:0] PC,
    output [31:0] RD
    );

integer i;
reg [31:0] DM_REG [0:3071];


initial begin
for (i = 0; i < 3072; i = i + 1) begin
            DM_REG[i] <= 32'b0;
end
end

always @(posedge clk) begin
    if (rst) begin
        for (i = 0; i < 3072; i = i + 1) begin
            DM_REG[i] <= 32'b0;
        end
    end else begin
        if (DMWe) begin
            $display("%d@%h: *%h <= %h", $time, PC, ADDR, WD);
            DM_REG[ADDR[13:2]] <= WD;
        end
    end
end
assign RD = DM_REG[ADDR[13:2]];

endmodule
