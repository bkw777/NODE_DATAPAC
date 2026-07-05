# Broken sometime in the last few days.
Use an old commit from at least a week ago to get a good binary.  
CO files copied from disk to ram are corrupt.  
I can't test or fix it right now.  
This is *probably ok*: https://github.com/bkw777/NODE_DATAPAC/tree/a2793982dc668337d4b501e3509e82795d3a6777  
Or if not, then try a little bit older: https://github.com/bkw777/NODE_DATAPAC/tree/56e26bfd6ce8e61dd948243872eae66284c12d2d  
Or try any from about a weak or older: https://github.com/bkw777/NODE_DATAPAC/commits/main  
It was fine, but I made a lot of big changes just in the last week.  


# Assembly Source for RAMDSK Reconstructed from Disassembly

Disassembled & reassembled source for Paul Globman's RAMDSK for NODE DATAPAC/RAMPAC  
Now also somewhat modified.

Changes from the legacy version:  
 * Supports 4 banks / 1 Meg  
 * Better bank-detect routine  
   Detects how many banks the device has and only tries to switch within the discovered range  
 * Bank-detect only runs once on start-up  
   Old version ran a test every time you hit the bank button  
   (which admittedly was probably useful when calling the routine from another program)  
 * Bank-detect preserves pre-existing disk data  
   Old version wrote to disk without permission and without saving & restoring  
 * Different format/repair flow:  
   * Format & Repair both now get an extra confirm sure prompt  
   * LABEL key triggers format/repair on command any time  
     If you have an unformatted device with random data, and answer N to format  
     then Y to repair, you wind up with a scrambled unusable device, but RAMDSK  
     thinks it's formatted and will no longer offer to format.  
     This allows you to recover from that by manually invoking format/repair  
     whenever you want.  
   * Answering N to both format & repair only goes back to main rather than exit.  
     Since you can now trigger format/repair any time by pressing LABEL, you  
     don't necessarily need to be booted out.  
   * F8 key escapes format/repair loop if you don't want to answer Y to either one  
 * Several bits of dead code found and removed  
   Several small optimisations that each saved a few bytes  
 * File size artificially padded to match the old binary so that the BOOT.BA  
   BASIC code with hard-coded TOP & END addresses in it still works without  
   change on both old and new binaries. Even with all the new added code,  
   there was enough savings that the new binary actually needs *padding* even
   though the program now does more and does it slightly nicelyer.  
   Currently only 5 bytes. I've pretty much used up the gains doing the above.

Generates RAMxxx.CO and matching BASIC loader RAMxxx.DO for 100, 200, and K85.

Also generates RAMxxx.map, which contains CALL addresses. A few of those addresses are usable from BASIC.  
See [RAMDSK.TIP](../RAMDSK.TIP) and [RAMDSK.DO](../../../ROM/100/RAMDSK.DO) but ignore the addresses.

## Build
Build all: .CO & .DO for 100, 200, & K85  
`make clean all`

## Build a custom relocated binary
Specify desired END address with XFLAGS='-DHIMEM=addr'  
Example, You want to keep something else installed, and add RAMDSK below that.  
Install the other CO, `LOADM "FOO.CO"`, note the TOP addr, `CLEAR 0,TOPADDR`,  
then `?HIMEM`, and use that number. Ex: Model 200, TEENY is 747 bytes, MAXRAM is 61104  
`make clean 200 XFLAGS='-DHIMEM=60357'`  
(BTW, bad example because TEENY has a relocating installer, so it makes more sense  
to just install the normal RAMDSK first and let TEENY install itself below RAMDSK)

## Install  
`make load_100`  
`make load_200`  
`make load_K85`  

those are just shorthand for `dl -v -b RAM100.DO`  

Or, on Windows without Cygwin: [tsend](http://github.com/bkw777/tsend)


## Compatibility

The tiny 4-line BASIC bootstrap code with the hard-coded TOP & END values
for the old binaries works on the new binaries also, because although the
contents of the binaries changed, the total file size and ORG address are
kept the same as the old binaries.

The BOOT code silkscreened on MiniNDP PCBs is correct for both old and new binaries.  
For K85, use the BOOT code for 100 with RAMK85.CO

## Legacy Reference Versions

Preserved original binaries:  
[../RAM100/orig/](../RAM100/orig/) and [../RAM200/orig/](../RAM200/orig/)

Assembly source that reproduces the original binaries exactly:  
[../RAM100/orig/disasm/](../RAM100/orig/disasm/) and [../RAM200/orig/disasm/](../RAM200/orig/disasm/)

## programming references
rom addresses cross map, ide support for 8085 asm, system roms & docs  
https://github.com/bkw777/m100_dev
