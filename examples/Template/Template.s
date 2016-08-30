.include "libSFX.i"

Main:
        ;libSFX calls Main after CPU/PPU registers, memory and interrupt handlers are initialized.

        ;Set color 0
        CGRAM_setcolor_rgb 0, 7,31,31

        ;Turn on screen
        ;The vblank interrupt handler will copy the value in SFX_inidisp to INIDISP ($2100)
        lda     #inidisp(ON, DISP_BRIGHTNESS_MAX)
        sta     SFX_inidisp

        ;Turn on vblank interrupt
        VBL_on

:       wai
        bra :-
