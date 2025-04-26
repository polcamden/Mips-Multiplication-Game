.include "SysCalls.asm"
.data
	.globl playerIcon
	.globl playerName
	playerIcon: .byte '@'
	playerName: .asciiz "Player"
.text
.globl getPlayerInput
.globl printPlayerFullName

# purpose: gets player input
# parameters: 
# return: $v0, row input. $v1, col input
getPlayerInput:
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