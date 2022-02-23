////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Tank truck sprite handler
//
////////////////////////////////////////////////////////////////////////////////

#importonce

.macro CallTankSetPosition(trackX, trackY, xBit, spriteXLow, spriteYLow) {
    lda trackX
    sta TankTruck.SetPosition.NewX
    lda #trackY
    sta TankTruck.SetPosition.NewY
    lda #spriteXLow
    sta TankTruck.SetPosition.SpriteXLow
    lda #spriteYLow
    sta TankTruck.SetPosition.SpriteYLow
    jsr TankTruck.SetPosition

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

.filenamespace TankTruck

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

#import "chipset/lib/vic2.asm"
