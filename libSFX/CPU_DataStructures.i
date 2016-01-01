; libSFX Data Structures Macros
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_CPU_DataStructures__
::__MBSFX_CPU_DataStructures__ = 1

;-------------------------------------------------------------------------------

/**
  FIFO_alloc
  Allocate static FIFO buffer

  Buffer is allocated in the LORAM segment by default.
  If <name> ends with a token named "hi" or "ex" ("midi1-hi" for example)
  the buffer is instead allocated in HIRAM or EXRAM respectively.


  :in:    name    Name                  symbol  value
  :in:    size    Capacity in bytes     uint8   value
*/
.macro FIFO_alloc name, size
.if (.blank({size}))
  SFX_error "FIFO_init: Missing required parameter(s)"
.else
  .pushseg
  .if .tcount({name}) > 1
    .if (.xmatch(.right(1,{name}), hi) .or .xmatch(.right(1,{name}), HI))
      .segment "HIRAM"
    .elseif (.xmatch(.right(1,{name}), ex) .or .xmatch(.right(1,{name}), EX))
      .segment "EXRAM"
    .else
      .segment "LORAM"
    .endif
  .else
    .segment "LORAM"
  .endif
  .ident(.concat("__FIFO__",.string(.left(1,{name})))): .res .loword(size)
  .ident(.concat("__FIFO_META__",.string(.left(1,{name})))): .res 2
  .popseg
.endif
.endmac

/**
  FIFO_write
  Write byte to FIFO buffer

  :in:    name    Name                  string  value
  :in:    data    Data                  uint8   a/x/y or value
*/
.macro FIFO_write name, data
.if (.blank({data}))
  SFX_error "FIFO_write: Missing required parameter(s)"
.else
          sta   .ident(.concat("__FIFO__",.string(.left(1,{name}))))
.endif
.endmac

/**
  FIFO_read
  Read byte from FIFO buffer

  :in:    name    Name                  string  value
  :in:    data    Data                  uint8   a/x/y or value
*/
.macro FIFO_read name, data
.if (.blank({data}))
  SFX_error "FIFO_read: Missing required parameter(s)"
.else
          lda   .ident(.concat("__FIFO__",.string(.left(1,{name}))))
.endif
.endmac

.endif
