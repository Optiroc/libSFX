; Hello
; David Lindecrantz <optiroc@gmail.com>
;
; Example using the Mouse package to control two animated sprites
; using either mouse or joypad in either port

.include "libSFX.i"
.include "OAM.i"

;VRAM destination addresses
VRAM_MAP_LOC     = $0000
VRAM_TILES_LOC   = $8000
VRAM_SPRITES_LOC = $C000

Main:
        ;Set normal mouse sensitivty
        lda     #MOUSE_sensitivity_normal
        sta     SFX_mouse1+MOUSE_data::sensitivity
        sta     SFX_mouse2+MOUSE_data::sensitivity

        ;Init shadow oam
        OAM_init shadow_oam, 0, 0, 0

        ;Set initial cursor positions
        lda     #78
        ldx     #45
        sta     z:SFX_mouse1+MOUSE_data::cursor_y
        stx     z:SFX_mouse1+MOUSE_data::cursor_x
        lda     #45
        ldx     #208
        sta     z:SFX_mouse2+MOUSE_data::cursor_y
        stx     z:SFX_mouse2+MOUSE_data::cursor_x

        ;Transfer and execute SPC file
        SMP_playspc SPC_State, SPC_Image_Lo, SPC_Image_Hi

        ;Decompress graphics and upload to VRAM
        LZ4_decompress Map, EXRAM, y
        VRAM_memcpy VRAM_MAP_LOC, EXRAM, y

        LZ4_decompress Tiles, EXRAM, y
        VRAM_memcpy VRAM_TILES_LOC, EXRAM, y

        LZ4_decompress Sprites, EXRAM, y
        VRAM_memcpy VRAM_SPRITES_LOC, EXRAM, y

        CGRAM_memcpy 0, Palette, sizeof_Palette
        CGRAM_memcpy 128, Palette_spr, sizeof_Palette_spr

        ;Set up screen mode
        lda     #bgmode(BG_MODE_1, BG3_PRIO_NORMAL, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8)
        sta     BGMODE
        lda     #bgsc(VRAM_MAP_LOC, SC_SIZE_32X32)
        sta     BG1SC
        ldx     #bgnba(VRAM_TILES_LOC, 0, 0, 0)
        stx     BG12NBA
        lda     #objsel(VRAM_SPRITES_LOC, OBJ_8x8_32x32, 0)
        sta     OBJSEL
        lda     #tm(ON, OFF, OFF, OFF, ON)
        sta     TM

        ;Set VBlank handler
        VBL_set VBL

        ;Turn on screen
        lda     #inidisp(ON, DISP_BRIGHTNESS_MAX)
        sta     SFX_inidisp
        VBL_on
:       wai
        bra     :-

;-------------------------------------------------------------------------------
VBL:
        ;Set sprite attributes
        lda     SFX_tick
        ror
        and     #$0c
        tay
        lda     z:SFX_mouse1+MOUSE_data::cursor_y
        ldx     z:SFX_mouse1+MOUSE_data::cursor_x
        OAM_set shadow_oam, 0, 0, 0, 0, 1, 3

        lda     SFX_tick
        ror
        ror
        and     #$0c
        tay
        lda     z:SFX_mouse2+MOUSE_data::cursor_y
        ldx     z:SFX_mouse2+MOUSE_data::cursor_x
        OAM_set shadow_oam, 1, 0, 0, 0, 1, 3

        ;Copy shadow OAM
        OAM_memcpy shadow_oam

        rtl

;-------------------------------------------------------------------------------
.segment "LORAM"
shadow_oam:     .res 512+32

;-------------------------------------------------------------------------------

;Import graphics
.segment "RODATA"
incbin  Palette,        "Data/SNES.png.palette"
incbin  Tiles,          "Data/SNES.png.tiles.lz4"
incbin  Map,            "Data/SNES.png.map.lz4"

incbin  Sprites,        "Data/Sprites.png.tiles.lz4"
incbin  Palette_spr,    "Data/Sprites.png.palette"

;Import music
.define spc_file "Data/Music.spc"
.segment "RODATA"
SPC_State:    SPC_incbin_state spc_file
.segment "ROM2"
SPC_Image_Lo: SPC_incbin_lo spc_file
.segment "ROM3"
SPC_Image_Hi: SPC_incbin_hi spc_file
