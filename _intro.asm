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
    // jsr Finalize

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

    rts
}

/*
// No finalize needed, keeping for future use
Finalize: {
    rts
}
*/
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
    AnimateLake(Char1, Map.LakeChar3_1, Map.LakeChar3_2)
    AnimateLake(Char2, Map.LakeChar6_2, Map.LakeChar6_1)
    jmp Exit

  Delay20:
    AnimateLake(Char3, Map.LakeChar6_1, Map.LakeChar6_2)
    AnimateLake(Char4, Map.LakeChar7_1, Map.LakeChar7_2)
    jmp Exit

  Delay30:
    jmp Exit

  Delay40:
    AnimateLake(Char5, Map.LakeChar7_1, Map.LakeChar7_2)
    AnimateLake(Char6, Map.LakeChar3_1, Map.LakeChar3_2)
    jmp Exit

  DelayTriggered:
    lda DelayRequested      // delay reached 0, reset it
    sta DelayCounter

  Exit:
    rts

// Char position in screen ram
  .label Char1 = ScreenMemoryBaseAddress + c64lib_getTextOffset(28, 2)
  .label Char2 = ScreenMemoryBaseAddress + c64lib_getTextOffset(27, 3)

  .label Char3 = ScreenMemoryBaseAddress + c64lib_getTextOffset(5, 12)
  .label Char4 = ScreenMemoryBaseAddress + c64lib_getTextOffset(6, 12)

  .label Char5 = ScreenMemoryBaseAddress + c64lib_getTextOffset(34, 19)
  .label Char6 = ScreenMemoryBaseAddress + c64lib_getTextOffset(34, 18)

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
#import "_map.asm"
