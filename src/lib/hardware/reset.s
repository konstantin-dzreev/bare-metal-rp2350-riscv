.include "include/hardware/regs/addressmap.inc"
.include "include/hardware/regs/resets.inc"

# Function: unreset_subsystems
# Description: Takes hardware components out of reset (activates).
#
# Inputs:
#   a0 = hardware component bits, see RESETS_RESET register
#
# Outputs:
#   none
#
# Clobbers:
#   t0, t1
#
.global	unreset_subsystems
unreset_subsystems:
	li	t0, RESETS_BASE + REG_ALIAS_CLR_BITS
	sw	a0, (t0)				# clear reset bits for selected subsystems

	li	t0, RESETS_BASE
.L_wait_until_unreset_done:
	lw	t1, RESETS_RESET_DONE_OFFSET(t0)	# read reset completion status
	and	t1, t1, a0			# keep only requested subsystem bits
	bne	t1, a0, .L_wait_until_unreset_done	# wait until all subsystems are active
	ret


# Function: reset_subsystems
# Description: Takes hardware components into reset (deactivates).
#
# Inputs:
#   a0 = hardware component bits, see RESETS_RESET register
#
# Outputs:
#   none
#
# Clobbers:
#   t0
#
.global	reset_subsystems
reset_subsystems:
	li	t0, RESETS_BASE + REG_ALIAS_SET_BITS
	sw	a0, (t0)				# place selected subsystems into reset
	ret
