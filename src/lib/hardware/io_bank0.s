.include "include/hardware/regs/addressmap.inc"
.include "include/hardware/regs/io_bank0.inc"

# Function: io_bank0_select_function
# Description: Selects the function of a GPIO pin by writing the
#              GPIO control register in IO_BANK0.
#
# Inputs:
#   a0 = GPIO number
#   a1 = GPIO function value (FUNCSEL field)
#
# Outputs:
#   none
#
# Clobbers:
#   t0, a0
#
.global	io_bank0_set_gpio_function
io_bank0_set_gpio_function:
	li	t0, IO_BANK0_BASE
	sll	a0, a0, 3				# convert GPIO number to GPIO register offset (8 bytes per register)
	add	a0, a0, t0			# compute GPIO register base address
	sw	a1, IO_BANK0_GPIO0_CTRL_OFFSET(a0)	# select GPIO function
	ret
