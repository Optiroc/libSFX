; libSFX LZ4 Decompression
; David Lindecrantz <optiroc@gmail.com>

.include "../../libSFX.i"
.segment "LIBSFX_PKG"

;-------------------------------------------------------------------------------
/**
  SFX_LZ4_decompress
  Decompress LZ4 frame

  [a8i16, ret:a16i16]

  Parameters:
  >:in:  x       Source offset
  >:in:  y       Destination offset
  >:in:  b:a     Destination:Source banks

  Returns:
  >:out: a       Decompressed length
*/
SFX_LZ4_decompress:
        RW_assume a8i16
        jsr     Setup
        RW a16i16
        jsr     ReadHeader
        jsr     DecodeBlock
        rtl


/**
  SFX_LZ4_decompress_block
  Decompress LZ4 block
  [a8i16, ret:a16i16]

  :in:  x       Source offset
  :in:  y       Destination offset
  :in:  b:a     Destination:Source banks
  :out: a       Decompressed length
*/
SFX_LZ4_decompress_block:
        RW_assume a8i16
        jsr     Setup
        RW a16i16
        jsr     DecodeBlock
        rtl


;-------------------------------------------------------------------------------
;Scratch pad usage
.define LZ_source   ZPAD+$00    ;Source (indirect long)
.define LZ_dest     ZPAD+$03    ;Destination (indirect long)
.define LZ_mvl      ZPAD+$06    ;Literal block move (mvn + banks + return)
.define LZ_mvm      ZPAD+$0a    ;Match block move (mvn + banks + return)
.define LZ_blockend ZPAD+$0e    ;End address for current block

Setup:
        RW_assume a8i16
        stx     LZ_source+$00   ;Set source for indirect and block move addressing
        sta     LZ_source+$02
        sta     LZ_mvl+$02

        xba                     ;Set destination for indirect and block move addressing
        sty     LZ_dest+$00
        sta     LZ_dest+$02
        sta     LZ_mvl+$01
        sta     LZ_mvm+$01
        sta     LZ_mvm+$02

        lda     #$54            ;Write MVN and RTS/RTL instructions
        sta     LZ_mvl+$00
        sta     LZ_mvm+$00
  .if ROM_MAPMODE <> 1
        lda     #$60            ;Mode 20 = RTS
  .else
        lda     #$6b            ;Mode 21 = RTL
  .endif
        sta     LZ_mvl+$03
        sta     LZ_mvm+$03
        rts

ReadHeader:
        RW_assume a16i16
        jsr     Skip4           ;Skip LZ4 Magic number
        lda     [LZ_source]     ;Read FLG byte
        inc     LZ_source       ;Skip FLG+BD bytes
        inc     LZ_source
        and     #$0008          ;Check content size bit
                                ;b2 = Content checksum
                                ;b3 = Content size
                                ;b4 = Block checksum
                                ;b5 = Blocks independent
        beq     :+
        jsr     Skip4           ;If content size present, skip 4 more bytes
:       inc     LZ_source       ;Skip header checksum
        rts

DecodeBlock:
        RW_assume a16i16
        ldy     LZ_dest         ;Store destination offset for decompressed size calculation
        phy
        lda     [LZ_source]     ;Read lower 16 bits of block size
        jsr     Skip4           ;Skip block size
        add     LZ_source       ;Store block end offset
        sta     LZ_blockend


ReadToken:
        lda     [LZ_source]     ;Read token byte
        pha                     ;Save for @Match
        inc     LZ_source

        and     #$00f0          ;Check high nibble
        beq     @IsBlockDone    ;Zero: No literal

@Literal:
        lsr                     ;Compute literal length
        lsr
        lsr
        lsr
        cmp     #$000f          ;Short literal?
        bne     @CopyLiteral
        jsr     @AddLength

@CopyLiteral:
        ldx     LZ_source       ;Length in A, perform block move
        ldy     LZ_dest
        dec
        phb
  .if ROM_MAPMODE <> 1
        jsr     LZ_mvl          ;Mode 20 = JSR
  .else
        jsl     LZ_mvl          ;Mode 21 = JSL
  .endif
        plb
        stx     LZ_source       ;Copy offsets
        sty     LZ_dest


@IsBlockDone:
        lda     LZ_blockend
        cmp     LZ_source
        beq     @BlockDone


@Match:
        pla                     ;Pull block token
        tax                     ;Stash

        lda     [LZ_source]     ;Read match offset (word)
        pha                     ;and save on stack for @CopyMatch
        inc     LZ_source
        inc     LZ_source

        txa                     ;Swap back token
        and     #$000f          ;Check low nibble
        cmp     #$000f          ;Short match length?
        bne     @CopyMatch
        jsr     @AddLength

@CopyMatch:
        tay                     ;Length in A
        lda     LZ_dest         ;Copy from dest
        sec
        sbc     1,s             ;Offset on stack
        tax
        pla                     ;Unwind

        tya
        add     #$03
        ldy     LZ_dest
        phb
  .if ROM_MAPMODE <> 1
        jsr     LZ_mvm          ;Mode 20 = JSR
  .else
        jsl     LZ_mvm          ;Mode 21 = JSL
  .endif
        plb
        sty     LZ_dest         ;Copy destination offset

        bra     ReadToken


@BlockDone:
        pla
        lda     LZ_dest         ;Calculate decompressed size
        sec
        sbc     1,s             ;Start offset on stack
        plx                     ;Unwind
        rts


@AddLength:
        pha                     ;Accumulated length at s+1
:       lda     [LZ_source]     ;Read next length byte
        inc     LZ_source
        tay
        and     #$00ff          ;Add to length
        clc
        adc     1,s
        sta     1,s

        tya                     ;Check end condition: length byte != #$ff
        RW a8
        inc
        RW a16
        beq     :-

        pla                     ;Done: pull back summed length
        rts


Skip4:  inc     LZ_source       ;Skip 4 bytes
Skip3:  inc     LZ_source       ;Skip 3 bytes
        inc     LZ_source
        inc     LZ_source
        rts
