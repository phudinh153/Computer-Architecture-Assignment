.data
		board1: .asciiz "| "
		space: .asciiz " "
		endl: .asciiz "|\n"
		array: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		X: .asciiz "X"
		O: .asciiz "O"
		input: .asciiz "Player   please pick your move (1-25): "
		invalid: .asciiz "Invalid! Please choose again!\n"
		undo: .asciiz "Undo previous move [0]|No or [1]|Yes: "
		center: .asciiz "Cannot choose central point in the first turn of both players!\n"
		tie: .asciiz " XXXXXX!!!!DRAW!!!!OOOOOO"
		winX: .asciiz "  !!!!PLAYER [X] WINS!!!!"
		winO: .asciiz "  !!!!PLAYER [O] WINS!!!!"
		start: .asciiz "\n-------START GAME!-------\n"
		
.text
main:		
		add $s1, $zero, $zero #count to print
		la $s4, input
		
		add $s6, $zero, $zero #count to check tie and undo
		move $t9, $zero #store to check undo
		add $s3, $zero, $zero #count to check Win
		add $s2, $zero, $zero
		add $s5, $zero, $zero
		move $t1, $zero
		move $t2, $zero
		move $t3, $zero
		li $v0, 4
		la $a0, start
		syscall
reset:	
		la $s2, array
print:			
		lw $t1, ($s2)	
		addi $s1, $s1, 1
		beq $s1, 26, MoveXorO
		li $v0, 4
		la $a0, board1
		syscall
		
		beq $t1, 1, PrintX
		beq $t1, -1, PrintO
		li $v0, 1
		move $a0, $s1
		syscall
		
	checkprint:	
		bgt $s1, 9, loop
		li $v0, 4
		la $a0, space
		syscall
	loop:	
		addi $s2, $s2, 4
		li $v0, 4
		la $a0, space
		syscall
		
		
		rem $t2, $s1, 5
		bne $t2, 0, print
		
		li $v0, 4	#print endl
		la $a0, endl
		syscall	
		
		j print

PrintX:
		li $v0, 4
		la $a0, X
		syscall	
		blt $s1, 10, checkprint
		li $v0, 4
		la $a0, space
		syscall
		j checkprint
PrintO:
		li $v0, 4
		la $a0, O
		syscall	
		blt $s1, 10, checkprint
		li $v0, 4
		la $a0, space
		syscall
		j checkprint

MoveXorO: 			
		beq $s3, 3, WinX
		beq $s3, -3, WinO
		beq $s6, 25, Tie		#check Tie		
		add $s1, $zero, $zero	
		rem $t0, $s6, 2	
        	bne $t0, $zero, MoveO
        	j MoveX		
MoveX:
        	lb $a1, X
        	sb $a1, 7($s4)
        	j Input
MoveO:
        	lb $a1, O
        	sb $a1, 7($s4)
        	j Input
      
Input:		
		li $v0, 4	#print input
        	la $a0, input
        	syscall
        	li $v0, 5	#enter input
        	syscall 
        	move $s5, $v0
        		
		blt $s5, 1, Invalid
		bgt $s5, 25, Invalid
		blt $s6, 2, Center
		j Checkposition
						
Checkposition:		
		la $s2, array
		mul $s5, $s5, 4
		subi $s5, $s5, 4
		add $s2, $s2, $s5
		lw $t1, ($s2)
        	
		bne $t1, 0, Invalid
		bne $t0, $zero, SaveO
        	j SaveX
        
        SaveX:
        	addi $t1, $t1, 1
        	sw $t1, ($s2)
        	addi $s6, $s6, 1
        	bne $s6, 0, Undo
        
        SaveO:
        	addi $t1, $t1, -1
        	sw $t1, ($s2)
        	addi $s6, $s6, 1
        	bne $s6, 0, Undo
   
        Undo:   		
        	li $v0, 4	#print undo
        	la $a0, undo
        	syscall
        	li $v0, 5	#enter [0]|No - [1]|Yes to undo
        	syscall 
        	beq $v0, 1, Checkundo
        	beq $v0, 0, Checkwin		#win check
        	
        	li $v0, 4
        	la $a0, invalid		
        	syscall
        	j Undo	
        Checkundo: 
		addi $s6, $s6, -1
		la $s2, array
		add $s2, $s2, $s5
		move $t1, $zero
		sw $t1, ($s2)	
		j reset
Center: 
		bne $s5, 13, Checkposition	
		li $v0, 4
        	la $a0, center
        	syscall
		j Input
Checkwin:	
		move $t9, $s5		#keep the main check point
		move $t3, $t1		#keep the value of the main check point
		
	checkdiagonalupleft:	
		add $s3, $zero, $t3
		move $s5, $t9
		#special case
		beq $s5, 60, checkdiagonalupright
		beq $s5, 64, checkdiagonalupright
		beq $s5, 80, checkdiagonalupright
		beq $s5, 84, checkdiagonalupright
		
	upleft:	
		addi $s5, $s5, -24
		la $s2, array
		add $s2, $s2, $s5
		lw $t1, ($s2)
		add $s3, $s3, $t1
				
		beq $t1, 0, checkdiagonalupright	
		beq $s3, 2, upleft
		beq $s3, 3, reset
		beq $s3, -2, upleft
		beq $s3, -3, reset
		
	checkdiagonalupright:	
		add $s3, $zero, $t3
		move $s5, $t9
		#special case
		beq $s5, 32, checkdiagonaldownleft
		beq $s5, 52, checkdiagonaldownleft
		beq $s5, 72, checkmidleftright
		beq $s5, 92, checkdiagonaldownleft
		beq $s5, 36, checkdiagonaldownleft
		beq $s5, 56, checkleft
		beq $s5, 76, checkleft
		beq $s5, 92, checkleft
		beq $s5, 96, checkleft
		
	upright:		
		addi $s5, $s5, -16
		la $s2, array
		add $s2, $s2, $s5
		lw $t1, ($s2)
		add $s3, $s3, $t1
	
		beq $t1, 0, checkdiagonaldownleft
		beq $s3, 2, upright
		beq $s3, 3, reset
		beq $s3, -2, upright
		beq $s3, -3, reset
	checkdiagonaldownleft:	
		add $s3, $zero, $t3
		move $s5, $t9
		#special case
		beq $s5, 4, checkdiagonaldownright
		beq $s5, 24, checkdiagonaldownright
		beq $s5, 44, checkdiagonaldownright
		beq $s5, 64, checkmidleftright
		beq $s5, 0, checkdiagonaldownright
		beq $s5, 20, checkdiagonaldownright
		beq $s5, 40, checkdiagonaldownright
		beq $s5, 60, checkright
		beq $s5, 80, checkright
		
	downleft:	
		addi $s5, $s5, 16
		la $s2, array
		add $s2, $s2, $s5
		lw $t1, ($s2)
		add $s3, $s3, $t1
		
		beq $t1, 0, checkdiagonaldownright
		beq $s3, 2, downleft
		beq $s3, 3, reset
		beq $s3, -2, downleft
		beq $s3, -3, reset
		
	checkdiagonaldownright:	
		add $s3, $zero, $t3
		move $s5, $t9
		#special case
		beq $s5, 12, checkleft
		beq $s5, 16, checkleft
		beq $s5, 36, checkleft
		
	downright:		
		addi $s5, $s5, 24
		la $s2, array
		add $s2, $s2, $s5
		lw $t1, ($s2)
		add $s3, $s3, $t1
		
		beq $t1, 0, checkmidleftright
		beq $s3, 2, downright
		beq $s3, 3, reset
		beq $s3, -2, downright
		beq $s3, -3, reset	
		
	checkmidleftright:
		add $s3, $zero, $t3
		move $s5, $t9	
		#special case
		beq $s5, 20, checkright
		beq $s5, 40, checkright
		
	midleftright:	
		addi $s5, $s5, -24
		la $s2, array
		add $s2, $s2, $s5
		lw $t1, ($s2)
		add $s3, $s3, $t1
		
		beq $t1, 0, checkmidrightleft
		addi $s5, $s5, 48
		la $s2, array
		add $s2, $s2, $s5
		lw $t1, ($s2)
		add $s3, $s3, $t1
																			
		beq $s3, 3, reset
		beq $s3, -3, reset	
		
	checkmidrightleft:
		add $s3, $zero, $t3
		move $s5, $t9		
	midrightleft:	
		addi $s5, $s5, -16
		la $s2, array
		add $s2, $s2, $s5
		lw $t1, ($s2)
		add $s3, $s3, $t1

		beq $t1, 0, checkright
		addi $s5, $s5, 32
		la $s2, array
		add $s2, $s2, $s5
		lw $t1, ($s2)
		add $s3, $s3, $t1								
																													
		beq $s3, 3, reset
		beq $s3, -3, reset	
		
	checkright:
		add $s3, $zero, $t3
		move $s5, $t9
		
		Condition1:
		beq $s5, 12, checkmidrow
		beq $s5, 32, checkmidrow
		beq $s5, 52, checkmidrow
		beq $s5, 72, checkmidrow
		beq $s5, 92, checkmidrow
		
		beq $s5, 16, checkleft
		beq $s5, 36, checkleft
		beq $s5, 56, checkleft
		beq $s5, 76, checkleft
		beq $s5, 96, checkleft
	
	right:
		la $s2, array
		addi $s5, $s5, 4
		add $s2, $s2, $s5
		lw $t1, ($s2)
		add $s3, $s3, $t1
	
		beq $t1, 0, checkleft
		beq $s3, 2, right
		beq $s3, 3, reset
		beq $s3, -2, right
		beq $s3, -3, reset
		
	checkleft:	
		add $s3, $zero, $t3
		move $s5, $t9
		Condition2:
		beq $s5, 0, checkup
		beq $s5, 20, checkup
		beq $s5, 40, checkup
		beq $s5, 60, checkup
		beq $s5, 80, checkup
		
		Condition3:
		beq $s5, 4, checkmidrow
		beq $s5, 24, checkmidrow
		beq $s5, 44, checkmidrow
		beq $s5, 64, checkmidrow
		beq $s5, 84, checkmidrow
				
	left:		
		la $s2, array
		addi $s5, $s5, -4
		add $s2, $s2, $s5
		lw $t1, ($s2)
		add $s3, $s3, $t1
		
		beq $t1, 0, checkmidrow
		beq $s3, 2, left
		beq $s3, 3, reset
		beq $s3, -2, left
		beq $s3, -3, reset	
	
	checkmidrow:
		add $s3, $zero, $t3
		move $s5, $t9
		
		Condition4:
		beq $s5, 16, checkup
		beq $s5, 36, checkup
		beq $s5, 56, checkup
		beq $s5, 76, checkup
		beq $s5, 96, checkup
		
		addi $s5, $s5, -4
		la $s2, array
		add $s2, $s2, $s5
		lw $t1, ($s2)
		add $s3, $s3, $t1

		beq $t1, 0, checkup
		addi $s5, $s5, 8
		la $s2, array
		add $s2, $s2, $s5
		lw $t1, ($s2)
		add $s3, $s3, $t1
																			
		beq $s3, 3, reset
		beq $s3, -3, reset												
		
	checkup:
		add $s3, $zero, $t3
		move $s5, $t9
		
		
	up:	
		la $s2, array
		addi $s5, $s5, -20
		add $s2, $s2, $s5
		lw $t1, ($s2)
		add $s3, $s3, $t1
		
		beq $t1, 0, checkdown
		beq $s3, 2, up
		beq $s3, 3, reset
		beq $s3, -2, up
		beq $s3, -3, reset	
		
	checkdown:
		add $s3, $zero, $t3
		move $s5, $t9
		
		
	down:	
		la $s2, array
		addi $s5, $s5, 20
		add $s2, $s2, $s5
		lw $t1, ($s2)
		add $s3, $s3, $t1
		
		beq $t1, 0, checkmidcol	#check diagonal
		beq $s3, 2, down
		beq $s3, 3, reset
		beq $s3, -2, down
		beq $s3, -3, reset	
		
	checkmidcol:
		add $s3, $zero, $t3
		move $s5, $t9
		addi $s5, $s5, -20
		la $s2, array
		add $s2, $s2, $s5
		lw $t1, ($s2)
		add $s3, $s3, $t1
		
		beq $t1, 0, reset
		addi $s5, $s5, 40
		la $s2, array
		add $s2, $s2, $s5
		lw $t1, ($s2)
		add $s3, $s3, $t1				
		beq $s3, 3, reset
		beq $s3, -3, reset														
		j reset																
Invalid:
		li $v0, 4
        	la $a0, invalid
        	syscall
        	j Input
WinX:		
		li $v0, 4
        	la $a0, winX
        	syscall	
        	j exit
WinO:		
		li $v0, 4
        	la $a0, winO
        	syscall
        	j exit
						
Tie:	
		li $v0, 4
        	la $a0, tie
        	syscall															
		j exit																									
exit:			
		li $v0, 10
        	syscall	
		
		
		
					
