.include "libSFX.i"

.export InitScreen

InitScreen:
        CGRAM_setcolor_rgb 0, 7,31,31   ;Set color 0

        lda     #$0f                    ;Turn on screen
        sta     SFX_inidisp

        rts
