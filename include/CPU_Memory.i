; libSFX S-CPU Memory Macros
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_CPU_Memory__
::__MBSFX_CPU_Memory__ = 1

.global SFX_WRAM_memset, SFX_WRAM_memcpy, SFX_VRAM_memset, SFX_VRAM_memcpy
.global SFX_CGRAM_memset, SFX_CGRAM_memcpy

;-------------------------------------------------------------------------------
;Memory move/set macros

/**
  memset
  Set CPU-bus memory to a given value

  Uses the 65816 block move instruction so its much slower than DMA
  for large blocks of memory. On the other hand it's quicker to setup
  doesn't interfere with DMA.

  :in:    addr    Address               uint24  ax/hi:x/ex:x or value
  :in:    length  Number of bytes       uint16  y or value
  :in?:   value   Value                 uint8   a or value
*/
.macro memset addr, length, value
.if .blank({length})
  SFX_error "memset: Missing required parameter(s)"
.else
        RW_push set:a8i16
        phb

  .if .not .xmatch({addr},{ax})
    ;Put fill value in a
    .if .not .blank(value)
      .if .xmatch({value},{a})
          ;no-op, value in a
      .else
          lda     #value
      .endif
    .else
          lda     #0
    .endif
    ;Bank is known - put bank in _bankbyte numvar, offset in x
    .if .xmatch({addr},{hi:x})
      _bankbyte .set $7e
    .elseif .xmatch({addr},{ex:x})
      _bankbyte .set $7f
    .else
      _bankbyte .set ^(addr)
        ldx     #.loword(addr)
    .endif
        pha                         ;Stash value
        lda     #_bankbyte          ;Put bank in db
        pha
        plb
        pla                         ;Value back in a
        sta     a:$0,x              ;Put fill value in first destination byte
        RW a16                      ;Put length in a
    .if .xmatch({length}, {y})
        tya
        dec
        dec
    .else
        lda     #length-2           ;Inline length
    .endif
        txy
        iny
        mvn     _bankbyte, _bankbyte
  .else
    ;Bank is in 'a', use zeropage mvn
    RW_assert a8, "memset: Accumulator must be 8-bit with 'ax' adress"
    .if .not .blank(value)
      .if .xmatch({value},{a})
        pha                         ;Value and bank in a, stash a (unlikely, but hey!)
      .endif
    .endif
        sta   SFX_mvn_src           ;Write banks
        sta   SFX_mvn_dst
        pha                         ;Bank in db
        plb
    .if .not .blank(value)
      .if .xmatch({value},{a})
        pla                         ;Pull back value
      .else
        lda     #value
      .endif
    .else
        lda     #0
    .endif
        sta     a:$0,x              ;Put fill value in first destination byte
        RW a16
    .if .xmatch({length}, {y})
        tya
        dec
        dec
    .else
        lda     #length-2           ;Inline length
    .endif
        txy
        iny
        jsl     SFX_mvn
  .endif

        plb
        RW_pull
.endif
.endmac


/**
  memcpy
  Copy bytes from/to CPU-bus

  Uses the 65816 block move instruction so its much slower than DMA
  for large transfers. On the other hand it's quicker to setup and
  doesn't interfere with DMA.

  :in:    dest    Destination address   uint24  ay/hi:y/ex:y or value
  :in:    source  Source address        uint24  ax/hi:x/ex:x or value
  :in:    length  Length                uint16  a or value
*/
.macro memcpy dest, source, length
.if .blank({length})
  SFX_error "memcpy: Missing required parameter(s)"
.else
        RW_push set:i16

  .if (.xmatch({dest},{ay}) .or .xmatch({source},{ax}))
    ;Using 'a' as bank pointer, set that right away so 'a' can safely be modified later
        RW a8
    .if .xmatch({dest},{ay})
        sta   SFX_mvn_dst
    .endif
    .if .xmatch({source},{ax})
        sta   SFX_mvn_src
    .endif
  .endif

  ;Set length
        RW a16
  .if .xmatch({length},{a})
        dec
  .else
        lda     #length-1
  .endif

  .if .not (.xmatch({dest},{ay}) .or .xmatch({source},{ax}))
    ;Banks are values, use inlined block move
    .if (.not (.xmatch({dest},{hi:y}) .or .xmatch({dest},{ex:y}) .or .xmatch({source},{hi:x}) .or .xmatch({source},{ex:x})))
      .if (.const(dest) .and .const(source))
        ;Addresses are known values - overlapping safe move
        .if (.loword(source) >= .loword(dest))
          ldx     #.loword(source)
          ldy     #.loword(dest)
          mvn     ^(dest), ^(source)
        .else
          ldx     #.loword(source)+length-1
          ldy     #.loword(dest)+length-1
          mvp     ^(dest), ^(source)
        .endif
      .else
        ;Addresses not known - mvn is the best bet
          ldx     #.loword(source)
          ldy     #.loword(dest)
          mvn     ^(dest), ^(source)
      .endif
    .else
      ;Addresses in registers - use mvn
      .if (.xmatch({dest},{hi:y}) .and .xmatch({source},{hi:x}))
          mvn     $7e, $7e
      .elseif (.xmatch({dest},{hi:y}) .and .xmatch({source},{ex:x}))
          mvn     $7e, $7f
      .elseif (.xmatch({dest},{ex:y}) .and .xmatch({source},{hi:x}))
          mvn     $7f, $7e
      .elseif (.xmatch({dest},{ex:y}) .and .xmatch({source},{ex:x}))
          mvn     $7f, $7f
      .endif
    .endif
  .else
    ;At least one bank only known at runtime, use zeropage mvn
    .if .const(dest)
          RW i8
          ldy     #^dest
          sty     SFX_mvn_dst
          RW i16
          ldy     #.loword(dest)
    .endif
    .if .const(source)
          RW i8
          ldx     #^source
          stx     SFX_mvn_src
          RW i16
          ldx     #.loword(source)
    .endif
        jsl     SFX_mvn
  .endif
        phk
        plb
        RW_pull
.endif
.endmac


/**
  WRAM_memset
  Set WRAM to a given value

  Disables DMA and uses channel 7 for transfer.

  :in:    addr    Address               uint24  hi:x/ex:x or value
  :in:    length  Number of bytes       uint16  y or value
  :in?:   value   Value                 uint8   a or value
*/
.macro  WRAM_memset addr, length, value
.if .blank({length})
  SFX_error "WRAM_memset: Missing required parameter(s)"
.else
        RW_push set:a8i16

  .if .not (.xmatch({value},{a}) .and (.xmatch({addr},{hi:x}) .or .xmatch({addr},{ex:x})))
        RW a16
        lda     #(value << 8) + (^addr & $7f)
        ldx     #.loword(addr)
  .else
        RW a8
    .ifblank value
        lda     #0
    .elseif .not .xmatch({value},{a})
        lda     #value
    .endif
        xba
    .if .xmatch({addr},{hi:x})
        lda     #$7e
    .elseif .xmatch({addr},{ex:x})
        lda     #$7f
    .else
        lda     #(^addr & $7f)
    .endif
  .endif

  .if .not .xmatch({length},{y})
        ldy     #length
  .endif

        RW a8
        jsl     SFX_WRAM_memset
        RW_pull
.endif
.endmac


/**
  WRAM_memcpy
  Copy bytes from CPU-bus to WRAM

  Disables DMA and uses channel 7 for transfer.
  WRAM to WRAM copy is not possible.

  :in:    dest    Destination address   uint24  ax/ay/hi:x/hi:y/ex:x/ex:y or value
  :in:    source  Source address        uint24  value
  :in:    length  Length                uint16  a/x/y or value
*/
.macro  WRAM_memcpy dest, source, length
.if .blank({length})
  SFX_error "WRAM_memcpy: Missing required parameter(s)"
.else
        RW_push set:a8i16

  .if .xmatch({dest}, {ay})
        sty     WMADDL                          ;Set dest offset
        and     #$01
        sta     WMADDH                          ;Set dest bank
  .elseif .xmatch({dest}, {ax})
        stx     WMADDL                          ;Set dest offset
        and     #$01
        sta     WMADDH                          ;Set dest bank
  .elseif .xmatch({dest}, {hi:y})
        sty     WMADDL                          ;Set dest offset
        stz     WMADDH                          ;Set dest bank
  .elseif .xmatch({dest}, {hi:x})
        stx     WMADDL                          ;Set dest offset
        stz     WMADDH                          ;Set dest bank
  .elseif .xmatch({dest}, {ex:y})
        sty     WMADDL                          ;Set dest offset
    .if .xmatch({length}, {a})
        xba
        lda     #$01
        sta     WMADDH                          ;Set dest bank
        xba
    .else
        lda     #$01
        sta     WMADDH                          ;Set dest bank
    .endif
  .elseif .xmatch({dest}, {ex:x})
        stx     WMADDL                          ;Set dest offset
    .if .xmatch({length}, {a})
        xba
        lda     #$01
        sta     WMADDH                          ;Set dest bank
        xba
    .else
        lda     #$01
        sta     WMADDH                          ;Set dest bank
    .endif
  .else
    .if .xmatch({length}, {x})
        ldy     #.loword(dest)
        sty     WMADDL                          ;Set dest offset
    .else
        ldx     #.loword(dest)
        stx     WMADDL                          ;Set dest offset
    .endif
    .if .xmatch({length}, {a})
        xba
        lda     #(^dest & $1)
        sta     WMADDH                          ;Set dest bank
        xba
    .else
        lda     #(^dest & $1)
        sta     WMADDH                          ;Set dest bank
    .endif
  .endif

  .if .xmatch({length}, {a})
        xba
        lda     #$00
        xba
        tay
  .elseif .xmatch({length}, {x})
        txy
  .elseif .xmatch({length}, {y})
        ;no-nop
  .else
        ldy     #length                         ;Load length
  .endif

        lda     #^source                        ;Load source bank
        ldx     #.loword(source)                ;Load source offset
        jsl     SFX_WRAM_memcpy
        RW_pull
.endif
.endmac


/**
  VRAM_memset

  Set VRAM to a given value
  Disables DMA and uses channel 7 for transfer.

  :in:    addr    Address               uint16  x (word address) or value (byte address)
  :in:    length  Length                uint16  y (words) or value (bytes)
  :in?:   value   Value                 uint8   a or value
*/
.macro  VRAM_memset addr, length, value
.if .blank({length})
  SFX_error "VRAM_memset: Missing required parameter(s)"
.else
        RW_push set:a8i16

  .if .not .xmatch({addr},{x})
        ldx     #.loword(addr >> 1)
  .endif
  .if .not .xmatch({length},{y})
        ldy     #.loword(length)
  .endif

  .ifblank value
        lda     #0
  .elseif .not .xmatch({value},{a})
        lda     #value
  .endif

        jsl     SFX_VRAM_memset
        RW_pull
.endif
.endmac


/**
  VRAM_memcpy

  Copy bytes from CPU-bus to VRAM.
  Disables DMA and uses channel 7 for transfer.

  :in:    dest    Destination           uint16  y (word address) or value (byte address)
  :in:    source  Source                uint24  ax/hi:x/ex:x or value
  :in:    length  Length                uint16  y/a(<<8) or value
*/
.macro  VRAM_memcpy dest, source, length
.if .blank({length})
  SFX_error "VRAM_memcpy: Missing required parameter(s)"
.elseif (.xmatch({source}, {ax}) .and .xmatch({length}, {a}))
  SFX_error "VRAM_memcpy: Can't use register a for both source and length"
.else
        RW_push set:a8i16

  .if .xmatch({dest},{y})
        sty     VMADDL                          ;Set VRAM destination (in words)
  .else
    .if .xmatch({length},{y}) .and .xmatch( .right(1,{source}),{x} )
        phy                                     ;No register free, use stack
        ldy     #.loword(dest >> 1)
        sty     VMADDL                          ;Set VRAM destination (in bytes)
        ply
    .else
      .if .xmatch({length},{y})
        ldx     #.loword(dest >> 1)             ;Register x not used
        stx     VMADDL                          ;Set VRAM destination (in bytes)
      .else
        ldy     #.loword(dest >> 1)             ;Register y not used
        sty     VMADDL                          ;Set VRAM destination (in bytes)
      .endif
    .endif
  .endif

  .if .xmatch({length},{y})
        ;no-op
  .elseif .xmatch({length},{a})
        RW a16
        and     #$00ff
        xba
        tay
        RW a8
  .else
        ldy     #length                         ;Load length
  .endif

  .if .xmatch({source},{ax})
        ;nop
  .elseif .xmatch({source},{hi:x})
        lda     #$7e                            ;Load source bank
  .elseif .xmatch({source},{ex:x})
        lda     #$7f                            ;Load source bank
  .else
        ldx     #.loword(source)                ;Load source offset
        lda     #^source                        ;Load source bank
  .endif

        jsl     SFX_VRAM_memcpy
        RW_pull
.endif
.endmac


/**
  CGRAM_memcpy

  Copy bytes from CPU-bus to CGRAM.
  Disables DMA and uses channel 7 for transfer.

  :in:    dest    Destination (word)    uint16  a or value
  :in:    source  Source                uint24  ax/hi:x/ex:x or value
  :in:    length  Length                uint16  y or value
*/
.macro  CGRAM_memcpy dest, source, length
.if .blank({length})
  SFX_error "CGRAM_memcpy: Missing required parameter(s)"
.elseif (.xmatch({source}, {ax}) .and .xmatch({dest}, {a}))
  SFX_error "CGRAM_memcpy: Can't use register a for both source and destination"
.else
        RW_push set:a8i16

  .if .xmatch({dest},{a})
        sta     CGADD                           ;Set CGRAM address
  .else
        lda     #.loword(dest)                  ;Register y not used
        sta     CGADD                           ;Set CGRAM address
  .endif

  .if .xmatch({length},{y})
        ;no-op
  .else
        ldy     #.loword(length)                ;Load length
  .endif

  .if .xmatch({source},{ax})
        ;nop
  .elseif .xmatch({source},{hi:x})
        lda     #$7e                            ;Load source bank
  .elseif .xmatch({source},{ex:x})
        lda     #$7f                            ;Load source bank
  .else
        ldx     #.loword(source)                ;Load source offset
        lda     #^source                        ;Load source bank
  .endif

        jsl     SFX_CGRAM_memcpy
        RW_pull
.endif
.endmac


.endif; __MBSFX_CPU_Memory__
