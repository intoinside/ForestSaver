////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Main source code. Game initialization and main loop container.
//
////////////////////////////////////////////////////////////////////////////////

BasicUpstart2(Entry)

* = * "Entry"
Entry: {
    jsr MainGameSettings
    jmp GamePlay
}

* = * "Main GamePlay"
GamePlay: {
    jsr IntroManager

  GamePlayFake:
    jmp GamePlayFake
}

.label SCREEN_RAM = $8400

* = * "Main MainGameSettings"
MainGameSettings: {
    // Switch out Basic so there is available ram on $a000-$bfff
    lda $01
    ora #%00000010
    and #%11111110
    sta $01

    // Set Vic bank 2 ($8000-$bfff)
    lda CIA.PORT_A
    ora #%00000001
    and #%11111101
    sta CIA.PORT_A

    rts
}

#import "label.asm"
#import "utils.asm"
#import "intro.asm"
