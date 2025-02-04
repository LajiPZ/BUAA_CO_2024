`timescale 1ns / 1ps
`include "parameters.v"
module mips( 
    input clk,
    input reset
    );

// Designed for the utmost redundancy.

//-------------------STAGE C-------------------//
    // IFU
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
        // Connections
            assign _IFU_NPC = _NPC_NPC;

    // NPC
        // Inputs
            wire [31:0] _NPC_PC,_NPC_C_PC;
            wire [15:0] _NPC_IMM16;
            wire [25:0] _NPC_IMM26;
            wire [31:0] _NPC_IMM32;
            wire [2:0] _NPC_Op, _NPC_Cond;
            wire _NPC_EQ, _NPC_LT;
        // Outputs
            wire [31:0] _NPC_NPC;

        NPC Npc (
            .PC(_NPC_PC), .C_PC(_NPC_C_PC),
            .IMM16(_NPC_IMM16), .IMM26(_NPC_IMM26), .IMM32(_NPC_IMM32),
            .NPCOp(_NPC_Op), .NPCCond(_NPC_Cond),
            .EQ(_NPC_EQ), .LT(_NPC_LT),
            .NPC(_NPC_NPC)
        );
        // Connections
            assign _NPC_PC = C_IFU_PC,
                _NPC_C_PC = _IFU_PC,
                _NPC_Op = _CTRL_D_NPC_Op,
                _NPC_Cond = _CTRL_D_NPC_Cond,
                _NPC_IMM16 = _CTRL_D_IMM16,
                _NPC_IMM26 = _CTRL_D_IMM26,
                _NPC_IMM32 = _GRF_RD1, // Temporary
                _NPC_EQ = _CMP_EQ,
                _NPC_LT = _CMP_LT;
    
    // LAYER_CD
        reg [31:0] C_IFU_INS, C_IFU_PC;
        reg [31:0] C_NPC_NPC;
        always @(posedge clk) begin
            if (reset) begin
                C_IFU_INS <= 32'b0;
                C_IFU_PC <= 32'b0;
                C_NPC_NPC <= 32'b0;
            end else begin
                C_IFU_INS <= _IFU_INS;
                C_IFU_PC <= _IFU_PC;
                C_NPC_NPC <= _NPC_NPC;
            end
        end

//-------------------STAGE D-------------------//
    // CTRL_D
        // Inputs
            wire [31:0] _CTRL_D_INS;
        // Outputs
            wire [4:0] _CTRL_D_RS, _CTRL_D_RT, _CTRL_D_RD, _CTRL_D_SHAMT; 
            wire [15:0] _CTRL_D_IMM16;
            wire [25:0] _CTRL_D_IMM26;
            wire [3:0] _CTRL_D_ALU_Op;
            wire [2:0] _CTRL_D_NPC_Op,_CTRL_D_NPC_Cond;
            wire _CTRL_D_GRF_We, _CTRL_D_EXT_Signed, _CTRL_D_DM_We;
            wire [3:0] _CTRL_D_MGRFA3_c, _CTRL_D_MGRFWD_c, _CTRL_D_MALUB_c, _CTRL_D_MALUSA_c;

        CTRL Ctrl_D (
            .INS(_CTRL_D_INS),
            .rs(_CTRL_D_RS), .rt(_CTRL_D_RT), .rd(_CTRL_D_RD), .shamt(_CTRL_D_SHAMT),
            .imm16(_CTRL_D_IMM16), .imm26(_CTRL_D_IMM26),
            .alu_op(_CTRL_D_ALU_Op), .npc_op(_CTRL_D_NPC_Op), .npc_cond(_CTRL_D_NPC_Cond),
            .grf_we(_CTRL_D_GRF_We), .ext_signed(_CTRL_D_EXT_Signed), .dm_we(_CTRL_D_DM_We),
            .mgrfa3_c(_CTRL_D_MGRFA3_c), .mgrfwd_c(_CTRL_D_MGRFWD_c), .malub_c(_CTRL_D_MALUB_c), .malusa_c(_CTRL_D_MALUSA_c)
        );
        // Connections
            assign _CTRL_D_INS = C_IFU_INS;

    // EXT
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
        // Connections
            assign _EXT_A = _CTRL_D_IMM16,
                _EXT_Signed = _CTRL_D_EXT_Signed;

    // GRF(Read)
        // Inputs
            // Read
            wire [4:0] _GRF_A1, _GRF_A2;
            // Write
            wire [4:0]  _GRF_A3;
            wire [31:0] _GRF_WD;
            wire _GRF_We;
            wire [31:0] _GRF_PC;
        // Outputs
            wire [31:0] _GRF_RD1, _GRF_RD2;
        
        GRF Grf (
            .A1(_GRF_A1), .A2(_GRF_A2), .A3(_GRF_A3),
            .WD(_GRF_WD),
            .GRFWe(_GRF_We),
            .clk(clk), .rst(reset),
            .RD1(_GRF_RD1), .RD2(_GRF_RD2),
            .PC(_GRF_PC)
        );
        // Connections
            assign _GRF_A1 = _CTRL_D_RS,
                   _GRF_A2 = _CTRL_D_RT;


    // CMP
        // Inputs 
            wire [31:0] _CMP_A1, _CMP_A2;
        // Outputs
            wire _CMP_EQ, _CMP_LT;

        CMP Cmp (
            .A1(_CMP_A1), .A2(_CMP_A2),
            .EQ(_CMP_EQ), .LT(_CMP_LT)
        );
        // Connections 
            assign _CMP_A1 = _GRF_RD1,
                _CMP_A2 = _GRF_RD2;

    // LAYER_DE
        reg [31:0] D_IFU_INS, D_IFU_PC;
        reg [31:0] D_NPC_NPC;
        reg [31:0] D_EXT_B;
        reg [31:0] D_GRF_RD1, D_GRF_RD2;
        reg D_CMP_EQ, D_CMP_LT;
        always @(posedge clk) begin
            if (reset) begin
                D_IFU_INS <= 32'b0;
                D_IFU_PC <= 32'b0;
                D_NPC_NPC <= 32'b0;
                D_EXT_B <= 32'b0;
                D_GRF_RD1 <= 32'b0;
                D_GRF_RD2 <= 32'b0;
                D_CMP_EQ <= 1'b0;
                D_CMP_LT <= 1'b0;
            end else begin
                D_IFU_INS <= C_IFU_INS;
                D_IFU_PC <= C_IFU_PC;
                D_NPC_NPC <= C_NPC_NPC;
                D_EXT_B <= _EXT_B;
                D_GRF_RD1 <= _GRF_RD1;
                D_GRF_RD2 <= _GRF_RD2;
                D_CMP_EQ <= _CMP_EQ;
                D_CMP_LT <= _CMP_LT;
            end
        end

//-------------------STAGE E-------------------//
    // CTRL_E
        // Inputs
            wire [31:0] _CTRL_E_INS;
        // Outputs
            wire [4:0] _CTRL_E_RS, _CTRL_E_RT, _CTRL_E_RD, _CTRL_E_SHAMT; 
            wire [15:0] _CTRL_E_IMM16;
            wire [25:0] _CTRL_E_IMM26;
            wire [3:0] _CTRL_E_ALU_Op;
            wire [2:0] _CTRL_E_NPC_Op,_CTRL_E_NPC_Cond;
            wire _CTRL_E_GRF_We, _CTRL_E_EXT_Signed, _CTRL_E_DM_We;
            wire [3:0] _CTRL_E_MGRFA3_c, _CTRL_E_MGRFWD_c, _CTRL_E_MALUB_c, _CTRL_E_MALUSA_c;

        CTRL Ctrl_E (
            .INS(_CTRL_E_INS),
            .rs(_CTRL_E_RS), .rt(_CTRL_E_RT), .rd(_CTRL_E_RD), .shamt(_CTRL_E_SHAMT),
            .imm16(_CTRL_E_IMM16), .imm26(_CTRL_E_IMM26),
            .alu_op(_CTRL_E_ALU_Op), 
            .npc_op(_CTRL_E_NPC_Op), .npc_cond(_CTRL_E_NPC_Cond),
            .grf_we(_CTRL_E_GRF_We), .ext_signed(_CTRL_E_EXT_Signed), .dm_we(_CTRL_E_DM_We),
            .mgrfa3_c(_CTRL_E_MGRFA3_c), .mgrfwd_c(_CTRL_E_MGRFWD_c), .malub_c(_CTRL_E_MALUB_c), .malusa_c(_CTRL_E_MALUSA_c)
        );
        // Connections
            assign _CTRL_E_INS = D_IFU_INS;

    // ALU 
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
        // Connections
            wire [31:0] _MALUB;
            wire [4:0] _MALUSA;
            
            assign _MALUB = (_CTRL_E_MALUB_c == `malub_grf_a2) ? D_GRF_RD2 : D_EXT_B;

            assign _MALUSA = (_CTRL_E_MALUSA_c == `malusa_ctrl_sa) ? _CTRL_E_SHAMT : 5'd16;
            
            assign _ALU_A = D_GRF_RD1,
                _ALU_B = _MALUB,
                _ALU_SHAMT = _MALUSA,
                _ALU_Op = _CTRL_E_ALU_Op;
    
    // LAYER_EM
        reg [31:0] E_IFU_INS, E_IFU_PC;
        reg [31:0] E_NPC_NPC;
        reg [31:0] E_EXT_B;
        reg [31:0] E_GRF_RD1, E_GRF_RD2;
        reg E_CMP_EQ, E_CMP_LT;
        reg [31:0] E_ALU_C;
        always @(posedge clk) begin
            if (reset) begin
                E_IFU_INS <= 32'b0;
                E_IFU_PC <= 32'b0;
                E_NPC_NPC <= 32'b0;
                E_EXT_B <= 32'b0;
                E_GRF_RD1 <= 32'b0;
                E_GRF_RD2 <= 32'b0;
                E_CMP_EQ <= 1'b0;
                E_CMP_LT <= 1'b0;
                E_ALU_C <= 32'b0;
            end else begin    
                E_IFU_INS <= D_IFU_INS;
                E_IFU_PC <= D_IFU_PC;
                E_NPC_NPC <= D_NPC_NPC;
                E_EXT_B <= D_EXT_B;
                E_GRF_RD1 <= D_GRF_RD1;
                E_GRF_RD2 <= D_GRF_RD2;
                E_CMP_EQ <= D_CMP_EQ;
                E_CMP_LT <= D_CMP_LT;
                E_ALU_C <= _ALU_C;
            end
        end

//-------------------STAGE M-------------------//
    // CTRL_M
        // Inputs
            wire [31:0] _CTRL_M_INS;
        // Outputs
            wire [4:0] _CTRL_M_RS, _CTRL_M_RT, _CTRL_M_RD, _CTRL_M_SHAMT; 
            wire [15:0] _CTRL_M_IMM16;
            wire [25:0] _CTRL_M_IMM26;
            wire [3:0] _CTRL_M_ALU_Op;
            wire [2:0] _CTRL_M_NPC_Op,_CTRL_M_NPC_Cond;
            wire _CTRL_M_GRF_We, _CTRL_M_EXT_Signed, _CTRL_M_DM_We;
            wire [3:0] _CTRL_M_MGRFA3_c, _CTRL_M_MGRFWD_c, _CTRL_M_MALUB_c, _CTRL_M_MALUSA_c;

        CTRL Ctrl_M (
            .INS(_CTRL_M_INS),
            .rs(_CTRL_M_RS), .rt(_CTRL_M_RT), .rd(_CTRL_M_RD), .shamt(_CTRL_M_SHAMT),
            .imm16(_CTRL_M_IMM16), .imm26(_CTRL_M_IMM26),
            .alu_op(_CTRL_M_ALU_Op), .npc_op(_CTRL_M_NPC_Op), .npc_cond(_CTRL_M_NPC_Cond),
            .grf_we(_CTRL_M_GRF_We), .ext_signed(_CTRL_M_EXT_Signed), .dm_we(_CTRL_M_DM_We),
            .mgrfa3_c(_CTRL_M_MGRFA3_c), .mgrfwd_c(_CTRL_M_MGRFWD_c), .malub_c(_CTRL_M_MALUB_c), .malusa_c(_CTRL_M_MALUSA_c)
        );
        // Connections
            assign _CTRL_M_INS = E_IFU_INS;
    // DM
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
            .PC(E_IFU_PC)
        );
        // Connections
            assign _DM_ADDR = E_ALU_C,
                _DM_WD = E_GRF_RD2,
                _DM_We = _CTRL_M_DM_We;
    
    // LAYER_MW
        reg [31:0] M_IFU_INS, M_IFU_PC;
        reg [31:0] M_NPC_NPC;
        reg [31:0] M_EXT_B;
        reg [31:0] M_GRF_RD1, M_GRF_RD2;
        reg M_CMP_EQ, M_CMP_LT;
        reg [31:0] M_ALU_C;
        reg [31:0] M_DM_RD;
        always @(posedge clk) begin
            if (reset) begin
                M_IFU_INS <= 32'b0;
                M_IFU_PC <= 32'b0;
                M_NPC_NPC <= 32'b0;
                M_EXT_B <= 32'b0;
                M_GRF_RD1 <= 32'b0;
                M_GRF_RD2 <= 32'b0;
                M_CMP_EQ <= 1'b0;
                M_CMP_LT <= 1'b0;
                M_ALU_C <= 32'b0;
                M_DM_RD <= 32'b0;
            end else begin
                M_IFU_INS <= E_IFU_INS;
                M_IFU_PC <= E_IFU_PC;
                M_NPC_NPC <= E_NPC_NPC;
                M_EXT_B <= E_EXT_B;
                M_GRF_RD1 <= E_GRF_RD1;
                M_GRF_RD2 <= E_GRF_RD2;
                M_CMP_EQ <= E_CMP_EQ;
                M_CMP_LT <= E_CMP_LT;
                M_ALU_C <= E_ALU_C;
                M_DM_RD <= _DM_RD;
            end
        end

//-------------------STAGE W-------------------//
    // CTRL_W
        // Inputs
            wire [31:0] _CTRL_W_INS;
        // Outputs
            wire [4:0] _CTRL_W_RS, _CTRL_W_RT, _CTRL_W_RD, _CTRL_W_SHAMT; 
            wire [15:0] _CTRL_W_IMM16;
            wire [25:0] _CTRL_W_IMM26;
            wire [3:0] _CTRL_W_ALU_Op;
            wire [2:0] _CTRL_W_NPC_Op,_CTRL_W_NPC_Cond;
            wire _CTRL_W_GRF_We, _CTRL_W_EXT_Signed, _CTRL_W_DM_We;
            wire [3:0] _CTRL_W_MGRFA3_c, _CTRL_W_MGRFWD_c, _CTRL_W_MALUB_c, _CTRL_W_MALUSA_c;

        CTRL Ctrl_W (
            .INS(_CTRL_W_INS),
            .rs(_CTRL_W_RS), .rt(_CTRL_W_RT), .rd(_CTRL_W_RD), .shamt(_CTRL_W_SHAMT),
            .imm16(_CTRL_W_IMM16), .imm26(_CTRL_W_IMM26),
            .alu_op(_CTRL_W_ALU_Op), .npc_op(_CTRL_W_NPC_Op), .npc_cond(_CTRL_W_NPC_Cond),
            .grf_we(_CTRL_W_GRF_We), .ext_signed(_CTRL_W_EXT_Signed), .dm_we(_CTRL_W_DM_We),
            .mgrfa3_c(_CTRL_W_MGRFA3_c), .mgrfwd_c(_CTRL_W_MGRFWD_c), .malub_c(_CTRL_W_MALUB_c), .malusa_c(_CTRL_W_MALUSA_c)
        );
        // Connections
            assign _CTRL_W_INS = M_IFU_INS;

    // GRF(Write)
        // Connections
            wire [4:0] _MGRFA3;
            wire [31:0] _MGRFWD;

            assign _MGRFA3 = (_CTRL_W_MGRFA3_c == `mgrfa3_5d31) ? 5'd31 :
                            (_CTRL_W_MGRFA3_c == `mgrfa3_rt) ? _CTRL_W_RT : _CTRL_W_RD;
            
            assign _MGRFWD = (_CTRL_W_MGRFWD_c == `mgrfwd_alu_c) ? M_ALU_C :
                            (_CTRL_W_MGRFWD_c == `mgrfwd_dm_rd) ? M_DM_RD : M_IFU_PC + 8;

            assign _GRF_A3 = _MGRFA3,
                   _GRF_We = _CTRL_W_GRF_We,
                   _GRF_WD = _MGRFWD,
                   _GRF_PC = M_IFU_PC;

endmodule
