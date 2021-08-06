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

    CheckFirePressed:
      jsr GetOnlyFirePress
      lda #$ff
      cmp FirePressed
      bne CheckFirePressed

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

      lda #$50
      sta SPRITE_0

      lda #$50
      sta $d000
      sta $d001

      lda #$0a
      sta SPRITES.EXTRACOLOR1

      lda #$00
      sta SPRITES.EXTRACOLOR2

      lda #$07
      sta SPRITES.COLOR0

// Enable the first sprite (just for test)
      lda #$01
      sta VIC.SPRITE_ENABLE
      sta VIC.SPRITE_MULTICOLOR

      rts
  }

  Finalize: {
      lda #$00
      sta VIC.SPRITE_ENABLE

      rts
  }

  AddColorToMap: {
// TODO(intoinside): don't like this macro, maybe changed with a function
// (there's no need to be fast but there is a need to have smaller code)
      SetColorToChars($4000)

      rts
  }

  .label SPRITE_0   = $43f8

}
