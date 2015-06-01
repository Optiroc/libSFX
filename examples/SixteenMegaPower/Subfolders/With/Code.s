.include "libSFX.i"

.export InitScreen

InitScreen:

        ;CGRAM_memcpy HIRAM, $20, $20

        ;Set color 0
        CGRAM_setColorRGB 0, 31,7,31

        ;Turn on screen
        lda     #$0f
        sta     INIDISP

        rts
