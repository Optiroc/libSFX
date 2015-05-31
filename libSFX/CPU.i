; libSFX S-CPU Macros
; David Lindecrantz <optiroc@gmail.com>

.ifndef __MBSFX_CPU__
__MBSFX_CPU__ = 1

;-------------------------------------------------------------------------------

/**
  Register width (RW*) macros

  Instead of using ca65's .a* and .i* directives or the "smart" mode to set
  current register width, libSFX uses these macros to track CPU state.

  The main advantage of this approach is that rep/sep instructions will be
  emitted only when necessary. When relying a lot on "function inlining" via
  macros those tend to add up quickly.

  A bonus is that this state can be queried with the RW_a_size/RW_i_size
  macros, allowing for conditial assembly depending on register widths.

  Of course, the tracking can only work within one assembly unit. When
  calling function over unit barriers there's a size stack and a couple of
  helper macros to keep things in sync.

  An example:

  .macro call_external
        RW_push set:a16             ;Push current state and set accumlator
                                    ;width to 16 bits if necessary
                                    ;Only if accumulator is 8 bits wide a
                                    ;rep #$20 instruction will be emitted

        jsl     external            ;Call external subroutine that assumes
                                    ;16-bit accumulator

        RW_pull                     ;Register widths are restored as needed
  .endmac

  The 'external' subroutine looks like this:

  .proc external
        RW_assume a16               ;16 bit accumulator is assumed
                                    ;(no instruction emitted)
        lda     #$f00d              ;So this will assemble nicely
        rtl
  .endproc

*/


;Variables for tracking accumlator/index flag (0 = 16-bit, 1 = 8-bit)
SFX_RW_a_size .set 1
SFX_RW_i_size .set 0

;Get current accumulator/index size
.define RW_a_size SFX_RW_a_size
.define RW_i_size SFX_RW_i_size


;Set accumulator/index width (no-op if current state == intended state)
.macro RW widths
.if .blank({widths})
  SFX_error "RW: Missing required parameter"
.else
  .if .xmatch({widths},{a8})
    .if SFX_RW_a_size <> 1
      sep #$20
    .endif
  .elseif .xmatch({widths},{a16})
    .if SFX_RW_a_size <> 0
      rep #$20
    .endif
  .elseif .xmatch({widths},{i8})
    .if SFX_RW_i_size <> 1
      sep #$10
    .endif
  .elseif .xmatch({widths},{i16})
    .if SFX_RW_i_size <> 0
      rep #$10
    .endif
  .elseif .xmatch({widths},{a8i8})
    .if SFX_RW_a_size <> 1 .or SFX_RW_i_size <> 1
      sep #$30
    .endif
  .elseif .xmatch({widths},{a16i16})
    .if SFX_RW_a_size <> 0 .or SFX_RW_i_size <> 0
      rep #$30
    .endif
  .elseif .xmatch({widths},{a8i16})
    RW a8
    RW i16
  .elseif .xmatch({widths},{a16i8})
    RW a16
    RW i8
  .else
    SFX_error "RW: Illegal parameter"
  .endif
  RW_assume widths
.endif
.endmac


;Assume known accumulator/index width
.macro RW_assume widths
.if .blank({widths})
  SFX_error "RW_assume: Missing required parameter"
.else
  .if .xmatch({widths},{a8})
    SFX_RW_a_size .set 1
    .a8
  .elseif .xmatch({widths},{a16})
    SFX_RW_a_size .set 0
    .a16
  .elseif .xmatch({widths},{i8})
    SFX_RW_i_size .set 1
    .i8
  .elseif .xmatch({widths},{i16})
    SFX_RW_i_size .set 0
    .i16
  .elseif .xmatch({widths},{a8i8})
    RW_assume a8
    RW_assume i8
  .elseif .xmatch({widths},{a16i16})
    RW_assume a16
    RW_assume i16
  .elseif .xmatch({widths},{a8i16})
    RW_assume a8
    RW_assume i16
  .elseif .xmatch({widths},{a16i8})
    RW_assume a16
    RW_assume i8
  .else
    SFX_error "RW_assume: Illegal parameter"
  .endif
.endif
.endmac


;Forced set (for when returning from subroutine and using RW_pull_forced to restore state)
.macro RW_forced widths
.if .blank({widths})
  SFX_error "RW_forced: Missing required parameter"
.else
  .if .xmatch({widths},{a8i8})
    sep #$30
  .elseif .xmatch({widths},{a16i16})
    rep #$30
  .elseif .xmatch({widths},{a8i16})
    sep #$20
    rep #$10
  .elseif .xmatch({widths},{a16i8})
    rep #$20
    sep #$10
  .else
    SFX_error "RW_forced: Illegal parameter"
  .endif
  RW_assume widths
.endif
.endmac


;Assert current accumulator/index width
.macro RW_assert widths, message
.if .blank({message})
  SFX_error "RW_assert: Missing required parameter(s)"
.else
  .if .xmatch({widths},{a8})
    .if SFX_RW_a_size <> 1
      SFX_error message
    .endif
  .elseif .xmatch({widths},{a16})
    .if SFX_RW_a_size <> 0
      SFX_error message
    .endif
  .elseif .xmatch({widths},{i8})
    .if SFX_RW_i_size <> 1
      SFX_error message
    .endif
  .elseif .xmatch({widths},{i16})
    .if SFX_RW_i_size <> 0
      SFX_error message
    .endif
  .elseif .xmatch({widths},{a8i8})
    .if SFX_RW_a_size <> 1 .or SFX_RW_i_size <> 1
      SFX_error message
    .endif
  .elseif .xmatch({widths},{a16i16})
    .if SFX_RW_a_size <> 0 .or SFX_RW_i_size <> 0
      SFX_error message
    .endif
  .elseif .xmatch({widths},{a8i16})
    RW_assert a8 message
    RW_assert i16 message
  .elseif .xmatch({widths},{a16i8})
    RW_assert a16 message
    RW_assert i8 message
  .else
    SFX_error "RW_assert: Illegal parameter"
  .endif
.endif
.endmac


;Accumulator/index width stack (bit 0 = accumulator size, bit 1 = index size)
SFX_RW_size_sp .set 0
SFX_RW_size_s1 .set %00
SFX_RW_size_s2 .set %00
SFX_RW_size_s3 .set %00
SFX_RW_size_s4 .set %00
SFX_RW_size_s5 .set %00
SFX_RW_size_s6 .set %00
SFX_RW_size_s7 .set %00
SFX_RW_size_s8 .set %00

;Push accumulator/index width state (optionally set new state)
.macro RW_push new
.if SFX_RW_size_sp = 8
  SFX_error "RW_push: RW stack overflow"
.endif

  SFX_RW_size_sp .set SFX_RW_size_sp+1

  _sizeval_ .set %00
  .if SFX_RW_a_size = 1
    _sizeval_ .set _sizeval_ | %01
  .endif
  .if SFX_RW_i_size = 1
    _sizeval_ .set _sizeval_ | %10
  .endif

  .if SFX_RW_size_sp = 1
    SFX_RW_size_s1 .set _sizeval_
  .elseif SFX_RW_size_sp = 2
    SFX_RW_size_s2 .set _sizeval_
  .elseif SFX_RW_size_sp = 3
    SFX_RW_size_s3 .set _sizeval_
  .elseif SFX_RW_size_sp = 4
    SFX_RW_size_s4 .set _sizeval_
  .elseif SFX_RW_size_sp = 5
    SFX_RW_size_s5 .set _sizeval_
  .elseif SFX_RW_size_sp = 6
    SFX_RW_size_s6 .set _sizeval_
  .elseif SFX_RW_size_sp = 7
    SFX_RW_size_s7 .set _sizeval_
  .elseif SFX_RW_size_sp = 8
    SFX_RW_size_s8 .set _sizeval_
  .endif

  .ifnblank new
    .if .xmatch({new}, {set:a8})
      RW a8
    .elseif .xmatch({new}, {set:a16})
      RW a16
    .elseif .xmatch({new}, {set:i8})
      RW i8
    .elseif .xmatch({new}, {set:i16})
      RW i16
    .elseif .xmatch({new}, {set:a8i16})
      RW a8i16
    .elseif .xmatch({new}, {set:a16i8})
      RW a16i8
    .elseif .xmatch({new}, {set:a16i16})
      RW a16i16
    .else
      SFX_error "RW_push: Unknown 'new' argument"
    .endif
  .endif
.endmac

;Pull accumulator/index width state
.macro RW_pull
.if SFX_RW_size_sp = 0
  SFX_error "RW_pull: RW stack underflow"
.endif

  .if SFX_RW_size_sp = 0
    _sizeval_ .set $ff
  .elseif SFX_RW_size_sp = 1
    _sizeval_ .set SFX_RW_size_s1
  .elseif SFX_RW_size_sp = 2
    _sizeval_ .set SFX_RW_size_s2
  .elseif SFX_RW_size_sp = 3
    _sizeval_ .set SFX_RW_size_s3
  .elseif SFX_RW_size_sp = 4
    _sizeval_ .set SFX_RW_size_s4
  .elseif SFX_RW_size_sp = 5
    _sizeval_ .set SFX_RW_size_s5
  .elseif SFX_RW_size_sp = 6
    _sizeval_ .set SFX_RW_size_s6
  .elseif SFX_RW_size_sp = 7
    _sizeval_ .set SFX_RW_size_s7
  .elseif SFX_RW_size_sp = 8
    _sizeval_ .set SFX_RW_size_s8
  .endif

  .if _sizeval_ = %00
    RW a16i16
  .elseif _sizeval_ = %01
    RW a8i16
  .elseif _sizeval_ = %10
    RW a16i8
  .elseif _sizeval_ = %11
    RW a8i8
  .else
    SFX_error "RW_pull: RW stack underflow"
  .endif

  SFX_RW_size_sp .set SFX_RW_size_sp-1
.endmac

.macro RW_pull_forced
.if SFX_RW_size_sp = 0
  SFX_error "RW_pull_forced: RW stack underflow"
.endif

  .if SFX_RW_size_sp = 0
    _sizeval_ .set $ff
  .elseif SFX_RW_size_sp = 1
    _sizeval_ .set SFX_RW_size_s1
  .elseif SFX_RW_size_sp = 2
    _sizeval_ .set SFX_RW_size_s2
  .elseif SFX_RW_size_sp = 3
    _sizeval_ .set SFX_RW_size_s3
  .elseif SFX_RW_size_sp = 4
    _sizeval_ .set SFX_RW_size_s4
  .elseif SFX_RW_size_sp = 5
    _sizeval_ .set SFX_RW_size_s5
  .elseif SFX_RW_size_sp = 6
    _sizeval_ .set SFX_RW_size_s6
  .elseif SFX_RW_size_sp = 7
    _sizeval_ .set SFX_RW_size_s7
  .elseif SFX_RW_size_sp = 8
    _sizeval_ .set SFX_RW_size_s8
  .endif

  .if _sizeval_ = %00
    RW_forced a16i16
  .elseif _sizeval_ = %01
    RW_forced a8i16
  .elseif _sizeval_ = %10
    RW_forced a16i8
  .elseif _sizeval_ = %11
    RW_forced a8i8
  .else
    SFX_error "RW_pull_forced: RW stack underflow"
  .endif

  SFX_RW_size_sp .set SFX_RW_size_sp-1
.endmac

;Print current accumulator/index width state
.macro RW_print
  .if SFX_RW_a_size = 0
    .out "Accumulator size = 0 (16-bit)"
  .elseif SFX_RW_a_size = 1
    .out "Accumulator size = 1 (8-bit)"
  .else
    .out "Accumulator size undefined (!)"
  .endif
  .if SFX_RW_i_size = 0
    .out "Index size = 0 (16-bit)"
  .elseif SFX_RW_i_size = 1
    .out "Index size = 1 (8-bit)"
  .else
    .out "Index size undefined (!)"
  .endif
.endmac


;-------------------------------------------------------------------------------
;CPU register macros

/**
  Push CPU state to stack
*/
.macro  push
        php
        rep     #$39
        pha
        phb
        phd
        phx
        phy
        RW_assume a16i16
.endmac


/**
  Pull CPU state from stack
*/
.macro  pull
        rep     #$39
        ply
        plx
        pld
        plb
        pla
        plp
.endmac


/**
  Set data bank register (DB)

  :in:    bank  Bank          uint8   a/x/y or value (using a)
*/
.macro  dbank   bank
.if .xmatch({bank}, {a})
        RW_assert a8
        pha
        plb
.elseif .xmatch({bank}, {x})
        RW_assert i8
        phx
        plb
.elseif .xmatch({bank}, {y})
        RW_assert i8
        phy
        plb
.else
        RW_push set:a8
  .ifconst(bank)
        lda     #bank
  .else
        lda     #^bank
  .endif
        pha
        plb
        RW_pull
.endif
.endmac


/**
  dpo()
  Get address minus current direct page offset

  Works with the latest value set by the 'dpage' macro with a constant/symbol parameter
*/
SFX_dp_offset .set 0
.define dpo(addr) -SFX_dp_offset+(addr)


/**
  dpage
  Set direct page register (D)

  :in:    offs  Offset        uint16  a or value (using a)
*/
.macro  dpage   offs
        RW_push set:a16
.if .xmatch({offs}, {a})
        tcd
.else
        SFX_dp_offset .set .loword(offs)
        lda     #.loword(offs)
        tcd
.endif
        RW_pull
.endmac



;-------------------------------------------------------------------------------
;Meta instructions

/**
  Relative subroutine call

  :param: addr  Address
*/
.macro  bsr     addr
        per     * + 4
        bra     addr
.endmac

/**
  Relative long subroutine call

  :param: addr  Address
*/
.macro  bsl     addr
        per     * + 5
        brl     addr
.endmac


.endif
