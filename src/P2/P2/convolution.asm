.data
matrix_f: .space 1024 #16*16*4
matrix_h: .space 1024

.macro addr_calc(%dest,%a,%b)
	move %dest,%a
	sll %dest,%dest,4
	add %dest,%dest,%b
	sll %dest,%dest,2
.end_macro

.text
# $s0 = m1 ,$s1 = n1; $s2 = m2, $s3 = n2
li $v0,5
syscall
move $s0,$v0

li $v0,5
syscall
move $s1,$v0

li $v0,5
syscall
move $s2,$v0
  
li $v0,5
syscall
move $s3,$v0

# $s4 = m3, $s5 = n3
sub $s4,$s0,$s2
addi $s4,$s4,1

sub $s5 $s1,$s3
addi $s5,$s5,1

# Reading f(m1,n1)
# Using $t0,$t1 as iterator
li $t0,0
for_1_1:
	li $t1,0
	for_1_2:
		li $v0,5
		syscall
		move $t2,$v0 #$v0而非$a0!!几次了！！！
		addr_calc($t3,$t0,$t1)
		sw $t2,matrix_f($t3)
		addi $t1,$t1,1
	blt $t1,$s1,for_1_2
	nop
addi $t0,$t0,1
blt $t0,$s0,for_1_1
nop

li $t0,0
for_2_1:
	li $t1,0
	for_2_2:
		li $v0,5
		syscall
		move $t2,$v0
		addr_calc($t3,$t0,$t1)
		sw $t2,matrix_h($t3)
		addi $t1,$t1,1
	blt $t1,$s3,for_2_2
	nop
addi $t0,$t0,1
blt $t0,$s2,for_2_1
nop


# Using $a1 to store sum
li $t0,0
for_3_1:
	li $t1,0
	for_3_2:
		li $t2,0
		li $a1,0
		for_4_1:
			li $t3,0
			for_4_2:
				addr_calc($t4,$t2,$t3)
				add $t8,$t0,$t2
				add $t9,$t1,$t3
				addr_calc($t5,$t8,$t9)
				lw $t8,matrix_h($t4)
				lw $t9,matrix_f($t5)
				mul $t6,$t8,$t9
				add $a1,$a1,$t6
			addi $t3,$t3,1
			blt $t3,$s3,for_4_2
			nop
		addi $t2,$t2,1
		blt $t2,$s2,for_4_1
		nop
		
	li $v0,1
	move $a0,$a1
	syscall
	
	li $v0,11
	li $a0,32
	syscall
	addi $t1,$t1,1
	blt $t1,$s5,for_3_2
	nop
	
li $v0,11
li $a0,10
syscall
addi $t0,$t0,1
blt $t0,$s4,for_3_1
nop


li $v0,10
syscall


  