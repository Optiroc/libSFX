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
left:   cpx     #JOY_LEFT
        bne     up
        SMP_Runtime_AsyncEvent $01
up:     cpx     #JOY_UP
        bne     right
        SMP_Runtime_AsyncEvent $02
right:  cpx     #JOY_RIGHT
        bne     down
        SMP_Runtime_AsyncEvent $03
down:   cpx     #JOY_DOWN
        bne     btn_y
        SMP_Runtime_AsyncEvent $04
btn_y:  cpx     #JOY_Y
        bne     btn_x
        SMP_Runtime_AsyncEvent $05
btn_x:  cpx     #JOY_X
        bne     btn_a
        SMP_Runtime_AsyncEvent $06
btn_a:  cpx     #JOY_A
        bne     btn_b
        SMP_Runtime_AsyncEvent $07
btn_b:  cpx     #JOY_B
        bne     end
        SMP_Runtime_AsyncEvent $08

end:    jmp     Loop

;-------------------------------------------------------------------------------
.segment "RODATA"
incbin  SMP,  "SMP.bin"
