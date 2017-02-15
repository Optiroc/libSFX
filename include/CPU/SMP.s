; libSFX S-CPU to S-SMP Communication
; David Lindecrantz <optiroc@gmail.com>
; Transfer and I/O routines by Shay Green <gblargg@gmail.com>

.include "../libSFX.i"
.segment "LIBSFX"

;-------------------------------------------------------------------------------
;Wait for SMP ready signal (i16)
SFX_SMP_ready:
        ldy     #$bbaa
:       cpy     SMPIO0
        bne     :-
        rtl

;-------------------------------------------------------------------------------
;Tell SPC700 to jump to address via IPL (a8i16)
;X = Jump address
SFX_SMP_jmp:
        jsl     SFX_SMP_ready

        stx     SMPIO2          ;Set jump address
        lda     #$cc
        stz     SMPIO1          ;Send execute command
        sta     SMPIO0          ;Send kick flag
:       cmp     SMPIO0          ;Wait for acknowledgement
        bne     :-

        stz     SMPIO0          ;Reset flag
        rtl

;-------------------------------------------------------------------------------
;Transfer and execute SPC700 binary (a8i16)
;       A:X = Source (bank:offset)
;         Y = Destination (offset in SMP RAM)
;  ZPAD+$03 = Length (word)
;  ZPAD+$05 = Execution offset (word)
SFX_SMP_exec:
        stx     ZPAD+$00                ;Set 24-bit offset
        sta     ZPAD+$02

        jsr     smpBeginUpload          ;SMP handshake, set destination
                                        ;Y=0 when done
        ldx     ZPAD+$03                ;Length

:       lda     [ZPAD],y                ;Upload bytes
        jsr     smpUploadByte
        dex
        bne     :-

        ldy     ZPAD+$05                ;Execute
        jsr     smpExecute
        rtl

;-------------------------------------------------------------------------------
;Transfer entire SPC dump and start playback (a8i16)
SFX_SMP_execspc:
        phb
        sei                             ;Disable interrupts
        stz     NMITIMEN

        jsr     spcClearEcho
        jsr     spcUploadDSP
        jsr     spcUploadRAM
        jsr     spcUploadZP
        jsr     spcStart

        lda     SFX_nmitimen            ;Restore interrupts
        sta     NMITIMEN
        cli
        plb
        rtl


;-------------------------------------------------------------------------------
;Clear echo garbage in RAM dump
spcClearEcho:
        lda     f:SFX_DSP_STATE+$6c     ;Check ECEN (echo enable) in FLG
        and     #$20
        bne     @done
        lda     f:SFX_DSP_STATE+$7d     ;Buffer size > 0
        and     #$0f
        beq     @done

        lda     f:SFX_DSP_STATE+$6d     ;ESA (Echo buffer offset address) -> X
        xba                             ;<< 8
        lda     #$00
        tax

        lda     f:SFX_DSP_STATE+$7d     ;EDL (Echo ring buffer size) -> Y
        and     #$0f                    ;<< 11
        asl     a
        asl     a
        asl     a
        xba
        lda     #$00
        tay

        lda     #$ff                    ;Clear buffer
:       sta     f:SFX_SPC_IMAGE,x
        inx
        dey
        bne     :-

@done:  rts


;-------------------------------------------------------------------------------
;Upload DSP registers + $00f8-$01ff
spcUploadDSP:
        ldy     #$0002                  ;Begin upload
        jsr     smpBeginUpload

        ldx     #$0000                  ;Upload loader
:       lda     f:SMP_SetDSP_LOC,x
        jsr     smpUploadByte
        inx
        cpy     #SMP_SetDSP_SIZ
        bne     :-

        lda     f:SFX_DSP_STATE+$86     ;#SPC_SP ;Upload SP, PC & PSW
        jsr     smpUploadByte
        lda     f:SFX_DSP_STATE+$81     ;#SPC_PC_HI
        jsr     smpUploadByte
        lda     f:SFX_DSP_STATE+$80     ;#SPC_PC_LO
        jsr     smpUploadByte
        lda     f:SFX_DSP_STATE+$85     ;#SPC_PSW
        jsr     smpUploadByte

        ldx     #$0000                  ;Upload DSP registers
:       cpx     #$004c                  ;Initialize FLG and KON ($6c/$4c) to avoid artifacts
        bne     :+
        lda     #$00
        bra     :+++
:       cpx     #$006c
        bne     :+
        lda     #$e0
        bra     :++
:       lda     f:SFX_DSP_STATE,x
:       jsr     smpUploadByte
        inx
        cpx     #$0080
        bne     :----

        ldy     #$00f1                  ;Upload fixed values for $F1-$F3
        jsr     smpNextUpload

        lda     #$80                    ;Stop timers
        jsr     smpUploadByte
        lda     #$6c                    ;Get dspaddr set for later
        jsr     smpUploadByte
        lda     #$60
        jsr     smpUploadByte

        ldy     #$00f8                  ;Upload $00f8-$01ff
        jsr     smpNextUpload

        ldx     #$00f8
:       lda     f:SFX_SPC_IMAGE,x
        jsr     smpUploadByte
        inx
        cpx     #$0200
        bne     :-

        ldy     #$0002                  ;Execute loader
        jsr     smpExecute
        rts


;-------------------------------------------------------------------------------
;Upload $0200-$ffff with timed bursts
spcUploadRAM:
        ldy     #$0002
        jsr     smpBeginUpload

        ldx     #$0000                  ;Upload transfer routine
:       lda     f:SMP_Burst_LOC,x
        jsr     smpUploadByte
        inx
        cpy     #SMP_Burst_SIZ
        bne     :-

        ldx     #$023f                  ;Prepare transfer address
        ldy     #$0002                  ;Execute transfer routine
        sty     SMPIO2
        stz     SMPIO1
        lda     SMPIO0
        inc     a
        inc     a
        sta     SMPIO0

:       cmp     SMPIO0                  ;Wait for acknowledgement
        bne :-

:       ldy     #$003f                  ;3 - Page
:       lda     f:SFX_SPC_IMAGE,x       ;5 - Quad
        sta     SMPIO0                  ;4
        lda     f:SFX_SPC_IMAGE+$40,x   ;5
        sta     SMPIO1                  ;4
        lda     f:SFX_SPC_IMAGE+$80,x   ;5
        sta     SMPIO2                  ;4
        lda     f:SFX_SPC_IMAGE+$C0,x   ;5
        sta     SMPIO3                  ;4
        tya                             ;2 = 38 cycles

:       cmp     SMPIO3                  ;4
        bne     :-                      ;3
        dex                             ;2
        dey                             ;2
        bpl     :--                     ;3 = 14 cycles

        rep     #$21                    ;3
        RW_assume a16
        txa                             ;2
        adc     #$0140                  ;3
        tax                             ;2
        sep     #$20                    ;3
        RW_assume a8
        cpx     #$003f                  ;3
        bne     :---                    ;3 = 19 cycles
        rts


;-------------------------------------------------------------------------------
;Upload $0002-$00EF using IPL
spcUploadZP:
        ldy     #$0002
        jsr     smpBeginUpload

        ldx     #$0002
:       lda     f:SFX_SPC_IMAGE,x
        jsr     smpUploadByte
        inx
        cpx     #$00f0
        bne     :-
        rts


;-------------------------------------------------------------------------------
;Finalize SPC state
spcStart:
        jsr     smpStartExecIO          ;Prepare execution from I/O registers
        stz     MEMSEL                  ;SPC700 I/O code requires slow timing

        ;Restore $0000-$0001
        lda     f:SFX_SPC_IMAGE
        xba
        lda     #$e8                    ;MOV A,SFX_SPC_IMAGE
        tax
        jsr     smpExecInstr
        ldx     #$00c4                  ;MOV $00,A
        jsr     smpExecInstr

        lda     f:SFX_SPC_IMAGE+1
        xba
        lda     #$e8                    ;MOV A,SFX_SPC_IMAGE+1
        tax
        jsr     smpExecInstr
        ldx     #$01c4                  ;MOV $01,A
        jsr     smpExecInstr

        ;Restore SP
        lda     f:SFX_DSP_STATE+$86     ;#SPC_SP
        sec
        sbc     #$03
        xba
        lda     #$cd                    ;MOV X,#SPC_SP
        tax
        jsr     smpExecInstr
        ldx     #$00bd                  ;MOV SP,X
        jsr     smpExecInstr

        ;Restore X
        lda     f:SFX_DSP_STATE+$83     ;#SPC_X
        xba
        lda     #$cd                    ;MOV X,#SPC_X
        tax
        jsr     smpExecInstr

        ;Restore Y
        lda     f:SFX_DSP_STATE+$84     ;#SPC_Y
        xba
        lda     #$8d                    ;MOV Y,#SPC_Y
        tax
        jsr     smpExecInstr

        ;Restore DSP FLG register
        lda     f:SFX_DSP_STATE+$6c
        xba
        lda     #$e8                    ;MOV A,#SPC_DSP_REGS+$6c
        tax
        jsr     smpExecInstr
        ldx     #$f3C4                  ;MOV $f3,A -> $f2 has been set-up before by SPC700 loader
        jsr     smpExecInstr

        WAIT_frames 10                  ;Wait for DSP to settle

        ;Restore DSP KON register
        lda     #$4c
        xba
        lda     #$e8                    ;MOV A,#$4c
        tax
        jsr     smpExecInstr
        ldx     #$f2c4                  ;MOV $f2,A
        jsr     smpExecInstr
        lda     f:SFX_DSP_STATE+$4c
        xba
        lda     #$e8                    ;MOV A,#SPC_DSP_REGS+$4c
        tax
        jsr     smpExecInstr
        ldx     #$f3c4                  ;MOV $f3,A
        jsr     smpExecInstr

        ;Restore DSP register address
        lda     f:SFX_SPC_IMAGE+$f2
        xba
        lda     #$e8                    ;MOV A,#SFX_SPC_IMAGE+$F2
        tax
        jsr     smpExecInstr
        ldx     #$f2c4                  ;MOV dest,A
        jsr     smpExecInstr

        ;Restore CONTROL register
        lda     f:SFX_SPC_IMAGE+$f1
        and     #$cf                    ;Don't clear input ports
        xba
        lda     #$e8                    ;MOV A,#SFX_SPC_IMAGE+$F1
        tax
        jsr     smpExecInstr
        ldx     #$f1c4                  ;MOV $F1,A
        jsr     smpExecInstr

        ;Restore A
        lda     f:SFX_DSP_STATE+$82     ;#SPC_A
        xba
        lda     #$e8                    ;MOV A,#SPC_A
        tax
        jsr     smpExecInstr

        ;Restore PSW and PC
        ldx     #$7f00                  ;NOP; RTI
        stx     SMPIO0
        lda     #$fc                    ;Patch loop to execute instruction just written
        sta     SMPIO3

        ;Restore IO ports $f4-$f7
        rep     #$20
        lda     f:SFX_SPC_IMAGE+$f4
        tax
        lda     f:SFX_SPC_IMAGE+$f6
        sta     SMPIO2
        stx     SMPIO0                  ;Last to avoid overwriting RETI before run
        sep     #$20

        lda     #$01                    ;Restore fast CPU operation
        sta     MEMSEL
        rts


;-------------------------------------------------------------------------------
;Utility functions

smpBeginUpload:
        sty     SMPIO2          ;Set address
        ldy     #$bbaa          ;Wait for SPC
:       cpy     SMPIO0
        bne     :-

        lda     #$cc            ;Send acknowledgement
        sta     SMPIO1
        sta     SMPIO0
:       cmp     SMPIO0          ;Wait for acknowledgement
        bne     :-

        ldy     #$0000          ;Initialize index
        rts

;---------------------------------------
smpUploadByte:
        sta     SMPIO1
        tya                     ;Signal it's ready
        sta     SMPIO0
:       cmp     SMPIO0          ;Wait for acknowledgement
        bne     :-
        iny
        rts

;---------------------------------------
smpNextUpload:
        sty     SMPIO2
        lda     SMPIO0          ;Send command
        inc     a
        inc     a
        bne     :+
        inc     a
:       sta     SMPIO1
        sta     SMPIO0
:       cmp     SMPIO0          ;Wait for acknowledgement
        bne     :-

        ldy     #$0000
        rts

;---------------------------------------
smpExecute:
        sty     SMPIO2
        stz     SMPIO1
        lda     SMPIO0
        inc     a
        inc     a
        sta     SMPIO0

:       cmp     SMPIO0          ;Wait for acknowledgement
        bne     :-
        rts

;---------------------------------------
smpStartExecIO:
        ldx     #$00f5          ;Set execution address
        stx     SMPIO2

        stz     SMPIO1          ;NOP
        ldx     #$fe2f          ;BRA *-2

        lda     SMPIO0          ;Signal to SPC that we're ready
        inc     a
        inc     a
        sta     SMPIO0

:       cmp     SMPIO0          ;Wait for acknowledgement
        bne     :-

        stx     SMPIO2          ;Quickly write branch
        rts

;---------------------------------------
smpExecInstr:
        stx     SMPIO0          ;Replace instruction
        lda     #$fc
        sta     SMPIO3          ;30

        ;SPC BRA loop takes 4 cycles, so it reads
        ;the branch offset every 4 SPC cycles (84 master).
        ;We must handle the case where it read just before
        ;the write above, and when it reads just after it.
        ;If it reads just after, we have at least 7 SPC
        ;cycles (147 master) to change restore the branch
        ;offset.

        ;48 minimum, 90 maximum
        ora     $00
        ora     $00
        ora     $00
        nop
        nop
        nop

        ;66 delay, about the middle of the above limits
        phd             ;4
        pld             ;5

        ;Patch loop to skip first two bytes
        lda     #$fe    ;16
        sta     SMPIO3  ;30

        ;38 minimum (assuming 66 delay above)
        phd             ;4
        pld             ;5

        ;Give plenty of extra time if single execution
        ;isn't needed, as this avoids such tight timing
        ;requirements.
        phd
        pld
        phd
        pld
        rts
