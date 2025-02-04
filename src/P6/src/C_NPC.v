`timescale 1ns / 1ps

`include "parameters.v"
module NPC(
    input [31:0] PC,
    input [31:0] C_PC, 
    input [15:0] IMM16,
    input [25:0] IMM26,
    input [31:0] IMM32,
    input [2:0] NPCOp,
    input EQ,LT,
    input [2:0] NPCCond,
    input stall,
    output [31:0] NPC
    );

    wire [31:0] _norm, _b, _j26, _j32;
    wire _cond, _uncond, _eq, _lt, _gt, _le, _ge, _ne;
    wire [31:0] _NPC, _NPC_temp;

    assign _norm = C_PC + 4,
           _b = PC + 4 + {{14{IMM16[15]}},IMM16,{2{1'b0}}},
           _j26 = {PC[31:28],IMM26,{2{1'b0}}},
           _j32 = IMM32;
            
    assign _uncond = 1'b1,
           _eq = EQ,
           _ne = !EQ,
           _lt = LT,
           _gt = !EQ & !LT,
           _le = LT | EQ,
           _ge = !LT;

    assign _cond = (NPCCond == `npc_cond_uncond) ? _uncond : 
                   (NPCCond == `npc_cond_ne) ? _ne : 
                   (NPCCond == `npc_cond_eq) ? _eq : 
                   (NPCCond == `npc_cond_lt) ? _lt : 
                   (NPCCond == `npc_cond_gt) ? _gt : 
                   (NPCCond == `npc_cond_le) ? _le : _ge;

    assign _NPC_temp = (NPCOp == `npc_op_norm) ? _norm :
                 (NPCOp == `npc_op_b) ? _b :
                 (NPCOp == `npc_op_j26) ? _j26 : _j32;

    assign _NPC = (_cond) ? _NPC_temp : _norm;

    assign NPC = (stall) ? C_PC : _NPC;

endmodule
