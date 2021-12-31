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

.filenamespace Intro

// Manager of intro screen
* = * "Intro IntroManager"
Manager: {
    jsr Init
    SetupColorMap($40)

  KeyPress:
    jsr WaitRoutine
    jsr TimedRoutine

    IsIKeyPressed()
    beq !+
    jsr InfoScreen.Handler

    jsr Init
    SetupColorMap($40)

  !:
    IsReturnPressed()
    beq KeyPress

  ExitIntroScreen:
    jsr Finalize

    rts
}

// Initialization of intro screen
* = * "Intro Init"
Init: {
// Set background and border color
    lda #ORANGE
    sta c64lib.BORDER_COL
    sta c64lib.BG_COL_0

    lda #BLACK
    sta c64lib.BG_COL_1
    lda #WHITE
    sta c64lib.BG_COL_2

    lda #LIGHT_RED
    sta c64lib.SPRITE_COL_0
    lda #BLACK
    sta c64lib.SPRITE_COL_1

// Set pointer to char memory to $7800-$7fff (xxxx111x)
// and pointer to screen memory to $4000-$43ff (0000xxxx)
    lda #%00001110
    sta c64lib.MEMORY_CONTROL       

    jsr Hud.ResetScore

    jsr DrawHiScore

    jsr Instruction

    // jsr Copyright
    // jsr Copyright2

    rts
}

Finalize: {
    rts
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

    .label ScorePtr = ScreenMemoryBaseAddress + c64lib_getTextOffset(2, 22)
}

* = * "Intro Instruction"
Instruction: {
    ldx #InstructionLabelLen
  LabelLoop:
    lda InstructionLabel, x
    sta ScreenMemoryBaseAddress + c64lib_getTextOffset(23, 22), x
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

* = * "Intro TimedRoutine"
TimedRoutine: {
    lda DelayCounter
    beq DelayTriggeredFar        // when counter is zero stop decrementing
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

  DelayTriggeredFar:
    jmp DelayTriggered

  Delay10:
    AnimateLake(Char1, $5e, $64)
    AnimateLake(Char2, $65, $61)
    jmp Exit

  Delay20:
    AnimateLake(Char3, $61, $65)
    AnimateLake(Char4, $62, $66)
    jmp Exit

  Delay30:
    jmp Exit

  Delay40:
    AnimateLake(Char5, $62, $66)
    AnimateLake(Char6, $5e, $64)
    jmp Exit

  DelayTriggered:
    AnimateLake(Char7, $61, $65)
    AnimateLake(Char8, $62, $66)

    lda DelayRequested      // delay reached 0, reset it
    sta DelayCounter

  Exit:
    rts

// Char position in screen ram
  .label Char1 = ScreenMemoryBaseAddress + c64lib_getTextOffset(27, 3)
  .label Char2 = ScreenMemoryBaseAddress + c64lib_getTextOffset(26, 4)

  .label Char3 = ScreenMemoryBaseAddress + c64lib_getTextOffset(4, 13)
  .label Char4 = ScreenMemoryBaseAddress + c64lib_getTextOffset(5, 13)

  .label Char5 = ScreenMemoryBaseAddress + c64lib_getTextOffset(10, 20)
  .label Char6 = ScreenMemoryBaseAddress + c64lib_getTextOffset(10, 19)

  .label Char7 = ScreenMemoryBaseAddress + c64lib_getTextOffset(35, 19)
  .label Char8 = ScreenMemoryBaseAddress + c64lib_getTextOffset(36, 19)

  DelayCounter:   .byte 50    // Counter storage
  DelayRequested: .byte 50    // 1 second delay
}

// "HI-SCORE: 0000"
HiScoreLabel: .byte $09, $0a, $27, $14, $04, $10, $13, $06, $34, $00
              .byte ZeroChar, ZeroChar, ZeroChar, ZeroChar

.label ZeroChar = $2a

.label ScreenMemoryBaseAddress = $4000

#import "_utils.asm"
#import "_keyboard.asm"
#import "_infoscreen.asm"
#import "_hud.asm"
