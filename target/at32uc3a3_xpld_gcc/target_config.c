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
 *		�^�[�Q�b�g�ˑ����W���[���iAT32UC3A3_XPLD�p�j
 */

#include "kernel_impl.h"
#include <sil.h>
#include <asf.h>

FP exc_handler_table[EXCNO_MAX + 1];

/*
 *  �v���Z�b�T���ʂ̂��߂̕ϐ��i�}���`�v���Z�b�T�Ή��j
 */
uint_t	board_id;			/* �{�[�hID */
void	*board_addr;		/* ���[�J���������̐擪�A�h���X */

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
 *  �^�[�Q�b�g�ˑ��̏�����
 */
void
target_initialize(void)
{
	int i;
	/*
	 *  �v���Z�b�T�ˑ��̏�����
	 */
	prc_initialize();

	board_init();

	sysclk_init();

	/* CPU��O�n���h���E�e�[�u���̏����� */
	for (i = 0; i < (EXCNO_MAX + 1); i++)
		exc_handler_table[i] = NULL;

	INTC_init_interrupts();

	usart_early_init();
}

/*
 *  �^�[�Q�b�g�ˑ��̏I������
 */
void
target_exit(void)
{
	/*
	 *  �v���Z�b�T�ˑ��̏I������
	 */
	prc_terminate();

	while(1);
}

/*
 *  �V�X�e�����O�̒჌�x���o�͂̂��߂̕����o��
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
 *  �����݃n���h���̐ݒ�
 *
 *  �x�N�g���ԍ�inhno�̊����݃n���h���̏o���������̔Ԓn��int_entry�ɐ�
 *  �肷��D
 */
void
x_define_inh(INHNO inhno, FP int_entry)
{
	assert(VALID_INHNO_DEFINH(inhno));
	INTC_register_interrupt((__int_handler)int_entry, inhno, AVR32_INTC_INT0);
}

/*
 *  CPU��O�n���h���̐ݒ�
 *
 *  �x�N�g���ԍ�excno��CPU��O�n���h���̏o���������̔Ԓn��exc_entry�ɐ�
 *  �肷��D
 */
void
x_define_exc(EXCNO excno, FP exc_entry)
{
	assert(VALID_EXCNO_DEFEXC(excno));
	exc_handler_table[excno] = exc_entry;
}

/*
 *  �����ݗv�����C���̑����̐ݒ�
 *
 *  ASP�J�[�l���ł̗��p��z�肵�āC�p�����[�^�G���[�̓A�T�[�V�����Ń`�F�b
 *  �N���Ă���Dcfg_int�T�[�r�X�R�[����݂���ꍇ�ɂ́C�G���[��Ԃ��悤
 *  �ɂ��ׂ��ł��낤�D
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
	 *  �����݂̃}�X�N
	 *
	 *  �����݂��󂯕t�����܂܁C���x���g���K�^�G�b�W�g���K�̐ݒ��C��
	 *  ���ݗD��x�̐ݒ���s���̂͊댯�Ȃ��߁C�����ݑ����ɂ�����炸�C
	 *  ��U�}�X�N����D
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
