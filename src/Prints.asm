.include "SysCalls.asm"

.globl printBoard
.globl printNumberLine
.globl lineReturn
.globl spamChar
.globl printHeader
.globl enterToContinue

.data
	######################### Prompts ############################
	promptIntro: .asciiz "-+-+-+- Welcome to multiplication game -+-+-+-\n"
	promptNames: .asciiz " vs. "
	promptContinue: .asciiz "Enter to continue"
	promptWinner: .asciiz " is the winner\n"
	promptPlayAgain: .asciiz "Play again? (y/n) "
	########################## Board #############################
	boardHorizontal: .asciiz "+----+----+----+----+----+----+\n"
	numberLine: .asciiz "   1   2   3   4   5   6   7   8   9\n"
	downArrow: .asciiz "\\/\n"
	upArrow: .asciiz "/\\\n"
	
.text
# purpose: prints board with claims
# parameters: 
# return: 
printBoard:
	addi $sp, $sp, -16            # add to stack
	sw $ra, 0($sp)                # save $ra on stack
	sw $s0, 4($sp)                # save $s0 on stack
	sw $s1, 8($sp)                # save $s1 on stack
	sw $s2, 12($sp)               # save $s2 on stack
	
	li $s0, 0                     # $s0 = 0, rowIndex
	li $s1, 0                     # $s1 = 0, colIndex
	lw $s2, boardWidth            # $s2 = boardWidth
	
	li $v0, SysPrintString        # service call: print int
	la $a0, boardHorizontal       # load word at index
	syscall                       # syscall
  rowLoop:
   colLoop:                     # get value of cell and icon of player claim
    move $a0, $s0                 # $a0 = rowIndex
	move $a1, $s1                 # $a1 = colIndex
   	jal getCellData               # call getCellData
   	move $t0, $v0                 # $t0 = value
   	move $t1, $v1                 # $t1 = claim
   	move $a0, $v1                 # $a0 = claim
   	jal getPlayerIcon             # call getPlayerIcon
   	move $t2, $v0                 # $t2 = claimIcon
   	                            # print out cell
   	li $v0, SysPrintChar          # service call: print int
	li $a0, 124                   # $a0 = '|'
	syscall                       # syscall
   	li $v0, SysPrintChar          # service call: print int
	move $a0, $t2                 # $a0 = claim char, for printing
	syscall                       # syscall
	sle $t7, $t0, 9               # $t7 = $a0 <= 9 ? 1 : 0
	beqz $t7, boardNoSpace        # if $t7 != 0 goto boardNoSpace
	li $v0, SysPrintChar          # service call: print char
	li $a0, 32                    # $a0 = ' '
	syscall                       # syscall
   boardNoSpace:
	li $v0, SysPrintInt           # service call: print int
	move $a0, $t0                 # $a0 = claim char, for printing
	syscall                       # syscall
	li $v0, SysPrintChar          # service call: print int
	move $a0, $t2                 # $a0 = claim char, for printing
	syscall                       # syscall
   	                            # iterate loop
   	addi $s1, $s1, 1              # colIndex++
	bne $s1, $s2, colLoop         # if(colIndex != boardWidth) goto colLoop
	li $v0, SysPrintChar          # service call: print int
	li $a0, 124                   # $a0 = '|'
	syscall                       # syscall
	li $v0, SysPrintChar          # service call: print char
	li $a0, 10                    # $a0 = '/n'
	syscall                       # syscall
	li $v0, SysPrintString        # service call: print int
	la $a0, boardHorizontal       # load word at index
	syscall                       # syscall
	li $s1, 0                     # colIndex = 0
	addi $s0, $s0, 1              # rowIndex++
    bne $s0, $s2, rowLoop         # if(rowIndex != boardWidth) goto colLoop
   
	lw $ra, 0($sp)                # save $ra on stack
	lw $s0, 4($sp)                # save $s0 on stack
	lw $s1, 8($sp)                # save $s1 on stack
	lw $s2, 12($sp)               # save $s2 on stack
	lw $s3, 16($sp)               # save $s3 on stack
 	addi $sp, $sp, 16             # return $sp to original
	jr $ra                        # return 

# purpose: prints number line and current numbers 
# parameters: 
# return: 
printNumberLine:
	addi $sp, $sp, -4             # add to stack
	sw $ra, 0($sp)                # save $ra on stack
	lw $t6, upper                 # $t6 = upper
	lw $t7, lower                 # $t7 = lower
	                            # print upper arrow
	li $a0, 32                    # $a0 = ' '
  	li $a1, 4                     # $a1 = 4
  	mul $a1, $a1, $t6             # $a1 *= upper
  	addi $a1, $a1, -2             # $a1 -= 1
  	jal spamChar                  # call spamChar
	li $v0, SysPrintString        # print string 
	la $a0, downArrow             # $a0 = &downArrow
	syscall                       # syscall
	                            # print number line
	li $v0, SysPrintString        # print string 
	la $a0, numberLine            # $a0 = &numberLine
	syscall                       # syscall
	                            # print lower arrow
	li $a0, 32                    # $a0 = ' '
  	li $a1, 4                     # $a1 = 4
  	mul $a1, $a1, $t7             # $a1 *= lower
  	addi $a1, $a1, -2             # $a1 -= 1
  	jal spamChar                  # call spamChar
  	li $v0, SysPrintString        # print string 
	la $a0, upArrow               # $a0 = &downArrow
	syscall                       # syscall
	                            # unstack and return
	lw $ra, 0($sp)                # get ra from stack
 	addi $sp, $sp, 4              # return $sp to original
	jr $ra                        # return 

PrintPlayerWin:
	beq $v0, 2, isComputerWin     # if($v0 == 2) goto isComputerWin
   	jal printPlayerFullName       # else, call printPlayerFullName
   	j winnerExit                  # exit if/else
  isComputerWin:
   	jal printComputerFullName     # call printComputerFullName
  winnerExit:
   	li $v0, SysPrintString        # service call: print int
	la $a0, promptWinner          # load winner prompt                  
	syscall                       # syscall
	
	jr $ra

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