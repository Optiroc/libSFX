.include "libSFX.i"

.export InitScreen

InitScreen:
        FIFO_enq TestFIFO, $f
        FIFO_enq TestFIFO, $a
        FIFO_enq TestFIFO, $5
        FIFO_enq TestFIFO, $d

        FIFO_deq TestFIFO
        FIFO_deq TestFIFO
        break                   ;z = 0, a = $0a, head = 4, tail = 2

        FIFO_enq TestFIFO, $f0
        FIFO_enq TestFIFO, $0d
        FIFO_deq TestFIFO
        FIFO_deq TestFIFO
        FIFO_deq TestFIFO
        FIFO_deq TestFIFO
        break                   ;z = 0, a = $0d, head = 6, tail = 6

        FIFO_deq TestFIFO
        break                   ;z = 1 (queue empty), head = 6, tail = 6

        FIFO_enq TestFIFO, $10
        FIFO_enq TestFIFO, $ff
        break                   ;last byte in buffer = $ff, head = 0, tail = 6

        FIFO_enq TestFIFO, $aa
        break                   ;first byte in buffer = $aa, head = 1, tail = 6

        FIFO_deq TestFIFO
        FIFO_deq TestFIFO
        break                   ;z = 0, a = $ff, head = 1, tail = 0

        FIFO_deq TestFIFO
        break                   ;z = 0, a = $aa, head = 1, tail = 1

        FIFO_deq TestFIFO
        break                   ;z = 1 (queue empty), head = 6, tail = 6

        CGRAM_setColorRGB 0, 7,31,31    ;Set color 0

        lda     #$0f                    ;Turn on screen
        sta     SFX_inidisp

        rts
