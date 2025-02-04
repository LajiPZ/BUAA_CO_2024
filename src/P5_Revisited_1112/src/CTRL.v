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
    output mcmpa2_c,
    output forward_m,
    output forward_w,
    output [4:0] target,
    output [2:0] forward_src, 
    output [2:0] t_use_rd1, t_use_rd2, t_new,
    output neo
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

// Instruction decoding output
       assign rs = _rs,
              rt = _rt,
              rd = _rd,
              shamt = _shamt,
              imm16 = _imm16,
              imm26 = _imm26;

// CTRL_AND

    wire _special;
    wire _add, _sub, _jr, _sll; // R-type ins
    wire _ori, _lw, _sw, _beq, _lui; // I-type ins
    wire _jal; // J-type ins
    wire _neo; // Reserved for new instruction

    assign _special = !(|_opcode);
    
    assign _add = _special & (_funct == 6'b100000),
           _sub = _special & (_funct == 6'b100010),
           _jr = _special & (_funct == 6'b001000),
           _sll = _special & (_funct == 6'b000000);

    assign _ori = (_opcode == 6'b001101),
           _lw = (_opcode == 6'b100011),
           _sw = (_opcode == 6'b101011),
           _beq = (_opcode == 6'b000100),
           _lui = (_opcode == 6'b001111);

    assign _jal = (_opcode == 6'b000011);

    // For new instruction
    assign _neo = (_opcode == 6'b111111) & (_funct == 6'b111111);
    assign neo = _neo;


// CTRL_OR

       // Instruction categories

              wire _no_reg_usage;
              assign _no_reg_usage = _lui;

              // NPC; 
                     wire _branch;
                            assign _branch = _beq;
                     wire _jump; // Condition?
                            wire _jump_26, _jump_32;
                                   assign _jump = _jump_26 | _jump_32;
                                          assign _jump_26 = _jal,
                                                 _jump_32 = _jr;
                     wire _cond;
                            wire _cond_eq, _cond_lt, _cond_gt, _cond_le, _cond_ge, _cond_uncond;
                                   assign _cond = _cond_uncond | _cond_eq;
                                          assign _cond_uncond = _jal | _jr,
                                                 _cond_eq = _beq;
                     wire _link;
                            assign _link = _jal;

                     // CMP;
                            wire _cmp_with_zero;
                                   assign _cmp_with_zero = 1'b0; // Grounded;
              
              // ALU; 
                     wire _calc;
                            wire _calc_add, _calc_sub, _calc_or, _calc_sll, _calc_imm16, _calc_shift;
                                   assign _calc = _calc_add | _calc_sub | _calc_or | _calc_sll;
                                          assign _calc_add = _add | _memory,
                                                 _calc_sub = _sub,
                                                 _calc_or = _ori,
                                                 _calc_sll = _sll | _lui,
                                          
                                                 _calc_imm16 = _ori | _lui | _memory,
                                                 _calc_shift = _sll;

              // DM; 
                     wire _memory;
                            wire _memory_read, _memory_write;
                                   assign _memory = _memory_read | _memory_write;
                                          assign _memory_read = _lw,
                                                 _memory_write = _sw;


              // 注意！当前仅_lui特殊，需要向下寻找特例！

       // Forwarding
              assign forward_m = (_calc & !_memory) | _link;
              assign forward_w = (_calc & !_memory_write) | _link;

              assign target = (_calc & !_calc_imm16) ? _rd : 
                            (_calc_imm16 & !_memory_write) ? _rt :
                            (_link) ? 5'd31 : 5'b0;

              // Forward source; For forwarding in STAGE M

                     // When a new value is generated in a module, the module becomes the source of forwarding.
                     wire _src_alu;
                     wire _src_pc_8;

                     assign _src_alu = (_calc & !_memory);
                     assign _src_pc_8 = _link;

                     assign forward_src = (_src_alu) ? `forward_src_alu :
                                          (_src_pc_8) ? `forward_src_pc_8 : 3'b000; // Temporary: default to alu_c

       // Stall

              // RD1 is usually linked with rs
              assign t_use_rd1 = (_no_reg_usage | _calc_shift) ? 3'd3 :    // inf.
                            ( _calc & !_no_reg_usage & !_calc_shift) ? 3'd1 :
                            3'd0;

              // RD2 is usually linked with rt
              assign t_use_rd2 = (_memory_read | _no_reg_usage) ? 3'd3 :        // regarded as 3'd3 (inf.) to prevent unexpected stall
                            (_memory_write) ? 3'd2 :
                            (_calc & !_no_reg_usage & !_memory) ? 3'd1 :
                            3'd0;

              assign t_new = (_memory_read) ? 3'd2 :
                            (_calc & !_memory) ? 3'd1 : 
                            3'd0;

       // Modules

              // NPC
                     wire _npc_op_b, _npc_op_j26, _npc_op_j32; // _npc_op_norm set as default; no judgement needed
                     assign _npc_op_b = _branch,
                            _npc_op_j26 = _jump_26,
                            _npc_op_j32 = _jump_32;

                     wire _npc_cond_uncond, _npc_cond_eq, _npc_cond_lt, _npc_cond_gt, _npc_le, _npc_ge;
                     assign _npc_cond_uncond = _cond_uncond,
                            _npc_cond_eq = _cond_eq;
                            // Reserved for future development

                     // Operation
                            assign npc_op = (_npc_op_b) ? `npc_op_b :
                                          (_npc_op_j26) ? `npc_op_j26 :
                                          (_npc_op_j32) ? `npc_op_j32 : `npc_op_norm;
                     // Condition
                            assign npc_cond = (_npc_cond_uncond) ? `npc_cond_uncond : 
                                          (_npc_cond_eq) ? `npc_cond_eq : 
                                                               `npc_cond_eq; // Temporary


              // CMP
                     //TODO: RD2 to MUX; RD2 or 32'b0       
                     assign mcmpa2_c = (_cmp_with_zero) ? 1'b1 : 1'b0;

              // EXT
                     wire _ext_signed; 
                     assign _ext_signed = _memory;

                     assign ext_signed = (_ext_signed) ? 1'b1 : 1'b0;

              // ALU
                     wire _alu_add, _alu_sub, _alu_or, _alu_sll; // _alu_add = _add | _lw | _sw   set as default
                     assign _alu_add = _calc_add, 
                            _alu_sub = _calc_sub,
                            _alu_or = _calc_or,
                            _alu_sll = _calc_sll;

                     assign alu_op = (_alu_add) ? `alu_add :
                                     (_alu_sub) ? `alu_sub :
                                     (_alu_or) ? `alu_or :
                                     (_alu_sll) ? `alu_sll : `alu_add;     

                     // MALUB
                            wire _malub_grf_a2, _malub_ext_b; // _malub_grf_a2 = _calc_imm16     GRF.A2 as default

                            assign _malub_grf_a2 = !_calc_imm16,
                                   _malub_ext_b = _calc_imm16; // TAKE CARE OF IT WHEN TAKING THE EXAM

                            assign malub_c =  (_malub_grf_a2) ? `malub_grf_a2 :
                                              (_malub_ext_b) ? `malub_ext_b : 
                                              `malub_grf_a2;
              
                     // MALUSA
                            wire _malusa_5d16, _malusa_v; // _malusa_ctrl_sa = _sll   CTRL.SA as default; v = variable, reserved for future dev.
                            assign _malusa_5d16 = _lui;
                            
                            assign malusa_c = (_malusa_5d16) ? `malusa_5d16 : `malusa_ctrl_sa; 
              // DM
                     wire _dm_we;
                     assign _dm_we = _memory_write;

                     assign dm_we = (_dm_we) ? 1'b1 : 1'b0;

              // GRF
                     wire _grf_we_n;
                     assign _grf_we_n = _memory_write | (_branch & !_link) | (_jump & !_link);

                     assign grf_we = (!_grf_we_n) ? 1'b1 : 1'b0;

                     // MGRFA3
                            wire _mgrfa3_rd, _mgrfa3_rt, _mgrfa3_5d31; // _mgrfa3_rd = !_calc_imm16 set as default

                            assign _mgrfa3_rd = !_calc_imm16,
                                   _mgrfa3_5d31 = _link,
                                   _mgrfa3_rt = _calc_imm16; // TAKE CARE OF IT WHEN TAKING THE EXAM

                            assign mgrfa3_c = (_mgrfa3_5d31) ? `mgrfa3_5d31: // jal优先级更高
                                          (_mgrfa3_rd) ? `mgrfa3_rd : 
                                          (_mgrfa3_rt) ? `mgrfa3_rt : 
                                          `mgrfa3_rd;

                     // MGRFWD
                            wire  _mgrfwd_dm_rd, _mgrfwd_pc_8; // ALU.C as default

                            assign _mgrfwd_dm_rd = _memory_read,
                                   _mgrfwd_pc_8 = _link;

                            assign mgrfwd_c = (_mgrfwd_dm_rd) ? `mgrfwd_dm_rd :
                                          (_mgrfwd_pc_8) ? `mgrfwd_pc_8 : 
                                          `mgrfwd_alu_c;
                            

endmodule
