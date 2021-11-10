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

.macro AddPoints(digit4, digit3, digit2, digit1) {
    lda #digit1
    sta Hud.AddScore.Points + 3
    lda #digit2
    sta Hud.AddScore.Points + 2
    lda #digit3
    sta Hud.AddScore.Points + 1
    lda #digit4
    sta Hud.AddScore.Points

    jsr Hud.AddScore
}

.macro SubPoints(digit4, digit3, digit2, digit1) {
    lda #digit1
    sta Hud.SubScore.Points + 3
    lda #digit2
    sta Hud.SubScore.Points + 2
    lda #digit3
    sta Hud.SubScore.Points + 1
    lda #digit4
    sta Hud.SubScore.Points

    jsr Hud.SubScore
}

CompareAndUpdateHiScore: {
    lda Intro.HiScoreLabel + $0a
    cmp Hud.ScoreLabel + $07
    bcc UpdateHiScore1
    lda Intro.HiScoreLabel + $0b
    cmp Hud.ScoreLabel + $08
    bcc UpdateHiScore2
    lda Intro.HiScoreLabel + $0c
    cmp Hud.ScoreLabel + $09
    bcc UpdateHiScore3
    lda Intro.HiScoreLabel + $0d
    cmp Hud.ScoreLabel + $0a
    bcc UpdateHiScore4
    jmp !+

  UpdateHiScore1:
    lda Hud.ScoreLabel + $07
    sta Intro.HiScoreLabel + $0a
  UpdateHiScore2:
    lda Hud.ScoreLabel + $08
    sta Intro.HiScoreLabel + $0b
  UpdateHiScore3:
    lda Hud.ScoreLabel + $09
    sta Intro.HiScoreLabel + $0c
  UpdateHiScore4:
    lda Hud.ScoreLabel + $0a
    sta Intro.HiScoreLabel + $0d

  !:
    rts
}

Hud: {
  * = * "Hud Init"
  Init: {
// ScreenMemoryAddress points to first byte of Hud
      clc
      lda ScreenMemoryAddress
      adc #$03
      sta DrawScore.SelfMod + 2
      sta DrawDismissal.SelfMod + 2

      lda ScreenMemoryAddress + 1
      adc #$98
      sta DrawScore.SelfMod + 1
      sta DrawDismissal.SelfMod + 1

      jsr DrawScore

      lda DrawDismissal.SelfMod + 1
      adc #$16
      sta DrawDismissal.SelfMod + 1

      jsr DrawDismissal

      rts
  }

  * = * "Hud AddScore"
  AddScore: {
      ldx #$03
      clc
    !:
      lda CurrentScore, x
      adc Points, x
      cmp #10
      bcc SaveDigit
      sbc #10
      sec

    SaveDigit:
      sta CurrentScore, x
      dex
      bne !-

    Done:
      jsr DrawScore
      rts

    Points: .byte $00, $00, $00, $00
  }

  * = * "Hud SubScore"
  SubScore: {
      ldx #$04
      sec
    !:
      lda CurrentScore - 1, x

      sbc Points - 1, x
      bpl SaveDigit
      adc #10
      clc

    SaveDigit:
      sta CurrentScore - 1, x
      dex
      bne !-

    Done:
      jsr DrawScore
      rts

    Points: .byte $00, $00, $00, $00
  }

  * = * "Hud ResetScore"
  ResetScore: {
      ldx #$03
      lda #$00
    !:
      sta CurrentScore, x
      dex
      bne !-

      rts
  }

  * = * "Hud DrawScore"
  DrawScore: {
    // Append current score on score label
      ldx #$00
      clc
    !:
      lda CurrentScore, x
      adc #ZeroChar
      sta ScoreLabel + $07, x
      inx
      cpx #$04
      bne !-

    // Draws score label
      ldx #$00
    LoopScore:
      lda ScoreLabel, x
    SelfMod:
      sta ScorePtr
      inc SelfMod + 1

      inx
      cpx #$0b
      bne LoopScore

      lda SelfMod + 1
      sbc #$0b
      sta SelfMod + 1

      rts

    .label ScorePtr = $beef
  }

  * = * "Hud IsScoreBiggerThanZero"
  IsScoreBiggerThanZero: {
      ldx #$04
      ldy #$00
    !:
      lda CurrentScore - 1, x
      bne NonZero
      dex
      bne !-
      jmp !+

    NonZero:
      iny
    !:
      sty BiggerThanZero
      rts

    BiggerThanZero: .byte $00
  }

  * = * "Hud ReduceDismissalCounter"
  ReduceDismissalCounter: {
      lda DismissalCompleted
      bne Done

      ldx #$10
    !:
      lda DismissalLabel, x
      cmp #DismissalAliveChar
      beq Reduce
      dex
      cpx #$0b
      bne !-

    RangerDismissal:
      lda #$00
      sta DismissalLabel + $0b
      inc DismissalCompleted
      jmp Done

    Reduce:
      lda #$00
      sta DismissalLabel, x

    Done:
      jsr DrawDismissal
      rts

    DismissalCompleted: .byte $00
  }

  * = * "Hud ResetDismissalCounter"
  ResetDismissalCounter: {
      ldx #05
      lda #DismissalAliveChar
    !:
      sta DismissalLabel + $0a, x
      dex
      bne !-

      rts
  }

  * = * "Hud DrawDismissal"
  DrawDismissal: {
      ldx #$00
    LoopDismissal:
      lda DismissalLabel, x
    SelfMod:
      sta DismissalPtr
      inc SelfMod + 1

      inx
      cpx #$10
      bne LoopDismissal

      lda SelfMod + 1
      sbc #$10
      sta SelfMod + 1

      rts

      .label DismissalPtr = $beef
  }

  CurrentScore: .byte $00, $00, $00, $00

  // "SCORE: 0000"
  ScoreLabel: .byte $14, $04, $10, $13, $06, $34, $00
              .byte ZeroChar, ZeroChar, ZeroChar, ZeroChar

  .label ZeroChar = $2a


  // "DISMISSAL: *****"
  DismissalLabel: .byte $05, $0a, $14, $0e, $0a, $14, $14, $02, $0d, $34, $00
                  .byte DismissalAliveChar, DismissalAliveChar, DismissalAliveChar
                  .byte DismissalAliveChar, DismissalAliveChar

  .label DismissalAliveChar = $a4

  ScreenMemoryAddress:
    .word $be00
}

#import "_label.asm"
