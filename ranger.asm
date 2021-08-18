////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Ranger sprite handler
//
////////////////////////////////////////////////////////////////////////////////

#importonce

Ranger: {
  * = * "Ranger Init"
  Init: {
      lda #SPRITES.RANGER_STANDING
    LoadSprite1:
      sta SPRITES.SPRITE_0

      lda #$50
      sta SPRITES.X0
      lda #$40
      sta SPRITES.Y0

      rts
  }

  * = * "Ranger UpdateRangerFrame"
  UpdateRangerFrame: {
      inc RangerFrame
      lda RangerFrame
      lsr
      lsr
      lsr
      lsr
      bcc NoMove

      lda #$00
      sta RangerFrame

      lda Direction
      beq CheckVerticalMove
      cmp #$ff
      beq Left

    Right:
      ldx #SPRITES.RANGER_STANDING + 5
    LoadSprite1:
      lda SPRITES.SPRITE_0
      cmp #SPRITES.RANGER_STANDING + 6
      beq RightUpdate
      inx

    RightUpdate:
      // If right frame edit occours, no other frame switch will be performed
    StoreSprite1:
      stx SPRITES.SPRITE_0
      jmp NoMove

    Left:
      ldx #SPRITES.RANGER_STANDING + 7
    LoadSprite2:
      lda SPRITES.SPRITE_0
      cmp #SPRITES.RANGER_STANDING + 8
      beq LeftUpdate
      inx

    LeftUpdate:
      // If left frame edit occours, no other frame switch will be performed
    StoreSprite2:
      stx SPRITES.SPRITE_0
      jmp NoMove

    CheckVerticalMove:
      lda DirectionY
      beq NoMove
      cmp #$ff
      beq Up

    Down:
      ldx #SPRITES.RANGER_STANDING + 1
    LoadSprite3:
      lda SPRITES.SPRITE_0
      cmp #SPRITES.RANGER_STANDING + 2
      beq UpUpdate
      inx

    DownUpdate:
    StoreSprite3:
      stx SPRITES.SPRITE_0
      jmp NoMove

    Up:
      ldx #SPRITES.RANGER_STANDING + 3
    LoadSprite4:
      lda SPRITES.SPRITE_0
      cmp #SPRITES.RANGER_STANDING + 4
      beq UpUpdate
      inx

    UpUpdate:
    StoreSprite4:
      stx SPRITES.SPRITE_0

    NoMove:
      rts

    RangerFrame:
      .byte $ff
  }
}

#import "label.asm"
