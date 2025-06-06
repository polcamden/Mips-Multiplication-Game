.include "SysCalls.asm"

#Note: these could have accessors for more security
.globl upper 
.globl lower
.globl claims
.globl board
.globl boardWidth

.globl resetBoard
.globl claimCell
.globl getCellData
.globl checkWin

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
	
.text
# purpose: resets claims, upper, and lower
# parameters: 
# return: 
resetBoard:
	sw $zero, upper                 # upper = 0
	sw $zero, lower               # lower = 0
	
	la $t0, claims                # $t0 = &claims, index
	addi $t1, $t0, 42             # $t1 = &claims[claims.length], end
  claimsResetLoop:
	sb $zero, 0($t0)              # claims[$t0] = 0
	addi $t0, $t0, 1
	bne $t0, $t1, claimsResetLoop # if($t0 != $t1) goto claimsResetLoop
	
	jr $ra                        # return

# purpose: prints board to screen 
# parameters: $a0, slider. $a1, value. $a2, claimMaker 1-player 2-computer
# return: $v0, successful = 1 else 0. $a0, claimedRow. $a1, claimedCol.  
claimCell:
	addi $sp, $sp, -8             # add to stack
	sw $ra, 0($sp)                # save $ra on stack
	sw $s0, 4($sp)                # save $s0 on stack
	
	move $t3, $a0                 # $t3 = $a0, slider
	
	lw $t0, upper                 # $t0 = upper
	lw $t1, lower                 # $t1 = lower
	seq $t2, $t0, 0               # $t2 = upper == 0
	seq $t5, $t1, 0               # $t3 = lower == 0
	and $t4, $t2, $t5             # $t4 = upper == 0 && lower == 0
	beq $t4, 0, notFirstMove      # if(upper != 0 && lower != 0) goto notFirstMove
	li $s0, 0                     # $s0 = 0
	li $a2, 0                     # $a2 = 0
	la $t0, claims                # $t0 = &claims
	j validMove                   # goto validMoveExit
  notFirstMove:
	                            # get oposite slider
	lw $t7, lower                 # $t7 = upper
	beq $t3, 0, isLower           # if($a0 == 0) goto isUpper
	lw $t7, upper                 # $t7 = lower
  isLower:
  	mul $t6, $t7, $a1             # $t6 = oppositeSlider * value
  	beq $t6, 0, invalidMove       # if(oppositeSlider * value == 0) goto invalidMove
  	move $a0, $t6                 # $a0 = $t6
  	jal findCellByValue           # call findCellByValue
  	move $s0, $v0                 # $s0 = cellIndex
  	la $t0, claims                # $t0 = &claims
  	add $t0, $t0, $v0             # $t0 = &claims[foundIndex]
  	lb $t1, 0($t0)                # $t1 = claims[foundIndex]
  	beq $t1, 0, validMove         # if($t1 == 0) goto validMove
  invalidMove:
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
  	lw $t0, boardWidth            # $t0 = boardWidth
  	divu $s0, $t0                 # divide cellIndex by width
	mflo $a0                      # $a0 = row (quotient)
	mfhi $a1                      # $a1 = col (remainder)

	lw $ra, 0($sp)                # get $ra from stack
	lw $s0, 4($sp)                # get $s0 on stack
 	addi $sp, $sp, 8              # return $sp to original
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
   	
# purpose: checks wins 
# parameters: $a0, row. $a1, col
# return: $v0, winner claim 1,2 or 0 for no winner
checkWin:
	addi $sp, $sp, -36             # add to stack
	sw $ra, 0($sp)                # save $ra on stack
	sw $s0, 4($sp)                # save $s0 on stack
	sw $s1, 8($sp)                # save $s1 on stack
	sw $s2, 12($sp)               # save $s2 on stack
	sw $s3, 16($sp)               # save $s3 on stack
	sw $s4, 20($sp)               # save $s4 on stack
	sw $s5, 24($sp)               # save $s5 on stack
	sw $s6, 28($sp)               # save $s6 on stack
	sw $s7, 32($sp)               # save $s7 on stack
	
	move $s0, $a0                 # $s0 = row
	move $s1, $a1                 # $s1 = col
	
	li $s2, 0                     # $t0 = 0, directionIndex
  directionLoop:
  	move $a0, $s2                 # $v0 = directionIndex
	jal getDirection              # call getDirection
	move $s6, $v0                 # $t1 = rowDirection
	move $s7, $v1                 # $t2 = colDirection
	mul $t3, $s6, -3              # $t3 = rowDirection * -3, for rowPosition
	mul $t4, $s7, -3              # $t4 = colDirection * -3, for colPosition
	add $s3, $t3, $s0             # rowPosition += row
	add $s4, $t4, $s1             # colPosition += col
	
	li $s5, 0                     # $s5 = 0, for line index 0-6
   stackClaims:
   	move $a0, $s3                 # $v0 = rowPosition
	move $a1, $s4                 # $v1 = colPosition
	jal getCellData               # call cellData
	addi $sp, $sp, -1             # add to stack
   	sb $v1, 0($sp)                # add claim onto stack
   	
   	add $s3, $s3, $s6             # rowPos += rowDir
   	add $s4, $s4, $s7             # colPos += colDir
	addi $s5, $s5, 1              # lineIndex++
	bne $s5, 7, stackClaims       # if(lineIndex != 7) goto stackClaims
   #stackClaims end
	li $s5, 0                     # $s5 = 0, for line index 0-6
	li $t1, 0                     # $t1 = 0, currentClaim being counted
	li $t2, 0                     # $t2 = 1, claimCount
	addi $t7, $sp, 7              # $t7 = $sp - 7, for the original stackPos
   clearClaims:
   	lb $t0, 0($sp)                # $t0 = cellClaim, grab cellClaim from stack
	addi $sp, $sp, 1              # push stack down 1 bytes
	
	bne $t0, $t1, newClaimCount   # if(currentClaim != $t0) goto changeClaimCounting
	addi $t2, $t2, 1              # claimCount++
	beq $t2, 4, hasWinner         # if(claimCount == 4) goto hasWinner
	j claimCountExit              # else goto claimCountExit
    newClaimCount:
	li $t2, 1                     # reset claimCount to 1
	move $t1, $t0                 # change currentClaim to this cell
    claimCountExit:
	addi $s5, $s5, 1              # lineIndex++
	bne $s5, 7, clearClaims       # if(lineIndex != 7) goto stackClaims
	addi $s2, $s2, 1              # directionIndex++
	bne $s2, 4, directionLoop     # if(directionIndex != 4) goto DirectionLoop
	li $v0, 0                     # else, $v0 = 0, by this time if hasWinner was never jumped theres no winner
	j directionExit               # goto directionExit
  hasWinner:
  	move $v0, $t1                 # $v0 = claimCount
  	move $sp, $t7                 # reset stack to original pos
  directionExit:
	lw $ra, 0($sp)                # get ra from stack
	lw $s0, 4($sp)                # save $s0 on stack
	lw $s1, 8($sp)                # save $s1 on stack
	lw $s2, 12($sp)               # save $s2 on stack
	lw $s3, 16($sp)               # save $s3 on stack
	lw $s4, 20($sp)               # save $s4 on stack
	lw $s5, 24($sp)               # save $s5 on stack
	sw $s6, 28($sp)               # save $s6 on stack
	sw $s7, 32($sp)               # save $s7 on stack
 	addi $sp, $sp, 36             # return $sp to original
	jr $ra                        # return
	
# purpose: gets the win directions
# parameters: $a0, [0-3] right, downRight, down, downLeft
# return: $v0, rowDirection. $v1, colDirection.
getDirection:
	beq $a0, $zero, dirRight      # if($a0 == 0) goto dirRight
	li $t1, 1
	beq $a0, $t1, dirDownRight    # if($a0 == 1) goto dirDownRight
	li $t1, 2
	beq $a0, $t1, dirDown         # if($a0 == 2) goto dirDown
	li $t1, 3
	beq $a0, $t1, dirDownLeft     # if($a0 == 2) goto dirDownLeft
  dirRight:
	li $v0, 0                     # $v0 = 0 rowDir
	li $v1, 1                     # $v1 = 1 colDir
	j directionEnd
  dirDownRight:
	li $v0, 1                     # $v0 = 1 rowDir
	li $v1, 1                     # $v1 = 1 colDir
	j directionEnd
  dirDown:
	li $v0, 1                     # $v0 = 1 rowDir
	li $v1, 0                     # $v1 = 0 colDir
	j directionEnd
  dirDownLeft:
	li $v0, 1                     # $v0 = 1 rowDir
	li $v1, -1                    # $v1 = 0 colDir
  directionEnd:
	jr $ra                        # return
