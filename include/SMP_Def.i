; libSFX S-SMP Register Definitions
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_SMP_Def__
::__MBSFX_SMP_Def__ = 1

SMP_RAM                 = $0200

;-------------------------------------------------------------------------------
/**
   Group: CPU Memory Map
*/

/**
   Registers: CPU Memory Map / MMIO

   >TEST                    = $f0     ;SPC700 testing functions
   >CONTROL                 = $f1     ;Timer, I/O and ROM Control
   >
   >DSPADDR                 = $f2     ;DSP register address
   >DSPDATA                 = $f3     ;DSP register data read/write
   >
   >CPUIO0                  = $f4     ;SNES CPU Communication Port 0
   >CPUIO1                  = $f5     ;SNES CPU Communication Port 1
   >CPUIO2                  = $f6     ;SNES CPU Communication Port 2
   >CPUIO3                  = $f7     ;SNES CPU Communication Port 3
   >
   >T0DIV                   = $fa     ;Timer 0 divider
   >T1DIV                   = $fb     ;Timer 1 divider
   >T2DIV                   = $fc     ;Timer 2 divider
   >T0OUT                   = $fd     ;Timer 0 output
   >T1OUT                   = $fe     ;Timer 1 output
   >T2OUT                   = $ff     ;Timer 2 output
   >
   >IPL entry points
   >IPL_INIT                = $ffc0   ;Clear zero page and wait
   >IPL_WAIT                = $ffc9   ;Wait for new transfer
*/

TEST                    = $f0 ;SPC700 testing functions

CONTROL                 = $f1 ;Timer, I/O and ROM Control
CONTROL_ST0_MASK        = $fe ;Timer 0 start
CONTROL_ST1_MASK        = $fd ;Timer 1 start
CONTROL_ST2_MASK        = $fb ;Timer 2 start
CONTROL_RIO01_MASK      = $ef ;Reset CPUIO0 & CPUIO1 ($f4/f5)
CONTROL_RIO23_MASK      = $df ;Reset CPUIO2 & CPUIO3 ($f6/f7)
CONTROL_ROMEN_MASK      = $7f ;Enable ROM at $ffc0-$ffff
CONTROL_ST0_START       = $01
CONTROL_ST1_START       = $02
CONTROL_ST2_START       = $04
CONTROL_RIO01_RESET     = $10
CONTROL_RIO23_RESET     = $20
CONTROL_ROMEN_ON        = $80
CONTROL_ROMEN_OFF       = $00

DSPADDR                 = $f2 ;DSP register address
DSPDATA                 = $f3 ;DSP register data read/write
CPUIO0                  = $f4 ;SNES CPU Communication Port 0
CPUIO1                  = $f5 ;SNES CPU Communication Port 1
CPUIO2                  = $f6 ;SNES CPU Communication Port 2
CPUIO3                  = $f7 ;SNES CPU Communication Port 3

AUXIO4                  = $f8 ;AUX I/O, not connected, works as RAM
AUXIO5                  = $f9

T0DIV                   = $fa ;Timer 0 divider
T1DIV                   = $fb ;Timer 1 divider
T2DIV                   = $fc ;Timer 2 divider
T0OUT                   = $fd ;Timer 0 output
T1OUT                   = $fe ;Timer 1 output
T2OUT                   = $ff ;Timer 2 output

;IPL entry points
IPL_INIT                = $ffc0 ;Clear zero page and wait
IPL_WAIT                = $ffc9 ;Wait for new transfer

;-------------------------------------------------------------------------------
/**
   Group: S-DSP
*/

/**
   Registers: S-DSP Registers

   >MVOLL                   = $0c     ;Left channel master volume
   >MVOLR                   = $1c     ;Right channel master volume
   >EVOLL                   = $2c     ;Left channel echo volume
   >EVOLR                   = $3c     ;Right channel echo volume
   >KON                     = $4c     ;Key On Flags for Voice 0..7
   >KOF                     = $5c     ;Key Off Flags for Voice 0..7
   >
   >FLG                     = $6c     ;Reset, Mute, Echo-Write Flags + Noise Clock
   >
   >ENDX                    = $7c     ;Voice End Flags for Voice 0..7
   >EFB                     = $0d     ;Echo feedback volume
   >PMON                    = $2d     ;Pitch Modulation Enable Flags for Voice 1..7
   >NON                     = $3d     ;Noise Enable Flags for Voice 0..7
   >EON                     = $4d     ;Echo Enable Flags for Voice 0..7
   >DIR                     = $5d     ;Sample directory offset address
   >ESA                     = $6d     ;Echo buffer offset address
   >EDL                     = $7d     ;Echo delay (ring buffer size)
   >FIR0                    = $0f     ;Echo FIR filter coefficient 0
   >FIR1                    = $1f     ;Echo FIR filter coefficient 1
   >FIR2                    = $2f     ;Echo FIR filter coefficient 2
   >FIR3                    = $3f     ;Echo FIR filter coefficient 3
   >FIR4                    = $4f     ;Echo FIR filter coefficient 4
   >FIR5                    = $5f     ;Echo FIR filter coefficient 5
   >FIR6                    = $6f     ;Echo FIR filter coefficient 6
   >FIR7                    = $7f     ;Echo FIR filter coefficient 7
   >
   >Voice Control (n = 0-7)
   >VnVOLL                  = $n0     ;Left volume
   >VnVOLR                  = $n1     ;Right volume
   >VnPITCHL                = $n2     ;Pitch (LSB)
   >VnPITCHH                = $n3     ;Pitch (MSB)
   >VnSRCN                  = $n4     ;Source number
   >VnADSR1                 = $n5     ;ADSR settings 1
   >VnADSR2                 = $n6     ;ADSR settings 2
   >VnGAIN                  = $n7     ;Gain settings
   >VnENVX                  = $n8     ;Current envelope value
   >VnOUTX                  = $n9     ;Current sample value
*/

;General
MVOLL                   = $0c ;Left channel master volume
MVOLR                   = $1c ;Right channel master volume
EVOLL                   = $2c ;Left channel echo volume
EVOLR                   = $3c ;Right channel echo volume
KON                     = $4c ;Key On Flags for Voice 0..7
KOF                     = $5c ;Key Off Flags for Voice 0..7

FLG                     = $6c ;Reset, Mute, Echo-Write Flags + Noise Clock
FLG_RESET_MASK          = $7f ;Soft reset all voices
FLG_MUTE_MASK           = $bf ;Mute all voices
FLG_ECEN_MASK           = $df ;Enable echo write
FLG_NCK_MASK            = $e0 ;Noise clock
FLG_RESET_ON            = $80
FLG_RESET_OFF           = $00
FLG_MUTE_ON             = $40
FLG_MUTE_OFF            = $00
FLG_ECEN_ON             = $20
FLG_ECEN_OFF            = $00

ENDX                    = $7c ;Voice End Flags for Voice 0..7
EFB                     = $0d ;Echo feedback volume
PMON                    = $2d ;Pitch Modulation Enable Flags for Voice 1..7
NON                     = $3d ;Noise Enable Flags for Voice 0..7
EON                     = $4d ;Echo Enable Flags for Voice 0..7
DIR                     = $5d ;Sample directory offset address
ESA                     = $6d ;Echo buffer offset address
EDL                     = $7d ;Echo delay (ring buffer size)
FIR0                    = $0f ;Echo FIR filter coefficient 0
FIR1                    = $1f ;Echo FIR filter coefficient 1
FIR2                    = $2f ;Echo FIR filter coefficient 2
FIR3                    = $3f ;Echo FIR filter coefficient 3
FIR4                    = $4f ;Echo FIR filter coefficient 4
FIR5                    = $5f ;Echo FIR filter coefficient 5
FIR6                    = $6f ;Echo FIR filter coefficient 6
FIR7                    = $7f ;Echo FIR filter coefficient 7


;Voice 0
V0VOLL                  = $00 ;Left volume
V0VOLR                  = $01 ;Right volume
V0PITCHL                = $02 ;Pitch (LSB)
V0PITCHH                = $03 ;Pitch (MSB)
V0SRCN                  = $04 ;Source number

V0ADSR1                 = $05 ;ADSR settings 1
V0ADSR2                 = $06 ;ADSR settings 2
ADSR1_MODE_MASK         = $7f ;ADSR/Gain Select
ADSR1_AR_MASK           = $f0 ;Attack rate
ADSR1_DR_MASK           = $8f ;Decay rate
ADSR2_SR_MASK           = $e0 ;Sustain rate
ADSR2_SL_MASK           = $1f ;Sustain level
ADSR1_MODE_ADSR         = $80
ADSR1_MODE_GAIN         = $00

V0GAIN                  = $07 ;Gain settings
V0ENVX                  = $08 ;Current envelope value
V0OUTX                  = $09 ;Current sample value
V0RAM0                  = $0a ;Scratch pad RAM
V0RAM1                  = $0b
V0RAM2                  = $0e


;Voice 1
V1VOLL                  = $10
V1VOLR                  = $11
V1PITCHL                = $12
V1PITCHH                = $13
V1SRCN                  = $14
V1ADSR1                 = $15
V1ADSR2                 = $16
V1GAIN                  = $17
V1ENVX                  = $18
V1OUTX                  = $19
V1RAM0                  = $1a
V1RAM1                  = $1b
V1RAM2                  = $1e

;Voice 2
V2VOLL                  = $20
V2VOLR                  = $21
V2PITCHL                = $22
V2PITCHH                = $23
V2SRCN                  = $24
V2ADSR1                 = $25
V2ADSR2                 = $26
V2GAIN                  = $27
V2ENVX                  = $28
V2OUTX                  = $29
V2RAM0                  = $2a
V2RAM1                  = $2b
V2RAM2                  = $2e

;Voice 3
V3VOLL                  = $30
V3VOLR                  = $31
V3PITCHL                = $32
V3PITCHH                = $33
V3SRCN                  = $34
V3ADSR1                 = $35
V3ADSR2                 = $36
V3GAIN                  = $37
V3ENVX                  = $38
V3OUTX                  = $39
V3RAM0                  = $3a
V3RAM1                  = $3b
V3RAM2                  = $3e

;Voice 4
V4VOLL                  = $40
V4VOLR                  = $41
V4PITCHL                = $42
V4PITCHH                = $43
V4SRCN                  = $44
V4ADSR1                 = $45
V4ADSR2                 = $46
V4GAIN                  = $47
V4ENVX                  = $48
V4OUTX                  = $49
V4RAM0                  = $4a
V4RAM1                  = $4b
V4RAM2                  = $4e

;Voice 5
V5VOLL                  = $50
V5VOLR                  = $51
V5PITCHL                = $52
V5PITCHH                = $53
V5SRCN                  = $54
V5ADSR1                 = $55
V5ADSR2                 = $56
V5GAIN                  = $57
V5ENVX                  = $58
V5OUTX                  = $59
V5RAM0                  = $5a
V5RAM1                  = $5b
V5RAM2                  = $5e

;Voice 6
V6VOLL                  = $60
V6VOLR                  = $61
V6PITCHL                = $62
V6PITCHH                = $63
V6SRCN                  = $64
V6ADSR1                 = $65
V6ADSR2                 = $66
V6GAIN                  = $67
V6ENVX                  = $68
V6OUTX                  = $69
V6RAM0                  = $6a
V6RAM1                  = $6b
V6RAM2                  = $6e

;Voice 7
V7VOLL                  = $70
V7VOLR                  = $71
V7PITCHL                = $72
V7PITCHH                = $73
V7SRCN                  = $74
V7ADSR1                 = $75
V7ADSR2                 = $76
V7GAIN                  = $77
V7ENVX                  = $78
V7OUTX                  = $79
V7RAM0                  = $7a
V7RAM1                  = $7b
V7RAM2                  = $7e


.endif;__MBSFX_SMP_Def__
