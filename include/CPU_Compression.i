; libSFX Data Compression Macros
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_CPU_Compression__
::__MBSFX_CPU_Compression__ = 1

.global SFX_LZ4_decompress, SFX_LZ4_decompress_block

;-------------------------------------------------------------------------------
;LZ4 decompression

/**
  Decompress LZ4 frame

  :in:    source  LZ4 frame address (uint24)    constant
  :in:    dest    Destination address (uint24)  ay/hi:y/ex:y
                                                constant
  :out?:  outlen  Decompressed length (uint16)  a/x/y
*/
.macro  LZ4_decompress source, dest, outlen
.if (.blank({dest}))
  SFX_error "LZ4_decompress: Missing required parameter(s)"
.else
        RW_push set:a16i16
        ldx     #.loword(source)
.if .xmatch({dest}, {ay})
        xba
        and     #$ff00
        ora     #.loword(^source)
.elseif .xmatch({dest}, {hi:y})
        lda     #$7e00
        ora     #.loword(^source)
.elseif .xmatch({dest}, {ex:y})
        lda     #$7f00
        ora     #.loword(^source)
.else
        ldy     #.loword(dest)
        lda     #.loword((^dest << 8) + ^source)
.endif
        RW a8
        jsl     SFX_LZ4_decompress
        RW_assume a16

.ifnblank outlen
  .if .xmatch({outlen}, {a})
        ;no-nop, length already in a
  .elseif .xmatch({outlen}, {x})
        tax
  .elseif .xmatch({outlen}, {y})
        tay
  .else
    SFX_error "LZ4_decompress: Parameter 'outlen' is incorrect"
  .endif
.endif

        RW_pull
.endif
.endmac

/**
  Decompress LZ4 block

  :in:    source  LZ4 block address (uint24)    constant
  :in:    dest    Destination address (uint24)  ay/hi:y/ex:y
                                                constant
  :out?:  outlen  Decompressed length (uint16)  a/x/y
*/
.macro  LZ4_decompress_block source, dest
.if (.blank({dest}))
  SFX_error "LZ4_decompress_block: Missing required parameter(s)"
.else
        RW_push set:a16i16
        ldx     #.loword(source)
.if .xmatch({dest}, {ay})
        xba
        and     #$ff00
        ora     #.loword(^source)
.elseif .xmatch({dest}, {hi:y})
        lda     #$7e00
        ora     #.loword(^source)
.elseif .xmatch({dest}, {ex:y})
        lda     #$7f00
        ora     #.loword(^source)
.else
        ldy     #.loword(dest)
        lda     #.loword((^dest << 8) + ^source)
.endif
        RW a8
        jsl     SFX_LZ4_decompress_block
        RW_assume a16

.ifnblank outlen
  .if .xmatch({outlen}, {a})
        ;no-op, length already in a
  .elseif .xmatch({outlen}, {x})
        tax
  .elseif .xmatch({outlen}, {y})
        tay
  .else
    SFX_error "LZ4_decompress_block: Parameter 'outlen' is incorrect"
  .endif
.endif

        RW_pull
.endif
.endmac


.endif; __MBSFX_CPU_Compression__
