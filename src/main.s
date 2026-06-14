.section	.text
.align	2	# 4 bytes

.include "include/hardware/regs/rosc.inc"
.include "include/hardware/regs/ticks.inc"
.include "include/hardware/regs/timer.inc"

.include "src/lib/hardware/clocks.s"
.include "src/lib/hardware/io_bank0.s"
.include "src/lib/hardware/pads_bank0.s"
.include "src/lib/hardware/pll.s"
.include "src/lib/hardware/rvcsr.s"
.include "src/lib/hardware/reset.s"
.include "src/lib/hardware/sio.s"
.include "src/lib/hardware/ticks.s"
.include "src/lib/hardware/timer.s"
.include "src/lib/hardware/xosc.s"

.equ	big_number, 0x0000300000

.globl	_start
_start:
	#--------------------------
	# Interrupts
	#--------------------------

	call	rvcsr_disable_interrupts		# disable interrupts globally
	call	rvcsr_disable_all_machine_interrupts	# disable all machine-mode interrupts
	la	a0, vector_table_start		# vector table address
	call	rvcsr_set_mtvec_vectored_mode		# set vectored mode interrupts
	li	a0, RVCSR_MIE_MEIE_BITS		# external interrupts only
	call	rvcsr_enable_machine_interrupts	# enable machine interrupts (IRQs only)
	call	rvcsr_enable_interrupts		# enable interrupts globally

	li	a0, 0				# IRQ-0 (Timer0 Alarm0)
	call	rvcsr_enable_irq			# enable IRQ-0
	li	a0, 1				# IRQ-1 (Timer0 Alarm1)
	call	rvcsr_enable_irq			# enable IRQ-1

	#--------------------------
	# Activate periferals
	#--------------------------

	li	a0, RESETS_RESET_IO_BANK0_BITS | RESETS_RESET_PADS_BANK0_BITS | RESETS_RESET_TIMER0_BITS | RESETS_RESET_PLL_SYS_BITS
	call	unreset_subsystems

	#--------------------------
	# GPIO
	#--------------------------

	li	a0, 25				# GPIO 25
	li	a1, 5				# function 5: SIO_0
	call	io_bank0_set_gpio_function		# GPIO is controlled by SIO
	call	sio_gpio_enable_output		# allow SIO to drive the GPIO
	call	pads_bank0_enable_pad_output		# enable pad output and remove isolation
	li	a0, 0				# GPIO 0
	call	io_bank0_set_gpio_function
	call	sio_gpio_enable_output
	call	pads_bank0_enable_pad_output
	li	a0, 2				# GPIO 2
	call	io_bank0_set_gpio_function
	call	sio_gpio_enable_output
	call	pads_bank0_enable_pad_output

	#-------------------
	# Change ROSC freq (optional)
	#-------------------
	# li	a0, ROSC_BASE
	# li	a1, 0xFFF
	# lw	a2, ROSC_CTRL_OFFSET(a0)
	# andn	a2, a2, a1
	# #li	a3, ROSC_CTRL_FREQ_RANGE_VALUE_LOW
	# li	a3, ROSC_CTRL_FREQ_RANGE_VALUE_TOOHIGH
	# or	a2, a2, a3
	# sw	a2, ROSC_CTRL_OFFSET(a0)

	#--------------------------
	# Crystal oscillator (XOSC)
	# Pico-2 comes with 12Mhz
	#--------------------------

	call	xosc_start
	call	clocks_set_clk_ref_source_xosc
	call	clocks_set_clk_sys_source_clk_ref

	#--------------------------
	# PLL
	#--------------------------

	# Divider params for 48 MHz:
	#
	# $ cd pico-sdk
	# $ src/rp2_common/hardware_clocks/scripts/vcocalc.py 48
	#   Requested: 48.0 MHz
	#   Achieved:  48.0 MHz
	#   REFDIV:    1
	#   FBDIV:     120 (VCO = 1440.0 MHz)
	#   PD1:       6
	#   PD2:       5
	#
	li	a0, 1	# REFDIV
	li	a1, 120	# FBDIV
	li	a2, 6	# PD1
	li	a3, 5	# PD2
	# li	a0, 1	# REFDIV # 300 MHz
	# li	a1, 125	# FBDIV
	# li	a2, 5	# PD1
	# li	a3, 1	# PD2
	call	pll_sys_start

	#--------------------------
	# Clocks: set CLK_SYS to AUXILARY PLL
	#--------------------------

	call	clocks_set_clk_sys_aux_source_pll_sys
	call	clocks_set_clk_sys_source_aux

	#-------------------
	# Ticks: 
	#-------------------

	li	a0, 12			# every 1mks: 12 CLK_REF cycles at 12 MHz
	call	ticks_set_timer0_increment_cycles
	call	ticks_start_timer0

	#-------------------
	# Timer0
	#-------------------

	call	timer0_set_source_tick_generator

	li	a0, 0
	li	a1, 500000
	call	timer0_set_alarm_relative
	call	timer0_enable_alarm_interrupt

	li	a0, 1
	li	a1, 500000
	call	timer0_set_alarm_relative
	call	timer0_enable_alarm_interrupt

	#-------------------
	# Blink
	#-------------------

led_loop:	
	li	a0, 0
	call	sio_toggle_gpio
	call	pause
	j	led_loop

pause:	li	t0, big_number
1:	addi	t0, t0, -1
	bnez	t0, 1b
	ret
