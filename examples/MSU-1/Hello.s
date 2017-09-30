; MSU-1
; Kyle Swanson <k@ylo.ph>
;
; MSU-1 example

.include "libSFX.i"

init_with_MSU:
        break
        ldx     #$0001  ; Writing a 16-bit value will automatically
        stx     MSU_TRACK

        break
        lda     #$01    ; Set audio state to play, no repeat.
        sta     MSU_CONTROL

        break
        lda     #$FF
        sta     MSU_VOLUME

        break
        CGRAM_setcolor_rgb 0, 0,255,0
        rts

init_without_MSU:
        CGRAM_setcolor_rgb 0, 255,0,0
        rts

Main:
        ;Transfer and execute SMP code
        SMP_exec SMP_RAM, SMP, sizeof_SMP, SMP_RAM

        ;Detect MSU-1, fire a callback
        MSU_detect init_with_MSU, init_without_MSU

        ;Turn on screen
        lda     #inidisp(ON, DISP_BRIGHTNESS_MAX)
        sta     SFX_inidisp
        VBL_on

:       wai
        bra     :-

.segment "RODATA"
incbin  SMP,  "SMP.bin"
