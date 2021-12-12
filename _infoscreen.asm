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
      ldy #$58
      sty SPRITES.Y0

      lda #SPRITES.ENEMY_STANDING
      sta SPRITE_1
      ldy #$70
      sty SPRITES.Y1

      lda #SPRITES.TANK_BODY_LE
      sta SPRITE_2
      lda #SPRITES.TANK_TAIL_LE
      sta SPRITE_3
      ldy #$8c
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

// Draw text instruction
      ldx #Title1LabelLen
    !:
      lda Title1Label, x
      sta $4000 + (40 * 1 + 2), x
      dex
      bne !-

      ldx #Title2LabelLen
    !:
      lda Title2Label, x
      sta $4000 + (40 * 2 + 2), x
      dex
      bne !-

      ldx #Title3LabelLen
    !:
      lda Title3Label, x
      sta $4000 + (40 * 3 + 2), x
      dex
      bne !-

      ldx #RangerLabelLen
    !:
      lda RangerLabel, x
      sta $4000 + (40 * 6 + 10), x
      dex
      bne !-

      ldx #WoodcutterLabelLen
    !:
      lda WoodcutterLabel, x
      sta $4000 + (40 * 9 + 10), x
      dex
      bne !-

      ldx #TankLabelLen
    !:
      lda TankLabel, x
      sta $4000 + (40 * 12 + 10), x
      dex
      bne !-

      ldx #FireLabelLen
    !:
      lda FireLabel, x
      sta $4000 + (40 * 20 + 2), x
      dex
      bne !-

      ldx #Fire2LabelLen
    !:
      lda Fire2Label, x
      sta $4000 + (40 * 21 + 8), x
      dex
      bne !-

      ldx #Fire3LabelLen
    !:
      lda Fire3Label, x
      sta $4000 + (40 * 23 + 2), x
      dex
      bne !-

      jsr Intro.AddColorToMap

    !:
      IsBackArrowPressed()
      beq !-

      jsr DisableAllSprites

      CopyScreenRam(MapDummyArea, $4000)

      jsr Intro.Init
      jsr Intro.AddColorToMap

      rts

    .label Title1LabelLen = 30
    Title1Label:      .byte $00, $0e, $10, $17, $06, $00, $13, $02, $0f, $08
                      .byte $06, $13, $00, $02, $04, $13, $10, $14, $14, $00
                      .byte $15, $09, $06, $00, $14, $04, $13, $06, $06, $0f
                      .byte $26

    .label Title2LabelLen = 32
    Title2Label:      .byte $00, $13, $06, $02, $04, $09, $00, $1a, $10, $16
                      .byte $13, $00, $06, $0f, $06, $0e, $0a, $06, $14, $00
                      .byte $02, $0f, $05, $00, $07, $0a, $0f, $06, $00, $15
                      .byte $09, $06, $0e

    .label Title3LabelLen = 20
    Title3Label:      .byte $00, $02, $14, $00, $14, $10, $10, $0f, $00, $02
                      .byte $14, $00, $11, $10, $14, $14, $0a, $03, $0d, $06
                      .byte $28

    .label RangerLabelLen = 11
    RangerLabel:      .byte $00, $1a, $10, $16, $13, $00, $13, $02, $0f, $08
                      .byte $06, $13

    .label WoodcutterLabelLen = 24
    WoodcutterLabel:  .byte $00, $2c, $2a, $00, $11, $10, $0a, $0f, $15, $14
                      .byte $00, $07, $10, $13, $00, $18, $10, $10, $05, $04
                      .byte $16, $15, $15, $06, $13

    .label TankLabelLen = 18
    TankLabel:        .byte $00, $2f, $2a, $00, $11, $10, $0a, $0f, $15, $14
                      .byte $00, $07, $10, $13, $00, $15, $02, $0f, $0c

    .label FireLabelLen = 32
    FireLabel:        .byte $00, $07, $0a, $13, $06, $00, $00, $13, $02, $0f
                      .byte $08, $06, $13, $00, $08, $10, $00, $02, $04, $13
                      .byte $10, $14, $14, $00, $10, $03, $14, $15, $02, $04
                      .byte $0d, $06, $14


    .label Fire2LabelLen = 17
    Fire2Label:       .byte $00, $22, $11, $10, $0a, $0f, $15, $14, $00, $13
                      .byte $06, $12, $16, $0a, $13, $06, $05, $23

    .label Fire3LabelLen = 19
    Fire3Label:       .byte $00, $1d, $00, $00, $00, $00, $00, $03, $02, $04
                      .byte $0c, $00, $15, $10, $00, $0a, $0f, $15, $13, $10

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
