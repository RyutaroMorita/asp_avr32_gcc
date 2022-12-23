#
#		Makefileのプロセッサ依存部（AVR32UC3用）
#

#
#  GNU開発環境のターゲットアーキテクチャの定義
#
GCC_TARGET = avr32

#
#  プロセッサ依存部ディレクトリ名の定義
#
PRCDIR = $(SRCDIR)/arch/$(PRC)_$(TOOL)

#
#  コンパイルオプション
#
INCLUDES := $(INCLUDES) \
		    -I$(SRCDIR)/arch/$(PRC)_$(TOOL)/UC3A_DFP/1.0.53/include/AT32UC3A3256
COPTS := $(COPTS) -mpart=uc3a3256 -DBOARD=UC3_A3_XPLAINED -std=gnu99
LDFLAGS := $(LDFLAGS)

#
#  カーネルに関する定義
#
KERNEL_DIR := $(KERNEL_DIR) $(PRCDIR)
KERNEL_ASMOBJS := $(KERNEL_ASMOBJS) prc_support.o
KERNEL_COBJS := $(KERNEL_COBJS) prc_config.o

#
#  コンフィギュレータ関係の変数の定義
#
CFG_TABS := $(CFG_TABS) --cfg1-def-table $(PRCDIR)/prc_def.csv

#
#  オフセットファイル生成のための定義
#
OFFSET_TF = $(PRCDIR)/prc_offset.tf
