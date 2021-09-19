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

SpriteNumberMask:
    .byte %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000

.macro RemoveTree(startAddress, colorStartAddress) {
    ldx #$00
    stx startAddress
    stx startAddress + $01
    stx startAddress + $02
    stx startAddress + $03

    stx startAddress + $28
    stx startAddress + $29
    stx startAddress + $2a
    stx startAddress + $2b

    stx startAddress + $50
    stx startAddress + $53

    inx
    stx startAddress + $51
    inx
    stx startAddress + $52

    inx
    stx startAddress + $78
    inx
    stx startAddress + $79
    inx
    stx startAddress + $7a
    inx
    stx startAddress + $7b

    ldx #$04
  Loop:
    ldy startAddress
    lda CharColors, y
    sta colorStartAddress + $d800, x
    dex
    bne Loop

    ldx #$04
  Loop2:
    ldy startAddress + $28
    lda CharColors, y
    sta colorStartAddress + $d800 + $28, x
    dex
    bne Loop2

    ldx #$04
  Loop3:
    ldy startAddress + $50
    lda CharColors, y
    sta colorStartAddress + $d800 + $50, x
    dex
    bne Loop3

    ldx #$04
  Loop4:
    ldy startAddress + $78
    lda CharColors, y
    sta colorStartAddress + $d800 + $78, x
    dex
    bne Loop4
}

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

.macro EnableSprite(bSprite, bEnable) {
    ldy #bSprite
    lda SpriteNumberMask, y
    .if (bEnable)   // Build-time condition (not run-time)
    {
      ora VIC.SPRITE_ENABLE   // Merge with the current sprite enable register
    }
    else
    {
      eor #$FF    // Get mask compliment
      and VIC.SPRITE_ENABLE   // Merge with the current sprite enable register
    }
    sta VIC.SPRITE_ENABLE       // Set the new value into the sprite enable register
}

.macro SpriteCollided(spriteNumber) {
    ldy spriteNumber
    lda SpriteNumberMask, y
    and SPRITES.COLLISION_REGISTER
}

* = * "SetColorToChars"
SetColorToChars: {
    lda ScreenMemoryAddress
    sta Dummy1 + 2
    lda #$d8
    sta ColorMap + 2
    lda #$00
    sta StartLoop + 1

    lda #$04
    sta CleanLoop
  StartLoop:
    ldx #$00
  PaintCols:
  Dummy1:
    ldy DummyScreenRam, x
    lda CharColors, y
  ColorMap:
    sta $d800, x
    dex
    bne PaintCols

    inc Dummy1 + 2
    inc ColorMap + 2
    dec CleanLoop
    lda CleanLoop
    cmp #$01
    beq SetLastRun
    cmp #$00
    beq Done
    jmp StartLoop

  SetLastRun:
    lda #$e7
    sta StartLoop + 1
    jmp StartLoop

  Done:
    rts

  ScreenMemoryAddress:
    .byte $be
  .label DummyScreenRam = $be00

  CleanLoop:
    .byte $03
}

.macro GetRandomUpTo(maxNumber) {
    lda #maxNumber
    sta GetRandom.GeneratorMax
    jsr GetRandom
}

GetRandom: {
  Loop:
    lda $d012
    eor $dc04
    sbc $dc05
    cmp GeneratorMax
    bcs Loop
    rts

    GeneratorMax: .byte $00
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

#import "allimport.asm"
