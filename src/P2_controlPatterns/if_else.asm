# Common control structures

# switch

li $v0,5
syscall
move $s0,$v0

li $v0,5
syscall
move $s1,$v0

if: # > 0 -> true
bgt $s0,$s1,true
nop
blt $s0,$s1,false
nop
# Else
j if_end
nop
# Note: NO ELSE -> DEFAULT TO TRUE!!!
true:
li $v0,1
li $a0,1
syscall
j if_end
nop
false:
li $v0,1
li $a0,0
syscall
j if_end
if_end:
li $v0,10
syscall
