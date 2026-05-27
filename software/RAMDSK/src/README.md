# RAMDSK remade

Disassembled & reassembled source for Paul Globman's RAMDSK for NODE DATAPAC/RAMPAC

This single source builds all versions & targets:  
- RAM100 legacy version for Model 100/102 - supports 2 banks, binary exactly matches the legacy binary.
- RAM200 Same for Model 200
- RAM100 new version for Model 100/102 - supports 4 banks, binary matches the original binary's TOP/LEN/EXE
- RAM200 Same for Model 200
 
A BASIC loader .DO is also generated for each .CO

## Build new binaries that support up to 4 banks  
`make clean all`

## Build reproduction legacy binaries and verify they match the real ones  
`make legacy`

## Install  
`dl -v -b RAM100.DO`  
...or for Windows without Cygwin: [tsend](http://github.com/bkw777/tsend)

The tiny 4-line BASIC bootstrap code with the hard-coded TOP & END values
for the old binaries works on the new binaries also, because although the
contents of the binaries changed to add the 4-bank support,
the total file size and ORG address are the same as the old binaries.

So even the BASIC code silkscreened onto the PCBs years ago is still correct
for these new binaries.

# KC-85
There is also a completed but not working version for KC-85.
You can build it with `make K85`
