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

  IsReturnPressed: {
      lda KEYB.CURRENT_PRESSED
      and #$01
      sta ReturnPressed

      rts
  }

  ReturnPressed:  .byte $00
}

#import "_label.asm"
