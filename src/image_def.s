.include "include/boot/picobin.inc"
.include "include/hardware/regs/addressmap.inc"

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
	.byte	0x01          # Block size in words
	.hword	PICOBIN_IMAGE_TYPE_IMAGE_TYPE_EXE | (PICOBIN_IMAGE_TYPE_EXE_SECURITY_S << PICOBIN_IMAGE_TYPE_EXE_SECURITY_LSB) | (PICOBIN_IMAGE_TYPE_EXE_CPU_RISCV << PICOBIN_IMAGE_TYPE_EXE_CPU_LSB) | (PICOBIN_IMAGE_TYPE_EXE_CHIP_RP2350 << PICOBIN_IMAGE_TYPE_EXE_CHIP_LSB)

	# BLOCK ITEM: Entry point (optional)
	.byte	PICOBIN_BLOCK_ITEM_1BS_ENTRY_POINT
	.byte	0x03          # Block size in words
	.hword	0x00          # pad
	.word	_start        # Inital PC (runtime) address (aka entry point)
	.word	SRAM_END      # Initial SP address (aka stack pointer)
image_def_block_items_end:

	# BLOCK ITEM: Last item
	.byte	PICOBIN_BLOCK_ITEM_2BS_LAST
	.hword	(image_def_block_end - image_def_block_start - 16) / 4  # size of all prev items in words
	.byte	0x00          # pad
	# LINK: Relative position in bytes of next block HEADER relative to this block’s HEADER (a single block loop has 0 here)
	.word	0x00
	.word	PICOBIN_BLOCK_MARKER_END
image_def_block_end:
