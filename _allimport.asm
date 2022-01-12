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

.segment MapData
* = $4000 "IntroMap"
  .import binary "./maps/intro.bin"
* = $4400 "Level1"
  .import binary "./maps/level1.bin"
* = $4800 "Level2"
  .import binary "./maps/level2.bin"
* = $4c00 "Level3"
  .import binary "./maps/level3.bin"

.segment MapDummyArea
* = $5000 "MapDummyArea"
MapDummyArea:

.segment Sprites
  .import binary "./sprites/sprites.bin"

.segment Charsets
Charset:
  .import binary "./maps/charset.bin"

.segment CharsetsColors
CharColors:
  .import binary "./maps/charcolors.bin"
