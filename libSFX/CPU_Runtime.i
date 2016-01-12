; libSFX S-CPU NMI/IRQ Vector Macros
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_CPU_Runtime__
::__MBSFX_CPU_Runtime__ = 1

;Default settings for joypad polling
.ifndef SFX_AUTOJOY
    SFX_AUTOJOY = ENABLE
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

.if SFX_AUTOJOY = ENABLE
.globalzp SFX_joy1cnt, SFX_joy1trg, SFX_joy2cnt, SFX_joy2trg
.endif

;-------------------------------------------------------------------------------
;Interrupt handler macros

/**
  VBL_set
  Set software vblank interrupt

  :in:    addr  Address       uint24  value
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
  VBL_clr
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
  VBL_on
  Enable vblank interrupt
*/
.macro  VBL_on
        RW_push set:a8
        lda     SFX_nmitimen
.if SFX_AUTOJOY = ENABLE
        ora     #NMI_NMI_ON + NMI_JOY_ON
.else
        ora     #NMI_NMI_ON
.endif
        sta     SFX_nmitimen
        sta     NMITIMEN
        RW_pull
.endmac

/**
  VBL_off
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
  IRQ_set
  Set software vertical line interrupt

  :in:    line  Trigger line  uint8   value
  :in?:   addr  Address       uint24  value (if omitted, last registered address remains)
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
  IRQ_on
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
  IRQ_off
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
  IRQ_suspend
  Suspend vertical line interrupt
*/
.macro  IRQ_suspend
        IRQ_off
        RW_push set:a8i16
        jsl     SFX_stash_nmi
        RW_pull
.endmac

/**
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
;Initialization

/**
  CPU_init
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
        phk                             ;If not HiROM: Set DB to fast mirror
        plb
  .endif
        WAIT_frames 2
        RW_pull
.endmac

/**
  REG_init
  Initialize PPU & CPU I/O registers
*/
.macro  REG_init
        RW_push set:a8i16
        jsl     SFX_INIT_mmio
        RW_pull
.endmac


.endif;__MBSFX_CPU_Runtime__
