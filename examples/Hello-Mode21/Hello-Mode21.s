; Hello-HiROM
; David Lindecrantz <optiroc@gmail.com>
;
; Mode 21 (colloquially known as "HiROM") version of the "Hello" example

.include "libSFX.i"

TILEMAP_LOC     = $0000
TILESET_LOC     = $8000

Main:
        ;Transfer and execute SPC file
        SMP_playspc SPC_State, SPC_Image

        ;Decompress graphics and upload to VRAM
        LZ4_decompress Tilemap, EXRAM, y
        VRAM_memcpy TILEMAP_LOC, EXRAM, y
        LZ4_decompress Tiles, EXRAM, y
        VRAM_memcpy TILESET_LOC, EXRAM, y
        CGRAM_memcpy 0, Palette, sizeof_Palette

        ;Set up screen mode
        lda     #bgmode(BG_MODE_1, BG3_PRIO_NORMAL, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8)
        sta     BGMODE
        lda     #bgsc(TILEMAP_LOC, SC_SIZE_32X32)
        sta     BG1SC
        ldx     #bgnba(TILESET_LOC, 0, 0, 0)
        stx     BG12NBA
        lda     #tm(ON, OFF, OFF, OFF, OFF)
        sta     TM

        ;Turn on screen
        lda     #inidisp(ON, DISP_BRIGHTNESS_MAX)
        sta     SFX_inidisp
        VBL_on

:       wai
        bra :-


;-------------------------------------------------------------------------------

;Import graphics
.segment "RODATA"
incbin  Tilemap,        "Data/SNES.png.tilemap.lz4"
incbin  Tiles,          "Data/SNES.png.tiles.lz4"
incbin  Palette,        "Data/SNES.png.palette"

;Import music
.define spc_file "Data/Music.spc"
.segment "RODATA"
SPC_State:  SPC_incbin_state spc_file
.segment "ROM1"
SPC_Image:  SPC_incbin spc_file
