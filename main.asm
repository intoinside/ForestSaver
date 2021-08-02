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

Entry:
		jsr MainGameSettings
		jmp GamePlay

GamePlay: {
		jsr IntroManager

	GamePlayFake:
		jmp GamePlayFake
}

MainGameSettings: {
		lda $01

		// Switch out Basic
		ora #%00000010
		and #%11111110
		sta $01

		rts
}

#import "label.asm"
#import "utils.asm"
#import "intro.asm"
