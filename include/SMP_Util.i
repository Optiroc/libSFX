; libSFX S-SMP Utility Macros
; David Lindecrantz <optiroc@gmail.com>
; Kyle Swanson <k@ylo.ph>

.ifndef ::__MBSFX_SMP_Util__
::__MBSFX_SMP_Util__ = 1

;-------------------------------------------------------------------------------
;DSP access

/**
  Macro: DSP_get
  Get DSP register

  Parameters:
  >:in:    dsp_reg    Register (uint8)     constant
  >:in:    spc_reg    Register (uint8)     a/x/y
*/
.macro DSP_get dsp_reg, spc_reg
.if (.blank({dsp_reg}) .or .blank({spc_reg}))
  SFX_error "DSP_get: Missing required parameter(s)"
.elseif .not (.xmatch({spc_reg}, {a}) .or .xmatch({spc_reg}, {x}) .or .xmatch({spc_reg}, {y}))
  SFX_error "DSP_get: Invalid SPC-700 register (a/x/y)"
.elseif ((dsp_reg < $00) .or (dsp_reg > $7F))
  SFX_error "DSP_get: Invalid DSP register"
.else
          mov   DSPADDR,#dsp_reg
  .if .xmatch({spc_reg}, {x})
          mov   x,DSPDATA
  .elseif .xmatch({spc_reg}, {y})
          mov   y,DSPDATA
  .elseif .xmatch({spc_reg}, {a})
          mov   a,DSPDATA
  .else
  .endif
.endif
.endmac

/**
  Macro: DSP_set
  Set DSP register

  Parameters:
  >:in:    reg     Register (uint8)        constant
  >:in:    val     Value (uint8)           constant
  >                                        direct page address
  >                                        a/x/y
*/
.macro DSP_set reg, val
.if (.blank({val}) .or .blank({reg}))
  SFX_error "DSP_set: Missing required parameter(s)"
.elseif ((reg < $00) .or (reg > $7F))
  SFX_error "DSP_set: Invalid DSP register"
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
