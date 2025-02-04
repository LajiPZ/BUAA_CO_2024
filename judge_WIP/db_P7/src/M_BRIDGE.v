`include "parameters.v"
module BRIDGE (
    input clk,rst,

    input [31:0] ADDR,
    input [31:0] WD,
    output [31:0] RD,
    input WE,
    input [1:0] R_W_Op,

    input load, store,
    output exception,
    output [4:0] exception_type,

    input interrupt_IntGen,
    output [31:0] m_int_addr,     
    output reg [3:0] m_int_byteen,   

    output [5:0] interrupt_src,

    output oor
);

// Range
    wire _range_Timer0, _range_Timer1, _range_IntGen;
    assign _range_Timer0 = (ADDR >= 32'h0000_7F00) & (ADDR <= 32'h0000_7F0B),
        _range_Timer1 = (ADDR >= 32'h0000_7F10) & (ADDR <= 32'h0000_7F1B),
        _range_IntGen = (ADDR >= 32'h0000_7F20) & (ADDR <= 32'h0000_7F23);

// WE
    wire _Timer0_WE, _Timer1_WE, _IntGen_WE;
    assign _Timer0_WE = _range_Timer0 & WE,
           _Timer1_WE = _range_Timer1 & WE,
           _IntGen_WE = _range_IntGen & WE;

// Timer0
    // Outputs
        wire [31:0] _Timer0_RD;
        wire _Timer0_interrupt;
    TC Timer0(
        .clk(clk), .reset(rst),
        .Addr(ADDR[31:2]), .WE(_Timer0_WE), .Din(WD), .Dout(_Timer0_RD), 
        .IRQ(_Timer0_interrupt)
    );

// Timer1
    // Outputs
        wire [31:0] _Timer1_RD;
        wire _Timer1_interrupt;
    TC Timer1(
        .clk(clk), .reset(rst),
        .Addr(ADDR[31:2]), .WE(_Timer1_WE), .Din(WD), .Dout(_Timer1_RD), 
        .IRQ(_Timer1_interrupt)
    );

// IntGen
    // Outputs
        wire [31:0] _IntGen_RD; // Whoops! We can't read it, GROUNDED
        wire _IntGen_interrupt;
    // Binding
        assign _IntGen_interrupt = interrupt_IntGen;
        assign m_int_addr = ADDR;

        always @(*) begin
            if (_IntGen_WE) begin
                case(R_W_Op)
                    `dm_word: begin
                        m_int_byteen = 4'b1111;
                    end
                    `dm_half:begin
                        case(ADDR[1])
                            1'b1: m_int_byteen = 4'b1100;
                            1'b0: m_int_byteen = 4'b0011;
                        endcase
                    end
                    `dm_byte:begin
                        case(ADDR[1:0])
                            2'b11: m_int_byteen = 4'b1000;
                            2'b10: m_int_byteen = 4'b0100;
                            2'b01: m_int_byteen = 4'b0010;
                            2'b00: m_int_byteen = 4'b0001;
                        endcase
                    end
                endcase
            end else begin
                m_int_byteen = 4'b0000;
            end
        end

        assign _IntGen_RD = 32'b0;

// RD
assign RD = (_range_Timer0) ? _Timer0_RD :
            (_range_Timer1) ? _Timer1_RD :
            (_range_IntGen) ? _IntGen_RD :
            32'b0;

// Exception

    assign oor = !_range_Timer0 & !_range_Timer1 & !_range_IntGen;

    wire _non_word_timer_reg;
    assign _non_word_timer_reg = (R_W_Op != `dm_word) & (_range_Timer0 | _range_Timer1);

    wire _store_to_cnt;
    assign _store_to_cnt = (ADDR == 32'h0000_7F08) | (ADDR == 32'h0000_7F18);

    wire _align_word, _align_half;
    assign _align_word = (ADDR[1:0] == 2'b0),
           _align_half = (ADDR[0] == 1'b0);

    wire _align = (R_W_Op == `dm_word & !_align_word) | (R_W_Op == `dm_half & !_align_half);

    wire _AdEL, _AdES;
    assign _AdEL = load & (_non_word_timer_reg | _align),
        _AdES = store & (_non_word_timer_reg | _store_to_cnt | _align);

    wire _Int;
    assign _Int = _Timer0_interrupt | _Timer1_interrupt | _IntGen_interrupt;


    wire _exception;
    assign _exception = _AdEL | _AdES;

    assign exception = _exception;
    assign exception_type = (_AdEL) ? `AdEL :
                            (_AdES) ? `AdES :
                            `Int;

    assign {interrupt_src[5:3],interrupt_src[2],interrupt_src[1],interrupt_src[0]} = {3'b0,_IntGen_interrupt, _Timer1_interrupt, _Timer0_interrupt};
        
    
endmodule