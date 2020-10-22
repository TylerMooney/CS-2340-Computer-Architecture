# Author: Tyler Mooney
# Date: September 29th, 2020
# Professor: Karen Mazidi
# Assignment: Homework 3: MIPS FP Operations
#
# Purpose:
# - Read an input file "input.txt" into a buffer in memory
# - Extract the string "numbers", convert them to integers and store in an array
# - Print the integers to console
# - Sort the integers in place using selection sort
# - Print the sorted integers to console
# - Calculate the mean, median, and standard deviation, printing results to the console
#
# Notes:
# popping and pushing stuff might help
# I should name functions better names
# I should probably change which registers I use, and delete some lines that are
# redundant or meaningless. (Note for future me)
# In the function, I use lb, should probably change those to lw or lwc1
# Somehow putting the array at the bottom fixed a problem where the array contents
# were overwritten by the mean, deviation, and median
# In order to read the file, you need to have the MARs ide/jar executable 
# in the same folder as the .txt and .asm
# Some code was used/referenced from the Professor's Github
# link: https://github.com/kjmazidi/CS_2340/tree/master/Code%20Samples/3-Advanced%20MIPS%20Examples
# Example/Intended Output
# The array before: 	18 9 27 5 48 16 2 53 64 98 49 82 7 17 53 38 65 71 24 31 
# The array after: 	2 5 7 9 16 17 18 24 27 31 38 48 49 53 53 64 65 71 82 98 
# The mean is: 38.85
# The median is: 34.5
# The standard deviation is: 27.686735

	.data
error:		.asciiz		"Error. Exiting Program."
fileName:	.asciiz		"input.txt"
arrayBeforeMsg:	.asciiz		"The array before: 	"
arrayAfterMsg:	.asciiz		"The array after: 	"
meanMsg:	.asciiz		"The mean is: "
medianMsg:	.asciiz		"The median is: "
deviationMsg:	.asciiz		"The standard deviation is: "
space:		.asciiz		" "
newLine:	.asciiz		"\n"
buffer:		.space		80
byteCount:	.word		0
arrayLength:	.word		0
medianInt:	.word		0
medianFloat:	.float		0
deviation:	.word		0
mean:		.float		0
array:		.space		20
	
	.text
main:
	# Jump to readFile
	la	$a0, fileName
	la	$a1, buffer	# Storing the address of filename and the buffer
	jal	readFile
	sw	$v0, byteCount	# Storing byte count into the proper variable
	
	# Printing out byteCount to see if byte count is right
	#li	$v0, 1
	#lw	$a0, byteCount
	#syscall
	
	# Checking if $v0 <= 0, if so then jump to errorExit
	ble	$t1, $0, errorExit
	
	# Jump to extractInt
	la	$a0, array
	li	$a1, 20
	la	$a2, buffer
	jal	extractInt
	sw	$v0, arrayLength
	
######### Printing out header for Initial Array
	li	$v0, 4
	la	$a0, arrayBeforeMsg
	syscall
	
	# Jump to printArray
	la	$a0, array
	la	$a1, arrayLength
	jal	printArray
	
	# Print new line
	li	$v0, 4
	la	$a0, newLine
	syscall
	
######### Jump to sortArray
	la	$a0, array
	la	$a1, arrayLength
	jal	sortArray
	
######### Printing out header for Sorted Array
	li	$v0, 4
	la	$a0, arrayAfterMsg
	syscall
	
	# Jump to printArray
	la	$a0, array
	la	$a1, arrayLength
	jal	printArray
	
	# Print new line
	li	$v0, 4
	la	$a0, newLine
	syscall
	
######### Printing out header for Mean
	li	$v0, 4
	la	$a0, meanMsg
	syscall
	
	# Jump to calcMean
	la	$a0, array
	#la	$a1, arrayLength
	jal	calcMean
	
	# Printing out Mean
	li	$v0, 2		# Printing out mean
	swc1	$f12, mean	
	syscall
	
	# Print new line
	li	$v0, 4
	la	$a0, newLine
	syscall
	
######### Printing out header for Median
	li	$v0, 4
	la	$a0, medianMsg
	syscall
	
	# Jump to printArray
	la	$a0, array
	la	$a1, arrayLength
	jal	calcMedian
	
	beq	$v1, 1, printInt	# Checking if the median is an int or float
	
	# Print float median
	li	$v0, 2		
	swc1	$f12, medianFloat	
	syscall
	j	continueMain
	
printInt: # Print integer median
	move	$a0, $v0
	li	$v0, 1			
	syscall
	j	continueMain

continueMain:	
	# Print new line
	li	$v0, 4
	la	$a0, newLine
	syscall
	

######### Printing out header for Standard Deviation
	li	$v0, 4
	la	$a0, deviationMsg
	syscall
	
	# Jump to calcDeviation
	la	$a0, array
	la	$a1, arrayLength
	jal	calcDeviation
	
	# Printing out Mean
	li	$v0, 2		# Printing out Standard Deviation
	swc1	$f12, deviation	
	syscall
	
	# Print new line
	li	$v0, 4
	la	$a0, newLine
	syscall
	
	# Jump to exit because program is done
	j	exit

errorExit:
	la	$a0, error
	li	$v0, 4
	syscall
exit:
	li	$v0, 10		# Exit program
	syscall

# Reads the text from the input file
# Places the input in a buffer of 80 bytes
# Before calling this function set $a0 = address of filename, $a1 = address of the buffer
# Should return the number of bytes read in $v0
# When back in main, print an error message and terminate the program if $v0 <= 
# Code used from Professor's github for this function
readFile:
	
	# Open (for reading) a file that hopefully exists
 	li	$v0, 13       # system call for open file
	li	$a1, 0        # Open for reading (flags are 0: read, 1: write)
	li	$a2, 0        # mode is ignored
 	syscall            # open a file (file descriptor returned in $v0)
 	ble	$v0, $0, errorExit    # $v0 <= 0, exit because of error, not sure if I needed this or not
 	move	$s6, $v0      # save the file descriptor 
 	
 	# read from file just opened
 	li	$v0, 14		# system call for file read
 	move	$a0, $s6	# file descriptor 
 	la	$a1, buffer	# address of buffer to read into
 	li	$a2, 80 	# hardcoded buffer length
 	syscall			# read from file
 	move	$t1, $v0	# Saving the number of bytes read
 	
 	# Close the file 
	li   $v0, 16		# system call for close file
	move $a0, $s6		# file descriptor to close
	syscall			# close file
	
	# Returning number of bytes read in $v0
	move $v0, $t1		# putting number of bytes read back into $v0
	jr	$ra		# jump back to jal


# Function extracts integers from the text input buffer and stores them in an array of 20 words
# Before calling this function set $a0 = address of the array, $a1 = 20,
# $a2 = address of where the buffer starts
# In order to extract the integers from the buffer, load each byte in one by one
# Ignore the byte if, byte < 48 decimal, or 30 hex(0 ASCII) or > 57 decimal, or 39 hex (ASCII for 9)
# Just check the decimals, it'll probably be easier for you this way
# Subtract 48 to convert from ASCII to int
# Multiply the register as an accumulator by 10, then add the digit
# When you load in a byte that is equal to 10, this is newline, you are done with converting the integer
# Save the integer into the next array element
# When you load a byte that is equal to zero, you have reached the end of the data
extractInt:
	li	$s1, 0			# Setting accumulator to 0
	li	$t0, 0			# Creates index of the array
loopInt:
	lb 	$t1, ($a2)		# Loading the first byte
	beq	$t1, 10, storeInt	# if ($t1 == 10), byte is a newline, conversion is done
	beq	$t1, $0, returnInts	# if ($t1 == 0), end of data is reached, jump back to main
	blt	$t1, 48, nextInt	# if ($t1 < 48), ignore byte
	bgt	$t1, 57, nextInt	# if ($t1 > 57), ignore byte
	add	$t1, $t1, -48		# Subtracting 48 to convert from ASCII to int
	mul	$s1, $s1, 10		# Multiply the register by 10
	add	$s1, $s1, $t1		# Adding converted value
nextInt:
	add	$a2,$a2,1		# Incrimenting to the next byte
	j	loopInt			# Going back to beginning of loop
storeInt:
	mul	$t2,$t0,4		# Index * 4, moves the values over byte? by byte?
	add	$t2, $t2, $a0		# setting $t2 to the address of where to store the integer
	sw	$s1, ($t2)		# Storing decimal
	li	$s1, 0			# Setting accumulator to 0
	add	$t0,$t0,1		# Increment array index
	add	$a2,$a2,1		# Increment to next byte
	j	loopInt
returnInts:
	move	$v0, $t0		# Return $t0 because it will be the length of the array from now on
	jr	$ra			# Jump back to jal

# Function prints the array of ints as shown in the sample output
# Print the array before you sort and then after sort, with appropriate text messages
printArray:
	move	$t2, $a0		# Saving array address
	li 	$t0, 0			# Setting array index to 0
	lb	$t8, arrayLength	# Loading in array length
loopPrint:
	beq	$t0,$t8,returnPrint	# Check if the end of the array has been reached
	# Printing integer
	li	$v0, 1
	mul	$t1, $t0, 4		# Index * 4
	add	$t1, $t1, $t2
	lw	$a0, ($t1)		# Loading integer
	syscall				# Print integer
	# Printing space
	li	$v0, 4
	la	$a0, space
	syscall				# Print space
	add	$t0, $t0, 1		# Increment index by 1 (i++)
	j	loopPrint
returnPrint:
	jr	$ra			# jump back to jal

# Function sorts array by selection sort
# Use the algorithm from any textbook or https://en.wikipedia.org/wiki/Selection_sort
sortArray:
	li	$t0, 0			# Setting index for outer loop to zero
	lb	$t8, arrayLength	# Loading in array length
	sub	$s0, $t8, 1 		# Setting $s0 to the cap of the outer loop
loopSortOuter:
	beq	$t0, $s0, returnSort	# Checking if the sort is done
	move	$s1, $t0		# Saving the index of the minimum value
	add	$t1, $t0, 1		# Setting the index for the inner loop
loopSortInner:
	beq	$t1, $t8, ifSwap	# If the inner loop is done, check to see if swap can be done
	mul	$t2, $t1, 4
	mul	$t3, $s1, 4
	add	$t2, $t2, $a0
	add	$t3, $t3, $a0
	lw	$t4, ($t2)
	lw	$t5, ($t3)
	blt	$t4, $t5, setMinIndex	# if the value at index $t0 is less than value at index $t1
	j	incrementInner
setMinIndex: # Setting the index of the minimum to a new one, if a new minimum is found
	move	$s1, $t1
incrementInner:
	add	$t1, $t1, 1
	j	loopSortInner
ifSwap:
	bne	$s1, $t0, swap		# swap if the value at the outerIndex < value at minIndex
	j	incrementOuter
swap:
	mul	$t2, $t0, 4
	mul	$t3, $s1, 4
	add	$t2, $t2, $a0
	add	$t3, $t3, $a0
	lw	$t4, ($t2)
	lw	$t5, ($t3)
	sw	$t4, ($t3)
	sw	$t5, ($t2)
incrementOuter:
	add	$t0, $t0, 1
	j	loopSortOuter

returnSort:
	jr	$ra		# jump back to jal

# Before calling the functions below: set $a0 to the start of the array
# $a1 to the length of the array
# Return integer values in $v0 and float values in one of the $f registers

# Calculates the mean with single precision and stores it into memory as a float
calcMean:
	li	$t0, 0		# Setting loop index
	li	$t6, 0		# Setting accumulator
	lb	$t8, arrayLength	# Loading in array length
	
meanLoop: # Adding all the values in the array
	mul	$t2, $t0, 4
	add	$t2, $t2, $a0
	lw	$t4, ($t2)
	add	$t6, $t6, $t4
	add	$t0, $t0, 1
	beq	$t0,$t8,returnMean
	j	meanLoop
returnMean:
	# Divide the value of $t6 by value of length of array, then store in a float and return it
	mtc1	$t6, $f0
	cvt.s.w	$f0, $f0
	mtc1	$t8, $f1
	cvt.s.w	$f1, $f1
	div.s	$f12, $f0, $f1
	jr	$ra		# jump back to jal

# Calculates the median.
# If the array length is odd, return the middle value as an integer
# If the array length is even, return the median as a float.
# Set $v1 to be a flag to indicate whether the result was int or float
# so you can use the appropriate syscall in main
# $a0 - address of array, $a1 - length of array
calcMedian:
	li	$t0, 0			# Setting loop index
	li	$t5, 0			# Setting accumulator to 0
	lb	$t8, arrayLength	# Loading in array length
checkMedian:
	div	$t1, $t8, 2		# Determining if the array length is odd or even
	mfhi	$t2			# Acquiring Median
	beq	$t2, 1, returnOddMedian	# Checks if the array is odd
	
	# Array length is even, so we must calculate and return a floating point
	# Adding the two middle values together
	mul	$t3, $t1, 4
	add	$t3, $t3, $a0
	lw	$t4, ($t3)
	add	$t5, $t5, $t4
	sub	$t1, $t1, 1
	mul	$t3, $t1, 4
	add	$t3, $t3, $a0
	lw	$t4, ($t3)
	add	$t5, $t5, $t4
	
	# Converting to float
	li	$t8, 2		# Loading in 2, for division
	mtc1	$t5, $f0
	cvt.s.w	$f0, $f0
	mtc1	$t8, $f1
	cvt.s.w	$f1, $f1
	div.s	$f12, $f0, $f1
	
	# Return median float
	li	$v1, 0		# Setting print check
	jr	$ra		# Jump back to jal
returnOddMedian:
	mul	$t3, $t1, 4
	add	$t3, $t3, $a0
	lw	$v0, ($t3)
	li	$v1, 1		# Setting print check
	jr	$ra		# jump back to jal

# Calculates the standard deviation
# Remember that there is a sqrt.s instruction in MARS
# When in main save the standard deviation and print it
# $a0 is the array, $a1 is the arrayLength, $a2 is the mean
calcDeviation:
	li	$t0, 0			# Setting loop index
	lb	$t2, arrayLength	# Saving the array length
	sub	$t2, $t2, 1		# creating n - 1
	mtc1	$t2, $f3
	cvt.s.w	$f3, $f3		# Converting array length to float
	lwc1	$f0, mean		# Saving mean
	mtc1	$0, $f12		# Setting accumulator to 0
loopDeviation:
	beq	$t0, 20, returnDeviation	# Checking if the sort is done
	mul	$t3, $t0, 4
	add	$t3, $t3, $a0
	lw	$t4, ($t3)		# Loading integer from the array at the array index
	mtc1	$t4, $f1
	cvt.s.w	$f1, $f1		# Convert value to float
	sub.s	$f2, $f1, $f0
	mul.s	$f2, $f2, $f2		# Squaring the result
	add.s	$f12, $f12, $f2
	add	$t0, $t0, 1		# Incrementing the loop
	j	loopDeviation
returnDeviation:
	div.s	$f12, $f12, $f3		# Dividing the accumulator by the array length
	sqrt.s	$f12, $f12		# Taking the square root of the value

	jr	$ra		# jump back to jal
