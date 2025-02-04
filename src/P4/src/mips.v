`timescale 1ns / 1ps
`include "parameters.v"
module mips( 
    input clk,
    input reset
    );

    // Inputs
    wire [31:0] _IFU_NPC;
    // Outputs
    wire [31:0] _IFU_INS, _IFU_PC;

    IFU Ifu (
        .NPC(_IFU_NPC),
        .clk(clk),.rst(reset),
        .INS(_IFU_INS),
        .PC(_IFU_PC)
    );

    // Inputs
    wire [31:0] _NPC_PC;
    wire [15:0] _NPC_IMM16;
    wire [25:0] _NPC_IMM26;
    wire [31:0] _NPC_IMM32;
    wire [2:0] _NPC_Op, _NPC_Cond;
    wire _NPC_EQ, _NPC_LT;
    // Outputs
    wire [31:0] _NPC_NPC, _NPC_PC4;

    NPC Npc (
        .PC(_NPC_PC),
        .IMM16(_NPC_IMM16), .IMM26(_NPC_IMM26), .IMM32(_NPC_IMM32),
        .NPCOp(_NPC_Op), .NPCCond(_NPC_Cond),
        .EQ(_NPC_EQ), .LT(_NPC_LT),
        .NPC(_NPC_NPC), .PC4(_NPC_PC4)
    );

    // Inputs
    wire [31:0] _CTRL_INS;
    // Outputs
    wire [4:0] _CTRL_RS, _CTRL_RT, _CTRL_RD, _CTRL_SHAMT; 
    wire [15:0] _CTRL_IMM16;
    wire [25:0] _CTRL_IMM26;
    wire [3:0] _CTRL_ALU_Op;
    wire [2:0] _CTRL_NPC_Op,_CTRL_NPC_Cond;
    wire _CTRL_GRF_We, _CTRL_EXT_Signed, _CTRL_DM_We;
    wire [3:0] _CTRL_MGRFA3_c, _CTRL_MGRFWD_c, _CTRL_MALUB_c, _CTRL_MALUSA_c;

    CTRL Ctrl (
        .INS(_CTRL_INS),
        .rs(_CTRL_RS), .rt(_CTRL_RT), .rd(_CTRL_RD), .shamt(_CTRL_SHAMT),
        .imm16(_CTRL_IMM16), .imm26(_CTRL_IMM26),
        .alu_op(_CTRL_ALU_Op), .npc_op(_CTRL_NPC_Op), .npc_cond(_CTRL_NPC_Cond),
        .grf_we(_CTRL_GRF_We), .ext_signed(_CTRL_EXT_Signed), .dm_we(_CTRL_DM_We),
        .mgrfa3_c(_CTRL_MGRFA3_c), .mgrfwd_c(_CTRL_MGRFWD_c), .malub_c(_CTRL_MALUB_c), .malusa_c(_CTRL_MALUSA_c)
    );

    // Inputs
    wire [15:0] _EXT_A;
    wire _EXT_Signed;
    //Outputs
    wire [31:0] _EXT_B;

    EXT Ext (
        .A(_EXT_A),
        .EXTOp(_EXT_Signed),
        .B(_EXT_B)
    );

    // Inputs
    wire [4:0] _GRF_A1, _GRF_A2, _GRF_A3;
    wire [31:0] _GRF_WD;
    wire _GRF_We;
    // Outputs
    wire [31:0] _GRF_RD1, _GRF_RD2;
    
    GRF Grf (
        .A1(_GRF_A1), .A2(_GRF_A2), .A3(_GRF_A3),
        .WD(_GRF_WD),
        .GRFWe(_GRF_We),
        .clk(clk), .rst(reset),
        .RD1(_GRF_RD1), .RD2(_GRF_RD2),
		  .PC(_IFU_PC)
    );

    // Inputs
    wire [31:0] _ALU_A, _ALU_B;
    wire [4:0] _ALU_SHAMT;
    wire [3:0] _ALU_Op;
    // Outputs
    wire [31:0] _ALU_C;

    ALU Alu (
        .A(_ALU_A), .B(_ALU_B),
        .SHAMT(_ALU_SHAMT),
        .ALUOp(_ALU_Op),
        .C(_ALU_C)
    );

    // Inputs 
    wire [31:0] _CMP_A1, _CMP_A2;
    // Outputs
    wire _CMP_EQ, _CMP_LT;

    CMP Cmp (
        .A1(_CMP_A1), .A2(_CMP_A2),
        .EQ(_CMP_EQ), .LT(_CMP_LT)
    );

    // Inputs
    wire _DM_We;
    wire [31:0] _DM_ADDR;
    wire [31:0] _DM_WD;
    // Outputs
    wire [31:0] _DM_RD;

    DM Dm (
        .DMWe(_DM_We),
        .clk(clk), .rst(reset),
        .ADDR(_DM_ADDR), .WD(_DM_WD),
        .RD(_DM_RD),
		  .PC(_IFU_PC)
    );

    // Connections
    
    // NPC
    assign _NPC_PC = _IFU_PC,
           _NPC_Op = _CTRL_NPC_Op,
           _NPC_Cond = _CTRL_NPC_Cond,
           _NPC_IMM16 = _CTRL_IMM16,
           _NPC_IMM26 = _CTRL_IMM26,
           _NPC_IMM32 = _GRF_RD1, // Temporary
           _NPC_EQ = _CMP_EQ,
           _NPC_LT = _CMP_LT;
    
    // IFU
    assign _IFU_NPC = _NPC_NPC;

    // CTRL
    assign _CTRL_INS = _IFU_INS;

    // GRF
    wire [4:0] _MGRFA3;
    wire [31:0] _MGRFWD;

    assign _MGRFA3 = (_CTRL_MGRFA3_c == `mgrfa3_5d31) ? 5'd31 :
                     (_CTRL_MGRFA3_c == `mgrfa3_rt) ? _CTRL_RT : _CTRL_RD;
    
    assign _MGRFWD = (_CTRL_MGRFWD_c == `mgrfwd_alu_c) ? _ALU_C :
                     (_CTRL_MGRFWD_c == `mgrfwd_dm_rd) ? _DM_RD : _IFU_PC + 4;

    assign _GRF_A1 = _CTRL_RS,
           _GRF_A2 = _CTRL_RT,
           _GRF_A3 = _MGRFA3,
			  _GRF_We = _CTRL_GRF_We,
           _GRF_WD = _MGRFWD;

    // EXT
    assign _EXT_A = _CTRL_IMM16,
           _EXT_Signed = _CTRL_EXT_Signed;

    wire [31:0] _MALUB;
    wire [4:0] _MALUSA;

    // ALU
    assign _MALUB = (_CTRL_MALUB_c == `malub_grf_a2) ? _GRF_RD2 : _EXT_B;

    assign _MALUSA = (_CTRL_MALUSA_c == `malusa_ctrl_sa) ? _CTRL_SHAMT : 5'd16;
    
    assign _ALU_A = _GRF_RD1,
           _ALU_B = _MALUB,
           _ALU_SHAMT = _MALUSA,
           _ALU_Op = _CTRL_ALU_Op;


    // CMP
    assign _CMP_A1 = _GRF_RD1,
           _CMP_A2 = _GRF_RD2;

    // DM
    assign _DM_ADDR = _ALU_C,
           _DM_WD = _GRF_RD2,
           _DM_We = _CTRL_DM_We;

endmodule
