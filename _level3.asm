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
      jsr HandleEnemyMove

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

// Sprite color setting
      lda #$07
      sta SPRITES.COLOR0
      lda #$08
      sta SPRITES.COLOR1
      lda #$02
      sta SPRITES.COLOR2

// Enable the first sprite (ranger)
      EnableSprite(0, true)

      GetRandomUpTo(3)
      sta WoodCutterFromLeft.CurrentWoodCutter

      jsr SetLeftWoodCutterTrack

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

  * = * "Level3 AddEnemy"
  AddEnemy: {
      lda GameEnded
      bne Done

      lda LevelCompleted
      bne Done

      GetRandomUpTo(3)

      cmp #$02
      beq StartWoodCutterFromLeft

      jmp Done

    StartWoodCutterFromLeft:
      lda EnemyActive
      and #%00000100
      bne Done
      lda EnemyActive
      ora #%00000100
      sta EnemyActive

      lda #$0
      sta SPRITES.X2
      lda #$45
      sta SPRITES.Y2

      EnableSprite(2, true)

    Done:
      rts

    EnemyActive:      .byte $00
  }

  * = * "Level3 HandleEnemyMove"
  HandleEnemyMove: {
      lda AddEnemy.EnemyActive
      and #%00000100
      beq Done
      jsr WoodCutterFromLeft

    Done:
      rts
  }

  * = * "Level3 WoodCutterFromLeft"
  WoodCutterFromLeft: {
      lda WoodCutterFined
      beq CutCompletedCheck
      lda ComplaintShown
      bne GoToWalkOutFar

      EnableSprite(1, false)

      lda TreeStartAddress
      sta HandleWoodCutterFined.MapComplain
      lda TreeStartAddress + 1
      sta HandleWoodCutterFined.MapComplain + 1
      lda #$01
      sta HandleWoodCutterFined.AddOrSub
      lda #$03
      sta HandleWoodCutterFined.Offset
      jsr HandleWoodCutterFined
      inc ComplaintShown

      lda LevelCompleted
      bne !+

      AddPoints(0, 0, 2, 0);

      lda #$2f
      sta Ranger.IsFining

    !:
      jmp Done

    CutCompletedCheck:
      lda CutCompleted
      bne GoToWalkOutFar
      jmp CutNotCompleted

    GoToWalkOutFar:
      jmp WalkOut

    CutNotCompleted:
      lda WalkInCompleted
      bne ShowHatchetFar
      jmp WalkIn

    ShowHatchetFar:
      jmp ShowHatchet

    WalkIn:
      // Woodcutter walks in, check if walk-in is done
      ldx SPRITES.X1
      cpx TrackWalkXEnd
      beq WalkInDone

      inc SPRITES.X1

      CallSetPosition(SPRITES.X1, TrackWalkY, $0, $04, $05);

      lda #<SPRITE_2
      sta WoodCutter.ScreenMemoryAddress + 1
      lda #>SPRITE_2
      sta WoodCutter.ScreenMemoryAddress

      CallUpdateWoodCutterFrame(DirectionX, DirectionY, WoodCutterFrame);

      jmp Done

      // Woodcutter is in position, stop walk
    WalkInDone:
      inc WalkInCompleted

      jmp Done

    ShowHatchet:
      // Woodcutter is in position, start to cut the tree
      lda HatchetShown
      bne HatchetStrike

      // Walk is done, hatchet must be set
      lda SPRITES.X2
      sta SPRITES.X1
      lda SPRITES.Y2
      sta SPRITES.Y1

      lda SPRITES.EXTRA_BIT
      and #%00000100
      beq SetHatchetBitToZero
      lda SPRITES.EXTRA_BIT
      ora #%00000010
      jmp !+

    SetHatchetBitToZero:
      lda SPRITES.EXTRA_BIT
      and #%11111101

    !:
      sta SPRITES.EXTRA_BIT

      lda #SPRITES.HATCHET_REV
      sta SPRITE_1

      EnableSprite(1, true)

      inc HatchetShown

      jmp Done

    HatchetStrike:
      lda SPRITES.EXTRA_BIT
      and #%00000010
      beq !+
      lda #$1
    !:
      sta SpriteCollision.OtherX + 1
      lda SPRITES.X1
      sta SpriteCollision.OtherX
      lda SPRITES.Y1
      sta SpriteCollision.OtherY
      jsr SpriteCollision
      bne RangerWoodCutterMet

      lda #<SPRITE_1
      sta Hatchet.ScreenMemoryAddress + 1
      lda #>SPRITE_1
      sta Hatchet.ScreenMemoryAddress

      CallUseTheHatchet(HatchetFrame, SPRITES.HATCHET_REV);

      lda Hatchet.UseTheHatchet.StrokeHappened
      bne StrokeHappened
      jmp Done

    StrokeHappened:
      dec HatchetStrokes
      lda HatchetStrokes
      bne DoneFar
      inc CutCompleted
      jmp HideHatchet

    RangerWoodCutterMet:
      inc WoodCutterFined
      jmp Done

    DoneFar:
      jmp Done
    HideHatchet:
      lda #$00
      sta HatchetShown
      lda #HatchetStrokesMax
      sta HatchetStrokes

      EnableSprite(1, false)

    // Tree has been cut, remove tree
      lda TreeStartAddress
      sta RemoveTree.StartAddress
      lda TreeStartAddress + 1
      sta RemoveTree.StartAddress + 1
      jsr RemoveTree

      ldx CurrentWoodCutter
      lda #$01
      sta TreeAlreadyCut, x

      lda LevelCompleted
      bne !+

      lda GameEnded
      bne !+

      jsr Hud.ReduceDismissalCounter

      lda Hud.ReduceDismissalCounter.DismissalCompleted
      sta GameEnded
      beq !+

      lda #$48
      sta ShowGameEndedMessage.StartAddress + 1
      jsr ShowGameEndedMessage

    !:
      jmp Done

    WalkOut:
    // Hide hatchet and move woodcutter out of screen
      ldx SPRITES.X1
      beq WalkOutDone

      dec SPRITES.X1

      CallSetPosition(SPRITES.X1, TrackWalkY, 0, $04, $05);

      lda #<SPRITE_2
      sta WoodCutter.ScreenMemoryAddress + 1
      lda #>SPRITE_2
      sta WoodCutter.ScreenMemoryAddress

      CallUpdateWoodCutterFrameReverse(DirectionX, DirectionY, WoodCutterFrame);

      jmp Done

    WalkOutDone:
      lda TreeStartAddress
      sta HandleWoodCutterFinedOut.MapComplain
      lda TreeStartAddress + 1
      sta HandleWoodCutterFinedOut.MapComplain + 1
      lda #$01
      sta HandleWoodCutterFinedOut.AddOrSub
      lda #$03
      sta HandleWoodCutterFinedOut.Offset
      jsr HandleWoodCutterFinedOut

      EnableSprite(2, false)

      // Prepare next sprite track
      ldx #$00
    LookForTreeAvailable:
      lda TreeAlreadyCut, x
      beq CheckNextWoodCutter
      iny
    !Next:
      inx
      cpx #$02
      bne LookForTreeAvailable
      jmp Done
    CheckNextWoodCutter:
      GetRandomUpTo(3)
      tax
      lda TreeAlreadyCut, x
      bne CheckNextWoodCutter
      stx CurrentWoodCutter
      jsr SetLeftWoodCutterTrack

      // Clear sprite
      lda AddEnemy.EnemyActive
      and #%11111011
      sta AddEnemy.EnemyActive

      lda #0
      sta HatchetShown
      sta CutCompleted
      sta WalkInCompleted
      sta ComplaintShown
      sta WoodCutterFined

      lda #HatchetStrokesMax
      sta HatchetStrokes

    Done:
      rts

    TreeAlreadyCut: .byte $00, $00, $00

    // Number of strokes to cut tree
    .label HatchetStrokesMax = 20
    HatchetStrokes: .byte HatchetStrokesMax

    HatchetFrame:
      .byte $ff

    WoodCutterFrame:
      .byte $00

    WoodCutterFined:
      .byte $00

    ComplaintShown:
      .byte 0

    HatchetShown:
      .byte 0
    CutCompleted:
      .byte 0
    WalkInCompleted:
      .byte 0

    CurrentWoodCutter: .byte $00

// Woodcutter dummy data
    TrackWalkXStart:  .byte $00
    TrackWalkXEnd:    .byte $00
    TrackWalkY:       .byte $00

    DirectionX:       .byte $00
    DirectionY:       .byte $00

    TreeStartAddress: .word $beef
  }

  * = * "Level3 SetLeftWoodCutterTrack"
  SetLeftWoodCutterTrack: {
      lda WoodCutterFromLeft.CurrentWoodCutter
      cmp #$02
      beq FixForWoodCutter3
      cmp #$01
      beq FixForWoodCutter2

    FixForWoodCutter1:
      lda #TrackWalk1XStart
      sta WoodCutterFromLeft.TrackWalkXStart
      lda #TrackWalk1XEnd
      sta WoodCutterFromLeft.TrackWalkXEnd

      lda #TrackWalk1Y
      sta WoodCutterFromLeft.TrackWalkY

      lda #DirectionX1
      sta WoodCutterFromLeft.DirectionX
      lda #DirectionY1
      sta WoodCutterFromLeft.DirectionY

      lda TreeStartAddress1
      sta WoodCutterFromLeft.TreeStartAddress
      lda TreeStartAddress1 + 1
      sta WoodCutterFromLeft.TreeStartAddress + 1

      jmp Done

    FixForWoodCutter2:
      lda #TrackWalk2XStart
      sta WoodCutterFromLeft.TrackWalkXStart
      lda #TrackWalk2XEnd
      sta WoodCutterFromLeft.TrackWalkXEnd

      lda #TrackWalk2Y
      sta WoodCutterFromLeft.TrackWalkY

      lda #DirectionX2
      sta WoodCutterFromLeft.DirectionX
      lda #DirectionY2
      sta WoodCutterFromLeft.DirectionY

      lda TreeStartAddress2
      sta WoodCutterFromLeft.TreeStartAddress
      lda TreeStartAddress2 + 1
      sta WoodCutterFromLeft.TreeStartAddress + 1

      jmp Done

    FixForWoodCutter3:
      lda #TrackWalk3XStart
      sta WoodCutterFromLeft.TrackWalkXStart
      lda #TrackWalk3XEnd
      sta WoodCutterFromLeft.TrackWalkXEnd

      lda #TrackWalk3Y
      sta WoodCutterFromLeft.TrackWalkY

      lda #DirectionX3
      sta WoodCutterFromLeft.DirectionX
      lda #DirectionY3
      sta WoodCutterFromLeft.DirectionY

      lda TreeStartAddress3
      sta WoodCutterFromLeft.TreeStartAddress
      lda TreeStartAddress3 + 1
      sta WoodCutterFromLeft.TreeStartAddress + 1

    Done:
      lda WoodCutterFromLeft.TrackWalkXStart
      sta SPRITES.X1
      lda WoodCutterFromLeft.TrackWalkY
      sta SPRITES.Y1

      rts

// First woodcutter track data
    .label TrackWalk1XStart = 0
    .label TrackWalk1XEnd   = 56
    .label TrackWalk1Y      = 111
    .label DirectionX1      = 1
    .label DirectionY1      = 0

    TreeStartAddress1: .word $4c00 + (40 * 6) + 5

// Second woodcutter track data
    .label TrackWalk2XStart = 0
    .label TrackWalk2XEnd   = 46
    .label TrackWalk2Y      = 166
    .label DirectionX2      = 1
    .label DirectionY2      = 0

    TreeStartAddress2: .word $4c00 + (40 * 13) + 4

// Third woodcutter track data
    .label TrackWalk3XStart = 0
    .label TrackWalk3XEnd   = 112
    .label TrackWalk3Y      = 191
    .label DirectionX3      = 1
    .label DirectionY3      = 0

    TreeStartAddress3: .word $4c00 + (40 * 16) + 12
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
      jsr AddEnemy

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

  .label SPRITE_1     = $4ff9
  .label SPRITE_3     = $4ffb

  .label SPRITE_2     = $4ffa
  .label SPRITE_4     = $4ffc
}
