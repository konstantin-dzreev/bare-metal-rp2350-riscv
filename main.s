# 2.1.3. Atomic Register Access
.equ	ATOMIC_CLEAR, 0x3000

# 7. Resets
.equ	RESETS_BASE, 0x40020000
.equ	RESET_DONE, 0x08

# 9. GPIO
.equ	IO_BANK0_BASE, 0x40028000
.equ	GPIO25_CTRL, 0x0cc

# 3.1. SIO
.equ	SIO_BASE, 0xd0000000
.equ	GPIO_OE_SET, 0x038
.equ	GPIO_OUT_SET, 0x018
.equ	GPIO_OUT_CLR, 0x020

# 9. GPIO
.equ 	PADS_BANK0_BASE, 0x40038000
.equ	PADS_BANK0_GPIO25, 0x68

.equ	big_number, 0x00080000


.section .text
.global	_start
.align	4

_start:
	li	a0, RESETS_BASE + ATOMIC_CLEAR
	li	a2, 1<<6 | 1<<9    # PADS_BANK0 and IO_BANK0
	sw	a2, (a0)	

start:
	li	a0, RESETS_BASE
	lw	a1, RESET_DONE(a0)
	and	a1, a1, a2
	bne	a1, a2, start

	li	a0, IO_BANK0_BASE + GPIO25_CTRL
	li	a1, 5
	sw	a1, (a0)

	li	a0, SIO_BASE
	li	a1, 1<<25
	sw	a1, GPIO_OE_SET(a0)

	# Non-SDK applications ported from RP2040 must clear the ISO bit before using a GPIO, as this feature was not
	# present on RP2040. The SDK automatically clears the ISO bit when gpio_set_function() is called.
	# 9.7. Pad Isolation Latches
	li	a4, 1<<7 | 1<<8
	li	a5, PADS_BANK0_BASE + PADS_BANK0_GPIO25 + ATOMIC_CLEAR
	sw	a4, (a5)

led_loop:
	# LED on
	sw	a1, GPIO_OUT_SET(a0)
	jal	pause

	# LED off
	sw	a1, GPIO_OUT_CLR(a0)
	jal	pause

	# Loop
	j	led_loop

pause:
	li	t0, big_number
1:	addi	t0, t0, -1
	bnez	t0, 1b
	ret
