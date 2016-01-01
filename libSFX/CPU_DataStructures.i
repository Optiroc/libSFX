; libSFX Data Structures Macros
; David Lindecrantz <optiroc@gmail.com>

.ifndef ::__MBSFX_CPU_DataStructures__
::__MBSFX_CPU_DataStructures__ = 1

;-------------------------------------------------------------------------------

/**
  FIFO_alloc
  Allocate FIFO buffer

  :in:    name    Name                  string  value
  :in:    size    Capacity in bytes     uint16  value
  :in?:   memtype Memory type           ident   loram (default), zeropage, hiram, exram
*/
.macro FIFO_alloc name, size, memtype
.if (.blank({size}))
  SFX_error "FIFO_init: Missing required parameter(s)"
.else
  .pushseg
  .if .xmatch({memtype},{zeropage})
    .segment "ZEROPAGE"
  .elseif .xmatch({memtype},{hiram})
    .segment "HIRAM"
  .elseif .xmatch({memtype},{exram})
    .segment "EXRAM"
  .else
    .segment "LORAM"
  .endif
  .ident (.concat("__FIFO__", name)): .res .loword(size)
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
          lda   .ident (.concat("__FIFO__", name))
.endif
.endmac

.endif
