.ifndef ::__SNIPPETS_OAM__
::__SNIPPETS_OAM__ = 1

/**
  OAM_set
  Set values for OAM entry in RAM

  NB! It's very inefficient to set OAM entries one by one like this.
      Only viable for simple proof of concept scenarios.

  Parameters:
  >:in:    xpos      X position (9 bits)           x
  >:in:    ypos      Y position (8 bits)           a
  >:in:    tile      Tile index (9 bits)           y
  >:in:    table     Table address (uint24)        constant
  >:in:    entry     Table entry (8 bits)          constant
  >:in?:   xflip     X-flip bit                    constant
  >:in?:   yflip     Y-flip bit                    constant
  >:in?:   size      Size bit                      constant
  >:in?:   prio      Priority (2 bits)             constant
*/
.macro OAM_set table, entry, palette, xflip, yflip, size, prio
        sta     a:.loword((table + (entry << 2)) + 1)
        tya
        sta     a:.loword((table + (entry << 2)) + 2)
        xba
        asl
        rol
        ora     #.lobyte(((palette & $7) << 1) | ((prio & $3) << 4) | ((yflip & $1) << 6) | ((xflip & $1) << 7))
        sta     a:.loword((table + (entry << 2)) + 3)
        txa
        sta     a:.loword((table + (entry << 2)) + 0)

        lda     #.lobyte(~($3 << ((entry & 3) * 2)))
        and     a:.loword(table + 512 + (entry >> 4))
        sta     a:.loword(table + 512 + (entry >> 4))
        xba
        and     #1
        ora     #(size << 1)
  .repeat (entry & 3)
        asl
        asl
  .endrepeat
        ora     a:.loword(table + 512 + (entry >> 4))
        sta     a:.loword(table + 512 + (entry >> 4))
.endmac

.endif; __SNIPPETS_OAM__
