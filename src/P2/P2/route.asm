.data
matrix:   .space  256                     # 8*8*4
accessed: .space  256

 .macro  addr_calc(%dest, %a, %b)
li %dest,0
add     %dest,  %dest,  %a
sll     %dest,  %dest,  3
add     %dest,  %dest,  %b
sll     %dest,  %dest,  2
.end_macro

.macro push(%reg)
	sub $sp,$sp,4
	sw %reg,0($sp)
.end_macro

.macro pop(%reg)
	lw %reg,0($sp)
	add $sp,$sp,4
.end_macro

.text
# Read [n,m] to [$s0,$s1]
li $v0,5
syscall
move $s0,$v0
li $v0,5
syscall
move $s1,$v0
# Load matrix data
li $t0,1
for_1:
	li $t1,1
	for_2:
		addr_calc($t2,$t0,$t1)
		li $v0,5
		syscall
		sw $v0,matrix($t2)
	addi $t1,$t1,1
	ble $t1,$s1,for_2
	nop
addi $t0,$t0,1
ble $t0,$s0,for_1
nop
# $t0,$t1,$t2 no longer used
# Read [sx,sy] and [ex,ey] to [$s2,$s3] and [$s4,$s5] 
li $v0,5
syscall
move $s2,$v0
li $v0,5
syscall
move $s3,$v0

li $v0,5
syscall
move $s4,$v0
li $v0,5
syscall
move $s5,$v0

# Start!
# Using $a1,$a2 to pass arguments,$a0 for return value
move $a1,$s2
move $a2,$s3
jal search
nop
li $v0,1
syscall
li $v0,10
syscall

search:
# Using $a1,$a2 to pass arguments,$a0 for return value
# When incrusively invocated, related reg shall be protected BEFORE BRANCHING
# AFTER RETURNING, pop the protected reg from stack
	addr_calc($t0,$a1,$a2)
	## DO NO READ WHEN ADDR IS INVALID!
	blez $a1,search_return_0
	nop
	blez $a2,search_return_0
	nop
	blt $s0,$a1,search_return_0
	nop
	blt $s1,$a2,search_return_0
	
	lw $t1,accessed($t0)	
	bnez $t1,search_return_0
	nop
	
	lw $t1,matrix($t0)	
	bnez $t1,search_return_0
	nop
	
	bne $a1,$s4,search_norm
	nop
	beq $a2,$s5,search_return_1
	nop
	
	
	search_norm:
	li $t1,1
	sw $t1,accessed($t0)
	# Protect!
	push($ra)
	push($a1)
	push($a2)
	push($t0)
		# Up
		subi $a1,$a1,1
		jal search
		nop
	pop($t0)
	pop($a2)
	pop($a1)
	pop($ra)
	
	push($ra)
	push($a1)
	push($a2)
	push($t0)
		# Down
		addi $a1,$a1,1
		jal search
		nop
	pop($t0)
	pop($a2)
	pop($a1)
	pop($ra)
	
	push($ra)
	push($a1)
	push($a2)
	push($t0)
		# Left
		subi $a2,$a2,1
		jal search
		nop
	pop($t0)
	pop($a2)
	pop($a1)
	pop($ra)
	
	push($ra)
	push($a1)
	push($a2)
	push($t0)
		# Right
		addi $a2,$a2,1
		jal search
		nop
	pop($t0)
	pop($a2)
	pop($a1)
	pop($ra)
	
	li $t1,0
	sw $t1,accessed($t0)
	jr $ra
	nop

search_return_0:
addi $a0,$a0,0
jr $ra	
nop
search_return_1:
addi $a0,$a0,1
jr $ra 
nop