; libSFX S-CPU Macros
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_CPU__
::__MBSFX_CPU__ = 1

;-------------------------------------------------------------------------------
/**
  Group: RW* (register width macros)

  Instead of using ca65's .a* and .i* directives or the "smart" mode to set
  current register widths, libSFX uses these macros to track CPU state.

  The main advantage of this approach is that rep/sep instructions will be
  emitted only when necessary. When relying a lot on "function inlining" via
  macros those tend to add up quickly. A bonus is that the state can be
  queried with the RW_a_size() and RW_i_size() macros, allowing for conditial
  assembly depending on register widths.

  This tracking can only work within the same assembly unit, of course. When
  calling function over unit barriers there's an RW stack and a couple of
  helper macros to keep those pesky register sizes in sync.

  Example:

  (start code)
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

  proc external, a16                ;16 bit accumulator is assumed (no instruction emitted)
        lda     #$f00d              ;So this will assemble nicely
        rtl
  endproc
  (end)
*/

/**
  Macro: proc
  Define procedure with separate RW state

  This is equivalent to .proc directive, but ensures that using the RW*
  macros inside of the procedure does not affect tracking of CPU state anywhere
  outside of the procedure, and vice-versa.

  It is recommended to use the 'proc' and 'endproc' macros instead of .proc and
  .endproc for any code using libSFX macros.

  By default, code inside the procedure assumes 8-bit A and 16-bit X/Y (M=1, X=0).
  Optionally, you may specify other incoming register sizes as a parameter.
  (See also: 'RW_init', 'RW_assume')

  Parameter:
  >:in:    name      Procedure name
  >:in?:   widths    Register widths         a8/a16/i8/i16/a8i8/a16i16/a8i16/a16i8
*/
.macro proc name, widths
  RW_push ; save .a8/.a16/etc so ca65 can remember them later
  .proc name
  RW_init ; create new RW state in this scope
  .ifnblank widths
    RW_assume widths ; create new RW state with initial values
  .endif
.endmac

/**
  Macro: endproc
  End procedure and restore RW state

  This is the equivalent to .endproc corresponding with the 'proc' macro.
  This ensures that the outer scope continues to track the correct register
  sizes regardless of any RW* macros which were used in the inner scope.
*/
.macro endproc
  .endproc
  RW_pull ; check previous RW state in outer scope so ca65 can be reminded what the widths were
.endmac

/**
  Macro: RW_init
  Define RW state variables in current scope

  Used by all register width macros to ensure that register state can be tracked
  in any scope. This also means that code inside of a .proc or .scope will not
  affect tracked register widths for code in the global scope, and vice-versa.
  (Thus, the register widths inside a nested scope are always initially a8i16.)
*/
.macro RW_init
  .if !.const(SFX_RW_init)
    SFX_RW_init .set 1

    ;Initial register widths
    RW_assume a8i16

    ;RW stack (bit 0 = accumulator size, bit 1 = index size)
    SFX_RW_size_sp .set 0
    SFX_RW_size_s1 .set %00
    SFX_RW_size_s2 .set %00
    SFX_RW_size_s3 .set %00
    SFX_RW_size_s4 .set %00
    SFX_RW_size_s5 .set %00
    SFX_RW_size_s6 .set %00
    SFX_RW_size_s7 .set %00
    SFX_RW_size_s8 .set %00
  .endif
.endmac

/**
  Macro: RW
  Set accumulator/index register widths

  No-op if current state == intended state.

  Parameter:
  >:in:    widths    Register widths         a8/a16/i8/i16/a8i8/a16i16/a8i16/a16i8
*/
.macro RW widths
.if .blank({widths})
  SFX_error "RW: Missing required parameter"
.else
  RW_init
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


/**
  Macro: RW_assume
  Assume known accumulator/index register widths without emitting any instructions

  Parameter:
  >:in:    widths    Register widths         a8/a16/i8/i16/a8i8/a16i16/a8i16/a16i8
*/
.macro RW_assume widths
.if .blank({widths})
  SFX_error "RW_assume: Missing required parameter"
.else
  RW_init
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


/**
  Macro: RW_forced
  Force set accumulator/index register widths (ie. always emit rep/sep instructions)

  Parameter:
  >:in:    widths    Register widths         a8/a16/i8/i16/a8i8/a16i16/a8i16/a16i8
*/
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


/**
  Macro: RW_assert
  Assert (at assemble time) that the specified register widths
  match with the state of the register tracking logic.

  Parameters:
  >:in:    widths    Register widths         a8/a16/i8/i16/a8i8/a16i16/a8i16/a16i8
  >:in:    message   Error message           string
*/
.macro RW_assert widths, message
.if .blank({message})
  SFX_error "RW_assert: Missing required parameter(s)"
.else
  RW_init
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
    RW_assert a8, message
    RW_assert i16, message
  .elseif .xmatch({widths},{a16i8})
    RW_assert a16, message
    RW_assert i8, message
  .else
    SFX_error "RW_assert: Illegal parameter"
  .endif
.endif
.endmac


/**
  Macro: RW_push
  Push current register widths state to the RW stack,
  and optionally set new state

  No-op if current state == intended state.

  Parameter:
  >:in?:   widths    Register widths         a8/a16/i8/i16/a8i8/a16i16/a8i16/a16i8
*/
.macro RW_push new
  RW_init
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
    .elseif .xmatch({new}, {set:a8i8})
      RW a8i8
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

/**
  Macro: RW_pull
  Pull register widths state from the RW stack

  No-op if current state == intended state.
*/
.macro RW_pull
  RW_init
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


/**
  Macro: RW_pull_forced
  Pull register widths state from the RW stack,
  always emitting rep/sep instructions

  Might come in handy when calling a subroutine that returns
  with the register widths in an unknown state.
*/
.macro RW_pull_forced
  RW_init
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

/**
  Macro: RW_print
  Print (at assemble time) the current register widths state
*/
.macro RW_print
  .if .const(SFX_RW_a_size) .and SFX_RW_a_size = 0
    .out "Accumulator size = 0 (16-bit)"
  .elseif .const(SFX_RW_a_size) .and  SFX_RW_a_size = 1
    .out "Accumulator size = 1 (8-bit)"
  .else
    .out "Accumulator size undefined (!)"
  .endif
  .if .const(SFX_RW_i_size) .and SFX_RW_i_size = 0
    .out "Index size = 0 (16-bit)"
  .elseif .const(SFX_RW_i_size) .and SFX_RW_i_size = 1
    .out "Index size = 1 (8-bit)"
  .else
    .out "Index size undefined (!)"
  .endif
.endmac


/**
  Macro: RW_a_size()
  Get the current accumlator register width

  Returns:
  >0 = 16 bits
  >1 = 8 bits
*/
.define RW_a_size SFX_RW_a_size

/**
  Macro: RW_i_size()
  Get the current index register width

  Returns:
  >0 = 16 bits
  >1 = 8 bits
*/
.define RW_i_size SFX_RW_i_size


;-------------------------------------------------------------------------------
/**
  Group: CPU register macros
*/

/**
  Macro: push
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
  Macro: pull
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
  Macro: dbank
  Set data bank register (DB)

  Parameter:
  >:in:    bank      Bank (uint8)            a/x/y       Requires RW a8 or i8
  >                                          constant    Using a
*/
.macro  dbank   bank
.if .xmatch({bank}, {a})
        RW_assert a8, "dbank: In parameter 'bank = a' requires 8-bit accumulator"
        pha
        plb
.elseif .xmatch({bank}, {x})
        RW_assert i8, "dbank: In parameter 'bank = x' requires 8-bit index registers"
        phx
        plb
.elseif .xmatch({bank}, {y})
        RW_assert i8, "dbank: In parameter 'bank = y' requires 8-bit index registers"
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
  Macro: dpage
  Set direct page register (D)

  Parameter:
  >:in:    offs      Offset (uint16)         a
  >                                          constant    Using a
*/
.macro  dpage   offs
        RW_push set:a16
.if .xmatch({offs}, {a})
        SFX_dp_offset .set 0
        tcd
.else
  .if .const(offs)
        SFX_dp_offset .set .loword(offs)
  .else
        SFX_dp_offset .set 0
  .endif
        lda     #.loword(offs)
        tcd
.endif
        RW_pull
.endmac


/**
  Macro: dpo()
  Get address minus current direct page offset

  Calculates a byte offset using the latest value set by the 'dpage' macro.

  Parameter:
  >:in:    addr      Address (uint16)        constant

  Example:
  (start code)
  dpage   INIDISP
  stz     z:dpo(OBJSEL)           ;Reset OAM regs
  stz     z:dpo(OAMADDL)
  stz     z:dpo(OAMADDH)
  (end)
*/
SFX_dp_offset .set 0
.define dpo(addr) -SFX_dp_offset+(addr)


;-------------------------------------------------------------------------------
/**
  Group: CPU meta instructions
*/

/**
  Meta: bgt
  Branch if greater than

  Parameter:
  >:in:    addr      Address
*/
.macro bgt addr
        beq     :+
        bge     addr
:
.endmac

/**
  Meta: bsr
  Relative subroutine call

  Parameter:
  >:in:    addr      Address
*/
.macro  bsr     addr
        per     * + 4
        bra     addr
.endmac

/**
  Meta: bsl
  Relative long subroutine call

  Parameter:
  >:in:    addr      Address
*/
.macro  bsl     addr
        per     * + 5
        brl     addr
.endmac

/**
  Meta: add
  Add (without carry)

  Parameters:
  >:in:    op        Operand
  >:in?:   ix        Index
*/
.macro add op, ix
  .if .blank({ix})
        clc
        adc     op
  .else
        clc
        adc     op, ix
  .endif
.endmac

/**
  Meta: sub
  Subtract (without carry)

  Parameters:
  >:in:    op        Operand
  >:in?:   ix        Index
*/
.macro sub op, ix
  .if .blank({ix})
        sec
        sbc     op
  .else
        sec
        sbc     op, ix
  .endif
.endmac

/**
  Meta: asr
  Arithmetic shift right
*/
.macro asr
  .if RW_a_size = 1
        cmp     #$80
        ror
  .else
        cmp     #$8000
        ror
  .endif
.endmac

/**
  Meta: neg
  Negate (signed integer)
*/
.macro neg
  .if RW_a_size = 1
        eor     #$ff
        inc
  .else
        eor     #$ffff
        inc
  .endif
.endmac

/**
  Meta: break
  Break debugger

  If assembled with debug=1 the break macro emits a "wdm $00" instruction,
  which can be set to trigger a break in the bsnes+ debugger.
*/
.macro break
  .ifdef ::__DEBUG__
        wdm     $00
  .endif
.endmac


.endif; __MBSFX_CPU__
