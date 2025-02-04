// ALU 
    // ALUOp
    `define alu_add 4'b0000
    `define alu_sub  4'b0001
    `define alu_or  4'b0010
    `define alu_sll  4'b0011
    `define alu_and 4'b0100

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
    `define npc_cond_ne 3'b110

// SET
    `define set_cond_lt 3'b00

// Forwarding
    // Forward src for Stage D
        `define forward_src_d_set 3'b000
        `define forward_src_d_pc_8 3'b001
    // Forward src for Stage E
        `define forward_src_alu 3'b000
        `define forward_src_pc_8 3'b001
        `define forward_src_set 3'b010
        `define forward_src_hi 3'b011
        `define forward_src_lo 3'b100


// MUX
    // MGRFA3
    `define mgrfa3_rd 3'b000
    `define mgrfa3_rt 3'b001
    `define mgrfa3_5d31 3'b010
    // MGRFWD
    `define mgrfwd_alu_c 3'b000
    `define mgrfwd_dm_rd 3'b001
    `define mgrfwd_pc_8 3'b010
    `define mgrfwd_set 3'b011
    `define mgrfwd_hi 3'b100
    `define mgrfwd_lo 3'b101
    `define mgrfwd_cp0 3'b110
    
    // MALUB
    `define malub_grf_a2 3'b000
    `define malub_ext_b 3'b001
    // MALUSA
    `define malusa_ctrl_sa 3'b000
    `define malusa_5d16 3'b001

    // MCMPA2
    `define mcmpa2_rd2 2'b00
    `define mcmpa2_zero 2'b01
    `define mcmpa2_ext_imm16 2'b10

// DM
    // DMOp
    `define dm_word 2'b00
    `define dm_half 2'b01
    `define dm_byte 2'b10

// Exception code
    `define Int 5'd0
    `define AdEL 5'd4
    `define AdES 5'd5
    `define Syscall 5'd8
    `define RI 5'd10
    `define Ov 5'd12


