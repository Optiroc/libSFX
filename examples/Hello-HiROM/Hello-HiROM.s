; Hello-HiROM
; David Lindecrantz <optiroc@gmail.com>
;
; Mode21/HiROM version of the "Hello" example

.include "libSFX.i"

Main:
        ;Transfer and execute SPC file
        SMP_playspc_hirom SPC_Image, SPC_State

        ;Decompress graphics and upload to VRAM
        LZ4_decompress Tilemap, EXRAM, y
        VRAM_memcpy $0000, EXRAM, y
        LZ4_decompress Tiles, EXRAM, y
        VRAM_memcpy $4000, EXRAM, y
        CGRAM_memcpy 0, Palette, Palette_END-Palette

        ;Set up screen mode
        lda     #BG_MODE_1
        sta     BGMODE
        lda     #$00
        sta     BG1SC
        ldx     #$fff4
        stx     BG12NBA
        lda     #$01
        sta     TM

        ;Turn on screen
        lda     #$0f
        sta     SFX_inidisp
        VBL_on

:       wai
        bra :-


;-------------------------------------------------------------------------------

;Import graphics
.segment "RODATA"
Tilemap:      .incbin "Data/SNES.png.tilemap.lz4"
Tiles:        .incbin "Data/SNES.png.tiles.lz4"
Palette:      .incbin "Data/SNES.png.palette"
Palette_END:

;Import music
.define spc_file "Data/Music.spc"
.segment "RODATA"
SPC_State:  SPC_incbin_state spc_file
.segment "ROM1"
SPC_Image:  SPC_incbin spc_file
