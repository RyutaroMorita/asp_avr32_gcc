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
 *  上記著作権者は，以下の(1)〜(4)の条件を満たす場合に限り，本ソフトウェ
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
 *		プロセッサ依存モジュール（AVR32UC3用）
 *
 *  このインクルードファイルは，target_config.h（または，そこからインク
 *  ルードされるファイル）のみからインクルードされる．他のファイルから
 *  直接インクルードしてはならない．
 */

#ifndef TOPPERS_PRC_CONFIG_H
#define TOPPERS_PRC_CONFIG_H

#ifndef TOPPERS_MACRO_ONLY

/*
 *  プロセッサの特殊命令のインライン関数定義
 */
#include "prc_insn.h"

/*
 *  非タスクコンテキスト用のスタック初期値
 */
#define TOPPERS_ISTKPT(istk, istksz) (((STK_T *)((uint8_t *)(istk) + (istksz))))

/*
 *  タスクコンテキストブロックの定義
 */
typedef struct task_context_block {
	void	*msp;		/* スタックポインタ */
	FP		pc;			/* プログラムカウンタ */
} TSKCTXB;

#endif /* TOPPERS_MACRO_ONLY */

#ifndef TOPPERS_MACRO_ONLY

/*
 *  割込み優先度マスクの外部表現と内部表現の変換
 */
Inline PRI
EXT_IPM(uint32_t iipm)
{
	PRI pri = 0;
	switch (iipm >> 17) {
	case 0x0001U:
		pri = -1;
		break;
	case 0x0003U:
		pri = -2;
		break;
	case 0x0007U:
		pri = -3;
		break;
	case 0x000FU:
		pri = -4;
		break;
	}
	return pri;
}

Inline uint32_t
INT_IPM(PRI ipm)
{
	uint32_t ixm = 0UL;
	switch (ipm) {
	case -1:
		ixm = 0x00000001UL;
		break;
	case -2:
		ixm = 0x00000003UL;
		break;
	case -3:
		ixm = 0x00000007UL;
		break;
	case -4:
		ixm = 0x0000000FUL;
		break;
	}
	ixm = ixm << 17;
	return ixm;
}

/*
 *  IPM（ハードウェアの割込み優先度マスク，内部表現）の現在値の読出し
 */
Inline uint32_t
current_iipm(void)
{
	return(current_sr() & 0x001E0000UL);
}

/*
 *  IPM（ハードウェアの割込み優先度マスク，内部表現）の現在値の設定
 */
Inline void
set_iipm(uint32_t iipm)
{
	set_sr((current_sr() & ~0x001E0000UL) | iipm);
}

/*
 *  コンテキストの参照
 */
extern volatile int		int_cnt;
Inline bool_t
sense_context(void)
{
	return (int_cnt != 0U);
}

#endif /* TOPPERS_MACRO_ONLY */

/*
 *  CPUロック状態での割込み優先度マスク
 *
 *  TIPM_LOCKは，カーネル管理の割込みをすべてマスクする値に定義する．
 */
#if (-1 >= TMIN_INTPRI) && (TMIN_INTPRI >= -4)
#define TIPM_LOCK		TMIN_INTPRI
#else /* (-1 >= TMIN_INTPRI) && (TMIN_INTPRI >= -4) */
#error TMIN_INTPRI out of range.
#endif /* (-1 >= TMIN_INTPRI) && (TMIN_INTPRI >= -4) */

/*
 *  CPUロック状態での割込み優先度マスクの内部表現
 */
#if (TIPM_LOCK == -1)
#define IIPM_LOCK		0x00020000UL
#define IIPM_LOCK_H		0x0002U
#elif (TIPM_LOCK == -2)
#define IIPM_LOCK		0x00060000UL
#define IIPM_LOCK_H		0x0006U
#elif (TIPM_LOCK == -3)
#define IIPM_LOCK		0x000E0000UL
#define IIPM_LOCK_H		0x000EU
#else
#define IIPM_LOCK		0x001E0000UL
#define IIPM_LOCK_H		0x001EU
#endif

/*
 *  TIPM_ENAALL（割込み優先度マスク全解除）の内部表現
 */
#define IIPM_ENAALL		0x00000000UL

#ifndef TOPPERS_MACRO_ONLY

/*
 *  CPUロックフラグ実現のための変数
 *
 *  これらの変数は，CPUロック状態の時のみ書き換えてよいものとする．
 */
extern volatile bool_t		lock_flag;	/* CPUロックフラグの値を保持する変数 */
extern volatile uint16_t	saved_iipm;	/* 割込み優先度マスクを保存する変数 */

/*
 *  CPUロック状態への移行
 *
 *  IPM（ハードウェアの割込み優先度マスク）を，saved_iipmに保存し，カー
 *  ネル管理の割込みをすべてマスクする値（TIPM_LOCK）に設定する．また，
 *  lock_flagをtrueにする．
 *
 *  IPMが，最初からTIPM_LOCKと同じかそれより高い場合には，それを
 *  saved_iipmに保存するのみで，TIPM_LOCKには設定しない．これは，モデル
 *  上の割込み優先度マスクが，TIPM_LOCKと同じかそれより高いレベルに設定
 *  されている状態にあたる．
 *
 *  この関数は，CPUロック状態（lock_flagがtrueの状態）で呼ばれることは
 *  ないものと想定している．
 */
Inline void
x_lock_cpu(void)
{
	volatile uint32_t	iipm;

	/*
	 *  current_iipm()の返り値を直接saved_iipmに保存せず，一時変数iipm
	 *  を用いているのは，current_iipm()を呼んだ直後に割込みが発生し，
	 *  起動された割込み処理でsaved_iipmが変更される可能性があるためで
	 *  ある．
	 */
	iipm = current_iipm();
	if (IIPM_LOCK > iipm) {
		set_iipm(IIPM_LOCK);
	}
	saved_iipm = iipm;
	lock_flag = true;
	Asm("":::"memory");
}

#define t_lock_cpu()	x_lock_cpu()
#define i_lock_cpu()	x_lock_cpu()

/*
 *  CPUロック状態の解除
 *
 *  lock_flagをfalseにし，IPM（ハードウェアの割込み優先度マスク）を，
 *  saved_iipmに保存した値に戻す．
 *
 *  この関数は，CPUロック状態（lock_flagがtrueの状態）でのみ呼ばれるも
 *  のと想定している．
 */
Inline void
x_unlock_cpu(void)
{
	Asm("":::"memory");
	lock_flag = false;
	set_iipm(saved_iipm);
}

#define t_unlock_cpu()	x_unlock_cpu()
#define i_unlock_cpu()	x_unlock_cpu()

/*
 *  CPUロック状態の参照
 */
Inline bool_t
x_sense_lock(void)
{
	return(lock_flag);
}

#define t_sense_lock()	x_sense_lock()
#define i_sense_lock()	x_sense_lock()

/*
 *  chg_ipmで有効な割込み優先度の範囲の判定
 *
 *  TMIN_INTPRIの値によらず，chg_ipmでは，-6〜TIPM_ENAALL（＝0）の範囲
 *  に設定できることとする（ターゲット定義の拡張）．
 */
#define VALID_INTPRI_CHGIPM(intpri) \
				(-6 <= (intpri) && (intpri) <= TIPM_ENAALL)

/*
 * （モデル上の）割込み優先度マスクの設定
 *
 *  CPUロックフラグがクリアされている時は，ハードウェアの割込み優先度マ
 *  スクを設定する．CPUロックフラグがセットされている時は，saved_iipm
 *  を設定し，さらに，ハードウェアの割込み優先度マスクを，設定しようと
 *  した（モデル上の）割込み優先度マスクとTIPM_LOCKの高い方に設定する．
 */
Inline void
x_set_ipm(PRI intpri)
{
	uint32_t	iipm = INT_IPM(intpri);

	if (!lock_flag) {
		set_iipm(iipm);
	}
	else {
		saved_iipm = iipm;
		set_iipm(iipm > IIPM_LOCK ? iipm : IIPM_LOCK);
	}
}

#define t_set_ipm(intpri)	x_set_ipm(intpri)
#define i_set_ipm(intpri)	x_set_ipm(intpri)

/*
 * （モデル上の）割込み優先度マスクの参照
 *
 *  CPUロックフラグがクリアされている時はハードウェアの割込み優先度マ
 *  スクを，セットされている時はsaved_iipmを参照する．
 */
Inline PRI
x_get_ipm(void)
{
	uint16_t	iipm;

	if (!lock_flag) {
		iipm = current_iipm();
	}
	else {
		iipm = saved_iipm;
	}
	return(EXT_IPM(iipm));
}

#define t_get_ipm()		x_get_ipm()
#define i_get_ipm()		x_get_ipm()

/*
 *  最高優先順位タスクへのディスパッチ（prc_support.S）
 *
 *  dispatchは，タスクコンテキストから呼び出されたサービスコール処理か
 *  ら呼び出すべきもので，タスクコンテキスト・CPUロック状態・ディスパッ
 *  チ許可状態・（モデル上の）割込み優先度マスク全解除状態で呼び出さな
 *  ければならない．
 */
extern void	dispatch(void);

/*
 *  ディスパッチャの動作開始（prc_support.S）
 *
 *  start_dispatchは，カーネル起動時に呼び出すべきもので，すべての割込
 *  みを禁止した状態（割込みロック状態と同等の状態）で呼び出さなければ
 *  ならない．
 */
extern void	start_dispatch(void) NoReturn;

/*
 *  現在のコンテキストを捨ててディスパッチ（prc_support.S）
 *
 *  exit_and_dispatchは，ext_tskから呼び出すべきもので，タスクコンテキ
 *  スト・CPUロック状態・ディスパッチ許可状態・（モデル上の）割込み優先
 *  度マスク全解除状態で呼び出さなければならない．
 */
extern void	exit_and_dispatch(void) NoReturn;

/*
 *  カーネルの終了処理の呼出し（prc_support.S）
 *
 *  call_exit_kernelは，カーネルの終了時に呼び出すべきもので，非タスク
 *  コンテキストに切り換えて，カーネルの終了処理（exit_kernel）を呼び出
 *  す．
 */
extern void call_exit_kernel(void) NoReturn;

/*
 *  タスクコンテキストの初期化
 *
 *  タスクが休止状態から実行できる状態に移行する時に呼ばれる．この時点
 *  でスタック領域を使ってはならない．
 *
 *  activate_contextを，インライン関数ではなくマクロ定義としているのは，
 *  この時点ではTCBが定義されていないためである．
 */
extern void	start_r(void);

#define activate_context(p_tcb)											\
{																		\
	(p_tcb)->tskctxb.msp = (void *)((char *)((p_tcb)->p_tinib->stk)		\
										+ (p_tcb)->p_tinib->stksz);		\
	(p_tcb)->tskctxb.pc = (void *) start_r;								\
}

/*
 *  calltexは使用しない
 */
#define OMIT_CALLTEX

/*
 *  割込みハンドラの出入口処理の生成
 */

/*
 *  割込みハンドラの出入口処理のラベルを作るマクロ
 */
#define INT_ENTRY(inhno, inthdr)	inthdr

/*
 *  LOG_INH_ENTERがマクロ定義されている場合に，CALL_LOG_INH_ENTERを，
 *  inhno_numをパラメータとしてlog_inh_enterを呼び出すアセンブリ言語コー
 *  ドにマクロ定義する．
 */
#define CALL_LOG_INH_ENTER(inhno_num)

/*
 *  LOG_INH_LEAVEがマクロ定義されていない場合の割込みハンドラの出入口処
 *  理．戻り番地としてret_intをスタックに積んだ後，割込みハンドラの起動
 *  番地に分岐する．割込みハンドラからのリターンにより，ret_intへ分岐す
 *  る．
 */
#define INTHDR_ENTRY(inhno, inhno_num, inthdr) extern void inthdr(void);

/*
 *  CPU例外ハンドラの出入口処理の生成
 */

/*
 *  CPU例外ハンドラの出入口処理のラベルを作るマクロ
 */
#define EXC_ENTRY(excno, exchdr)	exchdr

/*
 *  CPU例外ハンドラの出入口処理
 */
#define EXCHDR_ENTRY(excno, excno_num, exchdr) extern void exchdr(void *p_excinf);

/*
 *  CPU例外の発生した時のコンテキストの参照
 *
 *  CPU例外の発生した時のコンテキストが，タスクコンテキストの時にfalse，
 *  そうでない時にtrueを返す．
 */
Inline bool_t
exc_sense_context(void *p_excinf)
{
	/*
	 *  ネストカウンタが1より大なら非タスクコンテキスト
	 */
	return (int_cnt > 1U);
}

/*
 *  CPU例外の発生した時のIPM（ハードウェアの割込み優先度マスク，内部表
 *  現）の参照
 */
Inline uint16_t
exc_get_iipm(void *p_excinf)
{
	uint32_t iipm = *((uint32_t *) p_excinf);
	iipm = iipm & 0x001E0000UL;
	iipm /= 0x10000UL;
	return (uint16_t)iipm;
}

/*
 *  CPU例外の発生した時のコンテキストと割込みのマスク状態の参照
 *
 *  CPU例外の発生した時のシステム状態が，カーネル実行中でなく，タスクコ
 *  ンテキストであり，全割込みロック状態でなく，CPUロック状態でなく，割
 *  込み優先度マスク全解除状態である時にtrue，そうでない時にfalseを返す
 *  （CPU例外がカーネル管理外の割込み処理中で発生した場合にもfalseを返
 *  す）．
 */
Inline bool_t
exc_sense_intmask(void *p_excinf)
{
	return(!exc_sense_context(p_excinf)
					&& exc_get_iipm(p_excinf) == IIPM_ENAALL);
}

/*
 *  プロセッサ依存の初期化
 */
extern void	prc_initialize(void);

/*
 *  プロセッサ依存の終了時処理
 */
extern void	prc_terminate(void);

/*
 * 未登録の割込みが発生した場合に呼び出される
 */
extern void default_int_handler(void);

#endif /* TOPPERS_MACRO_ONLY */
#endif /* TOPPERS_PRC_CONFIG_H */
