.include "include/hardware/regs/addressmap.inc"
.include "include/hardware/regs/rvcsr.inc"
.include "include/hardware/regs/sio.inc"
.include "include/hardware/regs/timer.inc"

# VECTOR TABLE
# 3.8.4. Interrupts and exceptions

.section .vector_table_block, "ax"
.align	6 # 64 bytes
.option	push
.option	norvc # Disables generation of RVC (Compressed) instructions

.globl	vector_table_start
vector_table_start:
	j	machine_exception_handler		# Cause 00, Exceptions
	j	machine_catchall_handler		# Cause 01, Reserved
	j	machine_catchall_handler		# Cause 02, Reserved
	j	machine_software_interrupt_handler	# Cause 03, Software Interrupts
	j	machine_catchall_handler		# Cause 04, Reserved
	j	machine_catchall_handler		# Cause 05, Reserved
	j	machine_catchall_handler		# Cause 06, Reserved
	j	machine_timer_interrupt_handler	# Cause 07, Timer
	j	machine_catchall_handler		# Cause 08, Reserved
	j	machine_catchall_handler		# Cause 09, Reserved
	j	machine_catchall_handler		# Cause 10, Reserved
	j	machine_external_interrupt_handler	# Cause 11, External Interrupts
vector_table_end:

.globl	external_interrupt_table_start
external_interrupt_table_start:
	j	irq_0_handler		# IRQ 00, TIMER0_IRQ_0
	j	irq_1_handler		# IRQ 01, TIMER0_IRQ_1
	j	irq_catchall_handler	# IRQ 02, TIMER0_IRQ_2
	j	irq_catchall_handler	# IRQ 03, TIMER0_IRQ_3
	j	irq_catchall_handler	# IRQ 04, TIMER1_IRQ_0
	j	irq_catchall_handler	# IRQ 05, TIMER1_IRQ_1
	j	irq_catchall_handler	# IRQ 06, TIMER1_IRQ_2
	j	irq_catchall_handler	# IRQ 07, TIMER1_IRQ_3
	j	irq_catchall_handler	# IRQ 08, PWM_IRQ_WRAP_0
	j	irq_catchall_handler	# IRQ 09, PWM_IRQ_WRAP_1
	j	irq_catchall_handler	# IRQ 10, DMA_IRQ_0
	j	irq_catchall_handler	# IRQ 11, DMA_IRQ_1
	j	irq_catchall_handler	# IRQ 12, DMA_IRQ_2
	j	irq_catchall_handler	# IRQ 13, DMA_IRQ_3
	j	irq_catchall_handler	# IRQ 14, USBCTRL_IRQ
	j	irq_catchall_handler	# IRQ 15, PIO0_IRQ_0
	j	irq_catchall_handler	# IRQ 16, PIO0_IRQ_1
	j	irq_catchall_handler	# IRQ 17, PIO1_IRQ_0
	j	irq_catchall_handler	# IRQ 18, PIO1_IRQ_1
	j	irq_catchall_handler	# IRQ 19, PIO2_IRQ_0
	j	irq_catchall_handler	# IRQ 20, PIO2_IRQ_1
	j	irq_catchall_handler	# IRQ 21, IO_IRQ_BANK0
	j	irq_catchall_handler	# IRQ 22, IO_IRQ_BANK0_NS
	j	irq_catchall_handler	# IRQ 23, IO_IRQ_QSPI
	j	irq_catchall_handler	# IRQ 24, IO_IRQ_QSPI_NS
	j	irq_catchall_handler	# IRQ 25, SIO_IRQ_FIFO
	j	irq_catchall_handler	# IRQ 26, SIO_IRQ_BELL
	j	irq_catchall_handler	# IRQ 27, SIO_IRQ_FIFO_NS
	j	irq_catchall_handler	# IRQ 28, SIO_IRQ_BELL_NS
	j	irq_catchall_handler	# IRQ 29, SIO_IRQ_MTIMECMP
	j	irq_catchall_handler	# IRQ 30, CLOCKS_IRQ
	j	irq_catchall_handler	# IRQ 31, SPI0_IRQ
	j	irq_catchall_handler	# IRQ 32, SPI1_IRQ
	j	irq_catchall_handler	# IRQ 33, UART0_IRQ
	j	irq_catchall_handler	# IRQ 34, UART1_IRQ
	j	irq_catchall_handler	# IRQ 35, ADC_IRQ_FIFO
	j	irq_catchall_handler	# IRQ 36, I2C0_IRQ
	j	irq_catchall_handler	# IRQ 37, I2C1_IRQ
	j	irq_catchall_handler	# IRQ 38, OTP_IRQ
	j	irq_catchall_handler	# IRQ 39, TRNG_IRQ
	j	irq_catchall_handler	# IRQ 40, PROC0_IRQ_CTI
	j	irq_catchall_handler	# IRQ 41, PROC1_IRQ_CTI
	j	irq_catchall_handler	# IRQ 42, PLL_SYS_IRQ
	j	irq_catchall_handler	# IRQ 43, PLL_USB_IRQ
	j	irq_catchall_handler	# IRQ 44, POWMAN_IRQ_POW
	j	irq_catchall_handler	# IRQ 45, POWMAN_IRQ_TIMER
	j	irq_catchall_handler	# IRQ 46, SPAREIRQ_IRQ_0
	j	irq_catchall_handler	# IRQ 47, SPAREIRQ_IRQ_1
	j	irq_catchall_handler	# IRQ 48, SPAREIRQ_IRQ_2
	j	irq_catchall_handler	# IRQ 49, SPAREIRQ_IRQ_3
	j	irq_catchall_handler	# IRQ 50, SPAREIRQ_IRQ_4
	j	irq_catchall_handler	# IRQ 51, SPAREIRQ_IRQ_5
external_interrupt_table_end:

.option	pop


machine_catchall_handler:
	mret


machine_exception_handler:
	mret


machine_software_interrupt_handler:
	mret


machine_timer_interrupt_handler:
	mret


machine_external_interrupt_handler:
	addi	sp, sp, -32
	sw	ra,  0(sp)
	sw	t0,  4(sp)			# save all temporary registers because interrupt handler subroutines
	sw	t1,  8(sp)			# may clobber caller-saved registers
	sw	t2, 12(sp)
	sw	t3, 16(sp)
	sw	t4, 20(sp)
	sw	t5, 24(sp)
	sw	t6, 28(sp)

	la	t0, external_interrupt_table_start	# external interrupt vector table address
1:	csrr	t1, RVCSR_MEINEXT_OFFSET		# MEINEXT value
	bltz	t1, 2f				# exit if no more IRQs, (bit 31, RVCSR_MEINEXT_NOIRQ_BITS, can be tested with bltz)
	andi	t1, t1, RVCSR_MEINEXT_IRQ_BITS	# get IRQ number
	add	t1, t1, t0			# calculate IRQ handler address
	jalr	t1				# jump to IRQ handler
	j	1b				# loop, check for more IRQs

2:	lw	ra,  0(sp)
	lw	t0,  4(sp)
	lw	t1,  8(sp)
	lw	t2, 12(sp)
	lw	t3, 16(sp)
	lw	t4, 20(sp)
	lw	t5, 24(sp)
	lw	t6, 28(sp)
	addi	sp, sp, 32
	mret


irq_catchall_handler:
	ret


irq_0_handler:
	addi	sp, sp, -12
	sw	ra, 0(sp)
	sw	a0, 4(sp)
	sw	a1, 8(sp)

	li	a0, 0
	call	timer0_clear_alarm_interrupt
	li	a1, 100000
	call	timer0_set_alarm_relative
	li	a0, 2
	call	sio_toggle_gpio

	lw	ra, 0(sp)
	lw	a0, 4(sp)
	lw	a1, 8(sp)
	addi	sp, sp, 12
	ret


irq_1_handler:
	addi	sp, sp, -12
	sw	ra, 0(sp)
	sw	a0, 4(sp)
	sw	a1, 8(sp)

	li	a0, 1
	call	timer0_clear_alarm_interrupt
	li	a1, 500000
	call	timer0_set_alarm_relative
	li	a0, 25
	call	sio_toggle_gpio

	lw	ra, 0(sp)
	lw	a0, 4(sp)
	lw	a1, 8(sp)
	addi	sp, sp, 12
	ret
