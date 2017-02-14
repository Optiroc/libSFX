; Hello-SMP
; Kyle Swanson <k@ylo.ph>

.include "libSFX.i"

Main:
        ;Transfer and execute SMP code
        SMP_exec SMP_RAM, SMP, sizeof_SMP, SMP_RAM

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
.segment "RODATA"
incbin  SMP,  "SMP.bin"
