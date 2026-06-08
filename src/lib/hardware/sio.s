.include "include/hardware/regs/addressmap.inc"
.include "include/hardware/regs/sio.inc"

# Function: sio_gpio_set_output_enable_mask
# Description: Enables GPIO output drivers for one or more GPIOs by
#              setting bits in the SIO GPIO_OE register.
#
# Inputs:
#   a0 = GPIO bitmask
#
# Outputs:
#   none
#
# Clobbers:
#   t0
#
.globl	sio_gpio_set_output_enable_mask
sio_gpio_set_output_enable_mask:
	li	t0, SIO_BASE
	sw	a0, SIO_GPIO_OE_SET_OFFSET(t0)	# enable output drivers for selected GPIOs
	ret


# Function: sio_gpio_enable_output
# Description: Enables the output driver for a GPIO pin.
#
# Inputs:
#   a0 = GPIO number
#
# Outputs:
#   none
#
# Clobbers:
#   t0
#
.globl	sio_gpio_enable_output
sio_gpio_enable_output:
	addi	sp, sp, -8
	sw	ra, 0(sp)
	sw	a0, 4(sp)

	li	t0, 1
	sll	a0, t0, a0			# convert GPIO number to GPIO bitmask
	call	sio_gpio_set_output_enable_mask

	lw	ra, 0(sp)
	lw	a0, 4(sp)
	addi	sp, sp, 8
	ret
