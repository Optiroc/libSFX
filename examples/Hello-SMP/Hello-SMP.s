; Hello-SMP
; Kyle Swanson <k@ylo.ph>

.include "libSFX.i"

Main:
        ;Transfer and execute SMP code
        SMP_exec SMP_RAM, SMP, sizeof_SMP, SMP_RAM

        ;Clear SMPIO0 to avoid an unintended SMP_Runtime_AsyncEvent.
        stz   SMPIO0

        VBL_on

Loop:   wai
        ldx     z:SFX_joy1trig
        cpx     #$00
        beq     Loop

        ;Trigger SMP_Runtime_AsyncEvent based on JOY1 button presses.
@left:  cpx     #JOY_LEFT
        bne     @up
        lda     #$01
        jsr     PerformEvent
@up:    cpx     #JOY_UP
        bne     @right
        lda     #$02
        jsr     PerformEvent
@right: cpx     #JOY_RIGHT
        bne     @down
        lda     #$03
        jsr     PerformEvent
@down:  cpx     #JOY_DOWN
        bne     @y
        lda     #$04
        jsr     PerformEvent
@y:     cpx     #JOY_Y
        bne     @x
        lda     #$05
        jsr     PerformEvent
@x:     cpx     #JOY_X
        bne     @a
        lda     #$06
        jsr     PerformEvent
@a:     cpx     #JOY_A
        bne     @b
        lda     #$07
        jsr     PerformEvent
@b:     cpx     #JOY_B
        bne     @l
        lda     #$08
        jsr     PerformEvent
@l:     cpx     #JOY_L
        bne     @r
        lda     #$09
        jsr     PerformEvent
@r:     cpx     #JOY_R
        bne     @end
        lda     #$0A
        jsr     PerformEvent

@end:   bra     Loop

PerformEvent:
        SMP_Runtime_AsyncEvent a
        rts


;-------------------------------------------------------------------------------
.segment "RODATA"
incbin  SMP,  "SMP.bin"
