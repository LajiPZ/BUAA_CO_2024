`timescale 1ns / 1ps
`include "parameters.v"
module mips( 
    input clk,
    input reset
    );

// Designed for the utmost redundancy.

// CAUTION: 
// condition for branch/jump: override NPC_EQ with new condition
// flush has been provided and grounded 
// 


//-------------------STAGE C-------------------//
    // IFU
        // Inputs
            wire [31:0] _IFU_NPC;
        // Outputs
            wire [31:0] _IFU_INS, _IFU_PC;

        IFU Ifu (
            .NPC(_IFU_NPC),
            .clk(clk), .rst(reset),
            .INS(_IFU_INS),
            .PC(_IFU_PC)
        );
        // Connections
            assign _IFU_NPC = _NPC_NPC;
    
    // LAYER_CD
        reg [31:0] C_IFU_INS, C_IFU_PC;
        reg [31:0] C_NPC_NPC;
        always @(posedge clk) begin
            if (reset | _flush_CD) begin
                C_IFU_INS <= 32'b0;
                C_IFU_PC <= 32'b0;
                C_NPC_NPC <= 32'b0;
            end else begin
                if(!_stall) begin
                    C_IFU_INS <= _IFU_INS;
                    C_IFU_PC <= _IFU_PC;
                    C_NPC_NPC <= _NPC_NPC;
                end
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
            wire [2:0] _CTRL_D_t_use_rd1, _CTRL_D_t_use_rd2, _CTRL_D_t_new;
            wire _CTRL_D_neo;
            wire _CTRL_D_MCMPA2_c;

        CTRL Ctrl_D (
            .INS(_CTRL_D_INS),
            .rs(_CTRL_D_RS), .rt(_CTRL_D_RT), .rd(_CTRL_D_RD), .shamt(_CTRL_D_SHAMT),
            .imm16(_CTRL_D_IMM16), .imm26(_CTRL_D_IMM26),
            .alu_op(_CTRL_D_ALU_Op), .npc_op(_CTRL_D_NPC_Op), .npc_cond(_CTRL_D_NPC_Cond),
            .grf_we(_CTRL_D_GRF_We), .ext_signed(_CTRL_D_EXT_Signed), .dm_we(_CTRL_D_DM_We),
            .mgrfa3_c(_CTRL_D_MGRFA3_c), .mgrfwd_c(_CTRL_D_MGRFWD_c), .malub_c(_CTRL_D_MALUB_c), .malusa_c(_CTRL_D_MALUSA_c),
            .t_use_rd1(_CTRL_D_t_use_rd1), .t_use_rd2(_CTRL_D_t_use_rd2), .t_new(_CTRL_D_t_new),
            .neo(_CTRL_D_neo),
            .mcmpa2_c(_CTRL_D_MCMPA2_c)
        );
        // Connections
            assign _CTRL_D_INS = C_IFU_INS;

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
    // ! Flush  
        wire _flush_CD;
        wire _flush_CD_cond;

        //assign _flush_CD_cond = _CMP_EQ;

        //assign _flush_CD = (_CTRL_D_neo) & _flush_CD_cond & !_stall;

        assign _flush_CD = 1'b0; // Temporarily grounded

    // ! Stall ( Maybe with spin afterwards? lol )

        wire _stall;
        wire _stall_rd1, _stall_rd2;
        wire _stall_rd1_E, _stall_rd2_E;
        wire _stall_rd1_M, _stall_rd2_M;
        wire _stall_E_cond, _stall_M_cond;

        assign _stall_rd1_E_cond = ( $signed(D_t_new) - $signed(_CTRL_D_t_use_rd1) > $signed(3'd0) );
        assign _stall_rd1_M_cond = ( $signed(E_t_new) - $signed(_CTRL_D_t_use_rd1) > $signed(3'd1) );
        
        assign _stall_rd2_E_cond = ( $signed(D_t_new) - $signed(_CTRL_D_t_use_rd2) > $signed(3'd0) );
        assign _stall_rd2_M_cond = ( $signed(E_t_new) - $signed(_CTRL_D_t_use_rd2) > $signed(3'd1) );

        assign _stall_rd1_E = (_target_E == _GRF_A1) & _stall_rd1_E_cond & (_GRF_A1 != 5'b0);
        assign _stall_rd2_E = (_target_E == _GRF_A2) & _stall_rd2_E_cond & (_GRF_A2 != 5'b0);
        assign _stall_rd1_M = (_target_M == _GRF_A1) & _stall_rd1_M_cond & (_GRF_A1 != 5'b0);
        assign _stall_rd2_M = (_target_M == _GRF_A2) & _stall_rd2_M_cond & (_GRF_A2 != 5'b0);


        assign _stall_rd1 = _stall_rd1_E | _stall_rd1_M;
        assign _stall_rd2 = _stall_rd2_E | _stall_rd2_M;
        assign _stall = _stall_rd1 | _stall_rd2;

    
    // ! Forwarding
        // Inbound
            wire [31:0] _GRF_RD1_F, _GRF_RD2_F;
            wire _forward_RD1_M_D = (_GRF_A1 == _target_M) & _forward_M & (_GRF_A1 != 5'b0);
            wire _forward_RD2_M_D = (_GRF_A2 == _target_M) & _forward_M & (_GRF_A2 != 5'b0);
            wire _forward_RD1_W_D = (_GRF_A1 == _target_W) & _forward_W & (_GRF_A1 != 5'b0);
            wire _forward_RD2_W_D = (_GRF_A2 == _target_W) & _forward_W & (_GRF_A2 != 5'b0);

            assign _GRF_RD1_F = (_forward_RD1_M_D) ? (_forward_data_M) :
                                (_forward_RD1_W_D) ? (_GRF_WD) :
                                _GRF_RD1;

            assign _GRF_RD2_F = (_forward_RD2_M_D) ? (_forward_data_M) :
                                (_forward_RD2_W_D) ? (_GRF_WD) :
                                _GRF_RD2;

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
            .NPC(_NPC_NPC),
            .stall(_stall)
        );
        // Connections
            assign _NPC_PC = C_IFU_PC,
                _NPC_C_PC = _IFU_PC,
                _NPC_Op = _CTRL_D_NPC_Op,
                _NPC_Cond = _CTRL_D_NPC_Cond,
                _NPC_IMM16 = _CTRL_D_IMM16,
                _NPC_IMM26 = _CTRL_D_IMM26,
                _NPC_IMM32 = _GRF_RD1_F, // Temporary
                _NPC_EQ = _CMP_EQ,
                _NPC_LT = _CMP_LT;

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
            wire [31:0] _MCMPA2;
            assign _MCMPA2 = (_CTRL_D_MCMPA2_c) ? 32'b0 : _GRF_RD2_F;

            assign _CMP_A1 = _GRF_RD1_F,
                _CMP_A2 = _MCMPA2;

    // LAYER_DE
        reg [31:0] D_IFU_INS, D_IFU_PC;
        reg [31:0] D_NPC_NPC;
        reg [31:0] D_EXT_B;
        reg [31:0] D_GRF_RD1, D_GRF_RD2;
        reg [4:0] D_GRF_A1, D_GRF_A2;
        reg D_CMP_EQ, D_CMP_LT;
        reg [2:0] D_t_new;
        always @(posedge clk) begin
            if (reset | _stall) begin
                D_IFU_INS <= 32'b0;
                D_IFU_PC <= 32'b0;
                D_NPC_NPC <= 32'b0;
                D_EXT_B <= 32'b0;
                D_GRF_RD1 <= 32'b0;
                D_GRF_RD2 <= 32'b0;
                D_CMP_EQ <= 1'b0;
                D_CMP_LT <= 1'b0;
                D_GRF_A1 <= 5'b0;
                D_GRF_A2 <= 5'b0;
                D_t_new <= 3'b0;
            end else begin
                D_IFU_INS <= C_IFU_INS;
                D_IFU_PC <= C_IFU_PC;
                D_NPC_NPC <= C_NPC_NPC;
                D_EXT_B <= _EXT_B;
                D_GRF_RD1 <= _GRF_RD1_F;
                D_GRF_RD2 <= _GRF_RD2_F;
                D_CMP_EQ <= _CMP_EQ;
                D_CMP_LT <= _CMP_LT;
                D_GRF_A1 <= _GRF_A1;
                D_GRF_A2 <= _GRF_A2;
                D_t_new <= _CTRL_D_t_new;
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
            wire [4:0] _target_E;
            wire _CTRL_E_neo;

        CTRL Ctrl_E (
            .INS(_CTRL_E_INS),
            .rs(_CTRL_E_RS), .rt(_CTRL_E_RT), .rd(_CTRL_E_RD), .shamt(_CTRL_E_SHAMT),
            .imm16(_CTRL_E_IMM16), .imm26(_CTRL_E_IMM26),
            .alu_op(_CTRL_E_ALU_Op), 
            .npc_op(_CTRL_E_NPC_Op), .npc_cond(_CTRL_E_NPC_Cond),
            .grf_we(_CTRL_E_GRF_We), .ext_signed(_CTRL_E_EXT_Signed), .dm_we(_CTRL_E_DM_We),
            .mgrfa3_c(_CTRL_E_MGRFA3_c), .mgrfwd_c(_CTRL_E_MGRFWD_c), .malub_c(_CTRL_E_MALUB_c), .malusa_c(_CTRL_E_MALUSA_c),
            .target(_target_E),
            .neo(_CTRL_E_neo)
        );
        // Connections
            assign _CTRL_E_INS = D_IFU_INS;

    // ! Forwarding
        // Inbound
            wire [31:0] _D_GRF_RD1_F, _D_GRF_RD2_F;
            wire _forward_RD1_M_E = (D_GRF_A1 == _target_M) & _forward_M & (D_GRF_A1 != 5'b0); 
            wire _forward_RD2_M_E = (D_GRF_A2 == _target_M) & _forward_M & (D_GRF_A2 != 5'b0);
            wire _forward_RD1_W_E = (D_GRF_A1 == _target_W) & _forward_W & (D_GRF_A1 != 5'b0);
            wire _forward_RD2_W_E = (D_GRF_A2 == _target_W) & _forward_W & (D_GRF_A2 != 5'b0);

            assign _D_GRF_RD1_F = (_forward_RD1_M_E) ? (_forward_data_M) :
                                (_forward_RD1_W_E) ? (_GRF_WD) :
                                D_GRF_RD1;

            assign _D_GRF_RD2_F = (_forward_RD2_M_E) ? (_forward_data_M) :
                                (_forward_RD2_W_E) ? (_GRF_WD) :
                                D_GRF_RD2;

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
            
            assign _MALUB = (_CTRL_E_MALUB_c == `malub_grf_a2) ? _D_GRF_RD2_F : D_EXT_B;

            assign _MALUSA = (_CTRL_E_MALUSA_c == `malusa_ctrl_sa) ? _CTRL_E_SHAMT : 5'd16;
            
            assign _ALU_A = _D_GRF_RD1_F,
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
        reg [4:0] E_GRF_A1, E_GRF_A2;
        reg [2:0] E_t_new;

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
                E_GRF_A1 <= 5'b0;
                E_GRF_A2 <= 5'b0;
                E_t_new <= 3'b0;
            end else begin    
                E_IFU_INS <= D_IFU_INS;
                E_IFU_PC <= D_IFU_PC;
                E_NPC_NPC <= D_NPC_NPC;
                E_EXT_B <= D_EXT_B;
                E_GRF_RD1 <= _D_GRF_RD1_F;
                E_GRF_RD2 <= _D_GRF_RD2_F;
                E_CMP_EQ <= D_CMP_EQ;
                E_CMP_LT <= D_CMP_LT;
                E_ALU_C <= _ALU_C;
                E_GRF_A1 <= D_GRF_A1;
                E_GRF_A2 <= D_GRF_A2;
                E_t_new <= D_t_new;
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
            wire _forward_M;
            wire [4:0] _target_M;
            wire [2:0] _forward_M_src;
            wire _CTRL_M_neo;

        CTRL Ctrl_M (
            .INS(_CTRL_M_INS),
            .rs(_CTRL_M_RS), .rt(_CTRL_M_RT), .rd(_CTRL_M_RD), .shamt(_CTRL_M_SHAMT),
            .imm16(_CTRL_M_IMM16), .imm26(_CTRL_M_IMM26),
            .alu_op(_CTRL_M_ALU_Op), .npc_op(_CTRL_M_NPC_Op), .npc_cond(_CTRL_M_NPC_Cond),
            .grf_we(_CTRL_M_GRF_We), .ext_signed(_CTRL_M_EXT_Signed), .dm_we(_CTRL_M_DM_We),
            .mgrfa3_c(_CTRL_M_MGRFA3_c), .mgrfwd_c(_CTRL_M_MGRFWD_c), .malub_c(_CTRL_M_MALUB_c), .malusa_c(_CTRL_M_MALUSA_c),
            .target(_target_M), .forward_m(_forward_M), .forward_src(_forward_M_src),
            .neo(_CTRL_M_neo)
        );
        // Connections
            assign _CTRL_M_INS = E_IFU_INS;

    // ! Forwarding
        // Outbound
            wire [31:0] _forward_data_M;
            assign _forward_data_M = (_forward_M_src == `forward_src_alu) ? E_ALU_C :
                                     (_forward_M_src == `forward_src_pc_8) ? (E_IFU_PC + 8) :
                                     E_ALU_C; // Temporary

        // Inbound

            wire [31:0] _E_GRF_RD1_F, _E_GRF_RD2_F;
            wire _forward_RD1_W_M = (E_GRF_A1 == _target_W) & _forward_W & (E_GRF_A1 != 5'b0);
            wire _forward_RD2_W_M = (E_GRF_A2 == _target_W) & _forward_W & (E_GRF_A2 != 5'b0);

            assign _E_GRF_RD1_F = (_forward_RD1_W_M) ? (_GRF_WD) :
                                E_GRF_RD1;

            assign _E_GRF_RD2_F = (_forward_RD2_W_M) ? (_GRF_WD) :
                                E_GRF_RD2;

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
                _DM_WD = _E_GRF_RD2_F,
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
                M_GRF_RD1 <= _E_GRF_RD1_F;
                M_GRF_RD2 <= _E_GRF_RD2_F;
                M_CMP_EQ <= E_CMP_EQ;
                M_CMP_LT <= E_CMP_LT;
                M_ALU_C <= E_ALU_C;
                M_DM_RD <= _DM_RD;
            end
        end

        // No forwarding inbound for Stage W, so GRF.A1/2 is no longer propagated

//-------------------STAGE W-------------------//
    // ! Forward
        // Outbound
            // Nope; Default to _GRF_WD;

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
            wire _forward_W;
            wire [4:0] _target_W;
            wire _CTRL_W_neo;
            
        CTRL Ctrl_W (
            .INS(_CTRL_W_INS),
            .rs(_CTRL_W_RS), .rt(_CTRL_W_RT), .rd(_CTRL_W_RD), .shamt(_CTRL_W_SHAMT),
            .imm16(_CTRL_W_IMM16), .imm26(_CTRL_W_IMM26),
            .alu_op(_CTRL_W_ALU_Op), .npc_op(_CTRL_W_NPC_Op), .npc_cond(_CTRL_W_NPC_Cond),
            .grf_we(_CTRL_W_GRF_We), .ext_signed(_CTRL_W_EXT_Signed), .dm_we(_CTRL_W_DM_We),
            .mgrfa3_c(_CTRL_W_MGRFA3_c), .mgrfwd_c(_CTRL_W_MGRFWD_c), .malub_c(_CTRL_W_MALUB_c), .malusa_c(_CTRL_W_MALUSA_c),
            .target(_target_W), .forward_w(_forward_W),
            .neo(_CTRL_W_neo)
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
