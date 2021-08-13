////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Some useful routine.
//
////////////////////////////////////////////////////////////////////////////////

#importonce

#import "allimport.asm"

// Fill screen with $20 char (preserve sprite pointer memory area)
.macro ClearScreen(screenram) {
    lda #$20
    ldx #250
  !:
    dex
    sta screenram, x
    sta screenram + 250, x
    sta screenram + 500, x
    sta screenram + 750, x
    bne !-
}

.macro SetColorToChars(screenram) {
    ldx #250
  PaintCols:
    ldy screenram, x
    lda CharColors, y
    sta $d800, x
    ldy screenram + 250, x
    lda CharColors, y
    sta $d800 + 250, x
    ldy screenram + 500, x
    lda CharColors, y
    sta $d800 + 500, x
    ldy screenram + 750, x
    lda CharColors, y
    sta $d800 + 750, x
    dex
    bne PaintCols
}

WaitRoutine: {
    VBLANKWAITLOW:
        lda $d011
        bpl VBLANKWAITLOW
    VBLANKWAITHIGH:
        lda $d011
        bmi VBLANKWAITHIGH
        rts
}

StupidWaitRoutine: {
        ldy #$bf
    LoopY:
        ldx #$ff
    LoopX:
        nop
        nop
        dex
        bne LoopX
        dey
        bne LoopY
        rts
}
