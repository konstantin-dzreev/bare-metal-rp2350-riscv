.section .text

.include "include/hardware/regs/addressmap.inc"
.include "include/hardware/regs/ticks.inc"

# Function: ticks_set_timer0_increment_cycles
# Description: Configures the number of tick-generator cycles required
#              before TIMER0 increments once.
#
#              Larger values reduce the TIMER0 tick rate. Smaller
#              values increase the TIMER0 tick rate.
#
# Inputs:
#   a0 = number of source clock cycles per TIMER0 tick
#
# Outputs:
#   none
#
# Clobbers:
#   t0
#
.globl	ticks_set_timer0_increment_cycles
ticks_set_timer0_increment_cycles:
	li	t0, TICKS_BASE
	sw	a0, TICKS_TIMER0_CYCLES_OFFSET(t0)
	ret

# Function: ticks_start_timer0
# Description: Starts the TIMER0 tick generator by enabling its tick
#              source.
#
#              Once enabled, TIMER0 advances according to the configured
#              tick source and tick frequency.
#
# Inputs:
#   none
#
# Outputs:
#   none
#
# Clobbers:
#   t0, t1
#
.globl	ticks_start_timer0
ticks_start_timer0:
	li	t0, TICKS_BASE + REG_ALIAS_SET_BITS
	li	t1, TICKS_TIMER0_CTRL_ENABLE_BITS	# enable TIMER0 tick generation
	sw	t1, TICKS_TIMER0_CTRL_OFFSET(t0)
	ret

# Function: ticks_stop_timer0
# Description: Stops the TIMER0 tick generator by disabling its tick
#              source.
#
#              While disabled, TIMER0 no longer advances from the tick
#              generator.
#
# Inputs:
#   none
#
# Outputs:
#   none
#
# Clobbers:
#   t0, t1
#
.globl	ticks_stop_timer0
ticks_stop_timer0:
	li	t0, TICKS_BASE + REG_ALIAS_CLR_BITS
	li	t1, TICKS_TIMER0_CTRL_ENABLE_BITS	# disable TIMER0 tick generation
	sw	t1, TICKS_TIMER0_CTRL_OFFSET(t0)
	ret
