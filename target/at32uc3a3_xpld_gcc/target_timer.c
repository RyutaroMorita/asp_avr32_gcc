/*
 *  TOPPERS/ASP Kernel
 *      Toyohashi Open Platform for Embedded Real-Time Systems/
 *      Advanced Standard Profile Kernel
 *
 *  Copyright (C) 2005,2006 by Embedded and Real-Time Systems Laboratory
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
 *		タイマドライバ（AT32UC3A3_XPLD用）
 */

#include "kernel_impl.h"
#include "time_event.h"
#include <sil.h>
#include "target_timer.h"

#define TC_CHANNEL    0

/*
 *  タイマの起動処理
 */
void
target_timer_initialize(intptr_t exinf)
{
	CLOCK	cyc = TO_CLOCK(TIC_NUME, TIC_DENO);

	// Options for waveform genration.
	static const tc_waveform_opt_t WAVEFORM_OPT =
	{
		.channel	= TC_CHANNEL,							// Channel selection.

		.bswtrg		= TC_EVT_EFFECT_NOOP,					// Software trigger effect on TIOB.
		.beevt		= TC_EVT_EFFECT_NOOP,					// External event effect on TIOB.
		.bcpc		= TC_EVT_EFFECT_TOGGLE,					// RC compare effect on TIOB.
		.bcpb		= TC_EVT_EFFECT_TOGGLE,					// RB compare effect on TIOB.

		.aswtrg		= TC_EVT_EFFECT_NOOP,					// Software trigger effect on TIOA.
		.aeevt		= TC_EVT_EFFECT_NOOP,					// External event effect on TIOA.
		.acpc		= TC_EVT_EFFECT_TOGGLE,					// RC compare effect on TIOA: toggle.
		.acpa		= TC_EVT_EFFECT_TOGGLE,					// RA compare effect on TIOA: toggle (other possibilities are none, set and clear).

		.wavsel		= TC_WAVEFORM_SEL_UP_MODE_RC_TRIGGER,	// Waveform selection: Up mode with automatic trigger(reset) on RC compare.
		.enetrg		= false,								// External event trigger enable.
		.eevt		= 0,									// External event selection.
		.eevtedg	= TC_SEL_NO_EDGE,						// External event edge selection.
		.cpcdis		= false,								// Counter disable when RC compare.
		.cpcstop	= false,								// Counter clock stopped with RC compare.

		.burst		= false,								// Burst signal selection.
		.clki		= false,								// Clock inversion.
		.tcclks		= TC_CLOCK_SOURCE_TC4					// Internal source clock 4, connected to fPBA / 32.
	};

	static const tc_interrupt_t TC_INTERRUPT =
	{
		.etrgs = 0,
		.ldrbs = 0,
		.ldras = 0,
		.cpcs  = 1,
		.cpbs  = 0,
		.cpas  = 0,
		.lovrs = 0,
		.covfs = 0
	};

	/*
	 *  タイマ周期を設定し，タイマの動作を開始する．
	 */
	assert(cyc <= MAX_CLOCK);

	// Initialize the timer/counter.
	tc_init_waveform(&AVR32_TC0, &WAVEFORM_OPT);		 // Initialize the timer/counter waveform.

	// Set the compare triggers.
	// Remember TC counter is 16-bits, so counting second is not possible with fPBA = 84 MHz.
	// We configure it to count ms.
	// We want: (1/(fPBA/32)) * RC = 0.01 s, hence RC = (fPBA/32) / 1000 = 2625 to get an interrupt every 1 ms.
	tc_write_rc(&AVR32_TC0, TC_CHANNEL, cyc); // Set RC value

	tc_configure_interrupts(&AVR32_TC0, TC_CHANNEL, &TC_INTERRUPT);

	// Start the timer/counter.
	tc_start(&AVR32_TC0, TC_CHANNEL);					// And start the timer/counter.

	/*
	 *  タイマ割込み要求をクリアする．
	 */
	x_clear_int(INTNO_TIMER);
}

/*
 *  タイマの停止処理
 */
void
target_timer_terminate(intptr_t exinf)
{
	/*
	 *  タイマの動作を停止する．
	 */
	// Stop the timer/counter.
	tc_stop(&AVR32_TC0, TC_CHANNEL);
}

/*
 *  タイマ割込みハンドラ
 */
void
target_timer_handler(void)
{
	i_begin_int(INTNO_TIMER);
	tc_read_sr(&AVR32_TC0, TC_CHANNEL);
	signal_time();					/* タイムティックの供給 */
	i_end_int(INTNO_TIMER);
}
