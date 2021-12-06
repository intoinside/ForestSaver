////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Manager for level 3.
//
// Sprite pointer settings:
// * Ranger       Sprite 0
// * Hatchet 1    Sprite 1
// * Woodcutter 1 Sprite 2
// * Arsionist    Sprite 3
// * Flame        Sprite 4 
// * Tank tail    Sprite 5
// * Tank body    Sprite 6
// * Tank pipe    Sprite 7
//
////////////////////////////////////////////////////////////////////////////////

#importonce

Level3: {
  * = * "Level3 Manager"
  Manager: {
      jsr Init
      jsr AddColorToMap

    LevelDone:
      jsr Finalize
      rts
  }

  // Initialization of level 3
  * = * "Level3 Init"
  Init: {
      CopyScreenRam($4c00, MapDummyArea)

      lda #$4c
      sta ShowGameNextLevelMessage.StartAddress + 1

      SetSpriteToForeground()

      rts
  }

  * = * "Level3 Finalize"
  Finalize: {
      CopyScreenRam(MapDummyArea, $4400)

      jsr DisableAllSprites

      jsr CompareAndUpdateHiScore

      jsr Hud.ResetDismissalCounter

      rts
  }

  AddColorToMap: {
      lda #$4c
      sta SetColorToChars.ScreenMemoryAddress

      jsr SetColorToChars

      rts
  }

}
