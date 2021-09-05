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

  .label EXTRA_BIT          = $d010

  .label COLLISION_REGISTER = $d01e

  .label RANGER_STANDING    = $50

  .label ENEMY_STANDING     = $59

  .label HATCHET            = $64

  // These label will be modified with self-modification code
  .label SPRITE_0           = $bef8
  .label SPRITE_1           = $bef9
  .label SPRITE_2           = $befa
  .label SPRITE_3           = $befb
  .label SPRITE_4           = $befc
  .label SPRITE_5           = $befd
  .label SPRITE_6           = $befe
}

#import "main.asm"
