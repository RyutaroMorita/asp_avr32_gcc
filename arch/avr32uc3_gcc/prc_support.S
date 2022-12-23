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
 *		�v���Z�b�T�ˑ����W���[�� �A�Z���u�����ꕔ�iAVR32UC3�p�j
 */

#include <avr32/io.h>

#define	TOPPERS_MACRO_ONLY
#define UINT_C(val)			(val)		/* uint_t�^�̒萔�����}�N�� */
#define ULONG_C(val)		(val)		/* ulong_t�^�̒萔�����}�N�� */
#define CAST(type, val)		(val)		/* �^�L���X�g���s���}�N�� */
#include "kernel_impl.h"
#include "offset.h"

/*
 *  �^�X�N�f�B�X�p�b�`��
 */
	.text
	.globl dispatch
dispatch:
	/*
	 *  ���̃��[�`���́C�^�X�N�R���e�L�X�g�ECPU���b�N��ԁE�f�B�X�p�b�`
	 *  ����ԁE�i���f����́j�����ݗD��x�}�X�N�S������ԂŌĂяo��
	 *  ���D
	 */
	pushm	r0-r3, r4-r7, lr			/* ���W�X�^��ۑ� */

	lda.w	r9, p_runtsk
	ld.w	r8, r9[0]					/* p_runtsk��r8�� */
	st.w	r8[TCB_msp], sp				/* �^�X�N�X�^�b�N��ۑ� */
	lda.w	r9, dispatch_r
	st.w	r8[TCB_pc], r9				/* ���s�ĊJ�Ԓn��ۑ� */
	rjmp	dispatcher

dispatch_r:
	/*
	 *  SR�̃��[�h�t���OSR[M2:M0]��B'001�ɐݒ肵�X�[�p�[�o�C�U�[���[�h
	 *  �ֈڍs����D
	 */
	ssrf	AVR32_SR_M0_OFFSET
	csrf	AVR32_SR_M1_OFFSET
	csrf	AVR32_SR_M2_OFFSET
	popm	r0-r3, r4-r7, lr			/* ���W�X�^�𕜋A */

	ld.uh	r9, r8[TCB_enatex]
	bld		r9, TCB_enatex_bit
	brne	dispatch_r_1				/* enatex��false�Ȃ烊�^�[�� */

	ld.w	r9, r8[TCB_texptn]
	cp.w	r9, 0
	brne	dispatch_r_1				/* texptn��0�Ȃ烊�^�[�� */

	lda.w	r9, ipmflg
	ld.w	r10, r9[0]
	cp.w	r0, 0						/* ipmflg��true�ł����            */
	brne	call_texrtn					/*  �^�X�N��O�������[�`���̌ďo�� */

dispatch_r_1:
	mov		pc, lr

/*
 *  �f�B�X�p�b�`���̓���J�n�iprc_support.S�j
 */
	.globl start_dispatch
start_dispatch:
	/*
	 *  ���̃��[�`���́C�J�[�l���N�����ɁC���ׂĂ̊����݂��֎~�������
	 * �i�����݃��b�N��ԂƓ����j�ŌĂяo�����D�܂��C�����݃��[�h�i��
	 *  �^�X�N�R���e�L�X�g�Ɠ����j�ŌĂяo����邱�Ƃ�z�肵�Ă���D
	 *
	 *  prc_initialize�ŁClock_flag��true�ɁCsaved_iipm��IIPM_ENAALL��
	 *  ���������Ă��邽�߁C�J�[�l���Ǘ��O�̊����݂������邱�ƂŁC
	 *  CPU���b�N��ԁE�i���f����́j�����ݗD��x�}�X�N�S������ԂɂȂ�D
	 *  �܂��Cinitialize_task��disdsp��false�ɏ��������Ă��邽�߁C�f�B
	 *  �X�p�b�`����ԂɂȂ��Ă���D
	 */
	lda.w	r9, int_cnt					/* �}�X�^���[�h�� */
	mov		r10, 0						/* �}�X�^���[�h�E                */
	st.w	r9[0], r10
	movh	r9, 0x001E
	com		r9
	mfsr	r10, AVR32_SR
	and		r9, r10
	movh	r10, IIPM_LOCK_H
	or		r9, r10
	mtsr	AVR32_SR, r9				/*  �J�[�l���Ǘ��O�̊����݂����� */
	rjmp	dispatcher_0

/*
 *  ���݂̃R���e�L�X�g���̂Ăăf�B�X�p�b�`
 */
	.globl exit_and_dispatch
exit_and_dispatch:
	/* �f�B�X�p�b�`���{�́idispatcher�j�� */

/*
 *  �f�B�X�p�b�`���{��
 */
dispatcher:
	/*
	 *  ���̃��[�`���́C�^�X�N�R���e�L�X�g�ECPU���b�N��ԁE�f�B�X�p�b�`
	 *  ����ԁE�i���f����́j�����ݗD��x�}�X�N�S������ԂŌĂяo��
	 *  ���D
	 *
	 *  ���Ȃ킿�C�}�X�^���[�h�Elock_flag��true�Edisdsp��false�Edspflg
	 *  ��true�Esaved_iipm��IIPM_ENAALL�ƂȂ��Ă���D���s�ĊJ�Ԓn�ւ���
	 *  �̏�Ԃ̂܂ܕ��򂷂�D
	 */
#ifdef LOG_DSP_ENTER
	lda.w	r8, p_runtsk				/* p_runtsk���p�����[�^�� */
	ld.w	r12, r8[0]
	call	log_dsp_enter

#endif /* LOG_DSP_ENTER */

dispatcher_0:
	lda.w	r9, p_schedtsk				/* p_schedtsk��p_runtsk�� */
	ld.w	r8, r9[0]
	lda.w	r9, p_runtsk
	st.w	r9[0], r8
	cp.w	r8, 0
	breq	dispatcher_1				/* p_runtsk��NULL�Ȃ�dispatcher_1�� */

	ld.w	sp, r8[TCB_msp]				/* �^�X�N�X�^�b�N�𕜋A */
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
	 *  CPU���b�N��Ԃ��������鏀��������D
	 */
	lda.w	r9, int_cnt					/* �����݃��[�h�� */
	mov		r10, 1
	st.w	r9[0], r10
	lda.w	r8, _kernel_istkpt
	ld.w	sp, r8[0]
	mfsr	r8, AVR32_SR				/* SR��r8�ɕۑ� */
	lda.w	r9, lock_flag				/* �����݃��[�h�� */
	mov		r10, 0
	st.w	r9[0], r10					/* CPU���b�N������Ԃ� */
dispatcher_2:
	/*
	 *  �����݂������C�����݃��[�h�ɐ؂芷���āC�����݂�҂D
	 *
	 *  �����Ŋ����݃��[�h�ɐ؂芷����̂́C�����Ŕ������銄���ݏ�����
	 *  �ǂ̃X�^�b�N���g�����Ƃ������̉����ƁC�����݃n���h�����ł̃^
	 *  �X�N�f�B�X�p�b�`�̖h�~�Ƃ���2�̈Ӗ�������D
	 *
	 *  �v���Z�b�T�������ݑ҂��Ɉڍs�����鏈���ƁC�����݋��Ƃ́C�s��
	 *  ���ɍs�Ȃ��K�v������D�����s���ɍs�Ȃ�Ȃ��ꍇ�C�����݂���
	 *  ��������Ɋ����݂�����C���̒��Ń^�X�N�����s�\��ԂɂȂ��
	 *  ���s���ׂ��^�X�N������ɂ�������炸�v���Z�b�T�������ݑ҂��ɂ�
	 *  ���Ă��܂��D
	 *
	 *  �����ݑ҂��̊Ԃ́Cp_runtsk��NULL�i��0�j�ɐݒ肵�Ȃ���΂Ȃ��
	 *  ���D���̂悤�ɐݒ肵�Ȃ��ƁC�����݃n���h������iget_tid���Ăяo
	 *  �����ۂ̓��삪�d�l�ɍ��v���Ȃ��Ȃ�D
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
	cp.w	r10, 0						/* reqflg��false�Ȃ�dispatcher_2�� */
	breq	dispatcher_2
	mtsr	AVR32_SR, r8				/* ���̏�Ԃɖ߂� */
	mov		r10, 0
	st.w	r9[0], r10					/* reqflg��false�� */
	/*
	 *  CPU���b�N��Ԃɖ߂��D�����ݑ҂��̊ԂɎ��s���������݃n���h���ɂ�
	 *  ��Csaved_iipm��������������\�������邽�߁C���̒l�ɖ߂��K
	 *  �v������Ddispatcher�����s����鎞�́Csaved_iipm��IIPM_ENAALL
	 *  �ƂȂ��Ă��邽�߁C�����ł�saved_iipm��IIPM_ENAALL�i��0�j�ɖ߂�
	 *  �΂悢�D
	 */
	lda.w	r9, int_cnt					/* �}�X�^���[�h�� */
	mov		r10, 0
	st.w	r9[0], r10
	lda.w	r9, saved_iipm				/* saved_iipm��0�ɂ��� */
	st.w	r9[0], r10
	lda.w	r9, lock_flag				/* CPU���b�N��Ԃ� */
	mov		r10, 1
	st.w	r9[0], r10
	rjmp	dispatcher_0

/*
 *  �J�[�l���̏I�������̌ďo��
 */
	.globl call_exit_kernel
call_exit_kernel:
	lda.w	r9, int_cnt					/* �����݃��[�h�� */
	mov		r10, 1
	st.w	r9[0], r10
	lda.w	r8, _kernel_istkpt
	ld.w	sp, r8[0]
	rjmp	exit_kernel					/* �J�[�l���̏I���������Ă� */

/*
 *  �^�X�N�J�n������
 */
	.text
	.globl start_r
start_r:
	lda.w	r9, lock_flag				/* CPU���b�N������Ԃ� */
	mov		r10, 0
	st.w	r9[0], r10
	csrf	AVR32_SR_GM_OFFSET
	ld.w	r9, r8[TCB_p_tinib]			/* p_runtsk->p_tinib��r9�� */
	ld.w	r12, r9[TINIB_exinf]
	lda.w	lr, ext_tsk
	ld.w	r8, r9[TINIB_task]			/* �^�X�N�̋N���Ԓn��r8�� */
	mov		pc, r8

/*
 *  �����݃G���g���ir12��Level�ԍ�������j
 */
	.global inthdr_entry
inthdr_entry:
	lda.w	r9, int_cnt					/* �����݃��[�h�� */
	ld.w	r8, r9[0]
	sub		r8, -1
	st.w	r9[0], r8
	cp.w	r8, 1
	brne	inthdr_entry_0_d			/* ���Z�O��0�łȂ���Α��d������ */

	lda.w	r9, int_sp
	st.w	r9[0], sp
	lda.w	r8, _kernel_istkpt			/* �����ݗp�̃X�^�b�N�֐ؑւ� */
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
 *  �����݃n���h���o������
 *
 *  ret_int�́C�����݃n���h������߂�������Ɏ��s���郋�[�`���ŁC
 *  INTHDR_ENTRY�}�N���œW�J���銄���݃n���h���̓��������ŁC�����݃n��
 *  �h������̖߂�Ԓn�ɐݒ肳���D
 */
	.text
	.globl ret_int
ret_int:
	lda.w	r9, int_cnt					/* �����݃��[�h�� */
	ld.w	r8, r9[0]
	sub		r8, 1
	st.w	r9[0], r8					/* �߂�悪�����݃��[�h�Ȃ� */
	brne	ret_int_1_d					/*           �����Ƀ��^�[�� */

	/*
	 *  �J�[�l���Ǘ��̊����݂��֎~����D���̎��_�ł́CCPU���b�N��Ԃ�
	 *  �͂Ȃ�Ȃ��ilock_flag��saved_iipm�͍X�V���Ȃ��j�D
	 *
	 *  reqflg���`�F�b�N����O�Ɋ����݂��֎~����̂́Creqflg���`�F�b�N
	 *  ��������Ɋ����݃n���h�����N������C���̒��Ńf�B�X�p�b�`���v��
	 *  ���ꂽ�ꍇ�ɁC�����Ƀf�B�X�p�b�`����Ȃ��Ƃ�����肪�����邽��
	 *  �ł���D
	 */
	/*
	 *  ���̃��[�`���̓J�[�l���Ǘ��̊����݂���N������邽�߁C�����ł́C
	 *  �����ݗD��x�}�X�N��TIPM_LOCK�����Ⴂ�Ƒz��ł���D
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
	cp.w	r8, 0						/* reqflg��true�ł����ret_int_2�� */
	brne	ret_int_2

	lda.w	r9, int_sp					/* �}�X�^���[�h�Ɂi�X�^�b�N�؊����j */
	ld.w	sp, r9[0]
ret_int_1:
	/*
	 *  �����ݏ�������̃��^�[���ɂ��CCPU���b�N������ԂɈڍs����悤
	 *  ��������D�����ݗD��x�}�X�N�́CRTE���߂ɂ�茳�̒l�ɖ߂邽�߁C
	 *  lock_flag��false�ɂ��Ă����΂悢�ilock_flag��false�ɂ���̂́C
	 *  CPU���b�N��Ԃ̂܂܊����݃n���h������߂������̑΍�j�D
	 */
	lda.w	r9, lock_flag				/* CPU���b�N�����̏��� */
	mov		r10, 0
	st.w	r9[0], r10
	rete

ret_int_1_d:
	rjmp	ret_int_1

ret_int_2:
	lda.w	r9, int_sp					/* �}�X�^���[�h�Ɂi�X�^�b�N�؊����j */
	ld.w	sp, r9[0]
ret_int_3:
	/*
	 *  �����ւ́CCPU��O�n���h���̏o��������������򂵂Ă���D
	 *
	 *  �����ł́C�߂�悪�^�X�N�ł���C�X�^�b�N�́C��O�X�^�b�N�t���[
	 *  ���̏�ɃX�N���b�`���W�X�^�݂̂��ۑ����ꂽ��ԂɂȂ��Ă���D��
	 *  ���C�v���Z�b�T�́C�}�X�^���[�h�E�J�[�l���Ǘ��̊����݂��֎~����
	 *  ��ԂƂȂ��Ă���D
	 */
	lda.w	r9, reqflg
	mov		r10, 0
	st.w	r9[0], r10					/* reqflg��false�� */
	/*
	 *  CPU���b�N��ԂɈڍs���C�����ݗD��x�}�X�N�������ݏ����O�̒l�ɐ�
	 *	�肷��D�J�[�l���Ǘ��̊����݂͂��łɋ֎~���Ă���̂ŁClock_flag
	 *  ��saved_iipm���X�V����Dsaved_iipm�́C�߂��̊����ݗD��x�}�X
	 *  �N�i�̓����\���j�ɐݒ肷��D
	 *
	 *  ���̎��_��CPU���b�N��ԂƂ���̂́Cdispatcher�֕��򂷂鎞�ƁC
	 *  call_texrtn���Ăяo�����ɁCCPU���b�N��ԂɂȂ��Ă���K�v������
	 *  ���߂ł���D
	 */
	ld.w	r8, sp[0]					/* �߂���SR��r8�� */
	movh	r9, 0x001E					/* IPM�����o����saved_iipm�� */
	and		r8, r9
	lda.w	r9, saved_iipm
	st.w	r9[0], r8
	lda.w	r9, lock_flag
	mov		r10, 1
	st.w	r9[0], r10					/* lock_flag��true�� */
	/*
	 *  dspflg��false�ł���ꍇ�ƁCp_runtsk��p_schedtsk�������ꍇ�ɂ́C
	 *  �f�B�X�p�b�`���s��Ȃ��D���̃`�F�b�N���K�v�Ȃ̂́C�^�X�N��O��
	 *  �����[�`���̌ďo�����K�v�ȏꍇ�ɁC�f�B�X�p�b�`���K�v�Ȃ��Ă��C
	 *  reqflg��true�ɂ��邽�߂ł���D
	 */
	lda.w	r9, p_runtsk				/* p_runtsk��r8�� */
	ld.w	r8, r9[0]
	lda.w	r9, dspflg					/* dspflg��false�Ȃ�ret_int_4�� */
	ld.w	r10, r9[0]
	cp.w	r10, 0
	breq	ret_int_4

	lda.w	r9, p_schedtsk				/* p_runtsk��p_schedtsk�������Ȃ� */
	ld.w	r10, r9[0]
	cp.w	r8, r10
	breq	ret_int_4					/*                    ret_int_4�� */

	pushm	r0-r3, r4-r7, lr			/* �c��̃��W�X�^��ۑ�*/

	st.w	r8[TCB_msp], sp				/* �^�X�N�X�^�b�N��ۑ� */
	lda.w	r9, ret_int_r				/* ���s�ĊJ�Ԓn��ۑ� */
	st.w	r8[TCB_pc], r9
	rjmp	dispatcher

ret_int_r:
	/*
	 *  SR�̃��[�h�t���OSR[M2:M0]��B'010,B'011,B'100,B'101�̂����ꂩ��
	 *  �ݒ肷��D
	 *  �����ȊO�̒l���ݒ肳��Ă���ꍇ�͌��rete���߂�R8-R12, LR��
	 *  ���A���s���Ȃ��D(�����ł́CB'010�ɐݒ肵�Ă���D)
	 */
	csrf	AVR32_SR_M0_OFFSET
	ssrf	AVR32_SR_M1_OFFSET
	csrf	AVR32_SR_M2_OFFSET
	popm	r0-r3, r4-r7, lr			/* ���W�X�^�𕜋A */
ret_int_4:
	/*
	 *  enatex��true�ŁCtexptn��0�łȂ��Cipmflg��true�ł���΁C�^�X�N
	 *  ��O�������[�`�����Ăяo���D
	 */
	ld.uh	r9, r8[TCB_enatex]
	bld		r9, TCB_enatex_bit
	breq	ret_int_5					/* enatex��false�Ȃ�ret_int_5�� */

	ld.w	r9, r8[TCB_texptn]
	cp.w	r9, 0						/* texptn��0�Ȃ�ret_int_5�� */
	breq	ret_int_5

	lda.w	r9, ipmflg
	ld.w	r10, r9[0]
	cp.w	r10, 0						/* ipmflg��false�Ȃ�ret_int_5�� */
	breq	ret_int_5

	call	call_texrtn					/* �^�X�N��O�������[�`���̌ďo�� */

ret_int_5:
	/*
	 *  �����ݏ�������̃��^�[���ɂ��CCPU���b�N������ԂɈڍs�����
	 *  ����������D�����ݗD��x�}�X�N�́CRTE���߂ɂ�茳�̒l�ɖ߂邽
	 *  �߁Clock_flag��false�ɂ��Ă����΂悢�D
	 */
	lda.w	r9, lock_flag				/* CPU���b�N�����̏��� */
	mov		r10, 0
	st.w	r9[0], r10
	rete