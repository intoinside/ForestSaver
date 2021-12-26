////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Handler for enemy type 2 (arsionist)
//
////////////////////////////////////////////////////////////////////////////////

#importonce

Arsionist: {
  * = * "Arsionist Init"
  Init: {
      clc
      lda ScreenMemoryAddress
      adc #$03
      sta ScreenMemoryAddress

// Self modify code to use current screen memory address, update hibyte
      sta UpdateFrame.LoadSprite1 + 2
      sta UpdateFrame.LoadSprite2 + 2
      sta UpdateFrame.StoreSprite1 + 2
      sta UpdateFrame.StoreSprite2 + 2
      sta UseTheFlame.LoadSprite1 + 2
      sta UseTheFlame.StoreSprite1 + 2

      rts
  }

  * = * "Arsionist UpdateFrame"
  UpdateFrame: {
      lda ScreenMemoryAddress + 1
      sta UpdateFrame.LoadSprite1 + 1
      sta UpdateFrame.LoadSprite2 + 1
      sta UpdateFrame.StoreSprite1 + 1
      sta UpdateFrame.StoreSprite2 + 1

      inc ArsionistFrame
      lda ArsionistFrame
      lsr
      lsr
      lsr
      lsr
      bcc NoMove

      lda #$00
      sta ArsionistFrame

    LoadDirection:
      lda DirectionX
      cmp #$ff
      beq Left

    Right:
      ldx #SPRITES.ARSIONIST_STANDING
    LoadSprite1:
      lda SPRITE_PTR
      cmp #SPRITES.ARSIONIST_STANDING + 1
      beq RightUpdate
      inx

    RightUpdate:
      // If right frame edit occours, no other frame switch will be performed
    StoreSprite1:
      stx SPRITE_PTR
      jmp NoMove

    Left:
      ldx #SPRITES.ARSIONIST_STANDING + 2
    LoadSprite2:
      lda SPRITE_PTR
      cmp #SPRITES.ARSIONIST_STANDING + 3
      beq LeftUpdate
      inx

    LeftUpdate:
      // If left frame edit occours, no other frame switch will be performed
    StoreSprite2:
      stx SPRITE_PTR
      jmp NoMove

    NoMove:
      rts

    ArsionistFrame:
      .byte $00
    DirectionX:
      .byte $00
    DirectionY:
      .byte $00
  }

  * = * "Arsionist UseTheFlame"
  UseTheFlame: {
      ldx ScreenMemoryAddress + 1
      inx
      stx UseTheFlame.LoadSprite1 + 1
      stx UseTheFlame.StoreSprite1 + 1

      inc FlameFrame
      lda FlameFrame
      lsr
      lsr
      lsr
      lsr
      bcc NoChange

      lda #$00
      sta FlameFrame

      ldx #SPRITES.FLAME_1
    LoadSprite1:
      lda SPRITE_PTR
      cmp #SPRITES.FLAME_3
      beq RightUpdate
      tax
      inx

    RightUpdate:
      // If right frame edit occours, no other frame switch will be performed
    StoreSprite1:
      stx SPRITE_PTR

    NoChange:
      rts

    FrameReference: .byte $00

    FlameFrame: .byte $00
  }

  ScreenMemoryAddress:
    .word $be00

  .label SPRITE_PTR = $beef
}

.macro CallUpdateArsionistFrame(arsionistFrame) {
  lda #$ff
  sta Arsionist.UpdateFrame.DirectionX

  lda arsionistFrame
  sta Arsionist.UpdateFrame.ArsionistFrame

  jsr Arsionist.UpdateFrame

  lda Arsionist.UpdateFrame.ArsionistFrame
  sta arsionistFrame
}

.macro CallUpdateArsionistFrameReverse(arsionistFrame) {
  lda #1
  sta Arsionist.UpdateFrame.DirectionX

  lda arsionistFrame
  sta Arsionist.UpdateFrame.ArsionistFrame

  jsr Arsionist.UpdateFrame

  lda Arsionist.UpdateFrame.ArsionistFrame
  sta arsionistFrame
}

.macro CallUseTheFlameThrower(flameFrame, frameReference) {
  lda flameFrame
  sta Arsionist.UseTheFlame.FlameFrame
  lda #frameReference
  sta Arsionist.UseTheFlame.FrameReference

  jsr Arsionist.UseTheFlame

  lda Arsionist.UseTheFlame.FlameFrame
  sta flameFrame
}
