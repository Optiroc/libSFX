; casfx - Super Nintendo GSU (aka SuperFX) program assembly using ca65
; by ARM9 - 2013

.ifndef ::__MBSFX_GSU_Assembler__
::__MBSFX_GSU_Assembler__ = 1

;-------------------------------------------------------------------------------
_CASFX_AUTO_NOP = 1

.define _CASFX_TEMP_ERR_STRING "Invalid argument for opcode "

.macro _ASSERT_RANGE_ABS arg, _lower, _upper, err
    .assert _lower <= (arg) && (arg) <= _upper, error, err
.endmacro

.macro _ASSERT_RANGE_IMM arg, _lower, _upper, err
    .assert _lower <= .right(.tcount({arg})-1, {arg}) && .right(.tcount({arg})-1, {arg}) <= _upper, error, err
.endmacro

;**** Registers
.define r0      $00 ; General purpose, default source/dest register
.define r1      $01 ; Pixel plot X pos register
.define r2      $02 ; Pixel plot Y pos register
.define r3      $03 ; General purpose
.define r4      $04 ; Lower 16 bit result of lmult
.define r5      $05 ; General purpose
.define r6      $06 ; Multiplier for fmult and lmult
.define r7      $07 ; Fixed point texel X position for merge
.define r8      $08 ; Fixed point texel Y position for merge
.define r9      $09 ; General purpose
.define r10     $0A ; General purpose (conventionally stack pointer)
.define r11     $0B ; Return addres set by link
.define r12     $0C ; Loop counter
.define r13     $0D ; Loop point address
.define r14     $0E ; ROM buffer address
.define r15     $0F ; Program counter
.define R0      $00
.define R1      $01
.define R2      $02
.define R3      $03
.define R4      $04
.define R5      $05
.define R6      $06
.define R7      $07
.define R8      $08
.define R9      $09
.define R10     $0A
.define R11     $0B
.define R12     $0C
.define R13     $0D
.define R14     $0E
.define R15     $0F

.define _alt1_op    $3D
.define _alt2_op    $3E
.define _alt3_op    $3F

.macro _op_implied op,alt
    .if .tcount({alt}) = 1
        .assert _alt1_op <= alt && alt <= _alt3_op, error, "Invalid alt mode"
        .byte alt
    .endif
    .byte op
.endmacro

.define malt1   _op_implied $3D,
.define malt2   _op_implied $3E,
.define malt3   _op_implied $3F,

.macro _op16_one_reg op, err, reg
    ; Rn
    _ASSERT_RANGE_ABS reg, r0, r15, .concat (_CASFX_TEMP_ERR_STRING,err," Rn; R0-R15")
    .byte (op+reg)
    .exitmacro
.endmacro

.define mto     _op16_one_reg $10,"TO",
.define mwith   _op16_one_reg $20,"WITH", ;Sets B flag which interacts with TO or FROM to form MOVE Rn, Rn' or MOVES Rn, Rn' respectively
.define mfrom   _op16_one_reg $B0,"FROM",

.macro _op16_arith_one_arg op, alt, err, arg
    .if .xmatch (.left (1, {arg}), #) ; #n
        _ASSERT_RANGE_IMM {arg}, 0, 15, .concat (_CASFX_TEMP_ERR_STRING,err," #n; #0-15")
        ; alt3 for adc, umult
        ; alt2 for add, sub, mult
        .if .xmatch ({err}, {"ADC"}) || .xmatch ({err}, {"UMULT"})
            malt3
        .elseif .xmatch ({err}, {"CMP"}) || .xmatch ({err}, {"SBC"})
            .assert 0, error, .concat("Immediate value not allowed for opcode ",err," Rn; R0-R15")
        .else
            malt2
        .endif
        .byte op + .right(.tcount({arg})-1, {arg})
        .exitmacro
    .endif
    _ASSERT_RANGE_ABS arg, r0, r15, .concat (_CASFX_TEMP_ERR_STRING,err," Rn; R0-R15")
    .if .xmatch ({err}, {"CMP"}); cmp Rn
        malt3
        .byte (op+arg)
        .exitmacro
    .endif
    ;op Rn but not cmp
    .if .tcount({alt}) = 1
        malt1
    .endif
    .byte (op+arg)
.endmacro

; Rn or #n
.define madd    _op16_arith_one_arg $50,,"ADD",
.define madc    _op16_arith_one_arg $50,_alt1_op,"ADC",
.define msub    _op16_arith_one_arg $60,,"SUB",
.define msbc    _op16_arith_one_arg $60,_alt1_op,"SBC",
.define mcmp    _op16_arith_one_arg $60,_alt3_op,"CMP",

.define mmult   _op16_arith_one_arg $80,,"MULT",
.define mumult  _op16_arith_one_arg $80,_alt1_op,"UMULT",

;mult_r no alt, mult_i alt2, umult_r alt1, umult_i alt3

.macro _op15h_one_arg op, alt, err, arg
    .if .xmatch ({.left (1, {arg})}, #) ; #n
        _ASSERT_RANGE_IMM arg, 1, 15, .concat (_CASFX_TEMP_ERR_STRING,err," #n; #1-15")
        ;alt2 for and, or
        ;alt3 for bic, xor
        .if .tcount({alt}) = 1
            malt3
        .else
            malt2
        .endif
        .byte op + .right(.tcount({arg})-1, {arg}) - 1
        .exitmacro
    .else ; Rn
        _ASSERT_RANGE_ABS arg, r1, r15, .concat (_CASFX_TEMP_ERR_STRING,err," Rn; R1-R15")
        ;no alt for and, or
        ;alt1 for bic, xor
        .if .tcount({alt}) = 1
            malt1
        .endif
    .endif
    .byte op+(arg-1)
    ;.exitmacro
    ;.assert 0, error, .concat(_CASFX_TEMP_ERR_STRING,err,";")
.endmacro

.define mand    _op15h_one_arg $71,,"AND",
.define mbic    _op15h_one_arg $71,_alt1_op,"BIC",
.define mor     _op15h_one_arg $C1,,"OR",
.define mxor    _op15h_one_arg $C1,_alt1_op,"XOR",

.macro _op15l_one_reg op, err, reg
    _ASSERT_RANGE_ABS reg, r0, r14, .concat (_CASFX_TEMP_ERR_STRING,err," Rn; R0-R14")
    .byte op+reg
.endmacro

.define minc    _op15l_one_reg $D0,"INC",
.define mdec    _op15l_one_reg $E0,"DEC",

.macro _op12_one_reg_indirect op, alt, err, reg
    .if .xmatch ({.left (1, {reg})}, {(})
        .if .xmatch ({.right (1, {reg})}, {)})
            _ASSERT_RANGE_ABS reg, r0, r11, .concat (_CASFX_TEMP_ERR_STRING,err," (Rm); (R0-R11)")
            .if .tcount({alt}) = 1
                .byte alt
            .endif
            .byte (op+reg)
            .exitmacro
        .endif
    .endif
    .assert 0, error, .concat(_CASFX_TEMP_ERR_STRING,err," (Rm); (R0-R11)")
.endmacro

.define mstw    _op12_one_reg_indirect $30,,"STW",
.define mstb    _op12_one_reg_indirect $30,_alt1_op,"STB",
.define mldw    _op12_one_reg_indirect $40,,"LDW",
.define mldb    _op12_one_reg_indirect $40,_alt1_op,"LDB",

.macro _op16_one_reg_one_imm op, range, name, err, reg, arg
    _ASSERT_RANGE_ABS reg, r0, r15, .concat (_CASFX_TEMP_ERR_STRING,name,err)
    .byte (op+reg)
    .if .xmatch (.left(1, {arg}), #)
        ; Only range check ibt, automatically clip iwt with .loword for convenience (obviously no support for > 16 bit numbers)
        .if range <= $FF
            _ASSERT_RANGE_IMM arg, 0, range, .concat (_CASFX_TEMP_ERR_STRING,name,err)
            .byte .right(.tcount({arg})-1, {arg})
        .else
            .word .loword(.right(.tcount({arg})-1, {arg}))
        .endif
        .exitmacro
    .endif
    .if .xmatch ({name}, {"LEA"})
        ;_ASSERT_RANGE_ABS arg, 0, range, .concat (_CASFX_TEMP_ERR_STRING,name,err)
        .word .loword(arg)
        .exitmacro
        ;interesting quirk about how ca65 handles immediate #xyz data: lea r5, #$beef todo find out why this works
    .endif
    .assert 0, error, .concat(_CASFX_TEMP_ERR_STRING,name,err)
.endmacro

.define mibt    _op16_one_reg_one_imm $A0,$FF,"IBT"," Rn, #pp; R0-R15, #0-$FF",
.define miwt    _op16_one_reg_one_imm $F0,$FFFF,"IWT"," Rn, #xxxx; R0-R15, #0-$FFFF",
.define mlea    _op16_one_reg_one_imm $F0,$FFFF,"LEA"," Rn, xxxx; R0-R15, 0-$FFFF",


.macro _op16_two_args op, alt, range, name, err, arg1, arg2
    .byte alt
    .if .xmatch (.left (1, {arg1}), {(}) ; SM or SMS
        .if .xmatch (.left (1, {arg2}), {(})
            .assert 0, error, .concat (_CASFX_TEMP_ERR_STRING,name,err)
        .endif
        _ASSERT_RANGE_ABS arg2, r0, r15, .concat (_CASFX_TEMP_ERR_STRING,name,err)
        _ASSERT_RANGE_ABS .loword(arg1), 0, range, .concat (_CASFX_TEMP_ERR_STRING,name,err)

        .if .xmatch ({name}, {"SM"})
            .byte (op+arg2)
            .word .loword(arg1)
            .exitmacro
        .elseif .xmatch ({name}, {"SMS"})
            .assert (arg1 & 1) <> 1, error, .concat("Operand (yy) must be even: ",name,err)
            .byte (op+arg2)
            .byte <(arg1>>1)
            .exitmacro
        .endif
        .assert 0, error, .concat (_CASFX_TEMP_ERR_STRING,name,err) ; this might not be necessary
    .elseif .xmatch (.left (1, {arg2}), {(}) ; LM or LMS
        _ASSERT_RANGE_ABS arg1, r0, r15, .concat (_CASFX_TEMP_ERR_STRING,name,err)
        _ASSERT_RANGE_ABS .loword(arg2), 0, range, .concat (_CASFX_TEMP_ERR_STRING,name,err)
        .if .xmatch ({name}, {"LM"})
            .byte (op+arg1)
            .word .loword(arg2)
            .exitmacro
        .elseif .xmatch ({name}, {"LMS"})
            .assert (arg2 & 1) <> 1, error, .concat("Operand (yy) must be even: ",name,err)
            .byte (op+arg1)
            .byte <(arg2>>1)
            .exitmacro
        .endif
    .endif
    .assert 0, error, .concat (_CASFX_TEMP_ERR_STRING,name,err)
.endmacro

; When the value of xx is odd, (xx-1) is loaded to the high byte.
.define mlm     _op16_two_args $F0,_alt1_op, $FFFF, "LM", " Rn, (xx); R0-R15, (0-$FFFF)", ;Load memory
.define mlms    _op16_two_args $A0,_alt1_op, 510, "LMS", " Rn, (yy); R0-R15, (0-510)", ;Load memory short address
.define msm     _op16_two_args $F0,_alt2_op, $FFFF, "SM", " (xx), Rn; (0-$FFFF), R0-R15", ;Store memory
.define msms    _op16_two_args $A0,_alt2_op, 510, "SMS", " (yy), Rn; (0-510), R0-R15", ;Store memory short address

.macro _op4_one_arg op, err, arg
    .if .xmatch ({.left (1, {arg})}, #) ; #n
        _ASSERT_RANGE_IMM arg, 1, 4, .concat (_CASFX_TEMP_ERR_STRING,err," #n; #1-4")
        .byte op + .right(.tcount({arg})-1, {arg}) - 1
    .else
        .assert 0, error, .concat (_CASFX_TEMP_ERR_STRING,err," #n; #1-4")
    .endif
.endmacro

.define mlink   _op4_one_arg $91,"LINK",

.macro _op6_one_reg op, alt, err, arg
    _ASSERT_RANGE_ABS arg, r8, r13, .concat (_CASFX_TEMP_ERR_STRING,err," Rn; R8-R13")
    .if .tcount ({alt}) = 1
        .byte alt
    .endif
    .byte op+(arg-8)
.endmacro

.define mjmp    _op6_one_reg $98,,"JMP",
.define mljmp   _op6_one_reg $98,_alt1_op,"LJMP",


;**** Branch

.macro _branch_offset instr, target
    .local @distance, @next
    @distance = (target) - @next
    instr
    .assert @distance >= -128 && @distance <= 127, error, "Branch out of range"
    .byte <@distance
@next:
.endmacro

.macro _op_branch inst, target
    _branch_offset {.byte inst}, target
.endmacro


.define mbra    _op_branch $05, ; target
.define mbge    _op_branch $06, ; target
.define mblt    _op_branch $07, ; target
.define mbne    _op_branch $08, ; target
.define mbeq    _op_branch $09, ; target
.define mbpl    _op_branch $0A, ; target
.define mbmi    _op_branch $0B, ; target
.define mbcc    _op_branch $0C, ; target
.define mbcs    _op_branch $0D, ; target
.define mbvc    _op_branch $0E, ; target
.define mbvs    _op_branch $0F, ; target

;**** Implied

.define mstop   _op_implied $00, ; Sends IRQ signal
.define mnop    _op_implied $01, ; Actually clears alt1, alt2 and B flags
.define mcache  _op_implied $02, ; If CBR != R15&$FFF0 then set CBR to R15&$FFF0 and clear all cache flags
.define mlsr    _op_implied $03,
.define mrol    _op_implied $04,

.define mloop   _op_implied $3C, ; if(--r12 != 0) then R15 = R13

.define mplot   _op_implied $4C,
.define mrpix   _op_implied $4C,_alt1_op
.define mcolor  _op_implied $4E,
.define mcmode  _op_implied $4E,_alt1_op
.define mswap   _op_implied $4D,
.define mnot    _op_implied $4F,

.define mmerge  _op_implied $70,

.define msbk    _op_implied $90,
.define msex    _op_implied $95,
.define mdiv2   _op_implied $96,_alt1_op
.define masr    _op_implied $96,
.define mror    _op_implied $97,
.define mlob    _op_implied $9E,
.define mfmult  _op_implied $9F,
.define mlmult  _op_implied $9F,_alt1_op

.define mhib    _op_implied $C0,

.define mgetc   _op_implied $DF,
.define mramb   _op_implied $DF,_alt2_op
.define mromb   _op_implied $DF,_alt3_op

.define mgetb   _op_implied $EF,
.define mgetbh  _op_implied $EF,_alt1_op
.define mgetbl  _op_implied $EF,_alt2_op
.define mgetbs  _op_implied $EF,_alt3_op


;**** Pseudo-op moves

; WARNING TODO FIXME moveb and movew (Rm), Rn and (xx), Rn are ambiguous,
; fixing would be annoying, thus I've omitted support for now.
; just use lm/sm/sms/lms
.macro _move_pseudo_op name, arg1, arg2
    .if .xmatch (.left (1, {arg1}), {(})
        .if .xmatch (.left (1, {arg2}), {(})
            ;move (var), (r8) is not a valid pseudo-op, nor is move (r8), (var)
            ;.assert 0, error, .concat(_CASFX_TEMP_ERR_STRING,name,";")
            .assert 0, error, .concat(_CASFX_TEMP_ERR_STRING, name, "; move (), () is not a valid pseudo-op")
        .endif
        .if .xmatch ({name}, {"MOVEB"})
            _ASSERT_RANGE_ABS arg1, r0, r11, .concat (_CASFX_TEMP_ERR_STRING,name," (Rm), Rn; (R0-R11), R1-R15")
            _ASSERT_RANGE_ABS arg2, r0, r15, .concat (_CASFX_TEMP_ERR_STRING,name," (Rm), Rn; (R0-R11), R1-R15")
            .if (arg2 <> 0)
                mfrom arg2
            .endif
            mstb arg1
            .exitmacro
        .elseif .xmatch ({name}, {"MOVEW"})
            _ASSERT_RANGE_ABS arg1, r0, r11, .concat (_CASFX_TEMP_ERR_STRING,name," (Rm), Rn; (R0-R11), R0-R15")
            _ASSERT_RANGE_ABS arg2, r0, r15, .concat (_CASFX_TEMP_ERR_STRING,name," (Rm), Rn; (R0-R11), R0-R15")
            .if (arg2 <> 0)
                mfrom arg2
            .endif
            mstw arg1
            .exitmacro
        .endif

        ;_ASSERT_RANGE_ABS arg1, 0, $FFFF, .concat (_CASFX_TEMP_ERR_STRING,name," (xx), Rn; (0-$FFFF), R0-R15")
        ;_ASSERT_RANGE_ABS arg2, r0, r15, .concat (_CASFX_TEMP_ERR_STRING,name," (xx), Rn; (0-$FFFF), R0-R15")
        ;;move (xx), Sreg
        ;.if (arg1 <= $1FE) && ((arg1 & 1) <> 1) ;Can't delay if else evaluation until link stage, fudgesicle.
            ;msms arg1, arg2
        ;.else
            ;msm arg1, arg2
        ;.endif
        ;.exitmacro
        .assert 0, error, .concat(_CASFX_TEMP_ERR_STRING, name, ";")
    .elseif .xmatch (.left (1, {arg2}), {(})

        .if .xmatch ({name}, {"MOVEB"})
            _ASSERT_RANGE_ABS arg1, r0, r15, .concat (_CASFX_TEMP_ERR_STRING,name," Rn, (Rm); R0-R15, (R0-R11)")
            _ASSERT_RANGE_ABS arg2, r0, r11, .concat (_CASFX_TEMP_ERR_STRING,name," Rn, (Rm); R0-R15, (R0-R11)")
            .if (arg1 <> 0)
                mto arg1
            .endif
            mldb arg2
            .exitmacro
        .elseif .xmatch ({name}, {"MOVEW"})
            _ASSERT_RANGE_ABS arg1, r0, r15, .concat (_CASFX_TEMP_ERR_STRING,name," Rn, (Rm); R0-R15, (R0-R11)")
            _ASSERT_RANGE_ABS arg2, r0, r11, .concat (_CASFX_TEMP_ERR_STRING,name," Rn, (Rm); R0-R15, (R0-R11)")
            .if (arg1 <> 0)
                mto arg1
            .endif
            mldw arg2
            .exitmacro
        .endif

		;_ASSERT_RANGE_ABS arg1, r0, r15, .concat (_CASFX_TEMP_ERR_STRING,name," Rn, (xx); R0-R15, (0-$FFFF)")
		;_ASSERT_RANGE_ABS arg2, 0, $FFFF, .concat (_CASFX_TEMP_ERR_STRING,name," Rn, (xx); R0-R15, (0-$FFFF)")
        ;;move Dreg, (xx)
        ;.if (arg2 <= $1FE) && ((arg2 & 1) <> 1)
            ;mlms arg1, arg2 ; lms Rn, (yy)
        ;.else
            ;mlm arg1, arg2 ; lm Rn, (xx)
        ;.endif
        ;.exitmacro
        .assert 0, error, .concat(_CASFX_TEMP_ERR_STRING, name, ";")
    .elseif .xmatch (.left (1, {arg2}), #)
        .if .not .xmatch ({name}, {"MOVE"})
            .assert 0, error, .concat(_CASFX_TEMP_ERR_STRING,name,";")
        .endif
        _ASSERT_RANGE_ABS arg1, r0, r15, .concat (_CASFX_TEMP_ERR_STRING,name," Rn, #xx; R0-R15, #0-$FFFF")
        _ASSERT_RANGE_IMM arg2, 0, $FFFF, .concat (_CASFX_TEMP_ERR_STRING,name," Rn, #xx; R0-R15, #0-$FFFF")
        .if .right(.tcount({arg2})-1, {arg2}) <= $FF
            mibt arg1, arg2
        .else
            miwt arg1, arg2
        .endif
        .exitmacro
    .endif
    .if .not .xmatch ({name}, {"MOVE"})
        .assert 0, error, .concat(_CASFX_TEMP_ERR_STRING,name,"; Did you mean ",name," Rn, (Rm) or (Rm), Rn?")
    .endif
    _ASSERT_RANGE_ABS arg1, r0, r15, .concat (_CASFX_TEMP_ERR_STRING,name," Sreg, Dreg; R0-R15, R0-R15")
    _ASSERT_RANGE_ABS arg2, r0, r15, .concat (_CASFX_TEMP_ERR_STRING,name," Sreg, Dreg; R0-R15, R0-R15")
    ; move Dreg, Sreg
    mwith arg2
    mto arg1
.endmacro

.define move    _move_pseudo_op "MOVE",
.define moveb   _move_pseudo_op "MOVEB",
.define movew   _move_pseudo_op "MOVEW",

; move Rn, #pp = ibt, move Rn, #xxxx = iwt
; moves R1, R2 R2 -> R1 and sets flags accordingly

.macro moves dreg, sreg
    _ASSERT_RANGE_ABS dreg, r0, r15, .concat (_CASFX_TEMP_ERR_STRING,"MOVES Dreg, Sreg; R0-R15, R0-R15")
    _ASSERT_RANGE_ABS sreg, r0, r15, .concat (_CASFX_TEMP_ERR_STRING,"MOVES Dreg, Sreg; R0-R15, R0-R15")
    .if .xmatch (.left (1, {dreg} ), {(}) || .xmatch (.left (1, {sreg}), {(})
        .assert 0, error, .concat(_CASFX_TEMP_ERR_STRING,"MOVES Dreg, Sreg; R0-R15, R0-R15")
    .endif
    mwith dreg
    mfrom sreg
    .exitmacro
.endmacro


; Custom pseudo-op macros

; Stack push/pop pseudo-ops, full descending
.macro mpush reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15
    .ifblank reg0
        .exitmacro
    .else
        mdec R10
        mdec R10
        movew (R10), reg0
    .endif
    mpush reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15
.endmacro

.macro mpop reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15
    .ifblank reg0
        .exitmacro
    .else
        movew reg0, (R10)
        minc R10
        minc R10
    .endif
    mpop reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15
.endmacro


;jump and link
.macro mjal dest ;Modifies r11 and r15
    ;.assert dest <= $FFFF, error, .sprintf("Address %d out of range (jal 0-$FFFF)", dest)
    mlink #4
    miwt R15, #dest;.loword(dest)
    .ifdef _CASFX_AUTO_NOP
        mnop
    .endif
.endmacro

.macro mret
    mjmp r11
    .ifdef _CASFX_AUTO_NOP
        mnop
    .endif
.endmacro

.macro autonop
    _CASFX_AUTO_NOP = 1
.endmacro

;.macro jsl dest
; _ibt R11, #02h
; _from r1
; _ljmp r11
;   .assert dest <= $FFFFFF, error, "Address out of range (jsl $00-FF:0000-FFFF)"
;   _ibt R0, #^dest
;   _iwt R11, #dest&$FFFF
    ;from R0
;   _ljmp R11
;.endmacro

;.repeat 16, i
;   .if .xmatch({val}, .ident(.sprintf("r%d", i)))
;       .byte op + i,
;   .endif
;.endrepeat

.ifndef GSU_INLINE
    .setcpu "none"

    .define adc     madc
    .define add     madd
    .define alt1    malt1
    .define alt2    malt2
    .define alt3    malt3
    .define and     mand
    .define asr     masr
    .define bcc     mbcc
    .define bcs     mbcs
    .define beq     mbeq
    .define bge     mbge
    .define bic     mbic
    .define blt     mblt
    .define bmi     mbmi
    .define bne     mbne
    .define bpl     mbpl
    .define bra     mbra
    .define bvc     mbvc
    .define bvs     mbvs
    .define cache   mcache
    .define cmode   mcmode
    .define cmp     mcmp
    .define color   mcolor
    .define dec     mdec
    .define div2    mdiv2
    .define fmult   mfmult
    .define from    mfrom
    .define getb    mgetb
    .define getbh   mgetbh
    .define getbl   mgetbl
    .define getbs   mgetbs
    .define getc    mgetc
    .define hib     mhib
    .define ibt     mibt
    .define inc     minc
    .define iwt     miwt
    .define jmp     mjmp
    .define ldb     mldb
    .define ldw     mldw
    .define lea     mlea
    .define link    mlink
    .define ljmp    mljmp
    .define lm      mlm
    .define lms     mlms
    .define lmult   mlmult
    .define lob     mlob
    .define loop    mloop
    .define lsr     mlsr
    .define merge   mmerge
    .define mult    mmult
    .define nop     mnop
    .define not     mnot
    .define or      mor
    .define plot    mplot
    .define ramb    mramb
    .define rol     mrol
    .define romb    mromb
    .define ror     mror
    .define rpix    mrpix
    .define sbc     msbc
    .define sbk     msbk
    .define sex     msex
    .define sm      msm
    .define sms     msms
    .define stb     mstb
    .define stop    mstop
    .define stw     mstw
    .define sub     msub
    .define swap    mswap
    .define to      mto
    .define umult   mumult
    .define with    mwith
    .define xor     mxor
    ;pseudo-ops
    .define pop     mpop
    .define push    mpush
    .define jal     mjal
    .define ret     mret
.endif

;.undefine _CASFX_TEMP_ERR_STRING

.endif;__MBSFX_GSU_Assembler__
