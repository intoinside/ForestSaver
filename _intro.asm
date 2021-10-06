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

      lda #$43
      sta DrawHiScore.SelfMod + 2

      lda #$9a
      sta DrawHiScore.SelfMod + 1

      jsr DrawHiScore

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
      lda $4093
      cmp #$5f
      beq !+
      ldx #$5f
      jmp !Set+
    !:
      ldx #$65

    !Set:
      stx $4093

      lda $40ba
      cmp #$66
      beq !+
      ldx #$66
      jmp !Set+
    !:
      ldx #$62

    !Set:
      stx $40ba
      rts
  }

  * = * "Intro AnimateIntro2"
  AnimateIntro2: {
      lda $420c
      cmp #$62
      beq !+
      ldx #$62
      jmp !Set+
    !:
      ldx #$66

    !Set:
      stx $420c

      lda $420d
      cmp #$63
      beq !+
      ldx #$63
      jmp !Set+
    !:
      ldx #$67

    !Set:
      stx $420d

      rts
  }

  * = * "Intro AnimateIntro3"
  AnimateIntro3: {
      lda $432d
      cmp #$63
      beq !+
      ldx #$63
      jmp !Set+
    !:
      ldx #$67

    !Set:
      stx $432d

      lda $4305
      cmp #$5f
      beq !+
      ldx #$5f
      jmp !Set+
    !:
      ldx #$65

    !Set:
      stx $4305

      rts
  }

  * = * "Intro AnimateIntro4"
  AnimateIntro4: {
      lda $431b
      cmp #$62
      beq !+
      ldx #$62
      jmp !Set+
    !:
      ldx #$66

    !Set:
      stx $431b

      lda $431c
      cmp #$63
      beq !+
      ldx #$63
      jmp !Set+
    !:
      ldx #$67

    !Set:
      stx $431c

      rts
  }

  * = * "Intro DrawScore"
  DrawHiScore: {
      ldx #$00
    LoopScore:
      lda HiScoreLabel, x
    SelfMod:
      sta ScorePtr
      inc SelfMod + 1

      inx
      cpx #$0e
      bne LoopScore

      lda SelfMod + 1
      sbc #$0e
      sta SelfMod + 1

      rts

      .label ScorePtr = $beef
  }

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
                .byte $2a, $2a, $2a, $2a

}

#import "_label.asm"
#import "_joystick.asm"
#import "main.asm"
