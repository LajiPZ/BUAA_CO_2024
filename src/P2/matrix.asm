.data
element: .space 16384 # a[n][m] ,64*64*4, made easier for sll ,16384
# You're better off printing a single character using ASCII value and syscall(11) in order to save available memory space
.macro addr_calc(%ans,%a,%m)
	sll %ans,%a,6
	add %ans,%ans,%m
	sll %ans,%ans,2
.end_macro

.text
## Set the width and height of the matrix
li $v0,5
syscall
move $s0, $v0 # n to $s0 
li $v0,5
syscall
move $s1, $v0 # m to $s1
## Start of loop
move $t0,$0
stage1:
	beq $t0,$s0,output_stage1_pre  #
	move $t1,$0
		stage2:
			beq $t1,$s1,stage2_end
			addr_calc($t2,$t0,$t1)
			li $v0,5
			syscall
			sw $v0,element($t2)
			addi $t1,$t1,1
		j stage2
		# nop
stage2_end:
addi $t0,$t0,1
j stage1
# nop

output_stage1_pre:
addi $s1,$s1,-1
addi $s0,$s0,-1
move $t1,$s1
move $t0,$s0
j output_stage1

## Let's do output
output_stage1:
	bltz $t0,end
		move $t1,$s1
		output_stage2:
			bltz $t1,output_stage2_end
			addr_calc($t2,$t0,$t1)			
			lw $t3,element($t2)
			bnez $t3,output_mid
			output_back:
			addi $t1,$t1,-1
		j output_stage2
output_stage2_end:
addi $t0,$t0,-1
j output_stage1

output_mid:
			addi $a0,$t0,1
			li $v0,1
			syscall
			li $a0,32
			li $v0,11
			syscall
			addi $a0,$t1,1
			li $v0,1
			syscall
			la $a0,32
			li $v0,11
			syscall
			

			lw $a0,element($t2)
			li $v0, 1
			syscall
			
			la $a0,10
			li $v0,11
			syscall
			
			j output_back

end:
li $v0,10
syscall
