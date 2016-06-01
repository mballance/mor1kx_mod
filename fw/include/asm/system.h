/*
 * (C) Copyright 2011, Julius Baxter <julius@opencores.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 */

#ifndef __ASM_OPENRISC_SYSTEM_H
#define __ASM_OPENRISC_SYSTEM_H

#include "asm/spr-defs.h"

//static inline unsigned long mfspr(unsigned long add)
//{
//	unsigned long ret;
//
//	__asm__ __volatile__ ("l.mfspr %0,r0,%1" : "=r" (ret) : "K" (add));
//
//	return ret;
//}

//static inline void mtspr(unsigned long add, unsigned long val)
//{
//	__asm__ __volatile__ ("l.mtspr r0,%1,%0" : : "I" (add), "r" (val));
//}

// SPRGROUP_SYS = 0x00000
// SPRGROUP_DC  = 3 << 11 = 0x60000
// SPRGROUP_IC  = 4 << 11 = 0x80000
static inline void mtspr_DCBFR(unsigned long val) {
	// SPRGROUP_DC + 2 == 0x60002
	__asm__ __volatile__ ("l.mtspr r0,%0,0x60002" : : "r" (val));
}

static inline void mtspr_DCBIR(unsigned long val) {
	// SPRGROUP_DC + 3 = 0x60003
	__asm__ __volatile__ ("l.mtspr r0,%0,0x60003" : : "r" (val));
}

static inline void mtspr_ICBIR(unsigned long val) {
	// SPRGROUP_IC + 2 = 0x80002
	__asm__ __volatile__ ("l.mtspr r0,%0,0x80002" : : "r" (val));
}

static inline void mtspr_SR(unsigned long val) {
	// SPRGROUP_SYS + 17 = 0x00017
	__asm__ __volatile__ ("l.mtspr r0,%0,0x00017" : : "r" (val));
}

static inline unsigned long mfspr_DCCFGR() {
	// SPRGROUP_SYS + 5 = 0x00005
	unsigned long ret;
	__asm__ __volatile__ ("l.mfspr %0,r0,0x00005" : "=r" (ret) : );

	return ret;
}

static inline unsigned long mfspr_ICCFGR() {
	// SPRGROUP_SYS + 6 = 0x00006
	unsigned long ret;
	__asm__ __volatile__ ("l.mfspr %0,r0,0x00006" : "=r" (ret) : );

	return ret;
}

static inline unsigned long mfspr_SR() {
	// SPRGROUP_SYS + 17 = 0x00017
	unsigned long ret;
	__asm__ __volatile__ ("l.mfspr %0,r0,0x00017" : "=r" (ret) : );

	return ret;
}

static inline unsigned long mfspr_UPR() {
	// SPRGROUP_SYS + 1 = 0x00001
	unsigned long ret;
	__asm__ __volatile__ ("l.mfspr %0,r0,0x00001" : "=r" (ret) : );

	return ret;
}

#endif /* __ASM_OPENRISC_SYSTEM_H */
