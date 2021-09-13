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

WoodCutter: {
  * = * "WoodCutter Init"
  Init: {
      clc
      lda ScreenMemoryAddress
      adc #$03
      sta ScreenMemoryAddress

// Self modify code to use current screen memotry address, update hibyte
      lda ScreenMemoryAddress
      sta LoadSprite1 + 2
      sta UpdateWoodCutterFrame.LoadSprite1 + 2
      sta UpdateWoodCutterFrame.LoadSprite2 + 2
      sta UpdateWoodCutterFrame.LoadSprite3 + 2
      sta UpdateWoodCutterFrame.LoadSprite4 + 2
      sta UpdateWoodCutterFrame.StoreSprite1 + 2
      sta UpdateWoodCutterFrame.StoreSprite2 + 2
      sta UpdateWoodCutterFrame.StoreSprite3 + 2
      sta UpdateWoodCutterFrame.StoreSprite4 + 2

// Update lobyte
      lda ScreenMemoryAddress + 1
      sta LoadSprite1 + 1

      lda #SPRITES.ENEMY_STANDING
    LoadSprite1:
      sta SPRITE_PTR

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

    UpUpdate:
    StoreSprite4:
      stx SPRITE_PTR

    NoMove:
      rts

    WoodCutterFrame:
      .byte $00
    DirectionX:
      .byte $00
    DirectionY:
      .byte $00
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

    NewX:
      .byte $00
    NewY:
      .byte $00
    SpriteXLow:
      .byte $00
    SpriteYLow:
      .byte $00
  }

  ScreenMemoryAddress:
    .word $be00

  .label SPRITE_PTR = $beef
}

#import "label.asm"
