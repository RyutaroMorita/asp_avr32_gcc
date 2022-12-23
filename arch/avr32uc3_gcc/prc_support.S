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
 *		プロセッサ依存モジュール アセンブリ言語部（AVR32UC3用）
 */

#include <avr32/io.h>

#define	TOPPERS_MACRO_ONLY
#define UINT_C(val)			(val)		/* uint_t型の定数を作るマクロ */
#define ULONG_C(val)		(val)		/* ulong_t型の定数を作るマクロ */
#define CAST(type, val)		(val)		/* 型キャストを行うマクロ */
#include "kernel_impl.h"
#include "offset.h"

/*
 *  タスクディスパッチャ
 */
	.text
	.globl dispatch
dispatch:
	/*
	 *  このルーチンは，タスクコンテキスト・CPUロック状態・ディスパッチ
	 *  許可状態・（モデル上の）割込み優先度マスク全解除状態で呼び出さ
	 *  れる．
	 */
	pushm	r0-r3, r4-r7, lr			/* レジスタを保存 */

	lda.w	r9, p_runtsk
	ld.w	r8, r9[0]					/* p_runtskをr8に */
	st.w	r8[TCB_msp], sp				/* タスクスタックを保存 */
	lda.w	r9, dispatch_r
	st.w	r8[TCB_pc], r9				/* 実行再開番地を保存 */
	rjmp	dispatcher

dispatch_r:
	/*
	 *  SRのモードフラグSR[M2:M0]をB'001に設定しスーパーバイザーモード
	 *  へ移行する．
	 */
	ssrf	AVR32_SR_M0_OFFSET
	csrf	AVR32_SR_M1_OFFSET
	csrf	AVR32_SR_M2_OFFSET
	popm	r0-r3, r4-r7, lr			/* レジスタを復帰 */

	ld.uh	r9, r8[TCB_enatex]
	bld		r9, TCB_enatex_bit
	brne	dispatch_r_1				/* enatexがfalseならリターン */

	ld.w	r9, r8[TCB_texptn]
	cp.w	r9, 0
	brne	dispatch_r_1				/* texptnが0ならリターン */

	lda.w	r9, ipmflg
	ld.w	r10, r9[0]
	cp.w	r0, 0						/* ipmflgがtrueであれば            */
	brne	call_texrtn					/*  タスク例外処理ルーチンの呼出し */

dispatch_r_1:
	mov		pc, lr

/*
 *  ディスパッチャの動作開始（prc_support.S）
 */
	.globl start_dispatch
start_dispatch:
	/*
	 *  このルーチンは，カーネル起動時に，すべての割込みを禁止した状態
	 * （割込みロック状態と同等）で呼び出される．また，割込みモード（非
	 *  タスクコンテキストと同等）で呼び出されることを想定している．
	 *
	 *  prc_initializeで，lock_flagをtrueに，saved_iipmをIIPM_ENAALLに
	 *  初期化しているため，カーネル管理外の割込みを許可することで，
	 *  CPUロック状態・（モデル上の）割込み優先度マスク全解除状態になる．
	 *  また，initialize_taskでdisdspをfalseに初期化しているため，ディ
	 *  スパッチ許可状態になっている．
	 */
	lda.w	r9, int_cnt					/* マスタモードに */
	mov		r10, 0						/* マスタモード・                */
	st.w	r9[0], r10
	movh	r9, 0x001E
	com		r9
	mfsr	r10, AVR32_SR
	and		r9, r10
	movh	r10, IIPM_LOCK_H
	or		r9, r10
	mtsr	AVR32_SR, r9				/*  カーネル管理外の割込みを許可 */
	rjmp	dispatcher_0

/*
 *  現在のコンテキストを捨ててディスパッチ
 */
	.globl exit_and_dispatch
exit_and_dispatch:
	/* ディスパッチャ本体（dispatcher）へ */

/*
 *  ディスパッチャ本体
 */
dispatcher:
	/*
	 *  このルーチンは，タスクコンテキスト・CPUロック状態・ディスパッチ
	 *  許可状態・（モデル上の）割込み優先度マスク全解除状態で呼び出さ
	 *  れる．
	 *
	 *  すなわち，マスタモード・lock_flagがtrue・disdspがfalse・dspflg
	 *  がtrue・saved_iipmがIIPM_ENAALLとなっている．実行再開番地へもこ
	 *  の状態のまま分岐する．
	 */
#ifdef LOG_DSP_ENTER
	lda.w	r8, p_runtsk				/* p_runtskをパラメータに */
	ld.w	r12, r8[0]
	call	log_dsp_enter

#endif /* LOG_DSP_ENTER */

dispatcher_0:
	lda.w	r9, p_schedtsk				/* p_schedtskをp_runtskに */
	ld.w	r8, r9[0]
	lda.w	r9, p_runtsk
	st.w	r9[0], r8
	cp.w	r8, 0
	breq	dispatcher_1				/* p_runtskがNULLならdispatcher_1へ */

	ld.w	sp, r8[TCB_msp]				/* タスクスタックを復帰 */
#ifdef LOG_DSP_LEAVE
	stm		--sp, r8
	ld.w	r12, r8[0]
	call	log_dsp_enter

	ldm		sp++, r8
#endif /* LOG_DSP_LEAVE */

	ld.w	r9, r8[TCB_pc]
	mov		pc,	r9
dispatcher_1:
	/*
	 *  CPUロック状態を解除する準備をする．
	 */
	lda.w	r9, int_cnt					/* 割込みモードに */
	mov		r10, 1
	st.w	r9[0], r10
	lda.w	r8, _kernel_istkpt
	ld.w	sp, r8[0]
	mfsr	r8, AVR32_SR				/* SRをr8に保存 */
	lda.w	r9, lock_flag				/* 割込みモードに */
	mov		r10, 0
	st.w	r9[0], r10					/* CPUロック解除状態に */
dispatcher_2:
	/*
	 *  割込みを許可し，割込みモードに切り換えて，割込みを待つ．
	 *
	 *  ここで割込みモードに切り換えるのは，ここで発生する割込み処理に
	 *  どのスタックを使うかという問題の解決と，割込みハンドラ内でのタ
	 *  スクディスパッチの防止という2つの意味がある．
	 *
	 *  プロセッサを割込み待ちに移行させる処理と，割込み許可とは，不可
	 *  分に行なう必要がある．これを不可分に行なわない場合，割込みを許
	 *  可した直後に割込みが入り，その中でタスクが実行可能状態になると
	 *  実行すべきタスクがあるにもかかわらずプロセッサが割込み待ちにな
	 *  ってしまう．
	 *
	 *  割込み待ちの間は，p_runtskをNULL（＝0）に設定しなければならな
	 *  い．このように設定しないと，割込みハンドラからiget_tidを呼び出
	 *  した際の動作が仕様に合致しなくなる．
	 */
	mfsr	r9, AVR32_SR
	movh	r10, 0x001E
	com		r10
	and		r10, r9
	mtsr	AVR32_SR, r10
	movh	r10, 0x001E
	or		r10, r9
	mtsr	AVR32_SR, r10
	lda.w	r9, reqflg
	ld.w	r10, r9[0]
	cp.w	r10, 0						/* reqflgがfalseならdispatcher_2へ */
	breq	dispatcher_2
	mtsr	AVR32_SR, r8				/* 元の状態に戻す */
	mov		r10, 0
	st.w	r9[0], r10					/* reqflgをfalseに */
	/*
	 *  CPUロック状態に戻す．割込み待ちの間に実行した割込みハンドラによ
	 *  り，saved_iipmが書き換えられる可能性があるため，元の値に戻す必
	 *  要がある．dispatcherが実行される時は，saved_iipmがIIPM_ENAALL
	 *  となっているため，ここではsaved_iipmをIIPM_ENAALL（＝0）に戻せ
	 *  ばよい．
	 */
	lda.w	r9, int_cnt					/* マスタモードに */
	mov		r10, 0
	st.w	r9[0], r10
	lda.w	r9, saved_iipm				/* saved_iipmを0にする */
	st.w	r9[0], r10
	lda.w	r9, lock_flag				/* CPUロック状態に */
	mov		r10, 1
	st.w	r9[0], r10
	rjmp	dispatcher_0

/*
 *  カーネルの終了処理の呼出し
 */
	.globl call_exit_kernel
call_exit_kernel:
	lda.w	r9, int_cnt					/* 割込みモードに */
	mov		r10, 1
	st.w	r9[0], r10
	lda.w	r8, _kernel_istkpt
	ld.w	sp, r8[0]
	rjmp	exit_kernel					/* カーネルの終了処理を呼ぶ */

/*
 *  タスク開始時処理
 */
	.text
	.globl start_r
start_r:
	lda.w	r9, lock_flag				/* CPUロック解除状態に */
	mov		r10, 0
	st.w	r9[0], r10
	csrf	AVR32_SR_GM_OFFSET
	ld.w	r9, r8[TCB_p_tinib]			/* p_runtsk->p_tinibをr9に */
	ld.w	r12, r9[TINIB_exinf]
	lda.w	lr, ext_tsk
	ld.w	r8, r9[TINIB_task]			/* タスクの起動番地をr8に */
	mov		pc, r8

/*
 *  割込みエントリ（r12にLevel番号が入る）
 */
	.global inthdr_entry
inthdr_entry:
	lda.w	r9, int_cnt					/* 割込みモードに */
	ld.w	r8, r9[0]
	sub		r8, -1
	st.w	r9[0], r8
	cp.w	r8, 1
	brne	inthdr_entry_0_d			/* 加算前が0でなければ多重割込み */

	lda.w	r9, int_sp
	st.w	r9[0], sp
	lda.w	r8, _kernel_istkpt			/* 割込み用のスタックへ切替え */
	ld.w	sp, r8[0]
	rjmp	inthdr_entry_0

inthdr_entry_0_d:
	rjmp	inthdr_entry_0

inthdr_entry_0:
	call	_get_interrupt_handler
	cp.w	r12, 0
	brne	inthdr_entry_1

	call	default_int_handler

inthdr_entry_1:
#ifdef LOG_INH_ENTER
	//
#endif /* LOG_EXC_ENTER */

	icall	r12

#ifdef LOG_INH_LEAVE
	//
#endif /* LOG_EXC_ENTER */

/*
 *  割込みハンドラ出口処理
 *
 *  ret_intは，割込みハンドラから戻った直後に実行するルーチンで，
 *  INTHDR_ENTRYマクロで展開する割込みハンドラの入口処理で，割込みハン
 *  ドラからの戻り番地に設定される．
 */
	.text
	.globl ret_int
ret_int:
	lda.w	r9, int_cnt					/* 割込みモードに */
	ld.w	r8, r9[0]
	sub		r8, 1
	st.w	r9[0], r8					/* 戻り先が割込みモードなら */
	brne	ret_int_1_d					/*           すぐにリターン */

	/*
	 *  カーネル管理の割込みを禁止する．この時点では，CPUロック状態に
	 *  はならない（lock_flagとsaved_iipmは更新しない）．
	 *
	 *  reqflgをチェックする前に割込みを禁止するのは，reqflgをチェック
	 *  した直後に割込みハンドラが起動され，その中でディスパッチが要求
	 *  された場合に，すぐにディスパッチされないという問題が生じるため
	 *  である．
	 */
	/*
	 *  このルーチンはカーネル管理の割込みから起動されるため，ここでは，
	 *  割込み優先度マスクがTIPM_LOCKよりも低いと想定できる．
	 */
	movh	r9, 0x001E
	com		r9
	mfsr	r10, AVR32_SR
	and		r9, r10
	movh	r10, IIPM_LOCK_H
	or		r9, r10
	mtsr	AVR32_SR, r9
	lda.w	r9, reqflg
	ld.w	r8, r9[0]
	cp.w	r8, 0						/* reqflgがtrueであればret_int_2へ */
	brne	ret_int_2

	lda.w	r9, int_sp					/* マスタモードに（スタック切換え） */
	ld.w	sp, r9[0]
ret_int_1:
	/*
	 *  割込み処理からのリターンにより，CPUロック解除状態に移行するよう
	 *  準備する．割込み優先度マスクは，RTE命令により元の値に戻るため，
	 *  lock_flagをfalseにしておけばよい（lock_flagをfalseにするのは，
	 *  CPUロック状態のまま割込みハンドラから戻った時の対策）．
	 */
	lda.w	r9, lock_flag				/* CPUロック解除の準備 */
	mov		r10, 0
	st.w	r9[0], r10
	rete

ret_int_1_d:
	rjmp	ret_int_1

ret_int_2:
	lda.w	r9, int_sp					/* マスタモードに（スタック切換え） */
	ld.w	sp, r9[0]
ret_int_3:
	/*
	 *  ここへは，CPU例外ハンドラの出口処理からも分岐してくる．
	 *
	 *  ここでは，戻り先がタスクであり，スタックは，例外スタックフレー
	 *  ムの上にスクラッチレジスタのみが保存された状態になっている．ま
	 *  た，プロセッサは，マスタモード・カーネル管理の割込みを禁止した
	 *  状態となっている．
	 */
	lda.w	r9, reqflg
	mov		r10, 0
	st.w	r9[0], r10					/* reqflgをfalseに */
	/*
	 *  CPUロック状態に移行し，割込み優先度マスクを割込み処理前の値に設
	 *	定する．カーネル管理の割込みはすでに禁止しているので，lock_flag
	 *  とsaved_iipmを更新する．saved_iipmは，戻り先の割込み優先度マス
	 *  ク（の内部表現）に設定する．
	 *
	 *  この時点でCPUロック状態とするのは，dispatcherへ分岐する時と，
	 *  call_texrtnを呼び出す時に，CPUロック状態になっている必要がある
	 *  ためである．
	 */
	ld.w	r8, sp[0]					/* 戻り先のSRをr8に */
	movh	r9, 0x001E					/* IPMを取り出してsaved_iipmに */
	and		r8, r9
	lda.w	r9, saved_iipm
	st.w	r9[0], r8
	lda.w	r9, lock_flag
	mov		r10, 1
	st.w	r9[0], r10					/* lock_flagをtrueに */
	/*
	 *  dspflgがfalseである場合と，p_runtskとp_schedtskが同じ場合には，
	 *  ディスパッチを行わない．このチェックが必要なのは，タスク例外処
	 *  理ルーチンの呼出しが必要な場合に，ディスパッチが必要なくても，
	 *  reqflgをtrueにするためである．
	 */
	lda.w	r9, p_runtsk				/* p_runtskをr8に */
	ld.w	r8, r9[0]
	lda.w	r9, dspflg					/* dspflgがfalseならret_int_4へ */
	ld.w	r10, r9[0]
	cp.w	r10, 0
	breq	ret_int_4

	lda.w	r9, p_schedtsk				/* p_runtskとp_schedtskが同じなら */
	ld.w	r10, r9[0]
	cp.w	r8, r10
	breq	ret_int_4					/*                    ret_int_4へ */

	pushm	r0-r3, r4-r7, lr			/* 残りのレジスタを保存*/

	st.w	r8[TCB_msp], sp				/* タスクスタックを保存 */
	lda.w	r9, ret_int_r				/* 実行再開番地を保存 */
	st.w	r8[TCB_pc], r9
	rjmp	dispatcher

ret_int_r:
	/*
	 *  SRのモードフラグSR[M2:M0]をB'010,B'011,B'100,B'101のいずれかに
	 *  設定する．
	 *  これら以外の値が設定されている場合は後のrete命令でR8-R12, LRの
	 *  復帰が行われない．(ここでは，B'010に設定している．)
	 */
	csrf	AVR32_SR_M0_OFFSET
	ssrf	AVR32_SR_M1_OFFSET
	csrf	AVR32_SR_M2_OFFSET
	popm	r0-r3, r4-r7, lr			/* レジスタを復帰 */
ret_int_4:
	/*
	 *  enatexがtrueで，texptnが0でなく，ipmflgがtrueであれば，タスク
	 *  例外処理ルーチンを呼び出す．
	 */
	ld.uh	r9, r8[TCB_enatex]
	bld		r9, TCB_enatex_bit
	breq	ret_int_5					/* enatexがfalseならret_int_5へ */

	ld.w	r9, r8[TCB_texptn]
	cp.w	r9, 0						/* texptnが0ならret_int_5へ */
	breq	ret_int_5

	lda.w	r9, ipmflg
	ld.w	r10, r9[0]
	cp.w	r10, 0						/* ipmflgがfalseならret_int_5へ */
	breq	ret_int_5

	call	call_texrtn					/* タスク例外処理ルーチンの呼出し */

ret_int_5:
	/*
	 *  割込み処理からのリターンにより，CPUロック解除状態に移行するよ
	 *  う準備する．割込み優先度マスクは，RTE命令により元の値に戻るた
	 *  め，lock_flagをfalseにしておけばよい．
	 */
	lda.w	r9, lock_flag				/* CPUロック解除の準備 */
	mov		r10, 0
	st.w	r9[0], r10
	rete
