////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Manager for level 2.
//
////////////////////////////////////////////////////////////////////////////////

Level2: {

// Manager of level 2
  * = * "Level2 Manager"
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
  * = * "Level2 Init"
  Init: {

  // Set background and border color to brown
      lda #$08
      sta VIC.BORDER_COLOR
      sta VIC.BACKGROUND_COLOR

      lda #$00
      sta VIC.EXTRA_BACKGROUND1
      lda #$01
      sta VIC.EXTRA_BACKGROUND2

// Set pointer to char memory to $b800-$bfff (xxxx111x)
// and pointer to screen memory to $8800-$8fff (0010xxxx)
      lda #%00101110
      sta VIC.MEMORY_SETUP

      rts
  }

  AddColorToMap: {
// TODO(intoinside): don't like this macro, maybe changed with a function
// (there's no need to be fast but there is a need to have smaller code)
    SetColorToChars($8800)

    rts
  }

}
