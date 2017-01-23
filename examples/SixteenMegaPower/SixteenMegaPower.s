; SixteenMegaPower
; David Lindecrantz <optiroc@gmail.com>
;
; Example showing:
;   - Customized memory map (Map.cfg)
;   - Customized libSFX.cfg
;   - Customized Makefile
;   - Calling out to code in other source file
;   - Nothing on screen!

.include "libSFX.i"

Main:
        jsr     InitScreen              ;Jump to subroutine defined elsewhere
        VBL_on                          ;Turn on vblank interrupt

:       wai
        bra :-
