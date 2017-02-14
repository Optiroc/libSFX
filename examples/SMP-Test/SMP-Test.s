; SMP-Test
; David Lindecrantz <optiroc@gmail.com>
;
; Test for the smp_overlays build feature

.include "libSFX.i"

Main:
        ;Execute SMP payloads in sequence
        SMP_exec SMP_RAM, SMP_nop, sizeof_SMP_nop, SMP_RAM
        SMP_exec SMP_RAM, SMP_play, sizeof_SMP_play, SMP_RAM
        SMP_exec SMP_RAM, SMP_nop, sizeof_SMP_nop, SMP_RAM
        SMP_exec SMP_RAM, SMP_play, sizeof_SMP_play, SMP_RAM

        ;Turn on screen
        CGRAM_setcolor_rgb 0, 31,7,31

        lda     #inidisp(ON, DISP_BRIGHTNESS_MAX)
        sta     SFX_inidisp
        VBL_on

:       ;Execute SMP payloads in sequence, forever
        SMP_exec SMP_RAM, SMP_play, sizeof_SMP_play, SMP_RAM
        SMP_exec SMP_RAM, SMP_nop, sizeof_SMP_nop, SMP_RAM
        bra :-

.segment "RODATA"
incbin  SMP_play,  "SMP-Play.bin"
incbin  SMP_nop,   "SMP-Nop.bin"
