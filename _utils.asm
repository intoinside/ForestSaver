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

#import "common/lib/math-global.asm"

* = * "Utils RemoveTree"
RemoveTree: {
    .assert "RemoveTree.StartAddress not beef", StartAddress != $beef, true

// Row #1
    lda StartAddress
    sta SelfMod1 + 1
    lda StartAddress + 1
    sta SelfMod1 + 2

    c64lib_inc16(StartAddress)
    lda StartAddress
    sta SelfMod2 + 1
    lda StartAddress + 1
    sta SelfMod2 + 2

    c64lib_inc16(StartAddress)
    lda StartAddress
    sta SelfMod3 + 1
    lda StartAddress + 1
    sta SelfMod3 + 2

    c64lib_inc16(StartAddress)
    lda StartAddress
    sta SelfMod4 + 1
    lda StartAddress + 1
    sta SelfMod4 + 2

// Row #2
    c64lib_add16($0025, StartAddress)
    lda StartAddress
    sta SelfMod5 + 1
    lda StartAddress + 1
    sta SelfMod5 + 2

    c64lib_inc16(StartAddress)
    lda StartAddress
    sta SelfMod6 + 1
    lda StartAddress + 1
    sta SelfMod6 + 2

    c64lib_inc16(StartAddress)
    lda StartAddress
    sta SelfMod7 + 1
    lda StartAddress + 1
    sta SelfMod7 + 2

    c64lib_inc16(StartAddress)
    lda StartAddress
    sta SelfMod8 + 1
    lda StartAddress + 1
    sta SelfMod8 + 2

// Row #3
    c64lib_add16($0025, StartAddress)
    lda StartAddress
    sta SelfMod9 + 1
    lda StartAddress + 1
    sta SelfMod9 + 2

    c64lib_inc16(StartAddress)
    lda StartAddress
    sta SelfMod10 + 1
    lda StartAddress + 1
    sta SelfMod10 + 2

    c64lib_inc16(StartAddress)
    lda StartAddress
    sta SelfMod11 + 1
    lda StartAddress + 1
    sta SelfMod11 + 2

    c64lib_inc16(StartAddress)
    lda StartAddress
    sta SelfMod12 + 1
    lda StartAddress + 1
    sta SelfMod12 + 2

// Row #4
    c64lib_add16($0025, StartAddress)
    lda StartAddress
    sta SelfMod13 + 1
    lda StartAddress + 1
    sta SelfMod13 + 2

    c64lib_inc16(StartAddress)
    lda StartAddress
    sta SelfMod14 + 1
    lda StartAddress + 1
    sta SelfMod14 + 2

    c64lib_inc16(StartAddress)
    lda StartAddress
    sta SelfMod15 + 1
    lda StartAddress + 1
    sta SelfMod15 + 2

    c64lib_inc16(StartAddress)
    lda StartAddress
    sta SelfMod16 + 1
    lda StartAddress + 1
    sta SelfMod16 + 2

    ldx #$00
  SelfMod1:
    stx $beef
  SelfMod2:
    stx $beef
  SelfMod3:
    stx $beef
  SelfMod4:
    stx $beef

  SelfMod5:
    stx $beef
  SelfMod6:
    stx $beef
  SelfMod7:
    stx $beef
  SelfMod8:
    stx $beef

  SelfMod9:
    stx $beef
  SelfMod12:
    stx $beef
    inx
  SelfMod10:
    stx $beef
    inx
  SelfMod11:
    stx $beef

    inx
  SelfMod13:
    stx $beef
    inx
  SelfMod14:
    stx $beef
    inx
  SelfMod15:
    stx $beef
    inx
  SelfMod16:
    stx $beef

    jsr SetColorToChars

    rts

    StartAddress: .word $beef
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

.macro bpl16(value, low) {
  lda value + 1
  cmp low + 1
  bpl end     // branch to end if value is bigger
  lda value
  cmp low
end:
}

.macro bmi16(value, low) {
  lda value + 1
  cmp low + 1
  bmi end     // branch to end if value is smaller
  lda value
  cmp low
end:
}

* = * "Utils SpriteCollision"
SpriteCollision: {

    lda #%00000001
    and SPRITES.COLLISION_REGISTER
    bne CollisionHappened
    jmp NoCollisionDetected

// Sprite 0 collided with someone, detect sprite0 corner
  CollisionHappened:
    lda SPRITES.EXTRA_BIT
    cmp #%00000001
    beq SetExtraBit
    lda #$00
    jmp NextArg
  SetExtraBit:
    lda #$01
  NextArg:
    sta X1 + 1

    lda SPRITES.X0
    sta X1
    clc
    adc #$08
    sta X2
    bcc !+
    lda #$01
    jmp !Next+
  !:
    lda #$00
  !Next:
    sta X2 + 1

    lda SPRITES.Y0
    sta Y1
    clc
    adc #$08
    sta Y2

// REMIND: BMI means jump if a is lower than b
    bmi16(I1, X1)
    bmi NoCollisionDetected
    bmi16(X2, I1)
    bmi NoCollisionDetected

    bmi16(J1, Y1)
    bmi NoCollisionDetected
    bmi16(Y2, J1)
    bmi NoCollisionDetected

  CollisionDetected:
    lda #$01
    jmp Done

  NoCollisionDetected:
    lda #$00

  Done:
    sta Collision
    rts

  SpriteNumber: .byte $00

// Woodcutter square
  X1: .word $0000
  X2: .word $0000
  Y1: .word $0000
  Y2: .word $0000

// Other sprite initial coordinate
  I1: .word $0000
  J1: .word $0000

  Collision: .byte $00
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

#import "_allimport.asm"
