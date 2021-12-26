[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) [![Gitter](https://badges.gitter.im/intoinside/community.svg)](https://gitter.im/intoinside/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge) [![CircleCI](https://circleci.com/gh/intoinside/ForestSaver/tree/main.svg?style=svg)](https://circleci.com/gh/intoinside/ForestSaver/tree/main)

# ForestSaver

A ranger has to do a lot of work to preserve the forest. He must be careful of the loggers, the industries that want to pollute the lakes and the arsonists who want space for their pastures.

## Tools needed

### Play
* A real Commodore 64
* Vice emulator https://vice-emu.sourceforge.io/
* FrodoC64 for Android&trade; https://play.google.com/store/apps/details?id=org.ab.c64
* Don't know if there's an emulator for Iphone

### Development
* Sublime Text https://www.sublimetext.com/3 with Kick Assembler http://theweb.dk/KickAssembler/
* CharPad https://subchristsoftware.itch.io/charpad-free-edition
* SpritePad https://www.subchristsoftware.com/spritepadfree/
* Vice emulator https://vice-emu.sourceforge.io/
* C64 debugger Gui https://magoarcade.org/wp/c64debuggui/
* Java JDK (at least v11) https://www.oracle.com/java/technologies/downloads/
* c64lib https://github.com/c64lib (common, chipset)

These are used for CI/CD, not needed (but helpful) for development
* Gradle build tool https://gradle.org/
* c64lib.retro-assembler https://github.com/c64lib/gradle-retro-assembler-plugin
* Circle.ci https://circleci.com/
* GitHub https://github.com/intoinside/ForestSaver

## Build info

### Download ForestSaver only for play
Look into [Releases](https://github.com/intoinside/ForestSaver/releases) and check for the latest prg/d64 available.

At this point you should be able to build project inside KickAssembler.

### Download ForestSaver for develop, build and play

* Clone repository on your folder
`git clone https://github.com/intoinside/ForestSaver.git`
* Switch to game folder
`cd ForestSaver`
* Run `gradlew build`
* Take `main.prg` and run it on Vice
