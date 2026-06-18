OUTPUT_FORMAT(elf32-littleriscv)

MEMORY
{
	FLASH(rx) : ORIGIN = 0x10000000, LENGTH = 4M
	RAM(rwx)  : ORIGIN = 0x20000000, LENGTH = 520K
}

/* Entry point for debugger */
ENTRY(_start)

SECTIONS {
	.text : {
		KEEP (*(.image_def_block))
		KEEP (*(.vector_table_block))
		. = ALIGN(4);
		*(.text)
	} > FLASH
}

