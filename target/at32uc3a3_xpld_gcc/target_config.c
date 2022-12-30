/*
 *  TOPPERS/ASP Kernel
 *      Toyohashi Open Platform for Embedded Real-Time Systems/
 *      Advanced Standard Profile Kernel
 *
 *  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
 *                              Toyohashi Univ. of Technology, JAPAN
 *  Copyright (C) 2005-2011 by Embedded and Real-Time Systems Laboratory
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
 *		ターゲット依存モジュール（AT32UC3A3_XPLD用）
 */

#include "kernel_impl.h"
#include <sil.h>
#include <asf.h>

FP exc_handler_table[EXCNO_MAX + 1];

/*
 *  プロセッサ識別のための変数（マルチプロセッサ対応）
 */
uint_t	board_id;			/* ボードID */
void	*board_addr;		/* ローカルメモリの先頭アドレス */

void
usart_early_init()
{
	static usart_serial_options_t usart_options = {
		.baudrate = 9600,
		.charlength = 8,
		.paritytype = USART_NO_PARITY,
		.stopbits = false
	};

	usart_serial_init(&AVR32_USART1, &usart_options);
}

/*
 *  ターゲット依存の初期化
 */
void
target_initialize(void)
{
	int i;
	/*
	 *  プロセッサ依存の初期化
	 */
	prc_initialize();

	board_init();

	sysclk_init();

	/* CPU例外ハンドラ・テーブルの初期化 */
	for (i = 0; i < (EXCNO_MAX + 1); i++)
		exc_handler_table[i] = NULL;

	INTC_init_interrupts();

	usart_early_init();
}

/*
 *  ターゲット依存の終了処理
 */
void
target_exit(void)
{
	/*
	 *  プロセッサ依存の終了処理
	 */
	prc_terminate();

	while(1);
}

/*
 *  システムログの低レベル出力のための文字出力
 */
void
target_fput_log(char c)
{
	if (c == '\n') {
		usart_serial_putchar(&AVR32_USART1, '\r');
	}
	usart_serial_putchar(&AVR32_USART1, c);
}

/*
 *
 */
void* target_get_exception_handler(uint32_t excno)
{
	return exc_handler_table[excno];
}

/*
 *  割込みハンドラの設定
 *
 *  ベクトル番号inhnoの割込みハンドラの出入口処理の番地をint_entryに設
 *  定する．
 */
void
x_define_inh(INHNO inhno, FP int_entry)
{
	assert(VALID_INHNO_DEFINH(inhno));
	INTC_register_interrupt((__int_handler)int_entry, inhno, AVR32_INTC_INT0);
}

/*
 *  CPU例外ハンドラの設定
 *
 *  ベクトル番号excnoのCPU例外ハンドラの出入口処理の番地をexc_entryに設
 *  定する．
 */
void
x_define_exc(EXCNO excno, FP exc_entry)
{
	assert(VALID_EXCNO_DEFEXC(excno));
	exc_handler_table[excno] = exc_entry;
}

/*
 *  割込み要求ラインの属性の設定
 *
 *  ASPカーネルでの利用を想定して，パラメータエラーはアサーションでチェッ
 *  クしている．cfg_intサービスコールを設ける場合には，エラーを返すよう
 *  にすべきであろう．
 */
extern void _evba, _int0, _int1, _int2, _int3;

#define IPR_INT0   ((AVR32_INTC_INT0 << AVR32_INTC_IPR_INTLEVEL_OFFSET) \
			| ((int)&_int0 - (int)&_evba))
#define IPR_INT1   ((AVR32_INTC_INT1 << AVR32_INTC_IPR_INTLEVEL_OFFSET) \
			| ((int)&_int1 - (int)&_evba))
#define IPR_INT2   ((AVR32_INTC_INT2 << AVR32_INTC_IPR_INTLEVEL_OFFSET) \
			| ((int)&_int2 - (int)&_evba))
#define IPR_INT3   ((AVR32_INTC_INT3 << AVR32_INTC_IPR_INTLEVEL_OFFSET) \
			| ((int)&_int3 - (int)&_evba))

void
x_config_int(INTNO intno, ATR intatr, PRI intpri)
{
	// Determine the group of the IRQ.
	uint32_t int_grp = intno / AVR32_INTC_MAX_NUM_IRQS_PER_GRP;

	/*
	 *  割込みのマスク
	 *
	 *  割込みを受け付けたまま，レベルトリガ／エッジトリガの設定や，割
	 *  込み優先度の設定を行うのは危険なため，割込み属性にかかわらず，
	 *  一旦マスクする．
	 */
	assert(VALID_INTNO_CFGINT(intno));
	assert(TMIN_INTPRI <= intpri && intpri <= TMAX_INTPRI);

	/* Program the corresponding IPRX register to set the interrupt priority
	level and the interrupt vector offset that will be fetched by the core
	interrupt system.
	NOTE: The _intx functions are intermediate assembly functions between
	the core interrupt system and the user interrupt handler. */
	if (intpri == -1) {
		AVR32_INTC.ipr[int_grp] = IPR_INT0;
	} else if (intpri == -2) {
		AVR32_INTC.ipr[int_grp] = IPR_INT1;
	} else if (intpri == -3) {
		AVR32_INTC.ipr[int_grp] = IPR_INT2;
	} else {
		AVR32_INTC.ipr[int_grp] = IPR_INT3;
	}
}
