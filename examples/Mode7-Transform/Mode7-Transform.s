; Mode 7 Transform
; David Lindecrantz <optiroc@gmail.com>
;
; Mode 7 zoom and rotate using joypad or mouse in port 1
; Building requires python to generate sine table

.include "libSFX.i"
.include "Math.i"

;VRAM destination address
VRAM_MODE7_LOC   = $0000

;Mode 7 center and offset
CENTER_X = 64
CENTER_Y = 64
SCROLL_X = (CENTER_X - (256/2))
SCROLL_Y = (CENTER_Y - (224/2))

Main:
        ;Transfer and execute SPC file
        SMP_playspc SPC_State, SPC_Image_Lo, SPC_Image_Hi

        ;Decompress graphics and transfer to VRAM
        LZ4_decompress Tiles, EXRAM, y
        VRAM_memcpy VRAM_MODE7_LOC, EXRAM, y, $80, 0, $19       ;Transfer tiles to odd VRAM addresses

        LZ4_decompress Map, EXRAM, y
        VRAM_memcpy VRAM_MODE7_LOC, EXRAM, y, 0, 0, $18         ;Transfer map to even VRAM addresses

        CGRAM_memcpy 0, Palette, sizeof_Palette

        ;Set up screen mode
        lda     #bgmode(BG_MODE_7, BG3_PRIO_NORMAL, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8)
        sta     BGMODE
        lda     #bgsc(VRAM_MODE7_LOC, SC_SIZE_32X32)
        sta     BG1SC
        ldx     #bgnba(VRAM_MODE7_LOC, 0, 0, 0)
        stx     BG12NBA
        lda     #tm(ON, OFF, OFF, OFF, OFF)
        sta     TM

        ;Set scroll and mode 7 center
        lda     #<SCROLL_X
        sta     BG1HOFS
        lda     #>SCROLL_X
        sta     BG1HOFS
        lda     #<SCROLL_Y
        sta     BG1VOFS
        lda     #>SCROLL_Y
        sta     BG1VOFS

        lda     #<CENTER_X
        sta     M7X
        lda     #>CENTER_X
        sta     M7X
        lda     #<CENTER_Y
        sta     M7Y
        lda     #>CENTER_Y
        sta     M7Y

        ldx     #$0100
        stx     scale

        ;Set VBlank handler
        VBL_set VBL

        ;Turn on screen
        lda     #inidisp(ON, DISP_BRIGHTNESS_MAX)
        sta     SFX_inidisp
        VBL_on

:       wai                     ;Simply wait in main loop
        bra     :-              ;VBL is called in each vertical blanking period

;-------------------------------------------------------------------------------
VBL:    RW_assume a8i16

        ;Controller deltas -> angle and scale
        RW      a8
        lda     z:SFX_mouse1+MOUSE_data::delta_x
        neg
        sign_extend
        RW      a16
        add     angle
        sta     angle

        RW      a8
        lda     z:SFX_mouse1+MOUSE_data::delta_y
        asl
        asl
        sign_extend
        RW      a16
        add     scale
        sta     scale
        RW      a8

        ;angle -> x
        lda     #$00
        xba
        lda     angle
        tax

        ;scale -> M7 multiplicand
        lda     scale
        sta     WRMPYM7A
        lda     scale+1
        sta     WRMPYM7A

        ;-sin(angle) * scale -> m7b
        lda     Sin,x
        neg
        sta     WRMPYM7B
        ldy     MPYM
        sty     m7b

        ;sin(angle) * scale -> m7c
        lda     Sin,x
        sta     WRMPYM7B
        ldy     MPYM
        sty     m7c

        ;cos index -> x
        lda     #$00
        xba
        txa
        add     #$40
        tax

        ;cos(angle) * scale -> m7a
        lda     Sin,x
        sta     WRMPYM7B
        ldy     MPYM
        sty     m7a

        ;cos(angle) * scale -> m7d
        lda     Sin,x
        sta     WRMPYM7B
        ldy     MPYM
        sty     m7d

        ;set registers
        lda     m7a
        sta     M7A
        lda     m7a+1
        sta     M7A

        lda     m7b
        sta     M7B
        lda     m7b+1
        sta     M7B

        lda     m7c
        sta     M7C
        lda     m7c+1
        sta     M7C

        lda     m7d
        sta     M7D
        lda     m7d+1
        sta     M7D

        rtl

;-------------------------------------------------------------------------------
.segment "LORAM"
angle: .res 2
scale: .res 2

m7a:   .res 2
m7b:   .res 2
m7c:   .res 2
m7d:   .res 2

;-------------------------------------------------------------------------------
;.segment "RODATA_ALIGN"

;Import graphics
.segment "RODATA"

incbin  Sin,            "Data/Sin.bin"

incbin  Palette,        "Data/Background.png.palette"
incbin  Tiles,          "Data/Background.png.tiles.lz4"
incbin  Map,            "Data/Background.png.map.lz4"


;Import music
.define spc_file "Data/Music.spc"
.segment "RODATA"
SPC_State:    SPC_incbin_state spc_file
.segment "ROM2"
SPC_Image_Lo: SPC_incbin_lo spc_file
.segment "ROM3"
SPC_Image_Hi: SPC_incbin_hi spc_file
