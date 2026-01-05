.equ    PICOBIN_BLOCK_MARKER_START, 0xffffded3     # 5.1.5.1. Blocks
.equ	PICOBIN_BLOCK_MARKER_END, 0xab123579

.equ	PICOBIN_BLOCK_ITEM_1BS_IMAGE_TYPE, 0x42	   # 5.9.3.1. IMAGE_DEF item
.equ	PICOBIN_BLOCK_ITEM_1BS_VECTOR_TABLE, 0x03  # 5.9.3.3. VECTOR_TABLE item
.equ	PICOBIN_BLOCK_ITEM_1BS_ENTRY_POINT, 0x44   # 5.9.3.4. ENTRY_POINT item
.equ	PICOBIN_BLOCK_ITEM_2BS_LAST, 0xff          # 5.9.1. Blocks and block loops

# PICOBIN_IMAGE_TYPE_xxx bits definition can be found at
# https://github.com/raspberrypi/pico-sdk/blob/master/src/common/boot_picobin_headers/include/boot/picobin.h
.equ	PICOBIN_IMAGE_TYPE_IMAGE_TYPE_EXE, 0x1     # 5.9.3.1. IMAGE_DEF item
.equ	PICOBIN_IMAGE_TYPE_EXE_SECURITY_S, 0x2 << 4
.equ	PICOBIN_IMAGE_TYPE_EXE_CPU_RISCV, 0x1 << 8
.equ	PICOBIN_IMAGE_TYPE_EXE_CHIP_RP2350, 0x1 << 12

.equ	SRAM_END, 0x20082000                       # 2.2.3. SRAM


# # VECTOR TABLE
# .section .vector_table_block, "ax"

# 3.7.4.6. Exceptions
# All populated vectors in the vector table entries must have bit[0] set.
# Creating a table entry with bit[0] clear generates an INVSTATE
# fault on the first instruction of the handler corresponding to this vector

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


# IMAGE_DEF
# 
# 5.1.5. Blocks And Block Loops
#
# IMAGE_DEFs is an example of blocks. A block is a recognisable, self-checking data structure
# containing one or more distinct data items. The type of the first item in a block defines the type of that entire block.
# 
# Blocks are backwards and forwards compatible; item types will not be changed in the future in ways that could cause
# existing code to misinterpret data. Consumers of blocks (including the bootrom) must skip items within the block
# whose types are currently listed as reserved; encountering reserved item types must not cause a block to fail validation.
# 
# To be considered valid, a block must have the following properties:
# • it must begin with the 4 byte magic header, PICOBIN_BLOCK_MARKER_START (0xffffded3)
# • the end of each (variably-sized) item must also be the start of another valid item
# • the last item must have type PICOBIN_BLOCK_ITEM_2BS_LAST and specify the correct full length of the block
# • it must end with the 4 byte magic footer, PICOBIN_BLOCK_MARKER_END (0xab123579)


.section .image_def_block, "a"

# Image deinition block HEADER
image_def_block_start:
	.word	PICOBIN_BLOCK_MARKER_START

image_def_block_items_start:
	# BLOCK ITEM: Image definition
	# 5.9.3.1. IMAGE_DEF item
	.byte	PICOBIN_BLOCK_ITEM_1BS_IMAGE_TYPE
	.byte	0x01            # Block size in words
	.hword	PICOBIN_IMAGE_TYPE_IMAGE_TYPE_EXE | PICOBIN_IMAGE_TYPE_EXE_CPU_RISCV | PICOBIN_IMAGE_TYPE_EXE_SECURITY_S | PICOBIN_IMAGE_TYPE_EXE_CHIP_RP2350

	# # BLOCK ITEM: Vector table (optional)
	# .byte   PICOBIN_BLOCK_ITEM_1BS_VECTOR_TABLE
	# .byte   0x02          # Block size in words   
	# .hword  0x00          # pad
	# .word   vector_table_start

	# BLOCK ITEM: Entry point (optional)
	.byte	PICOBIN_BLOCK_ITEM_1BS_ENTRY_POINT
	.byte	0x03            # Block size in words
	.hword	0x00            # pad
	.word	_start+1        # Inital PC (runtime) address (aka entry point)
	.word	SRAM_END        # Initial SP address (aka stack pointer)
image_def_block_items_end:

	# BLOCK ITEM: Last item
	.byte	PICOBIN_BLOCK_ITEM_2BS_LAST
	.hword	(image_def_block_end - image_def_block_start - 16) / 4  # size of all prev items in words
	.byte	0x00            # pad
	# LINK: Relative position in bytes of next block HEADER relative to this block’s HEADER (a single block loop has 0 here)
	.word	0x00
	.word	PICOBIN_BLOCK_MARKER_END
image_def_block_end:

