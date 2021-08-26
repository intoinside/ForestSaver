////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Hatchet sprite handler
//
////////////////////////////////////////////////////////////////////////////////

#importonce

Hatchet: {
* = * "Hatchet Init"
  Init: {

      rts
  }

// Parameter list in stack:
// Return address           2byte
// Sprite pointer address   2byte
// Hatchet frame            1byte

// Output list on stack:
// Return address           2byte
// Hatchet frame            1byte
// Hatchet stroke performed 1byte
* = * "Hatchet UseTheHatchet"
  UseTheHatchet: {
      pla
      sta ReturnAddress
      pla
      sta ReturnAddress + 1

      // Caller must set into stack the hi-byte and lo-byte of sprite pointer
      pla
      sta LoadHatchet1 + 2
      sta LoadHatchet2 + 2
      sta LoadHatchet3 + 2
      pla
      sta LoadHatchet1 + 1
      sta LoadHatchet2 + 1
      sta LoadHatchet3 + 1
      pla
      sta HatchetFrame

      ldx #$00

      inc HatchetFrame
      lsr
      lsr
      lsr
      lsr
      bcc Done

      lda #$00
      sta HatchetFrame

    LoadHatchet1:
      lda SPRITE_PTR
      cmp #SPRITES.HATCHET
      beq SwitchUpFrame
    LoadHatchet2:
    SwitchDownFrame:
      dec SPRITE_PTR
      jmp Done

    LoadHatchet3:
    SwitchUpFrame:
      inc SPRITE_PTR
      inx

    Done:
      txa
      pha
      lda HatchetFrame
      pha
      lda ReturnAddress + 1
      pha
      lda ReturnAddress
      pha

      rts

    .label SPRITE_PTR   = $beef

    HatchetFrame:
      .byte $ff

    ReturnAddress:
      .word $beef
  }

* = * "Hatchet UpdateHatchetFrame"
  UpdateHatchetFrame: {

    rts
  }
}

#import "label.asm"
