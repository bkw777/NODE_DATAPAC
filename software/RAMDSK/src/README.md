# Assembly Source for RAMDSK
Originally started as a disassembly of Paul Globman's RAM100.CO and RAM200.CO v2

RAMDSK.S85 is the main source  
100/200/K85/M10.S85 are platform headers  
Makefile uses [z88dk](https://github.com/z88dk/z88dk) to compile the asm to RAMxxx.CO, and co2ba.sh from [dl2](https://github.com/bkw777/dl2) to generate RAMxxx.DO  

Changes from the legacy version:  
 * Supports 4 banks / 1 Meg  
 * Kyotronic KC-85  
 * Olivetti M-10  
 * Bank-detect only runs once on start-up vs on every bank-switch  
 * Bank-detect preserves pre-existing disk data so non-ramdsk data is not corrupted  
 * Format & Repair both now have an extra confirm sure prompt  
 * Can trigger format/repair manually by pressing the LABEL key  
 * Answering N to both format & repair no longer exits the app  
 * F8 exit key now also works at the format/repair/sure prompts  
 * Several bits of dead code found and removed  
 * Several small refactors  
 * Binary length & origin artificially match the legacy binary by default for the sake of RBOOT.BA  

Makefile generates all of the following for each platform xxx = 100, 200, K85, M10:  
* RAMxxx.CO - binary executable  
* RAMxxx.DO - BASIC loader that contains and installs RAMxxx.CO  
* RAMxxx.calls - addresses to the main functions that can be CALLed from BASIC or another program  
* RBOOT.xxx - BASIC code that can be manually typed in to reinstall RAMxxx.CO from the device itself after a hard reset  

## Build
Build all: .CO & .DO for 100, 200, K85, & M10  
`make clean all`

## Build a custom relocated binary
Specify desired END address with `XFLAGS='-DHIMEM=addr'`  
`make clean 200 XFLAGS='-DHIMEM=60357'`

## Install  
`make load_100` or _200 _K85 _M10  
Which is just shorthand for `dl -v -b RAMxxx.DO`

Or, on Windows (if not using Cygwin/MSYS2), use the same .DO files with [tsend](http://github.com/bkw777/tsend)

## RBOOT.xxx
RBOOT.BA is an optional way to re-install RAMDSK after a hard reset, by loading it from the device itself without needing a computer or tape or TPDD. You can type-in the 4-line BASIC and that will load the file from the device, as long as RAMxxx.CO is the first file on the device.

The makefile generates RBOOT.xxx with the correct TOP & END addresses for the generated binary.  
IF you build without `-DMATCH_LEGACY_CO_HEADER`, then only the generated RBOOT.xxx will be correct for that binary.  

If you build with `-DMATCH_LEGACY_CO_HEADER` (the default), then the new binary is artificially made to match the old binary, and the RBOOT.BA code in the main readme and silkscreened on MiniNDP PCB which is hard-coded for the legacy binary's length and origin, is also correct for the new binary.  
For K85, use the code for 100 with RAMK85.CO  
For M10, use the code for 100 with RAMM10.CO  

## Legacy Reference Versions

Preserved original binaries:  
[../RAM100/orig/](../RAM100/orig/) and [../RAM200/orig/](../RAM200/orig/)

Assembly source that reproduces the original binaries exactly:  
[../RAM100/orig/disasm/](../RAM100/orig/disasm/) and [../RAM200/orig/disasm/](../RAM200/orig/disasm/)

## programming references
rom addresses cross map, ide support for 8085 asm, system roms & docs  
https://github.com/bkw777/m100_dev
