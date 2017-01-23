; libSFX Super Nintendo Mouse Driver
; David Lindecrantz <optiroc@gmail.com>

.include "../../libSFX.i"
.segment "LIBSFX_PKG"

;-------------------------------------------------------------------------------
.define CURSOR_MIN_X $0000
.define CURSOR_MAX_X $00f4
.define CURSOR_MIN_Y $0000
.define CURSOR_MAX_Y $00d6

;Scratch pad usage
.define ZP_reg     _ZNMI_+$00   ;Readout register (indirect)    (word)
.define ZP_value   _ZNMI_+$02   ;Stashed auto joypad readout    (byte)
.define ZP_dir_x   _ZNMI_+$03   ;X direction                    (byte)
.define ZP_dir_y   _ZNMI_+$04   ;Y direction                    (byte)
.define ZP_sens    _ZNMI_+$05   ;Sensitivity                    (byte)

;-------------------------------------------------------------------------------
.ifdef SFX_MOUSE_STRINGS
  .byte "START OF MOUSE BIOS"
.endif

SFX_MOUSE_nmi_hook:
        RW_assume a8i16
        RW a8i8

:       lda     HVBJOY                  ;Wait for joypad readout
        and     #1
        bne     :-

.if SFX_MOUSE & MOUSE1
        ldx     #SFX_mouse1             ;Read mouse in port 1
        lda     #<JOYA
        sta     z:ZP_reg
        lda     #>JOYA
        sta     z:ZP_reg+1
        lda     JOY1L
        jsr     read_mouse

  .if SFX_AUTOJOY & JOY1
        lda     a:SFX_mouse1            ;If joypad #1 readout is enabled
        bne     @mouse1_connected       ;perform readout if SFX_mouse1::status == not connected

        RW      a16i16
        ldx     z:SFX_joy1cont
        lda     JOY1L
        sta     z:SFX_joy1cont
        txa
        eor     z:SFX_joy1cont
        and     z:SFX_joy1cont
        sta     z:SFX_joy1trig
        RW      a8i8

        xba                             ;Copy buttons A/X -> left/right
        and     #%11000000
        sta     z:SFX_mouse1+MOUSE_data::buttons_trig
        lda     z:SFX_joy1cont
        and     #%11000000
        sta     z:SFX_mouse1+MOUSE_data::buttons_cont

        lda     z:SFX_joy1cont+1         ;Set mouse deltas (TODO: Acceleration?)
        and     #%00000011               ;Left/right
        beq     @joy1_no_x
        and     #%00000010
        bne     :+
        ldy     #$02                     ;Right
        bra     @joy1_set_x
:       ldy     #$fe                     ;Left
        bra     @joy1_set_x
@joy1_no_x:
        ldy     #0
@joy1_set_x:
        sty     z:SFX_mouse1+MOUSE_data::delta_x

        lda     z:SFX_joy1cont+1
        and     #%00001100               ;Up/down
        beq     @joy1_no_y
        and     #%00001000
        bne     :+
        ldy     #$02                     ;Down
        bra     @joy1_set_y
:       ldy     #$fe                     ;Up
        bra     @joy1_set_y
@joy1_no_y:
        ldy     #0
@joy1_set_y:
        sty     z:SFX_mouse1+MOUSE_data::delta_y

@mouse1_connected:
  .endif

        ldx     #SFX_mouse1
        jsr     set_cursor
.endif


.if SFX_MOUSE & MOUSE2
        ldx     #SFX_mouse2             ;Read mouse in port 2
        lda     #<JOYB
        sta     z:ZP_reg
        lda     #>JOYB
        sta     z:ZP_reg+1
        lda     JOY2L
        jsr     read_mouse

  .if SFX_AUTOJOY & JOY2
        lda     a:SFX_mouse2            ;If joypad #2 readout is enabled
        bne     @mouse2_connected       ;perform readout if SFX_mouse1::status == not connected

        RW      a16i16
        ldx     z:SFX_joy2cont
        lda     JOY2L
        sta     z:SFX_joy2cont
        txa
        eor     z:SFX_joy2cont
        and     z:SFX_joy2cont
        sta     z:SFX_joy2trig
        RW      a8i8

        xba                             ;Copy buttons A/X -> left/right
        and     #%11000000
        sta     z:SFX_mouse2+MOUSE_data::buttons_trig
        lda     z:SFX_joy2cont
        and     #%11000000
        sta     z:SFX_mouse2+MOUSE_data::buttons_cont

        lda     z:SFX_joy2cont+1         ;Set mouse deltas
        and     #%00000011               ;Left/right
        beq     @joy2_no_x
        and     #%00000010
        bne     :+
        ldy     #$02                     ;Right
        bra     @joy2_set_x
:       ldy     #$fe                     ;Left
        bra     @joy2_set_x
@joy2_no_x:
        ldy     #0
@joy2_set_x:
        sty     z:SFX_mouse2+MOUSE_data::delta_x

        lda     z:SFX_joy2cont+1
        and     #%00001100               ;Up/down
        beq     @joy2_no_y
        and     #%00001000
        bne     :+
        ldy     #$02                     ;Down
        bra     @joy2_set_y
:       ldy     #$fe                     ;Up
        bra     @joy2_set_y
@joy2_no_y:
        ldy     #0
@joy2_set_y:
        sty     z:SFX_mouse2+MOUSE_data::delta_y

@mouse2_connected:
  .endif

        ldx     #SFX_mouse2
        jsr     set_cursor
.endif

        RW a8i16
        rtl

;-------------------------------------------------------------------------------
read_mouse:
        RW_assume a8i8

        sta     z:ZP_value                      ;Stash MSB of automatic readout
        and     #$0f                            ;Check device signature
        cmp     #1
        beq     connected

not_connected:
        RW a16
        stz     z:MOUSE_data::status,x
        stz     z:MOUSE_data::buttons_cont,x
        stz     z:MOUSE_data::delta_x,x
        RW a8
        rts

connected:
        lda     z:MOUSE_data::status,x          ;If previous status == not connected -> set sensitivity
        beq     set_sensitivity

        lda     ZP_value                        ;If reported sensitivity != setting -> set sensitivity
        ror
        ror
        ror
        ror
        and     #$03
        cmp     z:MOUSE_data::sensitivity,x
        bne     set_sensitivity

;-------------------------------------------------------------------------------
read_bits:
        ldy     #8                              ;Shift in 8 bits of y displacement
:       lda     (ZP_reg)
        lsr
        rol     z:ZP_dir_y
        dey
        bne     :-

        ldy     #8                              ;Shift in 8 bits of x displacement
:       lda     (ZP_reg)
        lsr
        rol     z:ZP_dir_x
        dey
        bne     :-

        lda     z:ZP_dir_x                      ;Calculate X delta and position
        bpl     :+
        and     #$7f
        neg
:       sta     z:MOUSE_data::delta_x,x

        lda     z:ZP_dir_y                      ;Calculate Y delta and position
        bpl     :+
        and     #$7f
        neg
:       sta     z:MOUSE_data::delta_y,x


        lda     z:ZP_value                      ;Set button bits
        and     #$c0
        tay
        eor     z:MOUSE_data::buttons_cont,x
        sta     z:MOUSE_data::buttons_trig,x
        tya
        and     z:MOUSE_data::buttons_trig,x
        sta     z:MOUSE_data::buttons_trig,x
        sty     z:MOUSE_data::buttons_cont,x

        rts

;-------------------------------------------------------------------------------
set_sensitivity:
        lda     #$10
        sta     z:ZP_value+1
@loop:
        lda     #$01
        sta     JOYA
        lda     (ZP_reg)
        stz     JOYA

        lda     #$01                            ;Strobe joypad register
        sta     JOYA
        lda     #$00
        sta     JOYA            ;stz instead..?

        sta     z:ZP_sens                       ;Clear
        ldy     #10                             ;Skip to sensitivity bits
:       lda     (ZP_reg)
        dey
        bne     :-

        lda     (ZP_reg)                        ;Sensitivity bit 0
        lsr
        rol     z:ZP_sens

        lda     (ZP_reg)                        ;Sensitivity bit 1
        lsr
        rol     z:ZP_sens

        lda     z:ZP_sens                       ;Is readout matching setting?
        cmp     z:MOUSE_data::sensitivity,x
        beq     @done

        dec     z:ZP_value+1
        bne     @loop

        lda     #MOUSE_status_error             ;Error
        sta     z:MOUSE_data::status,x
        rts

@done:
        lda     #MOUSE_status_ok
        sta     z:MOUSE_data::status,x
        rts

;-------------------------------------------------------------------------------
set_cursor:
        RW_assume a8i8

        lda     z:MOUSE_data::delta_x,x
        beq     cursor_y
        bpl     plus_x

        xba                                     ;Negative delta
        lda     #$ff                            ;Sign extend
        xba
        RW a16
        add     z:MOUSE_data::cursor_x,x        ;Add and clamp
        cmp     #CURSOR_MIN_X
        bpl     :+
        lda     #CURSOR_MIN_X
:       sta     z:MOUSE_data::cursor_x,x
        RW a8
        bra     cursor_y
plus_x:
        xba                                     ;Positive delta
        lda     #$00                            ;Sign extend
        xba
        RW a16
        add     z:MOUSE_data::cursor_x,x        ;Add and clamp
        cmp     #CURSOR_MAX_X
        bcc     :+
        lda     #CURSOR_MAX_X
:       sta     z:MOUSE_data::cursor_x,x
        RW a8

cursor_y:
        lda     z:MOUSE_data::delta_y,x
        beq     cursor_done
        bpl     plus_y

        xba                                     ;Negative delta
        lda     #$ff                            ;Sign extend
        xba
        RW a16
        add     z:MOUSE_data::cursor_y,x        ;Add and clamp
        cmp     #CURSOR_MIN_Y
        bpl     :+
        lda     #CURSOR_MIN_Y
:       sta     z:MOUSE_data::cursor_y,x
        RW a8
        bra     cursor_done
plus_y:
        xba                                     ;Positive delta
        lda     #$00                            ;Sign extend
        xba
        RW a16
        add     z:MOUSE_data::cursor_y,x        ;Add and clamp
        cmp     #CURSOR_MAX_Y
        bcc     :+
        lda     #CURSOR_MAX_Y
:       sta     z:MOUSE_data::cursor_y,x
        RW a8

cursor_done:
        rts

.ifdef SFX_MOUSE_STRINGS
  .byte "SHVC MOUSE BIOS Ver1.10SFX "
  .byte "END OF MOUSE BIOS"
.endif

;-------------------------------------------------------------------------------
.segment "ZEROPAGE": zeropage

.if SFX_MOUSE & MOUSE1
SFX_mouse1:     .tag MOUSE_data
.endif
.if SFX_MOUSE & MOUSE2
SFX_mouse2:     .tag MOUSE_data
.endif
