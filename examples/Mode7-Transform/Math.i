.ifndef ::__SNIPPETS_MATH__
::__SNIPPETS_MATH__ = 1

/**
  sign_extend
  Sign extend 8 bit accumulator to 16 bits

  Expects 8 bit accumulator.
  Exits with 8 bit accumulator.
*/
.macro sign_extend
        RW_assume a8
        bpl     :+
        xba
        lda     #$ff
        xba
        bra     :++
:
        xba
        lda     #$00
        xba
:
.endmac

.endif; __SNIPPETS_MATH__
