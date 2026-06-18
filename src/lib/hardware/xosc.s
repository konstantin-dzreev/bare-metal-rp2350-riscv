.section .text

.include "include/hardware/regs/addressmap.inc"
.include "include/hardware/regs/xosc.inc"

# Function: xosc_start
# Description: Starts the external crystal oscillator (XOSC) and waits
#              until it reports a stable output.
#
#              The oscillator startup delay is configured before
#              enabling the XOSC. Execution does not return until the
#              STABLE status bit is asserted.
#
#              P.S. The datasheet-recommended value of 47 (~1 ms) for
#              STARTUP delay causes unreliable startup on some Pico 2
#              of my boards.
#
# Inputs:
#   none
#
# Outputs:
#   none
#
# Clobbers:
#   t0, t1, t2
#
.globl	xosc_start
xosc_start:
	li	t0, XOSC_BASE

	li	t1, 188				# configure startup delay: 12 MHz × 4 ms ÷ 256 ≈ 188.
	sw	t1, XOSC_STARTUP_OFFSET(t0)

	li	t1, (XOSC_CTRL_ENABLE_VALUE_ENABLE << XOSC_CTRL_ENABLE_LSB) | XOSC_CTRL_FREQ_RANGE_VALUE_1_15MHZ
	sw	t1, XOSC_CTRL_OFFSET(t0)		# enable the crystal oscillator in the 1-15 MHz frequency range

	li	t1, XOSC_STATUS_STABLE_BITS
1:	lw	t2, XOSC_STATUS_OFFSET(t0)		# wait until the XOSC stabilizes
	and	t2, t2, t1
	beqz	t2, 1b
	ret
