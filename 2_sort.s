.section .text
print:
     	or a4, a3, zero          # Set a4 = a3, copy the buffer address (a3 contains the buffer limit address)

	li t5, -1
	li t6, 1
     	li t1, 10                # Load 10 into t1 (used as the base for division, i.e., decimal base)
	read_number:
    		lw t0, 0(a2)            	 # Load the number from the memory address in a2 into t0
     		addi a2, a2, 4          	 # Increment the memory pointer in a2 (4 bytes per integer)
     		addi a1, a1, -1   	      	 # Decrement the counter in a1 (one number has been read)
     		blt t0, zero, handle_negative 	 # If the number is negative, jump to handle_negative

	save_number:
		remu t2, t0, t1		# Calculate remainder (t0 % 10) to get the least significant digit
     		addi t2, t2, '0'	# Convert the remainder (digit) into its ASCII character ('0' is added)
     		sb t2, 0(a4)		# Store the ASCII character at the buffer address pointed by a4
     		addi a4, a4, 1		# Move the buffer pointer (a4) to the next byte

     		div t0, t0, t1			# Divide t0 by 10 (shifting the decimal point left)
     		bne t0, zero, save_number	# If t0 is not zero, repeat the process for the next digit

		beq t6, zero, print_sign
     		j print_number	# Jump to print_number after all digits are processed

	handle_negative:
     		li t6, 0
		beq t0, t5, save_number
		sub t0, zero, t0
     		j save_number	# Jump to save_number to handle the absolute value of the number

	print_sign:
		li t6, '-'
		sb t6, 0(a0)
	print_number:
		addi a4, a4, -1
		lb t0, 0(a4)
		sb t0, 0(a0)
		bne a4, a3, print_number
		beq a1, zero, end_print
		li t0, ','
		sb t0, 0(a0)
		li t0, ' '
		sb t0, 0(a0)
		j read_number
	end_print:
     		ret	# Return from the function
simple_sort:
	# array size
	or a4, a1, zero
	# array
	or a5, a2, zero
	
	li a6, 4         # size of one element (4 bytes for integer)
	
	# i
	li t0, 0
	first_loop:
		# j = i+1
		addi t1, t0, 1
	second_loop:
		# Calculate (array + i) -> t2 and *(array + i) -> t3
		mul t2, t0, a6
		add t2, t2, a5
		lw t3, 0(t2)
		# Calculate (array + j) -> t4 and *(array + j) -> t5
		mul t4, t1, a6
		add t4, t4, a5
		lw t5, 0(t4)
		# Compare *array[i] and *array[j]
		blt t3, t5, no_swap
		# Swap if t3 > t5
		sw t5, 0(t2)
		sw t3, 0(t4)
	
	no_swap:
		# increment j and check loop condition
		addi t1, t1, 1
		blt t1, a4, second_loop
	
		addi t6, a4, -1
		# increment i and check loop condition
		addi t0, t0, 1
		blt t0, t6, first_loop
	
	ret
getnumber:
	li t6, 0
	li t1, 10  # 10
	li t2, '0' # char '0'
	li t3, '9' # char '9'

	lb t0, 0(a0)
	# sign?
	li t4, '-'
	beq t0, t4, minus
	li t4, '+'
	beq t0, t4, plus
	j is_number

	# t4 == 0 -> negative number || t4 != 0 -> positive number
	minus:
		li t4, 0
		j get_c
	plus:
		li t4, 1
		j get_c
	get_c:
		lb t0, 0(a0)
		beq t0, zero, not_number
	is_number:
		# is number?
		blt t0, t2, not_number
		blt t3, t0, not_number
		# char t0 - '0'
		sub t0, t0, t2
		# append a zero
		mul t6, t6, t1
		# adding
		add t6, t6, t0
		j get_c
	not_number:
		# sign?
		beq t4, zero, neg_number
		j end
	neg_number:
		sub t6, zero, t6
	end:
		ret
.global main
main:
	# prologue
	addi sp, sp, -16
	sw ra, 0(sp)
	# Setting UART0address
	li a0, 0x10000000
	# call getnumber
	call getnumber
	# store number of numbers to be sorted
	or a1, t6, zero
	# array of numbers to be sorted
	la a2, array
	# t5 = a1
	or t5, a1, zero
	# get numbers to be sorted
	getnumber_sort:
		# get number
		call getnumber
		addi t5, t5, -1
		# store number
		sw t6, 0(a2)
		addi a2, a2, 4
		bne t5, zero, getnumber_sort
	sort:
		la a2, array
		call simple_sort
	rev_print:
		la a2, array
		la a3, string
		call print
	return:
	# epilogue
	lw ra, 0(sp)
	addi sp, sp, 16
	li a0, 0
	ret
.section .data
array:
	.word 1000
string:
	.zero 12
