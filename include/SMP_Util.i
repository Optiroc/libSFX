; libSFX S-SMP Utility Macros
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_SMP_Util__
::__MBSFX_SMP_Util__ = 1

;-------------------------------------------------------------------------------
;DSP access

/**
  Macro: DSP_set
  Select DSP register

  Parameters:
  >:in:    reg     Register (uint8)        constant
  >:in:    val     Value (uint8)           constant
  >                                        direct page address
  >                                        a/x/y
*/
.macro DSP_set reg, val
.if (.blank({val}))
  SFX_error "DSP_set: Missing required parameter(s)"
.else
          mov   DSPADDR,#reg
  .if (.xmatch({val}, {a}) .or .xmatch({val}, {x}) .or .xmatch({val}, {y}))
    .if .xmatch({val}, {x})
          mov   DSPDATA,x
    .elseif .xmatch({val}, {y})
          mov   DSPDATA,y
    .else
          mov   DSPDATA,a
    .endif
  .else
        mov     DSPDATA,val
  .endif
.endif
.endmac


/*
;dir_set #sound, #offset, #loop_offset, #dir_offset
;Set DSP register with value
.MACRO  dir_set
        mov     a,#(\2 & $00ff)
        mov     !(\4 + \1*4),a
        mov     a,#((\2 >> 8) & $00ff)
        mov     !(\4 + \1*4)+1,a
        mov     a,#(\3 & $00ff)
        mov     !(\4 + \1*4)+2,a
        mov     a,#((\3 >> 8) & $00ff)
        mov     !(\4 + \1*4)+3,a
.ENDM
*/

;-------------------------------------------------------------------------------
;Misc

/**
  Macro: SMP_exit
  Return to IPL (clears timers, zeropage)

*/
.macro SMP_exit
        mov   CONTROL,#$80
        pcall <IPL_INIT
.endmac


.endif;__MBSFX_SMP_Util__
