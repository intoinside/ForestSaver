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
// TODO(intoinside): don't like this macro, maybe changed with a function
// (there's no need to be fast but there is a need to have smaller code)
    SetColorToChars($4800)

    rts
  }

  .label SPRITE_0     = $4bf8
  .label LIMIT_UP     = $32
  .label LIMIT_DOWN   = $e7
  .label LIMIT_LEFT   = $16
  .label LIMIT_RIGHT  = $46

}

#import "main.asm"
#import "joystick.asm"
