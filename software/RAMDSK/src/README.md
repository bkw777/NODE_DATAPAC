# Assembly Source for RAMDSK Reconstructed from Disassembly

Disassembled & reassembled source for Paul Globman's RAMDSK for NODE DATAPAC/RAMPAC

This version adds support for more than 2 banks, and makes a few minor cosmetic changes.

Generates RAMxxx.CO matching BASIC loader RAMxxx.DO for 100, 200, and K85

Also generates `RAMxxx.map`, which contains CALL addresses. A few of those addresses are usable from BASIC.  
See [RAMDSK.TIP](../RAMDSK.TIP) and [RAMDSK.DO](../../../ROM/100/RAMDSK.DO) but ignore the addresses.

## Build
Build all, .CO & .DO for 100, 200, & K85  
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
contents of the binaries changed to add the 4-bank support,
the total file size and ORG address are kept the same as the old binaries.

The BASIC code silkscreened on MiniNDP PCBs is still correct for these new binaries.  
For K85, use the code for 100 on the silkscreen.

## Legacy Reference Versions

Preserved original binaries:  
[../RAM100/orig/](../RAM100/orig/) and [../RAM200/orig/](../RAM200/orig/)

Assembly source that reproduces the original binaries exactly:  
[../RAM100/orig/disasm/](../RAM100/orig/disasm/) and [../RAM200/orig/disasm/](../RAM200/orig/disasm/)
