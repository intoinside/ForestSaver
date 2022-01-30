////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Ranger sprite handler
//
////////////////////////////////////////////////////////////////////////////////

#importonce

.filenamespace Ranger

* = * "Ranger Init"
Init: {
    clc
    lda ScreenMemoryAddress
    adc #$03
    sta ScreenMemoryAddress

// Self modify code to use current screen memotry address, update hibyte
    sta Init.LoadSprite1 + 2
    sta UpdateRangerFrame.LoadSprite1 + 2
    sta UpdateRangerFrame.LoadSprite2 + 2
    sta UpdateRangerFrame.LoadSprite3 + 2
    sta UpdateRangerFrame.LoadSprite4 + 2
    sta UpdateRangerFrame.StoreSprite1 + 2
    sta UpdateRangerFrame.StoreSprite2 + 2
    sta UpdateRangerFrame.StoreSprite3 + 2
    sta UpdateRangerFrame.StoreSprite4 + 2
    sta FiningInAction.FiningSprite + 2

// No need to update lobyte because ranger is always sprite 0
    lda #SPRITES.RANGER_STANDING
  LoadSprite1:
    sta SPRITES.SPRITE_0

    lda c64lib.SPRITE_0_X
    sta HandleRangerMove.OLDX0
    lda c64lib.SPRITE_0_Y
    sta HandleRangerMove.OLDY0

    lda c64lib.SPRITE_MSB_X
    and #%00000001
    sta HandleRangerMove.OLDXBIT

    rts
}

* = * "Ranger HandleRangerMove"
HandleRangerMove: {
    jsr GetOnlyFirePress
    lda FirePressed
    cmp #$ff
    bne !+
    lda #$00
    sta IsFining

  !:
    lda IsFining
    beq !+
    jsr FiningInAction
    jmp Done

  !:
    jsr BackgroundCollision
    lda BackgroundCollision.Collision
    beq NoCollision

    lda FirePressed
    cmp #$ff
    bne !+

    jsr Hud.IsScoreBiggerThanZero
    lda Hud.IsScoreBiggerThanZero.BiggerThanZero
    beq !+
    SubPoints(0, 0, 0, 1)
    jmp NoCollision

  !:
    // If there is collision, revert ranger position
    lda OLDX0
    sta c64lib.SPRITE_0_X
    lda c64lib.SPRITE_MSB_X
    ora OLDXBIT
    sta c64lib.SPRITE_MSB_X
    lda OLDY0
    sta c64lib.SPRITE_0_Y

  NoCollision:
    // If there is no collision, save position
    lda c64lib.SPRITE_0_X
    sta OLDX0
    lda c64lib.SPRITE_MSB_X
    and #%00000001
    sta OLDXBIT
    lda c64lib.SPRITE_0_Y
    sta OLDY0

    lda Direction
    beq CheckDirectionY

// Handle horizontal move
    lda Direction
    cmp #$ff
    beq MoveToLeft

  MoveToRight:
    ldx c64lib.SPRITE_0_X          // Moving to right
    inx                     // Calculate new sprite x position
    beq ToggleExtraBit      // If zero then should toggle extra bit
    lda c64lib.SPRITE_MSB_X   // If non zero, check extra bit
    and #$01
    beq UpdateSpriteXPos    // If extra bit not set, then update position
    cpx #LIMIT_RIGHT
    bcs CheckDirectionY     // If extra bit set and new position is over right
    jmp UpdateSpriteXPos    // border, no movement allowed

  ToggleExtraBit:
    lda c64lib.SPRITE_MSB_X
    eor #$01
    sta c64lib.SPRITE_MSB_X
  UpdateSpriteXPos:
    stx c64lib.SPRITE_0_X
    jmp CheckDirectionY

  MoveToLeft:
    lda c64lib.SPRITE_MSB_X   // Moving to right, check extra bit
    and #$01
    bne TryToMoveLeft         // If extra bit is set, then move allowed
    ldx c64lib.SPRITE_0_X     // Check if position is on left border
    cpx #LIMIT_LEFT
    bcc CheckDirectionY       // If extra bit not set and x-position is not on
    dex                       // left border, then move allowed
    jmp UpdateSpriteXPos

  TryToMoveLeft:
    ldx c64lib.SPRITE_0_X     // Calculate new position
    dex
    cpx #$ff
    bne UpdateSpriteXPos      // If position is $ff then extra bit must be
    jmp ToggleExtraBit        // toggled

  CheckDirectionY:
    lda DirectionY
    beq UpdateRangerFrame

    ldy c64lib.SPRITE_0_Y          // Calculate new position

    lda DirectionY
    cmp #$ff
    beq MoveToUp

  MoveToDown:
    iny
    cpy #LIMIT_DOWN
    bcs UpdateFrame
    sty c64lib.SPRITE_0_Y

    jmp UpdateFrame

  MoveToUp:
    dey
    cpy #LIMIT_UP
    bcc UpdateFrame
    sty c64lib.SPRITE_0_Y

  UpdateFrame:
    jsr UpdateRangerFrame

  Done:
    rts

  OLDX0:    .byte $00
  OLDXBIT:  .byte $00
  OLDY0:    .byte $00
}

* = * "Ranger FiningInAction"
FiningInAction: {
    dec IsFining
    beq StopFining

    lda #SPRITES.RANGER_FINING
    jmp FiningSprite

  StopFining:
    lda #SPRITES.RANGER_STANDING

  FiningSprite:
    sta SPRITES.SPRITE_0

    rts
}

ConvertDismissalToPoint: {
    lda Hud.ReduceDismissalCounter.DismissalCompleted
    bne Done

    ldx #15
  !:
    jsr WaitRoutine
    dex
    bne !-

    jsr Hud.ReduceDismissalCounter
    jsr Sfx.PointConversion
    AddPoints(0, 0, 5, 0)

  Done:
    rts
}

* = * "Ranger UpdateRangerFrame"
UpdateRangerFrame: {
    inc RangerFrame
    lda RangerFrame
    lsr
    lsr
    lsr
    lsr
    bcc NoMove

    lda #$00
    sta RangerFrame

    lda Direction
    beq CheckVerticalMove
    cmp #$ff
    beq Left

  Right:
    ldx #SPRITES.RANGER_STANDING + 5
  LoadSprite1:
    lda SPRITES.SPRITE_0
    cmp #SPRITES.RANGER_STANDING + 6
    beq RightUpdate
    inx

    jsr Sfx.Walkstep

  RightUpdate:
    // If right frame edit occours, no other frame switch will be performed
  StoreSprite1:
    stx SPRITES.SPRITE_0
    jmp NoMove

  Left:
    ldx #SPRITES.RANGER_STANDING + 7
  LoadSprite2:
    lda SPRITES.SPRITE_0
    cmp #SPRITES.RANGER_STANDING + 8
    beq LeftUpdate
    inx

    jsr Sfx.Walkstep

  LeftUpdate:
    // If left frame edit occours, no other frame switch will be performed
  StoreSprite2:
    stx SPRITES.SPRITE_0
    jmp NoMove

  CheckVerticalMove:
    lda DirectionY
    beq NoMove
    cmp #$ff
    beq Up

  Down:
    ldx #SPRITES.RANGER_STANDING + 1
  LoadSprite3:
    lda SPRITES.SPRITE_0
    cmp #SPRITES.RANGER_STANDING + 2
    beq UpUpdate
    inx

    jsr Sfx.Walkstep

  DownUpdate:
  StoreSprite3:
    stx SPRITES.SPRITE_0
    jmp NoMove

  Up:
    ldx #SPRITES.RANGER_STANDING + 3
  LoadSprite4:
    lda SPRITES.SPRITE_0
    cmp #SPRITES.RANGER_STANDING + 4
    beq UpUpdate
    inx

    jsr Sfx.Walkstep

  UpUpdate:
  StoreSprite4:
    stx SPRITES.SPRITE_0

  NoMove:
    rts

  RangerFrame:
    .byte $ff
}

// If > 0 indicates that fining is in progress (remaining time)
// If == 0 indicates fining is done or never happened
IsFining: .byte $00

.label LIMIT_UP     = $32
.label LIMIT_DOWN   = $e0
.label LIMIT_LEFT   = $16
.label LIMIT_RIGHT  = $46

ScreenMemoryAddress: .byte $be

#import "_label.asm"
#import "_joystick.asm"
#import "_hud.asm"
#import "_utils.asm"
#import "_sounds.asm"

#import "chipset/lib/vic2.asm"
