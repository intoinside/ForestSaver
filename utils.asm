// utils.asm

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
