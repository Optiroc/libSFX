.include "libSFX.i"

Main:
        break
        FIFO_alloc FIFO, $6
        jsr     InitScreen

        ;Set color 0
        CGRAM_setColorRGB 0, 7,31,31

        ;Turn on screen
        lda     #$0f
        sta     SFX_inidisp

        ;Turn on vblank interrupt
        VBL_on

:       wai
        bra :-
