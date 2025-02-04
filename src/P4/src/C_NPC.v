`timescale 1ns / 1ps

`include "parameters.v"
module NPC(
    input [31:0] PC,
    input [15:0] IMM16,
    input [25:0] IMM26,
    input [31:0] IMM32,
    input [2:0] NPCOp,
    input EQ,LT,
    input [2:0] NPCCond,
    output [31:0] NPC,PC4
    );

    wire [31:0] _norm, _b, _b_temp, _j26, _j32;
    wire _cond,_eq, _lt, _gt, _le, _ge;

    assign _norm = PC + 4,
           _b_temp = PC + 4 + {{14{IMM16[15]}},IMM16,{2{1'b0}}},
           _j26 = {PC[31:28],IMM26,{2{1'b0}}},
           _j32 = IMM32;
            
    assign _eq = EQ,
           _lt = LT,
           _gt = !EQ & !LT,
           _le = LT | EQ,
           _ge = !LT;

    assign _cond = (NPCCond == `npc_cond_eq) ? _eq : 
                   (NPCCond == `npc_cond_lt) ? _lt : 
                   (NPCCond == `npc_cond_gt) ? _gt : 
                   (NPCCond == `npc_cond_le) ? _le : _ge;

    assign _b = (_cond) ? _b_temp : _norm; 

    assign NPC = (NPCOp == `npc_op_norm) ? _norm :
                 (NPCOp == `npc_op_b) ? _b :
                 (NPCOp == `npc_op_j26) ? _j26 : _j32;
                   
    assign PC4 = _norm;

endmodule
