	mfc0 $6,$12
	mfc0 $7,$13
	mfc0 $8,$14
	ori $2,$0,0
	
	mfc0 $k0, $13
    	ori $k1, $0, 0x7c
    	and $k0, $k0, $k1
    	
    	ori $25,$0,0x00000020
    	beq $k0,$25,handle_syscall
    	nop
    	ori $25,$0,0x00000028
    	beq $k0,$25,handle_syscall
    	nop
    	bne $20,$0,handle_pc
    	nop
 
    	return:
    	mfc0 $k0, $14
    	addi $k0, $k0, 4
    	sw $k0,0($0)
    	lw $18,0($0)
    	mtc0 $18, $14
	eret

	handle_syscall:
    	beq $0,$0,return
    	nop
    	
    	handle_pc:
    	add $21,$31,8
    	mtc0 $31,$14
    	beq $0,$0,return
    	nop
