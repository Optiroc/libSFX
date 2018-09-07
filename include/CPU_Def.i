; libSFX S-CPU & S-PPU Register Definitions
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_CPU_Def__
::__MBSFX_CPU_Def__ = 1

;-------------------------------------------------------------------------------
/**
   Group: General
*/
/**
   Memory locations: RAM

   >HIRAM - 56KB of RAM at 7e:2000
   >EXRAM - 64KB of RAM at 7f:0000
*/

HIRAM                   = $7e2000
EXRAM                   = $7f0000

;-------------------------------------------------------------------------------
/**
   Group: PPU Display Control
*/

/**
   Registers: PPU Display Control Registers

   >INIDISP                 = $2100   ;Display Control 1
   >SETINI                  = $2133   ;Display Control 2
*/

INIDISP                 = $2100 ;Display Control 1
DISP_BLANKING_MASK      = $7f
DISP_BRIGHTNESS_MASK    = $f0
DISP_BLANKING_SHIFT     = 7
DISP_BLANKING_ON        = $80
DISP_BLANKING_OFF       = $00
DISP_BRIGHTNESS_MIN     = $00
DISP_BRIGHTNESS_MAX     = $0f

SETINI                  = $2133 ;Display Control 2
SET_INTERLACE_MASK      = $fe
SET_OBJ_V_MASK          = $fd
SET_BG_V_MASK           = $fb
SET_H_PSEUDO512_MASK    = $f7
SET_EXT_BG_MASK         = $bf
SET_EXT_SYNC_MASK       = $7f
SET_INTERLACE_SHIFT     = 0
SET_OBJ_V_SHIFT         = 1
SET_BG_V_SHIFT          = 2
SET_H_PSEUDO_SHIFT      = 3
SET_EXT_BG_SHIFT        = 6
SET_EXT_SYNC_SHIFT      = 7
SET_INTERLACE_ON        = $01
SET_INTERLACE_OFF       = $00
SET_OBJ_V_ON            = $02
SET_OBJ_V_OFF           = $00
SET_BG_V_ON             = $04
SET_BG_V_OFF            = $00
SET_H_PSEUDO512_ON      = $08
SET_H_PSEUDO512_OFF     = $00
SET_EXT_BG_ON           = $40
SET_EXT_BG_OFF          = $00
SET_EXT_SYNC_ON         = $80
SET_EXT_SYNC_OFF        = $00

/**
  Macro: inidisp()
  Encode value for INIDISP

  Parameters:
  >:in:    blanking    Screen blanking       bool (1 = screen blanking, 0 = screen on)
  >:in:    brightness  Screen brightness     0-15
*/
.define inidisp(blanking, brightness) (.lobyte(((~blanking & 1) << DISP_BLANKING_SHIFT) | (brightness & ~DISP_BRIGHTNESS_MASK)))


;-------------------------------------------------------------------------------
/**
   Group: PPU Data Ports
*/

/**
   Registers: PPU Data Port Registers

   >VMAINC                  = $2115   ;VRAM Address Increment Mode
   >VMADDL                  = $2116   ;VRAM Address (LSB)
   >VMADDH                  = $2117   ;VRAM Address (MSB)
   >VMDATAL                 = $2118   ;VRAM Data Write (LSB)
   >VMDATAH                 = $2119   ;VRAM Data Write (MSB)
   >VMDATALREAD             = $2139   ;PPU1 VRAM Data Read (LSB)
   >VMDATAHREAD             = $213a   ;PPU1 VRAM Data Read (MSB)
   >
   >OAMADDL                 = $2102   ;OAM Address (LSB)
   >OAMADDH                 = $2103   ;OAM Address (MSB) + Priority Rotation
   >OAMDATA                 = $2104   ;OAM Data Write (WRx2)
   >OAMDATAREAD             = $2138   ;PPU1 OAM Data Read
   >
   >CGADD                   = $2121   ;CGRAM Address
   >CGDATA                  = $2122   ;CGRAM Data Write (WRx2)
   >CGDATAREAD              = $213b   ;PPU2 CGRAM Data Read (WRx2)
*/

VMAINC                  = $2115 ;VRAM Address Increment Mode
VMADDL                  = $2116 ;VRAM Address (LSB)
VMADDH                  = $2117 ;VRAM Address (MSB)
VMDATAL                 = $2118 ;VRAM Data Write (LSB)
VMDATAH                 = $2119 ;VRAM Data Write (MSB)
VMDATALREAD             = $2139 ;PPU1 VRAM Data Read (LSB)
VMDATAHREAD             = $213a ;PPU1 VRAM Data Read (MSB)
VMA_TIMING_MASK         = $7f
VMA_MODE_MASK           = $f0
VMA_TIMING_SHIFT        = 7
VMA_MODE_SHIFT          = 0
VMA_TIMING_0            = $00
VMA_TIMING_1            = $80
VMA_MODE_1x1            = $00
VMA_MODE_32x32          = $01
VMA_MODE_64x64          = $02
VMA_MODE_128x128        = $03
VMA_MODE_8x32           = $04
VMA_MODE_8x64           = $05
VMA_MODE_8x128          = $06

OAMADDL                 = $2102 ;OAM Address (LSB)
OAMADDH                 = $2103 ;OAM Address (MSB) + Priority Rotation
OAMDATA                 = $2104 ;OAM Data Write (WRx2)
OAMDATAREAD             = $2138 ;PPU1 OAM Data Read

CGADD                   = $2121 ;CGRAM Address
CGDATA                  = $2122 ;CGRAM Data Write (WRx2)
CGDATAREAD              = $213b ;PPU2 CGRAM Data Read (WRx2)

/**
  Macro: rgb()
  Encode RGB values to SNES color word

  Parameters:
  >:in:    r           Red                   0-15
  >:in:    g           Green                 0-15
  >:in:    b           Blue                  0-15
*/
.define rgb(r, g, b) (.loword(((b & $1f) << 10) | ((g & $1f) << 5) | (r & $1f)))


;-------------------------------------------------------------------------------
/**
   Group: BG & OBJ Control
*/

/**
   Registers: BG & OBJ Control Registers

   >OBJSEL                  = $2101   ;Object Size + Object Base
   >BGMODE                  = $2105   ;BG Mode + BG Character Size
   >
   >BG1SC                   = $2107   ;BG1 Screen Base + Screen Size
   >BG2SC                   = $2108   ;BG2 Screen Base + Screen Size
   >BG3SC                   = $2109   ;BG3 Screen Base + Screen Size
   >BG4SC                   = $210a   ;BG4 Screen Base + Screen Size
   >
   >BG12NBA                 = $210b   ;BG1/2 Character Data Area Designation
   >BG34NBA                 = $210c   ;BG3/4 Character Data Area Designation
   >
   >BG1HOFS                 = $210d   ;BG1 Horizontal Scroll (WRx2)
   >BG1VOFS                 = $210e   ;BG1 Vertical Scroll (WRx2)
   >BG2HOFS                 = $210f   ;BG2 Horizontal Scroll (WRx2)
   >BG2VOFS                 = $2110   ;BG2 Vertical Scroll (WRx2)
   >BG3HOFS                 = $2111   ;BG3 Horizontal Scroll (WRx2)
   >BG3VOFS                 = $2112   ;BG3 Vertical Scroll (WRx2)
   >BG4HOFS                 = $2113   ;BG4 Horizontal Scroll (WRx2)
   >BG4VOFS                 = $2114   ;BG4 Vertical Scroll (WRx2)
   >
   >MOSAIC                  = $2106   ;Mosaic Size + Mosaic Enable
   >M7SEL                   = $211a   ;Rotation/Scaling Mode Settings
   >M7HOFS                  = BG1HOFS ;Horizontal Scroll (WRx2)
   >M7VOFS                  = BG1VOFS ;Vertical Scroll (WRx2)
   >M7A                     = $211b   ;Rotation/Scaling Parameter A (WRx2)
   >M7B                     = $211c   ;Rotation/Scaling Parameter B (WRx2)
   >M7C                     = $211d   ;Rotation/Scaling Parameter C (WRx2)
   >M7D                     = $211e   ;Rotation/Scaling Parameter D (WRx2)
   >M7X                     = $211f   ;Rotation/Scaling Center Coordinate X (WRx2)
   >M7Y                     = $2120   ;Rotation/Scaling Center Coordinate Y (WRx2)
*/

OBJSEL                  = $2101 ;Object Size + Object Base
OBJ_NAME_MASK           = $e0
OBJ_SIZE_MASK           = $1f
OBJ_NAME_SHIFT          = 0
OBJ_SIZE_SHIFT          = 5
OBJ_8x8_16x16           = $00
OBJ_8x8_32x32           = $20
OBJ_8x8_64x64           = $40
OBJ_16x16_32x32         = $60
OBJ_16x16_64x64         = $80
OBJ_32x32_64x64         = $a0

BGMODE                  = $2105 ;BG Mode + BG Character Size
BG_MODE_MASK            = $f8
BG_BG3_MAX_PRIO_MASK    = $f7
BG_SIZE_MASK            = $0f
BG_MODE_SHIFT           = 0
BG_BG3_MAX_PRIO_SHIFT   = 3
BG_SIZE_SHIFT           = 4
BG_MODE_0               = $00
BG_MODE_1               = $01
BG_MODE_2               = $02
BG_MODE_3               = $03
BG_MODE_4               = $04
BG_MODE_5               = $05
BG_MODE_6               = $06
BG_MODE_7               = $07
BG_BG3_MAX_PRIO         = $08
BG_SIZE_8X8             = $0
BG_SIZE_16X16           = $1
BG3_PRIO_NORMAL         = $0
BG3_PRIO_HIGH           = $1

BG1SC                   = $2107 ;BG1 Screen Base + Screen Size
BG2SC                   = $2108 ;BG2 Screen Base + Screen Size
BG3SC                   = $2109 ;BG3 Screen Base + Screen Size
BG4SC                   = $210a ;BG4 Screen Base + Screen Size
SC_SIZE_MASK            = $fc
SC_BASE_MASK            = $03
SC_SIZE_SHIFT           = 0
SC_BASE_SHIFT           = 2
SC_SIZE_0               = $00
SC_SIZE_32X32           = $00
SC_SIZE_1               = $01
SC_SIZE_64X32           = $01
SC_SIZE_2               = $02
SC_SIZE_32X64           = $02
SC_SIZE_3               = $03
SC_SIZE_64X64           = $03

BG12NBA                 = $210b ;BG1/2 Character Data Area Designation
BG34NBA                 = $210c ;BG3/4 Character Data Area Designation
BG_NBA1_MASK            = $f0
BG_BNA2_MASK            = $0f
BG_NBA1_SHIFT           = 0
BG_NBA2_SHIFT           = 4

BG1HOFS                 = $210d ;BG1 Horizontal Scroll (WRx2)
BG1VOFS                 = $210e ;BG1 Vertical Scroll (WRx2)
BG2HOFS                 = $210f ;BG2 Horizontal Scroll (WRx2)
BG2VOFS                 = $2110 ;BG2 Vertical Scroll (WRx2)
BG3HOFS                 = $2111 ;BG3 Horizontal Scroll (WRx2)
BG3VOFS                 = $2112 ;BG3 Vertical Scroll (WRx2)
BG4HOFS                 = $2113 ;BG4 Horizontal Scroll (WRx2)
BG4VOFS                 = $2114 ;BG4 Vertical Scroll (WRx2)

MOSAIC                  = $2106 ;Mosaic Size + Mosaic Enable
MOS_ENBL_MASK           = $f0
MOS_SIZE_MASK           = $0f
MOS_BG1_ON_MASK         = $fe
MOS_BG2_ON_MASK         = $fd
MOS_BG3_ON_MASK         = $fb
MOS_BG4_ON_MASK         = $f7
MOS_SIZE_SHIFT          = 4
MOS_BG1_ON_SHIFT        = 0
MOS_BG2_ON_SHIFT        = 1
MOS_BG3_ON_SHIFT        = 2
MOS_BG4_ON_SHIFT        = 3
BG1_MOS_ON              = $01
BG2_MOS_ON              = $02
BG3_MOS_ON              = $04
BG4_MOS_ON              = $08

M7SEL                   = $211a ;Rotation/Scaling Mode Settings
M7_FLIP_MASK            = $fc
M7_OVER_MASK            = $3f
M7_FLIP_SHIFT           = 0
M7_OVER_SHIFT           = 6
M7_FLIP_NONE            = $00
M7_FLIP_H               = $01
M7_FLIP_V               = $02
M7_FLIP_HV              = $03
M7_OVER_SC_REP          = $00
M7_OVER_CHR_REP         = $80
M7_OVER_COL             = $c0

M7HOFS                  = BG1HOFS ;Horizontal Scroll (WRx2)
M7VOFS                  = BG1VOFS ;Vertical Scroll (WRx2)
M7A                     = $211b   ;Rotation/Scaling Parameter A (WRx2)
M7B                     = $211c   ;Rotation/Scaling Parameter B (WRx2)
M7C                     = $211d   ;Rotation/Scaling Parameter C (WRx2)
M7D                     = $211e   ;Rotation/Scaling Parameter D (WRx2)
M7X                     = $211f   ;Rotation/Scaling Center Coordinate X (WRx2)
M7Y                     = $2120   ;Rotation/Scaling Center Coordinate Y (WRx2)


/**
  Macro: objsel()
  Encode value for OBJSEL

  Parameters:
  >:in:    base        VRAM Base Address     uint16 (truncated to 8K word alignment)
  >:in:    size        OBJ Size              OBJ_8x8_16x16   / OBJ_8x8_32x32   / OBJ_8x8_64x64 /
  >                                          OBJ_16x16_32x32 / OBJ_16x16_64x64 / OBJ_32x32_64x64
  >:in:    gap         Gap between OBJ sets  uint16 (truncated to 4K word alignment)
*/
.define objsel(base, size, gap) (.lobyte(((base >> 14) << OBJ_NAME_SHIFT) | ((gap >> 13) << 3) | (size & (-OBJ_SIZE_MASK))))

/**
  Macro: bgmode()
  Encode value for BGMODE

  Parameters:
  >:in:    mode        Mode                  0-7
  >:in:    bg3_prio    BG3 Priority          bool (0 = normal, 1 = high)
  >:in:    bg1sz       BG1 Size              BG_SIZE_8X8 / BG_SIZE_16X16
  >:in:    bg2sz       BG2 Size              BG_SIZE_8X8 / BG_SIZE_16X16
  >:in:    bg3sz       BG3 Size              BG_SIZE_8X8 / BG_SIZE_16X16
  >:in:    bg4sz       BG4 Size              BG_SIZE_8X8 / BG_SIZE_16X16
*/
.define bgmode(mode, bg3_prio, bg1sz, bg2sz, bg3sz, bg4sz) (.lobyte((mode & ~BG_MODE_MASK) | ((bg3_prio & 1) << BG_BG3_MAX_PRIO_SHIFT) | ((bg1sz & 1) << 4) | ((bg2sz & 1) << 5) | ((bg3sz & 1) << 6) | ((bg4sz & 1) << 7)))

/**
  Macro: bgsc()
  Encode value for BGnSC

  Parameters:
  >:in:    base        VRAM Base Address     uint16 (truncated to 1K word alignment)
  >:in:    size        BG Size               SC_SIZE_32X32 / SC_SIZE_64X32 / SC_SIZE_32X64 / SC_SIZE_64X64
*/
.define bgsc(base, size) (.lobyte(((base >> 11) << SC_BASE_SHIFT) | size))

/**
  Macro: bgnba()
  Encode value for BG12NBA+BG34NBA

  Parameters:
  >:in:    bg1         BG1 Character Area    uint16 (truncated to 4K word alignment)
  >:in:    bg2         BG2 Character Area    uint16 (truncated to 4K word alignment)
  >:in:    bg3         BG3 Character Area    uint16 (truncated to 4K word alignment)
  >:in:    bg4         BG4 Character Area    uint16 (truncated to 4K word alignment)
*/
.define bgnba(bg1, bg2, bg3, bg4) (.loword((bg1 >> 13) | ((bg2 >> 13) << 4) | ((bg3 >> 13) << 8) | ((bg4 >> 13) << 12)))

/**
  Macro: bg12nba()
  Encode value for BG12NBA

  Parameters:
  >:in:    bg1         BG1 Character Area    uint16 (truncated to 4K word alignment)
  >:in:    bg2         BG2 Character Area    uint16 (truncated to 4K word alignment)
*/
.define bg12nba(bg1, bg2) (.lobyte((bg1 >> 13) | ((bg2 >> 13) << 4)))

/**
  Macro: bg34nba()
  Encode value for BG34NBA

  Parameters:
  >:in:    bg3         BG3 Character Area    uint16 (truncated to 4K word alignment)
  >:in:    bg4         BG4 Character Area    uint16 (truncated to 4K word alignment)
*/
.define bg34nba(bg3, bg4) (.lobyte((bg3 >> 13) | ((bg4 >> 13) << 4)))


;-------------------------------------------------------------------------------
;PPU Data Register Bitmasks & Constants

;Base Segment Sizes
SC_BASE_SIZE            = $0800
BG_BASE_SIZE            = $2000
OBJ_BASE_SIZE           = $4000

;OAM Data
OAM_H_POS_MASK          = $ff00
OAM_V_POS_MASK          = $00ff
OAM_NAME_MASK           = $fe00
OAM_COLR_MASK           = $f1ff
OAM_PRIO_MASK           = $cfff
OAM_FLIP_MASK           = $3fff

OAM_H_POS_SHIFT         = 0
OAM_V_POS_SHIFT         = 8
OAM_NAME_SHIFT          = 0
OAM_COLR_SHIFT          = 9
OAM_PRIO_SHIFT          = 12
OAM_FLIP_SHIFT          = 14

OAM_H_FLIP              = $4000
OAM_V_FLIP              = $8000

;BG Screen Data
BG_SC_NAME_MASK         = $fc00
BG_SC_COLR_MASK         = $e3ff
BG_SC_PRIO_MASK         = $dfff
BG_SC_FLIP_MASK         = $3fff

BG_SC_NAME_SHIFT        = 0
BG_SC_COLR_SHIFT        = 10
BG_SC_PRIO_SHIFT        = 13
BG_SC_FLIP_SHIFT        = 14

BG_SC_H_FLIP            = $4000
BG_SC_V_FLIP            = $8000

;Color data
COLR_RED_MASK           = $ffe0
COLR_GREEN_MASK         = $fc1f
COLR_BLUE_MASK          = $83ff

COLR_RED_SHIFT          = 0
COLR_GREEN_SHIFT        = 5
COLR_BLUE_SHIFT         = 16

COLR_BLACK              = $0000
COLR_BLUE               = $7c00
COLR_RED                = $001f
COLR_MAGENTA            = $7c1f
COLR_GREEN              = $03e0
COLR_CYAN               = $7fe0
COLR_YELLOW             = $03ff
COLR_WHITE              = $7fff


;-------------------------------------------------------------------------------
/**
   Group: Window Mask
*/

/**
   Registers: Window Mask Registers

   >W12SEL                  = $2123   ;Window Mask Settings (BG1/2)
   >W34SEL                  = $2124   ;Window Mask Settings (BG3/4)
   >WOBJSEL                 = $2125   ;Window Mask Settings (OBJ/COLOR)
   >
   >WH0                     = $2126   ;Window 1 Left Position
   >WH1                     = $2127   ;Window 1 Right Position
   >WH2                     = $2128   ;Window 2 Left Position
   >WH3                     = $2129   ;Window 2 Right Position
   >
   >WBGLOG                  = $212a   ;Window 1/2 Mask Logic Settings (BG1-4)
   >WOBJLOG                 = $212b   ;Window 1/2 Mask Logic Settings (OBJ/MATH)
*/

W12SEL                  = $2123 ;Window Mask Settings (BG1/2)
W34SEL                  = $2124 ;Window Mask Settings (BG3/4)
WOBJSEL                 = $2125 ;Window Mask Settings (OBJ/COLOR)

WM1_W1_AREA_MASK        = $fe
WM1_W1_ON_MASK          = $fd
WM1_W2_AREA_MASK        = $fb
WM1_W2_ON_MASK          = $f7
WM2_W1_AREA_MASK        = $ef
WM2_W1_ON_MASK          = $df
WM2_W2_AREA_MASK        = $bf
WM2_W2_ON_MASK          = $7f
WM1_W1_AREA_SHIFT       = 0
WM1_W1_ON_SHIFT         = 1
WM1_W2_AREA_SHIFT       = 2
WM1_W2_ON_SHIFT         = 3
WM2_W1_AREA_SHIFT       = 4
WM2_W1_ON_SHIFT         = 5
WM2_W2_AREA_SHIFT       = 6
WM2_W2_ON_SHIFT         = 7
WM1_W1_AREA_IN          = $00
WM1_W1_AREA_OUT         = $01
WM1_W1_ON               = $02
WM1_W1_OFF              = $00
WM1_W2_AREA_IN          = $00
WM1_W2_AREA_OUT         = $04
WM1_W2_ON               = $08
WM1_W2_OFF              = $00
WM2_W1_AREA_IN          = $00
WM2_W1_AREA_OUT         = $10
WM2_W1_ON               = $20
WM2_W1_OFF              = $00
WM2_W2_AREA_IN          = $00
WM2_W2_AREA_OUT         = $40
WM2_W2_ON               = $80
WM2_W2_OFF              = $00

WH0                     = $2126 ;Window 1 Left Position
WH1                     = $2127 ;Window 1 Right Position
WH2                     = $2128 ;Window 2 Left Position
WH3                     = $2129 ;Window 2 Right Position

WBGLOG                  = $212a ;Window 1/2 Mask Logic Settings (BG1-4)
WOBJLOG                 = $212b ;Window 1/2 Mask Logic Settings (OBJ/MATH)

WL_BG1_MASK             = $fc
WL_BG2_MASK             = $f3
WL_BG3_MASK             = $cf
WL_BG4_MASK             = $3f
WL_OBJ_MASK             = $fc
WL_COLR_MASK            = $f3
WL_BG1_SHIFT            = 0
WL_BG2_SHIFT            = 2
WL_BG3_SHIFT            = 4
WL_BG4_SHIFT            = 6
WL_OBJ_SHIFT            = 0
WL_COLR_SHIFT           = 2
WL_OR                   = $00
WL_AND                  = $01
WL_XOR                  = $02
WL_XNOR                 = $03

WL_BG1_OR               = WL_OR<<WL_BG1_SHIFT
WL_BG1_AND              = WL_AND<<WL_BG1_SHIFT
WL_BG1_XOR              = WL_XOR<<WL_BG1_SHIFT
WL_BG1_XNOR             = WL_XNOR<<WL_BG1_SHIFT
WL_BG2_OR               = WL_OR<<WL_BG2_SHIFT
WL_BG2_AND              = WL_AND<<WL_BG2_SHIFT
WL_BG2_XOR              = WL_XOR<<WL_BG2_SHIFT
WL_BG2_XNOR             = WL_XNOR<<WL_BG2_SHIFT
WL_BG3_OR               = WL_OR<<WL_BG3_SHIFT
WL_BG3_AND              = WL_AND<<WL_BG3_SHIFT
WL_BG3_XOR              = WL_XOR<<WL_BG3_SHIFT
WL_BG3_XNOR             = WL_XNOR<<WL_BG3_SHIFT
WL_BG4_OR               = WL_OR<<WL_BG4_SHIFT
WL_BG4_AND              = WL_AND<<WL_BG4_SHIFT
WL_BG4_XOR              = WL_XOR<<WL_BG4_SHIFT
WL_BG4_XNOR             = WL_XNOR<<WL_BG4_SHIFT
WL_OBJ_OR               = WL_OR<<WL_OBJ_SHIFT
WL_OBJ_AND              = WL_AND<<WL_OBJ_SHIFT
WL_OBJ_XOR              = WL_XOR<<WL_OBJ_SHIFT
WL_OBJ_XNOR             = WL_XNOR<<WL_OBJ_SHIFT
WL_COLR_OR              = WL_OR<<WL_COLR_SHIFT
WL_COLR_AND             = WL_AND<<WL_COLR_SHIFT
WL_COLR_XOR             = WL_XOR<<WL_COLR_SHIFT
WL_COLR_XNOR            = WL_XNOR<<WL_COLR_SHIFT


;-------------------------------------------------------------------------------
/**
   Group: Screen Designation
*/

/**
   Registers: Screen Designation Registers

   >TM                      = $212c   ;Main Screen Designation
   >TS                      = $212d   ;Sub Screen Designation
   >TMW                     = $212e   ;Window Mask Designation for Main Screen
   >TSW                     = $212f   ;Window Mask Designation for Sub Screen
*/

TM                      = $212c ;Main Screen Designation
TM_BG1_MASK             = $fe
TM_BG2_MASK             = $fd
TM_BG3_MASK             = $fb
TM_BG4_MASK             = $f7
TM_OBJ_MASK             = $ef
TM_BG1_SHIFT            = 0
TM_BG2_SHIFT            = 1
TM_BG3_SHIFT            = 2
TM_BG4_SHIFT            = 3
TM_OBJ_SHIFT            = 4
TM_BG1_ON               = $01
TM_BG1_OFF              = $00
TM_BG2_ON               = $02
TM_BG2_OFF              = $00
TM_BG3_ON               = $04
TM_BG3_OFF              = $00
TM_BG4_ON               = $08
TM_BG4_OFF              = $00
TM_OBJ_ON               = $10
TM_OBJ_OFF              = $00

TS                      = $212d ;Sub Screen Designation
TS_BG1_MASK             = $fe
TS_BG2_MASK             = $fd
TS_BG3_MASK             = $fb
TS_BG4_MASK             = $f7
TS_OBJ_MASK             = $ef
TS_BG1_SHIFT            = 0
TS_BG2_SHIFT            = 1
TS_BG3_SHIFT            = 2
TS_BG4_SHIFT            = 3
TS_OBJ_SHIFT            = 4
TS_BG1_ON               = $01
TS_BG1_OFF              = $00
TS_BG2_ON               = $02
TS_BG2_OFF              = $00
TS_BG3_ON               = $04
TS_BG3_OFF              = $00
TS_BG4_ON               = $08
TS_BG4_OFF              = $00
TS_OBJ_ON               = $10
TS_OBJ_OFF              = $00

TMW                     = $212e ;Window Mask Designation for Main Screen
TMW_BG1_MASK            = $fe
TMW_BG2_MASK            = $fd
TMW_BG3_MASK            = $fb
TMW_BG4_MASK            = $f7
TMW_OBJ_MASK            = $ef
TMW_BG1_SHIFT           = 0
TMW_BG2_SHIFT           = 1
TMW_BG3_SHIFT           = 2
TMW_BG4_SHIFT           = 3
TMW_OBJ_SHIFT           = 4
TMW_BG1_ON              = $01
TMW_BG1_OFF             = $00
TMW_BG2_ON              = $02
TMW_BG2_OFF             = $00
TMW_BG3_ON              = $04
TMW_BG3_OFF             = $00
TMW_BG4_ON              = $08
TMW_BG4_OFF             = $00
TMW_OBJ_ON              = $10
TMW_OBJ_OFF             = $00

TSW                     = $212f ;Window Mask Designation for Sub Screen
TSW_BG1_MASK            = $fe
TSW_BG2_MASK            = $fd
TSW_BG3_MASK            = $fb
TSW_BG4_MASK            = $f7
TSW_OBJ_MASK            = $ef
TSW_BG1_SHIFT           = 0
TSW_BG2_SHIFT           = 1
TSW_BG3_SHIFT           = 2
TSW_BG4_SHIFT           = 3
TSW_MASK_SHIFT          = 4
TSW_BG1_ON              = $01
TSW_BG1_OFF             = $00
TSW_BG2_ON              = $02
TSW_BG2_OFF             = $00
TSW_BG3_ON              = $04
TSW_BG3_OFF             = $00
TSW_BG4_ON              = $08
TSW_BG4_OFF             = $00
TSW_OBJ_ON              = $10
TSW_OBJ_OFF             = $00

/**
  Macro: tm()
  Encode value for TM/TS/TMW/TSW

  Parameters:
  >:in:    bg1         BG1 Enable            bool
  >:in:    bg2         BG2 Enable            bool
  >:in:    bg3         BG3 Enable            bool
  >:in:    bg4         BG4 Enable            bool
  >:in:    obj         OBJ Enable            bool
*/
.define tm(bg1, bg2, bg3, bg4, obj) (.lobyte((bg1 & 1) | ((bg2 & 1) << TM_BG2_SHIFT) | ((bg3 & 1) << TM_BG3_SHIFT) | ((bg4 & 1) << TM_BG4_SHIFT) | ((obj & 1) << TM_OBJ_SHIFT)))


;-------------------------------------------------------------------------------
/**
   Group: Color Math
*/

/**
   Registers: Color Math Registers

   >CGSWSEL                 = $2130   ;Initial settings for fixed color/screen addition
   >CGADSUB                 = $2131   ;Addition/Subtraction Designation
   >COLDATA                 = $2132   ;Fixed Color Data
*/

CGSWSEL                 = $2130 ;Initial settings for fixed color/screen addition
CG_DIRECT_SELECT_MASK   = $fe
CG_ENABLE_MASK          = $fd
CG_SUB_MASK             = $cf
CG_MAIN_MASK            = $3f
CG_DIRECT_SELECT_SHIFT  = 0
CG_ENABLE_SHIFT         = 1
CG_SUB_SHIFT            = 4
CG_MAIN_SHIFT           = 6
CG_DIRECT_SELECT_ON     = $01
CG_DIRECT_SELECT_OFF    = $00
CG_ENABLE_FIXED_COL     = $00
CG_ENABLE_SUB_SC        = $02
CG_SUB_ALL              = $00
CG_SUB_INSIDE           = $10
CG_SUB_OUTSIDE          = $20
CG_SUB_OFF              = $30
CG_MAIN_ALL             = $00
CG_MAIN_INSIDE          = $40
CG_MAIN_OUTSIDE         = $80
CG_MAIN_OFF             = $c0

CGADSUB                 = $2131 ;Addition/Subtraction Designation
CG_BG1_MASK             = $fe
CG_BG2_MASK             = $fd
CG_BG3_MASK             = $fb
CG_BG4_MASK             = $f7
CG_OBJ_MASK             = $ef
CG_BACK_MASK            = $df
CG_HALF_MASK            = $bf
CG_MODE_MASK            = $7f
CG_BG1_SHIFT            = 0
CG_BG2_SHIFT            = 1
CG_BG3_SHIFT            = 2
CG_BG4_SHIFT            = 3
CG_OBJ_SHIFT            = 4
CG_BACK_SHIFT           = 5
CG_HALF_SHIFT           = 6
CG_MODE_SHIFT           = 7
CG_BG1_ON               = $01
CG_BG1_OFF              = $00
CG_BG2_ON               = $02
CG_BG2_OFF              = $00
CG_BG3_ON               = $04
CG_BG3_OFF              = $00
CG_BG4_ON               = $08
CG_BG4_OFF              = $00
CG_OBJ_ON               = $10
CG_OBJ_OFF              = $00
CG_BACK_ON              = $20
CG_BACK_OFF             = $00
CG_HALF_ON              = $40
CG_HALF_OFF             = $00
CG_MODE_ADD             = $00
CG_MODE_SUB             = $80

COLDATA                 = $2132 ;Fixed Color Data
CDAT_CONST_COL_MASK     = $e0
CDAT_RED_MASK           = $df
CDAT_GREEN_MASK         = $bf
CDAT_BLUE_MASK          = $7f
CDAT_CONST_SHIFT        = 0
CDAT_RED_SHIFT          = 5
CDAT_GREEN_SHIFT        = 6
CDAT_BLUE_SHIFT         = 7
CDAT_RED                = $20
CDAT_GREEN              = $40
CDAT_BLUE               = $80


;-------------------------------------------------------------------------------
/**
   Group: MMIO Math
*/

/**
   Registers: MMIO Math Registers

   >MPYL                    = $2134   ;PPU1 Signed Multiply Result (lower 8-bit)
   >MPYM                    = $2135   ;PPU1 Signed Multiply Result (middle 8-bit)
   >MPYH                    = $2136   ;PPU1 Signed Multiply Result (upper 8-bit)
   >
   >WRMPYM7A                = M7A     ;PPU1 Signed 16-bit Multiplicand
   >WRMPYM7B                = M7B     ;PPU1 Signed 8-bit Multiplier
   >
   >RDDIVL                  = $4214   ;Unsigned Division Result (Quotient) (LSB)
   >RDDIVH                  = $4215   ;Unsigned Division Result (Quotient) (MSB)
   >RDMPYL                  = $4216   ;Unsigned Division Remainder / Multiply Product (LSB)
   >RDMPYH                  = $4217   ;Unsigned Division Remainder / Multiply Product (MSB)
   >
   >WRMPYA                  = $4202   ;Unsigned 8-bit Multiplicand
   >WRMPYB                  = $4203   ;Unsigned 8-bit Multiplier
   >WRDIVL                  = $4204   ;Unsigned 16-bit Dividend (LSB)
   >WRDIVH                  = $4205   ;Unsigned 16-bit Dividend (MSB)
   >WRDIVB                  = $4206   ;Unsigned 8-bit Divisor
*/

MPYL                    = $2134 ;PPU1 Signed Multiply Result (lower 8-bit)
MPYM                    = $2135 ;PPU1 Signed Multiply Result (middle 8-bit)
MPYH                    = $2136 ;PPU1 Signed Multiply Result (upper 8-bit)

WRMPYM7A                = M7A   ;PPU1 Signed 16-bit Multiplicand
WRMPYM7B                = M7B   ;PPU1 Signed 8-bit Multiplier

RDDIVL                  = $4214 ;Unsigned Division Result (Quotient) (LSB)
RDDIVH                  = $4215 ;Unsigned Division Result (Quotient) (MSB)
RDMPYL                  = $4216 ;Unsigned Division Remainder / Multiply Product (LSB)
RDMPYH                  = $4217 ;Unsigned Division Remainder / Multiply Product (MSB)

WRMPYA                  = $4202 ;Unsigned 8-bit Multiplicand
WRMPYB                  = $4203 ;Unsigned 8-bit Multiplier
WRDIVL                  = $4204 ;Unsigned 16-bit Dividend (LSB)
WRDIVH                  = $4205 ;Unsigned 16-bit Dividend (MSB)
WRDIVB                  = $4206 ;Unsigned 8-bit Divisor


;-------------------------------------------------------------------------------
/**
   Group: APU & WRAM Data Ports
*/

/**
   Registers: APU & WRAM Data Port Registers

   >APUIO0                  = $2140   ;Sound CPU Communication Port 0
   >APUIO1                  = $2141   ;Sound CPU Communication Port 1
   >APUIO2                  = $2142   ;Sound CPU Communication Port 2
   >APUIO3                  = $2143   ;Sound CPU Communication Port 4
   >
   >SMPIO0                  = APUIO0  ;Aliases for APUIO
   >SMPIO1                  = APUIO1
   >SMPIO2                  = APUIO2
   >SMPIO3                  = APUIO3
   >
   >WMDATA                  = $2180   ;WRAM Data Read/Write
   >WMADDL                  = $2181   ;WRAM Address (lower 8-bit)
   >WMADDM                  = $2182   ;WRAM Address (middle 8-bit)
   >WMADDH                  = $2183   ;WRAM Address (upper 1-bit)
*/

APUIO0                  = $2140   ;Sound CPU Communication Port 0
APUIO1                  = $2141   ;Sound CPU Communication Port 1
APUIO2                  = $2142   ;Sound CPU Communication Port 2
APUIO3                  = $2143   ;Sound CPU Communication Port 4

SMPIO0                  = APUIO0  ;Aliases for APUIO
SMPIO1                  = APUIO1
SMPIO2                  = APUIO2
SMPIO3                  = APUIO3

WMDATA                  = $2180 ;WRAM Data Read/Write
WMADDL                  = $2181 ;WRAM Address (lower 8-bit)
WMADDM                  = $2182 ;WRAM Address (middle 8-bit)
WMADDH                  = $2183 ;WRAM Address (upper 1-bit)


;-------------------------------------------------------------------------------
/**
   Group: Joypad
*/

/**
   Registers: Joypad Registers

   >JOYFCL                  = $4016   ;Joypad Input Register (LSB)
   >JOYFCH                  = $4017   ;Joypad Input Register (MSB)
   >JOYWR                   = $4016   ;Joypad Output (W)
   >JOYA                    = $4016   ;Joypad Input Register A (R)
   >JOYB                    = $4017   ;Joypad Input Register B (R)
   >
   >WRIO                    = $4201   ;Joypad Programmable I/O Port
   >RDIO                    = $4213   ;Joypad Programmable I/O Port
   >
   >JOY1L                   = $4218   ;Joypad 1 (LSB)
   >JOY1H                   = $4219   ;Joypad 1 (MSB)
   >JOY2L                   = $421a   ;Joypad 2 (LSB)
   >JOY2H                   = $421b   ;Joypad 2 (MSB)
   >JOY3L                   = $421c   ;Joypad 3 (LSB)
   >JOY3H                   = $421d   ;Joypad 3 (MSB)
   >JOY4L                   = $421e   ;Joypad 4 (LSB)
   >JOY4H                   = $421f   ;Joypad 4 (MSB)
*/

JOYFCL                  = $4016 ;Joypad Input Register (LSB)
JOYFCH                  = $4017 ;Joypad Input Register (MSB)
JOYWR                   = $4016 ;Joypad Output (W)
JOYA                    = $4016 ;Joypad Input Register A (R)
JOYB                    = $4017 ;Joypad Input Register B (R)

WRIO                    = $4201 ;Joypad Programmable I/O Port
RDIO                    = $4213 ;Joypad Programmable I/O Port

JOY1L                   = $4218 ;Joypad 1 (LSB)
JOY1H                   = $4219 ;Joypad 1 (MSB)
JOY2L                   = $421a ;Joypad 2 (LSB)
JOY2H                   = $421b ;Joypad 2 (MSB)
JOY3L                   = $421c ;Joypad 3 (LSB)
JOY3H                   = $421d ;Joypad 3 (MSB)
JOY4L                   = $421e ;Joypad 4 (LSB)
JOY4H                   = $421f ;Joypad 4 (MSB)
JOY_R                   = $0010
JOY_L                   = $0020
JOY_X                   = $0040
JOY_A                   = $0080
JOY_RIGHT               = $0100
JOY_LEFT                = $0200
JOY_DOWN                = $0400
JOY_UP                  = $0800
JOY_START               = $1000
JOY_SELECT              = $2000
JOY_Y                   = $4000
JOY_B                   = $8000
JOY_BUTTON_MASK         = JOY_L+JOY_R+JOY_X+JOY_A+JOY_START+JOY_SELECT+JOY_Y+JOY_B
JOY_KEY_MASK            = JOY_RIGHT+JOY_LEFT+JOY_DOWN+JOY_UP
JOY_ALL_MASK            = JOY_BUTTON_MASK+JOY_KEY_MASK


;-------------------------------------------------------------------------------
/**
   Group: Interrupt & Status
*/

/**
   Registers: Interrupt & Status Registers

   >NMITIMEN                = $4200   ;Interrupt Enable / Joypad Request
   >
   >HTIMEL                  = $4207   ;H-Count Timer Setting (LSB)
   >HTIMEH                  = $4208   ;H-Count Timer Setting (MSB)
   >VTIMEL                  = $4209   ;V-Count Timer Setting (LSB)
   >VTIMEH                  = $420a   ;V-Count Timer Setting (MSB)
   >
   >MEMSEL                  = $420d   ;Access Cycle Designation
   >
   >RDNMI                   = $4210   ;V-Blank NMI Flag / CPU Version Number
   >TIMEUP                  = $4211   ;H/V-Timer IRQ Flag
   >HVBJOY                  = $4212   ;H/V-Blank Flag / Joypad Busy Flag
   >
   >SLHV                    = $2137   ;PPU1 Latch H/V-Counter
   >OPHCT                   = $213c   ;PPU2 Horizontal Counter Latch (read-twice)
   >OPVCT                   = $213d   ;PPU2 Vertical Counter Latch (read-twice)
   >
   >STAT77                  = $213e   ;PPU1 Status/Version
   >STAT78                  = $213f   ;PPU2 Status/Version
*/

NMITIMEN                = $4200 ;Interrupt Enable / Joypad Request
NMI_JOY_MASK            = $fe
NMI_H_TIMER_MASK        = $ef
NMI_V_TIMER_MASK        = $df
NMI_HV_TIMER_MASK       = $cf
NMI_NMI_MASK            = $7f
NMI_JOY_SHIFT           = 0
NMI_H_TIMER_SHIFT       = 4
NMI_V_TIMER_SHIFT       = 5
NMI_NMI_SHIFT           = 7
NMI_JOY_ON              = $01
NMI_JOY_OFF             = $00
NMI_H_TIMER_ON          = $10
NMI_H_TIMER_OFF         = $00
NMI_V_TIMER_ON          = $20
NMI_V_TIMER_OFF         = $00
NMI_NMI_ON              = $80
NMI_NMI_OFF             = $00

HTIMEL                  = $4207 ;H-Count Timer Setting (LSB)
HTIMEH                  = $4208 ;H-Count Timer Setting (MSB)
VTIMEL                  = $4209 ;V-Count Timer Setting (LSB)
VTIMEH                  = $420a ;V-Count Timer Setting (MSB)

MEMSEL                  = $420d ;Access Cycle Designation
MEM_268_MHZ             = $00
MEM_358_MHZ             = $01

RDNMI                   = $4210 ;V-Blank NMI Flag / CPU Version Number
RDNMI_5A22V_MASK        = $f0
RDNMI_NMI_STAT_MASK     = $7f
RDNMI_5A22V_SHIFT       = 0
RDNMI_NMI_STAT_SHIFT    = 7

TIMEUP                  = $4211 ;H/V-Timer IRQ Flag
TIME_STAT_MASK          = $7f
TIME_STAT_SHIFT         = 7

HVBJOY                  = $4212 ;H/V-Blank Flag / Joypad Busy Flag
HVBJOY_JOY_STAT_MASK    = $fe
HVBJOY_H_BLANK_MASK     = $bf
HVBJOY_V_BLANK_MASK     = $7f
HVBJOY_JOY_STAT_SHIFT   = 0
HVBJOY_H_BLANK_SHIFT    = 6
HVBJOY_V_BLANK_SHIFT    = 7
HVBJOY_JOY_FREE         = $00
HVBJOY_JOY_BUSY         = $01
HVBJOY_H_BLANK          = $40
HVBJOY_V_BLANK          = $80

SLHV                    = $2137 ;PPU1 Latch H/V-Counter
OPHCT                   = $213c ;PPU2 Horizontal Counter Latch (read-twice)
OPVCT                   = $213d ;PPU2 Vertical Counter Latch (read-twice)

STAT77                  = $213e ;PPU1 Status/Version
STAT77_5C77V_MASK       = $f0
STAT77_MS_MODE_MASK     = $df
STAT77_OBJSTAT_MASK     = $3f
STAT77_5C77V_SHIFT      = 0
STAT77_MS_MODE_SHIFT    = 5
STAT77_OBJSTAT_SHIFT    = 6

STAT78                  = $213f ;PPU2 Status/Version
STAT78_5C78V_MASK       = $f0
STAT78_VIDEOMODE_MASK   = $ef
STAT78_EXT_MASK         = $bf
STAT78_FIELD_MASK       = $7f
STAT78_5C78V_SHIFT      = 0
STAT78_VIDEOMODE_SHIFT  = 4
STAT78_EXT_SHIFT        = 6
STAT78_FIELD_SHIFT      = 7
STAT78_VIDEOMODE_NTSC   = $00
STAT78_VIDEOMODE_PAL    = $01


;-------------------------------------------------------------------------------
/**
   Group: DMA
*/

/**
   Registers: DMA Registers

   >MDMAEN                  = $420b   ;General Purpose DMA Channel Designation & Trigger
   >HDMAEN                  = $420c   ;H-DMA Channel Designation
   >
   >DMA Control (channel n = 0-7)
   >DMAPn                   = $43n0   ;DMA Parameters
   >BBADn                   = $43n1   ;DMA I/O-Bus Address (B-Bus)
   >A1TnL                   = $43n2   ;HDMA Table Start Address / DMA Current Address (LSB)
   >A1TnH                   = $43n3   ;HDMA Table Start Address / DMA Current Address (MSB)
   >A1Bn                    = $43n4   ;HDMA Table Start Address / DMA Current Address (BANK)
   >DASnL                   = $43n5   ;Indirect HDMA Address / DMA Byte-Counter (LSB)
   >DASnH                   = $43n6   ;Indirect HDMA Address / DMA Byte-Counter (MSB)
   >DASBn                   = $43n7   ;Indirect HDMA Address (BANK)
   >A2AnL                   = $43n8   ;HDMA Table Current Address (LSB)
   >A2AnH                   = $43n9   ;HDMA Table Current Address (MSB)
   >NTRLn                   = $43na   ;HDMA Line-Counter
*/

MDMAEN                  = $420b ;General Purpose DMA Channel Designation & Trigger
HDMAEN                  = $420c ;H-DMA Channel Designation
DMA0_ON                 = $01
DMA0_OFF                = $00
DMA1_ON                 = $02
DMA1_OFF                = $00
DMA2_ON                 = $04
DMA2_OFF                = $00
DMA3_ON                 = $08
DMA3_OFF                = $00
DMA4_ON                 = $10
DMA4_OFF                = $00
DMA5_ON                 = $20
DMA5_OFF                = $00
DMA6_ON                 = $40
DMA6_OFF                = $00
DMA7_ON                 = $80
DMA7_OFF                = $00

DMAP0                   = $4300 ;DMA Parameters
DMA_TRANS_SELECT_MASK   = $f8
DMA_INCDEC_MASK         = $e7
DMA_TYPE_MASK           = $bf
DMA_TRANS_DIR_MASK      = $7f
DMA_TRANS_SELECT_SHIFT  = 0
DMA_INCDEC_SHIFT        = 3
DMA_TYPE_SHIFT          = 6
DMA_TRANS_DIR_SHIFT     = 7
DMA_TRANS_1             = $00
DMA_TRANS_2_LH          = $01
DMA_TRANS_1_LL          = $02
DMA_TRANS_2_LLHH        = $03
DMA_TRANS_4_LHLH        = $04
HDMA_TRANS_1            = $00
HDMA_TRANS_2_LH         = $01
HDMA_TRANS_2_LL         = $02
HDMA_TRANS_2_LLHH       = $03
HDMA_TRANS_4_LHLH       = $04
DMA_FIXED               = $08
DMA_INCREMENT           = $00
DMA_DECREMENT           = $10
HDMA_ABSOLUTE           = $00
HDMA_INDIRECT           = $40
DMA_DIR_MEM_TO_PPU      = $00
DMA_DIR_PPU_TO_MEM      = $80

BBAD0                   = $4301 ;DMA I/O-Bus Address (B-Bus)
A1T0L                   = $4302 ;HDMA Table Start Address / DMA Current Address (LSB)
A1T0H                   = $4303 ;HDMA Table Start Address / DMA Current Address (MSB)
A1B0                    = $4304 ;HDMA Table Start Address / DMA Current Address (BANK)
DAS0L                   = $4305 ;Indirect HDMA Address / DMA Byte-Counter (LSB)
DAS0H                   = $4306 ;Indirect HDMA Address / DMA Byte-Counter (MSB)
DASB0                   = $4307 ;Indirect HDMA Address (BANK)
A2A0L                   = $4308 ;HDMA Table Current Address (LSB)
A2A0H                   = $4309 ;HDMA Table Current Address (MSB)
NTRL0                   = $430a ;HDMA Line-Counter

DMAP1                   = $4310
BBAD1                   = $4311
A1T1L                   = $4312
A1T1H                   = $4313
A1B1                    = $4314
DAS1L                   = $4315
DAS1H                   = $4316
DASB1                   = $4317
A2A1L                   = $4318
A2A1H                   = $4319
NTRL1                   = $431a

DMAP2                   = $4320
BBAD2                   = $4321
A1T2L                   = $4322
A1T2H                   = $4323
A1B2                    = $4324
DAS2L                   = $4325
DAS2H                   = $4326
DASB2                   = $4327
A2A2L                   = $4328
A2A2H                   = $4329
NTRL2                   = $432a

DMAP3                   = $4330
BBAD3                   = $4331
A1T3L                   = $4332
A1T3H                   = $4333
A1B3                    = $4334
DAS3L                   = $4335
DAS3H                   = $4336
DASB3                   = $4337
A2A3L                   = $4338
A2A3H                   = $4339
NTRL3                   = $433a

DMAP4                   = $4340
BBAD4                   = $4341
A1T4L                   = $4342
A1T4H                   = $4343
A1B4                    = $4344
DAS4L                   = $4345
DAS4H                   = $4346
DASB4                   = $4347
A2A4L                   = $4348
A2A4H                   = $4349
NTRL4                   = $434a

DMAP5                   = $4350
BBAD5                   = $4351
A1T5L                   = $4352
A1T5H                   = $4353
A1B5                    = $4354
DAS5L                   = $4355
DAS5H                   = $4356
DASB5                   = $4357
A2A5L                   = $4358
A2A5H                   = $4359
NTRL5                   = $435a

DMAP6                   = $4360
BBAD6                   = $4361
A1T6L                   = $4362
A1T6H                   = $4363
A1B6                    = $4364
DAS6L                   = $4365
DAS6H                   = $4366
DASB6                   = $4367
A2A6L                   = $4368
A2A6H                   = $4369
NTRL6                   = $436a

DMAP7                   = $4370
BBAD7                   = $4371
A1T7L                   = $4372
A1T7H                   = $4373
A1B7                    = $4374
DAS7L                   = $4375
DAS7H                   = $4376
DASB7                   = $4377
A2A7L                   = $4378
A2A7H                   = $4379
NTRL7                   = $437a

.endif; __MBSFX_CPU_Def__
