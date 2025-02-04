.data
matrix_a: .space 256 # matrix[8][8],8*8*4; aligned with word for easier debugging
matrix_b: .space 256
.macro addr_calc(%dest,%a,%b)
	move %dest,%a
	sll %dest,%dest,3
	add %dest,%dest,%b
	sll %dest,%dest,2	
.end_macro

.text
# Plan ahead!!!
# $t0 to store level; $t1,$t2 to control

#for(int i)
#	for(int j)
#		SUM=0
#		for(int k)
#			sum += a[i][k] * b[k][j]
#		a[i][j] = sum


li $v0,5
syscall
move $a0,$v0  # This is silly; $a0 will be used in syscall and may be a nuisance


li $t0,0 #i
li $t1,0 #j
for_i0:
li $t1,0 #!!!!
	for_j0:
		addr_calc($t2,$t0,$t1)
		li $v0,5
		syscall
		sw $v0,matrix_a($t2)
	addi $t1,$t1,1	
	bne $t1,$a0,for_j0
	nop
addi $t0,$t0,1
bne $t0,$a0,for_i0
nop



li $t0,0 #i
li $t1,0 #j
for_i1:
li $t1,0 #!!!!
	for_j1:
		addr_calc($t2,$t0,$t1)
		li $v0,5
		syscall
		sw $v0,matrix_b($t2)
	addi $t1,$t1,1	
	bne $t1,$a0,for_j1
	nop
addi $t0,$t0,1
bne $t0,$a0,for_i1
nop





li $t0,0 #i
li $t1,0 #j
li $t2,0 #k
li $t3,0 #sum
for_i:
	li $t1,0 #!!!!
	for_j:
		li $t2,0 #!!!!
		li $t3,0
		for_k:
			addr_calc($t4,$t0,$t2)
			addr_calc($t5,$t2,$t1)
			lw $t6,matrix_a($t4)
			lw $t7,matrix_b($t5)
			mul $s0,$t6,$t7
			add $t3,$t3,$s0
		addi $t2,$t2,1
		bne $t2,$a0,for_k
		nop
	move $s0,$a0
	
	move $a0,$t3
	li $v0,1
	syscall
	
	li $a0,32
	li $v0,11
	syscall
	
	move $a0,$s0
	addi $t1,$t1,1	
	bne $t1,$a0,for_j
	nop
	
move $s0,$a0	
li $a0,10
li $v0,11
syscall	
move $a0,$s0	
	
addi $t0,$t0,1
bne $t0,$a0,for_i
nop

li $v0,10
syscall
