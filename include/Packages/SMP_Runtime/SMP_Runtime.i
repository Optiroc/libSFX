; libSFX SMP Runtime Macros
; Kyle Swanson <k@ylo.ph>

.ifndef ::__MBSFX_SMP_Runtime_CPU__
::__MBSFX_SMP_Runtime_CPU__ = 1

/**
  Macro: SMP_Runtime_AsyncEvent
  Trigger an asynchronous SMP_Runtime event.
  The value of `event_no' is passed to register `X' of the SPC-700.

  Parameters:
  >:in:    event_no   Value (uint8)       constant (1-255)
*/
.macro SMP_Runtime_AsyncEvent event_no
        .if (event_no < 1 || event_no > 255)
        .error .sprintf("SMP_Runtime_AsyncEvent: Invalid event_no: `%d'.", event_no)
        .endif

        RW      a8
        lda     #event_no
        sta     SMPIO0
:       cmp     SMPIO0
        bne     :-
        lda     #$00
        sta     SMPIO0
        RW      a16
.endmacro

.endif;__MBSFX_SMP_Runtime_CPU__
