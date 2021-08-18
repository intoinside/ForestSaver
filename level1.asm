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
      beq CheckFirePressed

      jsr Ranger.UpdateRangerFrame

      ldy SPRITES.Y0          // Calculate new position

      lda DirectionY
      cmp #$ff
      beq MoveToUp

    MoveToDown:
      iny
      cpy #LIMIT_DOWN
      bcs CheckFirePressed
      sty SPRITES.Y0

      jmp CheckFirePressed

    MoveToUp:
      dey
      cpy #LIMIT_UP
      bcc CheckFirePressed
      sty SPRITES.Y0

    CheckFirePressed:
      lda FirePressed
      bne LevelDone

    JoystickMovementHelper:
      jmp JoystickMovement

    LevelDone:
      jsr Finalize

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

      jsr Ranger.Init

      lda #$50
      sta SPRITES.X0
      lda #$40
      sta SPRITES.Y0

      lda #SPRITES.ENEMY_STANDING
      sta SPRITES.SPRITE_1
      sta SPRITES.SPRITE_2

      lda #$07
      sta SPRITES.COLOR0
      lda #$02
      sta SPRITES.COLOR1
      sta SPRITES.COLOR2

// Enable the first sprite (just for test)
      lda #%00000111
      sta VIC.SPRITE_MULTICOLOR

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
      sta SPRITES.X1
      lda #$45
      sta SPRITES.Y1

      inc EnemyNo6Alive

      lda #%00000011
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

  * = * "Level1 EnemyManager"
  EnemyManager: {
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
      ldx TrackPointer
      cpx TrackWalkCounter
      beq Done
      lda TrackWalkX, x
      sta SPRITES.X1

      lda TrackWalkY, x
      sta SPRITES.Y1

      inc TrackPointer

    Done:
      rts

    TrackPointer:
      .byte 0

    TrackWalkCounter:
      .byte 11

    TrackWalkX:
      .byte 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50

    TrackWalkY:
      .byte 90, 90, 91, 91, 92, 92, 93, 93, 94, 94, 95

    DirectionX:
      .byte 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01
    DirectionY:
      .byte 00, 00, 01, 00, 01, 00, 01, 00, 01, 00, 01
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

      jsr EnemyManager

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

  EnemyLeft:
    .byte 6

  EnemyNo6Alive:
    .byte 0
}

#import "ranger.asm"
#import "utils.asm"
