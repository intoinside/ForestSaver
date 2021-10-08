[![CircleCI](https://circleci.com/gh/intoinside/ForestSaver/tree/main.svg?style=svg)](https://circleci.com/gh/intoinside/ForestSaver/tree/main)

# ForestSaver

A ranger has to do a lot of work to preserve the forest. He must be careful of the loggers, the industries that want to pollute the lakes and the arsonists who want space for their pastures.

## Tools needed

### For development
* Sublime Text https://www.sublimetext.com/3 with Kick Assembler http://theweb.dk/KickAssembler/
* CharPad https://subchristsoftware.itch.io/charpad-free-edition
* SpritePad https://www.subchristsoftware.com/spritepadfree/
* Vice emulator https://vice-emu.sourceforge.io/
* C64 debugger Gui https://magoarcade.org/wp/c64debuggui/
* Java JDK (at least v11) https://www.oracle.com/java/technologies/downloads/
* Gradle build tool https://gradle.org/
* c64lib https://github.com/c64lib
* c64lib.retro-assembler https://github.com/c64lib/gradle-retro-assembler-plugin

These are used for CI/CD, not needed (but helpful) for development
* Circle.ci https://circleci.com/
* GitHub https://github.com/intoinside/ForestSaver

### For play
* Vice emulator https://vice-emu.sourceforge.io/ or a real Commodore 64

## Build info

### Download ForestSaver only for play
Look into [Releases](https://github.com/intoinside/ForestSaver/releases) and take the last prg available.

### Download ForestSaver for develop

* Clone repository on your folder
`git clone https://github.com/intoinside/ForestSaver.git`
* Switch to game folder
`cd ForestSaver`
* Clone libraries
`git clone https://github.com/c64lib/common.git --branch 0.2.0`

At this point you should be able to build project inside KickAssembler.

### Download ForestSaver for build and play

* Clone repository on your folder
`git clone https://github.com/intoinside/ForestSaver.git`
* Switch to game folder
`cd ForestSaver`
* Run `gradlew build`
* Take `main.prg` and run it on Vice
