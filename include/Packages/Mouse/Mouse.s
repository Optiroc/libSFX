; libSFX Super Nintendo Mouse Driver
; David Lindecrantz <optiroc@gmail.com>

.include "../../libSFX.i"
.segment "LIBSFX_PKG"

;-------------------------------------------------------------------------------
;Scratch pad usage
.define ZP_reg      ZNMI+$00 ;Read-out register (indirect)   (word)
.define ZP_value    ZNMI+$02 ;Stashed auto joypad readout    (byte)
.define ZP_dir_x    ZNMI+$03 ;X direction                    (byte)
.define ZP_dir_y    ZNMI+$04 ;Y direction                    (byte)
.define ZP_sens     ZNMI+$05 ;Sensitivity                    (byte)

;-------------------------------------------------------------------------------
.ifdef SFX_MOUSE_STRINGS
  .byte "START OF MOUSE BIOS"
.endif

SFX_MOUSE_nmi_hook:
        RW_assume a8i16
        RW a8i8

:       lda     HVBJOY                  ;Wait for joypad read-out
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

  .if SFX_JOY & JOY1
        lda     a:SFX_mouse1            ;If joypad #1 read-out is enabled
        bne     @mouse1_connected       ;perform read-out if SFX_mouse1::status == not connected

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
        sta     z:SFX_mouse1+MOUSE_data::buttons_trig
        lda     z:SFX_joy1cont
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

  .if SFX_JOY & JOY2
        lda     a:SFX_mouse2            ;If joypad #2 read-out is enabled
        bne     @mouse2_connected       ;perform read-out if SFX_mouse1::status == not connected

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
        sta     z:SFX_mouse2+MOUSE_data::buttons_trig
        lda     z:SFX_joy2cont
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

        sta     z:ZP_value                      ;Stash MSB of automatic read-out
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

        ldy     z:MOUSE_data::buttons_cont,x    ;Set button bits
        lda     z:ZP_value
        and     #$c0
        sta     z:MOUSE_data::buttons_cont,x
        tya
        eor     z:MOUSE_data::buttons_cont,x
        and     z:MOUSE_data::buttons_cont,x
        sta     z:MOUSE_data::buttons_trig,x

        rts

;-------------------------------------------------------------------------------
set_sensitivity:
        lda     #$10
        sta     z:ZP_value+1
@loop:
        lda     #$01                             ;Strobe joypad register
        sta     JOYA
        lda     (ZP_reg)
        stz     JOYA
        lda     #$01
        sta     JOYA
        stz     JOYA

        stz     z:ZP_sens                       ;Clear
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

        lda     z:ZP_sens                       ;Is read-out matching setting?
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
        cmp     #MOUSE_cursor_x_min
        bpl     :+
        lda     #MOUSE_cursor_x_min
:       sta     z:MOUSE_data::cursor_x,x
        RW a8
        bra     cursor_y
plus_x:
        xba                                     ;Positive delta
        lda     #$00                            ;Sign extend
        xba
        RW a16
        add     z:MOUSE_data::cursor_x,x        ;Add and clamp
        cmp     #MOUSE_cursor_x_max
        bcc     :+
        lda     #MOUSE_cursor_x_max
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
        cmp     #MOUSE_cursor_y_min
        bpl     :+
        lda     #MOUSE_cursor_y_min
:       sta     z:MOUSE_data::cursor_y,x
        RW a8
        bra     cursor_done
plus_y:
        xba                                     ;Positive delta
        lda     #$00                            ;Sign extend
        xba
        RW a16
        add     z:MOUSE_data::cursor_y,x        ;Add and clamp
        cmp     #MOUSE_cursor_y_max
        bcc     :+
        lda     #MOUSE_cursor_y_max
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
