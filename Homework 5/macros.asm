# Author: Tyler Mooney
# Date: October 1st, 2020
# Professor: Karen Mazidi
# Assignment: Homework 5: Compression Program
#
# Purpose: Create macros to print an int, print a char, print a string,
# get a string from the user, open file, close file, read file, and allocate heap memory.
# You can use more macros than these if you like.
#
# Notes:
# In order to read the file, you need to have the MARs ide/jar executable 
# in the same folder as the .txt and .asm
# Some code was used/referenced from the Professor's Youtube Video
# link: https://www.youtube.com/watch?v=X27xbrJczcY&feature=youtu.be
# Used Advance MIPs Coding video by the Professor as a reference
# Timestamp: 6:36
# link: https://www.youtube.com/watch?v=Wh37So1xJGY

############################### Print integer #######################
.macro	print_int (%int)
	li	$v0, 1
	lw	$a0, %int
	syscall
.end_macro

####################### Print char ##################################
.macro	print_char (%char)
	.data
char:	.byte	%char
	.text
	li	$v0, 11
	lb	$a0, char
	syscall
.end_macro

############################ Print string ##########################
.macro print_string (%asciiz)
	.text
	li	$v0, 4
	la	$a0, %asciiz
	syscall
.end_macro

############ Prints the contents from a register ###################
.macro	print_string_register (%register)
	.text
	li	$v0, 4
	move	$a0, %register
	syscall
.end_macro

############## Acquire input from User ############################
.macro	get_string (%address, %space)
	.text
	li	$v0, 8
	la	$a0, %address
	li	$a1, %space
	syscall
.end_macro

############################ File Open ############################
.macro	file_open (%name, %mode)
	.data
error:	.asciiz		"Error! File could not be opened.\n"
	.text
	
	# deleting newline from end of string
	li	$t0, 10
	la	$a0, %name
loop2:
	lb	$t1, ($a0)
	beq	$t1, $0, continue
	beq	$t1, $t0, continue
	addi	$a0, $a0, 1
	j	loop2
continue:
	sb	$zero, ($a0)

	# Open (for reading) a file that hopefully exists
 	li	$v0, 13		# system call for open file
 	la	$a0, %name	# Loading name
	li	$a1, %mode	# Open for reading (flags are 0: read, 1: write)
	li	$a2, 0		# mode is ignored
 	syscall            # open a file (file descriptor returned in $v0)

 	move	$s4, $v0      # save the file descriptor 
 	bgtz	$v0, end
	# Exiting Program because of error
	print_string(error)
	li	$v0, 10		# Exit program
	syscall
end:
.end_macro

############################ File Close ##############################
.macro	file_close
	li	$v0, 16
	move	$a0, $s4
	syscall			# Close file
.end_macro

############################### File Read ############################
.macro	file_read (%buffer)
	li	$v0, 14
	move	$a0, $s4
	la	$a1, %buffer
	li	$a2, 1024
	syscall
	move	$s3, $v0		# File size
.end_macro

####################### Allocates memory for heap ##########################
.macro	allocate_heap (%heap, %size)
	li	$v0, 9
	li	$a0, %size
	syscall
	sw	$v0, %heap
.end_macro
