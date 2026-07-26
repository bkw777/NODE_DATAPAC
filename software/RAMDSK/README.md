# RAMDSK

Originally the DATAPAC was shipped with an option rom from Node (possibly commissioned from Travelling Software?) which saved and loaded files to/from the device.

Later, Paul Globman reverse-engineered the data format and wrote RAMDSK.CO, and Node eventually just licensed RAMDSK from Paul and shipped it with with the devices. (I call this RAMDSK v1)

Later still, Paul (or someone but presumably Paul) added support for 2 banks and added the format stamp repair function. (I call this RAMDSK v2)

Later still, I disassembled RAMDSK and modified it to support 4 banks and to improve the format/repair ux a little, and remove dead code, while artificially preserving the same file size and entry address as the previous version so that it would not require different boostrap/recovery BASIC code.

RAMDSK provides the same functionality as the NODE ROM, and is compatible with it.  
They both write the same filesystem structure to the device, either one can read/write a device that was formatted by the other.

Differences between the NODE ROM and RAMDSK:

The NODE ROM creates a text file when it formats a blank device, RAMDSK does not.

The NODE ROM docs claim it also supports PG Designs and PCSG ram expansions, which are NOT clones or work-alikes of the DATAPAC. RAMDSK only supports the DATAPAC or anything that works exactly the same way such as rampac, EXTRAM, MiniNDP.

RAMDSK supports banks (devices with more than 256K of ram), the NODE ROM only supports up to 256K.

RAMDISK includes a feature to automatically repair the easily-corrupted format stamp in the first 2 bytes of the device, the NODE ROM does not.

# Installing RAMDSK the first time

To get RAMDSK installed for the first time, use the appropriate `RAMxxx.DO` BASIC loader for your machine:  
  100: TRS-80 Model 100, TANDY Model 102  
  200: TANDY Model 200  
  K85: Kyotronic KC-85  
  M10: Olivetti M-10  

To bootstrap the BASIC loader from a PC running Windows:  
Install [tsend](https://github.com/bkw777/tsend)  
Then: `C:> tsend.ps1 -file RAM100.DO`

To bootstrap the BASIC loader from a PC running Linux, MACOS, FreeBSD, any unix, Cygwin/MSYS2:  
Install [dl2](https://github.com/bkw777/dl2)  
Then: `$ dl -v -b RAM100.DO`

Then run RAMDSK to format and use the device.

# Reinstalling RAMDSK from the device
Once you have RAMDSK installed, if you save a copy to the device as the very first file after a fresh format, then in the future you can re-install RAMDSK from the device itself after a hard reset by typing in a short BASIC program.

Archived docs mention an 8 line BASIC program called BOOT.  
That program does not seem to be archived anywhere, but I have written `RBOOT` below which is only 4 40-column lines.

Requires first saving a copy of RAMDSK.CO to the device, and must be the first file on the device.

You may notice that the inner byte-read loop is stupid. It's true but doesn't matter.  
This is optimized to tetris-pack into the fewest possible 40-column lines, with all platform differences in the first line.  

This has hard-coded TOP & END values that are only valid for the legacy RAMDSK v2 and the latest RAMDSK, only because the latest version is artificially padded to come out to the same length as the legacy version just for this reason.  
If you compile with other options or modified code, the makefile also generates RBOOT.xxx that is correct for the generated RAMxxx.CO (the same as these but with different TOP & END numbers in the 1st line)  
RAM200.CO v1 would also need different values than these.

## RBOOT for 100, 102, K85, & M10
```
1 CLEAR0,61558:T=61558:E=62957:OUT129,2
2 FORA=0TO15:N=INP(131):NEXT:FORA=TTOE
3 POKEA,INP(131):IFA=T+1007THENOUT129,1
4 ?".";:NEXT:SAVEM"RAMDSK",T,E,T
```

## RBOOT for 200  
```
1 CLEAR0,59715:T=59715:E=61101:OUT129,2
2 FORA=0TO15:N=INP(131):NEXT:FORA=TTOE
3 POKEA,INP(131):IFA=T+1007THENOUT129,1
4 ?".";:NEXT:SAVEM"RAMDSK",T,E,T
```

## multi-boot
Either of above may be adjusted to boot from a different bank instead of bank0.  
For bank 1, 2, or 3, change all (2) occurances of OUT129 to OUT133, 137, or 141.  
Example, Model 200 reinstalling from Bank1 (requres RAM200.CO saved as the first file in bank1):  
```
1 CLEAR0,59715:T=59715:E=61101:OUT133,2
2 FORA=0TO15:N=INP(131):NEXT:FORA=TTOE
3 POKEA,INP(131):IFA=T+1007THENOUT133,1
4 ?".";:NEXT:SAVEM"RAM200",T,E,T
```

You could get fancy and support for example both model 102 and model 200 at the same time on the same device by for example saving RAM100.CO to Bank0 and RAM200.CO to Bank1.


# Using RAMDSK
Usage is mostly pretty self-explanatory.  

A few things that aren't explained on-screen.  

* On legacy version RAMDSK v2 if you keep holding the Enter key down while RAMDSK starts up, then it switches from bank0 to bank1 before anything else, so you essentially start in bank1 instead of bank0.
  This code is omitted from the current version.  

* On startup RAMDSK looks at the first 2 bytes of the disk to tell if the disk is formatted or not.  
  If it does not see a valid format stamp (0x40 0x04), it asks if you want to format the disk.  
  You can answer Y or N here.  
  Don't panic if you get this on a device that is supposed to already be formatted and have files.  
  Just be sure to answer N! On the current version there is also an extra confirmation step so you even get 2 chances to avoid an unwanted format.  
  After you decline to format, you will get a chance to do a non-destructive repair instead.

* [The format stamp is easily corrupted](software/RAMDSK/RAMPAC.001),  
  When this happens, you will get the format prompt above. Don't Panic.  
  If you answer N to format, then next it asks "Repair?"  
  If you answer Y to repair, it just re-writes the format stamp without touching anything else.

  <!-- (As Paul Globman said above, it was not a great decision to use byte0 for this critical purpose (or any purpose) for exactly this reason, but that's what NODE did so we just have to deal with it.)  -->
  <!-- What Paul mentions about the latch being volatile is probably a good thing.  
  Better to always corrupt the same byte 0 than random bytes all over.  
  The latch losing power is like parking the heads. -->
  <!--
  You know what? now that we have source and can hack on RAMDSK, who cares about strict compatibility with the NODE ROM any more?
  TODO: maybe one of these, or something else:  
   - Use only the 2nd byte and ignore the 1st byte (but keep resetting it just to maximise compatibility with old binaries and node rom because no reason not to)  
     Maybe to make it less likely for a random data byte to match the valid format value, make it a checksum over the fcb table? That will definitely break compatibility because the legacy software is looking for exactly 0x40 0x04
   - Ignore both bytes 0 & 1 and don't even perform a format check, just assume it's formatted and display the gibberish if it's not. Format by providing a format button.  
     All of the actual load/save/kill/etc functions must still perform a test-else-abort on the spot every time just before their actual work, because the device is externally attached and can be disconnected at any time. 
     It's harmless to let the file listing display giberish. It's not harmless to let any other function read and operate on gibberish.
   - The 2nd 512 bytes of block0 are un-used, use some of them?
  -->

* Finally it displays a screen full of disk filenames.  
The files are not listed in the order they exist on the device, nor alphabetically. First all of the .BA files are listed, then the .CO files, then the .DO files.

* If there are more than one page of files on the disk, press Enter to see the next page of filenames.

* You can press LABEL to format the disk.

* All other actions done by the labelled F-keys.

F1 Bank - Switch between banks of 256k each.  
  Only functional on a device that has more than 256k.  
  The current bank number is displayed at the top of the screen.

F2 Load - Copy a file from disk to ram.

F3 Save - Copy a file from ram to disk.

F4 Name - Rename a file on disk.

F5 Kill - Delete a file on disk.

F8 Menu - Exit RAMDSK.

# Filesystem Data Structure

This is not previously documented that I have found.  
This comes from a combination of exploring a formatted device with [RAMPAC Inspector](../CRI), and from disassembling RAMDSK.

At the hardware level the device provides 256 1k blocks (per bank)

The NODE ROM and RAMDSK use that space to store files this way:

Block 0 is reserved for the format stamp and FCB table.

Blocks 1-255 are available for files.

The format stamp is the first 2 bytes of block 0: `0x40 0x04`  
NODE ROM and RAMDISK look for this to decide if a device is formatted or not.

The FCB table is the next 255 pairs of bytes of block 0.

Each FCB corresponds to a block.  
fcb 1-255 <-> block 1-255  

Each FCB is 2 bytes: `attr next`

`attr` is a file attribute  
the same value used by the MKDIRENT routine in the system rom.  
(0x2239 in the North American Model 100 system rom)  

  0x00 = block exists and is available  
  any value > 0x00 = block is not available  
  0x20 = block is part of a file but is not the first block in the file  
  0x40 = block does not exist or is otherwise not available  
  (block 0, blocks 127-255 on a device with only 128k of sram)  
  0x80 = first block of a .BA file  
  0xD0 = first block of a .CO file  
  0xA0 = first block of a .DO file

`next` is the block number of the next block in the file.  
  0x00 = file ends in this block, or block is not part of a file.

Bytes 512-1024 of block 0 are not used.  
You could store 512 bytes of hidden secrets there :)

For the remaining blocks 1-255:

If a block is the first block in a file, then the first 10 bytes of the block contain the RAMDSK file header:  
0-5: 6 bytes filename base  
6-7: 2 bytes filename extension  
8-9: 2 bytes file length, not including the 10-byte header  
The remaining 1014 bytes are file data

If a block is part of a file but not the first block in the file, then the block is all file data starting right at byte 0 and ending wherever the file length says to end.  
The bytes after the end of the file to the end of that block are not used.

The first block of a file is located by scanning the FCB table for all FCBs that have an `attr` matching the file you want, then reading the 10-byte header of each potential matching block until finding the matching filename.

The remaining blocks in a file are found by following the chain of `next` block pointers until filesize runs out and/or `next`=0x00. The FCB for the 1st block points to the 2nd block, the FCB for the 2nd block points to the 3rd, etc.

This means a bank may contain up to 255 1k files, or 1 255k file.

| block | contents |
| --- | --- |
|0|FCB table|
|1|file data|
|...|...|
|255|file data|

Block 0 / FCB table:

|byte#|1 byte|1 byte|desc|
| --- | --- | --- | --- |
|0-1|0x40|0x04|Stamp|
|2-3|attr|next|FCB 1|
|4-5|attr|next|FCB 2|
|...|...|...|...|
|509-510|attr|next|FCB 255|
|512-1024|||unused|

First block of any file:

|basename<br>6 bytes|extension<br>2 bytes|filesize<br>2 bytes|data<br>1014 bytes|
| --- | --- | --- | --- |
|RAMDSK|CO|0x7E 0x05|...|

Any other block:

|data<br>1024 bytes|
| --- |
|...|

# Assembly Source

[src/](src/)  
