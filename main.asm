////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Main source code. Game initialization and main loop container.
//
////////////////////////////////////////////////////////////////////////////////

#importonce

.segmentdef Code [start=$0810]
.segmentdef MapData [start=$4000]
.segmentdef MapDummyArea [start=$5000]
.segmentdef Sprites [start=$5400]
.segmentdef Charsets [start=$7800]
.segmentdef CharsetsColors [start=$c000]

.file [name="./main.prg", segments="Code, Charsets, CharsetsColors, MapData, Sprites", modify="BasicUpstart", _start=$0810]
.file [name="./ForestSaver.prg", segments="Code, Charsets, CharsetsColors, MapData, Sprites", modify="BasicUpstart", _start=$0810]
.disk [filename="./ForestSaver.d64", name="\FORESTSAVER", id="C2021", showInfo]
{
  [name="----------------", type="rel"],
  [name="FORESTSAVER", type="prg", segments="Code, Charsets, CharsetsColors, MapData, Sprites", modify="BasicUpstart", _start=$0810],
  [name="----------------", type="rel"]
}

.segment Code

* = * "Entry"
Entry: {
    jsr MainGameSettings
    jmp GamePlay
}

GameEnded:          // $00 - Game in progress
  .byte $00         // $ff - Played dead, game ended

* = * "Main GamePlay"
GamePlay: {
    jsr Intro.Manager

    InitNewGame()

/* Code commented only for level3 develop
// Play on level 1
    jsr Level1.Manager
    lda GameEnded
    bne GamePlay

// Play on level 2
    jsr Level2.Manager
    lda GameEnded
    bne GamePlay
*/

// Play on level 3
    jsr Level3.Manager
    lda GameEnded
    bne GamePlay

    jmp GamePlay
}

.macro InitNewGame() {
    lda #0
    sta GameEnded
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
    sta CIA2.PORT_A

// Set Multicolor mode on
    lda #%00011000
    sta c64lib.CONTROL_2

    lda #$ff
    sta c64lib.SPRITE_COL_MODE

    jsr Keyboard.Init

    rts
}

#import "_intro.asm"
#import "_level1.asm"
#import "_level2.asm"
#import "_level3.asm"
#import "_keyboard.asm"
#import "_allimport.asm"
