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

Keyboard: {
  Init: {
      lda #1
      sta KEYB.BUFFER_LEN     //  disable keyboard buffer
      lda #127
      sta KEYB.REPEAT_SWITCH  // disable key repeat
  }

  * = * "Keyboard IsReturnPressed"
  IsReturnPressed: {
      sei
      lda #%11111111
      sta $dc02
      lda #%00000000
      sta $dc03

      lda #%11111110
      sta $dc00
      lda $dc01
      and #%00000010
      beq Pressed
      lda #$00
      jmp !+
    Pressed:
      lda #$01

    !:
      sta ReturnPressed

      cli
      rts
  }

  * = * "Keyboard IsIKeyPressed"
  IsIKeyPressed: {
      sei
      lda #%11111111
      sta $dc02
      lda #%00000000
      sta $dc03

      lda #%11101111
      sta $dc00
      lda $dc01
      and #%00000010
      beq Pressed
      lda #$00
      jmp !+
    Pressed:
      lda #$01

    !:
      sta IKeyPressed

      cli
      rts
  }

  ReturnPressed:  .byte $00
  IKeyPressed:    .byte $00
}

#import "_label.asm"
