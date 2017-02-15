; libSFX S-SMP ADSR Macros
; Kyle Swanson <k@ylo.ph>


.macro ADSR_attack_ms time_ms
  .if (   time_ms = 0)
    #$0F
  .elseif(time_ms = 6)
    #$0E
  .elseif(time_ms = 10)
    #$0D
  .elseif(time_ms = 16)
    #$0C
  .elseif(time_ms = 24)
    #$0B
  .elseif(time_ms = 40)
    #$0A
  .elseif(time_ms = 64)
    #$09
  .elseif(time_ms = 96)
    #$08
  .elseif(time_ms = 160)
    #$07
  .elseif(time_ms = 260)
    #$06
  .elseif(time_ms = 380)
    #$05
  .elseif(time_ms = 640)
    #$04
  .elseif(time_ms = 1000)
    #$03
  .elseif(time_ms = 1500)
    #$02
  .elseif(time_ms = 2600)
    #$01
  .elseif(time_ms = 4100)
    #$00
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
  .if(voice_no < 0 || voice_no > 7)
    .error .sprintf("ADSR_set_attack_ms: Invalid voice_no: `%dr'.", voice_no)
  .endif
  DSP_get (V0ADSR1 + (voice_no * $10)),a
  and a,ADSR1_AR_MASK
  or  a,ADSR_attack_ms time_ms
  DSP_set (V0ADSR1 + (voice_no * $10)),a
.endmacro


.macro ADSR_decay_ms time_ms
  .if(    time_ms = 37)
    #$70
  .elseif(time_ms = 74)
    #$60
  .elseif(time_ms = 110)
    #$50
  .elseif(time_ms = 180)
    #$40
  .elseif(time_ms = 290)
    #$30
  .elseif(time_ms = 440)
    #$20
  .elseif(time_ms = 740)
    #$20
  .elseif(time_ms = 1200)
    #$00
  .else
    .error .sprintf("SMP_ADSR: Invalid decay_ms: `%d'.", time_ms)
  .endif
.endmacro


/**
  Macro: ADSR_set_decay_ms
  Set ADSR decay value in milliseconds.

  Parameters:
  >:in:    voice_no   Value (uint8)       constant
  >:in:    time_ms    Value (uint8)       constant
*/
.macro ADSR_set_decay_ms voice_no, time_ms
  .if(voice_no < 0 || voice_no > 7)
    .error .sprintf("ADSR_set_decay_ms: Invalid voice_no: `%d'.", voice_no)
  .endif
  DSP_get (V0ADSR1 + (voice_no * $10)),a
  and a,ADSR1_DR_MASK
  or  a,ADSR_decay_ms time_ms
  DSP_set (V0ADSR1 + (voice_no * $10)),a
.endmacro


.macro ADSR_sustain_ratio eighths
  .if(    eighths = 1)
    #$00
  .elseif(eighths = 2)
    #$10
  .elseif(eighths = 3)
    #$20
  .elseif(eighths = 4)
    #$30
  .elseif(eighths = 5)
    #$40
  .elseif(eighths = 6)
    #$50
  .elseif(eighths = 7)
    #$60
  .elseif(eighths = 8)
    #$70
  .else
    .error .sprintf("SMP_ADSR: Invalid sustain_ratio: `%d:8'.", ratio)
  .endif
.endmacro


/**
  Macro: ADSR_set_sustain_ratio
  Set ADSR sustain ratio.

  Parameters:
  >:in:    voice_no   Value (uint8)       constant
  >:in:    eighths    Value (uint8)       constant
*/
.macro ADSR_set_sustain_ratio voice_no, eighths
  .if(voice_no < 0 || voice_no > 7)
    .error .sprintf("ADSR_set_sustain_ratio: Invalid voice_no: `%d'.", voice_no)
    DSP_set (V0ADSR2 + (voice_no * $10)), ADSR_sustain_ratio eighths
  .endif
  DSP_get (V0ADSR2 + (voice_no * $10)),a
  and a,ADSR2_SL_MASK
  or  a,ADSR_sustain_ratio eighths
  DSP_set (V0ADSR2 + (voice_no * $10)),a
.endmacro


.macro ADSR_release_ms time_ms
  .if(    time_ms = 18)
    #$1F
  .elseif(time_ms = 37)
    #$1E
  .elseif(time_ms = 55)
    #$1D
  .elseif(time_ms = 74)
    #$1C
  .elseif(time_ms = 92)
    #$1B
  .elseif(time_ms = 110)
    #$1A
  .elseif(time_ms = 150)
    #$19
  .elseif(time_ms = 180)
    #$18
  .elseif(time_ms = 220)
    #$17
  .elseif(time_ms = 290)
    #$16
  .elseif(time_ms = 370)
    #$15
  .elseif(time_ms = 440)
    #$14
  .elseif(time_ms = 590)
    #$13
  .elseif(time_ms = 740)
    #$12
  .elseif(time_ms = 880)
    #$11
  .elseif(time_ms = 1200)
    #$10
  .elseif(time_ms = 1500)
    #$0F
  .elseif(time_ms = 1800)
    #$0E
  .elseif(time_ms = 2400)
    #$0D
  .elseif(time_ms = 2900)
    #$0C
  .elseif(time_ms = 3500)
    #$0B
  .elseif(time_ms = 4700)
    #$0A
  .elseif(time_ms = 5900)
    #$09
  .elseif(time_ms = 7100)
    #$08
  .elseif(time_ms = 9400)
    #$07
  .elseif(time_ms = 12000)
    #$06
  .elseif(time_ms = 14000)
    #$05
  .elseif(time_ms = 19000)
    #$04
  .elseif(time_ms = 24000)
    #$03
  .elseif(time_ms = 28000)
    #$02
  .elseif(time_ms = 38000)
    #$01
  .elseif(time_ms = -1) /* infinite */
    #$00
  .else
    .error .sprintf("SMP_ADSR: Invalid release_ms: `%d`.", time_ms)
  .endif
.endmacro


/**
  Macro: ADSR_set_release_ms
  Set ADSR release value in milliseconds.

  Parameters:
  >:in:    voice_no   Value (uint8)       constant
  >:in:    time_ms    Value (uint8)       constant
*/
.macro ADSR_set_release_ms voice_no, time_ms
  .if(voice_no < 0 || voice_no > 7)
    .error .sprintf("ADSR_set_release_ms: Invalid voice_no: `%d`.", voice_no)
  .endif
  DSP_get (V0ADSR2 + (voice_no * $10)),a
  and a,ADSR2_SR_MASK
  or  a,ADSR_release_ms time_ms
  DSP_set (V0ADSR2 + (voice_no * $10)),a
.endmacro


/**
  Macro: ADSR_set
  Set ADSR.

  Parameters:
  >:in:    voice_no               Value (uint8)       constant
  >:in:    attack_ms              Value (uint16)      constant
  >:in:    decay_ms               Value (uint16)      constant
  >:in:    sustain_ratio_eighths  Value (uint8)       constant
  >:in:    attack_ms              Value (uint16)      constant
*/
.macro ADSR_set voice_no, attack_ms, decay_ms, sustain_ratio_eighths, release_ms
  .if(voice_no < 0 || voice_no > 7)
    .error .sprintf("ADSR_set: Invalid voice_no: `%d`.", voice_no)
  .endif
  DSP_get (V0ADSR1 + (voice_no * $10)),a
  and a,~ADSR1_MODE_MASK
  or  a,((ADSR_attack_ms attack_ms) | (ADSR_decay_ms decay_ms))
  DSP_set (V0ADSR1 + (voice_no * $10)),a
  DSP_set (V0ADSR2 + (voice_no * $10)),((ADSR_sustain_ratio sustain_ratio_eighths) & (ADSR_release_ms release_ms)
.endmacro


.delmacro ADSR_attack_ms
.delmacro ADSR_decay_ms
.delmacro ADSR_sustain_ratio
.delmacro ADSR_release_ms
