/*
 *  TOPPERS/ASP Kernel
 *      Toyohashi Open Platform for Embedded Real-Time Systems/
 *      Advanced Standard Profile Kernel
 *
 *  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
 *                              Toyohashi Univ. of Technology, JAPAN
 *  Copyright (C) 2005-2010 by Embedded and Real-Time Systems Laboratory
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *
 *  上記著作権者は，以下の(1)～(4)の条件を満たす場合に限り，本ソフトウェ
 *  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
 *  変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
 *  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
 *      権表示，この利用条件および下記の無保証規定が，そのままの形でソー
 *      スコード中に含まれていること．
 *  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
 *      用できる形で再配布する場合には，再配布に伴うドキュメント（利用
 *      者マニュアルなど）に，上記の著作権表示，この利用条件および下記
 *      の無保証規定を掲載すること．
 *  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
 *      用できない形で再配布する場合には，次のいずれかの条件を満たすこ
 *      と．
 *    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
 *        作権表示，この利用条件および下記の無保証規定を掲載すること．
 *    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
 *        報告すること．
 *  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
 *      害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
 *      また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
 *      由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
 *      免責すること．
 *
 *  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
 *  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
 *  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
 *  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
 *  の責任を負わない．
 *
 *	2022/12/23 Ryutaro Morita
 */

/*
 *		ターゲット依存ベクターテーブル（AT32UC3A3-XPLD用）
 */

#include <avr32/io.h>

/*
 *  CPU例外番号
 *
 *
 *   0 - Unrecoverable exception
 *   1 - TLB multiple hit
 *   2 - Bus error data fetch
 *   3 - Bus error instruction fetch
 *   4 - NMI
 *   5 - Instruction Address
 *   6 - ITLB Protection
 *   7 - Breakpoint
 *   8 - Illegal Opcode
 *   9 - Unimplemented instruction
 *  10 - Privilege violation
 *  12 - Coprocessor absent
 *  13 - Data Address (Read)
 *  14 - Data Address (Write)
 *  15 - DTLB Protection (Read)
 *  16 - DTLB Protection (Write)
 *  20 - ITLB Miss
 *  24 - DTLB Miss (Read)
 *  28 - DTLB Miss (Write)
 *  64 - Supervisor call
 */

.section  .exception, "ax", @progbits
// Start of Exception Vector Table.
/*
 * EVBA must be aligned with a power of two strictly greater than the
 * EVBA-relative offset of the last vector.
 */
	.balign 0x200
// Export symbol.
	.global _evba
	.type _evba, @function
_evba:

	.org	0x000
	// Unrecoverable Exception.
_handle_Unrecoverable_Exception:
	lda.w   pc, _exchdr_0

	.org	0x004
	// TLB Multiple Hit.
_handle_TLB_Multiple_Hit:
	lda.w   pc, _exchdr_1

	.org	0x008
	// Bus Error Data Fetch.
_handle_Bus_Error_Data_Fetch:
	lda.w   pc, _exchdr_2

	.org	0x00C
	// Bus Error Instruction Fetch.
_handle_Bus_Error_Instruction_Fetch:
	lda.w   pc, _exchdr_3

	.org	0x010
	// NMI.
_handle_NMI:
	lda.w   pc, _exchdr_4

	.org	0x014
	// Instruction Address.
_handle_Instruction_Address:
	lda.w   pc, _exchdr_5

	.org	0x018
	// ITLB Protection.
_handle_ITLB_Protection:
	lda.w   pc, _exchdr_6

	.org	0x01C
	// Breakpoint.
_handle_Breakpoint:
	lda.w   pc, _exchdr_7

	.org	0x020
	// Illegal Opcode.
_handle_Illegal_Opcode:
	lda.w   pc, _exchdr_8

	.org	0x024
	// Unimplemented Instruction.
_handle_Unimplemented_Instruction:
	lda.w   pc, _exchdr_9

	.org	0x028
	// Privilege Violation.
_handle_Privilege_Violation:
	lda.w   pc, _exchdr_10

	.org	0x02C
	// Floating-Point: UNUSED IN AVR32UC and AVR32AP.
_handle_Floating_Point:
	rjmp	$

	.org	0x030
	// Coprocessor Absent: UNUSED IN AVR32UC.
_handle_Coprocessor_Absent:
	lda.w   pc, _exchdr_12

	.org	0x034
	// Data Address (Read).
_handle_Data_Address_Read:
	lda.w   pc, _exchdr_13

	.org	0x038
	// Data Address (Write).
_handle_Data_Address_Write:
	lda.w   pc, _exchdr_14

	.org	0x03C
	// DTLB Protection (Read).
_handle_DTLB_Protection_Read:
	lda.w   pc, _exchdr_15

	.org	0x040
	// DTLB Protection (Write).
_handle_DTLB_Protection_Write:
	lda.w   pc, _exchdr_16

	.org	0x044
	// DTLB Modified: UNUSED IN AVR32UC.
_handle_DTLB_Modified:
	rjmp	$

	.org	0x050
	// ITLB Miss.
_handle_ITLB_Miss:
	lda.w   pc, _exchdr_20

	.org	0x060
	// DTLB Miss (Read).
_handle_DTLB_Miss_Read:
	lda.w   pc, _exchdr_24

	.org	0x070
	// DTLB Miss (Write).
_handle_DTLB_Miss_Write:
	lda.w   pc, _exchdr_28

	.org	0x100
	// Supervisor Call.
_handle_Supervisor_Call:
	lda.w   pc, _exchdr_64


/*
 * Interrupt support.
 * The interrupt controller must provide the offset address relative to EVBA.
 * Important note:
 * All interrupts call a C function named _get_interrupt_handler.
 * This function will read group and interrupt line number to then return in
 *R12 a pointer to a user-provided interrupt handler.
 */
	.balign 4

	.global _int0
	.type _int0, @function
_int0:
	mov		r12, 0
	lda.w	r8, inthdr_entry
	mov		pc, r8
	rete

	.global _int1
	.type _int1, @function
_int1:
	mov		r12, 1
	lda.w	r8, inthdr_entry
	mov		pc, r8
	rete

	.global _int2
	.type _int2, @function
_int2:
	mov		r12, 2
	lda.w	r8, inthdr_entry
	mov		pc, r8
	rete

	.global _int3
	.type _int3, @function
_int3:
	mov		r12, 3
	lda.w	r8, inthdr_entry
	mov		pc, r8
	rete

.section  .text

	.global _exchdr_0
	.type _exchdr_0, @function
_exchdr_0:
	mov		r12, 0
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_1
	.type _exchdr_1, @function
_exchdr_1:
	mov		r12, 1
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_2
	.type _exchdr_2, @function
_exchdr_2:
	mov		r12, 2
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_3
	.type _exchdr_3, @function
_exchdr_3:
	mov		r12, 3
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_4
	.type _exchdr_4, @function
_exchdr_4:
	mov		r12, 4
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_5
	.type _exchdr_5, @function
_exchdr_5:
	mov		r12, 5
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_6
	.type _exchdr_6, @function
_exchdr_6:
	mov		r12, 6
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_7
	.type _exchdr_7, @function
_exchdr_7:
	mov		r12, 7
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_8
	.type _exchdr_8, @function
_exchdr_8:
	mov		r12, 8
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_9
	.type _exchdr_9, @function
_exchdr_9:
	mov		r12, 9
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_10
	.type _exchdr_10, @function
_exchdr_10:
	mov		r12, 10
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_11
	.type _exchdr_11, @function
_exchdr_11:
	mov		r12, 11
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_12
	.type _exchdr_12, @function
_exchdr_12:
	mov		r12, 12
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_13
	.type _exchdr_13, @function
_exchdr_13:
	mov		r12, 13
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_14
	.type _exchdr_14, @function
_exchdr_14:
	mov		r12, 14
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_15
	.type _exchdr_15, @function
_exchdr_15:
	mov		r12, 15
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_16
	.type _exchdr_16, @function
_exchdr_16:
	mov		r12, 16
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_20
	.type _exchdr_20, @function
_exchdr_20:
	mov		r12, 20
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_24
	.type _exchdr_24, @function
_exchdr_24:
	mov		r12, 24
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_28
	.type _exchdr_28, @function
_exchdr_28:
	mov		r12, 28
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete

	.global _exchdr_64
	.type _exchdr_64, @function
_exchdr_64:
	mov		r12, 64
	lda.w	r8, exchdr_entry
	mov		pc, r8
	rete
