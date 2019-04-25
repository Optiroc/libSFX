; libSFX S-CPU NMI/IRQ Vector Macros
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_CPU_Runtime__
::__MBSFX_CPU_Runtime__ = 1

;-------------------------------------------------------------------------------
/**
  Group: libSFX zero-page variables
*/

/**
  Variable: SFX_inidisp
  INIDISP shadow variable (byte)

  SFX_inidisp is a shadow for the PPU INIDISP register at $2100. Writes to
  SFX_inidisp will be written to $2100 at the next vertical blanking interval.

  Example:
  (start code)
  ;Turn on screen
  lda          #inidisp(ON, DISP_BRIGHTNESS_MAX)
  sta          SFX_inidisp
  VBL_on
*/

/**
  Variable: SFX_nmitimen
  NMITIMEN shadow variable (byte)

  Shadow variable for the NMITIMEN register at $4200. Used by the various
  interrupt control macros to enable suspension and enabling of interrupts.
*/

/**
  Variable: SFX_tick
  Frame ticker (word)

  16 bit variable that is incremented by 1 during every vertical
  blanking interval.
*/

/**
  Variable: SFX_joy#cont
  Joypad continous read-out (word)

  If enabled with <SFX_JOY>, libSFX performs automatic joypad read-out and
  sets the 12 most significant bits in these variables to 1 continously as
  the corresponding joypad button is pushed.

  Depending on how many joypads are enabled for automatic read-out in
  libSFX.cfg, SFX_joy1cont to SFX_joy4cont are available.

  Description:
  (start code)
  Bit       Button
  15        B
  14        Y
  13        Select
  12        Start
  11        Up
  10        Down
  09        Left
  08        Right
  07        A
  06        X
  05        L
  04        R
  (end)
*/

.global Main, BootVector, VBlankVector, IRQVector, EmptyVector, EmptyVBlank
.global SFX_stash_nmi, SFX_restore_nmi
.global RPAD

.globalzp ZPAD, ZNMI
.globalzp SFX_nmi_jml, SFX_irq_jml, SFX_nmi_store, SFX_inidisp, SFX_nmitimen
.globalzp SFX_tick, SFX_mvn, SFX_mvn_dst, SFX_mvn_src


/**
  Variable: SFX_joy#trig
  Joypad trigger read-out (word)

  As opposed to SFX_joy#cont, the bits in SFX_joy#trig are only set for
  one frame as a joypad button is pushed.
*/
.if SFX_JOY & JOY1
.globalzp SFX_joy1cont, SFX_joy1trig
.endif
.if SFX_JOY & JOY2
.globalzp SFX_joy2cont, SFX_joy2trig
.endif
.if SFX_JOY & JOY3
.globalzp SFX_joy3cont, SFX_joy3trig
.endif
.if SFX_JOY & JOY4
.globalzp SFX_joy4cont, SFX_joy4trig
.endif

;-------------------------------------------------------------------------------
/**
  Group: Interrupt handling
*/

/**
  Macro: VBL_set
  Set software vblank interrupt

  Parameter:
  >:in:    addr      Address (uint24)        constant
*/
.macro  VBL_set addr
        RW_push set:a8i16
        ldx     #.loword(addr)
        stx     SFX_nmi_jml+1
        lda     #^addr
        sta     SFX_nmi_jml+3
        RW_pull
.endmac

/**
  Macro: VBL_clr
  Clear software vblank interrupt
*/
.macro  VBL_clr
        RW_push set:a8i16
        ldx     #.loword(EmptyVBlank)
        stx     SFX_nmi_jml+1
        lda     #^EmptyVBlank
        sta     SFX_nmi_jml+3
        RW_pull
.endmac

/**
  Macro: VBL_on
  Enable vblank interrupt
*/
.macro  VBL_on
        RW_push set:a8
        lda     SFX_nmitimen
.if ::SFX_AUTO_READOUT <> DISABLE
        ora     #NMI_NMI_ON + NMI_JOY_ON
.else
        ora     #NMI_NMI_ON
.endif
        sta     SFX_nmitimen
        sta     NMITIMEN
        RW_pull
.endmac

/**
  Macro: VBL_off
  Disable vblank interrupt
*/
.macro  VBL_off
        RW_push set:a8
        lda     SFX_nmitimen
        and     #NMI_NMI_MASK & NMI_JOY_MASK
        sta     SFX_nmitimen
        sta     NMITIMEN
        RW_pull
.endmac

/**
  Macro: IRQ_set
  Set software vertical line interrupt

  Parameters:
  >:in:    line      Trigger line (uint8)    constant
  >:in?:   addr      Address (uint24)        constant    If omitted, last registered address remains
*/
.macro  IRQ_set line, addr
        RW_push set:a8i16
.ifnblank addr
        ldx     #.loword(addr)
        lda     #^addr
        stx     SFX_irq_jml+1
        sta     SFX_irq_jml+3
.endif
        ldx     #line
        stx     VTIMEL
        RW_pull
.endmac

/**
  Macro: IRQ_on
  Enable vertical line interrupt
*/
.macro  IRQ_on
        RW_push set:a8
        lda     SFX_nmitimen
        and     #NMI_HV_TIMER_MASK
        ora     #NMI_V_TIMER_ON
        sta     SFX_nmitimen
        cli
        RW_pull
.endmac

/**
  Macro: IRQ_off
  Disable vertical line interrupt
*/
.macro  IRQ_off
        RW_push set:a8
        sei
        lda     SFX_nmitimen
        and     #NMI_HV_TIMER_MASK
        lda     SFX_nmitimen
        RW_pull
.endmac


/**
  Macro: IRQ_suspend
  Suspend vertical line interrupt
*/
.macro  IRQ_suspend
        IRQ_off
        RW_push set:a8i16
        jsl     SFX_stash_nmi
        RW_pull
.endmac

/**
  Macro: IRQ_release
  Release suspended vertical line interrupt
*/
.macro  IRQ_release
        RW_push set:a8i16
        jsl     SFX_restore_nmi
        RW_pull
        IRQ_on
.endmac

.macro  IRQ_suspend_hard
        IRQ_off
        VBL_off
.endmac

.macro  IRQ_release_hard
        VBL_on
        IRQ_on
.endmac


;-------------------------------------------------------------------------------
/**
  Group: System initialization
*/

/**
  Macro: CPU_init
  Initialize CPU state
*/
.macro  CPU_init
        RW_push set:a8
        lda     #MEM_358_MHZ            ;Set 3.58MHz access cycle
        sta     MEMSEL
        RW a16i16
        ldx     #$1fff                  ;Set stack at $1fff
        txs
        lda     #$0000                  ;Set direct page at $0000
        tcd
        RW a8
  .if ::ROM_MAPMODE <> 1
        phk                             ;If not Mode 21: Set DB to same as PC bank
        plb
  .else
        lda     #$80                    ;If Mode21: Set DB to $80
        pha
        plb
  .endif
        WAIT_frames 2                   ;Because N said so
        RW_pull
.endmac

/**
  Macro: REG_init
  Initialize PPU & CPU MMIO registers
*/
.macro  REG_init
        RW_push set:a8i16
        jsl     SFX_INIT_mmio
        RW_pull
.endmac


.endif;__MBSFX_CPU_Runtime__
