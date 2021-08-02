// intro.asm

// Manager of intro screen
IntroManager: {
		jsr Init
		jsr ClearScreen

		rts
}

// Initialization of intro screen
Init: {
		lda #$00
		sta VIC.BORDER_COLOR
		sta VIC.BACKGROUND_COLOR

		rts
}
