.include "SysCalls.asm"

.globl playerIcon

.globl getPlayerInput
.globl printPlayerFullName

.data
	playerIcon: .byte '!'
	playerName: .asciiz "Player"
	
	inputPrompt1: .asciiz "upper or lower arrow [0,1]: "
	inputPrompt2: .asciiz "value [1-9]: "
	inputInvalid: .asciiz "Invalid move, cell already claimed.\n"
.text

# purpose: gets player input
# parameters: 
# return: $v0, slider. $v1, value. $a0, claimedRow. $a1, claimedCol
getPlayerInput:
	addi $sp, $sp, -4             # add to stack
	sw $ra, 0($sp)                # save $ra on stack
	j restartPrompt1              # jump to restartPrompt1
  invalidMove:
	li $v0, SysPrintString        # print string
	la $a0, inputInvalid          # print inputPrompt1
	syscall                       # syscall
  restartPrompt1:
	li $v0, SysPrintString        # print string
	la $a0, inputPrompt1          # print inputPrompt1
	syscall                       # syscall
	li $v0, SysReadInt            # read int
	syscall                       # syscall
	move $t0, $v0                 # move input into $t0
	sge $t6, $t0, 0               # $t6 = $t0 >= 0
	sle $t7, $t0, 1               # $t7 = $t0 <= 1
	and $t5, $t6, $t7             # $t5 = $t6 && $t7
	bne $t5, 1, restartPrompt1    # if($t5 != 1) goto retartPrompt1
  restartPrompt2:
	li $v0, SysPrintString        # print string
	la $a0, inputPrompt2          # print inputPrompt2
	syscall                       # syscall
	li $v0, SysReadInt            # read int
	syscall                       # syscall
	move $t1, $v0                 # move input into $t1
	sgt $t6, $t1, 0               # $t6 = $t1 > 0
	sle $t7, $t1, 9               # $t7 = $t1 <= 1
	and $t5, $t6, $t7             # $t5 = $t6 && $t7
	bne $t5, 1, restartPrompt2    # if($t5 != 1) goto retartPrompt2
	
	move $v0, $t0                 # $v0 = $t0, slider
	move $v1, $t1                 # $v1 = $t1, value
	
	move $a0, $v0                 # $a0 = $v0
	move $a1, $v1                 # $a0 = $v0
	li $a2, 1                     # $a2 = 2
	jal claimCell                 # call claimCell
	
	beq $v0, 0, invalidMove       # if($v0 == 0) goto invalid move
	
	lw $ra, 0($sp)                # get ra from stack
 	addi $sp, $sp, 4              # return $sp to original
	jr $ra                        # return

# purpose: prints player name and icon "player (@)"
# parameters: 
# return: 	
printPlayerFullName:
	li $v0, SysPrintString        # print string
	la $a0, playerName            # la playerName for printing
	syscall                       # syscall
	li $v0, SysPrintChar          # print char
	li $a0, 32                    # $a0 = ' '
	syscall                       # syscall
	li $v0, SysPrintChar          # print char
	li $a0, 40                    # $a0 = '('
	syscall                       # syscall
	li $v0, SysPrintChar          # print char
	lb $a0, playerIcon            # $a0 = playerIcon
	syscall                       # syscall
	li $v0, SysPrintChar          # print char
	li $a0, 41                    # $a0 = ')'
	syscall                       # syscall
	jr $ra                        #return
