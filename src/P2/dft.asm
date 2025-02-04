.data
adje: .space 256 # 8*8*4
points: .space 32 # 4*8

.macro addr_calc(%des,%a,%b)
	sll %des,%a,3
	add %des,%des,%b
	sll %des,%des,2
.end_macro

.macro read_num(%dest)
	li $v0,5
	syscall
	move %dest,$v0
.end_macro

.macro push(%src)
    addi    $sp, $sp, -4
    sw      %src, 0($sp)
.end_macro

.macro pop(%des)
    lw      %des, 0($sp)
    addi    $sp, $sp, 4
.end_macro

.text
read_num($t0) # $t0 = n ,num of points
read_num($t1) # $t1 = m , num of edges

# Read edges
start_read:
beq $t1,$t3,read_end
	read_num($t4) # $t4 = a
	read_num($t5) # $t5 = b
	addi $t4,$t4,-1
	addi $t5,$t5,-1
	
	addr_calc($t6,$t4,$t5)
	li $t2,1
	sw $t2,adje($t6)
	addr_calc($t6,$t5,$t4)
	li $t2,1
	sw $t2,adje($t6)
	
	addi $t3,$t3,1
j start_read

read_end:
li $a2,0
jal dft

li $v0,1
syscall
li $v0,10
syscall
# At this time, $t3-t6 is no longer used
# $a0 is reserved for ans, $a1 is for the argument of dfs() and uses $a2 to pass it
# DFT
dft:
	push($a1)
	push($t8)
	push($ra)
	move $a1,$a2
	move $t3,$a1
	sll $t4,$t3,2
	li $v0,1
	sw $v0,points($t4) # book[x] = 1, reused the 1 in $v0
	move $t5,$v0 # flag = $t5 = 1
	li $t6,0
	flag:
	beq $t0,$t6,flag_end # $t6 as i
		sll $t7,$t6,2
		lw $t8,points($t7)
		and $t5,$t5,$t8
		addi $t6,$t6,1
	j flag
	flag_end:
	
	if:
	beqz $t5,end_if
	addr_calc($t3,$a1,$0)
	lw $t4,adje($t3)
	beqz $t4,end_if
	#return()
		li $a0,1
		pop($ra)
		pop($t8)
		pop($a1)
		jr $ra
	end_if:
	# $t8 used as i
	li $t8,0
	
	stage3:
	beq $t8,$t0,s3e
	sll $t3,$t8,2
	lw $t4,points($t3)
	bnez $t4,s3n
	addr_calc($t5,$a1,$t8)
	lw $t6,adje($t5)
	beqz $t6,s3n
	move $a2,$t8
	jal dft
	s3n:
	addi $t8,$t8,1
	j stage3
	
	
	s3e:
	sll $t9,$a1,2
	sw $0,points($t9)
	pop($ra)
	pop($t8)
	pop($a1)
	jr $ra
	
	
	
	
	

	



