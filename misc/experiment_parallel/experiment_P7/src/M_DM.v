`timescale 1ns / 1ps
`include "parameters.v"
module DM(
    input DMWe,
    input [1:0] DMOp,
    input DMEXTOp,
    input [31:0] ADDR,WD,
    output [31:0] RD,

    input [31:0] PC,
    output [31:0] data_addr,
    output [31:0] data_wd,
    output reg [3:0] data_byte_we,
    output [31:0] data_pc,
    input [31:0] data_rd,

    input load, store,
    output exception,
    output [4:0] exception_type,

    output oor  // Out Of Range
    );

assign data_addr = ADDR,
       data_wd = wd_temp,
       data_pc = PC;

wire _range_DM;
assign _range_DM = (ADDR >= 32'h0000_0000) & (ADDR <= 32'h0000_2fff);

always @(*) begin
    if (DMWe) begin
        case(DMOp)
            `dm_word: begin
                data_byte_we = 4'b1111;
            end
            `dm_half:begin
                case(ADDR[1])
                    1'b1: data_byte_we = 4'b1100;
                    1'b0: data_byte_we = 4'b0011;
                endcase
            end
            `dm_byte:begin
                case(ADDR[1:0])
                    2'b11: data_byte_we = 4'b1000;
                    2'b10: data_byte_we = 4'b0100;
                    2'b01: data_byte_we = 4'b0010;
                    2'b00: data_byte_we = 4'b0001;
                endcase
            end
        endcase
    end else begin
        data_byte_we = 4'b0000;
    end
end

// Write processing

    wire [31:0] wd_temp;
    wire [31:0] wd_half_temp;
    wire [31:0] wd_byte_temp;

    assign wd_half_temp = (ADDR[1] == 1'b1) ? {WD[15:0],{16{1'b0}}} :
                                            {{16{1'b0}},WD[15:0]};

    assign wd_byte_temp = (ADDR[1:0] == 2'b11) ? {WD[7:0],{24{1'b0}}} : 
                        (ADDR[1:0] == 2'b10) ? {{8{1'b0}},WD[7:0],{16{1'b0}}} :
                        (ADDR[1:0] == 2'b01) ? {{16{1'b0}},WD[7:0],{8{1'b0}}} :
                        {{24{1'b0}},WD[7:0]};


    assign wd_temp = (DMOp == `dm_word) ? WD :
                    (DMOp == `dm_half) ? wd_half_temp :
                    wd_byte_temp;



// Extension
    wire [15:0] data_rd_half_temp;
    wire [7:0] data_rd_byte_temp;

    wire [31:0] data_rd_half, data_rd_byte;

    assign data_rd_half_temp = (ADDR[1] == 1'b1) ? data_rd[31:16] : 
                                                data_rd[15:0];

    assign data_rd_byte_temp = (ADDR[1:0] == 2'b11) ? data_rd[31:24] :
                            (ADDR[1:0] == 2'b10) ? data_rd[23:16] :
                            (ADDR[1:0] == 2'b01) ? data_rd[15:8] :
                            data_rd[7:0];

    assign data_rd_half = (DMEXTOp) ? {{16{data_rd_half_temp[15]}},data_rd_half_temp} : 
                                    {{16{1'b0}},data_rd_half_temp};

    assign data_rd_byte = (DMEXTOp) ? {{24{data_rd_byte_temp[7]}},data_rd_byte_temp} :
                                    {{24{1'b0}},data_rd_byte_temp};

    assign RD = (DMOp == `dm_word) ? data_rd : 
                (DMOp == `dm_half) ? data_rd_half :
                                    data_rd_byte ; 


// Exception
    wire _AdEL, _AdES;

    wire _oor;
    assign _oor = !_range_DM;
    assign oor = _oor;

    wire _align_word, _align_half;
    assign _align_word = (ADDR[1:0] == 2'b0),
           _align_half = (ADDR[0] == 1'b0);
        
    assign _AdEL = (load) & ( (DMOp == `dm_word & !_align_word) | (DMOp == `dm_half & !_align_half) ) & _range_DM,
        _AdES = (store) & ( (DMOp == `dm_word & !_align_word) | (DMOp == `dm_half & !_align_half) ) & _range_DM;

    wire _exception;
    assign _exception = _AdEL | _AdES;
    assign exception = _exception;
    assign exception_type = (_AdEL) ? `AdEL :
                            (_AdES) ? `AdES :
                            `AdEL;


endmodule
