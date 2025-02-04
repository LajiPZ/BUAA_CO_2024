.text
li $v0,5
syscall

##Initialize
move $t0,$v0
li $s0,4
li $s1,100
li $s2,400

#Calculation
div $t0,$s2
mfhi $t1
beqz $t1, yes #divided by 400
#nop
div $t0,$s0
mfhi $t1
beqz $t1, further
#nop


no:
li $a0,0
li $v0,1
syscall
j end
#nop


yes:
li $a0,1
li $v0,1
syscall
j end
#nop


further:
div $t0,$s1
mfhi $t1
beqz $t1,no
#nop
j yes
#nop


end:
li $v0,10
syscall