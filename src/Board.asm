.include "SysCalls.asm"
.data
	board: .word  1,  2,  3,  4,  5,  6, 
	              7,  8,  9, 10, 12, 14, 
	             15, 16, 18, 20, 21, 24, 
	             25, 27, 28, 30, 32, 35, 
	             36, 40, 42, 45, 48, 49, 
	             54, 56, 63, 64, 72, 81
	boardWidth: .word 6
	
	boardHorizontal: .asciiz "+----+----+----+----+----+----+"
	
	# claimed cells by players. 
	# 0b0...00 - unclaimed
	# 0b0...01 - player
	# 0b0...10 - computer
	claims: .byte 42
.text 
.globl printBoard

# purpose: prints board to screen 
# parameters: 
# return: 
printBoard:
	la $t0, board                 # $t0 = &board, this will act as an index
	addi $t1, $t0, 144            # $t1 = &board + 144, for last address
	li $t2, 0                     # $t2 = 0, used for width count
	lw $t3, boardWidth            # $t3 = boardWidth
	
  boardLoop:
	li $v0, SysPrintInt           # service call: print int
	lw $a0, 0($t0)                # load word at index
	syscall                       # syscall
	
	sle $t7, $a0, 9               # if $a0 <= 9 then $t7 = 1 else $t7 = 0
	beqz $t7, boardNoSpace        # if $t7 != 0 goto boardNoSpace
	li $v0, SysPrintChar          # service call: print char
	li $a0, 32                    # $a0 = ' '
	syscall                       # syscall
   boardNoSpace:
	li $v0, SysPrintChar          # service call: print char
	li $a0, 32                    # $a0 = ' '
	syscall                       # syscall
	
	addi $t2, $t2, 1              # add 1 to widthCount
	bne $t2, $t3, boardNoReturn   # if $t2 != $t3 goto boardNoReturn
	li $t2, 0                     # $t2 = 0, reset the width counter
	li $v0, SysPrintChar          # service call: print char
	li $a0, 10                    # $a0 = '/n'
	syscall                       # syscall
   boardNoReturn:
	li $v0, SysPrintChar          # service call: print int
	li $a0, 13                    # load word of int at $t0
	syscall                       # syscall
	
	addi $t0, $t0, 4              # add 4 bytes to index
	bne $t0, $t1, boardLoop       # if $t0 != $t1 goto boardLoop
	
	jr $ra
	
# purpose: prints board to screen 
# parameters: $a0, row. $a1, col. $a2, 1 - player  2 - computer
# return: 
claimCell:
	lw $t0, boardWidth            # $t0 = boardWidth
	
	li $t1, 0                     # $t1 = claim index, will be $t1 = row + col * width
	addi $t1, $a0, 0              # $t1 += row
	mult $a1, $t0                 # col * width
	mflo $t2                      # $t2 = col * width
	add  $t1, $t1, $t2            # $t1 += $t2
	
	la $t3, claims                # $t3 = &claims
	add $t3, $t3, $t1            # $t3 = &claims[$t1]
	
	sw $a2, 0($t3)                # claims[$t1] = $a2, set player claim
	jr $ra                        # return
