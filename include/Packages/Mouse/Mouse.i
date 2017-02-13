; libSFX Super Nintendo SFM1 Mouse Support
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_MOUSE__
::__MBSFX_MOUSE__ = 1

.ifndef SFX_MOUSE
    SFX_MOUSE = MOUSE1
.endif

.if SFX_JOY <> DISABLE
  .if (SFX_JOY < 0) || (SFX_JOY > (JOY1 | JOY2))
      SFX_error "SFX_JOY: Bad configuration (only JOY1 and JOY2 is supported in conjunction with the mouse driver)"
  .endif
.endif

.if SFX_AUTO_READOUT = DISABLE
  SFX_error "SFX_AUTO_READOUT: Bad configuration (the mouse driver relies on automatic read-out)"
.endif

.ifndef MOUSE_cursor_x_min
.define MOUSE_cursor_x_min $0000
.endif
.ifndef MOUSE_cursor_x_max
.define MOUSE_cursor_x_max $00f4
.endif
.ifndef MOUSE_cursor_y_min
.define MOUSE_cursor_y_min $0000
.endif
.ifndef MOUSE_cursor_y_max
.define MOUSE_cursor_y_max $00d6
.endif

.define MOUSE_sensitivity_slow    0
.define MOUSE_sensitivity_normal  1
.define MOUSE_sensitivity_fast    2

.define MOUSE_status_nc         $00
.define MOUSE_status_ok         $01
.define MOUSE_status_error      $80

.struct MOUSE_data
        status          .byte
        sensitivity     .byte
        buttons_cont    .byte
        buttons_trig    .byte
        delta_x         .byte
        delta_y         .byte
        cursor_x        .word
        cursor_y        .word
.endstruct

.global SFX_MOUSE_nmi_hook

.if SFX_MOUSE & MOUSE1
  .globalzp SFX_mouse1
.endif
.if SFX_MOUSE & MOUSE2
  .globalzp SFX_mouse2
.endif

;-------------------------------------------------------------------------------
/**
  Group: Mouse
  Optional package adding SNES SFM1 Mouse support

  To link mouse support in a project, simply add Mouse to libsfx_packages in
  the project makefile.

  Makefile:
  (start code)
  # Use packages
  libsfx_packages := Mouse
  (end)

  The mouse package adds mouse polling to the regular automatic joypad polling.
  By default the driver will look for a mouse in port 1. This is configurable
  with the SFX_MOUSE variable∶

  libSFX.cfg:
  (start code)
  SFX_MOUSE = MOUSE1 | MOUSE2
  (end)

  Mouse read-out data is stored in MOUSE_data structs with the following members∶

  (start code)
  .struct MOUSE_data
      status          .byte
      sensitivity     .byte
      buttons_cont    .byte
      buttons_trig    .byte
      delta_x         .byte
      delta_y         .byte
      cursor_x        .word
      cursor_y        .word
  .endstruct

  Possible status values:
  .define MOUSE_status_nc         $00 ;Mouse not connected
  .define MOUSE_status_ok         $01 ;Mouse connected and working
  .define MOUSE_status_error      $80 ;Hardware error

  Button presses are stored in the follwing bits of buttons_cont/buttons_trig:
  Bit
  7         Right button
  6         Left button
  (end)

  The driver updates all members during each VBlank interval at zero page
  locations SFX_mouse1 and SFX_mouse2. The data can be addressed like this∶

  (start code)
  ;Load cursor vertical position
  lda     z:SFX_mouse1+MOUSE_data::cursor_y
  (end)

  The 'sensitivity' member is used to set the mouse acceleration curve.

  (start code)
  ;Set normal mouse sensitivty
  lda     #MOUSE_sensitivity_normal
  sta     SFX_mouse1+MOUSE_data::sensitivity

  ;Possible values
  .define MOUSE_sensitivity_slow    0
  .define MOUSE_sensitivity_normal  1
  .define MOUSE_sensitivity_fast    2
  (end)

  All other members are read-only.

  If no mouse is detected and SFX_JOY is set for the port, the driver
  automatically falls back to joypad input. D-pad input is then mapped to
  delta and cursor, and the A/X buttons is mapped to the left/right buttons.

  The driver can optionally be "hugged" by special strings that – I suppose – some
  emulators rely on to automatically enable mouse input. Real hardware (and
  consequently, real emulators) doesn't care.

  libSFX.cfg:
  (start code)
  SFX_MOUSE_STRINGS = ENABLE
  (end)
*/

.endif;__MBSFX_MOUSE__
