; libSFX S-CPU Utility Macros
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_CPU_PPU__
::__MBSFX_CPU_PPU__ = 1

.global SFX_INIT_mmio, SFX_INIT_oam
.global SFX_WAIT_vbl, SFX_PPU_is_ntsc, SFX_PPU_fadeup

;-------------------------------------------------------------------------------
;HDMA Macros

;HDMA_setAbsolute #channel, #mode, #destination, #table_address (a8i16)
;Set absolute HDMA
.macro  HDMA_setAbsolute ch, mode, dest, table
        RW_push set:a8i16
        lda     #(HDMA_ABSOLUTE + mode)         ;A->B, absolute + mode
        sta     DMAP0 + (ch * $10)              ;DMAPx
        lda     #(dest & $00ff)                 ;Destination register
        sta     BBAD0 + (ch * $10)              ;BBADx
        ldx     #.loword(table)                 ;Source address
        stx     A1T0L + (ch * $10)              ;A1TxL
        lda     #^table
        sta     A1B0 + (ch * $10)               ;A1Bx
        RW_pull
.endmac

;HDMA_setIndirect #channel, #mode, #destination, #a1_table_address, #a2_table_address (a8x16)
;Set indirect HDMA
.macro  HDMA_setIndirect ch, mode, dest, a1_table, a2_table
        RW_push set:a8i16
        lda     #(HDMA_INDIRECT + mode)         ;A->B, indirect + mode
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

;CGRAM_setColorRGB #index, #r, #g, #b (a8)
.macro  CGRAM_setColorRGB index, r, g, b
        RW_push set:a8
        lda     #index
        sta     CGADD
        lda     #((g & %00111) << 5) + r
        sta     CGDATA
        lda     #(b << 2) + ((g & %11000) >> 3)
        sta     CGDATA
        RW_pull
.endmac

;CGRAM_setColor #index, #native_color (a8)
.macro  CGRAM_setColor index, color
        RW_push set:a8
        lda     #index
        sta     CGADD
        lda     #((color) & $00ff)
        sta     CGDATA
        lda     #((color >> 8) & $00ff)
        sta     CGDATA
        RW_pull
.endmac

;CGRAM_setColorX #index, X
.macro  CGRAM_setColorX index
        RW_push set:a8i16
        lda     #index
        sta     CGADD
        RW a16
        txa
        RW a8
        sta     CGDATA
        xba
        sta     CGDATA
        RW_pull
.endmac


;-------------------------------------------------------------------------------
;OAM Macros

;OAM_init #oamtable, #x-pos, #y-pos
;Initialize OAM-table
.macro  OAM_init table, xpos, ypos
        RW_push set:a8i16
        ldx     #.loword(table)
        ldy     #(($00ff & ypos) << 8) + ($00ff & xpos)
        lda     #((($0100 & xpos) >> 8) + (4 * (($0100 & xpos) >> 8)) + (16 * (($0100 & xpos) >> 8)) + (64 * (($0100 & xpos) >> 8)))
        xba
        lda     #^table
        jsl     SFX_INIT_oam
        RW_pull
.endmac

;OAM_memcpy #oamtable
;Copies a full OAM table (512+32 bytes) to the PPU (a8i16)
.macro  OAM_memcpy table
        RW_push set:a8i16
        ldx     #0
        stx     OAMADDL         ;Reset oam-addressing
        ldx     #$0400
        stx     DMAP7
        ldx     #.loword(table)
        stx     A1T7L           ;Offset to oamtable
        lda     #^table
        sta     A1B7            ;Bank to oamtable
        ldx     #512+32
        stx     DAS7L           ;Size
        lda     #%10000000
        sta     MDMAEN          ;Trig DMA

        RW_pull
.endmac


;-------------------------------------------------------------------------------
;Video Macros

;WAIT_vbl
;Wait furiously until next vertical blanking period
.macro  WAIT_vbl
        RW_push set:a8
        jsl     SFX_WAIT_vbl
        RW_pull
.endmac

;WAIT_frames #num
;Wait for #num number of vertical blanking periods
.macro  WAIT_frames num
        RW_push set:a8i16
        ldx     #num
:       jsl     SFX_WAIT_vbl
        dex
        bne     :-
        RW_pull
.endmac

;PPU_is_ntsc
;Returns with A=0(Z=1) if system passes as NTSC, otherwise A=1(Z=0)
.macro  PPU_is_ntsc
        RW_push set:a8i16
        jsl     SFX_PPU_is_ntsc
        RW_pull
.endmac


.endif;__MBSFX_CPU_PPU__
