; libSFX ROM Header
; David Lindecrantz <optiroc@gmail.com>

.include "../libSFX.i"

;-------------------------------------------------------------------------------
;Set defaults for any missing symbols

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

;-------------------------------------------------------------------------------
.segment "HEADER"
ROM_HEADER:
        .byte ROM_MAKERCODE             ;$ffb0-$ffb1  Maker code
        .byte ROM_GAMECODE              ;$ffb2-$ffb5  Game code
        .byte 0,0,0,0,0,0               ;$ffb6-$ffbb  Reserved
        .byte $00                       ;$ffbc        Expansion flash size
        .byte $00                       ;$ffbd        Expansion RAM size
        .byte $00                       ;$ffbe        Special version
        .byte >ROM_CHIPSET              ;$ffbf        Chipset sub-type
        .byte ROM_TITLE                 ;$ffc0-$ffd4  ROM title
        .byte ROM_MAPMODESPEED          ;$ffd5        Map mode / ROM speed
        .byte <ROM_CHIPSET              ;$ffd6        Chipset
        .byte ROM_ROMSIZE               ;$ffd7        ROM size
        .byte ROM_RAMSIZE               ;$ffd8        RAM size
        .byte ROM_COUNTRY               ;$ffd9        Country
        .byte $33                       ;$ffda        $33 = Extended header
        .byte ROM_VERSION               ;$ffdb        Version
        .word $ffff                     ;$ffdc-$ffdd  Checksum complement
        .word $0000                     ;$ffde-$ffdf  Checksum

.segment "VECTORS"
ROM_VECTORS:
        .word 0, 0                      ;Native mode vectors
        .word .loword(EmptyVector)      ;COP
        .word .loword(EmptyVector)      ;BRK
        .word .loword(EmptyVector)      ;ABORT
        .word .loword(VBlankVector)     ;NMI
        .word .loword(EmptyVector)      ;RST
        .word .loword(IRQVector)        ;IRQ

        .word 0, 0                      ;Emulation mode vectors
        .word .loword(EmptyVector)      ;COP
        .word 0
        .word .loword(EmptyVector)      ;ABORT
        .word .loword(EmptyVector)      ;NMI
        .word .loword(BootVector)       ;RESET
        .word .loword(EmptyVector)      ;IRQBRK
