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
// * Hatchet 3    Sprite 5
// * Woodcutter 3 Sprite 6
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
      sta SPRITE_6

// Ranger coordinates
      lda #$50
      sta SPRITES.X0
      lda #$40
      sta SPRITES.Y0

// Ranger module init
      lda #$00
      sta Ranger.ScreenMemoryAddress + 1
      lda #$47
      sta Ranger.ScreenMemoryAddress
      jsr Ranger.Init

      lda #$00
      sta WoodCutter.ScreenMemoryAddress + 1
      lda #$47
      sta WoodCutter.ScreenMemoryAddress
      jsr WoodCutter.Init

// Sprite color setting
      lda #$07
      sta SPRITES.COLOR0
      lda #$08
      sta SPRITES.COLOR1
      sta SPRITES.COLOR3
      sta SPRITES.COLOR5
      lda #$02
      sta SPRITES.COLOR2
      sta SPRITES.COLOR4
      sta SPRITES.COLOR6

// Enable the first sprite (ranger)
      lda #%00000001
      sta VIC.SPRITE_ENABLE

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
      dec EnemyLeft
      lda EnemyLeft
      cmp #$05
      beq EnemyNo6

      cmp #$04
      beq EnemyNo5
      /*
      cmp #$03
      beq EnemyNo4
      cmp #$02
      beq EnemyNo3
      cmp #$01
      beq EnemyNo2
      cmp #$00
      beq EnemyNo1
      */
      jmp Done

    EnemyNo6:
      lda #$0
      sta SPRITES.X2
      lda #$45
      sta SPRITES.Y2

      inc EnemyNo6Alive

      lda VIC.SPRITE_ENABLE
      ora #%00000100
      sta VIC.SPRITE_ENABLE

      jmp Done

    EnemyNo5:
      lda #$10
      sta SPRITES.X4
      lda #$cf
      sta SPRITES.Y4
      lda SPRITES.EXTRA_BIT
      ora #%00000000
      sta SPRITES.EXTRA_BIT

      inc EnemyNo5Alive

      lda VIC.SPRITE_ENABLE
      ora #%00010000
      sta VIC.SPRITE_ENABLE

      jmp Done

    EnemyNo4:
    EnemyNo3:
    EnemyNo2:
    EnemyNo1:

    Done:
      rts
  }

  * = * "Level1 HandleEnemyMove"
  HandleEnemyMove: {
      lda EnemyNo6Alive
      beq IsEnemyNo5Alive
      jsr Enemy6Manager

    IsEnemyNo5Alive:
      lda EnemyNo5Alive
      beq IsEnemyNo4Alive
      jsr Enemy5Manager

    IsEnemyNo4Alive:
    IsEnemyNo3Alive:
    IsEnemyNo2Alive:
    IsEnemyNo1Alive:

    Done:
      rts
  }

  * = * "Level1 Enemy6Manager"
  Enemy6Manager: {
      lda CutCompleted
      bne GoToWalkOutFar
      jmp CutNotCompleted

    GoToWalkOutFar:
      jmp WalkOut

    CutNotCompleted:
      lda WalkInCompleted
      bne ShowHatchet

    WalkIn:
      // Woodcutter walks in
      ldx TrackPointer
      cpx #TrackWalkCounter
      beq WalkInDone

      // Woodcutter didn't reached the tree, walk
      lda TrackWalkX, x
      sta WoodCutter.SetPosition.NewX
      lda TrackWalkY, x
      sta WoodCutter.SetPosition.NewY
      lda #$04
      sta WoodCutter.SetPosition.SpriteXLow
      lda #$05
      sta WoodCutter.SetPosition.SpriteYLow
      jsr WoodCutter.SetPosition

      lda #<SPRITE_2
      sta WoodCutter.ScreenMemoryAddress + 1
      lda #>SPRITE_2
      sta WoodCutter.ScreenMemoryAddress

      lda DirectionX, x
      sta WoodCutter.UpdateWoodCutterFrame.DirectionX
      lda DirectionY, x
      sta WoodCutter.UpdateWoodCutterFrame.DirectionY

      lda WoodCutterFrame
      sta WoodCutter.UpdateWoodCutterFrame.WoodCutterFrame

      jsr WoodCutter.UpdateWoodCutterFrame

      lda WoodCutter.UpdateWoodCutterFrame.WoodCutterFrame
      sta WoodCutterFrame

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

      lda #SPRITES.HATCHET
      sta SPRITE_1

      lda VIC.SPRITE_ENABLE
      ora #%00000010
      sta VIC.SPRITE_ENABLE
      inc HatchetShown

      jmp Done

    HatchetStrike:
    // When a jsr is performed, stack is populated with return address, remember
      lda #<SPRITE_1
      sta Hatchet.ScreenMemoryAddress + 1
      lda #>SPRITE_1
      sta Hatchet.ScreenMemoryAddress

      lda HatchetFrame
      sta Hatchet.UseTheHatchet.HatchetFrame

      jsr Hatchet.UseTheHatchet

      lda Hatchet.UseTheHatchet.HatchetFrame
      sta HatchetFrame

      lda Hatchet.UseTheHatchet.StrokeHappened
      bne StrokeHappened
      jmp Done

    StrokeHappened:
      dec HatchetStrokes
      lda HatchetStrokes
      bne DoneFar
      inc CutCompleted
      jmp HideHatchet

    DoneFar:
      jmp Done
    HideHatchet:
      lda #$00
      sta HatchetShown
      lda #HatchetStrokesMax
      sta HatchetStrokes
      lda VIC.SPRITE_ENABLE
      and #%11111101
      sta VIC.SPRITE_ENABLE

      jmp Done

    WalkOut:
    // Tree has been cut, remove tree
      RemoveTree($456c, $016c);

    // Hide hatchet and move woodcutter out of screen
      ldx TrackPointer
      beq WalkOutDone

      lda TrackWalkX, x
      sta WoodCutter.SetPosition.NewX
      lda TrackWalkY, x
      sta WoodCutter.SetPosition.NewY
      lda #$04
      sta WoodCutter.SetPosition.SpriteXLow
      lda #$05
      sta WoodCutter.SetPosition.SpriteYLow
      jsr WoodCutter.SetPosition

      lda #<SPRITE_2
      sta WoodCutter.ScreenMemoryAddress + 1
      lda #>SPRITE_2
      sta WoodCutter.ScreenMemoryAddress

      lda DirectionX, x
      sec                                               //1by, 2
      sbc #2                                            //2by, 2
      sta WoodCutter.UpdateWoodCutterFrame.DirectionX
      lda DirectionY, x
      sta WoodCutter.UpdateWoodCutterFrame.DirectionY

      lda WoodCutterFrame
      sta WoodCutter.UpdateWoodCutterFrame.WoodCutterFrame

      jsr WoodCutter.UpdateWoodCutterFrame

      lda WoodCutter.UpdateWoodCutterFrame.WoodCutterFrame
      sta WoodCutterFrame

      dec TrackPointer

      jmp Done

    WalkOutDone:
      lda VIC.SPRITE_ENABLE
      and #%11111011
      sta VIC.SPRITE_ENABLE

    Done:
      rts

    .label HatchetStrokesMax = $0f
    HatchetStrokes:
      .byte HatchetStrokesMax

    HatchetFrame:
      .byte $ff

    WoodCutterFrame:
      .byte $00

    HatchetShown:
      .byte 0
    TrackPointer:
      .byte 0
    CutCompleted:
      .byte 0
    WalkInCompleted:
      .byte 0

    .label TrackWalkCounter = 41

    TrackWalkX:
      .fill TrackWalkCounter, 6+i
    TrackWalkY:
      .fill TrackWalkCounter, 136

    DirectionX:
      .fill TrackWalkCounter, 1
    DirectionY:
      .fill TrackWalkCounter, 0
  }

    * = * "Level1 Enemy5Manager"
  Enemy5Manager: {
      lda CutCompleted
      bne GoToWalkOutFar
      jmp CutNotCompleted

    GoToWalkOutFar:
      jmp WalkOut

    CutNotCompleted:
      lda WalkInCompleted
      bne ShowHatchet

    WalkIn:
      // Woodcutter walks in
      ldx TrackPointer
      cpx #TrackWalkCounter
      beq WalkInDone

      // Woodcutter didn't reached the tree, walk
      lda TrackWalkX, x
      sta WoodCutter.SetPosition.NewX
      lda TrackWalkY, x
      sta WoodCutter.SetPosition.NewY
      lda #$08
      sta WoodCutter.SetPosition.SpriteXLow
      lda #$09
      sta WoodCutter.SetPosition.SpriteYLow
      jsr WoodCutter.SetPosition

      lda #<SPRITE_4
      sta WoodCutter.ScreenMemoryAddress + 1
      lda #>SPRITE_4
      sta WoodCutter.ScreenMemoryAddress

      lda DirectionX, x
      sta WoodCutter.UpdateWoodCutterFrame.DirectionX
      lda DirectionY, x
      sta WoodCutter.UpdateWoodCutterFrame.DirectionY

      lda WoodCutterFrame
      sta WoodCutter.UpdateWoodCutterFrame.WoodCutterFrame

      jsr WoodCutter.UpdateWoodCutterFrame

      lda WoodCutter.UpdateWoodCutterFrame.WoodCutterFrame
      sta WoodCutterFrame

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

      lda #SPRITES.HATCHET
      sta SPRITE_3

      lda VIC.SPRITE_ENABLE
      ora #%00001000
      sta VIC.SPRITE_ENABLE
      inc HatchetShown

      jmp Done

    HatchetStrike:
    // When a jsr is performed, stack is populated with return address, remember
      lda #<SPRITE_3
      sta Hatchet.ScreenMemoryAddress + 1
      lda #>SPRITE_3
      sta Hatchet.ScreenMemoryAddress

      lda HatchetFrame
      sta Hatchet.UseTheHatchet.HatchetFrame

      jsr Hatchet.UseTheHatchet

      lda Hatchet.UseTheHatchet.HatchetFrame
      sta HatchetFrame

      lda Hatchet.UseTheHatchet.StrokeHappened
      bne StrokeHappened
      jmp Done

    StrokeHappened:
      dec HatchetStrokes
      lda HatchetStrokes
      bne Done
      inc CutCompleted

    HideHatchet:
      lda #$00
      sta HatchetShown
      lda #HatchetStrokesMax
      sta HatchetStrokes
      lda VIC.SPRITE_ENABLE
      and #%11110111
      sta VIC.SPRITE_ENABLE

      jmp Done

    WalkOut:
    // Tree has been cut, hide hatchet and move woodcutter out of screen
      ldx TrackPointer
      beq WalkOutDone

      lda TrackWalkX, x
      sta WoodCutter.SetPosition.NewX
      lda TrackWalkY, x
      sta WoodCutter.SetPosition.NewY
      lda #$08
      sta WoodCutter.SetPosition.SpriteXLow
      lda #$09
      sta WoodCutter.SetPosition.SpriteYLow
      jsr WoodCutter.SetPosition

      lda #<SPRITE_4
      sta WoodCutter.ScreenMemoryAddress + 1
      lda #>SPRITE_4
      sta WoodCutter.ScreenMemoryAddress

// RIVEDERE PATH DEL TAGLIALEGNA
      lda DirectionX, x
      sec                                               //1by, 2
      sbc #2                                            //2by, 2
      sta WoodCutter.UpdateWoodCutterFrame.DirectionX
      lda DirectionY, x
      sta WoodCutter.UpdateWoodCutterFrame.DirectionY

      lda WoodCutterFrame
      sta WoodCutter.UpdateWoodCutterFrame.WoodCutterFrame

      jsr WoodCutter.UpdateWoodCutterFrame

      lda WoodCutter.UpdateWoodCutterFrame.WoodCutterFrame
      sta WoodCutterFrame

      dec TrackPointer

      jmp Done

    WalkOutDone:
      lda VIC.SPRITE_ENABLE
      and #%11101111
      sta VIC.SPRITE_ENABLE

    Done:
      rts

    .label HatchetStrokesMax = $0f
    HatchetStrokes:
      .byte HatchetStrokesMax

    HatchetFrame:
      .byte $ff

    WoodCutterFrame:
      .byte $00

    HatchetShown:
      .byte 0
    TrackPointer:
      .byte 0
    CutCompleted:
      .byte 0
    WalkInCompleted:
      .byte 0

    .label TrackWalkCounter = 41

    TrackWalkX:
      .fill TrackWalkCounter, $ff-i
    TrackWalkY:
      .fill TrackWalkCounter, 200

    DirectionX:
      .fill TrackWalkCounter, $ff
    DirectionY:
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

      lda WaitingForEnemy
      beq NotWaiting

    Waiting:
      dec WaitingForEnemy
      jsr AddEnemy

      jmp Exit

    NotWaiting:

    Exit:
      rts

    DelayCounter:
      .byte 50                  // Counter storage
    DelayRequested:
      .byte 50                  // 1 second delay

    WaitingForEnemy:
      .byte 2
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
// TODO(intoinside): don't like this macro, maybe changed with a function
// (there's no need to be fast but there is a need to have smaller code)
    SetColorToChars($4400)

    rts
  }

// Hatchet sprite pointer
  .label SPRITE_1     = $47f9
  .label SPRITE_3     = $47fb
  .label SPRITE_5     = $47fd

// Enemy sprite pointer
  .label SPRITE_2     = $47fa
  .label SPRITE_4     = $47fc
  .label SPRITE_6     = $47fe

  EnemyLeft:
    .byte 6

  EnemyNo6Alive:
    .byte 0
  EnemyNo5Alive:
    .byte 0
}

#import "ranger.asm"
#import "woodcutter.asm"
#import "hatchet.asm"
#import "utils.asm"
