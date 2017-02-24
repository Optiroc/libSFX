; libSFX S-SMP ADSR Macros
; Kyle Swanson <k@ylo.ph>

.ifndef ::__MBSFX_SMP_ADSR__
::__MBSFX_SMP_ADSR__ = 1

;-------------------------------------------------------------------------------

.macro ADSR_get_attack time_ms
  .if (time_ms = 0)
  .define ADSR_attack $0F
  .elseif(time_ms = 6)
  .define ADSR_attack $0E
  .elseif(time_ms = 10)
  .define ADSR_attack $0D
  .elseif(time_ms = 16)
  .define ADSR_attack $0C
  .elseif(time_ms = 24)
  .define ADSR_attack $0B
  .elseif(time_ms = 40)
  .define ADSR_attack $0A
  .elseif(time_ms = 64)
  .define ADSR_attack $09
  .elseif(time_ms = 96)
  .define ADSR_attack $08
  .elseif(time_ms = 160)
  .define ADSR_attack $07
  .elseif(time_ms = 260)
  .define ADSR_attack $06
  .elseif(time_ms = 380)
  .define ADSR_attack $05
  .elseif(time_ms = 640)
  .define ADSR_attack $04
  .elseif(time_ms = 1000)
  .define ADSR_attack $03
  .elseif(time_ms = 1500)
  .define ADSR_attack $02
  .elseif(time_ms = 2600)
  .define ADSR_attack $01
  .elseif(time_ms = 4100)
  .define ADSR_attack $00
  .else
  .error .sprintf("SMP_ADSR: Invalid attack_ms: `%d'.", time_ms)
  .endif
.endmacro


/**
  Macro: ADSR_set_attack_ms
  Set ADSR attack value in milliseconds.

  Parameters:
  >:in:    voice_no   Value (uint8)       constant
  >:in:    time_ms    Value (uint16)      constant
*/
.macro ADSR_set_attack_ms voice_no, time_ms
  .if((voice_no < 0) || (voice_no > 7))
  .error .sprintf("ADSR_set_attack_ms: Invalid voice_no: `%d'.", voice_no)
  .endif

  ADSR_get_attack time_ms
  DSP_get (V0ADSR1 + (voice_no * $10)), a
  and  a,#ADSR1_AR_MASK
  or   a,#ADSR_attack
  DSP_set (V0ADSR1 + (voice_no * $10)), a
  .undef ADSR_attack
.endmacro


.macro ADSR_get_decay time_ms
  .if(time_ms = 37)
  .define ADSR_decay $7
  .elseif(time_ms = 74)
  .define ADSR_decay $6
  .elseif(time_ms = 110)
  .define ADSR_decay $5
  .elseif(time_ms = 180)
  .define ADSR_decay $4
  .elseif(time_ms = 290)
  .define ADSR_decay $3
  .elseif(time_ms = 440)
  .define ADSR_decay $2
  .elseif(time_ms = 740)
  .define ADSR_decay $1
  .elseif(time_ms = 1200)
  .define ADSR_decay $0
  .else
  .error .sprintf("SMP_ADSR: Invalid decay_ms: `%d'.", time_ms)
  .endif
.endmacro


/**
  Macro: ADSR_set_decay_ms
  Set ADSR decay value in milliseconds.

  Parameters:
  >:in:    voice_no   Value (uint8)       constant
  >:in:    time_ms    Value (uint16)      constant
*/
.macro ADSR_set_decay_ms voice_no, time_ms
  .if(voice_no < 0 || voice_no > 7)
  .error .sprintf("ADSR_set_decay_ms: Invalid voice_no: `%d'.", voice_no)
  .endif

  ADSR_get_decay time_ms
  DSP_get (V0ADSR1 + (voice_no * $10)), a
  and  a,#ADSR1_DR_MASK
  or   a,#ADSR_decay << 4
  DSP_set (V0ADSR1 + (voice_no * $10)), a
  .undef ADSR_decay
.endmacro


.macro ADSR_get_sustain ratio
  .if(.xmatch({ratio}, {"1:8"}))
  .define ADSR_sustain $0
  .elseif(.xmatch({ratio}, {"2:8"}))
  .define ADSR_sustain $1
  .elseif(.xmatch({ratio}, {"3:8"}))
  .define ADSR_sustain $2
  .elseif(.xmatch({ratio}, {"4:8"}))
  .define ADSR_sustain $3
  .elseif(.xmatch({ratio}, {"5:8"}))
  .define ADSR_sustain $4
  .elseif(.xmatch({ratio}, {"6:8"}))
  .define ADSR_sustain $5
  .elseif(.xmatch({ratio}, {"7:8"}))
  .define ADSR_sustain $6
  .elseif(.xmatch({ratio}, {"8:8"}))
  .define ADSR_sustain $7
  .else
  .error .sprintf("SMP_ADSR: Invalid sustain_ratio: `%s'.", ratio)
  .endif
.endmacro


/**
  Macro: ADSR_set_sustain_ratio
  Set ADSR sustain ratio.

  Parameters:
  >:in:    voice_no   Value (uint8)       constant
  >:in:    eighths    Value (uint8)       constant
*/
.macro ADSR_set_sustain_ratio voice_no, ratio
  .if(voice_no < 0 || voice_no > 7)
  .error .sprintf("ADSR_set_sustain_ratio: Invalid voice_no: `%d'.", voice_no)
  .endif

  ADSR_get_sustain ratio
  DSP_get (V0ADSR2 + (voice_no * $10)), a
  and a,#ADSR2_SL_MASK
  or  a,#ADSR_sustain << 5
  DSP_set (V0ADSR2 + (voice_no * $10)), a
  .undef ADSR_sustain
.endmacro


.macro ADSR_get_release time_ms
  .if(time_ms = 18)
  .define ADSR_release $1F
  .elseif(time_ms = 37)
  .define ADSR_release $1E
  .elseif(time_ms = 55)
  .define ADSR_release $1D
  .elseif(time_ms = 74)
  .define ADSR_release $1C
  .elseif(time_ms = 92)
  .define ADSR_release $1B
  .elseif(time_ms = 110)
  .define ADSR_release $1A
  .elseif(time_ms = 150)
  .define ADSR_release $19
  .elseif(time_ms = 180)
  .define ADSR_release $18
  .elseif(time_ms = 220)
  .define ADSR_release $17
  .elseif(time_ms = 290)
  .define ADSR_release $16
  .elseif(time_ms = 370)
  .define ADSR_release $15
  .elseif(time_ms = 440)
  .define ADSR_release $14
  .elseif(time_ms = 590)
  .define ADSR_release $13
  .elseif(time_ms = 740)
  .define ADSR_release $12
  .elseif(time_ms = 880)
  .define ADSR_release $11
  .elseif(time_ms = 1200)
  .define ADSR_release $10
  .elseif(time_ms = 1500)
  .define ADSR_release $0F
  .elseif(time_ms = 1800)
  .define ADSR_release $0E
  .elseif(time_ms = 2400)
  .define ADSR_release $0D
  .elseif(time_ms = 2900)
  .define ADSR_release $0C
  .elseif(time_ms = 3500)
  .define ADSR_release $0B
  .elseif(time_ms = 4700)
  .define ADSR_release $0A
  .elseif(time_ms = 5900)
  .define ADSR_release $09
  .elseif(time_ms = 7100)
  .define ADSR_release $08
  .elseif(time_ms = 9400)
  .define ADSR_release $07
  .elseif(time_ms = 12000)
  .define ADSR_release $06
  .elseif(time_ms = 14000)
  .define ADSR_release $05
  .elseif(time_ms = 19000)
  .define ADSR_release $04
  .elseif(time_ms = 24000)
  .define ADSR_release $03
  .elseif(time_ms = 28000)
  .define ADSR_release $02
  .elseif(time_ms = 38000)
  .define ADSR_release $01
  .elseif(time_ms = -1) /* infinite */
  .define ADSR_release $00
  .else
  .error .sprintf("SMP_ADSR: Invalid release_ms: `%d'.", time_ms)
  .endif
.endmacro


/**
  Macro: ADSR_set_release_ms
  Set ADSR release value in milliseconds.

  Parameters:
  >:in:    voice_no   Value (uint8)       constant
  >:in:    time_ms    Value (uint16)      constant
*/
.macro ADSR_set_release_ms voice_no, time_ms
  .if(voice_no < 0 || voice_no > 7)
    .error .sprintf("ADSR_set_release_ms: Invalid voice_no: `%d'.", voice_no)
  .endif

  ADSR_get_release time_ms
  DSP_get (V0ADSR2 + (voice_no * $10)), a
  and a,#ADSR2_SR_MASK
  or  a,#ADSR_release
  DSP_set (V0ADSR2 + (voice_no * $10)), a
  .undef ADSR_release
.endmacro


/**
  Macro: ADSR_set
  Set ADSR.

  Parameters:
  >:in:    voice_no       Value (uint8)       constant
  >:in:    attack_ms      Value (uint16)      constant
  >:in:    decay_ms       Value (uint16)      constant
  >:in:    sustain_ratio  Value (uint8)       constant
  >:in:    attack_ms      Value (uint16)      constant
*/
.macro ADSR_set voice_no, attack_ms, decay_ms, sustain_ratio, release_ms
  .if(voice_no < 0 || voice_no > 7)
  .error .sprintf("ADSR_set: Invalid voice_no: `%d'.", voice_no)
  .endif

  ADSR_get_attack  attack_ms
  ADSR_get_decay   decay_ms
  ADSR_get_sustain sustain_ratio
  ADSR_get_release release_ms

  DSP_set (V0ADSR1 + (voice_no * $10)), #($80 | ADSR_attack | (ADSR_decay << 4))
  DSP_set (V0ADSR2 + (voice_no * $10)), #((ADSR_sustain << 5) | ADSR_release)

  .undef ADSR_attack
  .undef ADSR_decay
  .undef ADSR_sustain
  .undef ADSR_release
.endmacro


/**
  Macro: ADSR_on
  Turn on ADSR mode.

  Parameters:
  >:in:    voice_no       Value (uint8)       constant
*/
.macro ADSR_on voice_no
  .if(voice_no < 0 || voice_no > 7)
  .error .sprintf("ADSR_on: Invalid voice_no: `%d'.", voice_no)
  .endif

  DSP_get (V0ADSR1 + (voice_no * $10)), a
  or  a,#$80
  DSP_set (V0ADSR1 + (voice_no * $10)), a
.endmacro

.endif;__MBSFX_SMP_ADSR__
