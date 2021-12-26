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

#import "chipset/lib/vic2.asm"
#import "chipset/lib/vic2-global.asm"

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
      jsr HandleTankTruckMove
      jsr HandleArsionistMove

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
      CopyScreenRam(ScreenMemoryBaseAddress, MapDummyArea)

      lda #<ScreenMemoryBaseAddress
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
// and pointer to screen memory to $4c00-$4fff (0011xxxx)
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
      sta c64lib.SPRITE_0_X
      lda #$40
      sta c64lib.SPRITE_0_Y

// Optimization may be done
// Ranger module init
      lda #<ScreenMemoryBaseAddress
      sta Ranger.ScreenMemoryAddress + 1
      lda #>ScreenMemoryBaseAddress
      sta Ranger.ScreenMemoryAddress
      jsr Ranger.Init

      lda #<ScreenMemoryBaseAddress
      sta WoodCutter.ScreenMemoryAddress + 1
      lda #>ScreenMemoryBaseAddress
      sta WoodCutter.ScreenMemoryAddress
      jsr WoodCutter.Init

      lda #<ScreenMemoryBaseAddress
      sta Arsionist.ScreenMemoryAddress + 1
      lda #>ScreenMemoryBaseAddress
      sta Arsionist.ScreenMemoryAddress
      jsr Arsionist.Init

      lda #<ScreenMemoryBaseAddress
      sta Hud.ScreenMemoryAddress + 1
      lda #>ScreenMemoryBaseAddress
      sta Hud.ScreenMemoryAddress
      jsr Hud.Init

// Sprite color setting
      lda #$07
      sta SPRITES.COLOR0
      sta SPRITES.COLOR4
      lda #$08
      sta SPRITES.COLOR1
      sta SPRITES.COLOR3
      lda #$02
      sta SPRITES.COLOR2
      lda #$01
      sta SPRITES.COLOR5
      sta SPRITES.COLOR6
      lda #$03
      sta SPRITES.COLOR7

// Enable the first sprite (ranger)
      EnableSprite(0, true)

      GetRandomUpTo(3)
      sta WoodCutterFromLeft.CurrentWoodCutter

      jsr SetLeftWoodCutterTrack

      rts
  }

  * = * "Level3 Finalize"
  Finalize: {
      CopyScreenRam(MapDummyArea, ScreenMemoryBaseAddress)

      jsr DisableAllSprites

      lda #$00
      sta LevelCompleted
      sta AddEnemy.EnemyActive
      sta WoodCutterFromLeft.WoodCutterFined
      sta WoodCutterFromLeft.ComplaintShown
      sta WoodCutterFromLeft.CutCompleted
      sta WoodCutterFromLeft.WalkInCompleted
      sta WoodCutterFromLeft.HatchetShown

      sta WoodCutterFromLeft.TreeAlreadyCut
      sta WoodCutterFromLeft.TreeAlreadyCut + 1

      sta AddTankTruck.TruckActive

      sta TankTruckFromRight.LakeNotAvailable
      sta TankTruckFromRight.Polluted

      sta AddArsionist.ArsionistActive

      sta Hud.ReduceDismissalCounter.DismissalCompleted

      jsr CleanTankRight

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

      lda #<ScreenMemoryBaseAddress
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
      cpx #$03
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

    TreeStartAddress1: .word ScreenMemoryBaseAddress + c64lib_getTextOffset(5, 6)

// Second woodcutter track data
    .label TrackWalk2XStart = 0
    .label TrackWalk2XEnd   = 46
    .label TrackWalk2Y      = 166
    .label DirectionX2      = 1
    .label DirectionY2      = 0

    TreeStartAddress2: .word ScreenMemoryBaseAddress + c64lib_getTextOffset(4, 13)

// Third woodcutter track data
    .label TrackWalk3XStart = 0
    .label TrackWalk3XEnd   = 112
    .label TrackWalk3Y      = 191
    .label DirectionX3      = 1
    .label DirectionY3      = 0

    TreeStartAddress3: .word ScreenMemoryBaseAddress + c64lib_getTextOffset(12, 16)
  }

  * = * "Level3 AddTankTruck"
  AddTankTruck: {
      lda GameEnded
      beq !+
      jmp Done

    !:
// If there is already a truck active, no new truck is needed
      lda TruckActive
      bne Done

      GetRandomUpTo(6)

      cmp #$02
      beq StartTankTruckFromRight

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

  * = * "Level3 HandleTankTruckMove"
  HandleTankTruckMove: {
      lda AddTankTruck.TruckActive
      cmp #$02
      bne Done
      jsr TankTruckFromRight

    Done:
      rts
  }

  * = * "Level3 TankTruckFromRight"
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

      lda #<LakeCoordinates
      sta SetLakeToBlack.StartAddress
      lda #>(LakeCoordinates + 1)
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

    .label TankRightXStart = 92
    .label TankRightXEnd   = 64
    .label TankRightX1BitStart = 1
    .label TankRightY      = 160
    .label TankRightBodySpriteNum = $68
    .label TankRightTailSpriteNum = $69

    .label LakeCoordinates = ScreenMemoryBaseAddress + c64lib_getTextOffset(31, 15)
  }

  * = * "Level3 CleanTankRight"
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

  * = * "Level3 AddArsionist"
  AddArsionist: {
      lda GameEnded
      beq !+
      jmp Done

    !:
// If there is already an arsionist on screen, no arsionist needed
      lda ArsionistActive
      bne Done

      GetRandomUpTo(6)

      cmp #$02
      beq StartArsionistRight

      jmp Done

    StartArsionistRight:
      lda ArsionistFromRight.BushNotAvailable
      bne Done

      lda #$01
      sta ArsionistActive

      lda #SPRITES.ARSIONIST_STANDING
      sta SPRITE_3

    Done:
      rts

    ArsionistActive: .byte $00
  }

  * = * "Level3 HandleArsionistMove"
  HandleArsionistMove: {
      lda AddArsionist.ArsionistActive
      cmp #$01
      bne Done
      jsr ArsionistFromRight

    Done:
      rts
  }

  * = * "Level3 ArsionistFromRight"
  ArsionistFromRight: {
      lda BushNotAvailable
      beq BushNotBurned
      jmp CleanForNextRun

    BushNotBurned:
      lda ArsionistReady
      bne ArsionistReadyForWalkIn

      // Code for arsionist sprite preparing
      lda ArsionistStartX
      sta c64lib.SPRITE_3_X
      lda SPRITES.EXTRA_BIT
      ora #%00011000
      sta SPRITES.EXTRA_BIT

      lda ArsionistStartY
      sta c64lib.SPRITE_3_Y

      EnableSprite(3, true)

      inc ArsionistReady
      jmp Done

    ArsionistReadyForWalkIn:
      lda ArsionistIn
      bne ShowFlameThrower

      lda c64lib.SPRITE_3_X
      cmp ArsionistEndX
      bne !+

      inc ArsionistIn
      jmp ShowFlameThrower

    !:
      // Code for arsionist walk in
      dec c64lib.SPRITE_3_X

      lda #<SPRITE_3
      sta Arsionist.ScreenMemoryAddress + 1
      lda #>SPRITE_3
      sta Arsionist.ScreenMemoryAddress

      CallUpdateArsionistFrame(ArsionistFrame);
      jmp Done

    ShowFlameThrower:
      lda FlameThrowerShown
      bne ArsionistIsBurning

      lda #SPRITES.FLAME_1
      sta SPRITE_4

      lda SPRITES.X3
      clc
      sbc #18
      sta SPRITES.X4
      lda SPRITES.Y3
      sta SPRITES.Y4

      EnableSprite(4, true)
      inc FlameThrowerShown

      jmp Done

    ArsionistIsBurning:
      lda BushBurned
      cmp #$08
      beq ArsionistReadyForWalkOut

      // Code for bush burning
      CallUseTheFlameThrower(FlameFrame, SPRITES.FLAME_3);

      jmp Done

    ArsionistReadyForWalkOut:
      lda ArsionistOut
      bne ArsionistAlreadyOut

      // Code for arsionist walk out
      inc c64lib.SPRITE_3_X

      lda #<SPRITE_3
      sta Arsionist.ScreenMemoryAddress + 1
      lda #>SPRITE_3
      sta Arsionist.ScreenMemoryAddress

      CallUpdateArsionistFrameReverse(ArsionistFrame);
      jmp Done

    ArsionistAlreadyOut:
      lda BushBurned
      cmp #$08
      bne Done

    CleanForNextRun:
      lda #$00
      sta AddArsionist.ArsionistActive

      jsr CleanArsionist

      bne Done
      sta BushNotAvailable

    Done:
      rts

      ArsionistFrame: .byte $00
      FlameFrame: .byte $00

      ArsionistStartX: .byte 90
      ArsionistEndX: .byte 28
      ArsionistStartY: .byte 90

      BushNotAvailable: .byte $00
      ArsionistReady: .byte $00
      ArsionistIn: .byte $00
      FlameThrowerShown: .byte $00
      FlamingDone: .byte $00
      ArsionistOut: .byte $00
      BushBurned: .byte $00   // When is 8, bush is completely burnt
  }

  * = * "Level3 CleanArsionist"
  CleanArsionist: {
      lda #$00
      sta ArsionistFromRight.BushNotAvailable
      sta ArsionistFromRight.ArsionistReady
      sta ArsionistFromRight.ArsionistIn
      sta ArsionistFromRight.FlameThrowerShown
      sta ArsionistFromRight.FlamingDone
      sta ArsionistFromRight.ArsionistOut

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
      jsr AddEnemy
      jsr AddTankTruck
      jsr AddArsionist

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

  * = * "Level3 AddColorToMap"
  AddColorToMap: {
      lda #>ScreenMemoryBaseAddress
      sta SetColorToChars.ScreenMemoryAddress

      jsr SetColorToChars

      rts
  }

  LevelCompleted: .byte $00

  .label ScreenMemoryBaseAddress = $4c00

// Hatchet sprite pointer
  .label SPRITE_1     = ScreenMemoryBaseAddress + $3f9
  .label SPRITE_3     = ScreenMemoryBaseAddress + $3fb

// Enemy sprite pointer
  .label SPRITE_2     = ScreenMemoryBaseAddress + $3fa
  .label SPRITE_4     = ScreenMemoryBaseAddress + $3fc

// Tank tail and body sprite pointer
  .label SPRITE_5     = ScreenMemoryBaseAddress + $3fd
  .label SPRITE_6     = ScreenMemoryBaseAddress + $3fe
  .label SPRITE_7     = ScreenMemoryBaseAddress + $3ff
}

#import "_arsionist.asm"
#import "_utils.asm"
