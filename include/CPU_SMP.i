; libSFX S-CPU to S-SMP Communication
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_CPU_SMP__
::__MBSFX_CPU_SMP__ = 1

SFX_DSP_STATE = HIRAM   ;DSP state location
SFX_SPC_IMAGE = EXRAM   ;SPC image dump location for SFX_APU_execspc

.global SFX_SMP_ready, SFX_SMP_jmp, SFX_SMP_exec, SFX_SMP_execspc

;-------------------------------------------------------------------------------

/**
  SMP_ready
  Wait for SMP ready signal
*/
.macro  SMP_ready
        RW_push set:i16
        jsl     SFX_SMP_waitReady
        RW_pull
.endmac


/**
  SMP_exec
  Transfer & execute SPC700 binary via IPL transfer

  :in:    dest    Destination address (uint16)      constant
  :in:    source  Source address (uint24)           constant
  :in:    length  Length (uint16)                   constant
  :in:    exec    Jump address (uint16)             constant
*/
.macro  SMP_exec dest, source, length, exec
        RW_push set:a8i16
        ldx     #length
        stx     _ZPAD_+$03
        ldx     #exec
        stx     _ZPAD_+$05
        ldy     #dest
        ldx     #.loword(source)
        lda     #^source
        jsl     SFX_SMP_exec
        RW_pull
.endmac


/**
  SMP_memcpy
  Copy bytes from CPU to SMP memory and return to IPL

  :in:    dest    Destination address (uint16)      constant
  :in:    source  Source address (uint24)           constant
  :in:    length  Length (uint16)                   constant
*/
.macro  SMP_memcpy dest, source, length
        RW_push set:a8i16
        ldx     #length
        stx     _ZPAD_+$03
        ldx     #$ffc9
        stx     _ZPAD_+$05
        ldy     #dest
        ldx     #.loword(source)
        lda     #^source
        jsl     SFX_SMP_exec
        RW_pull
.endmac


/**
  SMP_jmp
  Transfer SPC700 control to address via IPL jump

  :in:    addr    Jump address (uint16)             constant
*/
.macro  SMP_jmp addr
        RW_push set:a8i16
        ldx     #addr
        jsl     SFX_SMP_jmp
        RW_pull
.endmac


/**
  SMP_playspc
  Transfer & start SPC music file

  If ROM_MAPMODE == 0 ("LoROM") both ram and ram_hi parameters are required.

  :in:    state   Address to DSP/CPU state (uint24)           constant
  :in:    ram     Address to full 64kB SPC RAM dump (uint24)  constant
                  Address to lower 32kB SPC RAM dump (uint24) constant
  :in?:   ram_hi  Address to upper 32kB SPC RAM dump (uint24) constant
*/
.macro  SMP_playspc state, ram, ram_hi
  .if ((ROM_MAPMODE = $0) && (.blank({ram_hi})))
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
  Helper macros for importing SPC dumps
*/
.macro SPC_incbin filename
        .incbin filename, $100, $10000  ;$0000-$ffff SMP RAM
.endmac

.macro SPC_incbin_lo filename
        .incbin filename, $100, $8000   ;$0000-$7fff SMP RAM
.endmac

.macro SPC_incbin_hi filename
        .incbin spc_file, $8100, $8000  ;$8000-$ffff SMP RAM
.endmac

.macro SPC_incbin_state filename
        .incbin filename, $10100, $80   ;DSP registers
        .incbin filename, $25, $7       ;CPU registers
.endmac


.endif;__MBSFX_CPU_SMP__
