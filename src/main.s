.section	.text
.align	2	# 4 bytes

.include	"src/lib/hardware/clocks.s"
.include	"src/lib/hardware/io_bank0.s"
.include	"src/lib/hardware/pads_bank0.s"
.include	"src/lib/hardware/pll.s"
.include	"src/lib/hardware/rvcsr.s"
.include	"src/lib/hardware/reset.s"
.include	"src/lib/hardware/sio.s"
.include	"src/lib/hardware/ticks.s"
.include	"src/lib/hardware/timer.s"
.include	"src/lib/hardware/xosc.s"

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

	# Divider params for 150 MHz:
	#
	# $ cd pico-sdk
	# $ src/rp2_common/hardware_clocks/scripts/vcocalc.py 150
	# Requested: 150.0 MHz
	# Achieved:  150.0 MHz
	# REFDIV:    1
	# FBDIV:     125 (VCO = 1500.0 MHz)
	# PD1:       5
	# PD2:       2

	li	a0, 1	# REFDIV
	li	a1, 125	# FBDIV
	li	a2, 5	# PD1
	li	a3, 2	# PD2
	call	pll_sys_start

	#--------------------------
	# Clocks: set CLK_SYS to AUXILARY PLL
	#--------------------------

	call	clocks_set_clk_sys_aux_source_pll_sys
	call	clocks_set_clk_sys_source_aux

	#-------------------
	# Ticks: 
	#-------------------

	li	a0, 12				# every 1mks: 12 CLK_REF cycles at 12 MHz
	call	ticks_set_timer0_increment_cycles
	call	ticks_start_timer0

	#-------------------
	# Timer0
	#-------------------

	call	timer0_set_source_tick_generator	# timer0 counts ticks

	li	a0, 0
	call	timer0_enable_alarm_interrupt		# enable timer0 alarm0
	call	rvcsr_trigger_irq			# trigger IRQ0 once to start counting

	#-------------------
	# Loop forever
	#-------------------

led_loop:	j	led_loop
