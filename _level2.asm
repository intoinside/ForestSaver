////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Manager for level 2.
//
// Sprite pointer settings:
// * Ranger       Sprite 0
// * Hatchet 1    Sprite 1
// * Woodcutter 1 Sprite 2
// * Hatchet 2    Sprite 3
// * Woodcutter 2 Sprite 4
// * Tank tail    Sprite 5
// * Tank body    Sprite 6
// * Tank pipe    Sprite 7
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
      jsr HandleEnemyMove
      jsr HandleTankTruckMove

      lda GameEnded
      bne CloseLevelAndGame

      jmp EndLoop

    CloseLevelAndGame:
      SetSpriteToBackground()
      jsr Keyboard.IsReturnPressed
      bne LevelDone

    EndLoop:
      jmp JoystickMovement

    LevelDone:
      jsr Finalize
      rts
  }

  // Initialization of level 2
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

// Init common sprite color
      lda #$0a
      sta SPRITES.EXTRACOLOR1

      lda #$00
      sta SPRITES.EXTRACOLOR2

// Woodcutter sprite init
      lda #SPRITES.ENEMY_STANDING
      sta SPRITE_2
      sta SPRITE_4

// Ranger coordinates
      lda #$50
      sta SPRITES.X0
      lda #$40
      sta SPRITES.Y0

// Optimization may be done
// Ranger module init
      lda #$00
      sta Ranger.ScreenMemoryAddress + 1
      lda #$48
      sta Ranger.ScreenMemoryAddress
      jsr Ranger.Init

      lda #$00
      sta WoodCutter.ScreenMemoryAddress + 1
      lda #$48
      sta WoodCutter.ScreenMemoryAddress
      jsr WoodCutter.Init

      lda #$00
      sta Hud.ScreenMemoryAddress + 1
      lda #$48
      sta Hud.ScreenMemoryAddress
      jsr Hud.Init

// Sprite color setting
      lda #$07
      sta SPRITES.COLOR0
      lda #$08
      sta SPRITES.COLOR1
      sta SPRITES.COLOR3
      lda #$02
      sta SPRITES.COLOR2
      sta SPRITES.COLOR4
      lda #$01
      sta SPRITES.COLOR5
      sta SPRITES.COLOR6
      lda #$03
      sta SPRITES.COLOR7

// Enable the first sprite (ranger)
      EnableSprite(0, true)

      GetRandomUpTo(2)
      sta WoodCutterFromLeft.CurrentWoodCutter
      GetRandomUpTo(2)
      sta WoodCutterFromRight.CurrentWoodCutter

      jsr SetLeftWoodCutterTrack
      jsr SetRightWoodCutterTrack

      rts
  }

  * = * "Level2 Finalize"
  Finalize: {
      CopyScreenRam(MapDummyArea, $4800)

      jsr DisableAllSprites

      lda #$00
      sta AddEnemy.EnemyActive
      sta WoodCutterFromLeft.WoodCutterFined
      sta WoodCutterFromLeft.ComplaintShown
      sta WoodCutterFromLeft.CutCompleted
      sta WoodCutterFromLeft.WalkInCompleted
      sta WoodCutterFromLeft.HatchetShown

      sta WoodCutterFromLeft.TreeAlreadyCut
      sta WoodCutterFromLeft.TreeAlreadyCut + 1

      sta WoodCutterFromRight.WoodCutterFined
      sta WoodCutterFromRight.ComplaintShown
      sta WoodCutterFromRight.CutCompleted
      sta WoodCutterFromRight.WalkInCompleted
      sta WoodCutterFromRight.HatchetShown

      sta WoodCutterFromRight.TreeAlreadyCut
      sta WoodCutterFromRight.TreeAlreadyCut + 1

      sta AddTankTruck.TruckActive

      sta TankTruckFromLeft.LakeNotAvailable
      sta TankTruckFromLeft.Polluted

      sta TankTruckFromRight.LakeNotAvailable
      sta TankTruckFromRight.Polluted

      sta Hud.ReduceDismissalCounter.DismissalCompleted

      jsr CleanTankLeft
      jsr CleanTankRight

      jsr CompareAndUpdateHiScore

      jsr Hud.ResetDismissalCounter

      rts
  }

  * = * "Level2 AddEnemy"
  AddEnemy: {
      lda GameEnded
      bne Done

      GetRandomUpTo(6)

      cmp #$02
      beq StartWoodCutterFromLeft

      cmp #$03
      beq StartWoodCutterFromRight

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

      jmp Done

    StartWoodCutterFromRight:
      lda EnemyActive
      and #%00001000
      bne Done
      lda EnemyActive
      ora #%00001000
      sta EnemyActive

      lda #$10
      sta SPRITES.X4
      lda #$cf
      sta SPRITES.Y4
      lda SPRITES.EXTRA_BIT
      ora #%00010000
      sta SPRITES.EXTRA_BIT

      EnableSprite(4, true)

    Done:
      rts

    EnemyActive:      .byte $00
  }

  * = * "Level2 HandleEnemyMove"
  HandleEnemyMove: {
      lda AddEnemy.EnemyActive
      and #%00000100
      beq IsEnemyFromRight3Alive
      jsr WoodCutterFromLeft

    IsEnemyFromRight3Alive:
      lda AddEnemy.EnemyActive
      and #%00001000
      beq Done
      jsr WoodCutterFromRight

    Done:
      rts
  }

  * = * "Level2 WoodCutterFromLeft"
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

      lda #$2f
      sta Ranger.IsFining

      AddPoints(0, 0, 2, 0);

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
      GetRandomUpTo(2)
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

    TreeAlreadyCut: .byte $00, $00

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

  * = * "Level2 SetLeftWoodCutterTrack"
  SetLeftWoodCutterTrack: {
      lda WoodCutterFromLeft.CurrentWoodCutter
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

    Done:
      lda WoodCutterFromLeft.TrackWalkXStart
      sta SPRITES.X1
      lda WoodCutterFromLeft.TrackWalkY
      sta SPRITES.Y1

      rts

// First woodcutter track data
    .label TrackWalk1XStart = 0
    .label TrackWalk1XEnd   = 94
    .label TrackWalk1Y      = 86
    .label DirectionX1      = 1
    .label DirectionY1      = 0

    TreeStartAddress1: .word $4882

// Second woodcutter track data
    .label TrackWalk2XStart = 0
    .label TrackWalk2XEnd   = 81
    .label TrackWalk2Y      = 189
    .label DirectionX2      = 1
    .label DirectionY2      = 0

    TreeStartAddress2: .word $4a89
  }

  * = * "Level2 WoodCutterFromRight"
  WoodCutterFromRight: {
      lda WoodCutterFined
      beq CutCompletedCheck
      lda ComplaintShown
      bne GoToWalkOutFar

      EnableSprite(3, false)

      lda TreeStartAddress
      sta HandleWoodCutterFined.MapComplain
      lda TreeStartAddress + 1
      sta HandleWoodCutterFined.MapComplain + 1
      lda #$00
      sta HandleWoodCutterFined.AddOrSub
      lda #$05
      sta HandleWoodCutterFined.Offset
      jsr HandleWoodCutterFined
      inc ComplaintShown

      lda #$2f
      sta Ranger.IsFining

      AddPoints(0, 0, 2, 0);

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
      // Woodcutter walks in
      ldx SPRITES.X3
      cpx TrackWalkXEnd
      beq WalkInDone

      // Woodcutter is not in end position, update x-pos
      dec SPRITES.X3
      dex
      cpx #$ff
      bne !+
      // X-pos had an underflow, set XBit to 0
      dec XBit

    !:
      lda XBit
      beq XBitNotSet2
      CallSetPosition(SPRITES.X3, TrackWalkY, $ff, $08, $09);
      jmp !+

    XBitNotSet2:
      CallSetPosition(SPRITES.X3, TrackWalkY, $0, $08, $09);

    !:
      lda #<SPRITE_4
      sta WoodCutter.ScreenMemoryAddress + 1
      lda #>SPRITE_4
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
      lda SPRITES.X4
      sta SPRITES.X3
      lda SPRITES.Y4
      sta SPRITES.Y3

      lda SPRITES.EXTRA_BIT
      and #%00010000
      beq SetHatchetBitToZero
      lda SPRITES.EXTRA_BIT
      ora #%00001000
      jmp !+

    SetHatchetBitToZero:
      lda SPRITES.EXTRA_BIT
      and #%11110111

    !:
      sta SPRITES.EXTRA_BIT

      lda #SPRITES.HATCHET
      sta SPRITE_3

      EnableSprite(3, true)

      inc HatchetShown

      jmp Done

    HatchetStrike:
      lda SPRITES.EXTRA_BIT
      and #%00001000
      beq !+
      lda #$01
    !:
      sta SpriteCollision.OtherX + 1
      lda SPRITES.X3
      sta SpriteCollision.OtherX
      lda SPRITES.Y3
      sta SpriteCollision.OtherY
      jsr SpriteCollision
      bne RangerWoodCutterMet

      lda #<SPRITE_3
      sta Hatchet.ScreenMemoryAddress + 1
      lda #>SPRITE_3
      sta Hatchet.ScreenMemoryAddress

      CallUseTheHatchet(HatchetFrame, SPRITES.HATCHET);

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

      EnableSprite(3, false)

    // Tree has been cut, remove tree
      lda TreeStartAddress
      sta RemoveTree.StartAddress
      lda TreeStartAddress + 1
      sta RemoveTree.StartAddress + 1
      jsr RemoveTree

      ldx CurrentWoodCutter
      lda #$01
      sta TreeAlreadyCut, x

      lda GameEnded
      bne !+

      jsr Hud.ReduceDismissalCounter

      lda Hud.ReduceDismissalCounter.DismissalCompleted
      sta GameEnded
      beq !+

// Optimize this assignation
      lda #$48
      sta ShowGameEndedMessage.StartAddress + 1
// END Optimize request
      jsr ShowGameEndedMessage

    !:
      jmp Done

    WalkOut:
    // Hide hatchet and move woodcutter out of screen
      ldx SPRITES.X3
      cpx TrackWalkXStart
      beq CheckXBitBeforeWalkOutDone
      jmp NoNeedToGoOut

    CheckXBitBeforeWalkOutDone:
      lda XBit
      bne WalkOutDone   // If XBit!=0, woodcutter is out of screen

    NoNeedToGoOut:
      inc SPRITES.X3    // Woodcutter is not out of screen
      bne DontSetXBit   // If x-pos not overflow, don't increment XBit

      inc XBit
    DontSetXBit:
      lda XBit
      beq XBitNotSet
      CallSetPosition(SPRITES.X3, TrackWalkY, $ff, $08, $09);
      jmp !+

    XBitNotSet:
      CallSetPosition(SPRITES.X3, TrackWalkY, $0, $08, $09);

    !:
      lda #<SPRITE_4
      sta WoodCutter.ScreenMemoryAddress + 1
      lda #>SPRITE_4
      sta WoodCutter.ScreenMemoryAddress

      CallUpdateWoodCutterFrameReverse(DirectionX, DirectionY, WoodCutterFrame);

      jmp Done

    WalkOutDone:
      lda TreeStartAddress
      sta HandleWoodCutterFinedOut.MapComplain
      lda TreeStartAddress + 1
      sta HandleWoodCutterFinedOut.MapComplain + 1
      lda #$00
      sta HandleWoodCutterFinedOut.AddOrSub
      lda #$05
      sta HandleWoodCutterFinedOut.Offset
      jsr HandleWoodCutterFinedOut

      EnableSprite(4, false)

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
      GetRandomUpTo(2)
      tax
      lda TreeAlreadyCut, x
      bne CheckNextWoodCutter
      stx CurrentWoodCutter
      jsr SetRightWoodCutterTrack

      // Clear sprite
      lda AddEnemy.EnemyActive
      and #%11110111
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

    TreeAlreadyCut: .byte $00, $00

    // Number of strokes to cut tree
    .label HatchetStrokesMax = 20
    HatchetStrokes:
      .byte HatchetStrokesMax

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
    XBit:             .byte $00

    DirectionX:       .byte $00
    DirectionY:       .byte $00

    TreeStartAddress: .word $beef
  }

  * = * "Level2 SetRightWoodCutterTrack"
  SetRightWoodCutterTrack: {
      lda WoodCutterFromRight.CurrentWoodCutter
      cmp #$01
      beq FixForWoodCutter2

    FixForWoodCutter1:
      lda #TrackWalk1XStart
      sta WoodCutterFromRight.TrackWalkXStart
      lda #TrackWalk1XEnd
      sta WoodCutterFromRight.TrackWalkXEnd

      lda #X1BitStart
      sta WoodCutterFromRight.XBit

      lda #TrackWalk1Y
      sta WoodCutterFromRight.TrackWalkY

      lda #DirectionX1
      sta WoodCutterFromRight.DirectionX
      lda #DirectionY1
      sta WoodCutterFromRight.DirectionY

      lda TreeStartAddress1
      sta WoodCutterFromRight.TreeStartAddress
      lda TreeStartAddress1 + 1
      sta WoodCutterFromRight.TreeStartAddress + 1
      jmp Done

    FixForWoodCutter2:
      lda #TrackWalk2XStart
      sta WoodCutterFromRight.TrackWalkXStart
      lda #TrackWalk2XEnd
      sta WoodCutterFromRight.TrackWalkXEnd

      lda #X2BitStart
      sta WoodCutterFromRight.XBit

      lda #TrackWalk2Y
      sta WoodCutterFromRight.TrackWalkY

      lda #DirectionX2
      sta WoodCutterFromRight.DirectionX
      lda #DirectionY2
      sta WoodCutterFromRight.DirectionY

      lda TreeStartAddress2
      sta WoodCutterFromRight.TreeStartAddress
      lda TreeStartAddress2 + 1
      sta WoodCutterFromRight.TreeStartAddress + 1

    Done:
      lda WoodCutterFromRight.TrackWalkXStart
      sta SPRITES.X3
      lda WoodCutterFromRight.TrackWalkY
      sta SPRITES.Y3

      rts

// First woodcutter track data
    .label TrackWalk1XStart = 70
    .label TrackWalk1XEnd   = 15
    .label X1BitStart       = 1
    .label TrackWalk1Y      = 71
    .label DirectionX1      = 255
    .label DirectionY1      = 0

    TreeStartAddress1: .word $4844

// Second woodcutter track data
    .label TrackWalk2XStart = 70
    .label TrackWalk2XEnd   = 233
    .label X2BitStart       = 1
    .label TrackWalk2Y      = 158
    .label DirectionX2      = 255
    .label DirectionY2      = 0

    TreeStartAddress2: .word $49f7
  }

  * = * "Level2 AddTankTruck"
  AddTankTruck: {
      lda GameEnded
      beq !+
      jmp Done

    !:
// If there is already a truck active, no new truck is needed
      lda TruckActive
      bne Done

      GetRandomUpTo(6)

      cmp #$01
      beq StartTankTruckFromLeft

      cmp #$02
      beq StartTankTruckFromRight

      jmp Done

    StartTankTruckFromLeft:
      lda TankTruckFromLeft.LakeNotAvailable
      bne Done

      lda #$01
      sta TruckActive

      lda #SPRITES.TANK_TAIL_LE
      sta SPRITE_5
      lda #SPRITES.TANK_BODY_LE
      sta SPRITE_6

      lda #TankTruckFromLeft.TankLeftXStart
      sta SPRITES.X6
      clc
      adc #24
      sta SPRITES.X5

      jmp Done

    StartTankTruckFromRight:
      lda TankTruckFromRight.LakeNotAvailable
      bne Done

      lda #$02
      sta TruckActive

      lda #SPRITES.TANK_TAIL_RI
      sta SPRITE_5
      lda #SPRITES.TANK_BODY_RI
      sta SPRITE_6

      lda #TankTruckFromRight.TankRightXStart
      sta SPRITES.X6
      clc
      sbc #24
      sta SPRITES.X5

    Done:
      rts

    TruckActive:      .byte $00
  }

  * = * "Level2 HandleTankTruckMove"
  HandleTankTruckMove: {
      lda AddTankTruck.TruckActive
      cmp #$01
      bne IsTruckFromRightAlive
      jsr TankTruckFromLeft
      jmp Done

    IsTruckFromRightAlive:
      lda AddTankTruck.TruckActive
      cmp #$02
      bne Done
      jsr TankTruckFromRight

    Done:
      rts
  }

  * = * "Level2 TankTruckFromLeft"
  TankTruckFromLeft: {
      lda LakeNotAvailable
      beq LakeGood
      jmp CleanForNextRun

    LakeGood:
      // Setting up tank sprites
      lda SpritesCreated
      bne TankDrivingIn
      inc SpritesCreated
      EnableSprite(5, true)
      EnableSprite(6, true)

    TankDrivingIn:
      // Lake is not polluted, so a new tank can drive in
      lda TankIn
      bne DriveInDone

      lda SPRITES.X5
      cmp #TankLeftXEnd
      bne !+
      jmp !Update+

    !:
      inc SPRITES.X5
      inc SPRITES.X6

      CallTankSetPosition(SPRITES.X5, TankLeftY, $0, $0a, $0b);
      CallTankSetPosition(SPRITES.X6, TankLeftY, $0, $0c, $0d);
      jmp !End+

    !Update:
      inc TankIn
    !End:
      jmp Done

    DriveInDone:
      // Tank is in position, showing pipe
      lda PipeShown
      bne Polluting

      lda #SPRITES.PIPE_1
      sta SPRITE_7
      sta PollutionFrame

      lda SPRITES.X5
      clc
      adc #22
      sta SPRITES.X7

      lda SPRITES.Y5
      sta SPRITES.Y7

      lda SPRITES.EXTRA_BIT
      and #%00011111
      sta SPRITES.EXTRA_BIT

      EnableSprite(7, true)

      inc PipeShown

      jmp Done

    Polluting:
      // Check if pollution is done, otherwise pollute it
      lda Polluted
      bne !DriveOut+
      lda TankFined
      bne !DriveOut+
      jmp !Proceed+

    !DriveOut:
      jmp DriveOut

    !Proceed: // Tank from left
      lda SPRITES.EXTRA_BIT
      and #%10000000
      beq !+
      lda #$1
    !:
      sta SpriteCollision.OtherX + 1

      lda SPRITES.X7
      sta SpriteCollision.OtherX
      lda SPRITES.Y7
      sta SpriteCollision.OtherY
      jsr SpriteCollision
      bne RangerTankMet

      inc PollutionFrameWait
      lda PollutionFrameWait
      lsr
      lsr
      lsr
      lsr
      lsr
      bcc !Done+

      lda #$00
      sta PollutionFrameWait

      lda PollutionCounter
      cmp #PollutionCounterLimit
      bne !+
      inc Polluted

      EnableSprite(7, false)

      lda #$97
      sta SetLakeToBlack.StartAddress
      lda #$49
      sta SetLakeToBlack.StartAddress + 1
      jsr SetLakeToBlack
      jsr AddColorToMap

      jsr Hud.ReduceDismissalCounter
      jmp Done

    !:
      inc PollutionCounter

      inc PollutionFrame
      lda PollutionFrame
      sta SPRITE_7

      cmp #SPRITES.PIPE_4
      bne !Done+

      lda #SPRITES.PIPE_1
      sta PollutionFrame

    !Done:
      jmp Done

    RangerTankMet:
      AddPoints(0, 0, 5, 0);

      inc TankFined
      EnableSprite(7, false)
      jmp Done

    DriveOut:
      lda TankOut
      bne DriveOutDone

      // Lake pollution is completed, tank should go out
      lda SPRITES.X5
      cmp #TankLeftXStart
      beq DriveOutDone

      dec SPRITES.X6
      bne !DecOtherSprite+
      EnableSprite(6, false)

    !DecOtherSprite:
      dec SPRITES.X5

      CallTankSetPosition(SPRITES.X5, TankLeftY, $0, $0a, $0b);
      CallTankSetPosition(SPRITES.X6, TankLeftY, $0, $0c, $0d);

      jmp Done

    DriveOutDone:
      // Tank is out of screen
      EnableSprite(5, false)
      inc TankOut

    CleanForNextRun:
      lda #$00
      sta AddTankTruck.TruckActive

      jsr CleanTankLeft

      lda Polluted
      sta LakeNotAvailable

    Done:
      rts

    LakeNotAvailable: .byte $00
    PipeShown: .byte $00
    SpritesCreated: .byte $00
    TankIn: .byte $00
    TankOut: .byte $00
    TankFined: .byte $00
    Polluted: .byte $00

    PollutionCounter: .byte $00
    PollutionFrame: .byte $00
    PollutionFrameWait: .byte $01

    .label PollutionCounterLimit = 20

    .label TankLeftXStart = 0
    .label TankLeftXEnd   = 40
    .label TankLeftX1BitStart = 0
    .label TankLeftY      = 120
    .label TankLeftBodySpriteNum = $67
    .label TankLeftTailSpriteNum = $66
  }

  * = * "Level2 CleanTankLeft"
  CleanTankLeft: {
      lda #$00
      sta TankTruckFromLeft.PipeShown
      sta TankTruckFromLeft.SpritesCreated
      sta TankTruckFromLeft.TankIn
      sta TankTruckFromLeft.TankOut
      sta TankTruckFromLeft.TankFined

      sta TankTruckFromLeft.PollutionCounter
      sta TankTruckFromLeft.PollutionFrame

      lda #$01
      sta TankTruckFromLeft.PollutionFrameWait

      rts
  }

  * = * "Level2 TankTruckFromRight"
  TankTruckFromRight: {
      lda LakeNotAvailable
      beq LakeGood
      jmp CleanForNextRun

    LakeGood:
      // Setting up tank sprites
      lda SpritesCreated
      bne TankDrivingIn
      inc SpritesCreated
      EnableSprite(5, true)
      EnableSprite(6, true)

    TankDrivingIn:
      // Lake is not polluted, so a new tank can drive in
      lda TankIn
      bne DriveInDone

      lda SPRITES.X5
      cmp #TankRightXEnd
      bne !+
      jmp !Update+

    !:
      dec SPRITES.X5
      dec SPRITES.X6

      CallTankSetPosition(SPRITES.X5, TankRightY, $1, $0a, $0b);
      CallTankSetPosition(SPRITES.X6, TankRightY, $1, $0c, $0d);
      jmp !End+

    !Update:
      inc TankIn
    !End:
      jmp Done

    DriveInDone:
      // Tank is in position, showing pipe
      lda PipeShown
      bne Polluting

      lda #SPRITES.PIPE_1_R
      sta SPRITE_7
      sta PollutionFrame

      lda SPRITES.X5
      clc
      sbc #22
      sta SPRITES.X7

      lda SPRITES.Y5
      sta SPRITES.Y7

      lda SPRITES.EXTRA_BIT
      ora #%11100000
      sta SPRITES.EXTRA_BIT

      EnableSprite(7, true)

      inc PipeShown

      jmp Done

    Polluting:
      // Check if pollution is done, otherwise pollute it
      lda Polluted
      bne !DriveOut+
      lda TankFined
      bne !DriveOut+
      jmp !Proceed+

    !DriveOut:
      jmp DriveOut

    !Proceed:  // Tank from right
      lda SPRITES.EXTRA_BIT
      and #%10000000
      beq !+
      lda #$1
    !:
      sta SpriteCollision.OtherX + 1
      lda SPRITES.X7
      sta SpriteCollision.OtherX
      lda SPRITES.Y7
      sta SpriteCollision.OtherY
      jsr SpriteCollision
      bne RangerTankMet

      inc PollutionFrameWait
      lda PollutionFrameWait
      lsr
      lsr
      lsr
      lsr
      lsr
      bcc !Done+

      lda #$00
      sta PollutionFrameWait

      lda PollutionCounter
      cmp #PollutionCounterLimit
      bne !+
      inc Polluted

      EnableSprite(7, false)

      lda #$84
      sta SetLakeToBlack.StartAddress
      lda #$49
      sta SetLakeToBlack.StartAddress + 1
      jsr SetLakeToBlack
      jsr AddColorToMap

      jsr Hud.ReduceDismissalCounter
      jmp Done

    !:
      inc PollutionCounter

      inc PollutionFrame
      lda PollutionFrame
      sta SPRITE_7

      cmp #SPRITES.PIPE_4_R
      bne !Done+

      lda #SPRITES.PIPE_1_R
      sta PollutionFrame

    !Done:
      jmp Done

    RangerTankMet:
      AddPoints(0, 0, 5, 0);

      inc TankFined
      EnableSprite(7, false)
      jmp Done

    DriveOut:
      lda TankOut
      bne DriveOutDone

      inc SPRITES.X6
      CallTankSetPosition(SPRITES.X6, TankRightY, $1, $0c, $0d);
      lda SPRITES.X6
      cmp #TankRightXStart
      bne !DecOtherSprite+
      EnableSprite(6, false)

    !DecOtherSprite:
      inc SPRITES.X5
      CallTankSetPosition(SPRITES.X5, TankRightY, $1, $0a, $0b);
      lda SPRITES.X5
      cmp #TankRightXStart
      beq DriveOutDone
      jmp Done

    DriveOutDone:
      EnableSprite(5, false)
      inc TankOut

    CleanForNextRun:
      lda #$00
      sta AddTankTruck.TruckActive

      jsr CleanTankRight

      lda Polluted
      sta LakeNotAvailable

    Done:
      rts

    LakeNotAvailable: .byte $00
    PipeShown: .byte $00
    SpritesCreated: .byte $00
    TankIn: .byte $00
    TankOut: .byte $00
    TankFined: .byte $00
    Polluted: .byte $00

    PollutionCounter: .byte $00
    PollutionFrame: .byte $00
    PollutionFrameWait: .byte $01

    .label PollutionCounterLimit = 20

    .label TankRightXStart = 70
    .label TankRightXEnd   = 44
    .label TankRightX1BitStart = 1
    .label TankRightY      = 110
    .label TankRightBodySpriteNum = $68
    .label TankRightTailSpriteNum = $69
  }

  * = * "Level2 CleanTankRight"
  CleanTankRight: {
      lda #$00
      sta TankTruckFromRight.PipeShown
      sta TankTruckFromRight.SpritesCreated
      sta TankTruckFromRight.TankIn
      sta TankTruckFromRight.TankOut
      sta TankTruckFromRight.TankFined

      sta TankTruckFromRight.PollutionCounter
      sta TankTruckFromRight.PollutionFrame

      lda #$01
      sta TankTruckFromRight.PollutionFrameWait

      rts
  }

  * = * "Level2 TimedRoutine"
  TimedRoutine: {
      jsr TimedRoutine10th

      lda DelayCounter
      beq DelayTriggered        // when counter is zero stop decrementing
      dec DelayCounter      // decrement the counter

      cmp #10
      beq Delay10
      cmp #20
      beq Delay20

      jmp Exit

    Delay10:
      lda TankTruckFromRight.Polluted
      bne Exit
      AnimateLake(Char1, $61, $65)
      AnimateLake(Char2, $62, $66)
      jmp Exit

    Delay20:
      lda TankTruckFromLeft.Polluted
      bne Exit
      AnimateLake(Char3, $61, $65)
      AnimateLake(Char4, $62, $66)
      jmp Exit

    DelayTriggered:
      // inc $4810

      lda DelayRequested      // delay reached 0, reset it
      sta DelayCounter

    Waiting:
      jsr AddEnemy
      jsr AddTankTruck

    Exit:
      rts

// Char position in screen ram
    .label Char1 = $4800 + (40 * 10 + 29)
    .label Char2 = $4800 + (40 * 10 + 30)

    .label Char3 = $4800 + (40 * 11 + 8)
    .label Char4 = $4800 + (40 * 11 + 9)

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
      // inc $4811

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

// Hatchet sprite pointer
  .label SPRITE_1     = $4bf9
  .label SPRITE_3     = $4bfb

// Enemy sprite pointer
  .label SPRITE_2     = $4bfa
  .label SPRITE_4     = $4bfc

// Tank tail and body sprite pointer
  .label SPRITE_5     = $4bfd
  .label SPRITE_6     = $4bfe
  .label SPRITE_7     = $4bff

}

#import "main.asm"
#import "_label.asm"
#import "_tanktruck.asm"
