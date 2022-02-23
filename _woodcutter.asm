////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Handler for enemy type 1 (woodcutter)
//
////////////////////////////////////////////////////////////////////////////////

#importonce

// Set woodcutter position
.macro CallSetPosition(trackX, trackY, xBit, spriteXLow, spriteYLow) {
    lda trackX
    sta WoodCutter.SetPosition.NewX
    lda trackY
    sta WoodCutter.SetPosition.NewY
    lda #spriteXLow
    sta WoodCutter.SetPosition.SpriteXLow
    lda #spriteYLow
    sta WoodCutter.SetPosition.SpriteYLow
    jsr WoodCutter.SetPosition

    lda c64lib.SPRITE_MSB_X
    .if (xBit==0)
    {
      .if (spriteXLow == $00) and #%11111110
      .if (spriteXLow == $02) and #%11111101
      .if (spriteXLow == $04) and #%11111011
      .if (spriteXLow == $06) and #%11110111
      .if (spriteXLow == $08) and #%11101111
      .if (spriteXLow == $0a) and #%11011111
      .if (spriteXLow == $0c) and #%10111111
      .if (spriteXLow == $0e) and #%01111111
    }
    else
    {
      .if (spriteXLow == $00) ora #%00000001
      .if (spriteXLow == $02) ora #%00000010
      .if (spriteXLow == $04) ora #%00000100
      .if (spriteXLow == $06) ora #%00001000
      .if (spriteXLow == $08) ora #%00010000
      .if (spriteXLow == $0a) ora #%00100000
      .if (spriteXLow == $0c) ora #%01000000
      .if (spriteXLow == $0e) ora #%10000000
    }
    sta c64lib.SPRITE_MSB_X
}

// Update woodcutter frame
.macro CallUpdateWoodCutterFrame(directionX, directionY, woodCutterFrame) {
    lda directionX
    sta WoodCutter.UpdateWoodCutterFrame.DirectionX
    lda directionY
    sta WoodCutter.UpdateWoodCutterFrame.DirectionY

    lda woodCutterFrame
    sta WoodCutter.UpdateWoodCutterFrame.WoodCutterFrame

    jsr WoodCutter.UpdateWoodCutterFrame

    lda WoodCutter.UpdateWoodCutterFrame.WoodCutterFrame
    sta woodCutterFrame
}

// Update woodcutter frame with reverse hatchet
.macro CallUpdateWoodCutterFrameReverse(directionX, directionY, woodCutterFrame) {
    lda directionX
    sec
    sbc #2
    sta WoodCutter.UpdateWoodCutterFrame.DirectionX
    lda directionY
    sta WoodCutter.UpdateWoodCutterFrame.DirectionY

    lda woodCutterFrame
    sta WoodCutter.UpdateWoodCutterFrame.WoodCutterFrame

    jsr WoodCutter.UpdateWoodCutterFrame

    lda WoodCutter.UpdateWoodCutterFrame.WoodCutterFrame
    sta woodCutterFrame
  }

.filenamespace WoodCutter

* = * "WoodCutter Init"
Init: {
    clc
    lda ScreenMemoryAddress
    adc #$03
    sta ScreenMemoryAddress

// Self modify code to use current screen memory address, update hibyte
    sta UpdateWoodCutterFrame.LoadSprite1 + 2
    sta UpdateWoodCutterFrame.LoadSprite2 + 2
    sta UpdateWoodCutterFrame.LoadSprite3 + 2
    sta UpdateWoodCutterFrame.LoadSprite4 + 2
    sta UpdateWoodCutterFrame.StoreSprite1 + 2
    sta UpdateWoodCutterFrame.StoreSprite2 + 2
    sta UpdateWoodCutterFrame.StoreSprite3 + 2
    sta UpdateWoodCutterFrame.StoreSprite4 + 2

    rts
}

* = * "WoodCutter UpdateWoodCutterFrame"
UpdateWoodCutterFrame: {
    lda ScreenMemoryAddress + 1
    sta UpdateWoodCutterFrame.LoadSprite1 + 1
    sta UpdateWoodCutterFrame.LoadSprite2 + 1
    sta UpdateWoodCutterFrame.LoadSprite3 + 1
    sta UpdateWoodCutterFrame.LoadSprite4 + 1
    sta UpdateWoodCutterFrame.StoreSprite1 + 1
    sta UpdateWoodCutterFrame.StoreSprite2 + 1
    sta UpdateWoodCutterFrame.StoreSprite3 + 1
    sta UpdateWoodCutterFrame.StoreSprite4 + 1

    inc WoodCutterFrame
    lda WoodCutterFrame
    lsr
    lsr
    lsr
    lsr
    bcc NoMove

    lda #$00
    sta WoodCutterFrame

  LoadDirection:
    lda DirectionX
    beq CheckVerticalMove
    cmp #$ff
    beq Left

  Right:
    ldx #SPRITES.ENEMY_STANDING + 5
  LoadSprite1:
    lda SPRITE_PTR
    cmp #SPRITES.ENEMY_STANDING + 6
    beq RightUpdate
    inx

    jsr Sfx.Walkstep

  RightUpdate:
    // If right frame edit occours, no other frame switch will be performed
  StoreSprite1:
    stx SPRITE_PTR
    jmp NoMove

  Left:
    ldx #SPRITES.ENEMY_STANDING + 7
  LoadSprite2:
    lda SPRITE_PTR
    cmp #SPRITES.ENEMY_STANDING + 8
    beq LeftUpdate
    inx

    jsr Sfx.Walkstep

  LeftUpdate:
    // If left frame edit occours, no other frame switch will be performed
  StoreSprite2:
    stx SPRITE_PTR
    jmp NoMove

  CheckVerticalMove:
  LoadDirectionY:
    lda DirectionY
    beq NoMove
    cmp #$ff
    beq Up

  Down:
    ldx #SPRITES.ENEMY_STANDING + 1
  LoadSprite3:
    lda SPRITE_PTR
    cmp #SPRITES.ENEMY_STANDING + 2
    beq UpUpdate
    inx

    jsr Sfx.Walkstep

  DownUpdate:
  StoreSprite3:
    stx SPRITE_PTR
    jmp NoMove

  Up:
    ldx #SPRITES.ENEMY_STANDING + 3
  LoadSprite4:
    lda SPRITE_PTR
    cmp #SPRITES.ENEMY_STANDING + 4
    beq UpUpdate
    inx

    jsr Sfx.Walkstep

  UpUpdate:
  StoreSprite4:
    stx SPRITE_PTR

  NoMove:
    rts

  WoodCutterFrame: .byte $00
  DirectionX: .byte $00
  DirectionY: .byte $00
}

SetPosition: {
    lda SpriteXLow
    sta SetX + 1
    lda SpriteYLow
    sta SetY + 1

    lda NewX
  SetX:
    sta $d0ef

    lda NewY
  SetY:
    sta $d0ef

  Done:
    rts

  NewX: .byte $00
  NewY: .byte $00
  SpriteXLow: .byte $00
  SpriteYLow: .byte $00
}

ScreenMemoryAddress: .byte $be

.label SPRITE_PTR = $beef

#import "_label.asm"
#import "_sounds.asm"

#import "chipset/lib/vic2.asm"
