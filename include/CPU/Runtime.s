; libSFX S-CPU Runtime (System initialization and NMI/IRQ handlers)
; David Lindecrantz <optiroc@gmail.com>

.include "../libSFX.i"
.segment "LIBSFX"

;-------------------------------------------------------------------------------

/**
  SNES starts here!
*/
BootVector:
        sei                     ;Disable interrupts
        clc                     ;Enter native mode
        xce
        jml     @fast           ;Jump to fast mirror
@fast:
.assert (^@fast >= $80), warning, "libSFX not linked at fast address space"

        ;Initialize system
        CPU_init
        REG_init
        VRAM_memset $0000, $0000, $00
        WRAM_memset $0000, $2000 - __STACKSIZE__, $00
        WRAM_memset HIRAM, $e000, $00
        WRAM_memset EXRAM, $0000, $00

        ;Initialize interrupts
        lda     #(NMI_NMI_OFF + NMI_JOY_OFF)
        sta     SFX_nmitimen
        sta     NMITIMEN
        lda     #inidisp(OFF, DISP_BRIGHTNESS_MIN)
        sta     SFX_inidisp

        ;Set up interrupt handlers
        lda     #$5c
        sta     SFX_nmi_jml
        sta     SFX_irq_jml
        lda     #^EmptyVBlank
        ldx     #.loword(EmptyVBlank)
        stx     SFX_nmi_jml+1
        sta     SFX_nmi_jml+3
        stx     SFX_irq_jml+1
        sta     SFX_irq_jml+3

        ;Set up SFX_mvn
        lda     #$54            ;mvn
        sta     z:SFX_mvn
        lda     #$6b            ;rtl
        sta     z:SFX_mvn_rtl

        ;Init done, jump to Main entrypoint
        jml     Main


;-------------------------------------------------------------------------------

/**
  VBlank interrupt (NMI) handler

  SNES jumps here at the beginning of each vblank period
  - Software VBL interrupt is called
  - Joypads are read out (depending on SFX_AUTOJOY settings)
*/
VBlankVector:
        jml     :+                      ;Jump to fast mirror
:       push

        dpage   $0000
        inc     a:SFX_tick              ;Global frame ticker

        RW a8
        lda     RDNMI                   ;Clear NMI
        lda     #inidisp(OFF, DISP_BRIGHTNESS_MIN)
        sta     INIDISP

.if SFX_AUTOJOY_FIRST = NO
        jsl     SFX_nmi_jml             ;Call trampoline
.endif

.if .defined(SFXPKG_MOUSE)              ;If mouse support is enabled, let the mouse
        jsl     SFX_MOUSE_nmi_hook      ;driver take care of joypad polling
.else

  .if SFX_AUTOJOY <> DISABLE
        RW a8
:       lda     HVBJOY                  ;Wait for joypad readout
        and     #1
        bne     :-

        RW a16i16
  .endif
  .if SFX_AUTOJOY & JOY1                ;Read joypad 1
        ldx     z:SFX_joy1cont
        lda     JOY1L
        sta     z:SFX_joy1cont
        txa
        eor     z:SFX_joy1cont
        and     z:SFX_joy1cont
        sta     z:SFX_joy1trig
  .endif
  .if SFX_AUTOJOY & JOY2                ;Read joypad 2
        ldx     z:SFX_joy2cont
        lda     JOY2L
        sta     z:SFX_joy2cont
        txa
        eor     z:SFX_joy2cont
        and     z:SFX_joy2cont
        sta     z:SFX_joy2trig
  .endif
  .if SFX_AUTOJOY & JOY3                ;Read joypad 3
        ldx     z:SFX_joy3cont
        lda     JOY3L
        sta     z:SFX_joy3cont
        txa
        eor     z:SFX_joy3cont
        and     z:SFX_joy3cont
        sta     z:SFX_joy3trig
  .endif
  .if SFX_AUTOJOY & JOY4                ;Read joypad 4
        ldx     z:SFX_joy4cont
        lda     JOY4L
        sta     z:SFX_joy4cont
        txa
        eor     z:SFX_joy4cont
        and     z:SFX_joy4cont
        sta     z:SFX_joy4trig
  .endif

.endif

.if SFX_AUTOJOY_FIRST = YES
        jsl     SFX_nmi_jml             ;Call trampoline
.endif

        RW a8
        lda     a:SFX_nmitimen          ;Set IRQ flags
        sta     NMITIMEN

        lda     a:SFX_inidisp           ;Restore screen and return
        sta     INIDISP

        pull

EmptyVector:
        rti


;-------------------------------------------------------------------------------

/**
  Vertical interrupt (IRQ) handler

  SNES jumps here at the raster line registered with the IRQ_set macro
*/
IRQVector:
        jml     :+                      ;Jump to fast mirror
:       push
        RW a8
        lda     TIMEUP                  ;Acknowledge IRQ
        jsl     SFX_irq_jml             ;Call trampoline
        pull
        rti


;-------------------------------------------------------------------------------
SFX_stash_nmi:
        RW_assume a8i16
        ldx     SFX_nmi_jml+1
        lda     SFX_nmi_jml+3
        stx     SFX_nmi_store
        sta     SFX_nmi_store+2
        lda     #^EmptyVBlank
        ldx     #.loword(EmptyVBlank)
        stx     SFX_nmi_jml+1
        sta     SFX_nmi_jml+3
        rtl

SFX_restore_nmi:
        RW_assume a8i16
        ldx     SFX_nmi_store
        lda     SFX_nmi_store+2
        stx     SFX_nmi_jml+1
        sta     SFX_nmi_jml+3

EmptyVBlank:
        rtl

.reloc

;-------------------------------------------------------------------------------
;RAM
.segment "ZEROPAGE": zeropage

SFX_nmi_jml:    .res 4          ;Software NMI trampoline (jml+longaddr)
SFX_irq_jml:    .res 4          ;Software IRQ trampoline (jml+longaddr)

SFX_nmi_store:  .res 3          ;Stashed NMI longaddr
SFX_inidisp:    .res 1          ;Stashed INIDISP
SFX_nmitimen:   .res 1          ;Stashed NMITIMEN

SFX_tick:       .res 2          ;Frame ticker

SFX_mvn:        .res 1          ;Modifiable mvn instruction
SFX_mvn_dst:    .res 1          ;  Destination bank
SFX_mvn_src:    .res 1          ;  Source bank
SFX_mvn_rtl:    .res 1          ;  Return

.if SFX_AUTOJOY & JOY1
SFX_joy1cont:   .res 2
SFX_joy1trig:   .res 2
.endif
.if SFX_AUTOJOY & JOY2
SFX_joy2cont:   .res 2
SFX_joy2trig:   .res 2
.endif
.if SFX_AUTOJOY & JOY3
SFX_joy3cont:   .res 2
SFX_joy3trig:   .res 2
.endif
.if SFX_AUTOJOY & JOY4
SFX_joy4cont:   .res 2
SFX_joy4trig:   .res 2
.endif

;Reserve ZPAD (Zero page scratchpad)
.segment "ZPAD": zeropage
_ZPAD_:         .res __ZPADSIZE__

;Reserve ZNMI (Zero page scratchpad for usage inside NMI/VBlank interrupts)
.segment "ZNMI": zeropage
_ZNMI_:         .res __ZNMISIZE__

;Reserve RPAD (LORAM scratchpad)
.segment "LORAM"
_RPAD_:         .res __RPADSIZE__
