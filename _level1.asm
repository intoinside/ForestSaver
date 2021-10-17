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

Level1: {

// Manager of level 1
  * = * "Level1 Manager"
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
  * = * "Level1 Init"
  Init: {
      CopyScreenRam($4400, $5000)

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
      lda #%00011110
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
      lda #$44
      sta Ranger.ScreenMemoryAddress
      jsr Ranger.Init

      lda #$00
      sta WoodCutter.ScreenMemoryAddress + 1
      lda #$44
      sta WoodCutter.ScreenMemoryAddress
      jsr WoodCutter.Init

      lda #$00
      sta Hud.ScreenMemoryAddress + 1
      lda #$44
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

// Enable the first sprite (ranger)
      lda #%00000001
      sta VIC.SPRITE_ENABLE

      GetRandomUpTo(3)
      sta Enemy2Manager.CurrentWoodCutter
      GetRandomUpTo(3)
      sta Enemy3Manager.CurrentWoodCutter

      jsr SetWoodCutter2Track
      jsr SetWoodCutter3Track

      rts
  }

  * = * "Level1 Finalize"
  Finalize: {
      CopyScreenRam($5000, $4400)

      lda #$00
      sta VIC.SPRITE_ENABLE
      sta AddEnemy.EnemyActive
      sta Enemy2Manager.WoodCutterFined
      sta Enemy2Manager.ComplaintShown
      sta Enemy2Manager.CutCompleted
      sta Enemy2Manager.WalkInCompleted
      sta Enemy2Manager.HatchetShown

      sta Enemy2Manager.TreeAlreadyCut
      sta Enemy2Manager.TreeAlreadyCut + 1
      sta Enemy2Manager.TreeAlreadyCut + 2

      sta Enemy3Manager.WoodCutterFined
      sta Enemy3Manager.ComplaintShown
      sta Enemy3Manager.CutCompleted
      sta Enemy3Manager.WalkInCompleted
      sta Enemy3Manager.HatchetShown

      sta Enemy3Manager.TreeAlreadyCut
      sta Enemy3Manager.TreeAlreadyCut + 1
      sta Enemy3Manager.TreeAlreadyCut + 2

      sta Hud.ReduceDismissalCounter.DismissalCompleted

      jsr CompareAndUpdateHiScore

      jsr Hud.ResetScore
      jsr Hud.ResetDismissalCounter

      jsr DisableAllSprites

      rts
  }

  * = * "Level1 AddEnemy"
  AddEnemy: {
      lda GameEnded
      bne Done

      GetRandomUpTo(6)

      cmp #$02
      beq StartEnemy2

      cmp #$03
      beq StartEnemy3

      jmp Done

    StartEnemy2:
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

    StartEnemy3:
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

  * = * "Level1 HandleEnemyMove"
  HandleEnemyMove: {
      lda AddEnemy.EnemyActive
      and #%00000100
      beq IsEnemyNo3Alive
      jsr Enemy2Manager

    IsEnemyNo3Alive:
      lda AddEnemy.EnemyActive
      and #%00001000
      beq Done
      jsr Enemy3Manager

    Done:
      rts
  }

  * = * "Level1 Enemy2Manager"
  Enemy2Manager: {
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

      AddPoints(0, 0, 1, 0);

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
      cmp #%00000010
      beq SetExtraBit
      lda #$00
      jmp NextArg
    SetExtraBit:
      lda #$01
    NextArg:
      sta SpriteCollision.I1 + 1
      lda SPRITES.X1
      sta SpriteCollision.I1
      lda SPRITES.Y1
      sta SpriteCollision.J1
      jsr SpriteCollision
      lda SpriteCollision.Collision
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

      lda #$44
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
      jsr SetWoodCutter2Track

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

    .label HatchetStrokesMax = $0c
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

  * = * "Level1 SetWoodCutter2Track"
  SetWoodCutter2Track: {
      ldx #0

      lda Enemy2Manager.CurrentWoodCutter
      cmp #$02
      beq FixForWoodCutter3
      cmp #$01
      beq FixForWoodCutter2

    FixForWoodCutter1:
      lda #TrackWalk1XStart
      sta Enemy2Manager.TrackWalkXStart
      lda #TrackWalk1XEnd
      sta Enemy2Manager.TrackWalkXEnd

      lda #TrackWalk1Y
      sta Enemy2Manager.TrackWalkY

      lda #DirectionX1
      sta Enemy2Manager.DirectionX
      lda #DirectionY1
      sta Enemy2Manager.DirectionY

      lda TreeStartAddress1
      sta Enemy2Manager.TreeStartAddress
      lda TreeStartAddress1 + 1
      sta Enemy2Manager.TreeStartAddress + 1

      jmp Done

    FixForWoodCutter2:
      lda #TrackWalk2XStart
      sta Enemy2Manager.TrackWalkXStart
      lda #TrackWalk2XEnd
      sta Enemy2Manager.TrackWalkXEnd

      lda #TrackWalk2Y
      sta Enemy2Manager.TrackWalkY

      lda #DirectionX2
      sta Enemy2Manager.DirectionX
      lda #DirectionY2
      sta Enemy2Manager.DirectionY

      lda TreeStartAddress2
      sta Enemy2Manager.TreeStartAddress
      lda TreeStartAddress2 + 1
      sta Enemy2Manager.TreeStartAddress + 1

      jmp Done

    FixForWoodCutter3:
      lda #TrackWalk3XStart
      sta Enemy2Manager.TrackWalkXStart
      lda #TrackWalk3XEnd
      sta Enemy2Manager.TrackWalkXEnd

      lda #TrackWalk3Y
      sta Enemy2Manager.TrackWalkY

      lda #DirectionX3
      sta Enemy2Manager.DirectionX
      lda #DirectionY3
      sta Enemy2Manager.DirectionY

      lda TreeStartAddress3
      sta Enemy2Manager.TreeStartAddress
      lda TreeStartAddress3 + 1
      sta Enemy2Manager.TreeStartAddress + 1

    Done:

      lda Enemy2Manager.TrackWalkXStart
      sta SPRITES.X1
      lda Enemy2Manager.TrackWalkY
      sta SPRITES.Y1

      rts

// First woodcutter track data
    .label TrackWalk1XStart = 0
    .label TrackWalk1XEnd   = 114
    .label TrackWalk1Y      = 79
    .label DirectionX1      = 1
    .label DirectionY1      = 0

    TreeStartAddress1: .word $445c

// Second woodcutter track data
    .label TrackWalk2XStart = 0
    .label TrackWalk2XEnd   = 45
    .label TrackWalk2Y      = 136
    .label DirectionX2      = 1
    .label DirectionY2      = 0

    TreeStartAddress2: .word $456c

// Third woodcutter track data
    .label TrackWalk3XStart = 0
    .label TrackWalk3XEnd   = 180
    .label TrackWalk3Y      = 167
    .label DirectionX3      = 1
    .label DirectionY3      = 0

    TreeStartAddress3: .word $461c
  }

  * = * "Level1 Enemy3Manager"
  Enemy3Manager: {
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

      AddPoints(0, 0, 1, 0);

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
      cmp #%00001000
      beq SetExtraBit
      lda #$00
      jmp NextArg
    SetExtraBit:
      lda #$01
    NextArg:
      sta SpriteCollision.I1 + 1
      lda SPRITES.X3
      sta SpriteCollision.I1
      lda SPRITES.Y3
      sta SpriteCollision.J1
      jsr SpriteCollision
      lda SpriteCollision.Collision
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

      lda #$44
      sta ShowGameEndedMessage.StartAddress + 1
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
      cpx #$03
      bne LookForTreeAvailable
      jmp Done
    CheckNextWoodCutter:
      GetRandomUpTo(3)
      tax
      lda TreeAlreadyCut, x
      bne CheckNextWoodCutter
      stx CurrentWoodCutter
      jsr SetWoodCutter3Track

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

    TreeAlreadyCut: .byte $00, $00, $00

    .label HatchetStrokesMax = $0c
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

    * = * "Level1 SetWoodCutter3Track"
  SetWoodCutter3Track: {
      ldx #0

      lda Enemy3Manager.CurrentWoodCutter
      cmp #$01
      beq FixForWoodCutter2
      cmp #$02
      beq FixForWoodCutter3

    FixForWoodCutter1:
      lda #TrackWalk1XStart
      sta Enemy3Manager.TrackWalkXStart
      lda #TrackWalk1XEnd
      sta Enemy3Manager.TrackWalkXEnd

      lda #X1BitStart
      sta Enemy3Manager.XBit

      lda #TrackWalk1Y
      sta Enemy3Manager.TrackWalkY

      lda #DirectionX1
      sta Enemy3Manager.DirectionX
      lda #DirectionY1
      sta Enemy3Manager.DirectionY

      lda TreeStartAddress1
      sta Enemy3Manager.TreeStartAddress
      lda TreeStartAddress1 + 1
      sta Enemy3Manager.TreeStartAddress + 1
      jmp Done

    FixForWoodCutter2:
      lda #TrackWalk2XStart
      sta Enemy3Manager.TrackWalkXStart
      lda #TrackWalk2XEnd
      sta Enemy3Manager.TrackWalkXEnd

      lda #X2BitStart
      sta Enemy3Manager.XBit

      lda #TrackWalk2Y
      sta Enemy3Manager.TrackWalkY

      lda #DirectionX2
      sta Enemy3Manager.DirectionX
      lda #DirectionY2
      sta Enemy3Manager.DirectionY

      lda TreeStartAddress2
      sta Enemy3Manager.TreeStartAddress
      lda TreeStartAddress2 + 1
      sta Enemy3Manager.TreeStartAddress + 1
      jmp Done

    FixForWoodCutter3:
      lda #TrackWalk3XStart
      sta Enemy3Manager.TrackWalkXStart
      lda #TrackWalk3XEnd
      sta Enemy3Manager.TrackWalkXEnd

      lda #X3BitStart
      sta Enemy3Manager.XBit

      lda #TrackWalk3Y
      sta Enemy3Manager.TrackWalkY

      lda #DirectionX3
      sta Enemy3Manager.DirectionX
      lda #DirectionY3
      sta Enemy3Manager.DirectionY

      lda TreeStartAddress3
      sta Enemy3Manager.TreeStartAddress
      lda TreeStartAddress3 + 1
      sta Enemy3Manager.TreeStartAddress + 1

    Done:

      lda Enemy3Manager.TrackWalkXStart
      sta SPRITES.X3
      lda Enemy3Manager.TrackWalkY
      sta SPRITES.Y3

      rts

// First woodcutter track data
    .label TrackWalk1XStart = 70
    .label TrackWalk1XEnd   = 210
    .label X1BitStart       = 1
    .label TrackWalk1Y      = 87
    .label DirectionX1      = 255
    .label DirectionY1      = 0

    TreeStartAddress1: .word $448d

// Second woodcutter track data
    .label TrackWalk2XStart = 70
    .label TrackWalk2XEnd   = 40
    .label X2BitStart       = 1
    .label TrackWalk2Y      = 145
    .label DirectionX2      = 255
    .label DirectionY2      = 0

    TreeStartAddress2: .word $45b0

// Third woodcutter track data
    .label TrackWalk3XStart = 70
    .label TrackWalk3XEnd   = 10
    .label X3BitStart       = 1
    .label TrackWalk3Y      = 199
    .label DirectionX3      = 255
    .label DirectionY3      = 0

    TreeStartAddress3: .word $46c4
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
      lda #$44
      sta SetColorToChars.ScreenMemoryAddress

      jsr SetColorToChars

      rts
  }

// Hatchet sprite pointer
  .label SPRITE_1     = $47f9
  .label SPRITE_3     = $47fb

// Enemy sprite pointer
  .label SPRITE_2     = $47fa
  .label SPRITE_4     = $47fc
}

#import "_hud.asm"
#import "_ranger.asm"
#import "_woodcutter.asm"
#import "_hatchet.asm"
#import "_utils.asm"
