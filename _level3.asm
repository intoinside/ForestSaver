////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Manager for level 3.
//
// Sprite pointer settings:
// * Ranger       Sprite 0
// * Hatchet 1    Sprite 1
// * Woodcutter 1 Sprite 2
// * Arsionist    Sprite 3
// * Flame        Sprite 4 
// * Tank tail    Sprite 5
// * Tank body    Sprite 6
// * Tank pipe    Sprite 7
//
////////////////////////////////////////////////////////////////////////////////

#importonce

Level3: {
  * = * "Level3 Manager"
  Manager: {
      jsr Init
      jsr AddColorToMap
      jsr StupidWaitRoutine

    JoystickMovement:
      jsr WaitRoutine
      jsr TimedRoutine
      jsr GetJoystickMove

      jsr Ranger.HandleRangerMove
      // jsr HandleEnemyMove

      //jsr CheckLevelCompleted
      //bne CloseLevelAndGotoNext

      lda GameEnded
      bne CloseLevelAndGame

      jmp EndLoop

    CloseLevelAndGame:
      SetSpriteToBackground()
      lda Keyboard.ReturnPressed
      bne LevelDone

    EndLoop:
      jmp JoystickMovement

    LevelDone:
      jsr Finalize
      rts
  }

  // Initialization of level 3
  * = * "Level3 Init"
  Init: {
      CopyScreenRam($4c00, MapDummyArea)

      lda #$4c
      sta ShowGameNextLevelMessage.StartAddress + 1

      SetSpriteToForeground()
// Set background and border color to brown
      lda #$09
      sta VIC.BORDER_COLOR
      sta VIC.BACKGROUND_COLOR

      lda #$00
      sta VIC.EXTRA_BACKGROUND1
      lda #$01
      sta VIC.EXTRA_BACKGROUND2

// Set pointer to char memory to $7800-$7fff (xxxx111x)
// and pointer to screen memory to $4400-$47ff (0001xxxx)
      lda #%00111110
      sta VIC.MEMORY_SETUP

// Init common sprite color
      lda #$0a
      sta SPRITES.EXTRACOLOR1

      lda #$00
      sta SPRITES.EXTRACOLOR2

// Ranger coordinates
      lda #$0
      sta SPRITES.EXTRA_BIT
      lda #$50
      sta SPRITES.X0
      lda #$40
      sta SPRITES.Y0

// Optimization may be done
// Ranger module init
      lda #$00
      sta Ranger.ScreenMemoryAddress + 1
      lda #$4c
      sta Ranger.ScreenMemoryAddress
      jsr Ranger.Init

      lda #$00
      sta WoodCutter.ScreenMemoryAddress + 1
      lda #$4c
      sta WoodCutter.ScreenMemoryAddress
      jsr WoodCutter.Init

      lda #$00
      sta Hud.ScreenMemoryAddress + 1
      lda #$4c
      sta Hud.ScreenMemoryAddress
      jsr Hud.Init

// Enable the first sprite (ranger)
      EnableSprite(0, true)

      rts
  }

  * = * "Level3 Finalize"
  Finalize: {
      CopyScreenRam(MapDummyArea, $4c00)

      jsr DisableAllSprites

      lda #$00
      sta LevelCompleted

      jsr CompareAndUpdateHiScore

      jsr Hud.ResetDismissalCounter

      rts
  }

  * = * "Level3 CheckLevelCompleted"
  CheckLevelCompleted: {
      rts
  }

  * = * "Level3 TimedRoutine"
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
      lda #$4c
      sta SetColorToChars.ScreenMemoryAddress

      jsr SetColorToChars

      rts
  }

  LevelCompleted: .byte $00

}
