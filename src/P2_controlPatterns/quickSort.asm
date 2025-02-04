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

.macro protect # һ�������������
	push($t1)
	push($a1)
	push($a2)
	push($ra)
.end_macro

.macro unprotect # ע��ȥ�����ͱ���˳���Ƿ��ģ�
	pop($ra)
	pop($a2)
	pop($a1)
	pop($t1)
.end_macro

.macro swap(%a_label,%b_label) # ע�⣬С�������õļĴ�����.text�����ã�����̫�鷳���������������Բ����õģ��������������
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
reading: # ������forѭ��
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
# Using $a1,$a2 as argument   # д����ǰ���涨�ñ���Ϊ�����ļĴ���
# �����з���ֵ������������ǰ�滮����ֵ��Ҫ�õ��ļĴ���
li $a1,0
subi $a2,$s0,1 # ���������һ��Ҫ���Ǳ�������

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
		lw $t3,sorting($a1) #k[left] # ������k[i+1]֮�࣬��������ʱ�޸�i��Ӧ�Ĵ�����ֵ����һ������ڸĻ�ȥ
		srl $a1,$a1,2
		bge $t2,$t3,no_swap 
		nop
			addi $t1,$t1,1 # С��©��k[i+1]��i+1
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
	
quickSort_end: # �������ñ���Ϊ��;������׼��
jr $ra
nop



# ���������for

# ���ڵڶ���õ�ѭ������j��ÿһ��iѭ�����Ҫ��0��
# ���õ�ʱ�������forǰ���i���Ͻ������ĳ�ʼ��������ֵ��0������

# ����if_elseif_else���������if_end����д��ÿһ��ε���ת��ϵ������͵��˳��ִ�У�

# break����ѭ����continue��������ѭ��ĩβ��ִ��i++����