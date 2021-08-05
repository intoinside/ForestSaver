# ForestSaver

A ranger has to do a lot of work to preserve the forest. He must be careful of the loggers, the industries that want to pollute the lakes and the arsonists who want space for their pastures.

## Tools used
* Sublime Text https://www.sublimetext.com/3 with Kick Assembler http://theweb.dk/KickAssembler/
* CharPad https://subchristsoftware.itch.io/charpad-free-edition
* SpritePad https://www.subchristsoftware.com/spritepadfree/
* Vice emulator https://vice-emu.sourceforge.io/
* C64 debugger Gui https://magoarcade.org/wp/c64debuggui/

## Tech information (ita and then eng)
Per il funzionamento, ho scelto il Vic Bank 2 ($8000-$bfff). Questo consente di avere a disposizione per il programma tutta l'area da $1000 a $7fff.
Ogni livello (compresa la schermata di introduzione) fa riferimento ad una screen memory separata, il cui contenuto viene caricato
dalle direttive .import.

```
* = $8400 "Map1"
  .import binary "./maps/map1.bin"
* = $8800 "Map2"
  .import binary "./maps/map2.bin"
```
Per usufruire di tutta l'area da $a000 a $bfff, ho disabilitato il Basic: essendo un programma in assembly, a parte la prima operazione SYS, non è richiesto.

Essendo previsti 3 livelli + intro, sono necessarie quattro screen memory che saranno:
* $8000-$83ff Intro
* $8400-$87ff Livello 1
* $8800-$8bff Livello 2
* $8c00-$8fff Livello 3

Con questa organizzazione è presumibile che gli sprite occuperanno lo spazio a partire da $9000.
Dato che ogni sprite occupa 63 bytes più 1 di padding (cioè $40), saturando tutta la memoria fino a $b7ff, potenzialmente si possono inserire fino a 195 sprite.
Per fare due conti esplicativi:
* $b7ff - $9000 = $27ff cioè 12287 bytes a disposizione
* (spazio totale a disposizione) $27ff / (dimensione di ogni sprite) $40 = $9f cioè 159 sprite

L'aggiunta di un quarto livello, con l'occupazione della relativa screen memory da 400 bytes, ridurrebbe il numero massimo di sprite a:
* $b7ff - $9400 = $23ff cioè 11263 bytes a disposizione
* (spazio totale a disposizione) $23ff / (dimensione di ogni sprite) $40 = $8f cioè 143 sprite

Anche 143 è un valore accettabile quindi farò qualche valutazione in futuro sulla possibilità di aggiungere un ulteriore livello.
```
* = $9000 "Sprites"
  .import binary "./sprites/sprites.bin"
```

Dopo l'area degli sprite, è presente la char memory, scelta nel momento di impostazione del Vic bank 2. Si trova all'indirizzo $b800:
```
* = $b800 "Charset"
  .import binary "./maps/charset.bin"
```

La definizione dei colori dei caratteri viene caricata nell'area di memoria a partire da $c000.
```
* = $c000 "CharColors"
CharColors:
  .import binary "./maps/charcolors.bin"
```

TBD
