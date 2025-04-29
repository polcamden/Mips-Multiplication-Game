# Term Project CS/SE 2340
# Author: Camden Ernst
# Date: 4/17/2025

.include "SysCalls.asm"

.data
	promptIntro: .asciiz "-+-+-+- Welcome to multiplication game -+-+-+-\n"
	promptNames: .asciiz " vs. "
	promptContinue: .asciiz "Enter to continue"
	
	promptWinner: .asciiz " is the winner\n"
	promptPlayAgain: .asciiz "Play again? (y/n) "
.text
.globl main
.globl spamChar
.globl lineReturn
main:
	jal printHeader               # print header
	jal enterToContinue           # pause till enter
	
	li $s0, 0                     # $s0 = 0, for winner
  gameLoop:
	jal resetBoard                # reset board
   turnLoop:
   		                        # player turn
	jal printBoard                # call printGridArray to display grid
	jal printNumberLine           # call printNumberLine
	jal getPlayerInput            # get player input
	#check if win at row col
	                            # computer turn
	jal getComputerInput          # get computer input
	# check retern value ^ and loop
	#bne $s0, 0, hasWinner         # break if theres a winner

	
    # check retern value ^ and loop
    #bne $s0, 0, hasWinner          # break if theres a winner
    j turnLoop                    # if no winner goto gameLoop
   hasWinner:
   	# display board
   	# display winner
   	# ask to play again
    
    
    
    li $v0, SysExit               # exit program
	syscall                       # syscall
    
### Prints ###
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
	addi $sp, $sp, -4             # add to stack
	sw $t0, 0($sp)                # save $t0 on stack
	
	sle $t0, $a1, $zero           # $t0 = ($a1 <= $zero) ? 1 : 0
	beq $t0, 1, spamCharExit      # exit to prevent endless loop

	li $t0, 0                     #$t0 = 0, for index
  spamCharLoop:
	li $v0, SysPrintChar          # print char
	syscall                       # syscall
	addi $t0, $t0, 1              # $t0++
	bne $t0, $a1, spamCharLoop    # if($t0 != $a1) goto spamCharLoop
	
  spamCharExit:
	lw $t0, 0($sp)                # get t0 from stack
 	addi $sp, $sp, 4              # return $sp to original
	jr $ra                        # return
	
# purpose: prints intro prompts 
# parameters: 
# return: 
printHeader:
	addi $sp, $sp, -4             # add to stack
	sw $ra, 0($sp)                # save $ra on stack
	
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
	
	lw $ra, 0($sp)                # get ra from stack
 	addi $sp, $sp, 4              # return $sp to original
	jr $ra                        # return

# purpose: pauses till enter is pressed 
# parameters: 
# return: 
enterToContinue:
	li $v0, SysPrintString        # print string
	la $a0, promptContinue        # la promptContinue for printing
	syscall                       # syscall
	li $v0, SysReadString         # read string for waiting
	syscall                       # syscall
	jr $ra                        # return
