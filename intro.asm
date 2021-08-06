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

    JoystickMovement:
      jsr WaitRoutine
      jsr GetJoystickMove

      lda Direction
      beq CheckDirectionY

// Handle horizontal move
      cmp #$ff
      beq MoveToLeft

    MoveToRight:
//        jsr switch_sprite_frog
      ldx SPRITES.X0          // Moving to right
      inx                     // Calculate new sprite x position
      beq ToggleExtraBit      // If zero then should toggle extra bit
      lda SPRITES.EXTRA_BIT   // If non zero, check extra bit
      and #$01
      beq UpdateSpriteXPos    // If extra bit not set, then update position
      cpx #$46
      bcs CheckDirectionY     // If extra bit set and new position is over right
      jmp UpdateSpriteXPos    // border, no movement allowed

    ToggleExtraBit:
      lda SPRITES.EXTRA_BIT
      eor #$01
      sta SPRITES.EXTRA_BIT
    UpdateSpriteXPos:
      stx SPRITES.X0
      jmp CheckDirectionY

    MoveToLeft:
//        jsr switch_sprite_frog
      lda SPRITES.EXTRA_BIT   // Moving to right, check extra bit
      and #$01
      bne TryToMoveLeft       // If extra bit is set, then move allowed
      ldx SPRITES.X0          // Check if position is on left border
      cpx #$16
      bcc CheckDirectionY     // If extra bit not set and x-position is not on
      dex                     // left border, then move allowed
      jmp UpdateSpriteXPos

    TryToMoveLeft:
      ldx SPRITES.X0          // Calculate new position
      dex
      cpx #$ff
      bne UpdateSpriteXPos    // If position is $ff then extra bit must be
      jmp ToggleExtraBit      // toggled

    CheckDirectionY:
      lda DirectionY

      lda FirePressed
      beq JoystickMovement

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

      lda #$fc
      sta $d000
      lda #$40
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

      // Reset game var
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

  .label SPRITE_0   = $43f8

}
