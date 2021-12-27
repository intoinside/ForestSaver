////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Routine for keyboard managing
//
////////////////////////////////////////////////////////////////////////////////

#importonce

.macro IsReturnPressed() {
    lda #%11111110
    sta Keyboard.DetectKeyPressed.MaskOnPortA
    lda #%00000010
    sta Keyboard.DetectKeyPressed.MaskOnPortB
    jsr Keyboard.DetectKeyPressed
    sta Keyboard.ReturnPressed
}

.macro IsIKeyPressed() {
    lda #%11101111
    sta Keyboard.DetectKeyPressed.MaskOnPortA
    lda #%00000010
    sta Keyboard.DetectKeyPressed.MaskOnPortB
    jsr Keyboard.DetectKeyPressed
    sta Keyboard.IKeyPressed
}

.macro IsBackArrowPressed() {
    lda #%01111111
    sta Keyboard.DetectKeyPressed.MaskOnPortA
    lda #%00000010
    sta Keyboard.DetectKeyPressed.MaskOnPortB
    jsr Keyboard.DetectKeyPressed
    sta Keyboard.BackArrowPressed
}

.filenamespace Keyboard

Init: {
    lda #1
    sta KEYB.BUFFER_LEN     // disable keyboard buffer
    lda #127
    sta KEYB.REPEAT_SWITCH  // disable key repeat
}

* = * "Keyboard DetectKeyPressed"
DetectKeyPressed: {
    sei
    lda #%11111111
    sta CIA1.PORT_A_DIRECTION
    lda #%00000000
    sta CIA1.PORT_B_DIRECTION

    lda MaskOnPortA
    sta CIA1.PORT_A
    lda CIA1.PORT_B
    and MaskOnPortB
    beq Pressed
    lda #$00
    jmp !+
  Pressed:
    lda #$01
  !:
    cli
    rts

  MaskOnPortA:    .byte $00
  MaskOnPortB:    .byte $00
}

ReturnPressed:    .byte $00
IKeyPressed:      .byte $00
BackArrowPressed: .byte $00

#import "_label.asm"
