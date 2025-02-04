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
	# $a2 as carry
	li $t1,0
	for_2:
		lw $t2,result($t1)
		mul $t2,$t2,$t0	
		add $t2,$t2,$a2
		li $a2,0
		sw $t2,result($t1)
		
		# Forward the carries
		lw $t2,result($t1)
		div $t2,$s3 # LO = quotient, HI = remainder
		mflo $t3
		beqz $t3,no_carry
		nop
		
		mfhi $t3 
		move $t2,$t3
		sw $t2,result($t1)
		
		mflo $t2
		move $a2,$t2
		bne $t1,$s2,no_carry # Skip when not at the highest bit
		addi $s1,$s1,1
		addi $s2,$s2,4		
		no_carry:
	addi $t1,$t1,4
	ble $t1,$s2,for_2
	nop
addi $t0,$t0,1
ble $t0,$a1,for_1
nop

# 好!把他们上市！
for_4:
lw $a0,result($s2)
li $v0,1
syscall
subi $s2,$s2,4
bgez $s2,for_4


li $v0,10
syscall
