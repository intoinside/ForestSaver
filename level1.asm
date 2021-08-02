////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Manager for intro screen.
//
////////////////////////////////////////////////////////////////////////////////

Level1: {

// Manager of level 1
  * = * "Level1 Manager"
  Manager: {
      jsr Init
      jsr AddColorToMap

    CheckFirePressed:
      jsr GetOnlyFirePress
      lda #$ff
      cmp FirePressed
      bne CheckFirePressed
      inc FirePressed

      rts
  }

  // Initialization of intro screen
  * = * "Level1 Init"
  Init: {

  // Set background and border color to brown
      lda #$09
      sta VIC.BORDER_COLOR
      sta VIC.BACKGROUND_COLOR

      lda #$00
      sta VIC.EXTRA_BACKGROUND1
      lda #$01
      sta VIC.EXTRA_BACKGROUND2

// Set pointer to char memory to $b800-$bfff (xxxx111x)
// and pointer to screen memory to $8400-$87ff (0001xxxx)
      lda #%00011110
      sta VIC.MEMORY_SETUP

      rts
  }

  AddColorToMap: {
// TODO(intoinside): don't like this macro, maybe changed with a function
// (there's no need to be fast but there is a need to have smaller code)
    SetColorToChars($8400)

    rts
  }

}
