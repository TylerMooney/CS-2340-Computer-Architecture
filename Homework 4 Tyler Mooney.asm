# Author: Tyler Mooney
# Date: October 9th, 2020
# Professor: Karen Mazidi
#
# Purpose: Program creates a square made of pixels with the marquee
# effect occuring with various colors displayed in the Bitmap Display Tool. 
# The user should be able to make inputs in the Keyboard and Display MMIO Simulator
# Specifically movement of the sqare, such as w = up, d = right, s = down, a = left,
# and when space is clicked the program will exit
#
# Notes:
# The reason for using so many jumps and not jals
# is because I couldn't figure out a way to write the code
# where the jal wouldn't be overwritten by a needed function call
# So I determined the only place that needs jals is during keyboard input
# Code base taken from professor's gitbhub
# Specific file used was Bitmap Demo Program 2
#
# Instructions: 
#   Connect bitmap display:
#         set pixel dim to 4x4
#         set display dim to 256x256
#	use $gp as base address
#   Connect keyboard and run
#	use w (up), s (down), a (left), d (right), space (exit)
#	all other keys are ignored

# set up some constants
# width of screen in pixels
# 256 / 4 = 64
.eqv WIDTH 64
# height of screen in pixels
.eqv HEIGHT 64
# colors
.eqv	RED 	0x00FF0000
.eqv	GREEN	0x0000FF00
.eqv	BLUE	0x000000FF
.eqv	WHITE	0x00FFFFFF
.eqv	YELLOW	0x00FFFF00
.eqv	CYAN	0x0000FFFF
.eqv	MAGENTA	0x00FF00FF

	.data
# Creation of an array holding all the color values
colors:	.word	RED, GREEN, BLUE, WHITE, YELLOW, CYAN, MAGENTA, -1


	.text
main:
	# set up starting position
	addi 	$a0, $0, WIDTH    # a0 = X = WIDTH/2
	sra 	$a0, $a0, 1
	addi 	$a1, $0, HEIGHT   # a1 = Y = HEIGHT/2
	sra 	$a1, $a1, 1
	li	$t5, 0		# Loading color array index
	la	$t7, colors	# Saving address of the colors array
	
loop:	
	li	$t2, 0		# Loading index variable
	move	$t3, $a0	# Setting the X value to a temporary value
	move	$t4, $a1	# Setting the Y value to a temporary value
	
box_draw:
	beq	$t1, 1, draw	# Checking if the square is being moved
draw_color:	j	color_get	# This induces the marquee effect on the square when inside the drawing box function
draw:	j	draw_pixel		# Calls function to draw pixels
check:
	blt	$t2, 7, box_top		# Check if top side of box is being made
	blt	$t2, 14, box_right	# Check if right side of box is being made
	blt	$t2, 21, box_bottom	# Check if bottom side of box is being made
	blt	$t2, 28, box_left	# Check if left side of box is being made
	beq	$t1, 1, move		# Check if square is moving
	j	continue		# if not keep rotating the colors
move:	
	li	$t1, 0		# Reset the input check
	jr	$ra		# Return to jal
	
box_top:
	addi	$t3, $t3, 1	# Incrimenting X (moves pixel to the right)
	addi	$t2, $t2, 1	# Incrimenting index
	j	box_draw
box_right:
	addi	$t4, $t4, 1	# Incrimenting Y (moves pixel down)
	addi	$t2, $t2, 1	# Incrimenting index
	j	box_draw
box_bottom:
	subi	$t3, $t3, 1	# Decrementing X (moves pixel to the left)
	addi	$t2, $t2, 1	# Incrimenting index
	j	box_draw
box_left:
	subi	$t4, $t4, 1	# Decrementing Y (moves pixel up)
	addi	$t2, $t2, 1	# Incrimenting index
	j	box_draw

continue:
	# check for input
	lw $t0, 0xffff0000  #s1 holds if input available
    	beq $t0, 0, loop   #If no input, keep displaying
	
	# process input
	lw 	$s1, 0xffff0004
	beq	$s1, 32, exit	# input space
	beq	$s1, 119, up 	# input w
	beq	$s1, 115, down 	# input s
	beq	$s1, 97, left  	# input a
	beq	$s1, 100, right	# input d
	# invalid input, ignore
	j	loop
	
	# process valid input
up:	
	li	$t1, 1		# Setting check to true, in order to erase the box
				# and jump back to the jal
	li	$a2, 0		# black out the box
	jal	loop
	addi	$a1, $a1, -1	# move box up
	j	loop

down:	
	li	$t1, 1		# Setting check to true, in order to erase the box
				# and jump back to the jal
	li	$a2, 0		# black out the box
	jal	loop
	addi	$a1, $a1, 1	# move box down
	j	loop
	
left:	
	li	$t1, 1		# Setting check to true, in order to erase the box
				# and jump back to the jal
	li	$a2, 0		# black out the box
	jal	loop
	addi	$a0, $a0, -1	# move box left
	j	loop
	
right:	
	li	$t1, 1		# Setting check to true, in order to erase the box
				# and jump back to the jal
	li	$a2, 0		# black out the box
	jal	loop
	addi	$a0, $a0, 1	# move box right
	j	loop
		
exit:	li	$v0, 10
	syscall

#################################################
# Method will change the color inputted
# $t5 is the color array's index value
color_get:
	move	$t8, $a0	# Storing value in $a0
	# Creating a pause
	li	$v0, 32
	li	$a0, 5		# pause is 5ms
	syscall
	move	$a0, $t8	# Putting the value back

	mul	$t6, $t5, 4		# Index * 4
	add	$t6, $t6, $t7		# Acquiring address of array element
	lw	$a2, ($t6)		# Loading integer
	beq	$a2, -1, color_reset	# Checking if end of array was reached
	addi	$t5, $t5, 1		# index++
	j	draw
	
# Method resets the color array index and address holder
color_reset:
	move	$t6, $0		# resetting accumulator
	move	$t5, $0		# resetting index
	j color_get
	
#################################################
# subroutine to draw a pixel
# $a0 = X
# $a1 = Y
# $a2 = color
draw_pixel:
	# s1 = address = $gp + 4*(x + y*width)
	mul	$t9, $t4, WIDTH   # y * WIDTH
	add	$t9, $t9, $t3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	j	check
