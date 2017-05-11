; libSFX S-CPU Utility Macros
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_CPU_PPU__
::__MBSFX_CPU_PPU__ = 1

.global SFX_INIT_mmio, SFX_INIT_oam
.global SFX_WAIT_vbl, SFX_PPU_is_ntsc, SFX_PPU_fadeup

;-------------------------------------------------------------------------------
;HDMA Macros

/**
  Macro: HDMA_set_absolute
  Set up absolute mode HDMA

  Parameters:
  >:in:    ch        Channel (0-7)                 constant
  >:in:    mode      Mode (0-7)                    constant
  >:in:    dest      Destination register (uint8)  constant
  >:in:    table     Table location (uint24)       constant
*/
.macro  HDMA_set_absolute ch, mode, dest, table
        RW_push set:a8i16
        lda     #(HDMA_ABSOLUTE + (mode & 7))   ;A->B, absolute + mode
        sta     DMAP0 + (ch * $10)              ;DMAPx
        lda     #(dest & $00ff)                 ;Destination register
        sta     BBAD0 + (ch * $10)              ;BBADx
        ldx     #.loword(table)                 ;Source address
        stx     A1T0L + (ch * $10)              ;A1TxL
        lda     #^table
        sta     A1B0 + (ch * $10)               ;A1Bx
        RW_pull
.endmac

/**
  Macro: HDMA_set_indirect
  Set up indirect mode HDMA

  Parameters:
  >:in:    ch        Channel (0-7)                 constant
  >:in:    mode      Mode (0-7)                    constant
  >:in:    dest      Destination register (uint8)  constant
  >:in:    a1_table  A1 Table location (uint24)    constant
  >:in:    a2_table  A2 Table location (uint24)    constant
*/
.macro  HDMA_set_indirect ch, mode, dest, a1_table, a2_table
        RW_push set:a8i16
        lda     #(HDMA_INDIRECT + (mode & 7))   ;A->B, indirect + mode
        sta     DMAP0 + (ch * $10)              ;DMAPx
        lda     #(dest & $00ff)                 ;Destination register
        sta     BBAD0 + (ch * $10)              ;BBADx
        ldx     #.loword(a1_table)              ;Source address
        stx     A1T0L + (ch * $10)              ;A1TxL
        lda     #^a1_table
        sta     A1B0 + (ch * $10)               ;A1Bx
        lda     #^a2_table
        sta     DASB0 + (ch * $10)              ;DASBx
        RW_pull
.endmac


;-------------------------------------------------------------------------------
;CGRAM Macros

/**
  Macro: CGRAM_setcolor
  Set color at index with a 15 bit "packed" color

  Parameters:
  >:in:    index     CGRAM index (uint8)           a
  >                                                constant
  >:in:    color     Color (uint16)                x/y         0x0bbbbbgggggrrrrr
  >                                                constant
*/
.macro  CGRAM_setcolor index, color
.if (.blank({b}))
  SFX_error "CGRAM_setcolor: Missing required parameter(s)"
.else
        RW_push set:a8i16
.if .not .xmatch({index}, {a})
        lda     #index
.endif
        sta     CGADD

.if (.xmatch({color}, {x}) .or .xmatch({color}, {y}))
        RW a16
  .if .xmatch({color}, {x})
        txa
  .else
        tya
  .endif
        RW a8
        sta     CGDATA
        xba
        sta     CGDATA
.else
        lda     #((color) & $00ff)
        sta     CGDATA
        lda     #((color >> 8) & $00ff)
        sta     CGDATA
.endif
        RW_pull
.endif
.endmac

/**
  Macro: CGRAM_setcolor_rgb
  Set color at index with a constant RGB triplet

  Parameters:
  >:in:    index     CGRAM index (uint8)           a
  >                                                constant
  >:in:    r         Red component (uint8)         constant    5 significant bits
  >:in:    g         Green component (uint8)       constant    5 significant bits
  >:in:    b         Blue component (uint8)        constant    5 significant bits
*/
.macro  CGRAM_setcolor_rgb index, r, g, b
.if (.blank({b}))
  SFX_error "CGRAM_setcolor_rgb: Missing required parameter(s)"
.else
        RW_push set:a8
.if .not .xmatch({index}, {a})
        lda     #index
.endif
        sta     CGADD
        lda     #(((g & %00000111) << 5) + (r & %00011111))
        sta     CGDATA
        lda     #(((b & %00011111) << 2) + ((g & %00011000) >> 3))
        sta     CGDATA
        RW_pull
.endif
.endmac


;-------------------------------------------------------------------------------
;OAM Macros

/**
  Macro: OAM_init
  Initialize shadow OAM table in RAM

  Parameters:
  >:in:    table     Table address (uint24)        constant
  >:in:    xpos      X position (9 bits)           constant
  >:in:    ypos      Y position (8 bits)           constant
  >:in:    size      Size bit                      constant
*/
.macro  OAM_init table, xpos, ypos, size
        RW_push set:a8i16
        ldx     #.loword(table)
        ldy     #(($00ff & ypos) << 8) + ($00ff & xpos)
        lda     #( ((($0100 & xpos) >> 8) | ((size & 1) << 1)) | (((($0100 & xpos) >> 8) | ((size & 1) << 1)) << 2) | (((($0100 & xpos) >> 8) | ((size & 1) << 1)) << 4) | (((($0100 & xpos) >> 8) | ((size & 1) << 1)) << 6))
        xba
        lda     #^table
        jsl     SFX_INIT_oam
        RW_pull
.endmac

/*
.macro OAM_set_tile number, tile
.endmac
*/

/**
  Macro: OAM_memcpy
  Copies shadow OAM table (512+32 bytes) to the PPU

  Disables DMA and uses channel 7 for transfer.

  Parameters:
  >:in:    table     Table address (uint24)        constant
*/
.macro  OAM_memcpy table
        RW_push set:a8i16
        ldx     #0
        stx     OAMADDL         ;Reset oam-addressing
        ldx     #$0400
        stx     DMAP7
        ldx     #.loword(table)
        stx     A1T7L
        lda     #^table
        sta     A1B7
        ldx     #512+32
        stx     DAS7L           ;Size
        lda     #%10000000
        sta     MDMAEN          ;Trig DMA
        RW_pull
.endmac


;-------------------------------------------------------------------------------
;Video Macros

/**
  Macro: WAIT_vbl
  Wait furiously until next vertical blanking period
*/
.macro  WAIT_vbl
        RW_push set:a8
        jsl     SFX_WAIT_vbl
        RW_pull
.endmac

/**
  Macro: WAIT_frames
  Wait for #num vertical blanking periods

  Parameters:
  >:in:    num       Number of frames (uint16)     constant
*/
.macro  WAIT_frames num
        RW_push set:a8i16
        ldx     #num
:       jsl     SFX_WAIT_vbl
        dex
        bne     :-
        RW_pull
.endmac

/**
  Macro: PPU_is_ntsc
  Check if system is NTSC

  Returns:
  >a = 0 / z = 1 if system passes as NTSC
  >a = 1 / z = 0 otherwise
*/
.macro  PPU_is_ntsc
        RW_push set:a8i16
        jsl     SFX_PPU_is_ntsc
        RW_pull
.endmac


.endif;__MBSFX_CPU_PPU__
