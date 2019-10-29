; libSFX Data Compression Macros
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_CPU_Compression__
::__MBSFX_CPU_Compression__ = 1

.global SFX_LZ4_decompress, SFX_LZ4_decompress_block

;-------------------------------------------------------------------------------
/**
  Group: LZ4
  Optional package adding LZ4 decompression

  <LZ4 at http://www.lz4.org> is an extremely simple compression algorithm
  that still outperforms algorithms traditionally most popular on consoles – like
  LZSS and its derivatives – both in compression ratio and decoding speed.

  Olivier Zardini has published a popular <65816 implementation at http://www.brutaldeluxe.fr/products/crossdevtools/lz4/>
  which relies heavily on self-modifying code. That makes it very fast and
  small, and it suits 65816-equipped home computers perfectly. It does have
  some drawbacks, though∶

  * It can't run from read only memory regions
  * It uses fixed source and destination offsets
  * The compressed stream size is needed as parameter

  The implementation included in libSFX overcome all these limitations with
  a slight (or even moderate!) performancy penalty. I haven't benchmarked the
  two under controlled circumstances, but the libSFX implementation shouldn't
  be much of a bottleneck at between 200-300KB/s (decoding 32-48KB blocks of
  raw image and text data from ROM to WRAM).

  Decompression from any memory region to RAM is performed with
  the <LZ4_decompress> macro. To link LZ4 support in a project, add LZ4
  to libsfx_packages in the project makefile.

  Makefile:
  (start code)
  # Use packages
  libsfx_packages := LZ4
  (end)

  The lz4 encoder is included in the toolchain. To automatically derive
  lz4 compressed files add them to the project makefile.

  Makefile:
  (start code)
  # Derived data files
  derived_files := Data/SNES.png.tiles.lz4
  (end)

  This will compress "Data/SNES.png.tiles" to "Data/SNES.png.tiles.lz4" during build,
  before any source files are assembled.
*/

;-------------------------------------------------------------------------------
/**
  Group: Macros
*/

/**
  Macro: LZ4_decompress
  Decompress LZ4 frame

  Parameters:
  >:in:    source  LZ4 frame address (uint24)    ax/hi:x/ex:x
  >                                              constant
  >:in:    dest    Destination address (uint24)  ay/hi:y/ex:y
  >                                              constant
  >:out?:  outlen  Decompressed length (uint16)  a/x/y

  Example:
  (begin code)
  ;Decompress graphics and upload to VRAM

  LZ4_decompress    Tilemap, EXRAM, y           ;Returns decompressed length in y
  VRAM_memcpy       $2000, EXRAM, y             ;Copy y bytes to VRAM
  (end)
*/
.macro  LZ4_decompress source, dest, outlen
.if (.blank({dest}))
  SFX_error "LZ4_decompress: Missing required parameter(s)"
.elseif (.xmatch({source}, {ax}) .and .xmatch({dest}, {ay}))
  SFX_error "LZ4_decompress: Can't use register a for both source and dest"
.else
        RW_push set:a16i16
  .if .xmatch({source}, {ax}) .or .xmatch({source}, {hi:x}) .or .xmatch({source}, {ex:x})
        ;no-op, source already in x
  .else
        ldx     #.loword(source)
  .endif

  .if .xmatch({dest}, {ay})
        xba
        and     #$ff00
        ora     #.loword(^source)
  .elseif .xmatch({dest}, {hi:y})
    .if .xmatch({source}, {ax})
        and     #$00ff
        ora     #$7e00
    .elseif .xmatch({source}, {hi:x})
        lda     #$7e7e
    .elseif .xmatch({source}, {ex:x})
        lda     #$7e7f
    .else
        lda     #.loword($7e00 + ^source)
    .endif
  .elseif .xmatch({dest}, {ex:y})
    .if .xmatch({source}, {ax})
        and     #$00ff
        ora     #$7f00
    .elseif .xmatch({source}, {hi:x})
        lda     #$7f7e
    .elseif .xmatch({source}, {ex:x})
        lda     #$7f7f
    .else
        lda     #.loword($7f00 + ^source)
    .endif
  .else
        ldy     #.loword(dest)
    .if .xmatch({source}, {ax})
        and     #$00ff
        ora     #.loword(^dest << 8)
    .elseif .xmatch({source}, {hi:x})
        lda     #.loword((^dest << 8) + $007e)
    .elseif .xmatch({source}, {ex:x})
        lda     #.loword((^dest << 8) + $007f)
    .else
        lda     #.loword((^dest << 8) + ^source)
    .endif
  .endif
        RW a8
        jsl     SFX_LZ4_decompress
        RW_assume a16

  .ifnblank outlen
    .if .xmatch({outlen}, {a})
        ;no-op, length already in a
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
  Macro: LZ4_decompress_block
  Decompress LZ4 block

  Parameters:
  >:in:    source  LZ4 block address (uint24)    ax/hi:x/ex:x
  >                                              constant
  >:in:    dest    Destination address (uint24)  ay/hi:y/ex:y
  >                                              constant
  >:out?:  outlen  Decompressed length (uint16)  a/x/y
*/
.macro  LZ4_decompress_block source, dest
.if (.blank({dest}))
  SFX_error "LZ4_decompress_block: Missing required parameter(s)"
.elseif (.xmatch({source}, {ax}) .and .xmatch({dest}, {ay}))
  SFX_error "LZ4_decompress_block: Can't use register a for both source and dest"
.else
        RW_push set:a16i16
  .if .xmatch({source}, {ax}) .or .xmatch({source}, {hi:x}) .or .xmatch({source}, {ex:x})
        ;no-op, source already in x
  .else
        ldx     #.loword(source)
  .endif

  .if .xmatch({dest}, {ay})
        xba
        and     #$ff00
        ora     #.loword(^source)
  .elseif .xmatch({dest}, {hi:y})
    .if .xmatch({source}, {ax})
        and     #$00ff
        ora     #$7e00
    .elseif .xmatch({source}, {hi:x})
        lda     #$7e7e
    .elseif .xmatch({source}, {ex:x})
        lda     #$7e7f
    .else
        lda     #.loword($7e00 + ^source)
    .endif
  .elseif .xmatch({dest}, {ex:y})
    .if .xmatch({source}, {ax})
        and     #$00ff
        ora     #$7f00
    .elseif .xmatch({source}, {hi:x})
        lda     #$7f7e
    .elseif .xmatch({source}, {ex:x})
        lda     #$7f7f
    .else
        lda     #.loword($7f00 + ^source)
    .endif
  .else
        ldy     #.loword(dest)
    .if .xmatch({source}, {ax})
        and     #$00ff
        ora     #.loword(^dest << 8)
    .elseif .xmatch({source}, {hi:x})
        lda     #.loword((^dest << 8) + $007e)
    .elseif .xmatch({source}, {ex:x})
        lda     #.loword((^dest << 8) + $007f)
    .else
        lda     #.loword((^dest << 8) + ^source)
    .endif
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
