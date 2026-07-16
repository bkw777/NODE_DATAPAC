# Assembly Source for RAMDSK
Originally started as a disassembly of Paul Globman's RAM100.CO and RAM200.CO v2

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

Generates RAMxxx.CO and matching BASIC loader RAMxxx.DO for 100, 200, K85, and M10.

Also generates RAMxxx.calls, which contains addresses to the main routines which can be CALLed from BASIC or from another machine language program ...in theory. Calling these functions from an external program has not been tested yet in the new version.  
See [RAMDSK.TIP](../RAMDSK.TIP) and [RAMDSK.DO](../../../ROM/100/RAMDSK.DO) for the old original docs about calling routines in the original NODE ROM and RAMDSK, but be aware the addresses in those docs are wrong even for the legacy RAMDSK v2. They are from RAMDSK v1, and we don't have a copy of RAMDSK v1 for 100, just for 200.

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

## RBOOT.BA
RBOOT.BA is an optional way to re-install RAMDSK after a hard reset, by loading it from the device itself without needing a computer or tape or TPDD. You can type-in the 4-line BASIC and that will load the file from the device, as long as RAMxxx.CO is the first file on the device.

The RBOOT.BA code in the main readme and silkscreened on MiniNDP PCB is hard-coded for the legacy binary's length and origin, but it is also correct for the new binary if built with `-DMATCH_LEGACY_CO_HEADER`, which is the default.

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
