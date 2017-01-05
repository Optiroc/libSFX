; libSFX Data Structures Macros
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_CPU_DataStructures__
::__MBSFX_CPU_DataStructures__ = 1

;-------------------------------------------------------------------------------
/**
  Group: FIFO
*/

/**
  Macro: FIFO_alloc
  Allocate static FIFO (queue) buffer

  Buffer is allocated in the LORAM segment.
  Implemented as a circular buffer without overrun protection.

  Parameters:
  >:in:    name    Name                  identifier  Any string (without quotes)
  >:in:    size    Capacity in bytes     constant    Power of two integer up to 256 bytes

  Example:
  (begin code)
  FIFO_alloc    TestFIFO, 32

  FIFO_enq      TestFIFO, $f
  FIFO_enq      TestFIFO, $0
  lda           #$0
  FIFO_enq      TestFIFO, a
  lda           #$d
  FIFO_enq      TestFIFO, a

  FIFO_deq      TestFIFO           ;y = #$0f, z = 0
  FIFO_deq      TestFIFO, a        ;a = #$00, z = 0
  FIFO_deq      TestFIFO           ;y = #$00, z = 0
  FIFO_deq      TestFIFO           ;y = #$0d, z = 0
  FIFO_deq      TestFIFO           ;z = 1 -> Buffer empty
  (end)
*/
.macro FIFO_alloc name, size
.if .blank({size})
  SFX_error "FIFO_alloc: Missing required parameter(s)"
.elseif .not SFX_is_pot(size)
  SFX_error "FIFO_alloc: Size not power of two"
.else
  .export .ident(.concat("__FIFO__",.string(.left(1,{name})))): absolute
  .export .ident(.concat("__FIFO_META__",.string(.left(1,{name})))): absolute
  .export .ident(.concat("__FIFO_SIZE__",.string(.left(1,{name})))): absolute = size
  .export .ident(.concat("__FIFO_MASK__",.string(.left(1,{name})))): absolute = size-1
  .pushseg
  .segment "LORAM"
  .ident(.concat("__FIFO__",.string(.left(1,{name})))): .res .lobyte(size)
  .ident(.concat("__FIFO_META__",.string(.left(1,{name})))): .res 2
  .popseg
          RW_push set:a8i16
          stz   .ident(.concat("__FIFO_META__",.string(.left(1,{name}))))
          stz   .ident(.concat("__FIFO_META__",.string(.left(1,{name}))))+1
          RW_pull
.endif
.endmac


/**
  Macro: FIFO_enq
  Write (enqueue) byte to FIFO buffer

  Destroys a and x.

  Parameters:
  >:in:    name    Buffer name           identifier  Any string (without quotes)
  >:in:    data    Data (int8)           a           Enqueue value in accumulator
  >                                      constant    Enqueue assemble-time constant
*/
.macro FIFO_enq name, data
.if .blank({data})
  SFX_error "FIFO_enq: Missing required parameter(s)"
.else
  .if .not (.defined(.ident(.concat("__FIFO__",.string(.left(1,{name}))))))
    .import .ident(.concat("__FIFO__",.string(.left(1,{name})))): absolute
    .import .ident(.concat("__FIFO_META__",.string(.left(1,{name})))): absolute
    .import .ident(.concat("__FIFO_SIZE__",.string(.left(1,{name})))): absolute
    .import .ident(.concat("__FIFO_MASK__",.string(.left(1,{name})))): absolute
  .endif
          RW_push set:a8i8
  .if .not .xmatch({data}, {a})
          lda   #data
  .endif
          ldx   a:.ident(.concat("__FIFO_META__",.string(.left(1,{name}))))     ;x = head
          sta   a:.ident(.concat("__FIFO__",.string(.left(1,{name})))),x        ;buffer[head] = a
          txa                                                                   ;++head
          inc
          and   #<.ident(.concat("__FIFO_MASK__",.string(.left(1,{name}))))
          sta   a:.ident(.concat("__FIFO_META__",.string(.left(1,{name}))))
          RW_pull
.endif
.endmac


/**
  Macro: FIFO_deq
  Read (dequeue) byte from FIFO buffer

  Value is returned in 'outreg' (default y), z = 0.
  If queue is empty z = 1.

  Destroys a and x or y.

  Parameters:
  >:in:    name    Buffer name           identifier  Any string (without quotes)
  >:out?:  outreg  Return register       identifier  y/x/a
*/
.macro FIFO_deq name, outreg
.if .blank({name})
  SFX_error "FIFO_read: Missing required parameter(s)"
.else
  .if .not (.defined(.ident(.concat("__FIFO__",.string(.left(1,{name}))))))
    .import .ident(.concat("__FIFO__",.string(.left(1,{name})))): absolute
    .import .ident(.concat("__FIFO_META__",.string(.left(1,{name})))): absolute
    .import .ident(.concat("__FIFO_SIZE__",.string(.left(1,{name})))): absolute
    .import .ident(.concat("__FIFO_MASK__",.string(.left(1,{name})))): absolute
  .endif
          RW_push set:a8i8
  .if .xmatch({outreg}, {a})
          ldx   a:.ident(.concat("__FIFO_META__",.string(.left(1,{name}))))+1   ;x = tail
          cpx   a:.ident(.concat("__FIFO_META__",.string(.left(1,{name}))))     ;if tail == head
          beq   :+                                                              ;  return (z = 1)
  .elseif .xmatch({outreg}, {x})
          ldy   a:.ident(.concat("__FIFO_META__",.string(.left(1,{name}))))+1
          cpy   a:.ident(.concat("__FIFO_META__",.string(.left(1,{name}))))
          beq   :+
  .else
          ldx   a:.ident(.concat("__FIFO_META__",.string(.left(1,{name}))))+1
          cpx   a:.ident(.concat("__FIFO_META__",.string(.left(1,{name}))))
          beq   :+
  .endif
  .if .xmatch({outreg}, {a})
          lda   a:.ident(.concat("__FIFO__",.string(.left(1,{name})))),x        ;a = buffer[tail]
          xba                                                                   ;stash value
          txa
  .elseif .xmatch({outreg}, {x})
          ldx   a:.ident(.concat("__FIFO__",.string(.left(1,{name})))),y        ;x = buffer[tail]
          tya
  .else
          ldy   a:.ident(.concat("__FIFO__",.string(.left(1,{name})))),x        ;y = buffer[tail]
          txa
  .endif
          inc                                                                   ;++tail
          and   #<.ident(.concat("__FIFO_MASK__",.string(.left(1,{name}))))
          sta   a:.ident(.concat("__FIFO_META__",.string(.left(1,{name}))))+1
  .if .xmatch({outreg}, {a})
          xba                                                                   ;restore value
  .endif
          rep   #$02                                                            ;z = 0
:         RW_pull
.endif
.endmac

;-------------------------------------------------------------------------------
/**
  Group: FILO
*/

/**
  Macro: FILO_alloc
  Allocate static FILO (stack) buffer

  Buffer is allocated in the LORAM segment.
  No overflow protection.

  Parameters:
  >:in:    name    Name                  identifier  Any string (without quotes)
  >:in:    size    Capacity in bytes     constant    Power of two integer up to 256 bytes

  Example:
  (begin code)
  FILO_alloc  TestFILO, 32

  FILO_push   TestFILO, $b
  FILO_push   TestFILO, $e
  lda         #$e
  FILO_push   TestFILO, a
  lda         #$f
  FILO_push   TestFILO, a

  FILO_pop    TestFILO            ;y = #$0f, z = 0
  FILO_pop    TestFILO, a         ;a = #$0e, z = 0
  FILO_pop    TestFILO            ;y = #$0e, z = 0
  FILO_pop    TestFILO            ;y = #$0b, z = 0
  FILO_pop    TestFILO            ;z = 1 -> Buffer empty
  (end)
*/
.macro FILO_alloc name, size
.if .blank({size})
  SFX_error "FILO_alloc: Missing required parameter(s)"
.elseif .not SFX_is_pot(size)
  SFX_error "FILO_alloc: Size not power of two"
.else
  .export .ident(.concat("__FILO__",.string(.left(1,{name})))): absolute
  .export .ident(.concat("__FILO_TOP__",.string(.left(1,{name})))): absolute
  .export .ident(.concat("__FILO_SIZE__",.string(.left(1,{name})))): absolute = size
  .export .ident(.concat("__FILO_MASK__",.string(.left(1,{name})))): absolute = size-1
  .pushseg
  .segment "LORAM"
  .ident(.concat("__FILO__",.string(.left(1,{name})))): .res .lobyte(size)
  .ident(.concat("__FILO_TOP__",.string(.left(1,{name})))): .res 1
  .popseg
          RW_push set:a8i16
          stz   .ident(.concat("__FILO_TOP__",.string(.left(1,{name}))))
          RW_pull
.endif
.endmac


/**
  Macro: FILO_push
  Write byte to FILO buffer

  Destroys x.

  Parameters:
  >:in:    name    Buffer name           identifier  Any string (without quotes)
  >:in:    data    Data (int8)           a           Push value in accumulator
  >                                      constant    Push assemble-time constant
*/
.macro FILO_push name, data
.if .blank({data})
  SFX_error "FILO_write: Missing required parameter(s)"
.else
  .if .not (.defined(.ident(.concat("__FILO__",.string(.left(1,{name}))))))
    .import .ident(.concat("__FILO__",.string(.left(1,{name})))): absolute
    .import .ident(.concat("__FILO_TOP__",.string(.left(1,{name})))): absolute
    .import .ident(.concat("__FILO_SIZE__",.string(.left(1,{name})))): absolute
    .import .ident(.concat("__FILO_MASK__",.string(.left(1,{name})))): absolute
  .endif
          RW_push set:a8i8
  .if .not (.xmatch({data}, {a}))
          lda   #data
  .endif
          ldx   a:.ident(.concat("__FILO_TOP__",.string(.left(1,{name}))))
          sta   a:.ident(.concat("__FILO__",.string(.left(1,{name})))),x
          inx
          stx   a:.ident(.concat("__FILO_TOP__",.string(.left(1,{name}))))
  ;Wasting cycles on overflow protection seems moot, maybe include optionally?
          ;txa
          ;inc
          ;and   #<.ident(.concat("__FILO_MASK__",.string(.left(1,{name}))))
          ;sta   a:.ident(.concat("__FILO_TOP__",.string(.left(1,{name}))))
          RW_pull
.endif
.endmac


/**
  Macro: FILO_pop
  Read byte from FILO buffer

  Value is returned in 'outreg' (default y), z = 0.
  If stack is empty z = 1.

  Destroys a and x or y.

  Parameters:
  >:in:    name    Buffer name           identifier  Any string (without quotes)
  >:out?:  outreg  Return register       identifier  y/x/a
*/
.macro FILO_pop name, outreg
.if .blank({name})
  SFX_error "FILO_pop: Missing required parameter(s)"
.else
  .if .not (.defined(.ident(.concat("__FILO__",.string(.left(1,{name}))))))
    .import .ident(.concat("__FILO__",.string(.left(1,{name})))): absolute
    .import .ident(.concat("__FILO_TOP__",.string(.left(1,{name})))): absolute
    .import .ident(.concat("__FILO_SIZE__",.string(.left(1,{name})))): absolute
    .import .ident(.concat("__FILO_MASK__",.string(.left(1,{name})))): absolute
  .endif
          RW_push set:a8i8
  .if .xmatch({outreg}, {a})
          ldx   a:.ident(.concat("__FILO_TOP__",.string(.left(1,{name}))))      ;if (top == 0)
          beq   :+                                                              ;  return (z = 1)
  .elseif .xmatch({outreg}, {x})
          ldy   a:.ident(.concat("__FILO_TOP__",.string(.left(1,{name}))))      ;if (top == 0)
          beq   :+                                                              ;  return (z = 1)
  .else
          ldx   a:.ident(.concat("__FILO_TOP__",.string(.left(1,{name}))))      ;if (top == 0)
          beq   :+                                                              ;  return (z = 1)
  .endif
  .if .xmatch({outreg}, {a})
          lda   a:.ident(.concat("__FILO__",.string(.left(1,{name}))))-1,x
          dex
          stx   a:.ident(.concat("__FILO_TOP__",.string(.left(1,{name}))))
  .elseif .xmatch({outreg}, {x})
          ldx   a:.ident(.concat("__FILO__",.string(.left(1,{name}))))-1,y
          dey
          sty   a:.ident(.concat("__FILO_TOP__",.string(.left(1,{name}))))
  .else
          ldy   a:.ident(.concat("__FILO__",.string(.left(1,{name}))))-1,x
          dex
          stx   a:.ident(.concat("__FILO_TOP__",.string(.left(1,{name}))))
  .endif
          rep   #$02                                                            ;z = 0
:         RW_pull
.endif
.endmac


.define SFX_is_pot(n) ((n = 2) || (n = 4) || (n = 8) || (n = 16) || (n = 32) || (n = 64) || (n = 128) || (n = 256))


.endif ;__MBSFX_CPU_DataStructures__
