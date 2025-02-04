.data
symbol: .byte 0:7
array: .byte 0:7


.macro push(%reg)
	subi $sp,$sp,4
	sw %reg,0($sp)
.end_macro

.macro pop(%out)
	lw %out,0($sp)
	addi $sp,$sp,4
.end_macro

# Start of program
.text
li $v0,5
syscall
move $a2,$v0
# $a1 as index
# $a2 as n // $a0 reserved for syscall
li $a1,0 # Before calling, argument shall be passed
jal fullArray
nop
li $v0,10
syscall

fullArray:

bge $a1,$a2,fullArray_end
nop

## $t1 used as iterator
li $t1,0
for1_loop:
	lb $t2,symbol($t1)
	bnez $t2,f1le
	nop
	addi $t1,$t1,1
	sb $t1,array($a1)
	subi $t1,$t1,1
	li $t2,1
	sb $t2,symbol($t1)
	
	addi $a1,$a1,1
	
	push($t1)
	push($a1)
	push($ra)
	jal fullArray
	nop
	
	pop($ra)
	pop($a1)
	pop($t1)
	
	sb $0,symbol($t1)
	subi $a1,$a1,1
	
f1le:
addi $t1,$t1,1
blt $t1,$a2,for1_loop
nop

jr $ra
nop

fullArray_end:
# $t0 used as iterator

li $t0,0
for_loop:
	lb $a0,array($t0)
 	li $v0,1
 	syscall
  	li $a0,32
  	li $v0,11
  	syscall
addi $t0,$t0,1
blt $t0,$a2,for_loop 
nop

li $a0,10
li $v0,11
syscall
jr $ra
nop