.section .text
debug:
	imprimir:
		lw t0, 0(a2)
		addi a2, a2, 4
		sb t0, 0(a0)
		addi a6, a6, -1
		bne a6, zero, imprimir
	ret
print:
	li t6, 10	# const (int % 10)
	li t5, '-'	# char '-'
	or t2, a2, zero # string
	print_start:
		li t4, 1			# sign, 1 == positive number
		lw t0, 0(a1)			# load integer
		addi a1, a1, 4			# increment index
		blt t0, zero, handle_sign	# t0 < 0, negative number
		j int2string
	handle_sign:
		li t4, 0			# t4 == 0 print '-' sign
		neg t0, t0
		j int2string
	int2string:
		remu t3, t0, t6			# take the last digit t0 % 10
		addi t3, t3, '0'		# digit + '0'
		sb t3, 0(t2)			# store char in string
		addi t2, t2, 1			# increment index
		div t0, t0, t6			# shift left the last digit t0 / 10
		bne t0, zero, int2string	# loop to get all digits
	print_sign:
		beq t4, zero, print_minus
	print_rev:
		addi t2, t2, -1
		lb s0, 0(t2)
		sb s0, 0(a0)
		bne t2, a2, print_rev
		addi a6, a6, -1
		bne a6, zero, print_new
		j end_print
	print_new:
		li t0, ','
		sb t0, 0(a0)
		j print_start
	print_minus:
		sb t5, 0(a0)
		j print_rev
		
	end_print:
		ret
simple_sort:
	or s1, a6, zero
	or s0, a1, zero
	bubble_sort:
   		 addi t0, s1, -1       # t0 = size - 1 (outer loop counter)

	outer_loop:
    		li t1, 0             # t1 = i (inner loop index)
    		add t2, s1, zero
    		addi t2, t2, -1      # t2 = size - 1
    		beqz t0, done        # If outer loop counter is 0, sorting is done
	inner_loop:
    		slli t3, t1, 2       # t3 = i * 4 (word offset)
   		add t4, s0, t3       # t4 = &array[i]
   		lw t5, 0(t4)         # t5 = array[i]
   		lw t6, 4(t4)         # t6 = array[i+1]
    		ble t5, t6, no_swap  # If array[i] <= array[i+1], no swap
    		sw t6, 0(t4)         # Swap: store array[i+1] at array[i]
    		sw t5, 4(t4)         # Swap: store array[i] at array[i+1]
	no_swap:
    		addi t1, t1, 1       # Increment inner loop index
    		blt t1, t2, inner_loop  # If i < size - 1, continue inner loop
    		addi t0, t0, -1      # Decrement outer loop counter
    		j outer_loop         # Repeat outer loop
	done:
    		ret
getnumbers:
	or s0, a6, zero # number of numbers to be sorted
	li t3, 10	# const 10, append a zero
	li t4, '0'	# char '0'
	li t5, '9'	# char '9'
	li t6, '-'	# char '-'
	
	start_get:
		li t2, 0	# number
		lb t0, 0(a0)		# read char
		beq t0, t6, minus_sign	# minus sign == 0
		li t1, 1		# plus sign == 1
		j is_number
	minus_sign:
		li t1, 0
		j get_c
	get_c:
		lb t0, 0(a0)		# read a char
	is_number:
		blt t0, t4, not_number	# t0 < '0', not number
		blt t5, t0, not_number  # '9' > t0, not number
		sub t0, t0, t4		# sub char - '0'
		mul t2, t2, t3		# append a zero
		add t2, t2, t0		# add the new digit
		j get_c			# keep getting digits
	not_number:
		addi s0, s0, -1		# decrement count of numbers to read
		beq t1, zero, nnumber   # neg number if t1 == 0
		j save_number
	nnumber:
		neg t2, t2
		j save_number
	save_number:	
		sw t2, 0(a1)		# save number
		addi a1, a1, 4		# increment 4 bytes
		bne s0, zero, start_get # keep getting numbers if s0 != 0
	ret
getsort:
	li a6, 0
	li t6, '0'
	li t5, 10
	li t4, '\n'
	getsort_loop:
		lb t0, 0(a0)			# read char (ASCII)
		beq t0, t4, end_getsort		# break loop if t0 == '\n'
		sub t0, t0, t6			# sub char - '0', expecting a char 0-9
		mul a6, a6, t5			# append a zero
		add a6, a6, t0			# add the new digit
		j getsort_loop
	end_getsort:
		ret
.global main
main:
	# Prologue
  	addi sp, sp, -16
    	sw ra, 0(sp)
	# setting uart0
	li a0, 0x10000000 
	# get number of numbers to be sorted and store in a6
	call getsort
	# array address
	la a1, array
	addi a1, a1, 12
	# store numbers to sort in array
	call getnumbers
	# sort numbers
	la a1, array
	addi a1, a1, 12
	call simple_sort
	# print debug
	la a1, array
	addi a1, a1, 12
	la a2, string
	#call debug
	la a1, array
	addi a1, a1, 12
	la a2, string
	call print
	# Epilogue
    	lw ra, 0(sp)
    	addi sp, sp, 16
    	# Setting return value to zero (success)
   	li a0, 0
   	# Returning from call
  	ret
.section .data
array:
	.word 1003
string:
	.zero 11
