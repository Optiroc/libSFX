; libSFX S-CPU/PPU MMIO Math Macros
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_CPU_Math__
::__MBSFX_CPU_Math__ = 1

;-------------------------------------------------------------------------------

/**
  Macro: mulu
  Unsigned multiplication (S-CPU MMIO)

  If :out: parameter is omitted, get result in RDMPYL/H (uint16) after 5 cycles

  Parameters:
  >:in:    n1    Multiplicand (uint8)    a/x/y     Requires RW a8 or i8
  >                                      constant  Uses a, sets RW a8
  >:in:    n2    Multiplier (uint8)      a/x/y     Requires RW a8 or i8
  >                                      constant  Uses a, sets RW a8
  >:out?:  ret   Product (uint16)        a/x/y     Sets RW a16 or i16

  Example:
  (start code)
  lda      #$88
  mulu     a,$7f, x      ;Returns x = #$4378
  (end)
*/
.macro  mulu    n1, n2, ret
.if (.blank({n2}))
  SFX_error "mulu: Missing required parameter(s)"
.else

.if .xmatch({n1}, {a})
        RW_assert a8, "mulu: In parameter 'n1 = a' requires 8-bit accumulator"
        sta     WRMPYA
.elseif .xmatch({n1}, {x})
        RW_assert i8, "mulu: In parameter 'n1 = x' requires 8-bit index registers"
        stx     WRMPYA
.elseif .xmatch({n1}, {y})
        RW_assert i8, "mulu: In parameter 'n1 = y' requires 8-bit index registers"
        sty     WRMPYA
.else
        RW a8
        lda     #n1
        sta     WRMPYA
.endif

.if .xmatch({n2}, {a})
        RW_assert a8, "mulu: In parameter 'n2 = a' requires 8-bit accumulator"
        sta     WRMPYB
.elseif .xmatch({n2}, {x})
        RW_assert i8, "mulu: In parameter 'n2 = x' requires 8-bit index registers"
        stx     WRMPYB
.elseif .xmatch({n2}, {y})
        RW_assert i8, "mulu: In parameter 'n2 = y' requires 8-bit index registers"
        sty     WRMPYB
.else
        RW a8
        lda     #n2
        sta     WRMPYB
.endif

.ifnblank ret
        bit     $ff
        nop
  .if .xmatch({ret}, {a})
        RW a16
        lda     RDMPYL
  .elseif .xmatch({ret}, {x})
        RW i16
        ldx     RDMPYL
  .elseif .xmatch({ret}, {y})
        RW i16
        ldy     RDMPYL
  .else
    SFX_error "mulu: Parameter 'ret' is incorrect"
  .endif
.endif

.endif
.endmac


/**
  Macro: divu
  Unsigned division (S-CPU MMIO)

  If :out: parameters are omitted, get quotient in RDDIVL (uint16)
  and remainder in RDMPYL (uint16) after 13 cycles

  Parameters:
  >:in:    n1    Dividend (uint16)       a/x/y     Requires RW a16 or i16
  >                                      constant  Uses x, sets RW i16
  >:in:    n2    Divisor (uint8)         a/x/y     Requires RW a8 or i8
  >                                      constant  Uses a, sets RW a8
  >:out?:  ret   Quotient (uint16)       a/x/y     Sets RW a16 or i16
  >:out?:  retr  Remainder (uint16)      a/x/y     Sets RW a16 or i16
*/
.macro  divu    n1, n2, ret, retr
.if (.blank({n2}))
  SFX_error "divu: Missing required parameter(s)"
.else

.if .xmatch({n1}, {a})
        RW_assert a16, "divu: In parameter 'n1 = a' requires 16-bit accumulator"
        sta     WRDIVL
.elseif .xmatch({n1}, {x})
        RW_assert i16, "divu: In parameter 'n1 = x' requires 16-bit index registers"
        stx     WRDIVL
.elseif .xmatch({n1}, {y})
        RW_assert i16, "divu: In parameter 'n1 = y' requires 16-bit index registers"
        sty     WRDIVL
.else
        RW i16
        ldx     #n1
        stx     WRDIVL
.endif

.if .xmatch({n2}, {a})
        RW_assert a8, "divu: In parameter 'n2 = a' requires 8-bit accumulator"
        sta     WRDIVB
.elseif .xmatch({n2}, {x})
        RW_assert i8, "divu: In parameter 'n2 = x' requires 8-bit index registers"
        stx     WRDIVB
.elseif .xmatch({n2}, {y})
        RW_assert i8, "divu: In parameter 'n2 = y' requires 8-bit index registers"
        sty     WRDIVB
.else
        RW a8
        lda     #n2
        sta     WRDIVB
.endif

.ifnblank ret
        bit     $ff
        bit     $ff
        bit     $ff
        nop
        nop
  .if .xmatch({ret}, {a})
        RW a16
        lda     RDDIVL
  .elseif .xmatch({ret}, {x})
        RW i16
        ldx     RDDIVL
  .elseif .xmatch({ret}, {y})
        RW i16
        ldy     RDDIVL
  .else
    SFX_error "divu: Parameter 'ret' is incorrect"
  .endif
.endif

.ifnblank retr
  .if .xmatch({retr}, {a})
        RW a16
        lda     RDMPYL
  .elseif .xmatch({retr}, {x})
        RW i16
        ldx     RDMPYL
  .elseif .xmatch({retr}, {y})
        RW i16
        ldy     RDMPYL
  .else
    SFX_error "divu: Parameter 'retr' is incorrect"
  .endif
.endif

.endif
.endmac


/**
  Macro: muls
  Signed multiplication (S-PPU MMIO)

  Not available during Mode 7 rendering
  If :out: parameter is omitted, result available in MPYL/M/H (sint24) immediately

  Parameters:
  >:in:    n1    Multiplicand (sint16)   x/y       Uses a, sets RW a8
  >                                      constant  Uses a, sets RW a8
  >:in:    n2    Multiplier (sint8)      a         Requires RW a8
  >                                      constant  Uses a, sets RW a8
  >:out?:  ret   Product (sint24)        ax/ay     Sets RW a8i16
*/
.macro  muls    n1, n2, ret
.if (.blank({n2}))
  SFX_error "muls: Missing required parameter(s)"
.else

.if .xmatch({n2}, {a})
        RW_assert a8, "muls: In parameter 'n2 = a' requires 8-bit accumulator"
        sta     WRMPYM7B
.else
        RW a8
        lda     #n2
        sta     WRMPYM7B
.endif

.if .xmatch({n1}, {x})
        RW a16
        txa
        RW a8
        sta     WRMPYM7A
        xba
        sta     WRMPYM7A
.elseif .xmatch({n1}, {y})
        RW a16
        tya
        RW a8
        sta     WRMPYM7A
        xba
        sta     WRMPYM7A
.else
        RW a8
        lda     #(.lobyte(n1) & $00ff)   ;Load LSB
        sta     WRMPYM7A
        lda     #(.hibyte(n1) & $00ff)   ;Load MSB
        sta     WRMPYM7A
.endif

.ifnblank ret
  .if .xmatch({ret}, {ax})
        RW a8i16
        lda     MPYH
        ldx     MPYL
  .elseif .xmatch({ret}, {ay})
        RW a8i16
        lda     MPYH
        ldy     MPYL
  .else
    SFX_error "muls: Parameter 'ret' is incorrect"
  .endif
.endif

.endif
.endmac


.endif; __MBSFX_CPU_Math__
