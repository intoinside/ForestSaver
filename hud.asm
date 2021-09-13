////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Heads-up display
//
// Manager for rows 23-24-25
//
////////////////////////////////////////////////////////////////////////////////

#importonce

Hud: {
  * = * "Hud Init"
  Init: {
// ScreenMemoryAddress points to first byte of Hud
      clc
      lda ScreenMemoryAddress
      adc #$03
      sta ScreenMemoryAddress
      lda ScreenMemoryAddress + 1
      adc #$98
      sta ScreenMemoryAddress + 1

      lda ScreenMemoryAddress
      sta DrawScore.SelfMod + 2
      lda ScreenMemoryAddress + 1
      sta DrawScore.SelfMod + 1

      jsr DrawScore

      rts
  }

  * = * "Hud DrawScore"
  DrawScore: {
      ldx #$00
    LoopScore:
      lda ScoreLabel, x
    SelfMod:
      sta ScorePtr
      inc SelfMod + 1

      inx
      cpx #$06
      bne LoopScore

      rts

      .label ScorePtr = $beef
  }

  // "SCORE: "
  ScoreMap: .byte $00
  ScoreLabel: .byte $7d, $6d, $79, $7c, $6f, $9d, $00

  ScreenMemoryAddress:
    .word $be00
}

#import "label.asm"
