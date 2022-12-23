/*
 *  TOPPERS Software
 *      Toyohashi Open Platform for Embedded Real-Time Systems
 *
 *  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
 *                              Toyohashi Univ. of Technology, JAPAN
 *  Copyright (C) 2004-2008 by Embedded and Real-Time Systems Laboratory
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
 *		t_stddef.h�̃^�[�Q�b�g�ˑ����iAT32UC3A3_XPLD�p�j
 *
 *  ���̃C���N���[�h�t�@�C���́Ct_stddef.h�̐擪�ŃC���N���[�h�����D
 *  ���̃t�@�C������͒��ڃC���N���[�h���邱�Ƃ͂Ȃ��D���̃C���N���[�h
 *  �t�@�C���ɐ旧���ď�������邽�߁C���̃C���N���[�h�t�@�C���Ɉˑ���
 *  �Ă͂Ȃ�Ȃ��D
 */

#ifndef TOPPERS_TARGET_STDDEF_H
#define TOPPERS_TARGET_STDDEF_H

/*
 *  �^�[�Q�b�g�����ʂ��邽�߂̃}�N���̒�`
 */
#define TOPPERS_AT32UC3A3_XPLD	/* �V�X�e������ */

/*
 *  �J�����ŋ��ʂȒ�`
 *
 *  �J������stdint.h���p�ӂ���Ă���ꍇ�ɂ́CTOPPERS_STDINT_TYPE1��
 *  �}�N����`���폜���Cstdint.h���C���N���[�h����΂悢�D
 */
/* #define TOPPERS_STDINT_TYPE1 */
#ifndef __ASSEMBLER__
#include <stdint.h>
#endif
#define TOPPERS_STDFLOAT_TYPE1
#include "gcc/tool_stddef.h"

/*
 *  �v���Z�b�T�ŋ��ʂȒ�`
 */
#include "avr32uc3_gcc/prc_stddef.h"

/*
 *  �A�T�[�V�����̎��s���̎��s���f����
 */
#ifndef TOPPERS_MACRO_ONLY
#ifdef TOPPERS_GDB_STUB				/* GDB�X�^�u */

Inline void
TOPPERS_assert_abort(void)
{
//	Asm("trap #2");
	while(1);
}

#else /* TOPPERS_GDB_STUB */		/* ���̑��̊J���� */

extern void		TOPPERS_assert_abort(void);

#endif /* TOPPERS_GDB_STUB */
#endif /* TOPPERS_MACRO_ONLY */
#endif /* TOPPERS_TARGET_STDDEF_H */