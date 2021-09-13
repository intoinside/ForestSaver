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
      clc
      lda ScreenMemoryAddress
      adc #$03
      sta ScreenMemoryAddress

// Self modify code to use current screen memotry address, update hibyte
      lda ScreenMemoryAddress
      sta Init.LoadSprite1 + 2
      sta UpdateRangerFrame.LoadSprite1 + 2
      sta UpdateRangerFrame.LoadSprite2 + 2
      sta UpdateRangerFrame.LoadSprite3 + 2
      sta UpdateRangerFrame.LoadSprite4 + 2
      sta UpdateRangerFrame.StoreSprite1 + 2
      sta UpdateRangerFrame.StoreSprite2 + 2
      sta UpdateRangerFrame.StoreSprite3 + 2
      sta UpdateRangerFrame.StoreSprite4 + 2

// No need to update lobyte because ranger is always sprite 0
      lda #SPRITES.RANGER_STANDING
    LoadSprite1:
      sta SPRITES.SPRITE_0

      rts
  }

  * = * "Ranger HandleRangerMove"
  HandleRangerMove: {
      lda Direction
      beq CheckDirectionY

      jsr UpdateRangerFrame

// Handle horizontal move
      lda Direction
      cmp #$ff
      beq MoveToLeft

    MoveToRight:
      ldx SPRITES.X0          // Moving to right
      inx                     // Calculate new sprite x position
      beq ToggleExtraBit      // If zero then should toggle extra bit
      lda SPRITES.EXTRA_BIT   // If non zero, check extra bit
      and #$01
      beq UpdateSpriteXPos    // If extra bit not set, then update position
      cpx #LIMIT_RIGHT
      bcs CheckDirectionY     // If extra bit set and new position is over right
      jmp UpdateSpriteXPos    // border, no movement allowed

    ToggleExtraBit:
      lda SPRITES.EXTRA_BIT
      eor #$01
      sta SPRITES.EXTRA_BIT
    UpdateSpriteXPos:
      stx SPRITES.X0
      jmp CheckDirectionY

    MoveToLeft:
      lda SPRITES.EXTRA_BIT   // Moving to right, check extra bit
      and #$01
      bne TryToMoveLeft       // If extra bit is set, then move allowed
      ldx SPRITES.X0          // Check if position is on left border
      cpx #LIMIT_LEFT
      bcc CheckDirectionY     // If extra bit not set and x-position is not on
      dex                     // left border, then move allowed
      jmp UpdateSpriteXPos

    TryToMoveLeft:
      ldx SPRITES.X0          // Calculate new position
      dex
      cpx #$ff
      bne UpdateSpriteXPos    // If position is $ff then extra bit must be
      jmp ToggleExtraBit      // toggled

    CheckDirectionY:
      lda DirectionY
      beq Done

      jsr UpdateRangerFrame

      ldy SPRITES.Y0          // Calculate new position

      lda DirectionY
      cmp #$ff
      beq MoveToUp

    MoveToDown:
      iny
      cpy #LIMIT_DOWN
      bcs Done
      sty SPRITES.Y0

      jmp Done

    MoveToUp:
      dey
      cpy #LIMIT_UP
      bcc Done
      sty SPRITES.Y0

    Done:
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

  .label LIMIT_UP     = $32
  .label LIMIT_DOWN   = $e0
  .label LIMIT_LEFT   = $16
  .label LIMIT_RIGHT  = $46

  ScreenMemoryAddress:
    .word $beef
}

#import "label.asm"
