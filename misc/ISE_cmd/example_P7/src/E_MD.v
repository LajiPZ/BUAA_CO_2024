`timescale 1ns / 1ps

module MD(
	input clk,rst,
	input start,
	output reg busy,
	input MDOp,
	input MDSigned,
	input MDOvrd,
	input MDOvrdDest,
	input [31:0] D1, D2,
	output [31:0] LO, HI,
	output ovrd_hi, ovrd_lo
    );
	 
	reg [31:0] LO_reg, HI_reg;
	reg [3:0] timer;
	reg status;

	reg ovrd_hi_reg, ovrd_lo_reg;
	reg [63:0] calc_result_reg;

	wire [63:0] calc_result;
	wire [63:0] mul, div;
	wire [63:0] mul_signed, mul_unsigned;

	wire [63:0] div_signed, div_unsigned;
	wire [31:0] q_signed, q_unsigned, r_signed, r_unsigned;

	wire lo_ovrd, hi_ovrd;
	
	assign mul_signed = $signed(D1) * $signed(D2);
	assign mul_unsigned = D1 * D2;
	
	assign q_signed = $signed(D1) / $signed(D2);
	assign q_unsigned = D1 / D2;
	assign r_signed = $signed(D1) % $signed(D2);
	assign r_unsigned = D1 % D2;
	assign div_signed = {r_signed,q_signed};
	assign div_unsigned = {r_unsigned,q_unsigned};
	
	assign mul = (MDSigned) ? mul_signed : mul_unsigned;
	assign div = (MDSigned) ? div_signed : div_unsigned;
	
	assign calc_result = (MDOp) ? mul : div;

	assign lo_ovrd = MDOvrd & !MDOvrdDest,
		   hi_ovrd = MDOvrd & MDOvrdDest;

	
	always @(posedge clk) begin
		if(rst) begin
			LO_reg <= 32'b0;
			HI_reg <= 32'b0;
			timer <= 4'b0;
			status <= 1'b0;
			ovrd_hi_reg <= 1'b0;
			ovrd_lo_reg <= 1'b0;
			busy <= 1'b0;
			calc_result_reg <= 64'b0;
		end else begin
			if(lo_ovrd) begin
				LO_reg <= D1;
				ovrd_lo_reg <= 1'b1;
			end
			if(hi_ovrd) begin
				HI_reg <= D1;
				ovrd_hi_reg <= 1'b1;
			end

			if(start) begin
				timer <= (MDOp) ? 4'd4 : 4'd9; // Intentional -1
				status <= 1'b1;
				// Override never happens when signal "start" is high
				ovrd_hi_reg <= 1'b0;
				ovrd_lo_reg <= 1'b0;
				calc_result_reg <= calc_result;
				busy <= 1'b1;
			end else if(status) begin
				timer <= timer - 1;
				
				if(timer == 5'b0) begin
					busy <= 1'b0;
					status <= 1'b0;
					if(!hi_ovrd & !ovrd_hi_reg) HI_reg <= calc_result_reg[63:32];
					if(!lo_ovrd & !ovrd_lo_reg) LO_reg <= calc_result_reg[31:0];
				end
			end
		end
	end
	
	assign LO = LO_reg, 
		   HI = HI_reg;

	assign ovrd_hi = hi_ovrd | ovrd_hi_reg,
		   ovrd_lo = lo_ovrd | ovrd_lo_reg;

endmodule
