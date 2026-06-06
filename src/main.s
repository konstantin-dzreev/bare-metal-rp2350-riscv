.include "include/hardware/regs/clocks.inc"
.include "include/hardware/regs/io_bank0.inc"
.include "include/hardware/regs/pads_bank0.inc"
.include "include/hardware/regs/rosc.inc"
.include "include/hardware/regs/rvcsr.inc"
.include "include/hardware/regs/sio.inc"
.include "include/hardware/regs/ticks.inc"
.include "include/hardware/regs/timer.inc"
.include "include/hardware/regs/xosc.inc"
.include "src/lib/reset.s"

.equ	big_number, 0x00400000

.section	.text
.global	_start
.align	2 # 4 bytes

_start:
	#-------------------
	# interrupts
	#-------------------

	li	t0, RVCSR_MSTATUS_MIE_BITS
	csrc	RVCSR_MSTATUS_OFFSET, t0		# disable interrupts globally

	csrw	RVCSR_MIE_OFFSET, zero		# disable all machine-mode interrupts

	la	t0, vector_table_start
	ori	t0, t0, RVCSR_MTVEC_MODE_VALUE_VECTORED	# configure vectored mode
	csrw	RVCSR_MTVEC_OFFSET, t0		# store vector table address

	li	t0, RVCSR_MIE_MEIE_BITS		# external interrupt bits
	csrw	RVCSR_MIE_OFFSET, t0		# enable external interrupts only

	li	t0, RVCSR_MSTATUS_MIE_BITS
	csrs	RVCSR_MSTATUS_OFFSET, t0		# enable interrupts globally

	#-------------------
	# Enable IRQ-0
	#-------------------

	li	t0, 0x00010000
	csrw	RVCSR_MEIEA_OFFSET, t0		# enable IRQ-0, Timer alarm 0


	# #-------------------
	# # Change ROSC freq (optional)
	# #-------------------
	# li	a0, ROSC_BASE
	# li	a1, 0xFFF
	# lw	a2, ROSC_CTRL_OFFSET(a0)
	# andn	a2, a2, a1
	# #li	a3, ROSC_CTRL_FREQ_RANGE_VALUE_LOW
	# li	a3, ROSC_CTRL_FREQ_RANGE_VALUE_TOOHIGH
	# or	a2, a2, a3
	# sw	a2, ROSC_CTRL_OFFSET(a0)

	#-------------------
	# Crystal oscillator (XOSC)
	# Pico-2 comes with 12Mhz one
	#-------------------

	li	t0, XOSC_BASE

	# 8.2.4. Startup delay
	li	t1, 100			# ~2ms. P.S. With the recommended 1ms delay: (12Mhz * 1ms) / 256 = 47 my pico-2 fails to start in 50% cases 
	sw	t1, XOSC_STARTUP_OFFSET(t0)

	# Start the XOSC
	li	t1, (XOSC_CTRL_ENABLE_VALUE_ENABLE << XOSC_CTRL_ENABLE_LSB) | XOSC_CTRL_FREQ_RANGE_VALUE_1_15MHZ
	sw	t1, XOSC_CTRL_OFFSET(t0)

.L_wait_for_stable_xosc:
	lw	t1, XOSC_STATUS_OFFSET(t0)
	li	t2, XOSC_STATUS_STABLE_BITS
	and	t1, t1, t2
	beqz	t1, .L_wait_for_stable_xosc

	# Switch CLK_REF clock to use XOSC
	li	t0, CLOCKS_BASE
	li	t1, CLOCKS_CLK_REF_CTRL_SRC_VALUE_XOSC_CLKSRC
	sw	t1, CLOCKS_CLK_REF_CTRL_OFFSET(t0)

.L_wait_for_clk_ref_to_switch:
	lw	t2, CLOCKS_CLK_REF_SELECTED_OFFSET(t0)
	li	t1, 1 << CLOCKS_CLK_REF_CTRL_SRC_VALUE_XOSC_CLKSRC
	and	t2, t2, t1
	beqz	t2, .L_wait_for_clk_ref_to_switch

	# Switch CLK_SYS  to use CLK_REF clock
	li	t1, CLOCKS_CLK_SYS_CTRL_SRC_VALUE_CLK_REF
	sw	t1, CLOCKS_CLK_SYS_CTRL_OFFSET(t0)

.L_wait_for_clk_sys_to_switch:
	lw	t2, CLOCKS_CLK_SYS_SELECTED_OFFSET(t0)
	li	t1, 1 << CLOCKS_CLK_SYS_CTRL_SRC_VALUE_CLK_REF
	and	t2, t2, t1
	beqz	t2, .L_wait_for_clk_sys_to_switch

	#-------------------
	# Activate periferals
	#-------------------

	li	a0, RESETS_RESET_IO_BANK0_BITS | RESETS_RESET_PADS_BANK0_BITS | RESETS_RESET_TIMER0_BITS
	call	unreset_subsystems

	#-------------------
	# Enable Timer Alarm
	#-------------------

	li	t0, TIMER0_BASE
	lw	t1, TIMER_TIMELR_OFFSET(t0)
	li	t2, 500000
	add	t1, t1, t2
	sw	t1, TIMER_ALARM0_OFFSET(t0)

	li	t2, TIMER_INTE_ALARM_0_BITS		# enable alarm interrupt
	sw	t2, TIMER_INTE_OFFSET(t0)

	#-------------------
	# Enable Timer0 Ticks: 8.5 Tick generators
	#-------------------

	li	t0, TICKS_BASE
	li	t1, TICKS_TIMER0_CTRL_ENABLE_BITS
	sw	t1, TICKS_TIMER0_CTRL_OFFSET(t0)


	# configure ticks to fire every 1 mks or every 12 SYS_CLK cycles at 12 MHz
	li	t1, 12
	sw	t1, TICKS_TIMER0_CYCLES_OFFSET(t0)

	#-------------------
	# GPIO
	#-------------------

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


#----------- HACK
	li	t0, SIO_BASE
	li	t1, 1 << 25
	sw	t1, SIO_GPIO_OUT_SET_OFFSET(t0)
#----------- HACK END

led_loop:

	# # LED on
	# sw	a1, SIO_GPIO_OUT_SET_OFFSET(a0)
	# call	pause

	# # LED off
	# sw	a1, SIO_GPIO_OUT_CLR_OFFSET(a0)
	# call	pause
	# call	pause
	# call	pause

	# Loop
	j	led_loop

pause:
	li	s0, big_number
1:	addi	s0, s0, -1
	bnez	s0, 1b
	ret
