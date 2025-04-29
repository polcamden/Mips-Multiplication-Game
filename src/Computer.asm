.include "SysCalls.asm"

.globl computerIcon

.globl getComputerInput
.globl printComputerFullName

.data
	computerIcon: .byte '&'
	computerName: .asciiz "Computer"
	
	inputPrompt1: .asciiz "computer thinking...\n"
	inputPrompt2: .asciiz "upper, value: "
	inputPrompt3: .asciiz "lower, value: "
.text
# purpose: gets computer input
# parameters: 
# return: $v0, slider. $v1, value
getComputerInput:
	addi $sp, $sp, -12             # add to stack
	sw $ra, 0($sp)                # save $ra on stack
	sw $s0, 4($sp)                # save $ra on stack
	sw $s1, 8($sp)                # save $ra on stack
	
	li $v0, SysPrintString        # print string
	la $a0, inputPrompt1          # print inputPrompt1
	syscall                       # syscall
	
	#get number $t0 slider, $t1, value
  invalidMove:
	li $v0, SysRandIntRange       # 42 is system call code to generate random int
	li $a1, 1                     # $a1 is where you set the upper bound
	syscall                       # your generated number will be at $a0
	move $s0, $a0                 # $t0 = $v0, randNumber
	
	li $v0, SysRandIntRange       # 42 is system call code to generate random int
	li $a1, 8                     # $a1 is where you set the upper bound
	syscall                       # your generated number will be at $a0
	addi $a0, $a0, 1              # $v0++
	move $s1, $a0                 # $t0 = $v0, randNumber

	move $a0, $s0                 # $a0 = $v0
	move $a1, $s1                 # $a0 = $v0
	li $a2, 2                     # $a2 = 2
	jal claimCell                 # call claimCell
	beq $v0, 0, invalidMove       # if($v0 == 0) goto invalidMove
	                             # print prompt of play
	beq $s0, 1, isLower           # if($v0 == 1) goto isLower
	li $v0, SysPrintString        # print string
	la $a0, inputPrompt2          # print inputPrompt2
	syscall                       # syscall
	j inputExit                   # jump to return
  isLower:                      # print lower prompt
	li $v0, SysPrintString        # print string
	la $a0, inputPrompt3          # print inputPrompt3
	syscall                       # syscall
  inputExit:                    # print value and return
	li $v0, SysPrintInt           # print int
	move $a0, $s1                 # print $t1
	syscall                       # syscall
	li $v0, SysPrintChar          # print char
	la $a0, 10                    # la promptNames for printing
	syscall                       # syscall
	
	lw $ra, 0($sp)                # get ra from stack
	lw $s0, 4($sp)                # get ra from stack
	lw $s1, 8($sp)                # get ra from stack
 	addi $sp, $sp, 12             # return $sp to original
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
