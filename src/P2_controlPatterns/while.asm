# While

li $v0,5
syscall
move $s0,$v0

li $v0,5
syscall
move $s1,$v0

while: # > $s1
	move $a0,$s0
	li $v0,1
	syscall
	subi $s0,$s0,1
bgt $s0,$s1,while
nop

li $v0,10
syscall