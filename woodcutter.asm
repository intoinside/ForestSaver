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
      lda #SPRITES.ENEMY_STANDING
    LoadSprite1:
      sta SPRITES.SPRITE_1

      lda #$00
      sta SPRITES.X1
      sta SPRITES.Y1

      rts
  }

  * = * "WoodCutter UpdateWoodCutterFrame"
  UpdateWoodCutterFrame: {
      inc WoodCutterFrame
      lda WoodCutterFrame
      lsr
      lsr
 //     lsr
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
      lda SPRITES.SPRITE_1
      cmp #SPRITES.ENEMY_STANDING + 6
      beq RightUpdate
      inx

    RightUpdate:
      // If right frame edit occours, no other frame switch will be performed
    StoreSprite1:
      stx SPRITES.SPRITE_1
      jmp NoMove

    Left:
      ldx #SPRITES.ENEMY_STANDING + 7
    LoadSprite2:
      lda SPRITES.SPRITE_1
      cmp #SPRITES.ENEMY_STANDING + 8
      beq LeftUpdate
      inx

    LeftUpdate:
      // If left frame edit occours, no other frame switch will be performed
    StoreSprite2:
      stx SPRITES.SPRITE_1
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
      lda SPRITES.SPRITE_1
      cmp #SPRITES.ENEMY_STANDING + 2
      beq UpUpdate
      inx

    DownUpdate:
    StoreSprite3:
      stx SPRITES.SPRITE_1
      jmp NoMove

    Up:
      ldx #SPRITES.ENEMY_STANDING + 3
    LoadSprite4:
      lda SPRITES.SPRITE_1
      cmp #SPRITES.ENEMY_STANDING + 4
      beq UpUpdate
      inx

    UpUpdate:
    StoreSprite4:
      stx SPRITES.SPRITE_1

    NoMove:
      rts

    WoodCutterFrame:
      .byte $ff
    DirectionX:
      .byte $00
    DirectionY:
      .byte $00
  }
}

#import "label.asm"
