; libSFX Global Defines
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_DEFINES__
::__MBSFX_DEFINES__ = 1

.define ON              1
.define OFF             0
.define YES             1
.define NO              0
.define ENABLE          1
.define DISABLE         0

.define JOY1    %00000001
.define JOY2    %00000010
.define JOY3    %00000100
.define JOY4    %00001000

.define MOUSE1  %00000001
.define MOUSE2  %00000010

.macro SFX_warning description
  .assert 0, warning, description
.endmac

.macro SFX_error description
  .assert 0, error, description
.endmac

;-------------------------------------------------------------------------------
;Utility macros

/**
  incbin
  Include binary file and create "name:" label and "sizeof_name" constant.

  :in:    name    Name         identifier
  :in:    file    Filename     string
  :in?:   offset  File offset  constant
  :in?:   size    Data size    constant
*/
.macro incbin name, file, offset, size
  .ident(.sprintf("%s", .string(name))):
  .if .not .blank(size)
    .incbin file, offset, size
  .elseif .not .blank(offset)
    .incbin file, offset
  .else
    .incbin file
  .endif
  .ident(.sprintf("sizeof_%s", .string(name))) = * - .ident(.sprintf("%s", .string(name)))
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


.endif;__MBSFX_DEFINES__
