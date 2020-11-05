# Author: Tyler Mooney
# Date: October 1st, 2020
# Professor: Karen Mazidi
# Assignment: Homework 5: Compression Program
#
# Purpose: Loop promptint user to enter in a filename, if the user doesn't
# input anything except a '\n' then exit, else attempt to open file.
# If file doesn't open, print error message and exit, else read the
# file contents and print it out. Then encode the file contents and
# print that out. Then unencode the contents and print that out.
# Then print out the file size of the original file versus the compressed file.
#
# Notes:
# Acquire files hello.txt and hello_art.txt from piazza
# In order to read the file, you need to have the MARs ide/jar executable 
# in the same folder as the .txt and .asm
# Remember to add a 0 (zero)/ a null terminator  at the end of 
# the file (original data) in order to indicate to your program that is
# end of thr original data, to prevent the program from printing data
# from previously accessed files
# Maybe instead of doing the double digit method, I can use a simple loop
# counter to reduce the lines of code.
# TODO Maybe should make a macro for uncompress
#
# For reference/help:
# Use the Professor's Youtube Video for help/explanation for the project
# link: https://www.youtube.com/watch?v=X27xbrJczcY&feature=youtu.be
# Referenced Homework 3 code

.include   "macros.asm"

	.data
prompt:		.asciiz	"Enter file name to compress or <Enter> to exit: "
dataOriginal:	.asciiz	"Original data:\n"
dataCompressed:	.asciiz	"Compressed data:\n"
dataUncomp:	.asciiz	"Uncompressed data:\n"
fileOriginal:	.asciiz	"Original file size: "
fileCompress:	.asciiz	"Compressed file size: "
fileName:	.space	30
buffer:		.space	1024
heap:		.word	0
sizeOriginal:	.word	0
sizeCompressed:	.word	0

	.text
main:
	# Allocating 1024 bytes of memory and saving the pointer to the area
	allocate_heap(heap, 1024)
	
	# Prompting user for input, and acquiring input
	print_string(prompt)
	get_string(fileName, 30)	# get filename
	print_char('\n')
	
	# Checking if the user pressed Enter. If so, exit the program
	lb	$t0, fileName
	beq	$t0, '\n', end
	
	# Open file then read input
	file_open(fileName, 0)
	file_read(buffer)
	sw	$s3, sizeOriginal	# Store the original file size
	
	# Add a null terminator
	la	$t0, buffer
	add	$s3, $s3, $t0
	sb	$zero, ($s3)
	file_close
	
	# Printing out the data from the file
	print_string(dataOriginal)
	print_string(buffer)
	print_char('\n')
	print_string(dataCompressed)
	
	# Loading necessary variables, then calling compression function
	la	$a0, buffer
	lw	$a1, heap
	lw	$a2, sizeOriginal
	jal	compress		# Compress Function
	
	# I made this a Function because of the homework rubric
	jal	printCompressed		# Print compressed data
	
	# Loading necessary variables, then calling uncompression function
	lw	$a0, heap
	lw	$a1, sizeOriginal
	jal uncompress			# Uncompress Function
	
	# Printing out the original data, original file size, and compressed file size
	print_char('\n')
	print_string(fileOriginal)
	print_int(sizeOriginal)
	print_char('\n')
	print_string(fileCompress)
	print_int(sizeCompressed)
	print_char('\n')
	
	j	main
	
end:
	li	$v0, 10		# Exit program
	syscall


################# Compress Function ############################
compress:
	li	$t0, 0			# creating index
	li	$s4, 0
loop1:
	bge	$t0, $a2, exit1		# if index is >= size, then exit
	li	$t1, 1			# counter = 1
	
while:
	add	$t2, $a0, $t0
	lb	$s1, ($t2)		# Acuiring string at current index in the array
	addi	$t3, $t0, 1
	add	$t3, $a0, $t3
	lb	$s2, ($t3)		# Acquiring next the index's string
	
	bge	$t0, $a1, store		# if the index is >= the heap, store the string
	bne	$s1, $s2, store		# if the strings at the current index and next index are the same, go to store
	addi	$t0, $t0, 1		# incrimenting index
	addi	$t1, $t1, 1		# incrimenting counter
	j	while
	
store:
	sb	$s1, ($a1)		# store the string
	addi	$s4, $s4, 1
	addi	$a1, $a1, 1		# Increment heap
	bgt	$t1, 9, doubleDigitLoop		# checks if the amount is double digits
	
	addi	$t1, $t1, 48		# Acquire ACSII value of count
	sb	$t1, ($a1)		# Store count
	
	addi	$s4, $s4, 1		# increment compressed size
	addi	$a1, $a1, 1		# increment heap
	addi	$t0, $t0, 1		# incrementing index
	j	loop1
	
doubleDigitLoop:
	li	$t6, 10
	div	$t1, $t6
	mflo	$t4		# First digit
	addi	$t4, $t4, 48		# ASCII value for the first digit
	sb	$t4, ($a1)		# Store count's ten's place
	addi	$s4, $s4, 1		# Compressed size
	
	mfhi	$t5		# Second digit
	addi	$t5, $t5, 48		# ACII value for the second digit
	addi	$a1, $a1, 1		# increment heap to next location
	sb	$t5, ($a1)		# Store count's one's place
	
	addi	$a1, $a1, 1		# increment heap to next location
	addi	$t0, $t0, 1		# Incrementing index
	j	loop1
	
exit1:
	sw	$s4, sizeCompressed		# save compressed size
	jr 	$ra

################## Uncompress Function ###########################
# Minusing 48 makes converts value from ascii to int
# TODO figure out how to use the printChar macro for the loops
uncompress:
	lb	$t0, ($a0)		# Load character
	lb	$t1, 1($a0)		# Load first digit character
	lb	$t2, 2($a0)		# Load second digit character (if there is one)
	
	beq	$a1, $0, exit2		# exit when 0
	blt	$t2, 48, singleDigit		# Checks if $t2 is not a digit
	ble	$t2, 57, doubleDigit		# Checks if $t2 is a digit
	
# Print out the number of chars if they're in the single digits
singleDigit:
	addi	$t1, $t1, -48	# Get count value
	addi	$sp, $sp, -4  
	sw	$a0, ($sp)	# save $s0 (push)
	move	$t3, $t1	# Setting counter
loop2:	# Printing out all chars
	beq	$t3, $0, exitSingle
	move	$a0, $t0
	li	$v0, 11		# prints char
	syscall
	addi	$t3, $t3, -1	# decrement counter
	j loop2
exitSingle:
	lw	$a0, ($sp)	# restore $s0 (pop)
	addi	$sp, $sp, 4
	sub	$a1, $a1, $t1		# decrement the count
	addi	$a0, $a0, 2		# Acquire next char
	j	uncompress

# Print out the number of chars if they're in the double digits
doubleDigit:
	addi	$t1, $t1, -48
	addi	$t2, $t2, -48		# Acquire the int1 * 10^0
	mul	$t1, $t1, 10		# Acquire the int2 * 10^1
	add	$t1, $t1, $t2		# Acquire the (int1 * 10^0) + (int2 * 10^1)
	
	addi	$sp, $sp, -4  
	sw	$a0, ($sp)	# save $s0 (push)
	move	$t3, $t1
loop3:	# Printing out all chars
	beq	$t3, $0, exitDouble
	move	$a0, $t0
	li	$v0, 11		# prints char
	syscall
	addi	$t3, $t3, -1
	j loop3
exitDouble:
	lw	$a0, ($sp)	# restore $s0 (pop)
	addi	$sp, $sp, 4
	sub	$a1, $a1, $t1		# decrement the count
	addi	$a0, $a0, 3		# Acquire next char
	j	uncompress
	
exit2:
	jr	$ra
	
############## printCompressed Function ##########################
printCompressed:
	# Printing out the compressed data
	lw	$t0, heap
	print_string_register($t0)		# Print compressed data from heap
	print_char('\n')
	print_string(dataUncomp)
	jr	$ra