.include "include/hardware/regs/addressmap.inc"
.include "include/hardware/regs/pll.inc"

# Function: pll_start
# Description: Configures and starts the system PLL.
#
#              The PLL reference divider and feedback divider are
#              programmed, the PLL and VCO are powered on, and
#              execution waits until the PLL reports a locked state.
#
#              After lock is achieved, the post-dividers are configured
#              and enabled.
#
# Inputs:
#   a0 = REFDIV value
#   a1 = FBDIV value
#   a2 = POSTDIV1 value
#   a3 = POSTDIV2 value
#
# Outputs:
#   none
#
# Clobbers:
#   t0, t1, t2
#
.global	pll_start
pll_start:
	li	t0, PLL_SYS_BASE
	lw	t1, PLL_CS_OFFSET(t0)		# configure the PLL reference divider.
	li	t2, ~PLL_CS_REFDIV_BITS		# clear REFDIV bits
	and	t1, t1, t2
	or	t1, t1, a0
	sw	t1, PLL_CS_OFFSET(t0)		# set REFDIV value (reference divider)
	sw	a1, PLL_FBDIV_INT_OFFSET(t0)		# set FBDIV value (feedback divider)

	li	t2, PLL_SYS_BASE + REG_ALIAS_CLR_BITS	# power up the PLL and VCO
	li	t1, PLL_PWR_PD_BITS | PLL_PWR_VCOPD_BITS
	sw	t1, PLL_PWR_OFFSET(t2)

	li	t1, PLL_CS_LOCK_BITS		# wait for PLL to lock
1:	lw	t2, PLL_CS_OFFSET(t0)
	and	t2, t2, t1
	beqz	t2, 1b

	slli	t1, a2, 16			# PD1
	slli	t2, a3, 12			# PD2
	or	t1, t1, t2
	sw	t1, PLL_PRIM_OFFSET(t0)		# configure the post-dividers

	li	t2, PLL_SYS_BASE + REG_ALIAS_CLR_BITS	# enable the post-divider stage
	li	t1, PLL_PWR_POSTDIVPD_BITS
	sw	t1, PLL_PWR_OFFSET(t2)
	ret
