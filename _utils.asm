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

// Switch char at CharPosition from CharFrame1 to CharFrame2 and back
.macro AnimateLake(CharPosition, CharFrame1, CharFrame2) {
    lda CharPosition
    cmp #CharFrame1
    beq !+
    ldx #CharFrame1
    jmp Set
  !:
    ldx #CharFrame2

  Set:
    stx CharPosition
}

* = * "Utils RemoveTree"
RemoveTree: {
    jsr Sfx.TreeFall

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
    ldx #$3a
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

    jmp SetColorToChars

    StartAddress: .word $beef
}

// Fill screen with $00 char (preserve sprite pointer memory area)
.macro ClearScreen(screenram) {
    lda #$00
    ldx #250
  !:
    dex
    sta screenram, x
    sta screenram + 250, x
    sta screenram + 500, x
    sta screenram + 750, x
    bne !-
}

.macro CopyScreenRam(StartAddress, EndAddress) {
    ldx #250
  !:
    dex
    lda StartAddress, x
    sta EndAddress, x
    lda StartAddress + 250, x
    sta EndAddress + 250, x
    lda StartAddress + 500, x
    sta EndAddress + 500, x
    lda StartAddress + 750, x
    sta EndAddress + 750, x
    cpx #$0
    bne !-
}

.macro ShowDialogNextLevel(ScreenMemoryBaseAddress) {
    lda #<ScreenMemoryBaseAddress
    sta ShowDialog.StartAddress
    lda #>ScreenMemoryBaseAddress
    sta ShowDialog.StartAddress + 1
    lda #<DialogNextLevel
    sta ShowDialog.DialogAddress
    lda #>DialogNextLevel
    sta ShowDialog.DialogAddress + 1
    jsr ShowDialog
}

.macro ShowDialogGameOver(ScreenMemoryBaseAddress) {
    lda #<ScreenMemoryBaseAddress
    sta ShowDialog.StartAddress
    lda #>ScreenMemoryBaseAddress
    sta ShowDialog.StartAddress + 1
    lda #<DialogGameOver
    sta ShowDialog.DialogAddress
    lda #>DialogGameOver
    sta ShowDialog.DialogAddress + 1
    jsr ShowDialog
}

ShowDialog: {
    lda StartAddress + 1
    sta StartAddressHi

    c64lib_add16(c64lib_getTextOffset(DialogStartX, DialogStartY), StartAddress)

    ldy #DialogHeight
  !Row:
    dey

    lda DialogAddress
    sta DialogAddressPtr + 1
    lda DialogAddress + 1
    sta DialogAddressPtr + 2

    lda StartAddress
    sta StartAddressPtr + 1
    lda StartAddress + 1
    sta StartAddressPtr + 2

    ldx #DialogWidth

  !:
    dex
  DialogAddressPtr:
    lda DialogAddress, x
  StartAddressPtr:
    sta StartAddress, x
    cpx #0
    bne !-

    c64lib_add16(40, StartAddress)
    c64lib_add16(DialogWidth, DialogAddress)

    cpy #0
    bne !Row-

    lda StartAddressHi
    sta SetColorToChars.ScreenMemoryAddress

    jsr SetColorToChars

    inc IsShown
    rts

  .label DialogStartX = 10;
  .label DialogStartY = 6;

  .label DialogWidth = 20;
  .label DialogHeight = 7;

  IsShown: .byte $00

  StartAddress: .word $beef
  DialogAddress: .word $beef
  StartAddressHi: .byte $be
}

.macro SetupColorMap(screenRamHiAddress) {
    lda #screenRamHiAddress
    sta SetColorToChars.ScreenMemoryAddress

    jsr SetColorToChars
}

DisableAllSprites: {
    lda #$00
    sta c64lib.SPRITE_ENABLE

    rts
}

SetSpriteToBackground: {
    lda #$ff
    sta c64lib.SPRITE_PRIORITY

    rts
}

SetSpriteToForeground: {
    lda #$00
    sta c64lib.SPRITE_PRIORITY

    rts
}

.macro SetSpriteToSamePosition(Sprite1X, Sprite2X) {
    lda Sprite1X
    sta Sprite2X
    lda Sprite1X + 1
    sta Sprite2X + 1
}
.assert "SetSpriteToSamePosition($2000, $2100) ", { SetSpriteToSamePosition($2000, $2100) }, {
  lda $2000; sta $2100; lda $2001; sta $2101
}

.macro EnableSprite(bSprite, bEnable) {
    ldy #bSprite
    lda SpriteNumberMask, y
    .if (bEnable)   // Build-time condition (not run-time)
    {
      ora c64lib.SPRITE_ENABLE   // Merge with the current sprite enable register
    }
    else
    {
      eor #$ff    // Get mask compliment
      and c64lib.SPRITE_ENABLE   // Merge with the current sprite enable register
    }
    sta c64lib.SPRITE_ENABLE       // Set the new value into the sprite enable register
}
.assert "EnableSprite($00, true) ", { EnableSprite($be, true) }, {
  ldy #$be; lda SpriteNumberMask, y; ora $d015; sta $d015
}
.assert "EnableSprite($00, false) ", { EnableSprite($be, false) }, {
  ldy #$be; lda SpriteNumberMask, y; eor #$ff; and $d015; sta $d015
}

.macro EnableMultiSprite(SpriteMask, bEnable) {
    lda #SpriteMask
    .if (bEnable)   // Build-time condition (not run-time)
    {
      ora c64lib.SPRITE_ENABLE   // Merge with the current sprite enable register
    }
    else
    {
      eor #$ff    // Get mask compliment
      and c64lib.SPRITE_ENABLE   // Merge with the current sprite enable register
    }
    sta c64lib.SPRITE_ENABLE       // Set the new value into the sprite enable register
}
.assert "EnableMultiSprite($be, true) ", { EnableMultiSprite($be, true) }, {
  lda #$be; ora $d015; sta $d015
}
.assert "EnableMultiSprite($00, false) ", { EnableMultiSprite($be, false) }, {
  lda #$be; eor #$ff; and $d015; sta $d015
}

.macro bmi16(arg1, arg2) {
    lda arg1 + 1
    cmp arg2 + 1
    bmi end     // branch to end if value is smaller than low
    lda arg1
    cmp arg2
  end:
}
.assert "bmi16($0102, $0a0b) ", { bmi16($0102, $0a0b) }, {
  lda $0103; cmp $0a0c; bmi end; lda $0102; cmp $0a0b; end:
}

* = * "Utils SetLakeToBlack"
SetLakeToBlack: {
    lda StartAddress
    sta Loop1 + 1
    lda StartAddress + 1
    sta Loop1 + 2

    ldx #$00
    lda #$a5
  Loop1:
    sta StartAddress, x
    clc
    adc #$01
    inx
    cpx #$04
    bne Loop1

    c64lib_add16($0028, StartAddress)
    lda StartAddress
    sta Loop2 + 1
    lda StartAddress + 1
    sta Loop2 + 2

    ldx #$00
    lda #$a9
  Loop2:
    sta StartAddress, x
    clc
    adc #$01
    inx
    cpx #$04
    bne Loop2

    rts

  StartAddress: .word $beef
}

* = * "Utils SpriteCollision"
SpriteCollision: {
    c64lib_add16($000c, OtherX)
    lda OtherY
    clc
    adc #10
    sta OtherY

    lda c64lib.SPRITE_MSB_X
    and #%00000001
    sta RangerX1 + 1
    sta RangerX2 + 1

    lda c64lib.SPRITE_0_X
    sta RangerX1
    sta RangerX2
    add16value($0018, RangerX2)

    lda c64lib.SPRITE_0_Y
    sta RangerY1
    clc
    adc #21
    sta RangerY2

    // Collision happened if OtherSprite coordinates is inside Ranger
    // square. This means that
    // * RangerX1 < OtherX < RangerX2
    // * RangerY1 < OtherY < RangerY2

    // REMIND: BMI means jump if first value is lower than second value

    // Is like if OtherX < RangerX1 then jump (no collision)
    bmi16(OtherX, RangerX1)             // OtherSpriteX - Ranger Left
    bmi NoCollisionDetected

    // Is like if RangerX2 < OtherX then jump (no collision)
    bmi16(RangerX2, OtherX)             // Ranger Right - OtherSpriteX
    bmi NoCollisionDetected

    // Is like if OtherY < RangerY1 then jump (no collision)
    lda OtherY
    cmp RangerY1
    bmi NoCollisionDetected     // branch to end if value is smaller than low

    // Is like if RangerY2 < OtherY then jump (no collision)
    lda RangerY2
    cmp OtherY
    bmi NoCollisionDetected     // branch to end if value is smaller than low

  CollisionDetected:
    lda #$01
    jmp Done

  NoCollisionDetected:
    lda #$00

  Done:
    rts

// Ranger square
  RangerX1: .word $0000
  RangerX2: .word $0000
  RangerY1: .byte $00
  RangerY2: .byte $00

// Other sprite initial coordinate
  OtherX: .word $0000
  OtherY: .byte $00
}

* = * "Utils BackgroundCollision"
BackgroundCollision: {
    lda c64lib.SPRITE_2B_COLLISION
    and #%00000001

    sta Collision
    rts

  Collision: .byte $00
}

.macro add16byte(value, dest) {
    clc
    lda dest
    adc value
    sta dest
    bcc !+
    inc dest + 1
  !:
}
.assert "add16byte($cc, $0123) ", { add16byte($cc, $0123) }, {
  clc; lda $0123; adc $cc; sta $0123; bcc !+; inc $0124; !:
}

.macro add16value(value, dest) {
    clc
    lda dest
    adc #<value
    sta dest
    lda dest + 1
    adc #>value
    sta dest + 1
}
.assert "add16value($0102, $0123) ", { add16value($0102, $0123) }, {
  clc; lda $0123; adc #<$0102; sta $0123 ; lda $0124 ; adc #>$0102 ; sta $0124
}

.macro sub16byte(value, dest) {
    sec
    lda dest
    sbc value
    sta dest
    lda dest + 1
    sbc #$00
    sta dest + 1
}
.assert "sub16byte($cc, $0123) ", { sub16byte($cc, $0123) }, {
  sec; lda $0123; sbc $cc; sta $0123; lda $0124; sbc #$00; sta $0124
}

.macro ShowComplain(address, x, y) {
    lda #<address
    sta ShowComplainRoutine.Dummy
    lda #>address
    sta ShowComplainRoutine.Dummy + 1

    c64lib_add16((y * 40) + x, ShowComplainRoutine.Dummy)

    jsr ShowComplainRoutine
}

* = * "Utils ShowComplain"
ShowComplainRoutine: {
    lda Dummy
    sta HandleEnemyFined.MapComplain
    lda Dummy + 1
    sta HandleEnemyFined.MapComplain + 1
    lda #0
    sta HandleEnemyFined.AddOrSub    
    jmp HandleEnemyFined  // jsr + rts

  Dummy: .word $beef
}

* = * "Utils HandleEnemyFined"
HandleEnemyFined: {
// Char self mod
    lda ComplainChars
    sta EditMap1 + 1
    lda ComplainChars + 1
    sta EditMap2 + 1
    lda ComplainChars + 2
    sta EditMap3 + 1

    lda ComplainChars + 3
    sta EditMap4 + 1
    lda ComplainChars + 4
    sta EditMap5 + 1
    lda ComplainChars + 5
    sta EditMap6 + 1

    lda AddOrSub
    beq MapSelfModAreaRow1
    cmp #$ff
    beq !Add+
  !Sub:
    sub16byte(Offset, MapComplain)
    jmp MapSelfModAreaRow1

  !Add:
    add16byte(Offset, MapComplain)

  MapSelfModAreaRow1:
    lda MapComplain
    sta EditMap1 + 3
    lda MapComplain + 1
    sta EditMap1 + 4
    c64lib_inc16(MapComplain);

    lda MapComplain
    sta EditMap2 + 3
    lda MapComplain + 1
    sta EditMap2 + 4
    c64lib_inc16(MapComplain);

    lda MapComplain
    sta EditMap3 + 3
    lda MapComplain + 1
    sta EditMap3 + 4

  MapSelfModAreaRow2:
    add16value($0026, MapComplain)

    lda MapComplain
    sta EditMap4 + 3
    lda MapComplain + 1
    sta EditMap4 + 4
    c64lib_inc16(MapComplain);

    lda MapComplain
    sta EditMap5 + 3
    lda MapComplain + 1
    sta EditMap5 + 4
    c64lib_inc16(MapComplain);

    lda MapComplain
    sta EditMap6 + 3
    lda MapComplain + 1
    sta EditMap6 + 4

  EditMap1:
    lda #$00
    sta $beef
  EditMap2:
    lda #$00
    sta $beef
  EditMap3:
    lda #$00
    sta $beef

  EditMap4:
    lda #$00
    sta $beef
  EditMap5:
    lda #$00
    sta $beef
  EditMap6:
    lda #$00
    sta $beef

    rts

  ComplainChars:  .byte $9e, $9f, $a0, $a1, $a2, $a3
  AddOrSub:       .byte $00   // $ff means add, $01 means sub, otherwise no offset
  Offset:         .byte $00   // Offset to add or sub from the position
  MapComplain:    .word $4569
}

.macro HideComplain(address, x, y) {
    lda #<address
    sta HideComplainRoutine.Dummy
    lda #>address
    sta HideComplainRoutine.Dummy + 1

    c64lib_add16((y * 40) + x, HideComplainRoutine.Dummy)

    jsr HideComplainRoutine
}

* = * "Utils HideComplainRoutine"
HideComplainRoutine: {
    lda Dummy
    sta HandleEnemyFinedOut.MapComplain
    lda Dummy + 1
    sta HandleEnemyFinedOut.MapComplain + 1
    lda #$00
    sta HandleEnemyFinedOut.AddOrSub
    jmp HandleEnemyFinedOut  // jsr + rts

  Dummy: .word $beef
}

* = * "Utils HandleEnemyFinedOut"
HandleEnemyFinedOut: {
    lda AddOrSub
    beq MapSelfModAreaRow1
    cmp #$ff
    beq !Add+
  !Sub:
    sub16byte(Offset, MapComplain)
    jmp MapSelfModAreaRow1

  !Add:
    add16byte(Offset, MapComplain)

  MapSelfModAreaRow1:
    lda MapComplain
    sta EditMap1 + 1
    lda MapComplain + 1
    sta EditMap1 + 2
    c64lib_inc16(MapComplain);

    lda MapComplain
    sta EditMap2 + 1
    lda MapComplain + 1
    sta EditMap2 + 2
    c64lib_inc16(MapComplain);

    lda MapComplain
    sta EditMap3 + 1
    lda MapComplain + 1
    sta EditMap3 + 2

  MapSelfModAreaRow2:
    add16value($0026, MapComplain)

    lda MapComplain
    sta EditMap4 + 1
    lda MapComplain + 1
    sta EditMap4 + 2
    c64lib_inc16(MapComplain);

    lda MapComplain
    sta EditMap5 + 1
    lda MapComplain + 1
    sta EditMap5 + 2
    c64lib_inc16(MapComplain);

    lda MapComplain
    sta EditMap6 + 1
    lda MapComplain + 1
    sta EditMap6 + 2

  EditCharMap1:
    lda FixComplainChars
  EditMap1:
    sta $beef
  EditMap2:
    sta $beef
  EditMap3:
    sta $beef

  EditMap4:
    sta $beef
  EditMap5:
    sta $beef
  EditMap6:
    sta $beef

    rts

  FixComplainChars: .byte $00
  AddOrSub:         .byte $00   // $ff means add, $01 means sub, otherwise no offset
  Offset:           .byte $00   // Offset to add or sub from the position
  MapComplain:      .word $4569 //, $456a, $456b, $4591, $4592, $4593
}

* = * "Utils SetColorToChars"
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

  ScreenMemoryAddress: .byte $be

  .label DummyScreenRam = $be00

  CleanLoop: .byte $03
}

// Generates a random number up to maxNumber (excluded)
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

.macro DrawAccumulator(position) {
    pha
    and #$0f
    cmp #$0a
    bpl !bigger+
    clc
    adc #$2a
    jmp !write+

  !bigger:
    sec
    sbc #$08

  !write:
    sta position + 1

    pla
    and #$f0
    clc
    ror
    ror
    ror
    ror
    cmp #$0a
    bpl !bigger+
    clc
    adc #$2a
    jmp !write+

  !bigger:
    sec
    sbc #$08

  !write:
    sta position
}

#import "common/lib/math-global.asm"
#import "chipset/lib/vic2.asm"
#import "chipset/lib/vic2-global.asm"

#import "_allimport.asm"
#import "_sounds.asm"
