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
      clc
      lda ScreenMemoryAddress
      adc #$03
      sta ScreenMemoryAddress

      rts
  }

* = * "Hatchet UseTheHatchet"
  UseTheHatchet: {
      lda ScreenMemoryAddress + 1
      sta LoadHatchet1 + 1
      sta LoadHatchet2 + 1
      sta LoadHatchet3 + 1

      lda ScreenMemoryAddress
      sta LoadHatchet1 + 2
      sta LoadHatchet2 + 2
      sta LoadHatchet3 + 2

      lda FrameReference
      sta SpriteFrameReference + 1

      ldx #$00

      inc HatchetFrame
      lda HatchetFrame
      lsr
      lsr
      lsr
      lsr
      bcc Done

      lda #$00
      sta HatchetFrame

    LoadHatchet1:
      lda SPRITE_PTR
    SpriteFrameReference:
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
      stx StrokeHappened

      rts

    .label SPRITE_PTR   = $beef

    FrameReference: .byte $00

    StrokeHappened:
      .byte $00

    HatchetFrame:
      .byte $ff
  }

  ScreenMemoryAddress:
    .word $be00
}

// Update hatchet frame
.macro CallUseTheHatchet(hatchetFrame, frameReference) {
  lda hatchetFrame
  sta Hatchet.UseTheHatchet.HatchetFrame
  lda #frameReference
  sta Hatchet.UseTheHatchet.FrameReference

  jsr Hatchet.UseTheHatchet

  lda Hatchet.UseTheHatchet.HatchetFrame
  sta hatchetFrame
}

#import "label.asm"
