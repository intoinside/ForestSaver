////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Manager for intro screen.
//
////////////////////////////////////////////////////////////////////////////////

Intro: {

// Manager of intro screen
  * = * "Intro IntroManager"
  Manager: {
      jsr Init
      jsr AddColorToMap

    CheckFire:
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

      rts
  }

  Finalize: {
      // Reset game var
      lda #$00
      sta GameEnded

      // Reset player orientation and direction
      sta Direction
      sta DirectionY

      lda #$01
      sta Orientation

      rts
  }

  AddColorToMap: {
// TODO(intoinside): don't like this macro, maybe changed with a function
// (there's no need to be fast but there is a need to have smaller code)
      SetColorToChars($4000)

      rts
  }

}
