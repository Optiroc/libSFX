.include "libSFX.i"

.export InitScreen

InitScreen:
        FIFO_enq FIFO, $f
        ;FIFO_enq FIFO, $3
        ;lda     #$04
        ;FIFO_enq FIFO, a
        ;FIFO_enq FIFO, $d
        ;nop
        FIFO_deq FIFO
        FIFO_deq FIFO
        FIFO_deq FIFO
        FIFO_deq FIFO

        ;FIFO_enq FIFO, $10
        ;FIFO_enq FIFO, $10
        ;FIFO_enq FIFO, $10
        ;FIFO_enq FIFO, $10
        ;FIFO_enq FIFO, $10
        ;FIFO_enq FIFO, $10

        ;Set color 0
        CGRAM_setColorRGB 0, 31,7,31

        ;Turn on screen
        lda     #$0f
        sta     INIDISP

        rts
