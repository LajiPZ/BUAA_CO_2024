.text
# 操控$5�?0xffff_ffff,$6�?0x8000_0000
# 测试$0
ori $0,$0,65535
# 若�?�过，测试ori；zero_ext
ori $3,$0,4096 # 高第三位�?1
ori $3,$3,65534 #�?后一�?0，高第三位为1
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
ori $2,$0,1
add $3,$5,$2 # 2137483647 + 1，溢出到-2137483648
add $0,$3,$2 # $0
# sll
ori $3,$0,65535 
sll $3,$3,16
sll $0,$3,1
sll $0,$0,0 #nop，无事发�?
# 通过，测试sw
ori $3,$0,1
ori $2,$0,4
sw $3,0($2)
sw $3,4($2)
sw $3,-4($2)
# lw
# 完成上述测试后，0�?4�?8应存�?1
ori $4,$0,1
ori $2,$0,4
lw $3,4($2)
lw $3,0($2)
lw $3,-4($2)
lw $0,0($2) # $0
# beq
ori $2,1
ori $3,2
ori $4,1
that:
beq $2,$3,that
beq $2,$2,next
ori $2,$0,16
next:
ori $3,$0,16
ori $2,$0,255
ori $3,$0,255
