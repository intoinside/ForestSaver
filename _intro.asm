////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Manager for intro screen.
//
////////////////////////////////////////////////////////////////////////////////

#importonce

Intro: {

// Manager of intro screen
  * = * "Intro IntroManager"
  Manager: {
      jsr Init
      jsr AddColorToMap
      jsr StupidWaitRoutine

    CheckFire:
      jsr WaitRoutine
      jsr TimedRoutine
      jsr GetJoystickMove

      lda FirePressed
      beq CheckFire

    NoMovement:
      jsr Finalize

      rts
  }

  // Initialization of intro screen
  * = * "Intro Init"
  Init: {
  // Set background and border color to black
      lda #$08
      sta VIC.BORDER_COLOR
      sta VIC.BACKGROUND_COLOR

      lda #$00
      sta VIC.EXTRA_BACKGROUND1
      lda #$01
      sta VIC.EXTRA_BACKGROUND2

// Set pointer to char memory to $7800-$7fff (xxxx111x)
// and pointer to screen memory to $4000-$43ff (0000xxxx)
      lda #%00001110
      sta VIC.MEMORY_SETUP

      jsr Hud.ResetScore

      jsr DrawHiScore

      jsr Instruction

      // jsr Copyright
      // jsr Copyright2

      rts
  }

  Finalize: {
      // Reset game var
      lda #$00
      sta GameEnded

      rts
  }

  * = * "Intro AnimateIntro1"
  AnimateIntro1: {
      lda Char1
      cmp #$5e
      beq !+
      ldx #$5e
      jmp !Set+
    !:
      ldx #$64

    !Set:
      stx Char1

      lda Char2
      cmp #$65
      beq !+
      ldx #$65
      jmp !Set+
    !:
      ldx #$61

    !Set:
      stx Char2
      rts

    .label Char1 = $4000 + (40 * 3 + 27)
    .label Char2 = $4000 + (40 * 4 + 26)
  }

  * = * "Intro AnimateIntro2"
  AnimateIntro2: {
      lda Char1
      cmp #$61
      beq !+
      ldx #$61
      jmp !Set+
    !:
      ldx #$65

    !Set:
      stx Char1

      lda Char2
      cmp #$62
      beq !+
      ldx #$62
      jmp !Set+
    !:
      ldx #$66

    !Set:
      stx Char2

      rts

    .label Char1 = $4000 + (40 * 13 + 4)
    .label Char2 = $4000 + (40 * 13 + 5)
  }

  * = * "Intro AnimateIntro3"
  AnimateIntro3: {
      lda Char1
      cmp #$62
      beq !+
      ldx #$62
      jmp !Set+
    !:
      ldx #$66

    !Set:
      stx Char1

      lda Char2
      cmp #$5e
      beq !+
      ldx #$5e
      jmp !Set+
    !:
      ldx #$64

    !Set:
      stx Char2

      rts

    .label Char1 = $4000 + (40 * 20 + 10)
    .label Char2 = $4000 + (40 * 19 + 10)
  }

  * = * "Intro AnimateIntro4"
  AnimateIntro4: {
      lda Char1
      cmp #$61
      beq !+
      ldx #$61
      jmp !Set+
    !:
      ldx #$65

    !Set:
      stx Char1

      lda Char2
      cmp #$62
      beq !+
      ldx #$62
      jmp !Set+
    !:
      ldx #$66

    !Set:
      stx Char2

      rts

    .label Char1 = $4000 + (40 * 19 + 35)
    .label Char2 = $4000 + (40 * 19 + 36)
  }

  * = * "Intro DrawHiScore"
  DrawHiScore: {
      ldx #$00
    LoopScore:
      lda HiScoreLabel, x
      sta ScorePtr, x
      inx
      cpx #$0e
      bne LoopScore

      rts

      .label ScorePtr = $4372
  }

  * = * "Intro Instruction"
  Instruction: {
      ldx #InstructionLabelLen
    LabelLoop:
      lda InstructionLabel, x
      sta $4387, x
      dex
      bne LabelLoop

      rts

  // "JOYSTICK PORT 2"
    .label InstructionLabelLen = $0f
    InstructionLabel: .byte $00, $0b, $10, $1a, $14, $15, $0a, $04, $0c, $00
                      .byte $11, $10, $13, $15, $00, $2c
  }

/*
  * = * "Intro Copyright"
  Copyright: {
      ldx #CopyrightLabelLen
    LabelLoop:
      lda CopyrightLabel, x
      sta $439e, x
      dex
      bne LabelLoop

      rts

  // "RAFFAELE.INTORCIA@GMAIL.COM"
    .label CopyrightLabelLen = $1B
    CopyrightLabel: .byte $00, $13, $02, $07, $07, $02, $06, $0D, $06, $28
                    .byte $0a, $0f, $15, $10, $13, $04, $0a, $02, $01
                    .byte $08, $0e, $02, $0a, $0d, $28, $04, $10, $0e
  }

  * = * "Intro Copyright2"
  Copyright2: {
      ldx #CopyrightLabelLen
    LabelLoop:
      lda CopyrightLabel, x
      sta $43cc, x
      dex
      bne LabelLoop

      rts

  // "INTOINSIDE (c)"
    .label CopyrightLabelLen = $0e
    CopyrightLabel: .byte $00, $0a, $0f, $15, $10, $0a, $0f, $14, $0a, $05
                    .byte $06, $00, $22, $04, $23
  }
*/
  AddColorToMap: {
      lda #$40
      sta SetColorToChars.ScreenMemoryAddress

      jsr SetColorToChars

      rts
  }

  * = * "Intro TimedRoutine"
  TimedRoutine: {
      lda DelayCounter
      beq DelayTriggered        // when counter is zero stop decrementing
      dec DelayCounter      // decrement the counter
      cmp #10
      beq Delay10
      cmp #20
      beq Delay20
      cmp #30
      beq Delay30
      cmp #40
      beq Delay40

      jmp Exit

    Delay10:
      jsr AnimateIntro1
      jmp Exit

    Delay20:
      jsr AnimateIntro2
      jmp Exit

    Delay30:
      jmp Exit

    Delay40:
      jsr AnimateIntro3
      jmp Exit

    DelayTriggered:
      jsr AnimateIntro4

      lda DelayRequested      // delay reached 0, reset it
      sta DelayCounter

    Waiting:

      jmp Exit

    NotWaiting:

    Exit:
      rts

    DelayCounter:
      .byte 50                  // Counter storage
    DelayRequested:
      .byte 50                  // 1 second delay
  }

  // "HI-SCORE: 0000"
  HiScoreLabel: .byte $09, $0a, $27, $14, $04, $10, $13, $06, $34, $00
                .byte ZeroChar, ZeroChar, ZeroChar, ZeroChar

  .label ZeroChar = $2a
}

#import "_label.asm"
#import "_joystick.asm"
#import "main.asm"
