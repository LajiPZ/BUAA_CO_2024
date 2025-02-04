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
