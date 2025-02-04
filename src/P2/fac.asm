.data
result: .space 4096 # 1024 * 4 words

.text
# Initialize
li $v0,5
syscall
move $a1,$v0
li $t0,1
sw $t0,result($0) # init result = 1
li $s1,0 # $s1 =  ( number of bits ) - 1
li $s2,0 # $s2 = $s1 * 4
li $s3,10 # Constant

# Begin
li $t0,1 # $t0 as multiplier
for_1:
	# Multiply without carry
	li $t1,0
	for_2:
		lw $t2,result($t1)
		mul $t2,$t2,$t0	
		sw $t2,result($t1)
	addi $t1,$t1,4
	ble $t1,$s2,for_2
	nop
		
addi $t0,$t0,1
ble $t0,$a1,for_1
nop


# Forward the carries
	li $t1,0
	for_3:	
		lw $t2,result($t1)
		div $t2,$s3 # LO =quotient, HI = remainder
		mflo $t3
		beqz $t3,no_carry
		nop
		mfhi $t3 
		move $t2,$t3
		sw $t2,result($t1)
		
		addi $t1,$t1,4
		mflo $t2
		lw $t3,result($t1)
		add $t3,$t3,$t2
		sw $t3,result($t1)
		subi $t1,$t1,4
		no_carry:
		bne $t1,$s2,not_highest
		nop	
			addi $t1,$t1,4
			lw $t3,result($t1)
			beqz $t3,forward # No number remains unrecorded 
			nop
			# Else...
			addi $s1,$s1,1
			addi $s2,$s2,4
			
			div $t3,$s3
			mflo $t4
			beqz $t4,forward
			nop
			# MORE
			mfhi $t4
			move $t3,$t4
			sw $t3,result($t1)
				addi $t1,$t1,4
				lw $t5,result($t1)
				mflo $t4
				add $t5,$t5,$t4
				sw $t5,result($t1)
				addi $s1,$s1,1
				addi $s2,$s2,4
				subi $t1,$t1,4
			forward:
			subi $t1,$t1,4
		not_highest:
	addi $t1,$t1,4
	ble $t1,$s2,for_3
	nop


li $v0,10
syscall
