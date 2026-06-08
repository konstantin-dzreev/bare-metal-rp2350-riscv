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
	j	irq_catchall_handler	# IRQ 01, TIMER0_IRQ_1
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
	cm.push	{ra, s0-s3}, -32
loop:
	csrr	s0, RVCSR_MEINEXT_OFFSET		# MEINEXT value
	li	s1, RVCSR_MEINEXT_NOIRQ_BITS		# IRQ MASK
	la	s2, external_interrupt_table_start	# external interrupt vector table address

	and	s3, s0, s1			# no more interrupts if not 0
	bnez	s3, done

	andi	s3, s0, RVCSR_MEINEXT_IRQ_BITS	# get IRQ number
	add	s3, s3, s2
	jalr	s3				# jump to IRQ handler

	j	loop
done:
	cm.pop	{ra, s0-s3}, 32
	mret


irq_catchall_handler:
	ret

irq_0_handler:
	cm.push	{ra, s0-s3}, -32

	li	s0, TIMER0_BASE			# clear ALARM0
	li	s1, TIMER_INTR_ALARM_0_BITS
	sw	s1, TIMER_INTR_OFFSET(s0)

	lw	s1, TIMER_TIMELR_OFFSET(s0)		# time for the next Alarm
	li	s2, 500000
	add	s1, s1, s2
	sw	s1, TIMER_ALARM0_OFFSET(s0)

	li	s0, SIO_BASE			# blink LED
	li	s1, 1 << 25
	lw	s2, SIO_GPIO_OUT_OFFSET(s0)
	and	s2, s2, s1
	beqz	s2, 1f
	sw	s1, SIO_GPIO_OUT_CLR_OFFSET(s0)
	j	2f
1:	sw	s1, SIO_GPIO_OUT_SET_OFFSET(s0)

2:	cm.popret	{ra, s0-s3}, 32
