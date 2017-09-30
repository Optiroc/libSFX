; libSFX S-CPU to MSU-1 Communication
; Kyle Swanson <k@ylo.ph>

.ifndef ::__MBSFX_CPU_MSU__
::__MBSFX_CPU_MSU__ = 1

MSU_STATUS  = $2000
MSU_READ    = $2001
MSU_ID      = $2002
MSU_SEEK    = $2000
MSU_TRACK   = $2004
MSU_VOLUME  = $2006
MSU_CONTROL = $2007

.macro MSU_detect MSU_detected, MSU_not_detected
        lda     MSU_ID
        cmp     #$53  ; 'S'
        bne     :+
        lda     MSU_ID+1
        cmp     #$2D  ; '-'
        bne     :+
        lda     MSU_ID+2
        cmp     #$4D  ; 'M'
        bne     :+
        lda     MSU_ID+3
        cmp     #$53  ; 'S'
        bne     :+
        lda     MSU_ID+4
        cmp     #$55  ; 'U'
        bne     :+
        lda     MSU_ID+5
        cmp     #$31  ; '1'
        bne     :+

        jsr     MSU_detected
        bra     :++
:       jsr     MSU_not_detected
:
.endmac

.endif;__MBSFX_CPU_SMP__
