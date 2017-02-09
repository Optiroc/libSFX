; Hello-SMP
; Kyle Swanson <k@ylo.ph>

.include "libSFX.i"

Main:
        ;Transfer and execute SMP code
        SMP_exec $400, smp_code_start, smp_code_end - smp_code_start, $400

        ldx   #$0000
        stx   SMPIO0

        VBL_on

:       wai
        RW_push set:a16
        lda     z:SFX_joy1trig
        cmp     #$00
        beq     :-

        RW_push set:a8
        lda     #$FF

        sta     SMPIO0
:       cmp     SMPIO0
        bne     :-
        lda     #$00
        sta     SMPIO0
        bra     :--
;-------------------------------------------------------------------------------

;Import smp.bin
.segment "RODATA"
smp_code_start:
.incbin "SMP/smp.bin"
smp_code_end:
