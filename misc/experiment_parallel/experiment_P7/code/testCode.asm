# AdEL
	# lw align
	ori $2,$0,2
	lw $5,0($2)
	# lh align
	ori $2,$0,1
	lh $5,0($2)
	# lh,lb to Timer 
	ori $2,$0,0x7F00
	lh $5,0($2)
	lb $5,0($2)
	ori $2,$0,0x7F10
	lh $5,0($2)
	lb $5,0($2)
	# DM_ADDR Overflow
	ori $2,$0,0xffffffff
	ori $3,$0,2
	lw $5,0($2)
	lh $5,0($2)
	lb $5,0($2)
	# Out Of Range
	ori $2,$0,0x7f24
	lw $5,0($2)
	lh $5,0($2)
	lb $5,0($2)
# AdES
	# sw align
	ori $2,$0,2
	sw $5,0($2)
	# sh align
	ori $2,$0,1
	sh $5,0($2)
	# sh,sb to Timer 
	ori $2,$0,0x7F00
	sh $5,0($2)
	sb $5,0($2)
	ori $2,$0,0x7F10
	sh $5,0($2)
	sb $5,0($2)
	# DM_ADDR Overflow
	ori $2,$0,0xffffffff
	ori $3,$0,2
	sw $5,0($2)
	sh $5,0($2)
	sb $5,0($2)
	# Save to count
	ori $2,$0,0x7f09
	sw $5,0($2)
	ori $2,$0,0x7f09
	sh $5,0($2)
	ori $2,$0,0x7f09
	sb $5,0($2)
	ori $2,$0,0x7f18
	sw $5,0($2)
	ori $2,$0,0x7f18
	sh $5,0($2)
	ori $2,$0,0x7f18
	sb $5,0($2)
	# Out Of Range
	ori $2,$0,0x7f25
	sw $5,0($2)
	sh $5,0($2)
	sb $5,0($2)
	
# Syscall
	ori $2,$0,32
	syscall	
# Ov
	ori $2,$0,0x7fffffff
	ori $3,$0,1
	add $5,$2,$3
	addi $5,$2,1
	
	ori $2,$0,0xffffffff
	ori $3,$0,0xffffffff
	sub $5,$2,$3
# RI 
	j next
	nop
	next:
	ori $2,$0,0xffffffff
	
# Special: PC associated
	ori $20,$0,1
	ori $21,$0,0x00002fff
	jal next_1
	nop
	next_1:
	jr $21
	nop
	ori $20,$0,0
	
	ori $20,$0,1
	ori $21,$0,0x00003001
	jal next_2
	nop
	next_2:
	jr $21
	nop
	ori $20,$0,0
	
ori $31,$0,0xffffffff	
end:
beq $0,$0,end
	
.ktext 0x4180
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
