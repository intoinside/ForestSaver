////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Label declaration
//
////////////////////////////////////////////////////////////////////////////////

#importonce

VIC: {
  .label BORDER_COLOR       = $d020
  .label BACKGROUND_COLOR   = $d021

  .label EXTRA_BACKGROUND1  = $d022
  .label EXTRA_BACKGROUND2  = $d023

  .label SCREEN_CONTROL_1   = $d011
  .label SCREEN_CONTROL_2   = $d016
  .label MEMORY_SETUP       = $d018

  .label SPRITE_ENABLE      = $d015
  .label SPRITE_MULTICOLOR  = $d01c
}

CIA: {
  .label PORT_A             = $dd00
}

SPRITES: {
  .label EXTRACOLOR1        = $d025
  .label EXTRACOLOR2        = $d026
  .label COLOR0             = $d027
  .label COLOR1             = $d028
  .label COLOR2             = $d029
  .label COLOR3             = $d02a
  .label COLOR4             = $d02b
  .label COLOR5             = $d02c
  .label COLOR6             = $d02d
  .label COLOR7             = $d02e

  .label X0                 = $d000
  .label Y0                 = $d001
  .label X1                 = $d002
  .label Y1                 = $d003
  .label X2                 = $d004
  .label Y2                 = $d005
  .label X3                 = $d006
  .label Y3                 = $d007
  .label X4                 = $d008
  .label Y4                 = $d009
  .label X5                 = $d00a
  .label Y5                 = $d00b
  .label X6                 = $d00c
  .label Y6                 = $d00d
  .label X7                 = $d00e
  .label Y7                 = $d00f

  .label EXTRA_BIT          = $d010

  .label PRIORITY           = $d01b

  .label COLLISION_TO_SPRITE = $d01e
  .label COLLISION_TO_BKG   = $d01f

// Level x ranger
  .label RANGER_STANDING    = $50

// Level 1 woodcutter and hatchet
  .label ENEMY_STANDING     = $59
  .label HATCHET            = $62
  .label HATCHET_REV        = $64

// Level 2 tank, pipe
  .label TANK_BODY_LE       = $66
  .label TANK_TAIL_LE       = $67
  .label TANK_TAIL_RI       = $68
  .label TANK_BODY_RI       = $69
  .label PIPE_1             = $6a
  .label PIPE_2             = $6b
  .label PIPE_3             = $6c
  .label PIPE_4             = $6d

// Level 3
// TBD

  // These label will be modified with self-modification code
  .label SPRITE_0           = $bef8
}

#import "main.asm"
