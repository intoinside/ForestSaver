////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Import for any external resource
//
////////////////////////////////////////////////////////////////////////////////

#importonce

// Screen map memory definition
* = $4000 "IntroMap"
  .import binary "./maps/intro.bin"
* = $4400 "Level1"
  .import binary "./maps/level1.bin"
* = $4800 "Level2"
  .import binary "./maps/level2.bin"
/*
* = $4c00 "Map3"
  .import binary "./maps/map2.bin"
* = $5000 "Map4"
  .import binary "./maps/map2.bin"
*/

// Sprite area definition
* = $5400 "Sprites"
  .import binary "./sprites/sprites.bin"

// Charset and char color
* = $7800 "Charset"
Charset:
  .import binary "./maps/charset.bin"
* = $c000 "CharColors"
CharColors:
  .import binary "./maps/charcolors.bin"

#import "main.asm"
