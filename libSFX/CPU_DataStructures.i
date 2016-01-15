; libSFX Data Structures Macros
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_CPU_DataStructures__
::__MBSFX_CPU_DataStructures__ = 1

;-------------------------------------------------------------------------------

/**
  FIFO_alloc
  Allocate static FIFO buffer

  Buffer is allocated in the LORAM segment.
  Size must be a power of two value up to 256 bytes.

  :in:    name    Name                  string  value
  :in:    size    Capacity in bytes     uint8   value
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
  FIFO_enq
  Write (enqueue) byte to FIFO buffer

  :in:    name    Buffer name           string  value
  :in:    data    Value to put          uint8   a or constant
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
  .if .not (.xmatch({data}, {a}))
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
  FIFO_deq
  Read (dequeue) byte from FIFO buffer

  Value is returned in register a with z = 0.
  If queue is empty a is untouched and z = 1.

  :in:    name    Buffer name           string  value
*/
.macro FIFO_deq name
.if .blank({data})
  SFX_error "FIFO_read: Missing required parameter(s)"
.else
  .if .not (.defined(.ident(.concat("__FIFO__",.string(.left(1,{name}))))))
    .import .ident(.concat("__FIFO__",.string(.left(1,{name})))): absolute
    .import .ident(.concat("__FIFO_META__",.string(.left(1,{name})))): absolute
    .import .ident(.concat("__FIFO_SIZE__",.string(.left(1,{name})))): absolute
    .import .ident(.concat("__FIFO_MASK__",.string(.left(1,{name})))): absolute
  .endif
          RW_push set:a8i8
          ldx   a:.ident(.concat("__FIFO_META__",.string(.left(1,{name}))))+1   ;x = tail
          cpx   a:.ident(.concat("__FIFO_META__",.string(.left(1,{name}))))     ;if tail == head
          beq   :+                                                              ;  return (z = 1)
          lda   a:.ident(.concat("__FIFO__",.string(.left(1,{name})))),x        ;a = buffer[tail]
          xba                                                                   ;stash value
          txa                                                                   ;++tail
          inc
          and   #<.ident(.concat("__FIFO_MASK__",.string(.left(1,{name}))))
          sta   a:.ident(.concat("__FIFO_META__",.string(.left(1,{name}))))+1
          xba                                                                   ;restore value
          rep   #$02                                                            ;z = 0
:         RW_pull
.endif
.endmac


/**
  FILO_alloc
  Allocate static FILO (stack) buffer

  Buffer is allocated in the LORAM segment. Max capacity is #$ff bytes.

  :in:    name    Name                  string  value
  :in:    size    Capacity in bytes     uint8   value
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
  FILO_push
  Write byte to FILO buffer

  :in:    name    Buffer name           string  value
  :in:    value   Value to push         uint8   a or constant
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
          txa
          inc
          and   #<.ident(.concat("__FILO_MASK__",.string(.left(1,{name}))))
          sta   a:.ident(.concat("__FILO_TOP__",.string(.left(1,{name}))))
          RW_pull
.endif
.endmac

/**
  FILO_pop
  Read byte from FILO buffer

  Value is returned in register a with z = 0.
  If empty stack z = 1.

  :in:    name    Buffer name           string  value
*/
.macro FILO_pop name
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
          ldx   a:.ident(.concat("__FILO_TOP__",.string(.left(1,{name}))))
          beq   :+                                                              ;  return (z = 1)
          lda   a:.ident(.concat("__FILO__",.string(.left(1,{name}))))-1,x
          xba
          txa
          dec
          sta   a:.ident(.concat("__FILO_TOP__",.string(.left(1,{name}))))
          xba
          rep   #$02                                                            ;z = 0
:         RW_pull
.endif
.endmac


.define SFX_is_pot(n) ((n = 2) || (n = 4) || (n = 8) || (n = 16) || (n = 32) || (n = 64) || (n = 128) || (n = 256))


.endif ;__MBSFX_CPU_DataStructures__
