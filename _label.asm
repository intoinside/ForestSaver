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

CIA1: {
  .label PORT_A             = $dc00
  .label PORT_B             = $dc01
  .label PORT_A_DIRECTION   = $dc02
  .label PORT_B_DIRECTION   = $dc03
}

CIA2: {
  .label PORT_A             = $dd00
}

KEYB: {
  .label CURRENT_PRESSED    = $00cb
  .label BUFFER_LEN         = $0289
  .label REPEAT_SWITCH      = $028a
}

SPRITES: {
// Level x ranger
  .label RANGER_STANDING    = $50
  .label RANGER_FINING      = $59

// Level 1 woodcutter and hatchet
  .label ENEMY_STANDING     = $5a
  .label HATCHET            = $63
  .label HATCHET_REV        = $65

// Level 2 tank, pipe
  .label TANK_BODY_LE       = $67
  .label TANK_TAIL_LE       = $68
  .label PIPE_1             = $69
  .label PIPE_2             = $6a
  .label PIPE_3             = $6b
  .label PIPE_4             = $6c
  .label TANK_TAIL_RI       = $6d
  .label TANK_BODY_RI       = $6e
  .label PIPE_1_R           = $6f
  .label PIPE_2_R           = $70
  .label PIPE_3_R           = $71
  .label PIPE_4_R           = $72

// Level 3
  .label ARSIONIST_STANDING    = $73
  .label ARSIONIST_WALKING     = $74
  .label ARSIONIST_STANDING_R  = $75
  .label ARSIONIST_WALKING_R   = $76
  .label ARSIONIST_FRONT    = $77
  .label FLAME_1            = $78
  .label FLAME_2            = $79
  .label FLAME_3            = $7a

  // These label will be modified with self-modification code
  .label SPRITE_0           = $bef8
}
