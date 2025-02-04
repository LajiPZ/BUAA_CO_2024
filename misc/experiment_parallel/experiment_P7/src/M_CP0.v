`include "parameters.v"

`define SR C0RF[12]
`define CAUSE C0RF[13]
`define EPC C0RF[14]

`define SR_IM 15:10
`define SR_EXL 1
`define SR_IE 0

`define CAUSE_BD 31
`define CAUSE_IP 15:10
`define CAUSE_ExcCode 6:2

// Note: Seems sel doesn't work on all of above; sel isn't implemented

module CP0 (
    input clk,rst,

    input [4:0] ADDR_REG,   // Designed for direct reading
    input we_REG,
    input [31:0] WD,    
    output [31:0] RD,

    input [31:0] VPC,   // the PC when exception happened
    input db_VPC,
    input EXCEPTION,
    input [4:0] EXCEPTION_TYPE,
    input [5:0] HARDWARE_INTERRUPT,
    input rst_EXL,
    
    output enter_HANDLER,
    output [31:0] ADDR_HANDLER,
    output [31:0] EPC

);

reg [31:0] C0RF [0:31];

integer i;
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        C0RF[i] <= 32'd0;
    end
end

// Enter Handler?
    wire [5:0] _IM, _IP;
    wire _EXL, _IE;
    wire [4:0] _ExcCode;

    assign _IM = `SR[`SR_IM],
        _IP = `CAUSE[`CAUSE_IP],
        _EXL = `SR[`SR_EXL],
        _IE = `SR[`SR_IE],
        _ExcCode = `CAUSE[`CAUSE_ExcCode];

    wire _INTERRUPT, _EXCEPTION;
    assign _INTERRUPT = ( (|(HARDWARE_INTERRUPT & _IM)) & _IE & !_EXL),
           _EXCEPTION = EXCEPTION & !_EXL;

    assign enter_HANDLER = (_INTERRUPT | _EXCEPTION);
    assign ADDR_HANDLER = 32'h0000_4180;    // MUX may be required?
    //assign ADDR_HANDLER = 32'h0000_3310;

    wire [4:0] _EXCEPTION_TYPE = (_INTERRUPT) ? `Int : EXCEPTION_TYPE; 

always @(posedge clk) begin
    if(rst) begin
        for (i = 0; i < 32; i = i + 1) begin
            C0RF[i] <= 32'd0;
        end
    end else begin 
        `CAUSE[`CAUSE_IP] = HARDWARE_INTERRUPT; // Guaranteed: No writing to Cause, therefore it's safe
        if (_EXCEPTION | _INTERRUPT) begin
            `EPC = (db_VPC) ? (VPC - 4) : VPC;
            `SR[`SR_EXL] = 1'b1;
            `CAUSE[`CAUSE_BD] = db_VPC;
            `CAUSE[`CAUSE_ExcCode] = _EXCEPTION_TYPE;
        end else if (rst_EXL) begin
            `SR[`SR_EXL] <= 1'b0;
        end else if (we_REG) begin
            C0RF[ADDR_REG] <= WD;
        end
    end
end

assign RD = C0RF[ADDR_REG];
assign EPC = `EPC;

endmodule