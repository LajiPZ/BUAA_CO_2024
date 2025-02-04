.data 
sorting: .space 64

.macro push(%reg)
	subi $sp,$sp,4
	sw %reg,0($sp)
.end_macro

.macro pop(%reg)
	lw %reg,0($sp)
	addi $sp,$sp,4
.end_macro

.macro protect # 一键保护，蛤蛤蛤蛤
	push($t1)
	push($a1)
	push($a2)
	push($ra)
.end_macro

.macro unprotect # 注意去保护和保护顺序是反的！
	pop($ra)
	pop($a2)
	pop($a1)
	pop($t1)
.end_macro

.macro swap(%a_label,%b_label) # 注意，小心里面用的寄存器在.text里有用；保护太麻烦，索性拿两个绝对不会用的，给这个操作保留
	sll %a_label,%a_label,2
	lw $t8,sorting(%a_label)
	sll %b_label,%b_label,2
	lw $t9,sorting(%b_label)
	
	sw $t8,sorting(%b_label)
	sw $t9,sorting(%a_label)
	srl %a_label,%a_label,2
	srl %b_label,%b_label,2
.end_macro

.text
li $v0,5
syscall
move $s0,$v0

li $t0,0
reading: # 常见的for循环
	li $v0,5
	syscall
	sll $t0,$t0,2
	sw $v0,sorting($t0)
	srl $t0,$t0,2
addi $t0,$t0,1
blt $t0,$s0,reading
nop
# $t0 released
# Start
# Using $a1,$a2 as argument   # 写函数前，规定好保留为参数的寄存器
# 对于有返回值函数，建议提前规划返回值需要用到的寄存器
li $a1,0
subi $a2,$s0,1 # 算术结果不一定要覆盖被操作数

jal quickSort
nop

li $v0,10
syscall

quickSort:
# $t0 = i; $t1 = last
bge $a1,$a2,quickSort_end # if l < R
	move $t1,$a1
	addi $t0,$a1,1
	for:
		sll $t0,$t0,2 
		lw $t2,sorting($t0) #k[i]
		srl $t0,$t0,2
		sll $a1,$a1,2
		lw $t3,sorting($a1) #k[left] # 类似于k[i+1]之类，可以先临时修改i对应寄存器的值，这一步完后在改回去
		srl $a1,$a1,2
		bge $t2,$t3,no_swap 
		nop
			addi $t1,$t1,1 # 小心漏掉k[i+1]中i+1
			swap($t1,$t0)
		no_swap:
	addi $t0,$t0,1
	ble $t0,$a2,for
	
	swap($a1,$t1)
	
	# Protect: t1,a1,a2,ra
	protect
	move $a1,$a1
	subi $a2,$t1,1
	jal quickSort
	nop
	unprotect
	
	protect
	addi $a1,$t1,1
	move $a2,$a2
	jal quickSort
	nop
	unprotect
	
quickSort_end: # 函数调用必须为中途返回做准备
jr $ra
nop



# 碎碎念：两层for

# 对于第二层得的循环变量j，每一次i循环完后都要置0！
# 调用的时候，最好在for前完成i，上界条件的初始化，哪怕值是0！！！

# 对于if_elseif_else，建议给出if_end，并写出每一层次的跳转关系，切勿偷懒顺序执行！

# break跳出循环，continue则是跳到循环末尾，执行i++处！