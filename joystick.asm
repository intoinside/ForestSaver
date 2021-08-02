////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Routine for joystick managing
//
////////////////////////////////////////////////////////////////////////////////

FirePressed:
  .byte $00

// Read joystick (port 2) status and set FirePressed to $ff if fire is pressed
// $00 otherwise
GetOnlyFirePress: {
    lda $dc00
    ldx #$00
    lsr
    lsr
    lsr
    lsr
    lsr
    bcs !NoFirePressed+
    ldx #$ff
  !NoFirePressed:
    stx FirePressed

    rts
}
