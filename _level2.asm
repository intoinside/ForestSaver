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

.filenamespace Level2

// Manager of level 2
* = * "Level2 Manager"
Manager: {
    jsr Init
    jsr AddColorToMap

  JoystickMovement:
    jsr WaitRoutine
    jsr TimedRoutine
    jsr GetJoystickMove

    lda LevelCompleted
    bne !+

    jsr Ranger.HandleRangerMove
  !:
    jsr HandleEnemyMove
    jsr HandleTankTruckMove

    jsr CheckLevelCompleted
    lda LevelCompleted
    bne CloseLevelAndGotoNext

    lda GameEnded
    bne CloseLevelAndGame

    jmp JoystickMovement

  CloseLevelAndGotoNext:
    jsr SetSpriteToBackground
    IsReturnPressed()
    bne LevelDone
    jmp JoystickMovement

  CloseLevelAndGame:
    jsr SetSpriteToBackground
    IsReturnPressed()
    bne LevelDone

  EndLoop:
    jmp JoystickMovement

  LevelDone:
    jsr Finalize
  !:
    IsReturnPressed()
    bne !-

    rts
}

// Initialization of level 2
* = * "Level2 Init"
Init: {
    CopyScreenRam(ScreenMemoryBaseAddress, MapDummyArea)

    jsr SetSpriteToForeground
// Set background and border color to brown
    lda #ORANGE
    sta c64lib.BORDER_COL
    sta c64lib.BG_COL_0

    lda #BLACK
    sta c64lib.BG_COL_1
    lda #WHITE
    sta c64lib.BG_COL_2

// Set pointer to char memory to $7800-$7fff (xxxx111x)
// and pointer to screen memory to $4800-$4fff (0010xxxx)
    lda #%00101110
    sta c64lib.MEMORY_CONTROL       

// Init common sprite color
    lda #LIGHT_RED
    sta c64lib.SPRITE_COL_0

    lda #BLACK
    sta c64lib.SPRITE_COL_1

// Woodcutter sprite init
    lda #SPRITES.ENEMY_STANDING
    sta SPRITE_2
    sta SPRITE_4

// Ranger coordinates
    lda #$0
    sta c64lib.SPRITE_MSB_X
    lda #$50
    sta c64lib.SPRITE_0_X
    lda #$40
    sta c64lib.SPRITE_0_Y

// Optimization may be done
// Ranger module init
    lda #>ScreenMemoryBaseAddress
    sta Ranger.ScreenMemoryAddress
    jsr Ranger.Init

    lda #>ScreenMemoryBaseAddress
    sta WoodCutter.ScreenMemoryAddress
    jsr WoodCutter.Init

    lda #<ScreenMemoryBaseAddress
    sta Hud.ScreenMemoryAddress + 1
    lda #>ScreenMemoryBaseAddress
    sta Hud.ScreenMemoryAddress
    jsr Hud.Init

// Sprite color setting
    lda #YELLOW
    sta c64lib.SPRITE_0_COLOR
    lda #ORANGE
    sta c64lib.SPRITE_1_COLOR
    sta c64lib.SPRITE_3_COLOR
    lda #RED
    sta c64lib.SPRITE_2_COLOR
    sta c64lib.SPRITE_4_COLOR
    lda #WHITE
    sta c64lib.SPRITE_5_COLOR
    sta c64lib.SPRITE_6_COLOR
    lda #CYAN
    sta c64lib.SPRITE_7_COLOR

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

    sta ShowDialog.IsShown

    jsr CleanTankLeft
    jsr CleanTankRight

    jsr CompareAndUpdateHiScore

    jsr Hud.ResetDismissalCounter

    rts
}

* = * "Level2 CheckLevelCompleted"
CheckLevelCompleted: {
    lda Hud.CurrentScore + 1
    cmp #6
    bcc Done
    lda ShowDialog.IsShown
    bne Done

    ShowDialogNextLevel(ScreenMemoryBaseAddress)

    inc LevelCompleted

  Done:
    rts
}

* = * "Level2 AddEnemy"
AddEnemy: {
    lda GameEnded
    bne Done

    lda LevelCompleted
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
    sta c64lib.SPRITE_2_X
    lda #$45
    sta c64lib.SPRITE_2_Y

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
    sta c64lib.SPRITE_4_X
    lda #$cf
    sta c64lib.SPRITE_4_Y
    lda c64lib.SPRITE_MSB_X
    ora #%00010000
    sta c64lib.SPRITE_MSB_X

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
    ldx c64lib.SPRITE_1_X
    cpx TrackWalkXEnd
    beq WalkInDone

    inc c64lib.SPRITE_1_X

    CallSetPosition(c64lib.SPRITE_1_X, TrackWalkY, $0, $04, $05);

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
    lda c64lib.SPRITE_2_X
    sta c64lib.SPRITE_1_X
    lda c64lib.SPRITE_2_Y
    sta c64lib.SPRITE_1_Y

    lda c64lib.SPRITE_MSB_X
    and #%00000100
    beq SetHatchetBitToZero
    lda c64lib.SPRITE_MSB_X
    ora #%00000010
    jmp !+

  SetHatchetBitToZero:
    lda c64lib.SPRITE_MSB_X
    and #%11111101

  !:
    sta c64lib.SPRITE_MSB_X

    lda #SPRITES.HATCHET_REV
    sta SPRITE_1

    EnableSprite(1, true)

    inc HatchetShown

    jmp Done

  HatchetStrike:
    lda c64lib.SPRITE_MSB_X
    and #%00000010
    beq !+
    lda #$1
  !:
    sta SpriteCollision.OtherX + 1
    lda c64lib.SPRITE_1_X
    sta SpriteCollision.OtherX
    lda c64lib.SPRITE_1_Y
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

    ShowDialogGameOver(ScreenMemoryBaseAddress)

  !:
    jmp Done

  WalkOut:
  // Hide hatchet and move woodcutter out of screen
    ldx c64lib.SPRITE_1_X
    beq WalkOutDone

    dec c64lib.SPRITE_1_X

    CallSetPosition(c64lib.SPRITE_1_X, TrackWalkY, 0, $04, $05);

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
    sta c64lib.SPRITE_1_X
    lda WoodCutterFromLeft.TrackWalkY
    sta c64lib.SPRITE_1_Y

    rts

// First woodcutter track data
  .label TrackWalk1XStart = 0
  .label TrackWalk1XEnd   = 94
  .label TrackWalk1Y      = 86
  .label DirectionX1      = 1
  .label DirectionY1      = 0

  TreeStartAddress1: .word ScreenMemoryBaseAddress + c64lib_getTextOffset(10, 3)

// Second woodcutter track data
  .label TrackWalk2XStart = 0
  .label TrackWalk2XEnd   = 81
  .label TrackWalk2Y      = 189
  .label DirectionX2      = 1
  .label DirectionY2      = 0

  TreeStartAddress2: .word ScreenMemoryBaseAddress + c64lib_getTextOffset(9, 16)
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
    ldx c64lib.SPRITE_3_X
    cpx TrackWalkXEnd
    beq WalkInDone

    // Woodcutter is not in end position, update x-pos
    dec c64lib.SPRITE_3_X
    dex
    cpx #$ff
    bne !+
    // X-pos had an underflow, set XBit to 0
    dec XBit

  !:
    lda XBit
    beq XBitNotSet2
    CallSetPosition(c64lib.SPRITE_3_X, TrackWalkY, $ff, $08, $09);
    jmp !+

  XBitNotSet2:
    CallSetPosition(c64lib.SPRITE_3_X, TrackWalkY, $0, $08, $09);

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
    lda c64lib.SPRITE_4_X
    sta c64lib.SPRITE_3_X
    lda c64lib.SPRITE_4_Y
    sta c64lib.SPRITE_3_Y

    lda c64lib.SPRITE_MSB_X
    and #%00010000
    beq SetHatchetBitToZero
    lda c64lib.SPRITE_MSB_X
    ora #%00001000
    jmp !+

  SetHatchetBitToZero:
    lda c64lib.SPRITE_MSB_X
    and #%11110111

  !:
    sta c64lib.SPRITE_MSB_X

    lda #SPRITES.HATCHET
    sta SPRITE_3

    EnableSprite(3, true)

    inc HatchetShown

    jmp Done

  HatchetStrike:
    lda c64lib.SPRITE_MSB_X
    and #%00001000
    beq !+
    lda #$01
  !:
    sta SpriteCollision.OtherX + 1
    lda c64lib.SPRITE_3_X
    sta SpriteCollision.OtherX
    lda c64lib.SPRITE_3_Y
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

    ShowDialogGameOver(ScreenMemoryBaseAddress)

  !:
    jmp Done

  WalkOut:
  // Hide hatchet and move woodcutter out of screen
    ldx c64lib.SPRITE_3_X
    cpx TrackWalkXStart
    beq CheckXBitBeforeWalkOutDone
    jmp NoNeedToGoOut

  CheckXBitBeforeWalkOutDone:
    lda XBit
    bne WalkOutDone   // If XBit!=0, woodcutter is out of screen

  NoNeedToGoOut:
    inc c64lib.SPRITE_3_X    // Woodcutter is not out of screen
    bne DontSetXBit   // If x-pos not overflow, don't increment XBit

    inc XBit
  DontSetXBit:
    lda XBit
    beq XBitNotSet
    CallSetPosition(c64lib.SPRITE_3_X, TrackWalkY, $ff, $08, $09);
    jmp !+

  XBitNotSet:
    CallSetPosition(c64lib.SPRITE_3_X, TrackWalkY, $0, $08, $09);

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
    sta c64lib.SPRITE_3_X
    lda WoodCutterFromRight.TrackWalkY
    sta c64lib.SPRITE_3_Y

    rts

// First woodcutter track data
  .label TrackWalk1XStart = 70
  .label TrackWalk1XEnd   = 15
  .label X1BitStart       = 1
  .label TrackWalk1Y      = 71
  .label DirectionX1      = 255
  .label DirectionY1      = 0

  TreeStartAddress1: .word ScreenMemoryBaseAddress + c64lib_getTextOffset(28, 1)

// Second woodcutter track data
  .label TrackWalk2XStart = 70
  .label TrackWalk2XEnd   = 233
  .label X2BitStart       = 1
  .label TrackWalk2Y      = 158
  .label DirectionX2      = 255
  .label DirectionY2      = 0

  TreeStartAddress2: .word ScreenMemoryBaseAddress + c64lib_getTextOffset(23, 12)
}

* = * "Level2 AddTankTruck"
AddTankTruck: {
    lda GameEnded
    beq !+
    jmp Done

  !:
    lda LevelCompleted
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
    sta c64lib.SPRITE_6_X
    clc
    adc #24
    sta c64lib.SPRITE_5_X

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
    sta c64lib.SPRITE_6_X
    clc
    sbc #24
    sta c64lib.SPRITE_5_X

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
    beq !+
    jmp CleanForNextRun

  !:
    lda LevelCompleted
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

    lda c64lib.SPRITE_5_X
    cmp #TankLeftXEnd
    bne !+
    jmp !Update+

  !:
    inc c64lib.SPRITE_5_X
    inc c64lib.SPRITE_6_X

    CallTankSetPosition(c64lib.SPRITE_5_X, TankLeftY, $0, $0a, $0b);
    CallTankSetPosition(c64lib.SPRITE_6_X, TankLeftY, $0, $0c, $0d);
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

    lda c64lib.SPRITE_5_X
    clc
    adc #22
    sta c64lib.SPRITE_7_X

    lda c64lib.SPRITE_5_Y
    sta c64lib.SPRITE_7_Y

    lda c64lib.SPRITE_MSB_X
    and #%00011111
    sta c64lib.SPRITE_MSB_X

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
    lda c64lib.SPRITE_MSB_X
    and #%10000000
    beq !+
    lda #$1
  !:
    sta SpriteCollision.OtherX + 1
    lda c64lib.SPRITE_7_X
    sta SpriteCollision.OtherX
    lda c64lib.SPRITE_7_Y
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

    lda Hud.ReduceDismissalCounter.DismissalCompleted
    sta GameEnded
    beq !Done+

    ShowDialogGameOver(ScreenMemoryBaseAddress)

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
    lda c64lib.SPRITE_5_X
    cmp #TankLeftXStart
    beq DriveOutDone

    dec c64lib.SPRITE_6_X
    bne !DecOtherSprite+
    EnableSprite(6, false)

  !DecOtherSprite:
    dec c64lib.SPRITE_5_X

    CallTankSetPosition(c64lib.SPRITE_5_X, TankLeftY, $0, $0a, $0b);
    CallTankSetPosition(c64lib.SPRITE_6_X, TankLeftY, $0, $0c, $0d);

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

  .label LakeCoordinates = ScreenMemoryBaseAddress + c64lib_getTextOffset(7, 10)
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
    beq !+
    jmp CleanForNextRun

  !:
    lda LevelCompleted
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

    lda c64lib.SPRITE_5_X
    cmp #TankRightXEnd
    bne !+
    jmp !Update+

  !:
    dec c64lib.SPRITE_5_X
    dec c64lib.SPRITE_6_X

    CallTankSetPosition(c64lib.SPRITE_5_X, TankRightY, $1, $0a, $0b);
    CallTankSetPosition(c64lib.SPRITE_6_X, TankRightY, $1, $0c, $0d);
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

    lda c64lib.SPRITE_5_X
    clc
    sbc #22
    sta c64lib.SPRITE_7_X

    lda c64lib.SPRITE_5_Y
    sta c64lib.SPRITE_7_Y

    lda c64lib.SPRITE_MSB_X
    ora #%11100000
    sta c64lib.SPRITE_MSB_X

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
    lda c64lib.SPRITE_MSB_X
    and #%10000000
    beq !+
    lda #$1
  !:
    sta SpriteCollision.OtherX + 1
    lda c64lib.SPRITE_7_X
    sta SpriteCollision.OtherX
    lda c64lib.SPRITE_7_Y
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

    lda Hud.ReduceDismissalCounter.DismissalCompleted
    sta GameEnded
    beq !Done+

    ShowDialogGameOver(ScreenMemoryBaseAddress)

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

    inc c64lib.SPRITE_6_X
    CallTankSetPosition(c64lib.SPRITE_6_X, TankRightY, $1, $0c, $0d);
    lda c64lib.SPRITE_6_X
    cmp #TankRightXStart
    bne !DecOtherSprite+
    EnableSprite(6, false)

  !DecOtherSprite:
    inc c64lib.SPRITE_5_X
    CallTankSetPosition(c64lib.SPRITE_5_X, TankRightY, $1, $0a, $0b);
    lda c64lib.SPRITE_5_X
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

  .label LakeCoordinates = ScreenMemoryBaseAddress + c64lib_getTextOffset(28, 9)
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
    lda LevelCompleted
    bne Exit
    AnimateLake(Char1, $61, $65)
    AnimateLake(Char2, $62, $66)
    jmp Exit

  Delay20:
    lda TankTruckFromLeft.Polluted
    bne Exit
    lda LevelCompleted
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
  .label Char1 = ScreenMemoryBaseAddress + c64lib_getTextOffset(29, 10)
  .label Char2 = ScreenMemoryBaseAddress + c64lib_getTextOffset(30, 10)

  .label Char3 = ScreenMemoryBaseAddress + c64lib_getTextOffset(8, 11)
  .label Char4 = ScreenMemoryBaseAddress + c64lib_getTextOffset(9, 11)

  DelayCounter: .byte 50    // Counter storage
  DelayRequested: .byte 50  // 1 second delay
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
    lda #>ScreenMemoryBaseAddress
    sta SetColorToChars.ScreenMemoryAddress

    jmp SetColorToChars
}

LevelCompleted: .byte $00

.label ScreenMemoryBaseAddress = $4800

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

#import "_utils.asm"
#import "_joystick.asm"
#import "_keyboard.asm"
#import "_hud.asm"
#import "_ranger.asm"
#import "_woodcutter.asm"
#import "_hatchet.asm"
#import "_tanktruck.asm"

#import "chipset/lib/vic2-global.asm"
