////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Manager for level 2.
//
////////////////////////////////////////////////////////////////////////////////

#importonce

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

      jsr Finalize

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

// Set pointer to char memory to $7800-$7fff (xxxx111x)
// and pointer to screen memory to $4800-$4fff (0010xxxx)
      lda #%00101110
      sta VIC.MEMORY_SETUP

// Init ranger
      lda #SPRITES.RANGER_STANDING
      sta SPRITE_0

      lda #$50
      sta SPRITES.X0
      lda #$40
      sta SPRITES.Y0

      lda #$0a
      sta SPRITES.EXTRACOLOR1

      lda #$00
      sta SPRITES.EXTRACOLOR2

      lda #$07
      sta SPRITES.COLOR0

// Enable the first sprite (just for test)
      lda #$01
      sta VIC.SPRITE_MULTICOLOR
      sta VIC.SPRITE_ENABLE

      rts
  }

  * = * "Level2 Finalize"
  Finalize: {

      rts
  }

  AddColorToMap: {
      lda #$48
      sta SetColorToChars.ScreenMemoryAddress

      jsr SetColorToChars

      rts
  }

  .label SPRITE_0     = $4bf8

}

#import "main.asm"
#import "joystick.asm"
