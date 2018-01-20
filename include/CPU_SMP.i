; libSFX S-CPU to S-SMP Communication
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_CPU_SMP__
::__MBSFX_CPU_SMP__ = 1

SMP_RAM                 = $0200

;Locations and sizes for relocatable SMP routines
.import SMP_Burst, SMP_Burst_END, SMP_SetDSP, SMP_SetDSP_END
SMP_Burst_LOC = __LIBSFX_SMP_LOAD__ - $02 + SMP_Burst
SMP_Burst_SIZ = SMP_Burst_END - SMP_Burst
SMP_SetDSP_LOC = __LIBSFX_SMP_LOAD__ - $02 + SMP_SetDSP
SMP_SetDSP_SIZ = SMP_SetDSP_END - SMP_SetDSP

;RAM locations for SPC burst transfer
SFX_DSP_STATE = HIRAM
SFX_SPC_IMAGE = EXRAM

;-------------------------------------------------------------------------------
.global SFX_SMP_ready, SFX_SMP_jmp, SFX_SMP_exec, SFX_SMP_execspc

/**
  Group: SMP macros
*/

/**
  Macro: SMP_ready
  Wait for SMP ready signal
*/
.macro  SMP_ready
        RW_push set:i16
        jsl     SFX_SMP_ready
        RW_pull
.endmac


/**
  Macro: SMP_exec
  Transfer & execute SPC700 binary via IPL transfer

  Parameters:
  >:in:    dest      Destination address (uint16)    constant
  >:in:    source    Source address (uint24)         constant
  >:in:    length    Length (uint16)                 constant
  >:in:    exec      Jump address (uint16)           constant

  Example:
  (start code)
  ;Transfer and execute SMP code
  ;The __SMPCODE_***__ symbols are exported from Map.cfg
  SMP_ready
  SMP_exec          __SMPCODE_RUN__, __SMPCODE_LOAD__, __SMPCODE_SIZE__, __SMPCODE_RUN__
  (end)
*/
.macro  SMP_exec dest, source, length, exec
        RW_push set:a8i16
        ldx     #length
        stx     ZPAD+$03
        ldx     #exec
        stx     ZPAD+$05
        ldy     #dest
        ldx     #.loword(source)
        lda     #^source
        jsl     SFX_SMP_exec
        RW_pull
.endmac


/**
  Macro: SMP_memcpy
  Copy bytes from CPU to SMP memory and return to IPL

  Parameters:
  >:in:    dest      Destination address (uint16)    constant
  >:in:    source    Source address (uint24)         constant
  >:in:    length    Length (uint16)                 constant

  Example:
  (start code)
  ;Transfer data to SMP
  SMP_ready
  SMP_memcpy        $2000, Sample1, sizeof_Sample1
  (end)
*/
.macro  SMP_memcpy dest, source, length
        RW_push set:a8i16
        ldx     #length
        stx     ZPAD+$03
        ldx     #$ffc9
        stx     ZPAD+$05
        ldy     #dest
        ldx     #.loword(source)
        lda     #^source
        jsl     SFX_SMP_exec
        RW_pull
.endmac


/**
  Macro: SMP_jmp
  Transfer SPC700 control to address via IPL jump

  Parameters:
  >:in:    addr      Jump address (uint16)           constant
*/
.macro  SMP_jmp addr
        RW_push set:a8i16
        ldx     #addr
        jsl     SFX_SMP_jmp
        RW_pull
.endmac


/**
  Macro: SMP_playspc
  Transfer & start SPC music file using custom (fast!) transfer

  If ROM_MAPMODE == 0 ("LoROM") both ram and ram_hi parameters are required.

  Parameters:
  >:in:    state     Address to DSP/CPU state (uint24)            constant
  >:in:    ram       Address to full 64kB SPC RAM dump (uint24)   constant
  >                  Address to lower 32kB SPC RAM dump (uint24)  constant
  >:in?:   ram_hi    Address to upper 32kB SPC RAM dump (uint24)  constant

  Example:
  (start code)
  ;Transfer and execute SPC file
  SMP_playspc       SPC_State, SPC_Image_Lo, SPC_Image_Hi

  ;Import music
  .define spc_file  "Data/Music.spc"
  .segment "RODATA"
  SPC_State:        SPC_incbin_state spc_file
  .segment "ROM2"
  SPC_Image_Lo:     SPC_incbin_lo spc_file
  .segment "ROM3"
  SPC_Image_Hi:     SPC_incbin_hi spc_file
  (end)
*/
.macro  SMP_playspc state, ram, ram_hi
  .if ((::ROM_MAPMODE = $0) && (.blank({ram_hi})))
        SFX_error "SMP_playspc: If ROM_MAPMODE == 0 (`LoROM`) both ram and ram_hi parameters are required."
  .endif
  .if .blank({ram_hi})
        WRAM_memcpy SFX_SPC_IMAGE, ram, $0000
        WRAM_memcpy SFX_DSP_STATE, state, $100
  .else
        WRAM_memcpy SFX_SPC_IMAGE, ram, $8000
        WRAM_memcpy SFX_SPC_IMAGE + $8000, ram_hi, $8000
        WRAM_memcpy SFX_DSP_STATE, state, $100
  .endif
        RW_push set:a8i16
        jsl     SFX_SMP_execspc
        RW_pull
.endmac


/**
  Group: Helper macros
  Helper macros for importing SPC dumps
*/

/**
  Macro: SPC_incbin
  Import 64KB SPC RAM image

  Parameters:
  >:in:    filename  SPC File                path
*/
.macro SPC_incbin filename
        .incbin filename, $100, $10000  ;$0000-$ffff SMP RAM
.endmac

/**
  Macro: SPC_incbin_lo
  Import lower 32KB of SPC RAM image

  Parameters:
  >:in:    filename  SPC File                path
*/
.macro SPC_incbin_lo filename
        .incbin filename, $100, $8000   ;$0000-$7fff SMP RAM
.endmac

/**
  Macro: SPC_incbin_hi
  Import upper 32KB of SPC RAM image

  Parameters:
  >:in:    filename  SPC File                path
*/
.macro SPC_incbin_hi filename
        .incbin filename, $8100, $8000  ;$8000-$ffff SMP RAM
.endmac

/**
  Macro: SPC_incbin_state
  Import SPC DSP/CPU state (#$87 bytes)

  Parameters:
  >:in:    filename  SPC File                path
*/
.macro SPC_incbin_state filename
        .incbin filename, $10100, $80   ;DSP registers
        .incbin filename, $25, $7       ;CPU registers
.endmac


.endif;__MBSFX_CPU_SMP__
