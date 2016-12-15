; SixteenMegaPower
; David Lindecrantz <optiroc@gmail.com>
;
; Example showing:
;   - Customized memory map (Map.cfg)
;   - Customized libSFX.cfg
;   - Customized Makefile

.include "libSFX.i"

Main:
        jsr     InitScreen              ;Jump to subroutine defined elsewhere
        VBL_on                          ;Turn on vblank interrupt

:       wai
        bra :-
