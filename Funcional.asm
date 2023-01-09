.data
	frameBuffer: 	.space 	0x80000		#512 wide x 256 high pixels
	
	#Cores
	black:	  .word 0x000000
	white:	  .word 0xFFFFFF
	robo:   .word 0xFF0000
	rastro: .word 0x202020
	end: .word 0x9C9C9C
	
	linha:                 .asciiz  "   |   |   |   |   |   |   |   |   |   |  \n"  # index 1, 5, 9 sao modificados 
    	separador:             .asciiz  "---+---+---+---+---+---+---+---+---+---+---\n"
	player1:               .byte  ' '
	player2:               .byte  'o'
    	vazio:                 .byte  ' '
    
	welcome: .asciiz "Welcome to the Naval Battle, letÂ´s start the game! \n"
	playerMode: .asciiz "Press 1 if you wanna play alone\nPress 2 if you wanna play with me (:\n"
	singlePlayerM2ode: .asciiz "Welcome to the SinglePlayer M2ODE\n"
	MultiplayerPlayerMode: .asciiz "Welcome to the MultiplayerPlayer MODE\n"
	selectSpaceMessage: .asciiz "\nSelecione os lugares a sem explodidos\n"
	
	acertouMessage: .asciiz "Acertou\n"
	errouMessage: .asciiz "Errou\n"
	
	winnerMessage: .asciiz "Parabens, voce ganhou!Voce fez: "
	loserMessage: .asciiz "Voce perdeu, jogue novamente! Voce fez: "
	score: .asciiz " pontos"
	
	line: .asciiz "\nDigite a linha: "
	column: .asciiz "\nDigite a coluna: "
	space: .asciiz " "
	lineSpace: .asciiz "\n"
	
	atacarLinhaMessage: .asciiz "\nDigite a linha a ser atacada: "
	
	atacarColumnMessage: .asciiz "\nDigite a coluna a ser atacada: "
	
	myArrayLine:
		.align 2
		.word 0:100
		
	myArrayColumn:
		.align 2
		.word 0:100
		
	             .align  4 # alinhamento de memï¿½ria
	m1:          .asciiz "\nDigite um numero inteiro:\t"
	m2:          .asciiz "\nM2[linha][coluna]:\t"
	M:           .word 0:100    # inicializa todos os elementos da matriz com zero

		
	.align 4 # alinhamento de memï¿½ria
         m3:         .asciiz "Digite o numero da linha: "
         m4:         .asciiz "Digite o numero da coluna: "
         m5:         .asciiz "\nColocar Submarino\n"
         m6:         .asciiz "\nColocar Destroyer\n"
         m7:         .asciiz "\nColocar Porta Avioes\n"
         m8:         .asciiz "\nColocar Encouraçado\n"
         M2: 	     .word 0:100    # inicializa todos os elementos da matriz com zero
        tamanho:     .word 100    # tamanho da matriz   
        
        m9:	     .asciiz "\nVez do Jogador \t"
    
.text
	set_tela: # Inicia todos os valores para a tela
		addi $t0, $zero, 65536 # 65536 = (512*512)/4 pixels
		add $t1, $t0, $zero # Adicionar a distribuição de pixels ao endereco $t1
		lui $t1, 0x1004 # Endereco base da tela
		j go_to_main
		
	set_cores: # salva as cores nos registradores
		lw $s4, white
		lw $s5, robo
		lw $s3, end
		jr $ra
		
	welcome_screen:
		# Boas Vindas M2essage
		li $v0, 4
		la $a0, welcome
		syscall
	
	choosePlayer:
		# Choose the player M2ode
		li $v0, 4
		la $a0, playerMode
		syscall
		
		li $v0, 5
		move $s0, $a0
		syscall
		
		verifyPlayer:
			beq $s0, 1, playAlone
		
			playAlone:
				li $v0, 4
				la $a0, singlePlayerM2ode
				syscall
				j playAloneStart
				
				
	playAloneStart:
        # Função singlePlayerFill
        # Função matriz_imprime
        # Função imprime_matriz
        singlePlayerFill:
			#barcos: id1:(submarino) qt3,
			# id2:(destroyer) qt2, id3:(porta aviÃµes) qt2, id4: (encouraÃ§ado) qt1
       			 # setando a pilha de chamada de procedimentos
        		subu     $sp, $sp, 32     # o frame de pilha tenm 32 bytes
       			sw     $ra, 20($sp)     # salva o endereÃ§o de retorno
        		sw     $fp, 16($sp)     # salva o ponteiro do frame
        		addiu     $sp, $sp, 28      # prepara o ponteiro do frame            
            		
            		move     $t7, $zero   # $s0: vez do jogador 0   
        		li     $v0, 4        
        		la     $a0, m9  
        		syscall 
        		li     $v0, 1        
        		move     $a0, $t7
        		syscall 
        		
            		jal matriz_preenche
            		jal print_jogo
            		jal matriz_imprime
            		
            		add     $t7,$t7, 1   # $s0: vez do jogador 0   
        		li     $v0, 4        
        		la     $a0, m9  
        		syscall 
        		li     $v0, 1        
        		move     $a0, $t7
        		syscall
        		
        		jal matriz_preenche
            		jal print_jogo
            		jal matriz_imprime
            		
            		jal atacar 
            		jal verificar
           
            		# re-setando a pilha de chamada de procedimentos
        		lw     $ra, 20($sp)       # restaura o endereÃ§o
        		lw     $fp, 16($sp)       # restaura o frame pointer
        		addiu     $sp, $sp, 32       # remove do frame        
        		j FIM   
			
			matriz_preenche:
				# configuraÃƒÂ§ÃƒÂµes da pilha
				subu  $sp, $sp, 32   # reserva o espaÃƒÂ§o do frame ($sp)    
				sw    $ra, 20($sp)   # salva o endereÃƒÂ§o de retorno ($ra)    
				sw    $fp, 16($sp)   # salva o frame pointer ($fp)    
				addiu $fp, $sp, 28   # prepara o frame pointer    
				sw    $a0, 0($fp)    # salva o argumento ($a0)    
		
				li       $t0, 10       # $t0: nÃƒÂºmero de linhas
				li       $t1, 10       # $t1: nÃƒÂºmero de colunas
				move     $s0, $zero   # $s0: contador da linha
				move     $s1, $zero   # $s1: contador da coluna
				move     $t2, $zero   # $t2: valor a ser lido/armazenado
				move	 $s3, $zero   # $s3: numero de chamadas do loop 
					
			popula_matriz:            
				# Cada iteraÃƒÂ§ÃƒÂ£o de loop armazenarÃƒÂ¡ o valor de $t1 incrementado no prÃƒÂ³ximo elemento da matriz
				# O deslocamento ÃƒÂ© calculado a cada iteraÃƒÂ§ÃƒÂ£o: deslocamento = 4 * (linha * nÃƒÂºmero de colunas + coluna)
				
				#SUBM2ARINO
				li     $v0, 4        
				la     $a0, m5   
				syscall 
				# incrementa o contador
				addi     $t2, $t2, 1 
				# solicita que o usuÃƒÂ¡rio digite um nÃƒÂºmero da linha
				li     $v0, 4        
				la     $a0, m3    
				syscall
				li     $v0, 5        
				syscall            
				move     $s0, $v0
				# solicita que o usuÃƒÂ¡rio digite um nÃƒÂºmero da coluna
				li     $v0, 4        
				la     $a0, m4       
				syscall                        
				li     $v0, 5
				syscall            
				move     $s1, $v0
					
				# calcula o endereÃƒÂ§o correto do array
				mult     $s0, $t1    # $s2 = linha * numero de colunas 
				mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
				add      $s2, $s2, $s1  # $s2 += contador de coluna
				sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte       
				# armazena o valor digitado pelo usuÃƒÂ¡rio
				beq $t7, $zero ELSE
        			sw    $t2, M2($s2)
        			j EndIf
			ELSE:	sw    $t2, M($s2)
			EndIf:
				
				#SUBM2ARINO 2
				li     $v0, 4        
				la     $a0, m5   
				syscall 
				# solicita que o usuÃƒÂ¡rio digite um nÃƒÂºmero da linha
				li     $v0, 4        
				la     $a0, m3    
				syscall                        
				li     $v0, 5        
				syscall            
				move     $s0, $v0
				# solicita que o usuÃƒÂ¡rio digite um nÃƒÂºmero da coluna
				li     $v0, 4        
				la     $a0, m4       
				syscall                        
				li     $v0, 5
				syscall            
				move     $s1, $v0
					
				# calcula o endereÃƒÂ§o correto do array
				mult     $s0, $t1    # $s2 = linha * numero de colunas 
				mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
				add      $s2, $s2, $s1  # $s2 += contador de coluna
				sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte       
				# armazena o valor digitado pelo usuÃƒÂ¡rio
				beq $t7, $zero ELSE2
        			sw    $t2, M2($s2)
        			j EndIf2
			ELSE2:	sw    $t2, M($s2)
			EndIf2:
				
				#SUBM2ARINO 3
				li     $v0, 4        
				la     $a0, m5  
				syscall 
				# solicita que o usuÃƒÂ¡rio digite um nÃƒÂºmero da linha
				li     $v0, 4        
				la     $a0, m3    
				syscall                        
				li     $v0, 5        
				syscall            
				move     $s0, $v0
				# solicita que o usuÃƒÂ¡rio digite um nÃƒÂºmero da coluna
				li     $v0, 4        
				la     $a0, m4       
				syscall                        
				li     $v0, 5
				syscall            
				move     $s1, $v0
					
				# calcula o endereÃƒÂ§o correto do array
				mult     $s0, $t1    # $s2 = linha * numero de colunas 
				mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
				add      $s2, $s2, $s1  # $s2 += contador de coluna
				sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte       
				# armazena o valor digitado pelo usuÃƒÂ¡rio
				beq $t7, $zero ELSE3
        			sw    $t2, M2($s2)
        			j EndIf3
			ELSE3:	sw    $t2, M($s2)
			EndIf3:
				
				#DESTROYER 1
				li     $v0, 4        
				la     $a0, m6
				syscall 
				# incrementa o contador
				addi     $t2, $t2, 1 
				# solicita que o usuÃƒÂ¡rio digite um nÃƒÂºmero da linha
				li     $v0, 4        
				la     $a0, m3    
				syscall                        
				li     $v0, 5        
				syscall            
				move     $s0, $v0
				# solicita que o usuÃƒÂ¡rio digite um nÃƒÂºmero da coluna
				li     $v0, 4        
				la     $a0, m4       
				syscall                        
				li     $v0, 5
				syscall            
				move     $s1, $v0
					
				# calcula o endereÃƒÂ§o correto do array
				mult     $s0, $t1    # $s2 = linha * numero de colunas 
				mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
				add      $s2, $s2, $s1  # $s2 += contador de coluna
				sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte       
				# armazena o valor digitado pelo usuÃƒÂ¡rio
				beq $t7, $zero ELSE4
        			sw    $t2, M2($s2)
        			j EndIf4
			ELSE4:	sw    $t2, M($s2)
			EndIf4:
				
				#adiciona uma coluna
				addi     $s1, $s1, 1
				# calcula o endereÃƒÂ§o correto do array
				mult     $s0, $t1    # $s2 = linha * numero de colunas 
				mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
				add      $s2, $s2, $s1  # $s2 += contador de coluna
				sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte 
				# armazena o valor digitado pelo usuÃƒÂ¡rio
				beq $t7, $zero ELSE5
        			sw    $t2, M2($s2)
        			j EndIf5
			ELSE5:	sw    $t2, M($s2)
			EndIf5:
				
				#DESTROYER 2
				li     $v0, 4        
				la     $a0, m6
				syscall 
				# solicita que o usuÃƒÂ¡rio digite um nÃƒÂºmero da linha
				li     $v0, 4        
				la     $a0, m3    
				syscall                        
				li     $v0, 5        
				syscall            
				move     $s0, $v0
				# solicita que o usuÃƒÂ¡rio digite um nÃƒÂºmero da coluna
				li     $v0, 4        
				la     $a0, m4       
				syscall                        
				li     $v0, 5
				syscall            
				move     $s1, $v0
					
				# calcula o endereÃƒÂ§o correto do array
				mult     $s0, $t1    # $s2 = linha * numero de colunas 
				mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
				add      $s2, $s2, $s1  # $s2 += contador de coluna
				sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte       
				# armazena o valor digitado pelo usuÃƒÂ¡rio
				beq $t7, $zero ELSE6
        			sw    $t2, M2($s2)
        			j EndIf6
			ELSE6:	sw    $t2, M($s2)
			EndIf6:
				
				#adiciona uma linha
				addi     $s0, $s0, 1
				# calcula o endereÃƒÂ§o correto do array
				mult     $s0, $t1    # $s2 = linha * numero de colunas 
				mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
				add      $s2, $s2, $s1  # $s2 += contador de coluna
				sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte 
				# armazena o valor digitado pelo usuÃƒÂ¡rio
				beq $t7, $zero ELSE7
        			sw    $t2, M2($s2)
        			j EndIf7
			ELSE7:	sw    $t2, M($s2)
			EndIf7:
				
				#PORTA-AVIÃƒâ€¢ES 1
				li     $v0, 4        
				la     $a0, m7
				syscall 
				# incrementa o contador
				addi     $t2, $t2, 1 
				# solicita que o usuÃƒÂ¡rio digite um nÃƒÂºmero da linha
				li     $v0, 4        
				la     $a0, m3    
				syscall                        
				li     $v0, 5        
				syscall            
				move     $s0, $v0
				# solicita que o usuÃƒÂ¡rio digite um nÃƒÂºmero da coluna
				li     $v0, 4        
				la     $a0, m4       
				syscall                        
				li     $v0, 5
				syscall            
				move     $s1, $v0
					
				# calcula o endereÃƒÂ§o correto do array
				mult     $s0, $t1    # $s2 = linha * numero de colunas 
				mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
				add      $s2, $s2, $s1  # $s2 += contador de coluna
				sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte       
				# armazena o valor digitado pelo usuÃƒÂ¡rio
				beq $t7, $zero ELSE8
        			sw    $t2, M2($s2)
        			j EndIf8
			ELSE8:	sw    $t2, M($s2)
			EndIf8:
				
				#adiciona uma coluna
				addi     $s1, $s1, 1
				# calcula o endereÃƒÂ§o correto do array
				mult     $s0, $t1    # $s2 = linha * numero de colunas 
				mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
				add      $s2, $s2, $s1  # $s2 += contador de coluna
				sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte 
				# armazena o valor digitado pelo usuÃƒÂ¡rio
				beq $t7, $zero ELSE9
        			sw    $t2, M2($s2)
        			j EndIf9
			ELSE9:	sw    $t2, M($s2)
			EndIf9:
				#adiciona uma coluna
				addi     $s1, $s1, 1
				# calcula o endereÃƒÂ§o correto do array
				mult     $s0, $t1    # $s2 = linha * numero de colunas 
				mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
				add      $s2, $s2, $s1  # $s2 += contador de coluna
				sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte 
				# armazena o valor digitado pelo usuÃƒÂ¡rio
				beq $t7, $zero ELSE10
        			sw    $t2, M2($s2)
        			j EndIf10
			ELSE10:	sw    $t2, M($s2)
			EndIf10:
				
				#PORTA-AVIÃƒâ€¢ES 2
				li     $v0, 4        
				la     $a0, m7
				syscall 
				# solicita que o usuÃƒÂ¡rio digite um nÃƒÂºmero da linha
				li     $v0, 4        
				la     $a0, m3    
				syscall                        
				li     $v0, 5        
				syscall            
				move     $s0, $v0
				# solicita que o usuÃƒÂ¡rio digite um nÃƒÂºmero da coluna
				li     $v0, 4        
				la     $a0, m4       
				syscall                        
				li     $v0, 5
				syscall            
				move     $s1, $v0
					
				# calcula o endereÃƒÂ§o correto do array
				mult     $s0, $t1    # $s2 = linha * numero de colunas 
				mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
				add      $s2, $s2, $s1  # $s2 += contador de coluna
				sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte       
				# armazena o valor digitado pelo usuÃƒÂ¡rio
				beq $t7, $zero ELSE11
        			sw    $t2, M2($s2)
        			j EndIf11
			ELSE11:	sw    $t2, M($s2)
			EndIf11:
				
				#adiciona uma linha
				addi     $s0, $s0, 1
				# calcula o endereÃƒÂ§o correto do array
				mult     $s0, $t1    # $s2 = linha * numero de colunas 
				mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
				add      $s2, $s2, $s1  # $s2 += contador de coluna
				sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte 
				# armazena o valor digitado pelo usuÃƒÂ¡rio
				beq $t7, $zero ELSE12
        			sw    $t2, M2($s2)
        			j EndIf12
			ELSE12:	sw    $t2, M($s2)
			EndIf12:
				#adiciona uma linha
				addi     $s0, $s0, 1
				# calcula o endereÃƒÂ§o correto do array
				mult     $s0, $t1    # $s2 = linha * numero de colunas 
				mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
				add      $s2, $s2, $s1  # $s2 += contador de coluna
				sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte 
				# armazena o valor digitado pelo usuÃƒÂ¡rio
				beq $t7, $zero ELSE13
        			sw    $t2, M2($s2)
        			j EndIf13
			ELSE13:	sw    $t2, M($s2)
			EndIf13:
				
				#ENCOURAÃƒâ€¡ADO
				li     $v0, 4        
				la     $a0, m8
				syscall 
				# incrementa o contador
				addi     $t2, $t2, 1 
				# solicita que o usuÃƒÂ¡rio digite um nÃƒÂºmero da linha
				li     $v0, 4        
				la     $a0, m3    
				syscall                        
				li     $v0, 5        
				syscall            
				move     $s0, $v0
				# solicita que o usuÃƒÂ¡rio digite um nÃƒÂºmero da coluna
				li     $v0, 4        
				la     $a0, m4       
				syscall                        
				li     $v0, 5
				syscall            
				move     $s1, $v0
					
				# calcula o endereÃƒÂ§o correto do array
				mult     $s0, $t1    # $s2 = linha * numero de colunas 
				mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
				add      $s2, $s2, $s1  # $s2 += contador de coluna
				sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte       
				# armazena o valor digitado pelo usuÃƒÂ¡rio
				beq $t7, $zero ELSE14
        			sw    $t2, M2($s2)
        			j EndIf14
			ELSE14:	sw    $t2, M($s2)
			EndIf14:
				
				#adiciona uma coluna
				addi     $s1, $s1, 1
				# calcula o endereÃƒÂ§o correto do array
				mult     $s0, $t1    # $s2 = linha * numero de colunas 
				mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
				add      $s2, $s2, $s1  # $s2 += contador de coluna
				sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte 
				# armazena o valor digitado pelo usuÃƒÂ¡rio
				beq $t7, $zero ELSE15
        			sw    $t2, M2($s2)
        			j EndIf15
			ELSE15:	sw    $t2, M($s2)
			EndIf15:
				#adiciona uma coluna
				addi     $s1, $s1, 1
				# calcula o endereÃƒÂ§o correto do array
				mult     $s0, $t1    # $s2 = linha * numero de colunas 
				mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
				add      $s2, $s2, $s1  # $s2 += contador de coluna
				sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte 
				# armazena o valor digitado pelo usuÃƒÂ¡rio
				beq $t7, $zero ELSE16
        			sw    $t2, M2($s2)
        			j EndIf16
			ELSE16:	sw    $t2, M($s2)
			EndIf16:
				#adiciona uma coluna
				addi     $s1, $s1, 1
				# calcula o endereÃƒÂ§o correto do array
				mult     $s0, $t1    # $s2 = linha * numero de colunas 
				mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
				add      $s2, $s2, $s1  # $s2 += contador de coluna
				sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte 
				# armazena o valor digitado pelo usuÃƒÂ¡rio
				beq $t7, $zero ELSE17
        			sw    $t2, M2($s2)
        			j EndIf17
			ELSE17:	sw    $t2, M($s2)
			EndIf17:
				
				# configuraÃƒÂ§ÃƒÂµes do procedimento    
				add     $v0, $s1, $zero # retorna para quem chamou    
				jr     $ra
    print_jogo:
    
    	beq $t7, $zero ELSE22
        	la $s2, M2 # i  = *array
        	j EndIf22
	ELSE22:	la $s2, M # i  = *array
	EndIf22:
	
        la $s0, linha # s0 = *linha
        li $s1, 1     # s1 = index
    desenho:
        lw   $t1, ($s2)         # t1 = array[i]
        bltz $t1, desenha_vazio # vazio     if t1 <  0
        bgtz $t1, desenha_o     # desenha_o if t1 >  0
        bgez $t1, desenha_x     # desenha_x if t1 >= 0
    desenha_o:
        lb  $t2, player2  # caracter = 'o'
        j next
    desenha_x:
        lb  $t2, player1  # caracter = 'x'
        j next
    desenha_vazio:
        lb  $t2, vazio    # caracter = ' '
        j next
    next:
        add $t1, $s0, $s1          # t1 = *linha[index]
        sb  $t2, ($t1)             # linha[index] = caracter
        addi $s2, $s2, 4           # i++
        addi $s1, $s1, 4           # index += 4
        li   $t1, 41               # t1 = 13 (index 13 q nao existe em linha)
        beq  $t1, $s1, print_linha # reset linha if s1 == 13 
        j desenho
    print_linha:
        la   $a0, linha                    # a0 = *linha
        li   $v0, 4                        # print
        syscall                            # string
        li   $s1, 1                        # index = 1 
        li   $t2, 400                      # array.length
        
        beq $t7, $zero ELSE23
        	la   $t3, M2                    # t3  = *array
        	j EndIf23
	ELSE23:	la   $t3, M                    # t3  = *array
	EndIf23:
        
        
        add  $t2, $t2, $t3                 # endereco array + 36 (9 words)
        beq  $s2, $t2, exit_print_desenho  # exit_print_desenho if i == fim do array
        la   $a0, separador                # a0 = *separador
        li   $v0, 4                        # print
        syscall                            # string
        j desenho
    exit_print_desenho:
        jr $ra		
		matriz_imprime:
				# configuraÃƒÂ§ÃƒÂµes da pilha
				subu  $sp, $sp, 32   # reserva o espaÃƒÂ§o do frame ($sp)    
				sw    $ra, 20($sp)   # salva o endereÃƒÂ§o de retorno ($ra)    
				sw    $fp, 16($sp)   # salva o frame pointer ($fp)    
				addiu $fp, $sp, 28   # prepara o frame pointer    
				sw    $a0, 0($fp)    # salva o argumento ($a0)    
		
				li       $t0, 10       # $t0: nÃƒÂºmero de linhas
				li       $t1, 10       # $t1: nÃƒÂºmero de colunas
				move     $s0, $zero   # $s0: contador da linha
				move     $s1, $zero   # $s1: contador da coluna
				move     $t2, $zero   # $t2: valor a ser lido/armazenado
				
		        
		     		imprime_matriz:    
					# calcula o endereço correto do array
					mult     $s0, $t1    # $s2 = linha * numero de colunas 
					mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
					add      $s2, $s2, $s1  # $s2 += contador de coluna
					sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte    
			
								# obtem o valor do elemento armazenado
					beq $t7, $zero ELSE18
        				lw    $t2, M2($s2)
        				j EndIf18
				ELSE18:	lw    $t2, M($s2)
				EndIf18:       
			
										# imprime no console o valor do elemento da matriz
					li     $v0, 4   
					la     $a0, m2
					syscall     
					li     $v0, 1    
					move     $a0, $t2
					syscall 
					
										# incrementa o contador
					addi     $t2, $t2, 1 
					addi     $s1, $s1, 1            	# increment column counter
					bne      $s1, $t1, imprime_matriz       # not at end of row so loop back
					move     $s1, $zero             	# reset column counter
					addi     $s0, $s0, 1            	# increment row counter
					bne      $s0, $t0, imprime_matriz       # not at end of matrix so loop back
					jr $ra
				
										# configuraÃƒÂ§ÃƒÂµes do procedimento    
					add     $v0, $s1, $zero 		# retorna para quem chamou    
					jr $ra
		
		atacar:
			beq $t7, $zero ELSE21
        		move $t7, $zero
        		j EndIf21
		ELSE21:	add    $t7, $t7, 1
		EndIf21:
			li     $v0, 4        
        		la     $a0, m9  
        		syscall 
        		li     $v0, 1        
        		move     $a0, $t7
        		syscall 
        		
			li $v0, 4
			la $a0, selectSpaceMessage
			syscall
			
			# solicita que o usuÃƒÂ¡rio digite um nÃƒÂºmero da linha
			li     $v0, 4        
			la     $a0, atacarLinhaMessage    
			syscall
			li     $v0, 5        
			syscall            
			move     $s0, $v0
			
			# solicita que o usuÃƒÂ¡rio digite um nÃƒÂºmero da coluna
			li     $v0, 4        
			la     $a0, atacarColumnMessage       
			syscall                        
			li     $v0, 5
			syscall            
			move     $s1, $v0	
			
			verificar:   
					# calcula o endereço correto do array
					mult     $s0, $t1    # $s2 = linha * numero de colunas 
					mflo     $s2            # move o resultado da multiplicaÃƒÂ§ÃƒÂ£o do registrador lo para $s2
					add      $s2, $s2, $s1  # $s2 += contador de coluna
					sll      $s2, $s2, 2    # $s2 *= 4 (deslocamento 2 bits para a esquerda) para deslocamento de byte    
			
								# obtem o valor do elemento armazenado
					beq $t7, $zero ELSE19
        				lw    $t2, M($s2)
        				j EndIf19
				ELSE19:	lw    $t2, M2($s2)
				EndIf19:
					
					
					move $t9, $t2 # Current Value of the array position
					
					# verifica se acertou ou nao um barco
					beq $t9, $zero, errou
					bgt $t9, $zero, acertou
					
					
					
						
				acertou:
					li $v0, 4
					la $a0, acertouMessage
					syscall
					
					sub $t9, $t9, 1
					
					beq $t7, $zero ELSE20
        				sw $t9, M($s2)
        				j EndIf20
				ELSE20:	sw $t9, M2($s2)
				EndIf20:
					
					addi $t2, $t2, 4
					addi $s6, $s6, 1
					addi $s7, $s7, 1
					bgt $s6, 25, FIM
					j atacar
					
				errou:
					li $v0, 4
					la $a0, errouMessage
					syscall
					
					addi $t2, $t2, 4
					addi $s6, $s6, 1
					bgt $s6, 25, FIM
					j atacar
		FIM: 
			bgt $s7, 10, winner
			blt $s7, 10, loser
			
			winner:
				li $v0, 4
				la $a0, winnerMessage
				syscall
				
				li $v0, 1
				move $a0, $s7
				syscall
				
				li $v0, 4
				la $a0, score
				syscall
				
				
				li $v0, 10
				syscall
				
			loser:
				li $v0, 4
				la $a0, loserMessage
				syscall
				
				li $v0, 1
				move $a0, $s7
				syscall
				
				li $v0, 4
				la $a0, score
				syscall
				
				li $v0, 10
				syscall
		
    go_to_main:
		jal welcome_screen
		jal choosePlayer
