.include "SysCalls.asm"

.data
	.globl computerIcon
	.globl computerName
	computerIcon: .byte '#'
	computerName: .asciiz "Computer"
.text
.globl getComputerInput
.globl printComputerFullName
#.globl printComputerFullName

# purpose: gets computer input
# parameters: 
# return: $v0, row input. $v1, col input
getComputerInput:
	jr $ra                        # return

# purpose: prints computer name and icon "computer (@)"
# parameters: 
# return: 	
printComputerFullName:
	li $v0, SysPrintString        # print string
	la $a0, computerName          # la computerName for printing
	syscall                       # syscall
	li $v0, SysPrintChar          # print char
	li $a0, 32                    # $a0 = ' '
	syscall                       # syscall
	li $v0, SysPrintChar          # print char
	li $a0, 40                    # $a0 = '('
	syscall                       # syscall
	li $v0, SysPrintChar          # print char
	lb $a0, computerIcon          # $a0 = computerIcon
	syscall                       # syscall
	li $v0, SysPrintChar          # print char
	li $a0, 41                    # $a0 = ')'
	syscall                       # syscall
	jr $ra                        #return