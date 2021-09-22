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

    CheckFirePressed:
      lda FirePressed
      bne LevelDone

      jmp JoystickMovement

    LevelDone:
      jsr Finalize
  }

  // Initialization of intro screen
  * = * "Level1 Init"
  Init: {
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
//      sta SPRITE_6

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
//      sta SPRITES.COLOR5
      lda #$02
      sta SPRITES.COLOR2
      sta SPRITES.COLOR4
//      sta SPRITES.COLOR6

// Enable the first sprite (ranger)
      lda #%00000001
      sta VIC.SPRITE_ENABLE

      jsr SetWoodCutter2Track
      jsr SetWoodCutter3Track

      rts
  }

  * = * "Level1 Finalize"
  Finalize: {
      lda #$00
      sta VIC.SPRITE_ENABLE

      rts
  }

  * = * "Level1 AddEnemy"
  AddEnemy: {
      lda WaitingForEnemy
      beq Done

      GetRandomUpTo(6)

      cmp #$02
      beq StartEnemy2

      cmp #$03
      beq StartEnemy3

/*
      cmp #$04
      beq StartEnemy4

      cmp #$03
      beq StartEnemy4

      cmp #$02
      beq StartEnemy5

      cmp #$01
      beq StartEnemy7
*/

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

      dec WaitingForEnemy

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

      dec WaitingForEnemy

      jmp Done

/*
    StartEnemy4:
      jmp Done

    StartEnemy5:
      jmp Done

    StartEnemy6:
      jmp Done

    StartEnemy7:
      jmp Done
*/

    Done:
      rts

    EnemyActive:      .byte $00
    WaitingForEnemy:  .byte $06
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

/*
    IsEnemyNo4Alive:
    IsEnemyNo5Alive:
    IsEnemyNo6Alive:
    IsEnemyNo7Alive:
*/
    Done:
      rts
  }

  * = * "Level1 HandleWoodCutterFined"
  HandleWoodCutterFined: {
// Char self mod
      lda ComplainChars
      sta EditMap1 + 1
      lda ComplainChars + 1
      sta EditMap2 + 1
      lda ComplainChars + 2
      sta EditMap3 + 1

      lda ComplainChars + 3
      sta EditMap4 + 1
      lda ComplainChars + 4
      sta EditMap5 + 1
      lda ComplainChars + 5
      sta EditMap6 + 1

// Map self mod
      lda MapComplain
      sta EditMap1 + 3
      lda MapComplain + 1
      sta EditMap1 + 4

      lda MapComplain + 2
      sta EditMap2 + 3
      lda MapComplain + 3
      sta EditMap2 + 4

      lda MapComplain + 4
      sta EditMap3 + 3
      lda MapComplain + 5
      sta EditMap3 + 4

      lda MapComplain + 6
      sta EditMap4 + 3
      lda MapComplain + 7
      sta EditMap4 + 4

      lda MapComplain + 8
      sta EditMap5 + 3
      lda MapComplain + 9
      sta EditMap5 + 4

      lda MapComplain + 10
      sta EditMap6 + 3
      lda MapComplain + 11
      sta EditMap6 + 4

    Stage1:
// WoodCutter and Ranger met, hide hatchet
      EnableSprite(1, false)

    EditMap1:
      lda #$00
      sta $beef
    EditMap2:
      lda #$00
      sta $beef
    EditMap3:
      lda #$00
      sta $beef

    EditMap4:
      lda #$00
      sta $beef
    EditMap5:
      lda #$00
      sta $beef
    EditMap6:
      lda #$00
      sta $beef

      rts

    ComplainChars:  .byte $64, $65, $66, $67, $68, $69
    MapComplain:    .word $4569, $456a, $456b, $4591, $4592, $4593
  }

  * = * "Level1 HandleWoodCutterFinedOut"
  HandleWoodCutterFinedOut: {
      lda MapComplain
      sta EditMap1 + 1
      lda MapComplain + 1
      sta EditMap1 + 2

      lda MapComplain + 2
      sta EditMap2 + 1
      lda MapComplain + 3
      sta EditMap2 + 2

      lda MapComplain + 4
      sta EditMap3 + 1
      lda MapComplain + 5
      sta EditMap3 + 2

      lda MapComplain + 6
      sta EditMap4 + 1
      lda MapComplain + 7
      sta EditMap4 + 2

      lda MapComplain + 8
      sta EditMap5 + 1
      lda MapComplain + 9
      sta EditMap5 + 2

      lda MapComplain + 10
      sta EditMap6 + 1
      lda MapComplain + 11
      sta EditMap6 + 2

    EditCharMap1:
      lda FixComplainChars
    EditMap1:
      sta $beef
    EditMap2:
      sta $beef
    EditMap3:
      sta $beef

    EditMap4:
      sta $beef
    EditMap5:
      sta $beef
    EditMap6:
      sta $beef

      rts

    FixComplainChars: .byte $00
    MapComplain:      .word $4569, $456a, $456b, $4591, $4592, $4593
  }

  * = * "Level1 Enemy2Manager"
  Enemy2Manager: {
      lda WoodCutterFined
      beq CutCompletedCheck
      lda ComplaintShown
      bne GoToWalkOutFar

      jsr HandleWoodCutterFined
      inc ComplaintShown

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
      ldx TrackPointer
      cpx #TrackWalkCounter
      beq WalkInDone

      // Woodcutter didn't reached the tree, walk
      lda TrackWalkXXbit, x
      bne Call2_a
    Call1_a:
      CallSetPosition(TrackWalkX, TrackWalkY, 0, $04, $05);
      jmp Proceed_a
    Call2_a:
      CallSetPosition(TrackWalkX, TrackWalkY, $ff, $04, $05);

    Proceed_a:
      lda #<SPRITE_2
      sta WoodCutter.ScreenMemoryAddress + 1
      lda #>SPRITE_2
      sta WoodCutter.ScreenMemoryAddress

      CallUpdateWoodCutterFrame(DirectionX, DirectionY, WoodCutterFrame);

      inc TrackPointer

      jmp Done

      // Woodcutter is in position, stop walk
    WalkInDone:
      inc WalkInCompleted

      jmp Done

    ShowHatchet:
      // Woodcutter is in position, start to cut the tree
      lda HatchetShown
      bne HatchetStrike

      dec TrackPointer

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
// TODO(rafs): need to setup a new collision detector
      // SpriteCollided(0);
      // bne RangerWoodCutterMet

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
      RemoveTree(TreeStartAddress, TreeColorStartAddress)
      /*
      lda TreeStartAddress
      sta RemoveTree.StartAddress
      lda TreeStartAddress + 1
      sta RemoveTree.StartAddress + 1
      jsr RemoveTree
      */
      jmp Done

    WalkOut:
    // Hide hatchet and move woodcutter out of screen
      ldx TrackPointer
      beq WalkOutDone

// TODO(rafs): this code can be optimized?
      lda TrackWalkXXbit, x
      bne Call2_b
    Call1_b:
      CallSetPosition(TrackWalkX, TrackWalkY, 0, $04, $05);
      jmp Proceed_b
    Call2_b:
      CallSetPosition(TrackWalkX, TrackWalkY, $ff, $04, $05);

    Proceed_b:
      lda #<SPRITE_2
      sta WoodCutter.ScreenMemoryAddress + 1
      lda #>SPRITE_2
      sta WoodCutter.ScreenMemoryAddress

      CallUpdateWoodCutterFrameReverse(DirectionX, DirectionY, WoodCutterFrame);

      dec TrackPointer

      jmp Done

    WalkOutDone:
      lda ComplaintHidden
      jsr HandleWoodCutterFinedOut
      inc ComplaintHidden

      EnableSprite(2, false)

      // Prepare next sprite track
      inc CurrentWoodCutter
      lda CurrentWoodCutter
      cmp #4
      bpl Done
      jsr SetWoodCutter2Track

      // Clear sprite
      lda AddEnemy.EnemyActive
      and #%11111011
      sta AddEnemy.EnemyActive

      lda #0
      sta HatchetShown
      sta TrackPointer
      sta CutCompleted
      sta WalkInCompleted

    Done:
      rts

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
    ComplaintHidden:
      .byte 0

    HatchetShown:
      .byte 0
    TrackPointer:
      .byte 0
    CutCompleted:
      .byte 0
    WalkInCompleted:
      .byte 0

    CurrentWoodCutter: .byte $01

// Woodcutter dummy data
    .label TrackWalkCounter = 180
    TrackWalkX:
      .fill TrackWalkCounter, 0
    TrackWalkY:
      .fill TrackWalkCounter, 0
    TrackWalkXXbit:
      .fill TrackWalkCounter, 0
    DirectionX:
      .fill TrackWalkCounter, 0
    DirectionY:
      .fill TrackWalkCounter, 0

    TreeStartAddress: .word $456c
    TreeColorStartAddress: .word $016c

/*
    .label TreeStartAddress1 = $456c
    .label TreeColorStartAddress1 = $016c

// Second woodcutter track data
    .label TreeStartAddress2 = $450c
    .label TreeColorStartAddress2 = $010c

// Third woodcutter track data
    .label TreeStartAddress3 = $460c
    .label TreeColorStartAddress3 = $020c
*/
    DummyXBit:  .byte 0
  }

    * = * "Level1 SetWoodCutter2Track"
  SetWoodCutter2Track: {
      ldx #0

      lda Enemy2Manager.CurrentWoodCutter
      cmp #$03
      beq FixForWoodCutter3
      cmp #$02
      beq FixForWoodCutter2

    FixForWoodCutter1:
    !:
      lda TrackWalkX1, x
      sta Enemy2Manager.TrackWalkX, x
      lda TrackWalkY1, x
      sta Enemy2Manager.TrackWalkY, x
      lda DirectionX1, x
      sta Enemy2Manager.DirectionX, x
      lda DirectionY1, x
      sta Enemy2Manager.DirectionY, x
      inx
      cpx #TrackWalkCounter
      bne !-
      lda TreeStartAddress1
      sta Enemy2Manager.TreeStartAddress
      lda TreeStartAddress1 + 1
      sta Enemy2Manager.TreeStartAddress + 1
      jmp Done

    FixForWoodCutter2:
    !:
      lda TrackWalkX2, x
      sta Enemy2Manager.TrackWalkX, x
      lda TrackWalkY2, x
      sta Enemy2Manager.TrackWalkY, x
      lda DirectionX2, x
      sta Enemy2Manager.DirectionX, x
      lda DirectionY2, x
      sta Enemy2Manager.DirectionY, x
      inx
      cpx #TrackWalkCounter
      bne !-
      lda #TreeStartAddress2
      sta Enemy2Manager.TreeStartAddress
      lda #TreeStartAddress2 + 1
      sta Enemy2Manager.TreeStartAddress + 1
      jmp Done

    FixForWoodCutter3:
    !:
      lda TrackWalkX3, x
      sta Enemy2Manager.TrackWalkX, x
      lda TrackWalkY3, x
      sta Enemy2Manager.TrackWalkY, x
      lda DirectionX3, x
      sta Enemy2Manager.DirectionX, x
      lda DirectionY3, x
      sta Enemy2Manager.DirectionY, x
      inx
      cpx #TrackWalkCounter
      bne !-
      lda #TreeStartAddress3
      sta Enemy2Manager.TreeStartAddress
      lda #TreeStartAddress3 + 1
      sta Enemy2Manager.TreeStartAddress + 1

    Done:
      rts

// Global woodcutter label
    .label TrackWalkCounter = 180

// First woodcutter track data
    .label Walk1Offset = 66
    TrackWalkX1:
      .fill Walk1Offset, 0
      .fill TrackWalkCounter - Walk1Offset, i
    TrackWalkY1:
      .fill TrackWalkCounter, 79
    TrackWalkXXbit1:
      .fill TrackWalkCounter, 0
    DirectionX1:
      .fill TrackWalkCounter, 1
    DirectionY1:
      .fill TrackWalkCounter, 0
    TreeStartAddress1: .word $456c
    TreeColorStartAddress1: .word $016c

// Second woodcutter track data
    .label Walk2Offset = 135
    TrackWalkX2:
      .fill Walk2Offset, 0
      .fill TrackWalkCounter - Walk2Offset, i
    TrackWalkY2:
      .fill TrackWalkCounter, 136
    TrackWalkXXbit2:
      .fill TrackWalkCounter, 0
    DirectionX2:
      .fill TrackWalkCounter, 1
    DirectionY2:
      .fill TrackWalkCounter, 0
    .label TreeStartAddress2 = $450c
    .label TreeColorStartAddress2 = $010c

// Third woodcutter track data
    .label Walk3Offset = 0
    TrackWalkX3:
      .fill Walk3Offset, 0
      .fill TrackWalkCounter - Walk3Offset, i
    TrackWalkY3:
      .fill TrackWalkCounter, 167
    TrackWalkXXbit3:
      .fill TrackWalkCounter, 0
    DirectionX3:
      .fill TrackWalkCounter, 1
    DirectionY3:
      .fill TrackWalkCounter, 0
    .label TreeStartAddress3 = $460c
    .label TreeColorStartAddress3 = $020c
  }

  * = * "Level1 Enemy3Manager"
  Enemy3Manager: {
      lda WoodCutterFined
      beq CutCompletedCheck
      lda ComplaintShown
      bne GoToWalkOutFar

      jsr HandleWoodCutterFined
      inc ComplaintShown

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
      ldx TrackPointer
      cpx #TrackWalkCounter
      beq WalkInDone

      // Woodcutter didn't reached the tree, walk
      lda TrackWalkXXbit, x
      bne Call2_a
    Call1_a:
      CallSetPosition(TrackWalkX, TrackWalkY, 0, $08, $09);
      jmp Proceed_a
    Call2_a:
      CallSetPosition(TrackWalkX, TrackWalkY, $ff, $08, $09);

    Proceed_a:
      lda #<SPRITE_4
      sta WoodCutter.ScreenMemoryAddress + 1
      lda #>SPRITE_4
      sta WoodCutter.ScreenMemoryAddress

      CallUpdateWoodCutterFrame(DirectionX, DirectionY, WoodCutterFrame);

      inc TrackPointer

      jmp Done

      // Woodcutter is in position, stop walk
    WalkInDone:
      inc WalkInCompleted

      jmp Done

    ShowHatchet:
      // Woodcutter is in position, start to cut the tree
      lda HatchetShown
      bne HatchetStrike

      dec TrackPointer

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
// TODO(rafs): need to setup a new collision detector
      // SpriteCollided(0);
      // bne RangerWoodCutterMet

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
      RemoveTree($448d, $008d)

      jmp Done

    WalkOut:
    // Hide hatchet and move woodcutter out of screen
      ldx TrackPointer
      beq WalkOutDone

      lda TrackWalkXXbit, x
      bne Call2_b
    Call1_b:
      CallSetPosition(TrackWalkX, TrackWalkY, 0, $08, $09);
      jmp Proceed_b
    Call2_b:
      CallSetPosition(TrackWalkX, TrackWalkY, $ff, $08, $09);

    Proceed_b:
      lda #<SPRITE_4
      sta WoodCutter.ScreenMemoryAddress + 1
      lda #>SPRITE_4
      sta WoodCutter.ScreenMemoryAddress

      CallUpdateWoodCutterFrameReverse(DirectionX, DirectionY, WoodCutterFrame);

      dec TrackPointer

      jmp Done

    WalkOutDone:
      lda ComplaintHidden
      jsr HandleWoodCutterFinedOut
      inc ComplaintHidden

      EnableSprite(4, false)

      // Prepare next sprite track
      inc CurrentWoodCutter
      lda CurrentWoodCutter
      cmp #4
      bpl Done
      jsr SetWoodCutter3Track

      // Clear sprite
      lda AddEnemy.EnemyActive
      and #%11110111
      sta AddEnemy.EnemyActive

      lda #0
      sta HatchetShown
      sta TrackPointer
      sta CutCompleted
      sta WalkInCompleted

    Done:
      rts

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
    ComplaintHidden:
      .byte 0

    HatchetShown:
      .byte 0
    TrackPointer:
      .byte 0
    CutCompleted:
      .byte 0
    WalkInCompleted:
      .byte 0

    CurrentWoodCutter: .byte $01

    .label TrackWalkCounter = 210
    TrackWalkX:
      .fill TrackWalkCounter, 0
    TrackWalkY:
      .fill TrackWalkCounter, 0
    TrackWalkXXbit:
      .fill TrackWalkCounter, 0
    DirectionX:
      .fill TrackWalkCounter, 0
    DirectionY:
      .fill TrackWalkCounter, 0

    DummyXBit:  .byte 0
  }

    * = * "Level1 SetWoodCutter3Track"
  SetWoodCutter3Track: {
      ldx #0

      lda Enemy3Manager.CurrentWoodCutter
      cmp #$03
      beq FixForWoodCutter3
      cmp #$02
      beq FixForWoodCutter2

    FixForWoodCutter1:
    !:
      lda TrackWalkX1, x
      sta Enemy3Manager.TrackWalkX, x
      lda TrackWalkY1, x
      sta Enemy3Manager.TrackWalkY, x
      lda TrackWalkXXbit1, x
      sta Enemy3Manager.TrackWalkXXbit, x
      lda DirectionX1, x
      sta Enemy3Manager.DirectionX, x
      lda DirectionY1, x
      sta Enemy3Manager.DirectionY, x
      inx
      cpx #TrackWalkCounter
      bne !-
      jmp Done

    FixForWoodCutter2:
    !:
      lda TrackWalkX2, x
      sta Enemy3Manager.TrackWalkX, x
      lda TrackWalkY2, x
      sta Enemy3Manager.TrackWalkY, x
      lda TrackWalkXXbit2, x
      sta Enemy3Manager.TrackWalkXXbit, x
      lda DirectionX2, x
      sta Enemy3Manager.DirectionX, x
      lda DirectionY2, x
      sta Enemy3Manager.DirectionY, x
      inx
      cpx #TrackWalkCounter
      bne !-
      jmp Done

    FixForWoodCutter3:
    !:
      lda TrackWalkX3, x
      sta Enemy3Manager.TrackWalkX, x
      lda TrackWalkY3, x
      sta Enemy3Manager.TrackWalkY, x
      lda TrackWalkXXbit3, x
      sta Enemy3Manager.TrackWalkXXbit, x
      lda DirectionX3, x
      sta Enemy3Manager.DirectionX, x
      lda DirectionY3, x
      sta Enemy3Manager.DirectionY, x
      inx
      cpx #TrackWalkCounter
      bne !-

    Done:
      rts

// Global woodcutter label
    .label TrackWalkCounter = 210

// First woodcutter track data
    .label MaxX1WithXBit = 65
    .label Walk1Offset = 96
    TrackWalkX1:
      .fill Walk1Offset, 255
      .fill MaxX1WithXBit, MaxX1WithXBit - i
      .fill TrackWalkCounter - (Walk1Offset + MaxX1WithXBit), 255 - i
    TrackWalkY1:
      .fill TrackWalkCounter, 87
    TrackWalkXXbit1:
      .fill (Walk1Offset + MaxX1WithXBit), 255
      .fill TrackWalkCounter - (Walk1Offset + MaxX1WithXBit), 0
    DirectionX1:
      .fill TrackWalkCounter, $ff
    DirectionY1:
      .fill TrackWalkCounter, 0

// Second woodcutter track data
    .label MaxX2WithXBit = 65
    .label Walk2Offset = 180
    TrackWalkX2:
      .fill Walk2Offset, 255
      .fill MaxX2WithXBit, MaxX2WithXBit - i
    TrackWalkY2:
      .fill TrackWalkCounter, 145
    TrackWalkXXbit2:
      .fill TrackWalkCounter, 255
    DirectionX2:
      .fill TrackWalkCounter, $ff
    DirectionY2:
      .fill TrackWalkCounter, 0

// Third woodcutter track data
    .label MaxX3WithXBit = 65
    .label Walk3Offset = 154
    TrackWalkX3:
      .fill Walk3Offset, 255
      .fill MaxX3WithXBit, MaxX3WithXBit - i
    TrackWalkY3:
      .fill TrackWalkCounter, 199
    TrackWalkXXbit3:
      .fill TrackWalkCounter, 255
    DirectionX3:
      .fill TrackWalkCounter, $ff
    DirectionY3:
      .fill TrackWalkCounter, 0
  }

  * = * "Level1 TimedRoutine"
  TimedRoutine: {
      jsr TimedRoutine10th

      lda DelayCounter
      beq DelayTriggered        // when counter is zero stop decrementing
      dec DelayCounter      // decrement the counter

      jmp Exit

    DelayTriggered:
      inc $4410

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
      inc $4411

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
//  .label SPRITE_5     = $47fd

// Enemy sprite pointer
  .label SPRITE_2     = $47fa
  .label SPRITE_4     = $47fc
//  .label SPRITE_6     = $47fe

/*
  EnemyLeft:
    .byte 6

  EnemyNo6Alive:
    .byte 0
  EnemyNo5Alive:
    .byte 0
*/
}

#import "hud.asm"
#import "ranger.asm"
#import "woodcutter.asm"
#import "hatchet.asm"
#import "utils.asm"
