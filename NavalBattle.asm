.data
	welcome: .asciiz "Welcome to the Naval Battle, let´s start the game! \n"
	playerMode: .asciiz "Press 1 if you wanna play alone\nPress 2 if you wanna play with me (:\n"
	
	singlePlayerMode: .asciiz "Welcome to the SinglePlayer MODE\n"
	MultiplayerPlayerMode: .asciiz "Welcome to the MultiplayerPlayer MODE\n"
	
	line: .asciiz "\nDigite a linha: "
	column: .asciiz "\nDigite a coluna: "
	space: .asciiz " "
	lineSpace: .asciiz "\n "
	
	myArrayLine: 
		.align 2
		.space 40
		
	myArrayColumn: 
		.align 2
		.space 40	

.text
	# Boas Vindas Message
	li $v0, 4
	la $a0, welcome
	syscall
	
	# Choose the player Mode
	choosePlayer:
		li $v0, 4
		la $a0, playerMode
		syscall
		
		li $v0, 5
		move $s0, $a0
		syscall
		
	# check the option placed by the player
	verifyPlayer:
		beq $s0, 1, playAlone
		beq $s0, 2, playMultiplayer
		
		playAlone:
			li $v0, 4
			la $a0, singlePlayerMode
			syscall
			j print_row_and_column
		playMultiplayer:
			li $v0, 4
			la $a0, MultiplayerPlayerMode
			syscall
			j print_row_and_column

	# fill the array with a sequence number of rows
	li $t0, 0  # initialize a counter to 0
	li $t1, 1  
	
	
	# Building the grid table
	print_row_and_column:
		beq $t0, 40, exit   # if the counter equals 40, go to the exit
		sw $t1, myArrayLine($t0)
		add $t1, $t1, 1
		add $t0, $t0, 4
		j print_row_and_column
		
	exit:
		move $t0, $zero
		print:
			beq $t0, 40, outPrint
	
			li $v0, 1
			lw $a0, myArrayLine($t0)
			syscall
			
			li $v0, 4
			la $a0, space
			syscall
			
			
			add $t0,$t0, 4
			
			j print
			
			syscall
		
		outPrint:
			
			
			
		
	
	