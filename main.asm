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
    jsr Intro.Manager
    jsr Level1.Manager
    jsr Level2.Manager

  GamePlayFake:
    jmp GamePlayFake
}

* = * "Main MainGameSettings"
MainGameSettings: {
// Switch out Basic so there is available ram on $a000-$bfff
    lda $01
    ora #%00000010
    and #%11111110
    sta $01

// Set Vic bank 1 ($4000-$7fff)
    lda #%00000010
    sta CIA.PORT_A

// Set Multicolor mode on
    lda #%00011000
    sta VIC.SCREEN_CONTROL_2

    rts
}

#import "label.asm"
#import "utils.asm"
#import "joystick.asm"
#import "intro.asm"
#import "level1.asm"
#import "level2.asm"
#import "allimport.asm"
