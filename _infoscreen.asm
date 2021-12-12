////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Manager for informative screen.
//
////////////////////////////////////////////////////////////////////////////////

#importonce

InfoScreen: {
  Handler: {
      CopyScreenRam($4000, MapDummyArea)

      ClearScreen($4000)

      lda #$02
      sta VIC.BORDER_COLOR
      sta VIC.BACKGROUND_COLOR

      lda #SPRITES.RANGER_STANDING
      sta SPRITE_0
      ldy #$50
      sty SPRITES.Y0

      lda #SPRITES.ENEMY_STANDING
      sta SPRITE_1

      ldy #$74
      sty SPRITES.Y1

      lda #SPRITES.TANK_BODY_LE
      sta SPRITE_2
      lda #SPRITES.TANK_TAIL_LE
      sta SPRITE_3

      ldy #$98
      sty SPRITES.Y2
      sty SPRITES.Y3

      ldx #$30
      stx SPRITES.X0
      stx SPRITES.X1
      stx SPRITES.X2
      ldx #$45
      stx SPRITES.X3

      lda #0
      sta SPRITES.EXTRA_BIT

      lda #$07
      sta SPRITES.COLOR0
      lda #$08
      sta SPRITES.COLOR1

      lda #$01
      sta SPRITES.COLOR2
      sta SPRITES.COLOR3

      EnableMultiSprite(%01111111, true)
    !:
      IsReturnPressed()
      beq !-

      jsr DisableAllSprites

      lda #$09
      sta VIC.BORDER_COLOR
      sta VIC.BACKGROUND_COLOR

      CopyScreenRam(MapDummyArea, $4000)

      rts

    .label SPRITE_0     = $43f8
    .label SPRITE_1     = $43f9
    .label SPRITE_2     = $43fa
    .label SPRITE_3     = $43fb
    .label SPRITE_4     = $43fc
    .label SPRITE_5     = $43fd
    .label SPRITE_6     = $43fe
    .label SPRITE_7     = $43ff
  }
}

#import "_utils.asm"
