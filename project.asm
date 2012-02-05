######## DATA ########
	.data
turnOn:
	.asciiz "-- The Vending Machine is on --\n"
instructions:
	.asciiz "Type 301 for Coffee\nType 302 for Tea\nType 0 to quit\n\n"
coffee:
	.asciiz "-- Display --\nYour coffee is ready\n\n"
tea:
	.asciiz "-- Display --\nYour tea is ready\n\n"
missing1:
	.asciiz "-- Display --\nYou're missing "
missing2:
	.asciiz " cents\n\n"
cash1:
	.asciiz "Cash: "
cash2:
	.asciiz "\n\n"
exitMsg:
	.asciiz "-- Shutting down the Vending Machine --\n"
flag:
	.word 0

######## TEXT SEGMENT ########
	.text
	.globl main
main:
	li $t1, 0					# t1 will be the initial credit
	# Euro Coins #
	li $t2, 5
	li $t3, 10
	li $t4, 20
	li $t5, 50
	li $t6, 100
	li $t7, 200
	# Beverages that will be sold #
	li $t8, 301
	li $t9, 302
	# End #
	li $v0, 4					# syscall code to print a string
	la $a0, turnOn				# string to print
	syscall						# print it!
	la $a0, instructions		# string to print
	syscall						# print it!
do:
	li $v0, 5					# syscall code to read an integer value
	syscall						# wait the user input, it's going to be saved in $v0
	bne $v0, $0, ifCoin5		# if the input is not 'zero', jump the code that sets 'flag' to 1
	lw $t0, flag
	li $t0, 1
	sw $t0, flag				# flag is now set to 1
ifCoin5:
	bne $v0, $t2, ifCoin10		# if v0 == 5 the credit is updated, otherwise check if v0 == 10
	add $t1, $t1, $v0
	j doEnd
ifCoin10:
	bne $v0, $t3, ifCoin20		# if v0 == 10 the credit is updated, otherwise check if v0 == 20
	add $t1, $t1, $v0
	j doEnd
ifCoin20:
	bne $v0, $t4, ifCoin50		# if v0 == 20 the credit is updated, otherwise check if v0 == 50
	add $t1, $t1, $v0
	j doEnd
ifCoin50:
	bne $v0, $t5, ifCoin100		# if v0 == 50 the credit is updated, otherwise check if v0 == 100
	add $t1, $t1, $v0
	j doEnd
ifCoin100:
	bne $v0, $t6, ifCoin200		# if v0 == 100 the credit is updated, otherwise check if v0 == 200
	add $t1, $t1, $v0
	j doEnd
ifCoin200:
	bne $v0, $t7, checkCoffee	# if v0 == 200 the credit is updated, otherwise jump to check if the user wrote the code to get a coffee (301)
	add $t1, $t1, $v0
	j doEnd
checkCoffee:
	bne $v0, $t8, checkTea		# if v0 == 301 it means the user wants some coffee, otherwise jump to check if the user wrote the code to get a tea (302)
	# Coffee has been chosen
	sltiu $t0, $t1, 35			# set $t0 to 1 if credit is not enough
	bgtz $t0, noMoneyC
	addi $t1, $t1, -35			# credit update
	li $v0, 4					# syscall code to print a string
	la $a0, coffee				# string to print
	syscall
	j doEnd
	noMoneyC:
		# credit is not enough!
		li $v0, 4				# syscall code to print a string
		la $a0, missing1		# string to print
		syscall
		li $t0, 35
		sub $t0, $t0, $t1		# how much does the user need to get a coffee?
		li $v0, 1				# syscall code to print an integer value
		li $a0, 0
		add $a0, $a0, $t0		# set $a0 to $t0 and print how much money the user will need to complete the transaction
		syscall
		li $v0, 4				# syscall code to print a string
		la $a0, missing2		# string to print
		syscall
		j doEnd
checkTea:
	bne $v0, $t9, doEnd			# if v0 == 302 it means the user wants some tea, otherwise jump to the end of the loop
	# Scelto te'
	sltiu $t0, $t1, 40			# set $t0 to 1 if credit is not enough
	bgtz $t0, noMoneyT
	addi $t1, $t1, -40			# credit update
	li $v0, 4					# syscall code to print a string
	la $a0, tea					# string to print
	syscall
	j doEnd
	noMoneyT:
		li $v0, 4				# syscall code to print a string
		la $a0, missing1		# string to print
		syscall
		li $t0, 40
		sub $t0, $t0, $t1		# how much does the user need to get a coffee?
		li $v0, 1				# syscall code to print an integer value
		li $a0, 0
		add $a0, $a0, $t0		# set $a0 to $t0 and print how much money the user will need to complete the transaction
		syscall
		li $v0, 4				# syscall code to print a string
		la $a0, missing2		# string to print
		syscall
doEnd:
	li $v0, 4					# syscall code to print a string
	la $a0, cash1				# string to print
	syscall
	li $v0, 1					# syscall code to print an integer value
	li $a0, 0
	add $a0, $a0, $t1			# set $a0 to $t1 and print the current credit
	syscall
	li $v0, 4					# syscall code to print a string
	la $a0, cash2				# string to print
	syscall
	lw $t0, flag
	beq $t0, $0, do				# if t0 == 0 go back to the start of the loop, otherwise go to exit
exit:
	li $v0, 4					# syscall code to print a string
	la $a0, exitMsg				# string to print
	syscall
	li $v0, 10					# exit
	syscall