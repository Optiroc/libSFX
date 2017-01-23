; libSFX ROM Header
; David Lindecrantz <optiroc@gmail.com>

.include "../libSFX.i"

;-------------------------------------------------------------------------------
.segment "HEADER"
ROM_HEADER:
        .byte ROM_MAKERCODE             ;$ffb0-$ffb1  Maker code
        .byte ROM_GAMECODE              ;$ffb2-$ffb5  Game code
        .byte 0,0,0,0,0,0               ;$ffb6-$ffbb  Reserved
        .byte $00                       ;$ffbc        Expansion flash size
        .byte ROM_EXPRAMSIZE            ;$ffbd        Expansion RAM size
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
