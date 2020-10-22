# Autor: Tyler Mooney
# Date: September 6th, 2020
# Professor: Karen Mazidi
# Assignment: Homework 1: MIPS Programming Basics
# Purpose: Must acquire the user's name and 3 integers,
# then calculate 3 different equations and display the results

	.data
a:	.word	0
b:	.word	0
c:	.word	0
ans1:	.word	0
ans2:	.word	0
ans3:	.word	0
name:	.space	20
msg1:	.asciiz	"Please enter your name: "
msg2:	.asciiz	"Please enter an integer between 1 and 100: "
msg3:	.asciiz	"The answers are "

	.text

	# Prompt user for name and acquire input
	li	$v0, 4		# print prompt
	la	$a0, msg1
	syscall
	li	$v0, 8		# get string from user
	la	$a0, name
	li	$a1, 20
	syscall
	
	# Acquire Three Integers from the user and fill a,b,c
	li	$v0, 4		#print string
	la	$a0, msg2
	syscall
	li	$v0, 5		# get integer from user
	syscall
	sw	$v0, a
	
	li	$v0, 4		#print string
	la	$a0, msg2
	syscall
	li	$v0, 5		# get integer from user
	syscall
	sw	$v0, b
	
	li	$v0, 4		#print string
	la	$a0, msg2
	syscall
	li	$v0, 5		# get integer from user
	syscall
	sw	$v0, c
	
	# Calculating ans1 = 2a - c + 4 and storing it
	lw	$s1, a
	lw	$s2, b
	lw	$s3, c
	
	add	$t0, $s1, $s1
	sub	$t1, $t0, $s3
	add	$t2, $t1, 4
	sw	$t2, ans1
	
	# Calculating ans2 = b - c + (a - 2) and storing it
	sub	$t0, $s2, $s3
	sub	$t1, $s1, 2
	add	$t2, $t0, $t1
	sw	$t2, ans2
	
	# Calculating ans3 = (a + 3) - (b - 1) + (c + 3) and storing it
	add	$t0, $s1, 3
	sub	$t1, $s2, 1
	add	$t2, $s3, 3
	sub	$t3, $t0, $t1
	add	$t4, $t3, $t2
	sw	$t4, ans3
	
	# Printing out user's name and the results
	li	$v0, 4
	la	$a0, name
	syscall
	
	li	$v0, 4
	la	$a0, msg3
	syscall
	
	lw	$a0, ans1
	li	$v0, 1
	syscall
	
 	li 	$v0, 11		#output a space
 	li 	$a0, 0x20
 	syscall
 	
 	lw	$a0, ans2
	li	$v0, 1
	syscall
	
 	li 	$v0, 11		#output a space
 	li 	$a0, 0x20
 	syscall
 	
 	lw	$a0, ans3
	li	$v0, 1
	syscall
	
	# Test case 1
	# name = Tyler
	# a = 65, b = 32, c = 4
	# Output: 
	# Tyler
	# The answers are 130 91 44
	
	# Test case 2
	# name = James
	# a = 7, b = 45, c = 26
	# Output:
	# James
	# The answers are The answers are -8 24 -5
	
	