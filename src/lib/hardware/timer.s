.include "include/hardware/regs/addressmap.inc"
.include "include/hardware/regs/timer.inc"

# Function: timer0_set_source_tick_generator
# Description: Selects the TICKS block as the TIMER0 clock source.
#
#              When configured, TIMER0 increments according to the
#              TIMER0 tick generator configuration in the TICKS block.
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
.globl	timer0_set_source_tick_generator
timer0_set_source_tick_generator:
	li	t0, TIMER0_BASE
	sw	zero, TIMER_SOURCE_OFFSET(t0)
	ret

# Function: timer0_set_alarm_relative
# Description: Sets TIMER0 ALARM to trigger after a delay relative
#              to the current TIMER0 count.
#
#              The alarm value is calculated as: current_timer_value + delay
#
# Inputs:
#   a0 = alarm number
#   a1 = delay in TIMER0 ticks
#
# Outputs:
#   none
#
# Clobbers:
#   t0, t1, t2
#
.globl	timer0_set_alarm_relative
timer0_set_alarm_relative:
	li	t0, TIMER0_BASE
	lw	t1, TIMER_TIMELR_OFFSET(t0)	# calculate the target alarm time.
	add	t1, t1, a1

	sll	t2, a0, 2			# calculate alarm offset by its number:
	add	t2, t2, t0

	sw	t1, TIMER_ALARM0_OFFSET(t2)	# program ALARM
	ret

# Function: timer0_enable_alarm_interrupt
# Description: Enables the interrupt for a TIMER0 alarm.
#
#              The specified alarm bit is set in the TIMER0 interrupt
#              enable register (INTE).
#
# Inputs:
#   a0 = alarm number
#
# Outputs:
#   none
#
# Clobbers:
#   t0, t1
#
.globl	timer0_enable_alarm_interrupt
timer0_enable_alarm_interrupt:
	li	t0, TIMER0_BASE + REG_ALIAS_SET_BITS
	li	t1, 1			# interrupt enable bitmask for the selected alarm
	sll	t1, t1, a0
	sw	t1, TIMER_INTE_OFFSET(t0)	# enable the alarm interrupt
	ret

# Function: timer0_clear_alarm_interrupt
# Description:
# Clears a pending TIMER0 alarm interrupt.
#
# The interrupt is cleared by writing the corresponding alarm bit to
# the TIMER0 interrupt register (INTR).
#
# Inputs:
# a0 = Alarm number (0-3).
#
# Outputs:
# None.
#
# Clobbers:
# t0, t1
#
.globl	timer0_clear_alarm_interrupt
timer0_clear_alarm_interrupt:
	li	t0, TIMER0_BASE
	li	t1, TIMER_INTR_ALARM_0_BITS
	sll	t1, t1, a0		# build the interrupt bitmask for the selected alarm
	sw	t1, TIMER_INTR_OFFSET(t0)
	ret
