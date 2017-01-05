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
  Variable: SFX_joy#cnt
  Joypad continous readout (word)

  If so configured, libSFX enables automatic joypad readout and sets
  the 12 most significant bits in these variables continously as the
  joypad buttons are pushed.

  Depending on how many joypads are enabled for automatic readout in
  libSFX.cfg, SFX_joy1cnt to SFX_joy4cnt are available.

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

/**
  Variable: SFX_joy#trg
  Joypad trigger readout (word)

  As opposed to SFX_joy#cnt, the bits in SFX_joy#trg are only set for
  one frame as a joypad button is pushed.
*/

;Default settings for joypad polling
.ifndef SFX_AUTOJOY
    SFX_AUTOJOY = JOY1 | JOY2
.endif

.if (SFX_AUTOJOY < 0) || (SFX_AUTOJOY > (JOY1 | JOY2 | JOY3 | JOY4))
    SFX_error "SFX_AUTOJOY: Bad configuration"
.endif

.ifndef SFX_AUTOJOY_FIRST
    SFX_AUTOJOY_FIRST = NO
.endif

.global Main, BootVector, VBlankVector, IRQVector, EmptyVector, EmptyVBlank
.global SFX_stash_nmi, SFX_restore_nmi

.globalzp _ZPAD_
.globalzp SFX_nmi_jml, SFX_irq_jml, SFX_nmi_store, SFX_inidisp, SFX_nmitimen
.globalzp SFX_tick, SFX_jml, SFX_addr, SFX_word
.globalzp SFX_mvn, SFX_mvn_dst, SFX_mvn_src

.if SFX_AUTOJOY & JOY1
.globalzp SFX_joy1cnt, SFX_joy1trg
.endif
.if SFX_AUTOJOY & JOY2
.globalzp SFX_joy2cnt, SFX_joy2trg
.endif
.if SFX_AUTOJOY & JOY3
.globalzp SFX_joy3cnt, SFX_joy3tr
.endif
.if SFX_AUTOJOY & JOY4
.globalzp SFX_joy3cnt, SFX_joy3tr
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
.if SFX_AUTOJOY <> DISABLE
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
  .if ROM_MAPMODE <> 1
        phk                             ;If not Mode 21 (HiROM): Set DB to fast mirror
        plb
  .endif
        WAIT_frames 2
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
