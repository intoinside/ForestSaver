[![CircleCI](https://circleci.com/gh/intoinside/ForestSaver/tree/main.svg?style=svg)](https://circleci.com/gh/intoinside/ForestSaver/tree/main)

# ForestSaver

A ranger has to do a lot of work to preserve the forest. He must be careful of the loggers, the industries that want to pollute the lakes and the arsonists who want space for their pastures.

## Tools used
* Sublime Text https://www.sublimetext.com/3 with Kick Assembler http://theweb.dk/KickAssembler/
* CharPad https://subchristsoftware.itch.io/charpad-free-edition
* SpritePad https://www.subchristsoftware.com/spritepadfree/
* Vice emulator https://vice-emu.sourceforge.io/
* C64 debugger Gui https://magoarcade.org/wp/c64debuggui/

## Tech information (ita and then eng)
Per il funzionamento, ho scelto il Vic Bank 1 ($4000-$7fff). Questo consente di avere a disposizione per il programma le seguenti aree di memoria:
* da $1000 a $4fff (16 Kib)
* da $8000 a $9fff (8 Kib)
* da $a000 a $bfff (8 Kib, dove è presente la Basic Rom che verrà disabilitata)
* da $c000 a $dfff (8 Kib)

Ogni livello (compresa la schermata di introduzione) fa riferimento ad una screen memory separata, il cui contenuto viene caricato
dalle direttive .import.

```
* = $4000 "IntroMap"
  .import binary "./maps/intro.bin"
* = $4400 "Map1"
  .import binary "./maps/map1.bin"
* = $4800 "Map2"
  .import binary "./maps/map2.bin"
```
Per usufruire dell'area da $a000 a $bfff, ho disabilitato il Basic: essendo un programma in assembly, a parte la prima operazione SYS, non è richiesto.

Essendo previsti 3 livelli + intro, sono necessarie quattro screen memory che saranno:
* $4000-$43ff Intro
* $4400-$47ff Livello 1
* $4800-$4bff Livello 2
* $4c00-$4fff Livello 3
* $5000-$53ff Livello 4

Con questa organizzazione è presumibile che gli sprite occuperanno lo spazio a partire da $6000. In questo modo, gli sprite avranno a disposizione tutto lo spazio restante nel Vic bank 1, da $6000 a $77ff.
Dato che ogni sprite occupa 63 bytes più 1 di padding (cioè $40), saturando tutta la memoria ipotizzata, potenzialmente si possono inserire fino a 95 sprite.
Per fare due conti esplicativi:
* $77ff - $6000 = $17ff cioè 6143 bytes a disposizione
* (spazio totale a disposizione) $17ff / (dimensione di ogni sprite) $40 = $5f cioè 95 sprite

L'indirizzo $6000 è stato scelto per avere spazio per l'eventuale aggiunta di livelli da mappare sulle screen memory disponibili. Da $5400 a $5fff si possono mappare ulteriori 2 screen.

Se volessimo utilizzare tutta la memoria disponibile nel bank 1, gli sprite possono partire da $5400:
* $77ff - $5400 = $23ff cioè 9215 bytes a disposizione
* (spazio totale a disposizione) $23ff / (dimensione di ogni sprite) $40 = $8f cioè 143 sprite

Al momento, i livelli ipotizzati sono 3 (quindi fino a $4fff), per comodità e, soprattutto in previsione di avere tanti sprite, verranno posizionati a partire da $5400 (lasciando quindi spazio per un ulteriore livello).
Si possono ricavare altre zone di memoria (esterne al bank 1) dove posizionare eventuali ulteriori sprite, ma per utilizzarli sarà necessario fare un bank switch (rimappando anche le screen memory) oppure una copia on-the-fly degli sprite all'interno del bank. Per ora non è necessario ricorrere a questi stratagemmi.

```
* = $5400 "Sprites"
  .import binary "./sprites/sprites.bin"
```
Considerando l'inserimento degli sprite a partire da $5400, lo sprite pointer del primo sprite è $50.
Il calcolo è il seguente:
* $5400 (area di stoccaggio degli sprite) - $4000 (inizio del VIc bank 1) = $1400 (posizione relativa dell'area di stoccaggio rispetto al Vic Bank 1)
* $1400 / $40 (dimensione di uno sprite + 1 byte di padding) = $50
Gli altri sprite avranno un posizionamento relativo al primo, aggiungendo l'offset definito in fase di design degli sprite.

Dopo l'area degli sprite, è presente la char memory, scelta nel momento di impostazione del Vic bank 1. Si trova all'indirizzo $7800:
```
* = $7800 "Charset"
  .import binary "./maps/charset.bin"
```
In questo momento sono presenti 157 caratteri, che occupano 1256 byte ($4e8) e sono destinati ad aumentare. La dimensione massima è $800 cioè 2048 bytes.

La definizione dei colori dei caratteri viene caricata nell'area di memoria a partire da $c000.
```
* = $c000 "CharColors"
CharColors:
  .import binary "./maps/charcolors.bin"
```

I dati inseriti in questa porzione di memoria sono "tampone" nel senso che verranno utilizzati come base per mappare i colori al cambio del puntamento della screen memory.

TBD
