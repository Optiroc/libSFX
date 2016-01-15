.include "libSFX.i"

Main:
        break
        FIFO_alloc TestFIFO, 8

        jsr     InitScreen              ;Jump to subroutine defined elsewhere

        FIFO_enq TestFIFO, $f

        VBL_on                          ;Turn on vblank interrupt

:       wai
        bra :-
