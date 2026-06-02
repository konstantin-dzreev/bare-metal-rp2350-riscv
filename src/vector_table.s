# # VECTOR TABLE
# .section .vector_table_block, "ax"

# vector_table_start:
#	.word	SRAM_END     # MSP, initial value for the main stack pointer
#	.word	_start + 1   # Exception 01, Reset Handler
#	.word	0x00         # Exception 02, NMI Handler
#	.word	0x00         # Exception 03, HardFault Handler
#	.word	0x00         # Exception 04, MPU Handler
#	.word	0x00         # Exception 05, BusFault Handler
#	.word	0x00         # Exception 06, UsageFault Handler
#	.word	0x00         # Exception 07, Secureaault Handler
#	.word	0x00         # Exception 08, Reserved
#	.word	0x00         # Exception 09, Reserved
#	.word	0x00         # Exception 10, Reserved
#	.word	0x00         # Exception 11, SVCall Handler
#	.word	0x00         # Exception 12, DebugMonitor Handler
#	.word	0x00         # Exception 13, Reserved
#	.word	0x00         # Exception 14, PendSV Handler
#	.word	0x00         # Exception 15, SysTic Handler
#	.word	0x00         # Exception 16, IRQ 00, TIMER0_IRQ_0
#	.word	0x00         # Exception 17, IRQ 01, TIMER0_IRQ_1
#	.word	0x00         # Exception 18, IRQ 02, TIMER0_IRQ_2
#	.word	0x00         # Exception 19, IRQ 03, TIMER0_IRQ_3
#	.word	0x00         # Exception 20, IRQ 04, TIMER1_IRQ_0
#	.word	0x00         # Exception 21, IRQ 05, TIMER1_IRQ_1
#	.word	0x00         # Exception 22, IRQ 06, TIMER1_IRQ_2
#	.word	0x00         # Exception 23, IRQ 07, TIMER1_IRQ_3
#	.word	0x00         # Exception 24, IRQ 08, PWM_IRQ_WRAP_0
#	.word	0x00         # Exception 25, IRQ 09, PWM_IRQ_WRAP_1
#	.word	0x00         # Exception 26, IRQ 10, DMA_IRQ_0
#	.word	0x00         # Exception 27, IRQ 11, DMA_IRQ_1
#	.word	0x00         # Exception 28, IRQ 12, DMA_IRQ_2
#	.word	0x00         # Exception 29, IRQ 13, DMA_IRQ_3
#	.word	0x00         # Exception 30, IRQ 14, USBCTRL_IRQ
#	.word	0x00         # Exception 31, IRQ 15, PIO0_IRQ_0
#	.word	0x00         # Exception 32, IRQ 16, PIO0_IRQ_1
#	.word	0x00         # Exception 33, IRQ 17, PIO1_IRQ_0
#	.word	0x00         # Exception 34, IRQ 18, PIO1_IRQ_1
#	.word	0x00         # Exception 35, IRQ 19, PIO2_IRQ_0
#	.word	0x00         # Exception 36, IRQ 20, PIO2_IRQ_1
#	.word	0x00         # Exception 37, IRQ 21, IO_IRQ_BANK0
#	.word	0x00         # Exception 38, IRQ 22, IO_IRQ_BANK0_NS
#	.word	0x00         # Exception 39, IRQ 23, IO_IRQ_QSPI
#	.word	0x00         # Exception 40, IRQ 24, IO_IRQ_QSPI_NS
#	.word	0x00         # Exception 41, IRQ 25, SIO_IRQ_FIFO
#	.word	0x00         # Exception 42, IRQ 26, SIO_IRQ_BELL
#	.word	0x00         # Exception 43, IRQ 27, SIO_IRQ_FIFO_NS
#	.word	0x00         # Exception 44, IRQ 28, SIO_IRQ_BELL_NS
#	.word	0x00         # Exception 45, IRQ 29, SIO_IRQ_MTIMECMP
#	.word	0x00         # Exception 46, IRQ 30, CLOCKS_IRQ
#	.word	0x00         # Exception 47, IRQ 31, SPI0_IRQ
#	.word	0x00         # Exception 48, IRQ 32, SPI1_IRQ
#	.word	0x00         # Exception 49, IRQ 33, UART0_IRQ
#	.word	0x00         # Exception 50, IRQ 34, UART1_IRQ
#	.word	0x00         # Exception 51, IRQ 35, ADC_IRQ_FIFO
#	.word	0x00         # Exception 52, IRQ 36, I2C0_IRQ
#	.word	0x00         # Exception 53, IRQ 37, I2C1_IRQ
#	.word	0x00         # Exception 54, IRQ 38, OTP_IRQ
#	.word	0x00         # Exception 55, IRQ 39, TRNG_IRQ
#	.word	0x00         # Exception 56, IRQ 40, PROC0_IRQ_CTI
#	.word	0x00         # Exception 57, IRQ 41, PROC1_IRQ_CTI
#	.word	0x00         # Exception 58, IRQ 42, PLL_SYS_IRQ
#	.word	0x00         # Exception 59, IRQ 43, PLL_USB_IRQ
#	.word	0x00         # Exception 60, IRQ 44, POWMAN_IRQ_POW
#	.word	0x00         # Exception 61, IRQ 45, POWMAN_IRQ_TIMER
#	.word	0x00         # Exception 62, IRQ 46, SPAREIRQ_IRQ_0
#	.word	0x00         # Exception 63, IRQ 47, SPAREIRQ_IRQ_1
#	.word	0x00         # Exception 64, IRQ 48, SPAREIRQ_IRQ_2
#	.word	0x00         # Exception 65, IRQ 49, SPAREIRQ_IRQ_3
#	.word	0x00         # Exception 66, IRQ 50, SPAREIRQ_IRQ_4
#	.word	0x00         # Exception 67, IRQ 51, SPAREIRQ_IRQ_5
# vector_table_end:
