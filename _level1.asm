////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Manager for level 1.
//
// Sprite pointer settings:
// * Ranger       Sprite 0
// * Hatchet 1    Sprite 1
// * Woodcutter 1 Sprite 2
// * Hatchet 2    Sprite 3
// * Woodcutter 2 Sprite 4
//
////////////////////////////////////////////////////////////////////////////////

#importonce

.filenamespace Level1

// Manager of level 1
* = * "Level1 Manager"
Manager: {
    jsr Init

  JoystickMovement:
    jsr WaitRoutine
    jsr TimedRoutine
    jsr GetJoystickMove

    lda LevelCompleted
    bne !+

    jsr Ranger.HandleRangerMove
  !:
    jsr HandleEnemyMove

    jsr CheckLevelCompleted
    lda LevelCompleted
    bne CloseLevelAndGotoNext

    lda GameEnded
    bne CloseLevelAndGame

    jmp JoystickMovement

  CloseLevelAndGotoNext:
    jsr SetSpriteToBackground
    jsr Ranger.ConvertDismissalToPoint
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

// Initialization of intro screen
* = * "Level1 Init"
Init: {
    CopyScreenRam(ScreenMemoryBaseAddress, MapDummyArea)

    jsr SetSpriteToForeground
// Set background and border color to brown
    lda #BROWN
    sta c64lib.BORDER_COL
    sta c64lib.BG_COL_0

    lda #BLACK
    sta c64lib.BG_COL_1
    lda #WHITE
    sta c64lib.BG_COL_2

// Set pointer to char memory to $7800-$7fff (xxxx111x)
// and pointer to screen memory to $4400-$47ff (0001xxxx)
    lda #%00011110
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

// Enable the first sprite (ranger)
    EnableSprite(0, true)

    GetRandomUpTo(3)
    sta WoodCutterFromLeft.CurrentWoodCutter
    GetRandomUpTo(3)
    sta WoodCutterFromRight.CurrentWoodCutter

    jsr SetLeftWoodCutterTrack
    jsr SetRightWoodCutterTrack

    jmp AddColorToMap   // jsr + rts
}

* = * "Level1 Finalize"
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
    sta WoodCutterFromLeft.TreeAlreadyCut + 2

    sta WoodCutterFromRight.WoodCutterFined
    sta WoodCutterFromRight.ComplaintShown
    sta WoodCutterFromRight.CutCompleted
    sta WoodCutterFromRight.WalkInCompleted
    sta WoodCutterFromRight.HatchetShown

    sta WoodCutterFromRight.TreeAlreadyCut
    sta WoodCutterFromRight.TreeAlreadyCut + 1
    sta WoodCutterFromRight.TreeAlreadyCut + 2

    sta Hud.ReduceDismissalCounter.DismissalCompleted

    sta ShowDialog.IsShown

    jsr CompareAndUpdateHiScore

    jsr Hud.ResetDismissalCounter

    rts
}

* = * "Level1 CheckLevelCompleted"
CheckLevelCompleted: {
    lda Hud.CurrentScore + 1
    cmp #2
    bcc Done
    lda ShowDialog.IsShown
    bne Done

    ShowDialogNextLevel(ScreenMemoryBaseAddress)

    inc LevelCompleted

  Done:
    rts
}

* = * "Level1 AddEnemy"
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

* = * "Level1 HandleEnemyMove"
HandleEnemyMove: {
    lda AddEnemy.EnemyActive
    and #%00000100
    beq IsEnemyNo3Alive
    jsr WoodCutterFromLeft

  IsEnemyNo3Alive:
    lda AddEnemy.EnemyActive
    and #%00001000
    beq Done
    jsr WoodCutterFromRight

  Done:
    rts
}

* = * "Level1 WoodCutterFromLeft"
WoodCutterFromLeft: {
    lda WoodCutterFined
    beq CutCompletedCheck
    lda ComplaintShown
    bne GoToWalkOutFar

    EnableSprite(1, false)

    lda TreeStartAddress
    sta HandleEnemyFined.MapComplain
    lda TreeStartAddress + 1
    sta HandleEnemyFined.MapComplain + 1
    lda #$01
    sta HandleEnemyFined.AddOrSub
    lda #$03
    sta HandleEnemyFined.Offset
    jsr HandleEnemyFined
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
    SetSpriteToSamePosition(c64lib.SPRITE_2_X, c64lib.SPRITE_1_X)
    SetXBitToSameValue(2, 1)

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
    bne DoneFar
    inc CutCompleted
    jmp HideHatchet

  RangerWoodCutterMet:
    inc WoodCutterFined

  DoneFar:
    jmp Done
  HideHatchet:
    lda #$00
    sta HatchetShown

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
    sta HandleEnemyFinedOut.MapComplain
    lda TreeStartAddress + 1
    sta HandleEnemyFinedOut.MapComplain + 1
    lda #$01
    sta HandleEnemyFinedOut.AddOrSub
    lda #$03
    sta HandleEnemyFinedOut.Offset
    jsr HandleEnemyFinedOut

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
    jsr SaveLeftTreeStrokesCount
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

  Done:
    rts

  TreeAlreadyCut: .byte $00, $00, $00

  // Number of strokes to cut tree
  HatchetStrokes: .byte 0

  HatchetFrame: .byte $ff
  WoodCutterFrame: .byte $00
  WoodCutterFined: .byte $00
  ComplaintShown: .byte 0
  HatchetShown: .byte 0
  CutCompleted: .byte 0
  WalkInCompleted: .byte 0
  CurrentWoodCutter: .byte $00

// Woodcutter dummy data
  TrackWalkXStart:  .byte $00
  TrackWalkXEnd:    .byte $00
  TrackWalkY:       .byte $00

  DirectionX:       .byte $00
  DirectionY:       .byte $00

  TreeStartAddress: .word $beef
}

* = * "Level1 SaveLeftTreeStrokesCount"
SaveLeftTreeStrokesCount: {
    lda WoodCutterFromLeft.CurrentWoodCutter
    cmp #$01
    beq SaveTree2StrokesCount
    cmp #$02
    beq SaveTree3StrokesCount

  SaveTree1StrokesCount:
    lda WoodCutterFromLeft.HatchetStrokes
    sta SetLeftWoodCutterTrack.TreeStrokesCount1
    jmp !+

  SaveTree2StrokesCount:  
    lda WoodCutterFromLeft.HatchetStrokes
    sta SetLeftWoodCutterTrack.TreeStrokesCount2
    jmp !+

  SaveTree3StrokesCount:  
    lda WoodCutterFromLeft.HatchetStrokes
    sta SetLeftWoodCutterTrack.TreeStrokesCount3

  !:
    rts
}

* = * "Level1 SetLeftWoodCutterTrack"
SetLeftWoodCutterTrack: {
    lda WoodCutterFromLeft.CurrentWoodCutter
    cmp #$02
    beq FixForWoodCutter3
    cmp #$01
    beq FixForWoodCutter2

  FixForWoodCutter1:
    lda TreeStrokesCount1
    sta WoodCutterFromLeft.HatchetStrokes

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
    lda TreeStrokesCount2
    sta WoodCutterFromLeft.HatchetStrokes

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
    lda TreeStrokesCount3
    sta WoodCutterFromLeft.HatchetStrokes

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
    sta c64lib.SPRITE_1_X
    lda WoodCutterFromLeft.TrackWalkY
    sta c64lib.SPRITE_1_Y

    rts

// First woodcutter track data
  .label TrackWalk1XStart = 0
  .label TrackWalk1XEnd   = 108
  .label TrackWalk1Y      = 79
  .label DirectionX1      = 1
  .label DirectionY1      = 0

  TreeStartAddress1: .word $445c
  TreeStrokesCount1: .byte HatchetStrokesMax

// Second woodcutter track data
  .label TrackWalk2XStart = 0
  .label TrackWalk2XEnd   = 39
  .label TrackWalk2Y      = 136
  .label DirectionX2      = 1
  .label DirectionY2      = 0

  TreeStartAddress2: .word $456c
  TreeStrokesCount2: .byte HatchetStrokesMax

// Third woodcutter track data
  .label TrackWalk3XStart = 0
  .label TrackWalk3XEnd   = 174
  .label TrackWalk3Y      = 167
  .label DirectionX3      = 1
  .label DirectionY3      = 0

  TreeStartAddress3: .word $461c
  TreeStrokesCount3: .byte HatchetStrokesMax

  .label HatchetStrokesMax = 20
}

* = * "Level1 WoodCutterFromRight"
WoodCutterFromRight: {
    lda WoodCutterFined
    beq CutCompletedCheck
    lda ComplaintShown
    bne GoToWalkOutFar

    EnableSprite(3, false)

    lda TreeStartAddress
    sta HandleEnemyFined.MapComplain
    lda TreeStartAddress + 1
    sta HandleEnemyFined.MapComplain + 1
    lda #$ff
    sta HandleEnemyFined.AddOrSub
    lda #$05
    sta HandleEnemyFined.Offset
    jsr HandleEnemyFined
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
    SetSpriteToSamePosition(c64lib.SPRITE_4_X, c64lib.SPRITE_3_X)
    SetXBitToSameValue(4, 3)

    lda #SPRITES.HATCHET
    sta SPRITE_3

    EnableSprite(3, true)

    inc HatchetShown

    jmp Done

  HatchetStrike:
    lda c64lib.SPRITE_MSB_X
    and #%00001000
    beq !+
    lda #$1
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
    bne DoneFar
    inc CutCompleted
    jmp HideHatchet

  RangerWoodCutterMet:
    inc WoodCutterFined

  DoneFar:
    jmp Done
  HideHatchet:
    lda #$00
    sta HatchetShown

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
    sta HandleEnemyFinedOut.MapComplain
    lda TreeStartAddress + 1
    sta HandleEnemyFinedOut.MapComplain + 1
    lda #$ff
    sta HandleEnemyFinedOut.AddOrSub
    lda #$05
    sta HandleEnemyFinedOut.Offset
    jsr HandleEnemyFinedOut

    EnableSprite(4, false)

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
    jsr SaveRightTreeStrokesCount
    GetRandomUpTo(3)
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

  Done:
    rts

  TreeAlreadyCut: .byte $00, $00, $00

  // Number of strokes to cut tree
  HatchetStrokes: .byte 0

  HatchetFrame: .byte $ff
  WoodCutterFrame: .byte $00
  WoodCutterFined: .byte $00
  ComplaintShown: .byte 0
  HatchetShown: .byte 0
  CutCompleted: .byte 0
  WalkInCompleted: .byte 0
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

* = * "Level1 SaveRightTreeStrokesCount"
SaveRightTreeStrokesCount: {
    lda WoodCutterFromRight.CurrentWoodCutter
    cmp #$01
    beq SaveTree2StrokesCount
    cmp #$02
    beq SaveTree3StrokesCount

  SaveTree1StrokesCount:
    lda WoodCutterFromRight.HatchetStrokes
    sta SetRightWoodCutterTrack.TreeStrokesCount1
    jmp !+

  SaveTree2StrokesCount:  
    lda WoodCutterFromRight.HatchetStrokes
    sta SetRightWoodCutterTrack.TreeStrokesCount2
    jmp !+

  SaveTree3StrokesCount:  
    lda WoodCutterFromRight.HatchetStrokes
    sta SetRightWoodCutterTrack.TreeStrokesCount3

  !:
    rts
}

* = * "Level1 SetRightWoodCutterTrack"
SetRightWoodCutterTrack: {
// Save current tree stroke count
    lda WoodCutterFromRight.CurrentWoodCutter
    cmp #$01
    beq FixForWoodCutter2
    cmp #$02
    beq FixForWoodCutter3

  FixForWoodCutter1:
    lda TreeStrokesCount1
    sta WoodCutterFromRight.HatchetStrokes

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
    lda TreeStrokesCount2
    sta WoodCutterFromRight.HatchetStrokes

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
    jmp Done

  FixForWoodCutter3:
    lda TreeStrokesCount3
    sta WoodCutterFromRight.HatchetStrokes

    lda #TrackWalk3XStart
    sta WoodCutterFromRight.TrackWalkXStart
    lda #TrackWalk3XEnd
    sta WoodCutterFromRight.TrackWalkXEnd

    lda #X3BitStart
    sta WoodCutterFromRight.XBit

    lda #TrackWalk3Y
    sta WoodCutterFromRight.TrackWalkY

    lda #DirectionX3
    sta WoodCutterFromRight.DirectionX
    lda #DirectionY3
    sta WoodCutterFromRight.DirectionY

    lda TreeStartAddress3
    sta WoodCutterFromRight.TreeStartAddress
    lda TreeStartAddress3 + 1
    sta WoodCutterFromRight.TreeStartAddress + 1

  Done:
    lda WoodCutterFromRight.TrackWalkXStart
    sta c64lib.SPRITE_3_X
    lda WoodCutterFromRight.TrackWalkY
    sta c64lib.SPRITE_3_Y

    rts

// First woodcutter track data
  .label TrackWalk1XStart = 70
  .label TrackWalk1XEnd   = 216
  .label X1BitStart       = 1
  .label TrackWalk1Y      = 87
  .label DirectionX1      = 255
  .label DirectionY1      = 0

  TreeStartAddress1: .word $448d
  TreeStrokesCount1: .byte HatchetStrokesMax

// Second woodcutter track data
  .label TrackWalk2XStart = 70
  .label TrackWalk2XEnd   = 46
  .label X2BitStart       = 1
  .label TrackWalk2Y      = 145
  .label DirectionX2      = 255
  .label DirectionY2      = 0

  TreeStartAddress2: .word $45b0
  TreeStrokesCount2: .byte HatchetStrokesMax

// Third woodcutter track data
  .label TrackWalk3XStart = 70
  .label TrackWalk3XEnd   = 16
  .label X3BitStart       = 1
  .label TrackWalk3Y      = 199
  .label DirectionX3      = 255
  .label DirectionY3      = 0

  TreeStartAddress3: .word $46c4
  TreeStrokesCount3: .byte HatchetStrokesMax

  .label HatchetStrokesMax = 20
}

* = * "Level1 TimedRoutine"
TimedRoutine: {
    jsr TimedRoutine10th

    lda DelayCounter
    beq DelayTriggered        // when counter is zero stop decrementing
    dec DelayCounter          // decrement the counter

    jmp Exit

  DelayTriggered:
    lda DelayRequested        // delay reached 0, reset it
    sta DelayCounter

  Waiting:
    jsr AddEnemy

    jmp Exit

  Exit:
    rts

  DelayCounter: .byte 50      // Counter storage
  DelayRequested: .byte 50    // 1 second delay
}

TimedRoutine10th: {
    lda DelayCounter
    beq DelayTriggered        // when counter is zero stop decrementing
    dec DelayCounter          // decrement the counter

    jmp Exit

  DelayTriggered:
    lda DelayRequested        // delay reached 0, reset it
    sta DelayCounter

  Exit:
    rts

  DelayCounter: .byte 8       // Counter storage
  DelayRequested: .byte 8     // 8/50 second delay
}

AddColorToMap: {
    lda #>ScreenMemoryBaseAddress
    sta SetColorToChars.ScreenMemoryAddress

    jmp SetColorToChars
}

LevelCompleted: .byte $00

.label ScreenMemoryBaseAddress = $4400

// Hatchet sprite pointer
.label SPRITE_1     = ScreenMemoryBaseAddress + $3f9
.label SPRITE_3     = ScreenMemoryBaseAddress + $3fb

// Enemy sprite pointer
.label SPRITE_2     = ScreenMemoryBaseAddress + $3fa
.label SPRITE_4     = ScreenMemoryBaseAddress + $3fc

#import "_utils.asm"
#import "_joystick.asm"
#import "_keyboard.asm"
#import "_hud.asm"
#import "_ranger.asm"
#import "_woodcutter.asm"
#import "_hatchet.asm"
