////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Some useful routine.
//
////////////////////////////////////////////////////////////////////////////////


// Fill screen with $20 char (preserve sprite pointer memory area)
ClearScreen: {
		lda #$20
		ldx	#250
	!:
		dex
		sta VIC.SCREEN_RAM, x
		sta VIC.SCREEN_RAM + 250, x
		sta VIC.SCREEN_RAM + 500, x
		sta VIC.SCREEN_RAM + 750, x
		bne !-

		rts
}
