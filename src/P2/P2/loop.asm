.data 
string: .space 20 # 1 byte per word

.text
# $a0 = n
li $v0,5
syscall
move $a0,$v0
li $t0,0
read:
	li $v0,12
	syscall
	move $t1,$v0
	sb $t1,string($t0)
	addi $t0,$t0,1
bne $t0,$a0,read
nop

li $t0,0
move $t1,$a0

check:
	subi $t1,$t1,1
	lb $t3,string($t0)
	lb $t4,string($t1)
	bne $t3,$t4,nope
	nop
	addi $t0,$t0,1
ble $t0,$t1,check

li $v0,1
li $a0,1
syscall
li $v0,10
syscall
nope:
li $v0,1
li $a0,0
syscall
li $v0,10
syscall