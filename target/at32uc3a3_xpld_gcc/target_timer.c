/*
 *  TOPPERS/ASP Kernel
 *      Toyohashi Open Platform for Embedded Real-Time Systems/
 *      Advanced Standard Profile Kernel
 *
 *  Copyright (C) 2005,2006 by Embedded and Real-Time Systems Laboratory
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *
 *  ��L���쌠�҂́C�ȉ���(1)�`(4)�̏����𖞂����ꍇ�Ɍ���C�{�\�t�g�E�F
 *  �A�i�{�\�t�g�E�F�A�����ς������̂��܂ށD�ȉ������j���g�p�E�����E��
 *  �ρE�Ĕz�z�i�ȉ��C���p�ƌĂԁj���邱�Ƃ𖳏��ŋ�������D
 *  (1) �{�\�t�g�E�F�A���\�[�X�R�[�h�̌`�ŗ��p����ꍇ�ɂ́C��L�̒���
 *      ���\���C���̗��p��������щ��L�̖��ۏ؋K�肪�C���̂܂܂̌`�Ń\�[
 *      �X�R�[�h���Ɋ܂܂�Ă��邱�ƁD
 *  (2) �{�\�t�g�E�F�A���C���C�u�����`���ȂǁC���̃\�t�g�E�F�A�J���Ɏg
 *      �p�ł���`�ōĔz�z����ꍇ�ɂ́C�Ĕz�z�ɔ����h�L�������g�i���p
 *      �҃}�j���A���Ȃǁj�ɁC��L�̒��쌠�\���C���̗��p��������щ��L
 *      �̖��ۏ؋K����f�ڂ��邱�ƁD
 *  (3) �{�\�t�g�E�F�A���C�@��ɑg�ݍ��ނȂǁC���̃\�t�g�E�F�A�J���Ɏg
 *      �p�ł��Ȃ��`�ōĔz�z����ꍇ�ɂ́C���̂����ꂩ�̏����𖞂�����
 *      �ƁD
 *    (a) �Ĕz�z�ɔ����h�L�������g�i���p�҃}�j���A���Ȃǁj�ɁC��L�̒�
 *        �쌠�\���C���̗��p��������щ��L�̖��ۏ؋K����f�ڂ��邱�ƁD
 *    (b) �Ĕz�z�̌`�Ԃ��C�ʂɒ�߂���@�ɂ���āCTOPPERS�v���W�F�N�g��
 *        �񍐂��邱�ƁD
 *  (4) �{�\�t�g�E�F�A�̗��p�ɂ�蒼�ړI�܂��͊ԐړI�ɐ����邢���Ȃ鑹
 *      �Q������C��L���쌠�҂����TOPPERS�v���W�F�N�g��Ɛӂ��邱�ƁD
 *      �܂��C�{�\�t�g�E�F�A�̃��[�U�܂��̓G���h���[�U����̂����Ȃ闝
 *      �R�Ɋ�Â�����������C��L���쌠�҂����TOPPERS�v���W�F�N�g��
 *      �Ɛӂ��邱�ƁD
 *
 *  �{�\�t�g�E�F�A�́C���ۏ؂Œ񋟂���Ă�����̂ł���D��L���쌠�҂�
 *  ���TOPPERS�v���W�F�N�g�́C�{�\�t�g�E�F�A�Ɋւ��āC����̎g�p�ړI
 *  �ɑ΂���K�������܂߂āC�����Ȃ�ۏ؂��s��Ȃ��D�܂��C�{�\�t�g�E�F
 *  �A�̗��p�ɂ�蒼�ړI�܂��͊ԐړI�ɐ����������Ȃ鑹�Q�Ɋւ��Ă��C��
 *  �̐ӔC�𕉂�Ȃ��D
 *
 *	2022/12/23 Ryutaro Morita
 */

/*
 *		�^�C�}�h���C�o�iAT32UC3A3_XPLD�p�j
 */

#include "kernel_impl.h"
#include "time_event.h"
#include <sil.h>
#include "target_timer.h"

#define TC_CHANNEL    0

/*
 *  �^�C�}�̋N������
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
	 *  �^�C�}������ݒ肵�C�^�C�}�̓�����J�n����D
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
	 *  �^�C�}�����ݗv�����N���A����D
	 */
	x_clear_int(INTNO_TIMER);
}

/*
 *  �^�C�}�̒�~����
 */
void
target_timer_terminate(intptr_t exinf)
{
	/*
	 *  �^�C�}�̓�����~����D
	 */
	// Stop the timer/counter.
	tc_stop(&AVR32_TC0, TC_CHANNEL);
}

/*
 *  �^�C�}�����݃n���h��
 */
void
target_timer_handler(void)
{
	i_begin_int(INTNO_TIMER);
	tc_read_sr(&AVR32_TC0, TC_CHANNEL);
	signal_time();					/* �^�C���e�B�b�N�̋��� */
	i_end_int(INTNO_TIMER);
}
