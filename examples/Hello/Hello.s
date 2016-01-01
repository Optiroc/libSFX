; Hello
; David Lindecrantz <optiroc@gmail.com>
;
; Super basic example that decompresses and displays some graphics and plays an SPC song

.include "libSFX.i"

Main:
        break
        FIFO_alloc MIDI1+hi, $20
        FIFO_alloc MIDI2+HI, $20
        FIFO_alloc MIDI3+ex, $20
        FIFO_alloc BONKERS_FAT, $80
        ;FIFO_read "BONKERS", 0

        ;Transfer and execute SPC file
        SMP_playspc SPC_State, SPC_Image_Lo, SPC_Image_Hi

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
SPC_State:    SPC_incbin_state spc_file
.segment "ROM2"
SPC_Image_Lo: SPC_incbin_lo spc_file
.segment "ROM3"
SPC_Image_Hi: SPC_incbin_hi spc_file
