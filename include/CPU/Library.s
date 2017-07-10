; libSFX S-CPU Library Functions
; David Lindecrantz <optiroc@gmail.com>

.include "../libSFX.i"
.segment "LIBSFX"

;-------------------------------------------------------------------------------

/**
  SFX_WRAM_memset
  Set WRAM to a given value

  Parameters:
  >:in:  b:a     Value:Bank
  >:in:  x       Offset
  >:in:  y       Length
*/
SFX_WRAM_memset:
        RW_assume a8i16
        stz     MDMAEN          ;Disable DMA
        sta     WMADDH          ;WRAM bank
        stx     WMADDL          ;WRAM offset
        sty     DAS7L           ;Length

        lda     #(^SFX_linear_tab)
        sta     A1B7            ;Source bank
        xba                     ;Clear value offset
        RW a16
        and     #$00ff
        clc
        adc     #.loword(SFX_linear_tab)
        sta     A1T7L
        RW a8

        ;Set mode, destination and start transfer
        ldx     #(<WMDATA << 8 + DMA_DIR_MEM_TO_PPU + DMA_TRANS_1 + DMA_FIXED)
        stx     DMAP7

        lda     #%10000000
        sta     MDMAEN
        rtl


/**
  SFX_WRAM_memcpy
  Copy bytes from CPU-bus to WRAM using DMA

  Assumes that destination registers have already been written.

  Parameters:
  >:in:  a       Source bank
  >:in:  x       Source offset
  >:in:  y       Length
*/
SFX_WRAM_memcpy:
        RW_assume a8i16
        stz     MDMAEN          ;Disable DMA
        stx     A1T7L           ;Data offset
        sta     A1B7            ;Data bank
        sty     DAS7L           ;Size

        ;Set mode, destination and start transfer
        ldx     #(<WMDATA << 8 + DMA_DIR_MEM_TO_PPU + DMA_TRANS_1 + DMA_INCREMENT)
        stx     DMAP7
        lda     #%10000000
        sta     MDMAEN
        rtl


/**
  SFX_VRAM_memset
  Set VRAM to a given value

  Parameters:
  >:in:  a       Value
  >:in:  x       Offset (words)
  >:in:  y       Length
*/
SFX_VRAM_memset:
        RW_assume a8i16
        stz     MDMAEN          ;Disable DMA
        stx     VMADDL          ;Destination offset
        sty     DAS7L           ;Length
        sta     ZPAD            ;Source value
        lda     #VMA_TIMING_1   ;VRAM transfer mode
        sta     VMAINC
        ldx     #$1809          ;Mode: DMA_DIR_MEM_TO_PPU + DMA_FIXED + DMA_TRANS_2_LH, Destination: $4218
        stx     DMAP7
        ldx     #ZPAD           ;Source offset
        stx     A1T7L
        lda     #^ZPAD          ;Source bank
        sta     A1B7
        lda     #%10000000
        sta     MDMAEN
        rtl


/**
  SFX_VRAM_memcpy
  Copy bytes from CPU-bus to VRAM using DMA

  Assumes that destination registers have already been written.

  Parameters:
  >:in:  a       Source bank
  >:in:  x       Source offset
  >:in:  y       Length
*/
SFX_VRAM_memcpy:
        RW_assume a8i16
        stz     MDMAEN          ;Disable DMA
        stx     A1T7L           ;Data offset
        sta     A1B7            ;Data bank
        sty     DAS7L           ;Size
        lda     #$01
        sta     DMAP7           ;DMA mode (word, normal, increment)
        lda     #$18
        sta     BBAD7           ;Destination register = VMDATA ($2118/19)
        lda     #%10000000
        sta     MDMAEN          ;Start DMA transfer
        rtl


/**
  SFX_CGRAM_memcpy
  Copy bytes from CPU-bus to VRAM using DMA

  Assumes that destination registers have already been written.

  Parameters:
  >:in:  a       Source bank
  >:in:  x       Source offset
  >:in:  y       Length
*/
SFX_CGRAM_memcpy:
        RW_assume a8i16
        stz     MDMAEN          ;Disable DMA
        stx     A1T7L           ;Data offset
        sta     A1B7            ;Data bank
        sty     DAS7L           ;Size
        stz     DMAP7           ;DMA mode (byte, normal increment)
        lda     #$22
        sta     BBAD7           ;Destination register = $2122
        lda     #%10000000
        sta     MDMAEN          ;Start DMA transfer
        rtl


;-------------------------------------------------------------------------------

/**
  SFX_INIT_mmio
  Initialize PPU/CPU MMIO according to N's recommendations
*/
SFX_INIT_mmio:
        RW_assume a8i16
        RW a8i8

        dpage   INIDISP
        lda     #inidisp(OFF, DISP_BRIGHTNESS_MIN)
        sta     z:dpo(INIDISP)
        sta     a:SFX_inidisp

        stz     z:dpo(OBJSEL)           ;Reset OAM regs
        stz     z:dpo(OAMADDL)
        stz     z:dpo(OAMADDH)
        stz     z:dpo(BGMODE)           ;Reset BG setting
        stz     z:dpo(MOSAIC)
        stz     z:dpo(BG1SC)
        stz     z:dpo(BG2SC)
        stz     z:dpo(BG3SC)
        stz     z:dpo(BG4SC)
        stz     z:dpo(BG12NBA)
        stz     z:dpo(BG34NBA)
        stz     z:dpo(BG1HOFS)          ;Set BG scrolling H:000
        stz     z:dpo(BG1HOFS)
        stz     z:dpo(BG2HOFS)
        stz     z:dpo(BG2HOFS)
        stz     z:dpo(BG3HOFS)
        stz     z:dpo(BG3HOFS)
        stz     z:dpo(BG4HOFS)
        stz     z:dpo(BG4HOFS)
        lda     #$ff                    ;Set BG scrolling V:7ff
        ldx     #$07
        sta     z:dpo(BG1VOFS)
        stx     z:dpo(BG1VOFS)
        sta     z:dpo(BG2VOFS)
        stx     z:dpo(BG2VOFS)
        sta     z:dpo(BG3VOFS)
        stx     z:dpo(BG3VOFS)
        sta     z:dpo(BG4VOFS)
        stx     z:dpo(BG4VOFS)

        lda     #$80                    ;MODE1 VRAM increment
        sta     z:dpo(VMAINC)
        stz     z:dpo(VMADDL)           ;Reset VRAM address
        stz     z:dpo(VMADDH)
        stz     z:dpo(M7SEL)            ;Reset MODE7 setting
        lda     #$01                    ;Reset MODE7 matrix + position
        stz     z:dpo(M7A)
        sta     z:dpo(M7A)
        stz     z:dpo(M7B)
        stz     z:dpo(M7B)
        stz     z:dpo(M7C)
        stz     z:dpo(M7C)
        stz     z:dpo(M7D)
        sta     z:dpo(M7D)
        stz     z:dpo(M7X)
        stz     z:dpo(M7X)
        stz     z:dpo(M7Y)
        stz     z:dpo(M7Y)

        stz     z:dpo(CGADD)            ;Reset CGRAM address
        stz     z:dpo(W12SEL)           ;Reset WINDOW MASK setting
        stz     z:dpo(W34SEL)
        stz     z:dpo(WOBJSEL)
        stz     z:dpo(WH0)              ;Reset WINDOW position
        stz     z:dpo(WH1)
        stz     z:dpo(WH2)
        stz     z:dpo(WH3)
        stz     z:dpo(WBGLOG)           ;Reset MASK LOGIC setting
        stz     z:dpo(WOBJLOG)
        stz     z:dpo(TM)               ;Reset SCREEN and MASK designation setting
        stz     z:dpo(TS)
        stz     z:dpo(TMW)
        stz     z:dpo(TSW)

        lda     #$30                    ;Reset COLOR ADD/SUB setting
        sta     z:dpo(CGSWSEL)
        stz     z:dpo(CGADSUB)          ;Reset ADD/SUB designation
        lda     #$e0                    ;Reset fixed ADD/SUB color
        sta     z:dpo(COLDATA)
        stz     z:dpo(SETINI)           ;Reset SCREEN setting (no interlace, no ext)

        dpage   NMITIMEN
        stz     z:dpo(NMITIMEN)         ;Disable NMI + joypad
        lda     #$ff                    ;Put #$ff on I/O port
        sta     z:dpo(WRIO)
        stz     z:dpo(WRMPYA)           ;Reset hardware MUL/DIV
        stz     z:dpo(WRMPYB)
        stz     z:dpo(WRDIVL)
        stz     z:dpo(WRDIVH)
        stz     z:dpo(WRDIVB)
        stz     z:dpo(HTIMEL)           ;Reset H/V IRQ setting
        stz     z:dpo(HTIMEH)
        stz     z:dpo(VTIMEL)
        stz     z:dpo(VTIMEH)
        stz     z:dpo(MDMAEN)           ;Reset DMA designation
        stz     z:dpo(HDMAEN)           ;Reset H-DMA designation
        stz     JOYFCL                  ;Reset famicom-style joypad register

        dpage   $0000
        RW a8i16
        rtl


;-------------------------------------------------------------------------------

/**
  SFX_INIT_oam

  Parameters:
  >:in:  a:x     Table address
  >:in:  y       X/Y-pos lo-byte
  >:in:  b       X-pos hi-bit (across whole byte)
*/
SFX_INIT_oam:
        RW_assume a8i16
        stx     a:ZPAD          ;Set up direct page indirect addressing
        sta     a:ZPAD+2
        xba                     ;Save msb
        pha

        RW a16                  ;Set lo-bytes
        tyx
        ldy     #$0000
:       txa
        sta     [ZPAD],y
        iny
        iny
        lda     #$0000
        sta     [ZPAD],y
        iny
        iny
        cpy     #$0200
        bne     :-

        RW a8                    ;Restore msb
        pla
:       sta     [ZPAD],y         ;Set hi-bits
        iny
        cpy     #$0220
        bne     :-
        rtl


/**
  SFX_WAIT_vbl
  Wait for VBlank period
*/
SFX_WAIT_vbl:
        RW_assume a8
:       lda     HVBJOY          ;If currently in vblank, wait until flag is down
        bmi     :-
:       lda     HVBJOY          ;Wait until vblank flag is up
        bpl     :-
        rtl


/**
  SFX_PPU_is_ntsc
  Check if system timing is near enough real NTSC hardware

  NB! Perform check with blank screen and with interrupts disabled.

  Returns:
  >:out: a/z     a=0 and z=1 if system passes as NTSC, otherwise a=1 and z=0
*/
NTSC_true       = $1918
NTSC_margin     = $3
SFX_PPU_is_ntsc:
        RW_assume a8i16
        ldy     #$0001
        ldx     #$0000
        jsl     SFX_WAIT_vbl

:       inx                     ;Time one frame
        lda     HVBJOY
        bmi     :-
:       inx
        lda     HVBJOY
        bpl     :-

        ;SNES/NTSC     #$1918          SNES/PAL      #$1de2
        ;BSNES/NTSC    #$1918          BSNES/PAL     #$1de2
        ;NO$SNS/NTSC   #$1917          NO$SNS/PAL    #$1de2

        cpx     #(NTSC_true - NTSC_margin)
        bmi     :+
        cpx     #(NTSC_true + NTSC_margin)
        bpl     :+
        dey                     ;NTSC = YES
:       tya
        rtl

;-------------------------------------------------------------------------------
; Data

; Table with values #$00-#$ff, used for WRAM_memset
SFX_linear_tab:
  .repeat $100, I
        .byte I
  .endrep
