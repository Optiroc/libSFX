; libSFX Meta Macros
; David Lindecrantz <optiroc@gmail.com>

.ifndef __MBSFX_META__
__MBSFX_META__ = 1

.define ON              1
.define OFF             0
.define YES             1
.define NO              0
.define ENABLE          1
.define DISABLE         0

.macro SFX_warning description
  .assert 0, warning, description
.endmac

.macro SFX_error description
  .assert 0, error, description
.endmac

;-------------------------------------------------------------------------------
;isdefined/define/undefine
;By Movax12 (http://forums.nesdev.com/viewtopic.php?f=2&t=11112&start=15#p127674)

.define isdefined(i) ( .defined(::.ident(.sprintf("_ISDEFINED_%s", i) )) .and ::.ident(.sprintf("_ISDEFINED_%s", i) ) )

.define isnotdefined(i) (.not (.defined(::.ident(.sprintf("_ISDEFINED_%s", i) )) .and ::.ident(.sprintf("_ISDEFINED_%s", i) ) ) )

.macro define i, v
  .if isdefined i
    .undefine .ident(i)
  .endif
  .define .ident(i) v
  ::.ident(.sprintf("_ISDEFINED_%s", i)) .set 1
.endmacro

.macro undefine i
  .if isdefined i
    .undefine .ident(i)
  .endif
  ::.ident(.sprintf("_ISDEFINED_%s", i)) .set 0
.endmacro


.endif
