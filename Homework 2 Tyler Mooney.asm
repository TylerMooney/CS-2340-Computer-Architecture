# Author: Tyler Mooney
# Date: September 13th, 2020
# Professor: Karen Mazidi
# Assignment: Homework 2: MIPS Control Structures
# Purpose: Prompt user with a dialog box to enter some text,
# then count how many characters and words are in the text
# Notes: You can click the question mark at the top to see the syscall requirements
# Just a label then a jump

	.data
intro:	.asciiz		"Enter some text: "
outro:	.asciiz		"Exiting Program"
wordmsg:.asciiz		" words "
charmsg:.asciiz		" characters\n"
empty:	.asciiz		""
wordcnt:.word		0
charcnt:.word		0
word:	.space		100 # max of 100
length:	.word		100 # Is just used as an arguement
		
	.text
	# Print out prompt in dialouge box and acquire text
main:
	li	$v0, 54		# print dialouge box
	la	$a0, intro
	la	$a1, word
	li	$a2, 100	
	syscall
	
	# Jump to Count Function
	bne	$a1, $0, exit
	la	$a1, word
	jal	count
	sw	$v1, wordcnt
	sw	$v0, charcnt
	
	# Printing out acquired text and results
	li	$v0, 4		# Printing out User Text
	la	$a0, word
	syscall
	
	li	$v0, 1		# Printing out wordcnt
	lw	$a0, wordcnt
	syscall
	
	li	$v0, 4		# Printing out wordmsg
	la	$a0, wordmsg
	syscall
	
	li	$v0, 1		# Printing out charcnt
	lw	$a0, charcnt
	syscall	
	
	li	$v0, 4		# Printing out charmsg
	la	$a0, charmsg
	syscall
	
	j	main		# We do a jump to main to repeat the program	
	
exit:
	la	$a0, outro
	la	$a1, empty	# Empty string in order to use syscall 59
	li	$v0, 59
	syscall
	
	li	$v0, 10		# Exit program
	syscall

############## COUNT FUNCTION ##################
# can loop through and count every chracter until you get to '\0'
# add up all the spaces you come across, then add +1 for the number of words in the text
# check: When you come across a '\0', check if the char or word count is zero
# If so, then jump to exit
# If not, then return the number of words and characters to $v0, $v1 (store in memory)
count:
	li	$t2, 0		# charcnt
	li	$t3, 1		# wordcnt already at 1 because we will always +1
	addi	$sp, $sp, -4
	sw	$s1, ($sp)	# save $s0 (push)

loop:
	lbu	$s1, ($a1)
	beq	$s1, $0, return	# if(x[i] == '\0') exit
	beq	$s1, '\n', return	# if(x[i] == '\n') return
	addi	$t2, $t2, 1	# incriment charcnt
	addi	$a1, $a1, 1	# incriment i
	bne	$s1, ' ', loop	# if(x[i] != ' ') loop
	addi	$t3, $t3, 1	# Incriment wordcnt
	j	loop

# Returns $v0, $v1
return:
	move	$v0, $t2
	move	$v1, $t3
	lw	$s1, ($sp)	# restore $s0 (pop)
	addi	$sp, $sp, 4
	jr	$ra		# jump back to jal

