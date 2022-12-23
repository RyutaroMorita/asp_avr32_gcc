#
#		Makefile�̃v���Z�b�T�ˑ����iAVR32UC3�p�j
#

#
#  GNU�J�����̃^�[�Q�b�g�A�[�L�e�N�`���̒�`
#
GCC_TARGET = avr32

#
#  �v���Z�b�T�ˑ����f�B���N�g�����̒�`
#
PRCDIR = $(SRCDIR)/arch/$(PRC)_$(TOOL)

#
#  �R���p�C���I�v�V����
#
INCLUDES := $(INCLUDES) \
		    -I$(SRCDIR)/arch/$(PRC)_$(TOOL)/UC3A_DFP/1.0.53/include/AT32UC3A3256
COPTS := $(COPTS) -mpart=uc3a3256 -DBOARD=UC3_A3_XPLAINED -std=gnu99
LDFLAGS := $(LDFLAGS)

#
#  �J�[�l���Ɋւ����`
#
KERNEL_DIR := $(KERNEL_DIR) $(PRCDIR)
KERNEL_ASMOBJS := $(KERNEL_ASMOBJS) prc_support.o
KERNEL_COBJS := $(KERNEL_COBJS) prc_config.o

#
#  �R���t�B�M�����[�^�֌W�̕ϐ��̒�`
#
CFG_TABS := $(CFG_TABS) --cfg1-def-table $(PRCDIR)/prc_def.csv

#
#  �I�t�Z�b�g�t�@�C�������̂��߂̒�`
#
OFFSET_TF = $(PRCDIR)/prc_offset.tf
