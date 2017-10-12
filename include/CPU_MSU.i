; libSFX S-CPU to MSU-1 Communication
; Kyle Swanson <k@ylo.ph>

.ifndef ::__MBSFX_CPU_MSU__
::__MBSFX_CPU_MSU__ = 1

;-------------------------------------------------------------------------------
;MSU-1 MMIO Registers

MSU_STATUS  = $2000
MSU_READ    = $2001
MSU_ID      = $2002
MSU_SEEK    = $2000
MSU_TRACK   = $2004
MSU_VOLUME  = $2006
MSU_CONTROL = $2007

;-------------------------------------------------------------------------------
;MSU-1 Macros

.macro MSU_detect MSU_detected, MSU_not_detected
        RW_push set:i16
        ldx     MSU_ID
        cpx     #$2D53  ; 'S-'
        bne     :+
        ldx     MSU_ID+2
        cpx     #$534D  ; 'MS'
        bne     :+
        ldx     MSU_ID+4
        cpx     #$3155  ; 'U1'

:       RW_pull
        bne     :+
        jsr     MSU_detected
        bra     :++
:       jsr     MSU_not_detected
:
.endmac


.endif;__MBSFX_CPU_MSU__
