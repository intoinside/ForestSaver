
// Screen map memory definition
* = $4000 "IntroMap"
  .import binary "./maps/intro.bin"
* = $4400 "Map1"
  .import binary "./maps/map1.bin"
* = $4800 "Map2"
  .import binary "./maps/map2.bin"
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
  .import binary "./maps/charset.bin"
* = $c000 "CharColors"
CharColors:
  .import binary "./maps/charcolors.bin"
