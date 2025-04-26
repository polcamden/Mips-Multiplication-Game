# Term Project CS/SE 2340
# Author: Camden Ernst
# Date: 4/17/2025

.include "SysCalls.asm"
#.include "Board.asm"
#.include "Player.asm"
#.include "Computer.asm"

.data
	promptIntro: .asciiz "-+-+-+- Welcome to multiplication game -+-+-+-\n"
	promptNames: .asciiz " vs. "
	promptContinue: .asciiz "Enter to start\n"
	
	promptTurn: .asciiz " turn input[0-9]: "
	promptWinner: .asciiz " is the winner\n"
	promptPlayAgain: .asciiz "Play again? (y/n) "
	#.word prevClaim 1             # the number to be multiplied by the next input
.text
.globl main
main:
	                            # intro prompt
	li $v0, SysPrintString        # print string
	la $a0, promptIntro           # la prompIntro for printing
	syscall                       # syscall
	                            # player vs. player print
	jal printPlayerFullName       # print player with icon
	li $v0, SysPrintString        # print string
	la $a0, promptNames           # la promptNames for printing
	syscall                       # syscall
	jal printComputerFullName     # print player with icon
	jal lineReturn                # print line return
	                            # ask to continue
	li $v0, SysPrintString        # print string
	la $a0, promptContinue        # la promptContinue for printing
	syscall                       # syscall
	li $v0, SysReadString         # read string for waiting
	syscall                       # syscall
	
  gameLoop:
    turnLoop:
	jal printBoard                # call printGridArray to display grid
    	#player input
	#check win
	    
	#display board
	#computer input
	#check win
    	
    	
    	
    	li $v0, SysExit               # exit program
	syscall                       # syscall
    	
	
	
	
	
	#display intro
	#game loop
	  #input loop while no winners
	    #display board
	    #player input
	    #check win
	    
	    #display board
	    #computer input
	    #check win
	  #if win, display winner, ask if replay
	#exit prog
	
### Common Prints ###
# purpose: prints a line return to screen 
# parameters: 
# return: 
lineReturn:
	li $v0, SysPrintChar          # print char
	la $a0, 10                    # la promptNames for printing
	syscall                       # syscall
	jr $ra                        # return
	
# purpose: prints $a1 number of char $a0
# parameters: $a0, ascii value of char. $a1 > 0, number of chars. 
# return: 
spamChar:
	li $t0, 0                     #$t0 = 0, for index
  spamCharLoop:
	li $v0, SysPrintChar          # print char
	syscall                       # syscall
	addi $t0, $t0, 1              # $t0++
	bne $t0, $a1, spamCharLoop    # if($t0 != $a1) goto spamCharLoop
	
	jr $ra                        # return