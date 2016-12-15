; SuperFX
; David Lindecrantz <optiroc@gmail.com>
;
; For now this merely gets code running on the GSU

.include "libSFX.i"

Main:
        ;Copy GSU code
        memcpy GSU_SRAM, __GSUCODE_LOAD__, __GSUCODE_SIZE__

        ;Configure GSU
        lda     #$70
        sta     GSU_PBR
        lda     #$10
        sta     GSU_SCBR
        lda     #%00001000
        sta     GSU_SCMR
        lda     #%10000000
        sta     GSU_CFGR
        lda     #$00
        sta     GSU_CLSR

        ;Start GSU
        break
        ldx     __GSUCODE_RUN__
        stx     GSU_R15

        ;Turn on screen
        CGRAM_setcolor_rgb 0, 31,7,31

        lda     #inidisp(ON, DISP_BRIGHTNESS_MAX)
        sta     SFX_inidisp
        VBL_on

:       wai
        bra :-
