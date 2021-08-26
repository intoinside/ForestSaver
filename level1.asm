////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Manager for level 1.
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

      jsr HandleRangerMove
      jsr HandleEnemyMove

    CheckFirePressed:
      lda FirePressed
      bne LevelDone

      jmp JoystickMovement

    LevelDone:
      jsr Finalize
  }

  * = * "Level1 HandleRangerMove"
  HandleRangerMove: {
      lda Direction
      beq CheckDirectionY

      jsr Ranger.UpdateRangerFrame

// Handle horizontal move
      lda Direction
      cmp #$ff
      beq MoveToLeft

    MoveToRight:
      ldx SPRITES.X0          // Moving to right
      inx                     // Calculate new sprite x position
      beq ToggleExtraBit      // If zero then should toggle extra bit
      lda SPRITES.EXTRA_BIT   // If non zero, check extra bit
      and #$01
      beq UpdateSpriteXPos    // If extra bit not set, then update position
      cpx #LIMIT_RIGHT
      bcs CheckDirectionY     // If extra bit set and new position is over right
      jmp UpdateSpriteXPos    // border, no movement allowed

    ToggleExtraBit:
      lda SPRITES.EXTRA_BIT
      eor #$01
      sta SPRITES.EXTRA_BIT
    UpdateSpriteXPos:
      stx SPRITES.X0
      jmp CheckDirectionY

    MoveToLeft:
      lda SPRITES.EXTRA_BIT   // Moving to right, check extra bit
      and #$01
      bne TryToMoveLeft       // If extra bit is set, then move allowed
      ldx SPRITES.X0          // Check if position is on left border
      cpx #LIMIT_LEFT
      bcc CheckDirectionY     // If extra bit not set and x-position is not on
      dex                     // left border, then move allowed
      jmp UpdateSpriteXPos

    TryToMoveLeft:
      ldx SPRITES.X0          // Calculate new position
      dex
      cpx #$ff
      bne UpdateSpriteXPos    // If position is $ff then extra bit must be
      jmp ToggleExtraBit      // toggled

    CheckDirectionY:
      lda DirectionY
      beq Done

      jsr Ranger.UpdateRangerFrame

      ldy SPRITES.Y0          // Calculate new position

      lda DirectionY
      cmp #$ff
      beq MoveToUp

    MoveToDown:
      iny
      cpy #LIMIT_DOWN
      bcs Done
      sty SPRITES.Y0

      jmp Done

    MoveToUp:
      dey
      cpy #LIMIT_UP
      bcc Done
      sty SPRITES.Y0

    Done:
      rts
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

// Init ranger
// Self modification code: sprite pointer needs to be relocated when screen
// memory address changes. $47f8
      lda #$47
      sta Ranger.Init.LoadSprite1 + 2
      sta Ranger.UpdateRangerFrame.LoadSprite1 + 2
      sta Ranger.UpdateRangerFrame.LoadSprite2 + 2
      sta Ranger.UpdateRangerFrame.LoadSprite3 + 2
      sta Ranger.UpdateRangerFrame.LoadSprite4 + 2
      sta Ranger.UpdateRangerFrame.StoreSprite1 + 2
      sta Ranger.UpdateRangerFrame.StoreSprite2 + 2
      sta Ranger.UpdateRangerFrame.StoreSprite3 + 2
      sta Ranger.UpdateRangerFrame.StoreSprite4 + 2

      sta WoodCutter.Init.LoadSprite1 + 2
      sta WoodCutter.UpdateWoodCutterFrame.LoadSprite1 + 2
      sta WoodCutter.UpdateWoodCutterFrame.LoadSprite2 + 2
      sta WoodCutter.UpdateWoodCutterFrame.LoadSprite3 + 2
      sta WoodCutter.UpdateWoodCutterFrame.LoadSprite4 + 2
      sta WoodCutter.UpdateWoodCutterFrame.StoreSprite1 + 2
      sta WoodCutter.UpdateWoodCutterFrame.StoreSprite2 + 2
      sta WoodCutter.UpdateWoodCutterFrame.StoreSprite3 + 2
      sta WoodCutter.UpdateWoodCutterFrame.StoreSprite4 + 2

      jsr Ranger.Init
      jsr WoodCutter.Init

      lda #$07
      sta SPRITES.COLOR0
      lda #$08
      sta SPRITES.COLOR1
      lda #$02
      sta SPRITES.COLOR2

// Enable the first sprite
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

      /*
      cmp #$04
      beq EnemyNo5
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

      lda #%00000101
      sta VIC.SPRITE_ENABLE

      jmp Done

/*
    EnemyNo5:
      lda #$20
      sta SPRITES.X2
      lda #$45
      sta SPRITES.Y2

      lda SPRITES.EXTRA_BIT
      ora #%00000100
      sta SPRITES.EXTRA_BIT

      lda #%00000111
      sta VIC.SPRITE_ENABLE

      jmp Done
*/
    Done:
      rts
  }

  * = * "Level1 HandleEnemyMove"
  HandleEnemyMove: {
      lda EnemyNo6Alive
      beq IsEnemyNo5Alive
      jsr Enemy6Manager

    IsEnemyNo5Alive:
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

      // Passing X/Y direction to woodcutter frame update
      lda DirectionX, x
      sta WoodCutter.UpdateWoodCutterFrame.DirectionX
      lda DirectionY, x
      sta WoodCutter.UpdateWoodCutterFrame.DirectionY

      // Woodcutter didn't reached the tree, walk
      lda TrackWalkX, x
      sta SPRITES.X2

      lda TrackWalkY, x
      sta SPRITES.Y2

      // Walk-step completed, update woodcutter frame
      jsr WoodCutter.UpdateWoodCutterFrame
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

      lda #SPRITES.RANGER_STANDING + 20
      sta SPRITE_1

      lda #$08
      sta SPRITES.COLOR1

      lda VIC.SPRITE_ENABLE
      ora #%00000010
      sta VIC.SPRITE_ENABLE
      inc HatchetShown

      jmp Done

    HatchetStrike:
    // When a jsr is performed, stack is populated with return address, remember
      lda HatchetFrame
      pha
      lda #$f9
      pha
      lda #$47
      pha
      jsr Hatchet.UseTheHatchet
      pla
      sta HatchetFrame
      pla
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
      and #%11111101
      sta VIC.SPRITE_ENABLE

      jmp Done

    WalkOut:
    // Tree has been cut, hide hatchet and move woodcutter out of screen
      ldx TrackPointer
      beq WalkOutDone

      lda DirectionX, x                                 //3by, 4
      sec                                               //1by, 2
      sbc #2                                            //2by, 2
      sta WoodCutter.UpdateWoodCutterFrame.DirectionX   //3by, 4

      lda DirectionY, x                                 //3by, 4
      sta WoodCutter.UpdateWoodCutterFrame.DirectionY   //3by, 4

      lda TrackWalkX, x
      sta SPRITES.X2

      lda TrackWalkY, x
      sta SPRITES.Y2

      jsr WoodCutter.UpdateWoodCutterFrame
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
      .byte 1
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

  .label LIMIT_UP     = $32
  .label LIMIT_DOWN   = $e0
  .label LIMIT_LEFT   = $16
  .label LIMIT_RIGHT  = $46

  .label SPRITE_1     = $47f9

  EnemyLeft:
    .byte 6

  EnemyNo6Alive:
    .byte 0
}

#import "ranger.asm"
#import "woodcutter.asm"
#import "hatchet.asm"
#import "utils.asm"
