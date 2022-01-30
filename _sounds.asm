////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Sound effects
//
////////////////////////////////////////////////////////////////////////////////

#importonce

.filenamespace Sfx

SID: {
  .label VOICE1_FREQ_1          = $d400
  .label VOICE1_FREQ_2          = $d401
  .label VOICE1_CTRL            = $d404
  .label VOICE1_ATTACK_DECAY    = $d405
  .label VOICE1_SUSTAIN_RELEASE = $d406

  .label VOICE2_FREQ_1          = $d407
  .label VOICE2_FREQ_2          = $d408
  .label VOICE2_CTRL            = $d40b
  .label VOICE2_ATTACK_DECAY    = $d40c
  .label VOICE2_SUSTAIN_RELEASE = $d40d

  .label VOLUME_FILTER_MODES    = $d418
}

// Voice 1
* = * "Sfx Walkstep"
Walkstep: {
      lda #%00011001
      sta SID.VOLUME_FILTER_MODES
      lda #%00000000        
      sta SID.VOICE1_FREQ_1
      lda #%00000010        
      sta SID.VOICE1_FREQ_2
      lda #%00000010        
      sta SID.VOICE1_ATTACK_DECAY
      lda #%00000010
      sta SID.VOICE1_SUSTAIN_RELEASE
      lda #%00000000        
      sta SID.VOICE1_CTRL
      lda #%10000001
      sta SID.VOICE1_CTRL

      rts
}

// Voice 2
* = * "Sfx TreeFall"
TreeFall: {
      lda #%00011011
      sta SID.VOLUME_FILTER_MODES
      lda #%10100000        
      sta SID.VOICE2_FREQ_1
      lda #240
      sta SID.VOICE2_FREQ_2
      lda #%10011010        
      sta SID.VOICE2_ATTACK_DECAY
      lda #%00000111
      sta SID.VOICE2_SUSTAIN_RELEASE
      lda #%00000000        
      sta SID.VOICE2_CTRL
      lda #%10000001
      sta SID.VOICE2_CTRL

      rts
}

// Voice 1
* = * "Sfx HatchetStrike"
HatchetStrike: {
      lda #%00011001
      sta SID.VOLUME_FILTER_MODES
      lda #%00000000        
      sta SID.VOICE1_FREQ_1
      lda #%00001000        
      sta SID.VOICE1_FREQ_2
      lda #%00000100        
      sta SID.VOICE1_ATTACK_DECAY
      lda #%00000110
      sta SID.VOICE1_SUSTAIN_RELEASE
      lda #%00000000        
      sta SID.VOICE1_CTRL
      lda #%10000001
      sta SID.VOICE1_CTRL

      rts
}

// Voice 1
* = * "Sfx PointConversion"
PointConversion: {
      lda #%00000111
      sta SID.VOLUME_FILTER_MODES
      lda #%00000000        
      sta SID.VOICE1_FREQ_1
      lda #%00001000      
      sta SID.VOICE1_FREQ_2
      lda #%00100100  
      sta SID.VOICE1_ATTACK_DECAY
      lda #%00000110
      sta SID.VOICE1_SUSTAIN_RELEASE
      lda #%00000000        
      sta SID.VOICE1_CTRL
      lda #%00010001
      sta SID.VOICE1_CTRL

      rts
}
