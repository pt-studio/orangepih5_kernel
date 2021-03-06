/*
 * Secondary CPU startup routine source file.
 *
 * Copyright (c) Allwinner.  All rights reserved.
 *
 * Sugar <shuge@allwinnertech.com>
 *
 * Interface functions needed for the SMP. This file is based on arm
 * realview smp platform.
 * Copyright (c) 2003 ARM Limited.
 *
 * This program is free software,you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */

#include <linux/linkage.h>
#include <linux/init.h>

	.text
	.align 4

ENTRY(sunxi_secondary_startup)
	msr	cpsr_fsxc, #0xd3	@ switch to SVC mode, disable IRQ

	mrc	p15, 0, r0, c0, c0, 5	@ get core id
	and	r0, r0, #0x3

	adr	r1, _cpus_boot_entry
	ldmia	r1, {r2, r3}		@ address to jump to after
	sub	lr, r1, r2		@ offset between Virt and Phy address
	add	r3, r0, lsl #2
	ldr	r2, [r3, lr]		@ get address of secondary function

	mov	r0, #0
	ldr	r1, =0x104d		@ Does secondary function need it?

	bx	r2
ENDPROC(sunxi_secondary_startup)

	.align
_cpus_boot_entry:
	.long .
	.long cpus_boot_entry

#ifdef CONFIG_CPU_IDLE_SUNXI
	.text
	.align 4

ENTRY(sunxi_cpux_entry_judge)
	msr	cpsr_fsxc, #0xd3	@ switch to SVC mode, disable IRQ

	mrc	p15, 0, r0, c0, c0, 5	@ get core id
	and	r0, r0, #0x3

	adr	r1, _cpux_entry_flag_array
	ldmia	r1, {r2, r3}		@ address to jump to after
	sub	lr, r1, r2		@ offset between Virt and Phy address
	add	r3, r0, lsl #2
	ldr	r2, [r3, lr]		@ get address of secondary function
	ldr	r3, [r2]
	cmp	r3, #1
	bne	__cpu_resume
	b	sunxi_secondary_startup
__cpu_resume:
	mrc	p15, 0, r1, c1, c0, 1	@ switch to SMP mode
	orr	r1, r1, #0x40
	mcr	p15, 0, r1, c1, c0, 1
	isb
	b cpu_resume
ENDPROC(sunxi_cpux_entry_judge)

	.align
_cpux_entry_flag_array:
	.long .
	.long cpux_flag_entry
#endif
