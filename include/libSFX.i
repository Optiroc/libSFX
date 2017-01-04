; libSFX
; Super Famicom Development Framework
; David Lindecrantz <optiroc@gmail.com>

.feature c_comments
.p816
.smart -
.linecont +

.ifndef ::__MBSFX_INC__
::__MBSFX_INC__ = 1

;-------------------------------------------------------------------------------
/**
  Group: libSFX documentation

  libSFX is a Super Nintendo assembler development framework. By leveraging the
  ca65 assembler and several macro packs it can create object code for∶

  * WDC65816 - also known as S-CPU, the main processor
  * SPC700 - the Sony 8-bit CPU controlling the sound DSP (S-SMP)
  * GSU - Graphics Support Unit, also known as "SuperFX"

  Using (and optionally extending) the included makefiles and configurations
  it's a relative breeze to get "full stack" SNES code up and running.

  libSFX consists of a small runtime that mainly initializes the system and
  handles hardware interrupts (which can be redirected in software). The real
  rice of the library are the macros included and documented here.

  To get started clone or download at <github.com/Optiroc/libSFX at https://github.com/Optiroc/libSFX>, and dive into the <CPU.i> documentation!

  libSFX is developed by David Lindecrantz and distributed under the terms of
  the <MIT license at https://raw.githubusercontent.com/Optiroc/libSFX/master/LICENSE>.
*/
;-------------------------------------------------------------------------------

.include "Meta.i"
.include "libSFX.cfg"

.if .defined(TARGET_SMP)
  ;S-SMP includes
  .include "SMP_Def.i"
  .include "SMP_Util.i"
  .include "SMP_Assembler.i"

.elseif .defined(TARGET_GSU)
  ;GSU includes
  .include "GSU_Assembler.i"

.else
  ;S-CPU includes
  .include "CPU_Def.i"
  .include "CPU.i"
  .include "CPU_Runtime.i"
  .include "CPU_Memory.i"
  .include "CPU_PPU.i"
  .include "CPU_Math.i"
  .include "CPU_DataStructures.i"
  .include "CPU_Compression.i"
  .include "CPU_SMP.i"
  .include "CPU_DSP.i"
  .include "CPU_GSU.i"

  ;Initial register widths
  RW_assume a8i16

.endif

.endif;__MBSFX_INC__
