.include "include/hardware/regs/addressmap.inc"
.include "include/hardware/regs/io_bank0.inc"
.include "include/hardware/regs/pads_bank0.inc"
.include "include/hardware/regs/rosc.inc"
.include "include/hardware/regs/sio.inc"

.include "src/lib/reset.s"

.equ	big_number, 0x00100000

.section	.text
.global	_start
#.align	4

_start:
	# Change ROSC freq (optional)
	li	a0, ROSC_BASE
	li	a1, 0xFFF
	lw	a2, ROSC_CTRL_OFFSET(a0)
	andn	a2, a2, a1
	li	a3, ROSC_CTRL_FREQ_RANGE_VALUE_HIGH
	or	a2, a2, a3
	sw	a2, ROSC_CTRL_OFFSET(a0)

	# Activate IO_BANK0 and PADS_BANK0 subsystems
	li	a0, RESETS_RESET_IO_BANK0_BITS | RESETS_RESET_PADS_BANK0_BITS
	call	unreset_subsystems

	# GPIO25: select function SIO
	li	a0, IO_BANK0_BASE
	li	a1, IO_BANK0_GPIO25_CTRL_FUNCSEL_VALUE_SIOB_PROC_25
	sw	a1, IO_BANK0_GPIO25_CTRL_OFFSET(a0)

	# GPIO25: enable output
	li	a0, SIO_BASE
	li	a1, 1 << 25
	sw	a1, SIO_GPIO_OE_SET_OFFSET(a0)

	# GPIO25: clear output disable and isolation bits on its pad
	li	a4, PADS_BANK0_GPIO25_OD_BITS | PADS_BANK0_GPIO25_ISO_BITS 
	li	a5, PADS_BANK0_BASE + REG_ALIAS_CLR_BITS
	sw	a4, PADS_BANK0_GPIO25_OFFSET(a5)

led_loop:
	# LED on
	sw	a1, SIO_GPIO_OUT_SET_OFFSET(a0)
	call	pause

	# LED off
	sw	a1, SIO_GPIO_OUT_CLR_OFFSET(a0)
	call	pause

	# Loop
	j	led_loop

pause:
	li	t0, big_number
1:	addi	t0, t0, -1
	bnez	t0, 1b
	ret
