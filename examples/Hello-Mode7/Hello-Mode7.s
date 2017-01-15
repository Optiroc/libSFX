; Hello Mode 7
; David Lindecrantz <optiroc@gmail.com>
;
; Mode 7 infinite zoom

.include "libSFX.i"

;VRAM destination addresses
VRAM_MODE7_LOC   = $0000

CENTER_X = 524
CENTER_Y = 538
SCROLL_X = (CENTER_X - (256/2)) - 8
SCROLL_Y = (CENTER_Y - (224/2)) - 12

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

        ldx     #$0000
        stx     scale

        ldx     #$0001
        stx     speed

        ;Set VBlank handler
        VBL_set VBL

        ;Turn on screen
        lda     #inidisp(ON, DISP_BRIGHTNESS_MAX)
        sta     SFX_inidisp
        VBL_on

:       wai                     ;Simply wait in main loop
        bra     :-              ;VBL is called in each vertical blanking period

;-------------------------------------------------------------------------------
VBL:
        RW a16

        lda     scale
        add     speed
        sta     scale

        and     #$003f          ;Increase speed every 64 frames
        bne     :+
        inc     speed
:
        lda     speed           ;Start flashing after a while
        and     #$fff0
        beq     :+

        inc     speed
        lda     color
        sub     speed
        and     #%0011110011101111
        sta     color
        tax
        CGRAM_setcolor 0, x
:
        RW a8                   ;Set mode 7 registers
        lda     scale
        sta     M7A
        lda     scale+1
        sta     M7A
        lda     scale
        sta     M7D
        lda     scale+1
        sta     M7D

        rtl

;-------------------------------------------------------------------------------
.segment "LORAM"
scale: .res 2
color: .res 2
speed: .res 2

;-------------------------------------------------------------------------------
;Import graphics
.segment "RODATA"
incbin  Palette,        "Data/SNES-Mode7.png.palette"
incbin  Tiles,          "Data/SNES-Mode7.png.tiles.lz4"
incbin  Map,            "Data/SNES-Mode7.png.map.lz4"

;Import music
.define spc_file "Data/Music.spc"
.segment "RODATA"
SPC_State:    SPC_incbin_state spc_file
.segment "ROM2"
SPC_Image_Lo: SPC_incbin_lo spc_file
.segment "ROM3"
SPC_Image_Hi: SPC_incbin_hi spc_file
