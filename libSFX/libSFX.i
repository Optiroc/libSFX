; libSFX 0.1 (20150515)
; Super Famicom Development Framework
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_INC__
::__MBSFX_INC__ = 1

;--------------------------------------------------------------------
.p816
.smart -
.feature c_comments
.linecont +

.include "Meta.i"
.include "libSFX.cfg"
.include "SMP_System.i700"

.ifdef TARGET_SMP
  ;S-SMP includes
  .include "SMP_Def.i700"
  .include "SMP_SPC700.i700"

.else
  ;S-CPU includes
  .include "CPU_Def.i"
  .include "CPU.i"
  .include "CPU_Runtime.i"
  .include "CPU_Memory.i"
  .include "CPU_PPU.i"
  .include "CPU_SMP.i"
  .include "CPU_Math.i"
  .include "CPU_DataStructures.i"
  .include "CPU_Compression.i"

  ;Initial register widths
  RW_assume a8i16

.endif


.endif;__MBSFX_INC__
