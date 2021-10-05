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

  * = * "Hud ReduceDismissalCounter"
  ReduceDismissalCounter: {
      ldx #$10
    !:
      lda DismissalLabel, x
      cmp #DismissalAliveChar
      beq Reduce
      dex
      cpx #$09
      bne !-

      // Dismissal NOW!!!!
    RangerDismissal:
      jmp Done

    Reduce:
      lda #$00
      sta DismissalLabel, x

    Done:
      jsr DrawDismissal
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

      lda SelfMod + 1
      sbc #$06
      sta SelfMod + 1

      rts

      .label ScorePtr = $beef
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
      cpx #$11
      bne LoopDismissal

      lda SelfMod + 1
      sbc #$11
      sta SelfMod + 1

      rts

      .label DismissalPtr = $beef
  }

  // "SCORE: "
  ScoreLabel: .byte $7d, $6d, $79, $7c, $6f, $9d

  // "DISMISSAL: ******"
  DismissalLabel: .byte $6e, $73, $7d, $77, $73, $7d, $7d, $6b, $76, $9d, $00
                  .byte DismissalAliveChar, DismissalAliveChar, DismissalAliveChar
                  .byte DismissalAliveChar, DismissalAliveChar, DismissalAliveChar

  .label DismissalAliveChar = $a4

  ScreenMemoryAddress:
    .word $be00
}

#import "_label.asm"
