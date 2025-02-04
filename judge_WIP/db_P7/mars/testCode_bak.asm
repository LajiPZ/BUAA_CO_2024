.text
ori $3,$3,65534 #�?后一�?0，高第三位为1，测试是否转�?
# 若�?�过，测试lui
lui $3,65535
lui $0,65535
# 若�?�过，测试减
ori $4,$0,5 #init
ori $2,$0,1
sub $3,$4,$2 #正常减法
ori $2,$0,6
sub $3,$3,$2 #跨到-1
ori $2,$0,1
sub $3,$6,$2 # -2137483648 - 1，溢出到2137483647
sub $0,$3,$1 # $0
# 若�?�过，测试加
ori $4,$0,5 #init
ori $2,$0,1
add $3,$4,$2 #正常+�?
ori $2,$0,1
sub $3,$0,$2 #$3跨到-1
add $3,$3,$2 #-1跨到0
ori $5,$0,0x7fffffff
ori $2,$0,1
add $3,$5,$2 # 2137483647 + 1，溢出到-2137483648
mult $5,$4
mfhi $26
mflo $25
ori $5,$0,0x7fffffff
add $3,$5,$2 # 2137483647 + 1，溢出到-2137483648
mthi $5
# sll
ori $3,$0,65535 
# 通过，测试sw
sw $3,4($2)
sw $3,-4($2)
# lw
# 完成上述测试后，0�?4�?8应存�?4
ori $4,$0,1
ori $2,$0,4
lw $3,4($2)
lw $3,0($2)
lw $3,-4($3) # 暂停
lw $0,0($2) # $0
# beq
ori $2,1
ori $3,2
ori $4,1
that:
beq $2,$3,that
nop

ori $2,$0,16
ori $3,$0,16
ori $7,$0,0
ori $8,$0,4
sw $2,0($7)
sw $3,0($8)
ori $2,$0,65535
ori $3,$0,65534
lw $2,0($7)
lw $3,0($8)
beq $2,$3,next # 暂停两个周期
ori $2,$0,16
ori $3,$0,65535
next:
ori $3,$0,16
ori $2,$0,255
ori $3,$0,255
ori $4,$0,126
ori $5,$0,127
ori $4,$0,127
beq $4,$5,next1 # 暂停�?个周�?
ori $4,$0,0
ori $4,$0,511
ori $5,$0,511
next1:
ori $2,$0,511
ori $3,$0,511

jal test # 测试跳转，以及下方延迟槽，以及jal有关转发是否正确
ori $31,$31,0
ori $3,$0,65535
test:
ori $3,$31,0 # 继续测转�?
ori $10,$0,65535
ori $21,$10,65535



sltu $9,$2,$3
slt $8,$2,$3


ori $2,$0,1
sltu $9,$2,$3
slt $8,$2,$3


ori $2,$0,-1
sltu $9,$2,$3
slt $8,$2,$3



ori $2,$0,0xffffffff
ori $3,$0,0x7fffffff
ori $20,$0,0x0000eeee
ori $30,$0,0x0000dddd

slt $8,$2,$3
sltu $9,$2,$3


mult $2,$3
mfhi $4
mflo $5
multu $2,$3
mfhi $4
mflo $5
div $2,$3
mfhi $4
mflo $5
divu $2,$3
mfhi $4
mflo $5

mult $2,$3
nop
nop
nop
mthi $20
mfhi $4
mflo $5
multu $2,$3
mtlo $30
mfhi $4
mflo $5
div $2,$3
mthi $30
mfhi $4
mflo $5
divu $2,$3
mtlo $20
mfhi $4
mflo $5

ori $2,$0,0xffffffff
ori $3,$0,0x7fffffff
div $2,$3
mthi $2
mtlo $3
mfhi $2
mflo $3
slt $4,$2,$3
sltu $4,$2,$3

ori $2,$0,0xffffffff
ori $3,$0,0x7fffffff
mthi $2
mtlo $3
div $2,$3
mfhi $2
mflo $3
slt $4,$2,$3
sltu $4,$2,$3

ori $2,$0,0xffffffff
ori $3,$0,0x7fffffff
div $2,$3
mfhi $2
mflo $3
slt $4,$2,$3
sltu $4,$2,$3

ori $2,$0,0xffffffff
ori $3,$0,0x7fffffff
divu $2,$3
mfhi $2
mflo $3
slt $4,$2,$3
sltu $4,$2,$3

ori $2,$0,0xffffffff
ori $3,$0,0x7fffffff
multu $2,$3
mfhi $2
mflo $3
slt $4,$2,$3
sltu $4,$2,$3


ori $2,$0,0x12345678
sw $2,0($0)
lw $3,0($0)
lh $3,0($0)
lb $3,0($0)
lh $3,2($0)
lb $3,1($0)
end:
beq $0,$0,end

.ktext 0x4180
ori $5,$0,0x00003000
mfhi $25
mflo $24
ori $2,$0,4
ori $3,$0,8
ori $23,0x00000001
ori $22,0x00007F20
sb $23,0($22)
eret
ori $31,$0,0x00003004

