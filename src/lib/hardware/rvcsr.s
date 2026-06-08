.include "include/hardware/regs/rvcsr.inc"

# Function: rvcsr_disable_interrupts
# Description: Disables interrupts globally by clearing the MIE bit in mstatus.
#
# Inputs:
#   none
#
# Outputs:
#   none
#
# Clobbers:
#   t0
#
.global	rvcsr_disable_interrupts
rvcsr_disable_interrupts:
	li	t0, RVCSR_MSTATUS_MIE_BITS
	csrc	RVCSR_MSTATUS_OFFSET, t0
	ret


# Function: rvcsr_enable_interrupts
# Description: Enables interrupts globally by setting the MIE bit in mstatus.
#
# Inputs:
#   none
#
# Outputs:
#   none
#
.global	rvcsr_enable_interrupts
rvcsr_enable_interrupts:
	li	t0, RVCSR_MSTATUS_MIE_BITS
	csrs	RVCSR_MSTATUS_OFFSET, t0
	ret


# Function: rvcsr_disable_all_machine_interrupts
# Description: Disables all machine-mode interrupt sources by clearing mie.
#
# Inputs:
#   none
#
# Outputs:
#   none
#
# Clobbers:
#   t0
#
.global	rvcsr_disable_all_machine_interrupts
rvcsr_disable_all_machine_interrupts:
	csrw	RVCSR_MIE_OFFSET, zero
	ret


# Function: rvcsr_enable_machine_interrupts
# Description: Enables one or more machine-mode interrupt sources by
#              setting bits in mie.
#
# Inputs:
#   a0 = interrupt enable bits to set, see mie register definitions
#
# Outputs:
#   none
#
# Clobbers:
#   none
#
.global	rvcsr_enable_machine_interrupts
rvcsr_enable_machine_interrupts:
	csrs	RVCSR_MIE_OFFSET, a0		
	ret


# Function: rvcsr_set_interrupt_mode
# Description: Configures the trap-vector base address and interrupt mode
#              by writing mtvec.
#
# Inputs:
#   a0 = trap-vector table base address (must satisfy mtvec alignment requirements)
#   a1 = mtvec mode value
#
# Outputs:
#   none
#
# Clobbers:
#   t0
#
.global	rvcsr_set_interrupt_mode
rvcsr_set_interrupt_mode:
	li	t0, ~RVCSR_MTVEC_MODE_BITS
	and	t0, t0, a0
	or	t0, t0, a1
	csrw	RVCSR_MTVEC_OFFSET, t0
	ret


# Function: rvcsr_enable_irqs_in_window
# Description: Enables one or more machine external interrupts within
#              a specified IRQ window. The window bitmask is placed in
#              bits [31:16] and the window index is placed in bits [15:0]
#              before writing the combined value to the MEIEA CSR.
#
# Inputs:
#   a0 = IRQ window bitmask
#   a1 = IRQ window index
#
# Outputs:
#   none
#
# Clobbers:
#   a0
#
.global	rvcsr_enable_irqs_in_window
rvcsr_enable_irqs_in_window:
	slli	a0, a0, 16	# place the window bitmask in bits [31:16]
	or	a0, a0, a1	# merge the windows and the index
	csrw	RVCSR_MEIEA_OFFSET, a0
	ret


# Function: rvcsr_enable_irq
# Description: Enables a machine external interrupt by IRQ number.
#              Converts the IRQ number into a window bitmask and
#              window index, then calls rvcsr_enable_irqs_in_window().
#
# Inputs:
#   a0 = IRQ number (IRQ0 = 0, IRQ1 = 1, etc.)
#
# Outputs:
#   none
#
# Clobbers:
#   t0, t1, a0, a1
#
.global	rvcsr_enable_irq
rvcsr_enable_irq:
	addi	sp, sp, -4
	sw	ra, 0(sp)

	li	t0, 16
	li	t1, 1
	divu	a1, a0, t0	# index:  irq / 16
	remu	a0, a0, t0	# window: 1 << (irq % 16)
	sll	a0, t1, a0
	call	rvcsr_enable_irqs_in_window

	lw	ra, 0(sp)
	addi	sp, sp, 4
	ret
