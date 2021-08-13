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

#import "utils.asm"
#import "joystick.asm"
#import "allimport.asm"
#import "main.asm"

Level1: {

// Manager of level 1
  * = * "Level1 Manager"
  Manager: {
      jsr Init
      jsr AddColorToMap
      jsr StupidWaitRoutine

    JoystickMovement:
      jsr WaitRoutine
      jsr GetJoystickMove

      lda Direction
      beq CheckDirectionY

      jsr UpdateRangerFrame

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

      jsr UpdateRangerFrame

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
      beq JoystickMovement

      jsr Finalize

      rts
  }

  * = * "Level1 UpdateRangerFrame"
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
      ldx #RANGER_STANDING + 5
      lda SPRITE_0
      cmp #RANGER_STANDING + 6
      beq RightUpdate
      inx

    RightUpdate:
      // If right frame edit occours, no other frame switch will be performed
      stx SPRITE_0
      jmp NoMove

    Left:
      ldx #RANGER_STANDING + 7
      lda SPRITE_0
      cmp #RANGER_STANDING + 8
      beq LeftUpdate
      inx

    LeftUpdate:
      // If left frame edit occours, no other frame switch will be performed
      stx SPRITE_0
      jmp NoMove

    CheckVerticalMove:
      lda DirectionY
      beq NoMove
      cmp #$ff
      beq Up

    Down:
      ldx #RANGER_STANDING + 1
      lda SPRITE_0
      cmp #RANGER_STANDING + 2
      beq UpUpdate
      inx

    DownUpdate:
      stx SPRITE_0
      jmp NoMove

    Up:
      ldx #RANGER_STANDING + 3
      lda SPRITE_0
      cmp #RANGER_STANDING + 4
      beq UpUpdate
      inx

    UpUpdate:
      stx SPRITE_0

    NoMove:
      rts

    RangerFrame:
      .byte $ff
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

// Init ranger
      lda #RANGER_STANDING
      sta SPRITE_0

      lda #$50
      sta SPRITES.X0
      lda #$40
      sta SPRITES.Y0

      lda #$0a
      sta SPRITES.EXTRACOLOR1

      lda #$00
      sta SPRITES.EXTRACOLOR2

      lda #$07
      sta SPRITES.COLOR0

// Enable the first sprite (just for test)
      lda #$01
      sta VIC.SPRITE_MULTICOLOR
      sta VIC.SPRITE_ENABLE

      rts
  }

  Finalize: {
      lda #$00
      sta VIC.SPRITE_ENABLE

      rts
  }

  AddColorToMap: {
// TODO(intoinside): don't like this macro, maybe changed with a function
// (there's no need to be fast but there is a need to have smaller code)
    SetColorToChars($4400)

    rts
  }

  .label SPRITE_0     = $47f8
  .label LIMIT_UP     = $32
  .label LIMIT_DOWN   = $e7
  .label LIMIT_LEFT   = $16
  .label LIMIT_RIGHT  = $46

  .label RANGER_STANDING  = $50

}
