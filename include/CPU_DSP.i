; libSFX S-CPU to DSP (1a/b) Register Definitions
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_CPU_DSP__
::__MBSFX_CPU_DSP__ = 1

;-------------------------------------------------------------------------------
;DSP MMIO Registers

.if ROM_MAPMODE <> 1
;DSP with Mode 20 "LoROM" mapping
DSP_BANK       = $bf
DSP_STATUS     = $8000 ;Status register
DSP_DATA       = $c000 ;Data register

.else
;DSP with Mode 21 "HiROM) mapping
DSP_BANK       = $80
DSP_STATUS     = $6000 ;Status register
DSP_DATA       = $7000 ;Data register

.endif

;-------------------------------------------------------------------------------
;DSP Commands

;General calculation
DSP_CMD_multiply        = $00; Fixed point (Q0.15?) multiplication
DSP_CMD_inverse         = $10

;Trigonometric calculation
DSP_CMD_triangle        = $04

;Vector calculation
DSP_CMD_radius          = $08
DSP_CMD_range           = $18
DSP_CMD_distance        = $28

;Coordinate calculation
DSP_CMD_rotate          = $0c
DSP_CMD_polar           = $1c
DSP_CMD_rotate2d        = DSP_CMD_rotate
DSP_CMD_rotate3d        = DSP_CMD_polar

;Projection calculation
DSP_CMD_parameter       = $02
DSP_CMD_project         = $06

;Matrix
DSP_CMD_attitude_a      = $01
DSP_CMD_attitude_b      = $11
DSP_CMD_attitude_c      = $21
DSP_CMD_objective_a     = $0d
DSP_CMD_objective_b     = $1d
DSP_CMD_objective_c     = $2d
DSP_CMD_subjective_a    = $03
DSP_CMD_subjective_b    = $13
DSP_CMD_subjective_c    = $23
DSP_CMD_scalar_a        = $0b
DSP_CMD_scalar_b        = $1b
DSP_CMD_scalar_c        = $2b

DSP_CMD_gyrate          = $14

;Screen space calculation
DSP_CMD_raster          = $1a
DSP_CMD_target          = $0e

.endif;__MBSFX_CPU_DSP__
