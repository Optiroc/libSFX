.include "libSFX.i"

.struct Vec3
        vx      .word
        vy      .word
        vz      .word
.endstruct

;-------------------------------------------------------------------------------
.segment "CODE"
Main:
/*
;       jsr     test_mulu
        jsr     test_setcolorvbl
:       wai
        bra :-
*/
        jsr     test_is_ntsc
        jsr     test_blockmove
        jsr     test_dbank
        jsr     test_dpage
        jsr     test_mulu
        jsr     test_divu
        jsr     test_muls
        jsr     test_wram
        jsr     test_vram
        jsr     test_fifo
        jsr     test_filo
        jsr     test_lz4
        jsr     test_meta
        jsr     test_mixed
        jsr     test_spc
        jsr     test_setcolorvbl

:       wai
        bra :-

;-------------------------------------------------------------------------------
test_blockmove:
        RW a8i16

        memset EXRAM+$6000, $5, $66             ;Set $7f6000-$7f6004 to #$66
        break

        memcpy EXRAM+$6774, SPC_State, $18c     ;Copy bytes from SPC_State to $7f6774-$7f68ff
        break

        memcpy EXRAM+$6820, HIRAM, $30          ;Copy bytes from $7e0000 (zeroes at this point) to $7f6820-$7f684f
        break

        rts

;-------------------------------------------------------------------------------
test_dbank:
        RW a8i16

        lda     #$6                     ;Set dbank using value in register a
        dbank   a
        break                           ;expected: db == $06

        dbank   $44                     ;Set dbank using constant value
        break                           ;expected: db == $06

        dbank   Main                    ;Set dbank using address
        break                           ;expected: db == $80

        rts

;-------------------------------------------------------------------------------
test_dpage:
        RW a16i16

        lda     #$6044                  ;Set dpage using value in register a
        dpage   a
        break

        dpage   repetetive_lz4          ;Set dpage using address
        break

        dpage   $0000                   ;Set dpage using constant value
        break

        rts

;-------------------------------------------------------------------------------
test_mulu:
        RW a8i16                        ;mulu register * value -> register
        lda     #$22
        mulu    a,$4, x
        break                           ;expected: x == #$0088

        RW i8                           ;mulu value * register -> register
        mulu    $7f,x, y
        break                           ;expected: y = #$4378

        RW i8                           ;mulu register * register -> register
        ldy     #$42
        mulu    y,x, y
        break                           ;expected: y = #$2310

        RW i16                          ;mulu value * value -> RDMPYL/H
        mulu    .sizeof(Vec3),$66
        bit     $ff
        nop
        ldx     RDMPYL
        break                           ;expected: x = #$0264

        rts

;-------------------------------------------------------------------------------
test_divu:
        RW a8i16

        ldx     #$9c00                  ;divu register / value -> register
        divu    x,$4, x
        break                           ;expected: x = #$2700

        divu    x,$7, x,y               ;divu register / value -> register.register
        break                           ;expected: x = #$0592
                                        ;          y = #$0002

        divu    .sizeof(Vec3)*100,$05   ;divu value / value -> RDDIVL/H.RDMPYL/H
        break

        rts

;-------------------------------------------------------------------------------
test_muls:
        RW a8i16
        ;Note: Using forced range for negative values, or ca65 gives range error

        ldx     #.loword(-822)          ;muls register * value -> register
        muls    x,.lobyte(-44), ax
        break                           ;expected: a:x = #$008d48 (+36168)

        lda     #.lobyte(-21)           ;muls register * register -> register
        ldx     #.loword(1001)
        muls    x,a, ay
        break                           ;expected: a:y = #$ffade3 (-21021)

        rts

;-------------------------------------------------------------------------------
test_wram:
        RW a8i16

        lda     #$7f                    ;Copy y bytes from "Tilemap" to a:x
        ldx     #$2000
        ldy     #$100
        WRAM_memcpy ax, Tilemap, y
        break

        lda     #$90                    ;Copy a bytes from $808000 to $7f:x
        ldx     #$5000
        WRAM_memcpy ex:x, $808000, a
        break

        rts

;-------------------------------------------------------------------------------
test_vram:
        RW a8i16

        ldx     #$4000                  ;Copy a<<8 bytes from $7e:x to VRAM word address $1600
        lda     #$02
        VRAM_memcpy $1600, hi:x, a
        break

        ldy     #$2000                  ;Copy $100 bytes from $7f:x to VRAM word address in y
        ldx     #$4000
        VRAM_memcpy y, ex:x, $100
        break

        ldx     #$1220                  ;Set $100 bytes from word address in x to value in a
        lda     #$cc
        VRAM_memset x, $50, a
        break

        rts

;-------------------------------------------------------------------------------
test_fifo:
        RW a8i16

        FIFO_alloc TestFIFO, 8

        FIFO_enq TestFIFO, $f
        FIFO_enq TestFIFO, $a
        lda     #$5
        FIFO_enq TestFIFO, a
        lda     #$d
        FIFO_enq TestFIFO, a

        FIFO_deq TestFIFO
        break                           ;z = 0, y = $0f, head = 4, tail = 2
        FIFO_deq TestFIFO, a
        break                           ;z = 0, a = $0a, head = 4, tail = 2

        FIFO_enq TestFIFO, $f0
        FIFO_enq TestFIFO, $0d
        FIFO_deq TestFIFO
        FIFO_deq TestFIFO
        FIFO_deq TestFIFO
        FIFO_deq TestFIFO, x
        break                           ;z = 0, x = $0d, head = 6, tail = 6

        FIFO_deq TestFIFO
        break                           ;z = 1 (queue empty), head = 6, tail = 6

        FIFO_enq TestFIFO, $10
        FIFO_enq TestFIFO, $ff
        break                           ;last byte in buffer = $ff, head = 0, tail = 6

        FIFO_enq TestFIFO, $aa
        break                           ;first byte in buffer = $aa, head = 1, tail = 6

        FIFO_deq TestFIFO
        FIFO_deq TestFIFO
        break                           ;z = 0, y = $ff, head = 1, tail = 0

        FIFO_deq TestFIFO
        break                           ;z = 0, y = $aa, head = 1, tail = 1

        FIFO_deq TestFIFO
        break                           ;z = 1 (queue empty), head = 6, tail = 6

        rts

;-------------------------------------------------------------------------------
test_filo:
        RW a8i16

        FILO_alloc TestFILO, 8

        FILO_push TestFILO, $f
        FILO_push TestFILO, $8
        lda     #$a
        FILO_push TestFILO, a
        lda     #$d
        FILO_push TestFILO, a
        break                           ;stack = 0f 08 0a 0d, top = 4

        FILO_pop TestFILO
        break                           ;z = 0, y = $0d, top = 3
        FILO_pop TestFILO, a
        break                           ;z = 0, a = $0a, top = 2
        FILO_pop TestFILO, x
        break                           ;z = 0, x = $08, top = 1
        FILO_pop TestFILO
        break                           ;z = 0, y = $0f, top = 0

        FILO_pop TestFILO
        break                           ;z = 1 (stack empty), top = 0

        rts

;-------------------------------------------------------------------------------
test_lz4:
        RW a8i16

        ;Decompress LZ4 frame at "repetetive_lz4" to "EXRAM", get decompressed length in x
        LZ4_decompress repetetive_lz4, EXRAM, x
        break

        ;Decompress LZ4 frame at "repetetive_lz4" to a:y, get decompressed length in y
        lda     #$7e
        ldy     #$4000
        LZ4_decompress repetetive_lz4, ay, y
        break

        ;Decompress LZ4 frame at "repetetive_lz4" to $7f:y
        ldy     #$4000
        LZ4_decompress repetetive_lz4, ex:y
        break

        rts

;-------------------------------------------------------------------------------
test_meta:
        RW a8i16

        lda     #%01101101              ;Arithmetic shift right (8-bit)
        asr
        break                           ;expected: a = #%00110110 ($36)
        asr
        break                           ;expected: a = #%00011011 ($1b)

        lda     #%10110001
        asr
        break                           ;expected: a = #%11011000 ($d8)
        asr
        break                           ;expected: a = #%11101100 ($ec)

        RW a16
        lda     #%0110001110010001      ;Arithmetic shift right (16-bit)
        asr
        break                           ;expected: a = #%0011000111001000 ($31c8)
        asr
        break                           ;expected: a = #%0001100011100100 ($18e4)

        lda     #%1010001110010001
        asr
        break                           ;expected: a = #%1101000111001000 ($d1c8)
        asr
        break                           ;expected: a = #%1110100011100100 ($e8e4)

        RW a8

        lda     #101                    ;Negate (8-bit)
        neg                             ;Note: Using forced range for negative values, or ca65 gives range error
        break                           ;expected: a = #$9b
        lda     #.lobyte(-127)
        neg
        break                           ;expected: a = #$7f

        RW a16

        lda     #28123                  ;Negate (16-bit)
        neg
        break                           ;expected: a = #$9225
        lda     #.loword(-32767)
        neg
        break                           ;expected: a = #$7fff

        rts

;-------------------------------------------------------------------------------
test_mixed:
        RW a8i16

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
        ldy     #sizeof_text_lz4
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

        rts

;-------------------------------------------------------------------------------
test_spc:
        RW a8i16

        ;Transfer and execute SPC dump
        SMP_playspc SPC_State, SPC_Image_Lo, SPC_Image_Hi

        rts

;-------------------------------------------------------------------------------
test_setcolorvbl:
        RW a8i16

        ;Set some colors
        break
        ldx     #rgb(7,31,31)
        CGRAM_setcolor_rgb 0, 7,31,31

        lda     #1
        CGRAM_setcolor_rgb a, 31,0,7

        CGRAM_setcolor 2, rgb(9,31,3)

        ldx     #rgb(3,7,25)
        CGRAM_setcolor 3, x

        lda     #4
        ldy     #rgb(8,29,4)
        CGRAM_setcolor a, y

        ;Turn on screen
        lda     #inidisp(ON, DISP_BRIGHTNESS_MAX)
        sta     SFX_inidisp
        VBL_on
        rts

;-------------------------------------------------------------------------------
test_is_ntsc:
        RW a8i16

        ;Test NTSC-check, display red screen if not NTSC or emulator with good timing
        PPU_is_ntsc
        break
        beq     :+
        jmp     @not_ntsc
:       rts

@not_ntsc:
        ;NTSC check failed, show red screen
        CGRAM_setcolor_rgb 0, 31,5,5
        lda     #inidisp(ON, DISP_BRIGHTNESS_MAX)
        sta     SFX_inidisp
        VBL_on
:       wai
        bra :-

;-------------------------------------------------------------------------------

;Import lz4 textfile
.segment "RODATA"
incbin  text_lz4,       "Data/The Eyes Have It.txt.lz4"
incbin  repetetive_lz4, "Data/The Eyes Have It.txt.lz4"

;Import graphics
.segment "ROM1"
incbin  Tilemap,        "Data/Graphics.tilemap.lz4"
incbin  Tiles,          "Data/Graphics.tiles.lz4"
incbin  Palette,        "Data/Graphics.palette"

;Import music
.define spc_file "Data/Music.spc"
.segment "RODATA"
SPC_State:              SPC_incbin_state spc_file
.segment "ROM2"
SPC_Image_Lo:           SPC_incbin_lo spc_file
.segment "ROM3"
SPC_Image_Hi:           SPC_incbin_hi spc_file
