.include "include/hardware/regs/addressmap.inc"
.include "include/hardware/regs/clocks.inc"
#.include "include/hardware/regs/io_bank0.inc"
#.include "include/hardware/regs/pads_bank0.inc"
.include "include/hardware/regs/pll.inc"
.include "include/hardware/regs/rosc.inc"
#.include "include/hardware/regs/rvcsr.inc"
#.include "include/hardware/regs/sio.inc"
.include "include/hardware/regs/ticks.inc"
.include "include/hardware/regs/timer.inc"
.include "include/hardware/regs/xosc.inc"

.include "src/lib/hardware/io_bank0.s"
.include "src/lib/hardware/pads_bank0.s"
.include "src/lib/hardware/rvcsr.s"
.include "src/lib/hardware/reset.s"
.include "src/lib/hardware/sio.s"

.equ	big_number, 0x0000200000

.section	.text
.global	_start
.align	2 # 4 bytes

_start:
	#--------------------------
	# Interrupts
	#--------------------------

	call	rvcsr_disable_interrupts		# disable interrupts globally

	call	rvcsr_disable_all_machine_interrupts	# disable all machine-mode interrupts

	la	a0, vector_table_start		# vector table address
	li	a1, RVCSR_MTVEC_MODE_VALUE_VECTORED	# vectored mode
	call	rvcsr_set_interrupt_mode		# set vectored mode interrupts

	li	a0, RVCSR_MIE_MEIE_BITS		# external interrupts only
	call	rvcsr_enable_machine_interrupts	# enable machine interrupts (IRQ only)

	call	rvcsr_enable_interrupts		# enable interrupts globally

	li	a0, 0				# enable IRQ-0 (Timer0 Alarm) interrupt
	call	rvcsr_enable_irq

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
	call	io_bank0_set_gpio_function
	li	a0, 25
	call	sio_gpio_enable_output
	li	a0, 25
	call	pads_bank0_enable_pad_output

	li	a0, 0				# GPIO 0
	li	a1, 5				# function 5: SIO_0
	call	io_bank0_set_gpio_function
	li	a0, 0
	call	sio_gpio_enable_output
	li	a0, 0
	call	pads_bank0_enable_pad_output

	li	a0, 2				# GPIO 2
	li	a1, 5				# function 5: SIO_0
	call	io_bank0_set_gpio_function
	li	a0, 2
	call	sio_gpio_enable_output
	li	a0, 2
	call	pads_bank0_enable_pad_output

	# # GPIO2: select function SIO
	# li	a0, IO_BANK0_BASE
	# li	a1, IO_BANK0_GPIO2_CTRL_FUNCSEL_VALUE_SIOB_PROC_2
	# sw	a1, IO_BANK0_GPIO2_CTRL_OFFSET(a0)

	# # GPIO2: enable output
	# li	a0, SIO_BASE
	# li	a1, 1 << 2
	# sw	a1, SIO_GPIO_OE_SET_OFFSET(a0)

	# # GPIO2: clear output disable and isolation bits on its pad
	# li	a4, PADS_BANK0_GPIO2_OD_BITS | PADS_BANK0_GPIO2_ISO_BITS 
	# li	a5, PADS_BANK0_BASE + REG_ALIAS_CLR_BITS
	# sw	a4, PADS_BANK0_GPIO2_OFFSET(a5)


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

	#--------------------------
	# Crystal oscillator (XOSC)
	# Pico-2 comes with 12Mhz
	#--------------------------

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

	# switch CLK_SYS to use CLK_REF clock
	# (preserving AUXSRC bits)
	lw	t1, CLOCKS_CLK_SYS_CTRL_OFFSET(t0)
	li	t2, ~CLOCKS_CLK_SYS_CTRL_SRC_BITS
	and	t1, t1, t2
	ori	t1, t1, CLOCKS_CLK_SYS_CTRL_SRC_VALUE_CLK_REF
	sw	t1, CLOCKS_CLK_SYS_CTRL_OFFSET(t0)

.L_wait_for_clk_sys_to_switch:
	lw	t2, CLOCKS_CLK_SYS_SELECTED_OFFSET(t0)
	li	t1, 1 << CLOCKS_CLK_SYS_CTRL_SRC_VALUE_CLK_REF
	and	t2, t2, t1
	beqz	t2, .L_wait_for_clk_sys_to_switch

	#--------------------------
	# PLL
	#--------------------------

	# rp2350 datasheet: 8.6 PLL, page 582
	#
	# The programming sequence for the PLL is as follows:
	# 1. Program the reference clock divider (is a divide by 1 in the RP2350 case).
	# 2. Program the feedback divider.
	# 3. Turn on the main power and VCO.
	# 4. Wait for the VCO to achieve a stable frequency, as indicated by the LOCK status flag.
	# 5. Set up post dividers and turn them on.
	#
	# # Divider params for 48 MHz:
	#
	# $ cd pico-sdk
	# $ src/rp2_common/hardware_clocks/scripts/vcocalc.py 48
	# Requested: 48.0 MHz
	# Achieved:  48.0 MHz
	# REFDIV:    1
	# FBDIV:     120 (VCO = 1440.0 MHz)
	# PD1:       6
	# PD2:       5
	#

	li	t0, PLL_SYS_BASE

	# set REFDIR
	lw	t1, PLL_CS_OFFSET(t0)
	li	t2, ~PLL_CS_REFDIV_BITS
	and	t1, t1, t2
	ori	t1, t1, 1			# REFDIR
	sw	t1, PLL_CS_OFFSET(t0)

	# set FBDIV
	li	t1, 120			# FBDIV
	sw	t1, PLL_FBDIV_INT_OFFSET(t0)

	# turn on PLL
	li	t2, PLL_SYS_BASE + REG_ALIAS_CLR_BITS
	li	t1, PLL_PWR_PD_BITS | PLL_PWR_VCOPD_BITS
	sw	t1, PLL_PWR_OFFSET(t2)

	li	t1, PLL_CS_LOCK_BITS
.L_wait_for_pll_to_lock:
	lw	t2, PLL_CS_OFFSET(t0)
	and	t2, t2, t1
	beqz	t2, .L_wait_for_pll_to_lock 

	# set post dividers: PD1=6, PD2=5
	li	t1, 6 << 16 | 5 << 12
	sw	t1, PLL_PRIM_OFFSET(t0)

	# turn ON post divider
	li	t1, PLL_PWR_POSTDIVPD_BITS
	li	t2, PLL_SYS_BASE + REG_ALIAS_CLR_BITS
	sw	t1, PLL_PWR_OFFSET(t2)

	#-------------------
	# PLL is up and running, now we need to switch CLK_SYS to it
	#-------------------

	# set AUX source to PLL_SYS
	li	t0, CLOCKS_BASE
	lw	t1, CLOCKS_CLK_SYS_CTRL_OFFSET(t0)
	li	t2, ~CLOCKS_CLK_SYS_CTRL_AUXSRC_BITS
	and	t1, t1, t2
	ori	t1, t1, CLOCKS_CLK_SYS_CTRL_AUXSRC_VALUE_CLKSRC_PLL_SYS << CLOCKS_CLK_SYS_CTRL_AUXSRC_LSB
	sw	t1, CLOCKS_CLK_SYS_CTRL_OFFSET(t0)

	# switch CLK_SYS to AUX source which is PLL_SYS now
	li	t2, CLOCKS_CLK_SYS_CTRL_SRC_VALUE_CLKSRC_CLK_SYS_AUX
	or	t1, t1, t2
	sw	t1, CLOCKS_CLK_SYS_CTRL_OFFSET(t0)

.L_wait_for_clk_sys_to_switch_to_aux:
	lw	t2, CLOCKS_CLK_SYS_SELECTED_OFFSET(t0)
	li	t1, 1 << CLOCKS_CLK_SYS_CTRL_SRC_VALUE_CLKSRC_CLK_SYS_AUX
	and	t2, t2, t1
	beqz	t2, .L_wait_for_clk_sys_to_switch_to_aux


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

led_loop:
	li	a0, SIO_BASE
	li	a1, 1

	# LED on
	sw	a1, SIO_GPIO_OUT_SET_OFFSET(a0)
	call	pause

	# LED off
	sw	a1, SIO_GPIO_OUT_CLR_OFFSET(a0)
	call	pause

	# Loop
	j	led_loop

pause:
	addi	sp, sp, -4			# store TMP registers
	sw	t0,  0(sp)

	li	t0, big_number
1:	addi	t0, t0, -1
	bnez	t0, 1b

	lw	t0,  0(sp)			# restore TMP registers
	addi	sp, sp, 4

	ret
