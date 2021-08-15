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

  .label X0                 = $d000
  .label Y0                 = $d001

  .label EXTRA_BIT          = $d010

  .label RANGER_STANDING    = $50

  .label ENEMY_STANDING     = $59

}

#import "main.asm"
