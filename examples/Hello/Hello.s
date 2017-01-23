; Hello
; David Lindecrantz <optiroc@gmail.com>
;
; Super basic example that decompresses and displays some graphics and plays an SPC song

.include "libSFX.i"

;VRAM destination addresses
VRAM_MAP_LOC     = $0000
VRAM_TILES_LOC   = $8000

Main:
        ;Transfer and execute SPC file
        SMP_playspc SPC_State, SPC_Image_Lo, SPC_Image_Hi

        ;Decompress graphics and upload to VRAM
        LZ4_decompress Map, EXRAM, y
        VRAM_memcpy VRAM_MAP_LOC, EXRAM, y
        LZ4_decompress Tiles, EXRAM, y
        VRAM_memcpy VRAM_TILES_LOC, EXRAM, y
        CGRAM_memcpy 0, Palette, sizeof_Palette

        ;Set up screen mode
        lda     #bgmode(BG_MODE_1, BG3_PRIO_NORMAL, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8)
        sta     BGMODE
        lda     #bgsc(VRAM_MAP_LOC, SC_SIZE_32X32)
        sta     BG1SC
        ldx     #bgnba(VRAM_TILES_LOC, 0, 0, 0)
        stx     BG12NBA
        lda     #tm(ON, OFF, OFF, OFF, OFF)
        sta     TM

        ;Turn on screen
        lda     #inidisp(ON, DISP_BRIGHTNESS_MAX)
        sta     SFX_inidisp
        VBL_on

:       wai
        bra     :-

;-------------------------------------------------------------------------------

;Import graphics
.segment "RODATA"
incbin  Palette,        "Data/SNES.png.palette"
incbin  Tiles,          "Data/SNES.png.tiles.lz4"
incbin  Map,            "Data/SNES.png.map.lz4"

;Import music
.define spc_file "Data/Music.spc"
.segment "RODATA"
SPC_State:    SPC_incbin_state spc_file
.segment "ROM2"
SPC_Image_Lo: SPC_incbin_lo spc_file
.segment "ROM3"
SPC_Image_Hi: SPC_incbin_hi spc_file
