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
    output cmp_signed,
    output [1:0] dm_op,
    output dm_ext_signed,
    output [3:0] mgrfa3_c,
                 mgrfwd_c,
                 malub_c,
                 malusa_c,
    output [1:0] mcmpa2_c,
    output forward_e,
    output forward_m,
    output forward_w,
    output [4:0] target,
    output [2:0] forward_src_d,
    output [2:0] forward_src, 
    output [2:0] t_use_rd1, t_use_rd2, t_new,
    output [2:0] set_cond,
    output md_start, md_op, md_signed, md_ovrd, md_ovrd_dest,
    output read_hi, read_lo,
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
    wire _and, _andi, _addi, _or;
    wire _lb, _lh, _sb, _sh;
    wire _bne;
    wire _slt, _sltu;
    wire _mult, _multu, _div, _divu;
    wire _mfhi, _mflo, _mthi, _mtlo;


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

    assign _and = _special & (_funct == 6'b100100);
    assign _andi = (_opcode == 6'b001100);
    assign _addi = (_opcode == 6'b001000);
    assign _or = _special & (_funct == 6'b100101);

    assign _lh = (_opcode == 6'b100001);
    assign _sh = (_opcode == 6'b101001);
    assign _lb = (_opcode == 6'b100000);
    assign _sb = (_opcode == 6'b101000);

    assign _slt = _special & (_funct == 6'b101010);
    assign _sltu = _special & (_funct == 6'b101011);

    assign _bne = (_opcode == 6'b000101);

    assign _mult = _special & (_funct == 6'b011000),
           _multu = _special & (_funct == 6'b011001),
           _div = _special & (_funct == 6'b011010),
           _divu = _special & (_funct == 6'b011011);

    assign _mfhi = _special & (_funct == 6'b010000),
           _mflo = _special & (_funct == 6'b010010),
           _mthi = _special & (_funct == 6'b010001),
           _mtlo = _special & (_funct == 6'b010011);

    // For new instruction
    assign _neo = (_opcode == 6'b111111) & (_funct == 6'b111111);
    assign neo = _neo;


// CTRL_OR

       // Instruction categories

              wire _no_reg_usage;
              assign _no_reg_usage = _lui | _md_read;

              // NPC; 
                     wire _branch;
                            assign _branch = _beq | _bne;
                     wire _jump; // Condition?
                            wire _jump_26, _jump_32;
                                   assign _jump = _jump_26 | _jump_32;
                                          assign _jump_26 = _jal,
                                                 _jump_32 = _jr;
                     wire _cond;
                            wire _cond_eq, _cond_lt, _cond_gt, _cond_le, _cond_ge, _cond_uncond, _cond_ne;
                                   assign _cond = _cond_uncond | _cond_eq | _cond_ne;
                                          assign _cond_uncond = _jal | _jr,
                                                 _cond_ne = _bne,
                                                 _cond_eq = _beq;
                     wire _link;
                            assign _link = _jal;

              // CMP;
                     // Signed?
                     wire _cmp_signed;
                     assign _cmp_signed = _cond | (_set & !_set_unsigned);
                     assign cmp_signed = (_cmp_signed) ? 1'b1 : 1'b0;

                     // MCMPA2
                     wire _cmp_with_zero;
                            assign _cmp_with_zero = 1'b0; // Grounded;
                     wire _cmp_with_signed_imm16;
                            assign _cmp_with_signed_imm16 = _set_imm16;
              
              // SET
                     wire _set;
                            wire _set_lt;
                                   assign _set = _set_lt;
                                          assign _set_lt = _slt | _sltu;
                            wire _set_imm16;
                                   assign _set_imm16 = 1'b0; // Grounded
                            wire _set_unsigned;
                                   assign _set_unsigned = _sltu;
                                   
              
              // ALU; 
                     wire _calc;
                            wire _calc_and, _calc_add, _calc_sub, _calc_or, _calc_sll, _calc_imm16, _calc_shift;
                                   assign _calc = _calc_and | _calc_add | _calc_sub | _calc_or | _calc_sll;
                                          assign _calc_and = _and | _andi,
                                                 _calc_add = _add | _memory | _addi,
                                                 _calc_sub = _sub,
                                                 _calc_or = _or | _ori,
                                                 _calc_sll = _sll | _lui,
                                          
                                                 _calc_imm16 = _andi | _addi | _ori | _lui | _memory,
                                                 _calc_shift = _sll;
                            wire _calc_zero_ext, _calc_signed_ext;
                                   assign _calc_zero_ext = _andi | _ori,
                                          _calc_signed_ext = _addi;

              // MD
                     wire _md;
                            assign _md = _md_mult | _md_div | _md_write | _md_read;
                                   wire _md_signed;
                                          assign _md_signed = _mult | _div;
                                   wire _md_mult, _md_div;
                                          assign _md_mult = _mult | _multu,
                                                 _md_div = _div | _divu;
                                   wire _md_write;
                                          wire _md_mthi, _md_mtlo;
                                          assign _md_write = _md_mthi | _md_mtlo;
                                                 assign _md_mthi = _mthi,
                                                        _md_mtlo = _mtlo;
                                   wire _md_read;
                                          wire _md_mfhi, _md_mflo;
                                          assign _md_read = _md_mfhi | _md_mflo;
                                                 assign _md_mfhi = _mfhi,
                                                        _md_mflo = _mflo;

              // DM; 
                     wire _memory;
                            wire _memory_read, _memory_write;
                                   assign _memory = _memory_read | _memory_write;
                                          assign _memory_read = _lw | _lh | _lb,
                                                 _memory_write = _sw | _sh | _sb;
                            wire _memory_word, _memory_half, _memory_byte;
                                   assign _memory_word = _lw | _sw,
                                          _memory_half = _lh | _sh,
                                          _memory_byte = _lb | _sb;
                            wire _memory_ext_signed;
                                   assign _memory_ext_signed = _lb | _lh;

              // 注意！当前仅_lui特殊，需要向下寻找特例！

       // Forwarding

              assign forward_e = _set | _link;
              assign forward_m = (_calc & !_memory) | _link | _set | _md_read;
              assign forward_w = (_calc & !_memory_write) | _link | _set | _md_read;

              assign target = ( (_calc & !_calc_imm16) | (_set & !_set_imm16) | _md_read) ? _rd : 
                            ((_calc_imm16 & !_memory_write) | _set_imm16) ? _rt :
                            (_link) ? 5'd31 : 5'b0;

              

              // Forward source; For forwarding in STAGE E
                     wire _src_d_set = _set;
                     wire _src_d_pc_8 = _link;
                     assign forward_src_d = (_src_d_set) ? `forward_src_d_set :
                                            (_src_d_pc_8) ? `forward_src_d_pc_8 :
                                            `forward_src_d_set;

              // Forward source; For forwarding in STAGE M

                     // When a new value is generated in a module, the module becomes the source of forwarding.
                     wire _src_alu;
                     wire _src_pc_8;
                     wire _src_set;
                     wire _src_hi, _src_lo;

                     assign _src_alu = (_calc & !_memory);
                     assign _src_pc_8 = _link;
                     assign _src_set = _set;
                     assign _src_hi = _md_mfhi;
                     assign _src_lo = _md_mflo;

                     assign forward_src = (_src_hi) ? `forward_src_hi :
                                          (_src_lo) ? `forward_src_lo :
                                          (_src_set) ? `forward_src_set :
                                          (_src_alu) ? `forward_src_alu :
                                          (_src_pc_8) ? `forward_src_pc_8 : 3'b000; // Temporary: default to alu_c

       // Stall

              // RD1 is usually linked with rs
              assign t_use_rd1 = (_no_reg_usage | _calc_shift) ? 3'd3 :    // inf.
                            ( (_calc & !_no_reg_usage & !_calc_shift) | _md_mult | _md_div | _md_write) ? 3'd1 :
                            (_set) ? 3'd0 :
                            3'd0;

              // RD2 is usually linked with rt
              assign t_use_rd2 = (_memory_read | _no_reg_usage | _set_imm16 | _md_write) ? 3'd3 :        // regarded as 3'd3 (inf.) to prevent unexpected stall
                            (_memory_write) ? 3'd2 :
                            ((_calc & !_no_reg_usage & !_memory) | _md_mult | _md_div ) ? 3'd1 :
                            ((_set & !_set_imm16)) ? 3'd0 :
                            3'd0;

              assign t_new = (_memory_read) ? 3'd2 :
                            ((_calc & !_memory) | _md_read) ? 3'd1 : 
                            (_set) ? 3'd0 :
                            3'd0;

       // Modules

              // NPC
                     wire _npc_op_b, _npc_op_j26, _npc_op_j32; // _npc_op_norm set as default; no judgement needed
                     assign _npc_op_b = _branch,
                            _npc_op_j26 = _jump_26,
                            _npc_op_j32 = _jump_32;

                     wire _npc_cond_uncond, _npc_cond_eq, _npc_cond_lt, _npc_cond_gt, _npc_cond_le, _npc_cond_ge, _npc_cond_ne;
                     assign _npc_cond_uncond = _cond_uncond,
                            _npc_cond_ne = _cond_ne,
                            _npc_cond_eq = _cond_eq;
                            // Reserved for future development

                     // Operation
                            assign npc_op = (_npc_op_b) ? `npc_op_b :
                                          (_npc_op_j26) ? `npc_op_j26 :
                                          (_npc_op_j32) ? `npc_op_j32 : `npc_op_norm;
                     // Condition
                            assign npc_cond = (_npc_cond_uncond) ? `npc_cond_uncond : 
                                              (_npc_cond_ne) ? `npc_cond_ne : 
                                              (_npc_cond_eq) ? `npc_cond_eq : 
                                                               `npc_cond_eq; // Temporary


              // CMP
                     //TODO: RD2 to MUX; RD2 or 32'b0       
                     assign mcmpa2_c = (_cmp_with_zero) ? `mcmpa2_zero :
                                       (_cmp_with_signed_imm16) ? `mcmpa2_ext_imm16 :
                                       `mcmpa2_rd2;

              // EXT
                     wire _ext_signed; 
                     assign _ext_signed = _memory | _cmp_with_signed_imm16 | _calc_signed_ext;

                     assign ext_signed = (_ext_signed) ? 1'b1 : 1'b0;

              // SET
                     assign set_cond = (_set_lt) ? `set_cond_lt :
                                       `set_cond_lt;

              // ALU
                     wire _alu_and, _alu_add, _alu_sub, _alu_or, _alu_sll; // _alu_add = _add | _lw | _sw   set as default
                     assign _alu_and = _calc_and,
                            _alu_add = _calc_add, 
                            _alu_sub = _calc_sub,
                            _alu_or = _calc_or,
                            _alu_sll = _calc_sll;

                     assign alu_op = (_alu_and) ? `alu_and : 
                                     (_alu_add) ? `alu_add :
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
              
              // MD
                     assign md_start = _md_mult | _md_div;
                     assign md_op = (_md_mult) ? 1'b1 : 1'b0;
                     assign md_signed = _md_signed;
                     assign md_ovrd = _md_write;
                     assign md_ovrd_dest = (_md_mthi) ? 1'b1 : 1'b0;

                     assign read_hi = _md_mfhi,
                            read_lo = _md_mflo;
       
              // DM
                     wire _dm_we;
                     assign _dm_we = _memory_write;
                     assign dm_we = (_dm_we) ? 1'b1 : 1'b0;

                     wire _dm_op_word, _dm_op_half, _dm_op_byte;
                     assign _dm_op_word = _memory_word,
                            _dm_op_half = _memory_half,
                            _dm_op_byte = _memory_byte;
                     assign dm_op = (_dm_op_word) ? `dm_word :
                                    (_dm_op_half) ? `dm_half :
                                    `dm_byte;

                     wire _dm_ext_signed;
                     assign _dm_ext_signed = _memory_ext_signed;
                     assign dm_ext_signed = (_dm_ext_signed) ? 1'b1 : 1'b0;

              // GRF
                     wire _grf_we_n;
                     assign _grf_we_n = _memory_write | (_branch & !_link) | (_jump & !_link) | _md_mult | _md_div | _md_write;

                     assign grf_we = (!_grf_we_n) ? 1'b1 : 1'b0;

                     // MGRFA3
                            wire _mgrfa3_rd, _mgrfa3_rt, _mgrfa3_5d31; // _mgrfa3_rd = !_calc_imm16 set as default

                            assign _mgrfa3_rd = (!_calc_imm16 & !_set_imm16) | _md_read,
                                   _mgrfa3_5d31 = _link,
                                   _mgrfa3_rt = _calc_imm16 | _set_imm16; // TAKE CARE OF IT WHEN TAKING THE EXAM

                            assign mgrfa3_c = (_mgrfa3_5d31) ? `mgrfa3_5d31: // jal优先级更高
                                          (_mgrfa3_rd) ? `mgrfa3_rd : 
                                          (_mgrfa3_rt) ? `mgrfa3_rt : 
                                          `mgrfa3_rd;

                     // MGRFWD
                            wire  _mgrfwd_dm_rd, _mgrfwd_pc_8, _mgrfwd_set; // ALU.C as default
                            wire _mgrfwd_hi, _mgrfwd_lo;

                            assign _mgrfwd_dm_rd = _memory_read,
                                   _mgrfwd_pc_8 = _link,
                                   _mgrfwd_set = _set,
                                   _mgrfwd_hi = _md_mfhi,
                                   _mgrfwd_lo = _md_mflo;

                            assign mgrfwd_c = (_mgrfwd_hi) ? `mgrfwd_hi :
                                              (_mgrfwd_lo) ? `mgrfwd_lo :
                                              (_mgrfwd_dm_rd) ? `mgrfwd_dm_rd :
                                              (_mgrfwd_pc_8) ? `mgrfwd_pc_8 : 
                                              (_mgrfwd_set) ? `mgrfwd_set :
                                              `mgrfwd_alu_c;
                            

endmodule
