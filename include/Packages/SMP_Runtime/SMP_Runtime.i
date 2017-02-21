; libSFX SMP Runtime Macros
; Kyle Swanson <k@ylo.ph>

.ifndef ::__MBSFX_SMP_Runtime_CPU__
::__MBSFX_SMP_Runtime_CPU__ = 1

/**
  Macro: SMP_Runtime_AsyncEvent
  Trigger an asynchronous SMP_Runtime event

  The value of `event_no' is passed to register `X' of the SPC-700.
  S-CPU is blocked until S-SMP acknowledges receipt of event.

  Parameters:
  >:in:    event_no   Value (uint8)       a
  >                                       constant (1-255)
*/
.macro SMP_Runtime_AsyncEvent event_no
        RW_push set:a8

  .if .not .xmatch({event_no}, {a})
    .if (event_no < 1 || event_no > 255)
      .error .sprintf("SMP_Runtime_AsyncEvent: Invalid event_no: `%d'.", event_no)
    .endif
        lda     #event_no
  .endif

        sta     SMPIO0
:       cmp     SMPIO0
        bne     :-
        stz     SMPIO0
        RW_pull
.endmacro

.endif;__MBSFX_SMP_Runtime_CPU__
