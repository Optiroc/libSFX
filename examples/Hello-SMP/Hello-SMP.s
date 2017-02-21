; Hello-SMP
; Kyle Swanson <k@ylo.ph>

.include "libSFX.i"

Main:
        ;Transfer and execute SMP code
        SMP_exec SMP_RAM, SMP, sizeof_SMP, SMP_RAM

        ;Clear SMPIO0 to avoid an unintended SMP_Runtime_AsyncEvent.
        ldx   #$0000
        stx   SMPIO0

        VBL_on

Loop:   wai
        RW      a16
        lda     z:SFX_joy1trig
        cmp     #$00
        beq     Loop

        ;Trigger SMP_Runtime_AsyncEvent based on JOY1 button presses.
@left:  cmp     #JOY_LEFT
        bne     @up
        SMP_Runtime_AsyncEvent $01
@up:    cmp     #JOY_UP
        bne     @right
        SMP_Runtime_AsyncEvent $02
@right: cmp     #JOY_RIGHT
        bne     @down
        SMP_Runtime_AsyncEvent $03
@down:  cmp     #JOY_DOWN
        bne     @y
        SMP_Runtime_AsyncEvent $04
@y:     cmp     #JOY_Y
        bne     @x
        SMP_Runtime_AsyncEvent $05
@x:     cmp     #JOY_X
        bne     @a
        SMP_Runtime_AsyncEvent $06
@a:     cmp     #JOY_A
        bne     @b
        SMP_Runtime_AsyncEvent $07
@b:     cmp     #JOY_B
        bne     @end
        SMP_Runtime_AsyncEvent $08

@end:   jmp     Loop

;-------------------------------------------------------------------------------
.segment "RODATA"
incbin  SMP,  "SMP.bin"
