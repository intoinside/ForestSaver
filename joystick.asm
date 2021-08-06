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

GetJoystickMove: {
    ldx #$00
    lda $dc00
    ldy GameEnded
    bne CheckOnlyFirePress
    lsr
    bcs !NoUp+
    ldx #$ff

  !NoUp:
    lsr
    bcs !NoDown+
  !NoDown:
    stx DirectionY
    ldx #$00
    lsr
    bcs !NoLeft+
    ldx #$ff
    stx Orientation
  !NoLeft:
    lsr
    bcs !NoRight+
    ldx #$01
    stx Orientation
  !NoRight:
    stx Direction
    ldx #$00
    lsr
    bcs !NoFirePressed+
    ldx #$ff
  !NoFirePressed:
    stx FirePressed
    rts

  CheckOnlyFirePress:
    jsr GetOnlyFirePress
    rts
}

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
