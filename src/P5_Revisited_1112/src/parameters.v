// ALU 
    // ALUOp
    `define alu_add 4'b0000
    `define alu_sub  4'b0001
    `define alu_or  4'b0010
    `define alu_sll  4'b0011

// NPC
    // NPCOp
    `define npc_op_norm 3'b000
    `define npc_op_b 3'b001
    `define npc_op_j26 3'b010
    `define npc_op_j32 3'b011
    // NPCCond
    `define npc_cond_eq 3'b000
    `define npc_cond_lt 3'b001
    `define npc_cond_gt 3'b010
    `define npc_cond_le 3'b011
    `define npc_cond_ge 3'b100
    `define npc_cond_uncond 3'b101

// Forwarding
    `define forward_src_alu 3'b000
    `define forward_src_pc_8 3'b001

// MUX
    // MGRFA3
    `define mgrfa3_rd 3'b000
    `define mgrfa3_rt 3'b001
    `define mgrfa3_5d31 3'b010
    // MGRFWD
    `define mgrfwd_alu_c 3'b000
    `define mgrfwd_dm_rd 3'b001
    `define mgrfwd_pc_8 3'b010
    
    // MALUB
    `define malub_grf_a2 3'b000
    `define malub_ext_b 3'b001
    // MALUSA
    `define malusa_ctrl_sa 3'b000
    `define malusa_5d16 3'b001




