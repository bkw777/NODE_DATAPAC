# Assembly Source for RAMDSK Reconstructed from Disassembly

Disassembled & reassembled source for Paul Globman's RAMDSK for NODE DATAPAC/RAMPAC

This single source builds all versions & targets:  

- exact replications of the legacy RAM100.CO & RAM200.CO
- a K85 equivalent of the legacy RAM100.CO
- (default) new version that supports 4 banks for 100, 200, & K85

For each target RAMxxx.CO, a matching RAMxxx.DO BASIC loader is also generated.

`RAMxx.map` are also generated, which contains subroutine addresses.  
A few of the main jump targets are usable from BASIC via CALL.  
See [RAMDSK.TIP](../RAMDSK.TIP) and [RAMDSK.DO](../../../ROM/100/RAMDSK.DO) but ignore those addresses.

## Build new binaries that support up to 4 banks  
`make clean all`

## Build exact reproduction legacy binaries and verify they match the preserved originals  
`make clean legacy`

## Install  
`dl -v -b RAM100.DO`  
...or for Windows without Cygwin: [tsend](http://github.com/bkw777/tsend)

Shortcut for above install command: `make load_100` or 200 or K85

## Compatibility

The tiny 4-line BASIC bootstrap code with the hard-coded TOP & END values
for the old binaries works on the new binaries also, because although the
contents of the binaries changed to add the 4-bank support,
the total file size and ORG address are kept the same as the old binaries.

So even the BASIC code silkscreened on MiniNDP PCBs the last few year years
is still correct for these new binaries.
