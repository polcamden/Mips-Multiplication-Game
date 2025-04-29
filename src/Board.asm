.include "SysCalls.asm"
.data
	######################## variables ###########################
	upper: .word 0                # where the upper arrow points
	lower: .word 0                # where the lower arrow points 
	claims: .space 42             # claimed cells by players.
	                              # 0 - unclaimed
	                              # 1 - player
	                              # 2 - computer
	######################## constants ###########################
	board: .word  1,  2,  3,  4,  5,  6, 
	              7,  8,  9, 10, 12, 14, 
	             15, 16, 18, 20, 21, 24, 
	             25, 27, 28, 30, 32, 35, 
	             36, 40, 42, 45, 48, 49, 
	             54, 56, 63, 64, 72, 81
	boardWidth: .word 6
	boardHorizontal: .asciiz "+----+----+----+----+----+----+\n"

	numberLine: .asciiz "   1   2   3   4   5   6   7   8   9\n"
	downArrow: .asciiz "\\/\n"
	upArrow: .asciiz "/\\\n"
.text
.globl resetBoard
.globl printBoard
.globl printNumberLine
.globl claimCell

# purpose: resets claims, upper, and lower
# parameters: 
# return: 
resetBoard:
	li $t0, 5                     # $t0 = 5
	sw $t0, upper                 # upper = 0
	sw $zero, lower               # lower = 0
	
	la $t0, claims                # $t0 = &claims, index
	addi $t1, $t0, 42             # $t1 = &claims[claims.length], end
  claimsResetLoop:
	sb $zero, 0($t0)              # claims[$t0] = 0
	addi $t0, $t0, 1
	bne $t0, $t1, claimsResetLoop # if($t0 != $t1) goto claimsResetLoop
	
	jr $ra                        # return

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

# purpose: prints board to screen 
# parameters: $a0, slider. $a1, value. $a2, claimMaker 1-player 2-computer
# return: $v0, successful = 1 else 0
claimCell:
	addi $sp, $sp, -4             # add to stack
	sw $ra, 0($sp)                # save $ra on stack
	                            # get oposite slider
	move $t3, $a0                 # $t3 = $a0, slider
	lw $t7, lower                 # $t7 = upper
	beq $t3, 0, isLower           # if($a0 == 0) goto isUpper
	lw $t7, upper                 # $t7 = lower
  isLower:
  	mul $t6, $t7, $a1             # $t6 = oppositeSlider * value
  	move $a0, $t6                 # $a0 = $t6
  	jal findCellByValue           # call findCellByValue
  	
  	la $t0, claims                # $t0 = &claims
  	add $t0, $t0, $v0             # $t0 = &claims[foundIndex]
  	lb $t1, 0($t0)                # $t1 = claims[foundIndex]
  	beq $t1, 0, validMove         # if($t1 == 0) goto validMove
  	li $v0, 0                     # $v0 = 0, unsuccessful move
  	j validMoveExit               # jump to validMoveExit
  validMove:
	sb $a2, 0($t0)                # claims[foundIndex] = claimMaker
	
	beq $t3, 1, isLowerChange     # if(slider == 1) goto isLowerChange
	sw $a1, upper                 # $t7 = lower
	j changeExit                  # exit if/else
   isLowerChange: 
	sw $a1, lower                 # $t7 = upper
   changeExit:
	li $v0, 1                     # $v0 = 1, successful move
  validMoveExit:
	lw $ra, 0($sp)                # get ra from stack
 	addi $sp, $sp, 4              # return $sp to original
	jr $ra                        # return

# purpose: given a value returns the cell index
# parameters: $a0, value
# return: $v0, cell index
findCellByValue:
	li $v0, 0                     # $v0 = 0, cellIndex
	la $t0, board                 # $t0 = &board, boardIndex
	addi $t1, $t0, 144            # $t1 = &board[board.length], endIndex
  findLoop:
	lw $t2, 0($t0)                # $t2 = board[$t0]
	beq $t2, $a0, cellFound       # if($t2 == $a0) goto cellFound
	addi $t0, $t0, 4              # $t0 += 4
	addi $v0, $v0, 1              # $v0 += 1
	beq $t1, $t0, cellNotFound    # if($t0 == $t1) goto cellNotFound
	j findLoop                    # jump findLoop
  cellNotFound:
  	li $v0, -1                    # $v0 = -1
  cellFound:
	jr $ra                        # return

# purpose: given a row, col get the cell value and claim 
# parameters: $a0, row. $a1, col.
# return: $v0, value. $v1, claim. 
getCellData:
	lw $t0, boardWidth            # $t0 = boardWidth
	                            # check if row and col are within board
	sge $t6, $a0, 0               # $t6 = $a0 >= 0
	slt $t7, $a0, $t0             # $t7 = $a0 < boardWidth
	and $t5, $t6, $t7             # $t5 = $t6 && $t7
	bne $t5, 1, invalidCell       # if($t5 != 1) goto invalidCell
	sge $t6, $a1, 0               # $t6 = $a1 >= 0
	slt $t7, $a1, $t0             # $t7 = $a1 < boardWidth
	and $t5, $t6, $t7             # $t5 = $t6 && $t7
	bne $t5, 1, invalidCell       # if($t5 != 1) goto invalidCell
	j validCell                   # goto validCell
  invalidCell:
	li $v0, -1                    # $v0 = -1
	li $v1, -1                    # $v1 = -1
	jr $ra                        # return
  validCell:
  	                            # $t1 = (row * width + col) * 4
	mul $t1, $a0, $t0             # $t1 = row * width
	add $t1, $t1, $a1             # $t1 += col
	sll $t2, $t1, 2               # $t2 *= 4
	la $t3, board                 # $t3 = &board
	add $t3, $t3, $t2             # $t3 = &board[$t2]
	la $t4, claims                # $t4 = &claim
	add $t4, $t4, $t1             # $t4 = &claim[$t1]
	lw $v0, 0($t3)                # $v0 = board[$t3]
	lb $v1, 0($t4)                # $v1 = claim[$t4]
	
	jr $ra                        # return
	
# purpose: gets player or computer icon from claim value 
# parameters: $a0, claim
# return: $v0, icon char.
getPlayerIcon:
	li $v0, 32                    # $t2 = claim icon, ' ' or player icon
	beq $a0, 1, isPlayer          # if(claim == 1) goto isPlayer
  	beq $a0, 2, isComputer        # if(claim == 2) goto isComputer
	j noClaim                     # jump to noClaim
  isPlayer:
	lb $v0, playerIcon            # load player char
	j noClaim                     # jump to noClaim
  isComputer:
	lb $v0, computerIcon          # load computer char 
  noClaim:
	jr $ra                     # return
   	
