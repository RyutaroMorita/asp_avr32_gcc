$
$ 		パス2のターゲット依存テンプレート（AT32UC3A3_XPLD用）
$

$
$  有効な割込み番号，割込みハンドラ番号
$
$INTNO_VALID = { 0,1,...,928 }$
$INHNO_VALID = INTNO_VALID$

$
$  ATT_ISRで使用できる割込み番号とそれに対応する割込みハンドラ番号
$
$INTNO_ATTISR_VALID = INTNO_VALID$
$INHNO_ATTISR_VALID = INHNO_VALID$

$
$  DEF_INT／DEF_EXCで使用できる割込みハンドラ番号／CPU例外ハンドラ番号
$
$INHNO_DEFINH_VALID = INHNO_VALID$

$
$  CFG_INTで使用できる割込み番号と割込み優先度
$
$INTNO_CFGINT_VALID = INTNO_VALID$
$INTPRI_CFGINT_VALID = { -4,-3,...,-1 }$

$
$  標準テンプレートファイルのインクルード
$
$INCLUDE "kernel/kernel.tf"$

/*$NL$
$SPC$*  Target-dependent Definitions (DVE68K/40)$NL$
$SPC$*/$NL$
$NL$

$
$   CFG_INTのターゲット依存のエラーチェックと_kernel_bitpat_cfgintの生成
$
