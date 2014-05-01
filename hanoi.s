#################################
#	Apoorv Singh		#
#	  2011028		#
#	 Group - 2		#
#################################

.data
greet:	.asciiz "Please enter the number of disks on pole A\n"
arrow:	.asciiz " to pole "
newline: .asciiz "\n"
comma:	.asciiz " "
moving:	.asciiz "Moving disk "
from: 	.asciiz " from pole "
movsep:	.asciiz	"==> "
separator1:	.asciiz "[[[["
separator2:	.asciiz "]]]]"
a_status:	.asciiz " Pole A's contents: "
b_status:	.asciiz " Pole B's contents: "
c_status:	.asciiz " Pole C's contents: "
stack_begin:    .asciiz "Stack Pointer's address at the beginning: "
show_stack:    .asciiz "{{{{ Stack Pointer's address is now: "
show_stack_b:    .asciiz " }}}}"
stack_end:    .asciiz "Stack Pointer's address after the end of the recursion: "
.text
.globl main
main:
    #The formalities
	la $a0,greet
	li $v0,4
	syscall
	li $v0,5
	syscall
	#Put n into $s0
	move $s0,$v0
	#Put a,b,c into $s1,$s2 and $s3 resp.
	li $s1, 97
	li $s2, 98
	li $s3, 99
    #Now I'll allocate 400 words each for A, B and C's arrays of disk numbers on the stack, and 400 words for recursion
    #Here's how the stack will look like:
    #First 400 words: Reserved for hanoi recursion
    #Next 400 words: Reserved for A's stack
    #Next 400 words: Reserved for B's stack
    #Next 400 words: Reserved for C's stack
	#Address for a's stack (sp - 400)
	move $fp,$sp
	addi $fp,$sp,-400
	move $s4,$fp
	move $s8,$s0
	addi $s8,$s8,1
	li $t0,1
	#Fill the disk numbers inside a's stack (1 to N)
fill:
	addi $s8,$s8,-1
	sw $s8, 0($s4)
	beq $s8,$t0,filled
	addi $s4,$s4,-4
	j fill
	####
filled:
	#Addres for b's stack (sp - 800)
	addi $fp,$sp,-800
	move $s5,$fp
	#Address for c's stack (sp - 1200)
	addi $fp,$sp,-1200
	move $s6,$fp
    #Print the stack pointer's address before recursion begins
    la $a0,stack_begin
    li $v0,4
    syscall
    move $a0,$sp
    li $v0,1
    syscall
    la $a0,newline
    li $v0,4
    syscall
    #Call the recursive function for hanoi
	jal hanoi
    #Print the stack pointer's address after recursion ends
    la $a0,stack_end
    li $v0,4
    syscall
    move $a0,$sp
    li $v0,1
    syscall
    la $a0,newline
    li $v0,4
    syscall
    #Exit
	li $v0,10
	syscall
hanoi:
    #Save some space on the stack
	addi $sp,$sp,-20
	sw $ra, 0($sp)
	sw $s0, -4($sp)     #N
	sw $s1, -8($sp)     #A
	sw $s2, -12($sp)    #B
	sw $s3, -16($sp)    #C
    #Are there any disks left?
	beqz $s0, return
move_the_disks:
    #Load values from stack to prepare for first recursion (a,c,b ordering) -> move a to b using c as an intermediate
	lw $s3, -12($sp)    
	lw $s2, -16($sp)
	lw $s1, -8($sp)
	lw $s0, -4($sp)
    #N=N-1
	addi $s0,$s0,-1
    #Call hanoi(n-1,a,c,b) -> Equivalent to moving n-1 disks from A to B (B acts as an intermediate)
	jal hanoi
	################
	#Print the values and status
	#From value -> $a0
	lw $a0,-8($sp)
	#To Value -> $v1
    #Determine what pole the disk is being moved from and to where
	lw $v1,-16($sp)
	beq $a0,97,from_a
	beq $a0,98,from_b
	#From c
	beq $v1,97,to_a_from_c
	#to_b	
	lw $t0,0($s6)
	addi $s5,$s5,-4 #Make some space on B's stack so that we can push a value
	sw $t0,0($s5)   #Push value to B's stack
	addi $s6,$s6, 4 #Pop the value from C's stack
	j after_moving
#Similary, we do the same thing for other cases (c->a, b->a, b->c, a->c or a->b)
to_a_from_c:	
	lw $t0,0($s6)
	addi $s4,$s4,-4
	sw $t0,0($s4)
	addi $s6,$s6,4
	j after_moving
from_a:
	beq $v1,98,to_b
	#to_c	
	lw $t0, 0($s4)
	addi $s6,$s6,-4
	sw $t0, 0($s6)
	addi $s4,$s4, 4	#Decrement a's stack
	j after_moving
to_b:	
	lw $t0, 0($s4)
	addi $s5,$s5,-4
	sw $t0, 0($s5)
	addi $s4, $s4, 4
	j after_moving
from_b:
	beq $v1,97,to_a_from_b
	#to c	
	lw $t0,0($s5)
	addi $s6,$s6,-4
	sw $t0,0($s6)
	addi $s5,$s5,4
	j after_moving
to_a_from_b:	
	lw $t0,0($s5)
	addi $s4,$s4,-4
	sw $t0,0($s4)
	addi $s5,$s5,4
	j after_moving
#After we are done making changes to each pole's stacks, we'll now print what value is being moved and to where
after_moving:
    #Backup a0's variable (which contains what value is being moved)
	move $t1,$a0
	la $a0,movsep
	li $v0,4
	syscall
	la $a0,moving
	syscall
    #Print the value (disk number)
	move $a0,$t0
	li $v0,1
	syscall
	la $a0,from
	li $v0,4
	syscall
    #Print which pole it is being moved from
	move $a0, $t1
	li $v0,11
	syscall
	la $a0,arrow
	li $v0,4
	syscall
    #Print to where it is being moved (-16($sp) corresponds to C, which is the destination)
	lw $a0,-16($sp)
	li $v0,11
	syscall
	la $a0,newline
	li $v0,4
	syscall
	###############
	#Printing status:
    #I accomplish this by decrementing each pole's stack's pointer and printing each value till I get a <=0 value
    #This way, I can safely print each pole's contents in ascending order
	move $t0,$s4
	move $t2,$s5
	move $t4,$s6
	#Printing a's stack
	la $a0,separator1
	li $v0,4
	syscall
	la $a0,a_status
	syscall
print_a:
	lw $t1, 0($t0)
	ble $t1,$zero,d_print_a
	move $a0,$t1
	li $v0,1
	addi $t0,$t0,4
	syscall
	la $a0,comma
	li $v0,4
	syscall
	j print_a
d_print_a:
	la $a0,b_status
	li $v0,4
	syscall
print_b:
	#Printing b's stack
	lw $t3, 0($t2)
    #Branch if value <= 0 is encountered
	ble $t3,$zero,d_print_b
	move $a0,$t3
	li $v0,1
	syscall
	la $a0,comma
	li $v0,4
	syscall
	addi $t2,$t2,4
	j print_b
d_print_b:
	la $a0,c_status
	li $v0,4
	syscall
print_c:
	#Printing c's stack
	lw $t5, 0($t4)
    #Branch if value <= 0 is encountered
	ble $t5,$zero,done_with_printing
	move $a0,$t5
	li $v0,1
	syscall
	la $a0,comma
	li $v0,4
	syscall
	addi $t4,$t4,4
	j print_c
done_with_printing:
	la $a0,separator2
	li $v0,4
	syscall
	la $a0,newline
	syscall
    la $a0,show_stack
    syscall
    #Printing what the stack pointer points to now
    move $a0,$sp
    li $v0,1
    syscall
    la $a0,show_stack_b
    li $v0,4
    syscall
    la $a0,newline
	syscall
	syscall
	################
    #Prepare saved registers for another recursion by loading values from stack (b,a,c ordering -> move disks from b to c)
	lw $s3, -16($sp)
	lw $s2, -8($sp)
	lw $s1, -12($sp)
	lw $s0, -4($sp)
    #N=N-1
	addi $s0,$s0,-1
    #Call hanoi(n-1,b,a,c): Equivalent to moving n-1 disks from b to c using a as in intermediate
	jal hanoi
return:
	lw $ra, 0($sp)
	addi $sp,$sp,20
	jr $ra
