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

.segmentdef Code [start=$0810]
.segmentdef MapData [start=$4000]
.segmentdef MapDummyArea [start=$5000]
.segmentdef Sprites [start=$5400]
.segmentdef Charsets [start=$7800]
.segmentdef CharsetsColors [start=$c000]

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

#import "main.asm"
