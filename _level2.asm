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
      jsr StupidWaitRoutine

    JoystickMovement:
      jsr WaitRoutine
      jsr TimedRoutine
      jsr GetJoystickMove

      jsr Ranger.HandleRangerMove

      lda GameEnded
      bne CloseLevelAndGame

      jmp EndLoop

    CloseLevelAndGame:
      SetSpriteToBackground()
      lda FirePressed
      bne LevelDone

    EndLoop:
      jmp JoystickMovement

    LevelDone:
      jsr Finalize
      rts
  }

  // Initialization of intro screen
  * = * "Level2 Init"
  Init: {
      CopyScreenRam($4800, MapDummyArea)

      SetSpriteToForeground()

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

// Enable the first sprite (ranger)
      lda #%00000001
      sta VIC.SPRITE_ENABLE

      rts
  }

  * = * "Level2 Finalize"
  Finalize: {
      CopyScreenRam(MapDummyArea, $4800)

      lda #$00
      sta VIC.SPRITE_ENABLE

      jsr CompareAndUpdateHiScore

      jsr Hud.ResetScore
      jsr Hud.ResetDismissalCounter

      jsr DisableAllSprites

      rts
  }

  * = * "Level1 TimedRoutine"
  TimedRoutine: {
      jsr TimedRoutine10th

      lda DelayCounter
      beq DelayTriggered        // when counter is zero stop decrementing
      dec DelayCounter      // decrement the counter

      jmp Exit

    DelayTriggered:
      // inc $4410

      lda DelayRequested      // delay reached 0, reset it
      sta DelayCounter

    Waiting:
      // jsr AddEnemy

      jmp Exit

    NotWaiting:

    Exit:
      rts

    DelayCounter:
      .byte 50                  // Counter storage
    DelayRequested:
      .byte 50                  // 1 second delay
  }

  TimedRoutine10th: {
      lda DelayCounter
      beq DelayTriggered        // when counter is zero stop decrementing
      dec DelayCounter        // decrement the counter

      jmp Exit

    DelayTriggered:
      // inc $4411

      lda DelayRequested      // delay reached 0, reset it
      sta DelayCounter

    Exit:
      rts

    DelayCounter:
      .byte 8                  // Counter storage
    DelayRequested:
      .byte 8                  // 8/50 second delay
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
