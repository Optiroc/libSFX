; libSFX Configuration Defaults
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_DEFAULTS__
::__MBSFX_DEFAULTS__ = 1

;-------------------------------------------------------------------------------
;Set defaults for any missing configuration symbols

.if isnotdefined "ROM_TITLE"
define "ROM_TITLE", "TO THE 65816 ON FIRE!"
.endif
.if .strlen(ROM_TITLE) <> 21
  SFX_warning "ROM_TITLE must be 21 characters"
  define "ROM_TITLE", "MEGABOYS STILL ALIVE!"
.endif

.ifndef ROM_MAPMODE
ROM_MAPMODE = $0
.endif

.ifndef ROM_SPEED
ROM_SPEED = $1
.endif

ROM_MAPMODESPEED = (ROM_MAPMODE & $0f) + ((ROM_SPEED & $01) << 4) + $20

.ifndef ROM_CHIPSET
ROM_CHIPSET = $00
.endif

.ifndef ROM_ROMSIZE
ROM_ROMSIZE = $07
.endif

.ifndef ROM_RAMSIZE
ROM_RAMSIZE = $00
.endif

.ifndef ROM_EXPRAMSIZE
ROM_EXPRAMSIZE = $00
.endif

.if isnotdefined "ROM_GAMECODE"
define "ROM_GAMECODE", "SFXJ"
.endif
.if .strlen(ROM_GAMECODE) <> 4
  SFX_warning "ROM_GAMECODE must be 4 characters"
  define "ROM_GAMECODE", "SFXJ"
.endif

.if isnotdefined "ROM_MAKERCODE"
define "ROM_MAKERCODE", "MB"
.endif
.if .strlen(ROM_MAKERCODE) <> 2
  SFX_warning "ROM_MAKERCODE must be 2 characters"
  define "ROM_MAKERCODE", "MB"
.endif

.ifndef ROM_VERSION
ROM_VERSION = $00
.endif

.ifndef ROM_COUNTRY
ROM_COUNTRY = $00
.endif

.ifndef SFX_JOY
  SFX_JOY = JOY1 | JOY2
.endif

.if (SFX_JOY < 0) || (SFX_JOY > (JOY1 | JOY2 | JOY3 | JOY4))
  SFX_error "SFX_JOY: Bad configuration"
.endif

.ifndef SFX_AUTO_READOUT
  SFX_AUTO_READOUT = ENABLE
.endif

.ifndef SFX_AUTO_READOUT_FIRST
  SFX_AUTO_READOUT_FIRST = NO
.endif

.endif;__MBSFX_DEFAULTS__
