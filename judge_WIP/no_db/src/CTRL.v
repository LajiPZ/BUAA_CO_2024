`timescale 1ns / 1ps
`include "parameters.v"
module CTRL(
    input [31:0] INS,
    output [4:0] rs,rt,rd,shamt,
    output [15:0] imm16,
    output [25:0] imm26,
    output [3:0] alu_op,
    output [2:0] npc_op,
                 npc_cond,
    output grf_we, 
           ext_signed,
           dm_we,
    output [3:0] mgrfa3_c,
                 mgrfwd_c,
                 malub_c,
                 malusa_c,
    output forward,
    output [4:0] target
    );

// CTRL_DEC

    wire [5:0] _opcode, _funct;
    wire [4:0] _rs, _rt, _rd, _shamt;
    wire [15:0] _imm16;
    wire [25:0] _imm26;

    assign _opcode = INS[31:26], // R-type
           _rs = INS[25:21],
           _rt = INS[20:16],
           _rd = INS[15:11],
           _shamt = INS[10:6],
           _funct = INS[5:0];
    
    assign _imm16 = INS[15:0], // I-type
           _imm26 = INS[25:0]; // J-type

// CTRL_AND

    wire _r_ins;
    wire _add, _sub, _jr, _sll; // R-type ins
    wire _ori, _lw, _sw, _beq, _lui; // I-type ins
    wire _jal; // J-type ins

    assign _r_ins = !(|_opcode);
    
    assign _add = _r_ins & (_funct == 6'b100000),
           _sub = _r_ins & (_funct == 6'b100010),
           _jr = _r_ins & (_funct == 6'b001000),
           _sll = _r_ins & (_funct == 6'b000000);

    assign _ori = (_opcode == 6'b001101),
           _lw = (_opcode == 6'b100011),
           _sw = (_opcode == 6'b101011),
           _beq = (_opcode == 6'b000100),
           _lui = (_opcode == 6'b001111);

    assign _jal = (_opcode == 6'b000011);

// CTRL_OR

       // Controls for modules

    // NPC
    wire _npc_op_b, _npc_op_j26, _npc_op_j32; // _npc_op_norm set as default; no judgement needed
    assign _npc_op_b = _beq,
           _npc_op_j26 = _jal,
           _npc_op_j32 = _jr;

    wire _npc_cond_eq, _npc_cond_lt, _npc_cond_gt, _npc_le, _npc_ge;
    assign _npc_cond_eq = _beq;
           // Reserved for future development

    // GRF
    wire _grf_we_n;
    assign _grf_we_n = _sw | _beq | _jr;


    // EXT
    wire _ext_signed; 
    assign _ext_signed = _lw | _sw;


    // ALU
    wire _alu_sub, _alu_or, _alu_sll; // _alu_add = _add | _lw | _sw   set as default
    assign _alu_sub = _sub,
           _alu_or = _ori,
           _alu_sll = _sll | _lui;
    
    // DM
    wire _dm_we;
    assign _dm_we = _sw;

       // Controls for MUXes
    
    // MGRFA3
    wire _mgrfa3_rt, _mgrfa3_5d31; // _mgrfa3_rd = _r_ins set as default
    assign _mgrfa3_5d31 = _jal,
           _mgrfa3_rt = !_r_ins; // TAKE CARE OF IT WHEN TAKING THE EXAM

    // MGRFWD
    wire  _mgrfwd_dm_rd, _mgrfwd_pc_4; // ALU.C as default
    assign _mgrfwd_dm_rd = _lw,
           _mgrfwd_pc_4 = _jal;
           
    // MALUB
    wire _malub_ext_b; // _malub_grf_a2 = _r_ins     GRF.A2 as default
    assign _malub_ext_b = !_r_ins; // TAKE CARE OF IT WHEN TAKING THE EXAM
    
    // MALUSA
    wire _malusa_5d16, _malusa_v; // _malusa_ctrl_sa = _sll   CTRL.SA as default; v reserved for future dev.
    assign _malusa_5d16 = _lui;

// Outputs

       assign alu_op = (_alu_sub) ? `alu_sub :
                     (_alu_or) ? `alu_or :
                     (_alu_sll) ? `alu_sll : `alu_add;

       assign npc_op = (_npc_op_b) ? `npc_op_b :
                     (_npc_op_j26) ? `npc_op_j26 :
                     (_npc_op_j32) ? `npc_op_j32 : `npc_op_norm;

       assign npc_cond = (_npc_cond_eq) ? `npc_cond_eq : `npc_cond_eq; // Temporary

       assign grf_we = (!_grf_we_n) ? 1'b1 : 1'b0;

       assign ext_signed = (_ext_signed) ? 1'b1 : 1'b0;

       assign dm_we = (_dm_we) ? 1'b1 : 1'b0;

       assign mgrfa3_c = (_mgrfa3_5d31) ? `mgrfa3_5d31: // jal优先级更高
                     (_mgrfa3_rt) ? `mgrfa3_rt : `mgrfa3_rd;

       assign mgrfwd_c = (_mgrfwd_dm_rd) ? `mgrfwd_dm_rd :
                     (_mgrfwd_pc_4) ? `mgrfwd_pc_4 : `mgrfwd_alu_c;

       assign malub_c = (_malub_ext_b) ? `malub_ext_b : `malub_grf_a2;

       assign malusa_c = (_malusa_5d16) ? `malusa_5d16 : `malusa_ctrl_sa;

       assign rs = _rs,
                     rt = _rt,
                     rd = _rd,
                     shamt = _shamt,
                     imm16 = _imm16,
                     imm26 = _imm26;

// Forwarding

       assign forward = _add | _sub | _sll | _ori | _lw | _lui | _jal;

       assign target = ( _add | _sub | _sll ) ? _rd : 
                       ( _ori | _lw | _lui ) ? _rt :
                       (_jal) ? 5'd31 : 5'b0;

endmodule
