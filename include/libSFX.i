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

  libSFX is a Super Nintendo assembler development framework. It aims to
  add as little magic and abstraction to the programming as possible while
  removing the tedium of boilerplate and mandatory micro management of
  configuration files.

  By leveraging the ca65 assembler and several macro packs it can
  create object code for∶

  * WDC65816 - also known as S-CPU, the main processor
  * SPC700 - the Sony 8-bit CPU (S-SMP) controlling the sound DSP (S-DSP)
  * GSU - Graphics Support Unit, also known as "SuperFX"

  Using (and optionally extending) the included makefiles and configurations
  it's a relative breeze to get SNES code up and running!

  *Anatomy*
  libSFX consists of a small runtime that mainly initializes the system and
  handles hardware interrupts (which can be redirected in software). The real
  rice of the library are the macros included and documented here.

  _Packages_
  There are also opt-in packages, adding a bit more to the object code size,
  for non-core features like input peripherals and data decompression.
  These are documented in the "Packages" section.

  _Tools_
  The ca65 toolchain and a couple of support tools are included as submodules
  in the libSFX/tools directory. These are the only tools used by the libSFX.make
  makefile, making libSFX pretty much self contained. Running make from the
  repository root will sync the submodules and build the tools.

  *Get started*
  Clone, fork or download the repository at <github.com/Optiroc/libSFX at https://github.com/Optiroc/libSFX>
  and dive into the <CPU.i> documentation.

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
  .include "CPU_SMP.i"
  .include "CPU_DSP.i"
  .include "CPU_GSU.i"

  ;S-CPU optional packages
  .if .defined(SFXPKG_LZ4)
    .include "Packages/LZ4/LZ4.i"
  .endif
  .if .defined(SFXPKG_MOUSE)
    .include "Packages/Mouse/Mouse.i"
  .endif

  ;Initial register widths
  RW_assume a8i16

.endif

.endif;__MBSFX_INC__
