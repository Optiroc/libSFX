.include "libSFX.i"

.struct Vec3
        vx      .word
        vy      .word
        vz      .word
.endstruct

.segment "CODE"
Main:
        ;Test NTSC-check, display red screen if not NTSC or emulator with good timing
        PPU_is_ntsc
        beq     :+
        jmp     Not_NTSC
:
;-------------------------------------------------------------------------------
@test_blockmove:
        RW a8i16

        ;Set $7f6000-$7f6004 to #$66
        memset EXRAM+$6000, $5, $66

        ;Copy bytes from SPC_State to $7f6774-$7f68ff
        memcpy EXRAM+$6774, SPC_State, $18c

        ;Copy bytes from $7e0000 (zeroes at this point) to $7f6820-$7f684f
        memcpy EXRAM+$6820, HIRAM, $30

;-------------------------------------------------------------------------------
@test_dbank:
        RW a8i16

        ;Set dbank using value in register a
        lda     #$6
        dbank   a

        ;Set dbank using constant value
        dbank   $44

        ;Set dbank using address
        dbank   Main

;-------------------------------------------------------------------------------
@test_dpage:
        RW a8i16

        ;Set dpage using value in register a
        RW a16
        lda     #$6044
        dpage   a

        ;Set dpage using address
        dpage   repetetive_lz4

        ;Set dpage using constant value
        dpage   $0000

;-------------------------------------------------------------------------------
@test_mulu:
        RW a8i16

        ;mulu register * value -> register
        lda     #$22
        mulu    a,$4, x                 ;Expected: x = #$0088

        ;mulu value * register -> register
        RW i8
        mulu    $7f,x, y                ;Expected: y = #$4378

        ;mulu value * value -> RDMPYL/H
        RW i16
        mulu    .sizeof(Vec3),$66
        bit     $ff
        nop
        ldx     RDMPYL                  ;Expected: x = #$0264

;-------------------------------------------------------------------------------
@test_divu:
        RW a8i16

        ;divu register / value -> register
        ldx     #$9c00
        divu    x,$4, x                 ;Expected: x = #$2700

        ;divu register / value -> register.register
        divu    x,$7, x,y               ;Expected: x = #$0592
                                        ;          y = #$0002

        ;divu value / value -> RDDIVL/H.RDMPYL/H
        divu    .sizeof(Vec3)*100,$05

;-------------------------------------------------------------------------------
@test_muls:
        RW a8i16

        ;muls register * value -> register
        ;Note: Using forced range for negative values, or ca65 gives range error
        ldx     #.loword(-822)
        muls    x,.lobyte(-44), ax      ;Expected: a:x = #$008d48 (+36168)

        ;muls register * register -> register
        lda     #.lobyte(-21)
        ldx     #.loword(1001)
        muls    x,a, ay                 ;Expected: a:y = #$ffade3 (-21021)

;-------------------------------------------------------------------------------
@test_meta:
        RW a8i16

        ;Arithmetic shift right
        RW a8
        lda     #%01101101
        asr                             ;Expected: a = #%00110110 ($36)
        asr                             ;Expected: a = #%00011011 ($1b)

        lda     #%10110001
        asr                             ;Expected: a = #%11011000 ($d8)
        asr                             ;Expected: a = #%11101100 ($ec)

        RW a16
        lda     #%0110001110010001
        asr                             ;Expected: a = #%0011000111001000 ($31c8)
        asr                             ;Expected: a = #%0001100011100100 ($18e4)

        lda     #%1010001110010001
        asr                             ;Expected: a = #%1101000111001000 ($d1c8)
        asr                             ;Expected: a = #%1110100011100100 ($e8e4)

        ;Negate
        ;Note: Using forced range for negative values, or ca65 gives range error
        RW a8
        lda     #101
        neg                             ;Expected: a = #$9b
        lda     #.lobyte(-127)
        neg                             ;Expected: a = #$7f

        RW a16
        lda     #28123
        neg                             ;Expected: a = #$9225
        lda     #.loword(-32767)
        neg                             ;Expected: a = #$7fff

;-------------------------------------------------------------------------------
@test_wram:
        RW a8i16

        ;Copy y bytes from "Tilemap" to a:x
        lda     #$7f
        ldx     #$2000
        ldy     #$100
        WRAM_memcpy ax, Tilemap, y

        ;Copy a bytes from $808000 to $7f:x
        lda     #$90
        ldx     #$5000
        WRAM_memcpy ex:x, $808000, a

;-------------------------------------------------------------------------------
@test_vram:
        RW a8i16

        ;Copy a<<8 bytes from $7e:x to VRAM word address $1600
        ldx     #$4000
        lda     #$02
        VRAM_memcpy $1600, hi:x, a

        ;Copy $100 bytes from $7f:x to VRAM word address in y
        ldy     #$2000
        ldx     #$4000
        VRAM_memcpy y, ex:x, $100

        ;Set $100 bytes from word address in x to value in a
        ldx     #$1220
        lda     #$cc
        VRAM_memset x, $50, a

;-------------------------------------------------------------------------------
@test_lz4:
        RW a8i16

        ;Decompress LZ4 frame at "repetetive_lz4" to "EXRAM", get decompressed length in x
        LZ4_decompress repetetive_lz4, EXRAM, x

        ;Decompress LZ4 frame at "repetetive_lz4" to a:y, get decompressed length in y
        lda     #$7e
        ldy     #$4000
        LZ4_decompress repetetive_lz4, ay, y

        ;Decompress LZ4 frame at "repetetive_lz4" to $7f:y
        ldy     #$4000
        LZ4_decompress repetetive_lz4, ex:y

;-------------------------------------------------------------------------------
@test_mixed:

        ;Decompress LZ4 file to address, get decompressed length in y
        LZ4_decompress text_lz4, HIRAM, y

        ;Overwrite decompressed data with #$ca, using previous length in y, hiram offset in x
        ;Decompressed length is #$6868 bytes, so using memset (blockmove) takes about 4 frames
        ldx     #$2000
        lda     #$7e
        memset ax, y, $ca

        ;memset using only values
        memset HIRAM+$80, $80, $fe

        ;Copy compressed file to WRAM using DMA
        lda     #$7f
        ldx     #$0000
        ldy     #(text_lz4_END - text_lz4)
        WRAM_memcpy ax, text_lz4, y

        ;Decompress LZ4 file in WRAM to WRAM, get decompressed length in x
        lda     #$7e
        ldy     #$4068
        LZ4_decompress $7f0000, ay, x

        ;Copy y bytes from "Tilemap" to a:x
        lda     #$7f
        ldx     #$2000
        ldy     #$100
        WRAM_memcpy ax, Tilemap, y

        ;Copy a bytes from $808000 to $7f:x
        lda     #$90
        ldx     #$5000
        WRAM_memcpy ex:x, $808000, a

;-------------------------------------------------------------------------------
@test_spc:

        ;Transfer and execute SPC dump
        SMP_playspc_lorom SPC_Image_Lo, SPC_Image_Hi, SPC_State

;-------------------------------------------------------------------------------
@test_setcolorvbl:

        ; Set color 0, turn on screen
        CGRAM_setColorRGB 0, 7,31,31
        lda     #$0f
        sta     SFX_inidisp
        VBL_on

:       wai
        bra :-

;-------------------------------------------------------------------------------
Not_NTSC:
        ;NTSC check failed, show red screen
        CGRAM_setColorRGB 0, 31,5,5
        lda     #$0f
        sta     SFX_inidisp
        VBL_on

:       wai
        bra :-

;-------------------------------------------------------------------------------

;Import lz4 textfile
.segment "RODATA"
text_lz4:               .incbin "Data/The Eyes Have It.txt.lz4"
text_lz4_END:
repetetive_lz4:         .incbin "Data/The Eyes Have It.txt.lz4"
repetetive_lz4_END:

;Import graphics
.segment "ROM1"
Tilemap:                .incbin "Data/Graphics.tilemap.lz4"
Tiles:                  .incbin "Data/Graphics.tiles.lz4"
Palette:                .incbin "Data/Graphics.palette"
Palette_END:

;Import music
.define spc_file "Data/Music.spc"
.segment "RODATA"
SPC_State:              SPC_incbin_state spc_file
.segment "ROM2"
SPC_Image_Lo:           SPC_incbin_lo spc_file
.segment "ROM3"
SPC_Image_Hi:           SPC_incbin_hi spc_file
