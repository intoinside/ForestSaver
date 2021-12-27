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

.filenamespace InfoScreen

Handler: {
    CopyScreenRam($4000, MapDummyArea)

    ClearScreen($4000)

    lda #$02
    sta c64lib.BORDER_COL
    sta c64lib.BG_COL_0

    lda #SPRITES.RANGER_STANDING
    sta SPRITE_0
    ldy #$58
    sty c64lib.SPRITE_0_Y

    lda #SPRITES.ENEMY_STANDING
    sta SPRITE_1
    ldy #$70
    sty c64lib.SPRITE_1_Y

    lda #SPRITES.TANK_BODY_LE
    sta SPRITE_2
    lda #SPRITES.TANK_TAIL_LE
    sta SPRITE_3
    ldy #$8c
    sty c64lib.SPRITE_2_Y
    sty c64lib.SPRITE_3_Y

    ldx #$30
    stx c64lib.SPRITE_0_X
    stx c64lib.SPRITE_1_X
    stx c64lib.SPRITE_2_X
    ldx #$45
    stx c64lib.SPRITE_3_X

    lda #0
    sta c64lib.SPRITE_MSB_X

    lda #$07
    sta c64lib.SPRITE_0_COLOR
    lda #$08
    sta c64lib.SPRITE_1_COLOR

    lda #$01
    sta c64lib.SPRITE_2_COLOR
    sta c64lib.SPRITE_3_COLOR

    EnableMultiSprite(%01111111, true)

// Draw text instruction
    ldx #Title1LabelLen
  !:
    lda Title1Label, x
    sta ScreenMemoryBaseAddress + c64lib_getTextOffset(2, 1), x
    dex
    bne !-

    ldx #Title2LabelLen
  !:
    lda Title2Label, x
    sta ScreenMemoryBaseAddress + c64lib_getTextOffset(2, 2), x
    dex
    bne !-

    ldx #Title3LabelLen
  !:
    lda Title3Label, x
    sta ScreenMemoryBaseAddress + c64lib_getTextOffset(2, 3), x
    dex
    bne !-

    ldx #RangerLabelLen
  !:
    lda RangerLabel, x
    sta ScreenMemoryBaseAddress + c64lib_getTextOffset(10, 6), x
    dex
    bne !-

    ldx #WoodcutterLabelLen
  !:
    lda WoodcutterLabel, x
    sta ScreenMemoryBaseAddress + c64lib_getTextOffset(10, 9), x
    dex
    bne !-

    ldx #TankLabelLen
  !:
    lda TankLabel, x
    sta ScreenMemoryBaseAddress + c64lib_getTextOffset(10, 12), x
    dex
    bne !-

    ldx #FireLabelLen
  !:
    lda FireLabel, x
    sta ScreenMemoryBaseAddress + c64lib_getTextOffset(2, 20), x
    dex
    bne !-

    ldx #Fire2LabelLen
  !:
    lda Fire2Label, x
    sta ScreenMemoryBaseAddress + c64lib_getTextOffset(8, 21), x
    dex
    bne !-

    ldx #Fire3LabelLen
  !:
    lda Fire3Label, x
    sta ScreenMemoryBaseAddress + c64lib_getTextOffset(2, 23), x
    dex
    bne !-

    SetupColorMap($40)

  !:
    IsBackArrowPressed()
    beq !-

    jsr DisableAllSprites

    CopyScreenRam(MapDummyArea, ScreenMemoryBaseAddress)

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

  .label ScreenMemoryBaseAddress = $4000

  .label SPRITE_0     = ScreenMemoryBaseAddress + $3f8
  .label SPRITE_1     = ScreenMemoryBaseAddress + $3f9
  .label SPRITE_2     = ScreenMemoryBaseAddress + $3fa
  .label SPRITE_3     = ScreenMemoryBaseAddress + $3fb
  .label SPRITE_4     = ScreenMemoryBaseAddress + $3fc
  .label SPRITE_5     = ScreenMemoryBaseAddress + $3fd
  .label SPRITE_6     = ScreenMemoryBaseAddress + $3fe
  .label SPRITE_7     = ScreenMemoryBaseAddress + $3ff
}

#import "_utils.asm"
#import "_label.asm"
#import "_keyboard.asm"
#import "chipset/lib/vic2-global.asm"
