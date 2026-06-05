# VECTOR TABLE
# 3.8.4. Interrupts and exceptions

.include "include/hardware/regs/rvcsr.inc"
.include "include/hardware/regs/sio.inc"
.include "include/hardware/regs/addressmap.inc"

.section .vector_table_block, "ax"
.align	6 # 64 bytes

.global	vector_table_start
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

.global	external_interrupt_table_start
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


machine_catchall_handler:
	mret


machine_exception_handler:
	mret


machine_software_interrupt_handler:
	mret


machine_timer_interrupt_handler:
	mret


machine_external_interrupt_handler:
	addi	sp, sp, -16			# Store TMP registers
	sw	t0,  0(sp)
	sw	t1,  4(sp)
	sw	t2,  8(sp)
	sw	t3, 12(sp)

#--------- HACK -------------
	li	t0, SIO_BASE
	li	t1, 1 << 25
	sw	t1, SIO_GPIO_OUT_SET_OFFSET(t0)
#--------- HACK -------------


loop:
	csrr	t0, RVCSR_MEINEXT_OFFSET		# MEINEXT value
	li	t1, RVCSR_MEINEXT_NOIRQ_BITS		# IRQ MASK
	la	t2, external_interrupt_table_start	# external interrupt vector table address

	and	t3, t0, t1			# no more interrupts if not 0
	bnez	t3, done

	andi	t3, t0, RVCSR_MEINEXT_IRQ_BITS	# get IRQ number
	add	t3, t3, t2
	jalr	t3				# jump to IRQ handler

	j	loop
done:
	lw	t0,  0(sp)			# Restore TMP registers
	lw	t1,  4(sp)
	lw	t2,  8(sp)
	lw	t3, 12(sp)
	addi	sp, sp, 16

	mret


irq_catchall_handler:
	j	irq_0_handler
	ret


irq_0_handler:
	addi	sp, sp, -16			# Store TMP registers
	sw	t0,  0(sp)
	sw	t1,  4(sp)
	sw	t2,  8(sp)
	sw	t3, 12(sp)

#--------- HACK -------------
	li	t0, SIO_BASE
	li	t1, 1 << 25
	sw	t1, SIO_GPIO_OUT_SET_OFFSET(t0)
#--------- HACK -------------


# 	li	t0, SIO_BASE
# 	li	t1, 1 << 25
# 	lw	t2, SIO_GPIO_IN_OFFSET(t0)
# 	and	t2, t2, t1
# 	beqz	t2, turn_on
# 	sw	t1, SIO_GPIO_OUT_CLR_OFFSET(t0)
# 	j	done1
# turn_on:
# 	sw	t1, SIO_GPIO_OUT_SET_OFFSET(t0)

done1:
	lw	t0,  0(sp)			# Restore TMP registers
	lw	t1,  4(sp)
	lw	t2,  8(sp)
	lw	t3, 12(sp)
	addi	sp, sp, 16

	ret
