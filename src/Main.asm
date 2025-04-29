# Term Project CS/SE 2340
# Author: Camden Ernst
# Date: 4/17/2025

.include "SysCalls.asm"

.data
	
.text
main:
	jal printHeader               # print header
	jal enterToContinue           # pause till enter
	
  gameLoop:
	jal resetBoard                # reset board
    turnLoop:
   	                            # player turn
	jal printBoard                # call printGridArray to display grid
	jal printNumberLine           # call printNumberLine
	
	jal getPlayerInput            # call getPlayerInput return $a0, rowClaimed. $a1, colClaimed
	jal checkWin                  # call checkWin $a0, $a1
	bne $v0, 0, hasWinner         # if($v0 != 0) goto hasWinner
	                            # computer turn
	jal getComputerInput          # get computer input
	jal checkWin                  # call checkWin $a0, $a1
	bne $v0, 0, hasWinner         # if($v0 != 0) goto hasWinner
	j turnLoop                    # if no winner goto turnLoop
  hasWinner:
   	jal printBoard                # print board
   	
   	move $a0, $v0                 # $a0 = winner
   	
   	
   	
   
   	# ask to play again
   	
	li $v0, SysExit               # exit program
	syscall                       # syscall
