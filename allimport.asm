


* = $8000 "Map1"
  .import binary "./maps/map1.bin"
* = $8400 "Map1"
  .import binary "./maps/map1.bin"

* = $b800
  .import binary "./maps/charset.bin"
* = $c000 "CharColors"
CharColors:
  .import binary "./maps/charcolors.bin"
