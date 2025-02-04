`timescale 1ns / 1ps
module GRF(
    input [4:0] A1,A2,A3,
    input [31:0] WD,
    input [31:0] PC,
    input GRFWe,
    input clk,rst,
    output [31:0] RD1,RD2
    );

    reg [31:0] GRF_REG [0:31]; 
    integer i;
	 
	 initial begin
	 for (i = 0; i < 32; i = i + 1) begin
                GRF_REG[i] <= 32'd0;
            end
	 end

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                GRF_REG[i] <= 32'd0;
            end
        end else if (GRFWe) begin
            $display("@%h: $%d <= %h", PC, A3, WD);
            GRF_REG[A3] <= (A3 == 5'b0) ? 32'b0 : WD;
        end
    end

    assign RD1 = GRF_REG[A1];
    assign RD2 = GRF_REG[A2];
endmodule
