////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Manager for intro screen.
//
////////////////////////////////////////////////////////////////////////////////

// Manager of intro screen
* = * "Intro IntroManager"
IntroManager: {
    jsr Init
    jsr ClearScreen

    rts
}

// Initialization of intro screen
* = * "Intro Init"
Init: {
    lda #$00
    sta VIC.BORDER_COLOR
    sta VIC.BACKGROUND_COLOR

    rts
}
