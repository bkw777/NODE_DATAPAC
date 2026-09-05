# NODE Systems DATAPAC
* [Documentation](#documentation)
* [Hardware](#datapac-hardware)
  * [Reproduction Schematic & PCB](#reproduction-schematic--pcb)
  * [Theory of Operation](#theory-of-operation)
  * [Battery](#battery)
  * [Upgrading 128K to 256K](#upgrading-to-256k)
  * [Model Compatibility](#model-compatibility)
* [Software](#software)
  * [BASIC](#basic)
<!-- 
  * [RAMDSK](#ramdsk)
    * [Installation](#installing-ramdsk)
    * [Usage](#using-ramdsk)
  * [NBOOT](#nboot)
  * [RAMPAC Inspector](#rampac-inspector)
  * [XOS-C](#xos-c)
  * [N-DKTR](#n-dktr)
  * [NODE-PDD-Link](#node-pdd-link)
  * [NDEXE](#ndexe)
  * [RAMPAC Diagnostic](#rampac-diagnostic)
-->
* [MiniNDP](#minindp)
<!--
  * [PCB & BOM](#minindp-pcb--bom)
  * [Cover](#minindp-cover)
-->

This repo documents the NODE Systems [DATAPAC](PICS/DATAPAC/), [rampac](PICS/rampac/), and a new clone, the [MiniNDP](#minindp).

The NODE Systems DATAPAC/rampac was a popular ram disk peripheral for TRS-80 / TANDY Models 100, 102, & 200 computers.

The schematic and PCB below documents the DATAPAC.

rampac is a smaller later version of the same device that uses fewer larger sram chips and replaces most of the discrete logic IC's with a single PLD, but functions exactly the same.

Here is some disorganized [INFO](software/) mostly gathered from the [M100SIG archive](https://github.com/LivingM100SIG/Living_M100SIG) and [club100](http://www.club100.org).

TLDR: To use the hardware, install [RAMDSK](software/RAMDSK), and what you get is a ram disk of 128k to 1M depending on model and installed ram.

![](PICS/DATAPAC/NODE_DATAPAC_256K_1.jpg)
![](PICS/DATAPAC/NODE_DATAPAC_256K_2.jpg)
![](PICS/DATAPAC/NODE_DATAPAC_256K_3.jpg)
![](PICS/DATAPAC/NODE_DATAPAC_256K_4.jpg)

![](PICS/rampac/20260724_155144534.JPG)
![](PICS/rampac/20260724_164507943.JPG)
![](PICS/rampac/20260724_154335102.JPG)

# Documentation
The original text file manual [RAMDSK.DO](ROM/100/RAMDSK.DO).  
The [NODE ROM](ROM) that came with the unit generates this file when formatting a device.

There are also some discussions in the [M100SIG archive](https://github.com/LivingM100SIG/Living_M100SIG) and Paul Globmans software on [club100](http://www.club100.org/library/libpg.html).  
Most of these are collected in [docs](docs).  
See also the docs for the various bits of [software](software).

Other References  
* "Database management with both the Node RAMPAC & DATAPAC."  
  Alspaugh, Ron - [Portable 100, Nov 90:8-11](https://archive.org/details/P100-Magazine/1990-11/page/8/)  
* "Node utility mini-extravaganza! Here are two special programs for Node Datapac/RAMPAC users."  
  Globman, Paul - [Portable 100, Dec 90:19-20](https://archive.org/details/P100-Magazine/1990-12/page/18/)  

# DATAPAC Hardware
## Reproduction Schematic & PCB
This is a new drawing but aims to reflect the original actual device as exactly as possible.  
It's meant to be a form of documentation or reference describing the original hardware as it was.  
For instance, the ungrounded inputs on the 161's, the inconsistent thickness of power traces, the fact that only 1 of the 2 bus VDD pins is connected, the VCC trace that almost touches one of the mounting screw heads, etc, are all exactly as in the original.  
(I added a fiber washer to that screw in my units after noticing that. The case is not connected to ground, but still...)  

For a historical reproduction version of the original PCB (minus the NODE copyright mark), see: NODE_DATAPAC_256K_historical_reproduction.kicad_pro

For a version of the original PCB that still uses the same components and fits in the same case, but cleans up a few things, see: NODE_DATAPAC_256K_bkw.kicad_pro

![](PCB/out/NODE_DATAPAC_256K_historical_reproduction.svg)

PCB TOP
![](PCB/out/NODE_DATAPAC_256K_historical_reproduction_top.jpg)

PCB BOTTOM
![](PCB/out/NODE_DATAPAC_256K_historical_reproduction_bottom.jpg)

The original PCB has no silkscreen. This image has silkscreen added to show where the components from the schematic go.
![](PCB/out/NODE_DATAPAC_256K_historical_reproduction_top_annotated.jpg)

<!--
## Updated Replacement PCB that fits the original case

Uses all the same through-hole parts, fits in the original enclosure, improves the trace routing a little, for example moving that VCC line away from that screw head, GND traces replaced by zone fills, thicker and all the same size vcc lines, decoupling caps, silkscreen.  
![](PCB/out/NODE_DATAPAC_256K_bkw.svg)
![](PCB/out/NODE_DATAPAC_256K_bkw.top.jpg)
![](PCB/out/NODE_DATAPAC_256K_bkw.bottom.jpg)
![](PCB/out/NODE_DATAPAC_256K_bkw.f.jpg)
![](PCB/out/NODE_DATAPAC_256K_bkw.b.jpg)
-->

## Theory of Operation
The circuit has 2 functions, SELECT-BLOCK and READ/WRITE-BYTE, controlled by the internal active-low signals /BLOCK and /BYTE.

The U4 HC138 monitors four lines from the bus, `/Y0` `(A)` `A8` `A9`, and based on that asserts either `/BLOCK` or `/BYTE` or neither.  
If neither /BLOCK nor /BYTE is asserted then the bus traffic has no effect on any of the other chips.

The 3 HC161 form a 0-1023 counter, setting SRAM address bits A0-A9.  
Call this the byte-number or byte-position counter or offset.

The HC374 sets SRAM address bits A10-A17 from the bus data bits AD0-AD7, and latches that value on its outputs until triggered to update to a new value.  
Call this the block-number or block selector.

The U5 HC138 converts 3 bits of the block-number into 1 of 8 chip-select to select 1 of 8 32K SRAM chips,  
and also monitors both /BYTE and RAMRST and disables all ram while either /BYTE or RAMRST is high.

----

### SELECT-BLOCK
When /BLOCK goes low:
* SRAM A0-A9 are reset to 0  (byte-position counter is reset to 0)
* BUS AD0-AD7 are copied to SRAM A10-A17  (bus data lines AD0-AD7 select a block-number)

When /BLOCK goes high:
* SRAM A10-A17 are held latched at whatever they were set to  (block-number is locked in until next /BLOCK)

----

### READ-BYTE / WRITE-BYTE
When /BYTE goes low:
* SRAM is enabled  (bus data lines AD0-AD7 read from or write to the current address in SRAM)

When /BYTE goes high:
* SRAM is disabled
* A0-A9 are incremented by 1 (byte-position, thus the current address in SRAM, is advanced to the next byte)

----

The byte-number and block-number combine to form the current address in SRAM at any given time.  

The device provides up to 256 blocks (8-bit block-number) of 1024 bytes each (10-bit byte-number).

The host computer first does a SELECT-BLOCK to select a block number from 0-255, then does READ-BYTE or WRITE-BYTE to read or write one byte of data at byte number 0 in that block, then repeats the BYTE operation up to 1023 more times to read or write up to all 1024 bytes in the block.  

If you read or write more than 1024 times without selecting a new block, the byte-number counter just rolls over to 0 again.

You can also mix reads and writes in the same block. Each read OR write advances the byte position the same way each time, regardless if the previous operation was a read or a write. For instance in order to skip over 64 bytes without modifying them and then start writing at the 65th byte, you would read-and-ignore 64 times and then start writing.

"ramdisk" is an appropriate term because the device actually does operate like a disk even though it has no brains or firmware. The block-select latch acts like a track or sector address, and the binary counter acts like a disk or tape head reading or writing a sequential stream of bytes.

Later versions of RAMPAC were offered with 384k or 512k by adding a second bank of up to 256k, and later versions of RAMDSK.CO know how to access the 2nd bank.

In 512K units, the extra 256K is accessed by the state of bus address line A10 during a SELECT-BLOCK operation.  
SELECT-BLOCK with BUS_A10 low accesses bank0, with BUS_A10 high accesses bank1.  
All other aspects are the same, so accessing bank0 on a a 512K device is the same as accessing the only bank on a 256K device.  Old software is still compatible with bank0 on new hardware, new software is still compatible with old hardware.

[What this all means from the host computer software side of things](https://github.com/bkw777/NODE_DATAPAC?tab=readme-ov-file#low-level-direct-access-using-only-basic)

## Battery
The original battery is no longer made, and the modern cross-reference is almost 2mm taller and does not fit inside the enclosure.

NODE Systems themselves used to perform an update to older units to replace the original rechargeable NiCD cell with a non-rechargeable lithium cell which was supposed to last about 5 years.

The change is simple and easy, and the parts are common. You just remove the old battery and the 200 ohm resistor, and replace them with a CR2032 holder and a diode. That's it. Both parts fit and solder right in the same locations where the old parts came out. Point the diode stripe away from the battery, just like the other diode that is right there next to it. Any standard diode will do. Schottky is not recommended because the reverse leakage is not good for a lithium cell. Another 1N4148 like the one that's already there is perfect.  
This should give at least 4 years of memory.  
(The original NiCD battery may have only lasted as little as a few months per charge according to a review in the archives. So the coin cell mod is not merely more conveniently available with current parts, it's an improvement.)

BEFORE
![](PCB/out/NODE_DATAPAC_256K_batt_mod_before.jpg)

AFTER
![](PCB/out/NODE_DATAPAC_256K_batt_mod_after.jpg)

STEPS
![](PCB/out/NODE_DATAPAC_256K_batt_mod_01.jpg)
![](PCB/out/NODE_DATAPAC_256K_batt_mod_02.jpg)
![](PCB/out/NODE_DATAPAC_256K_batt_mod_03.jpg)
![](PCB/out/NODE_DATAPAC_256K_batt_mod_04.jpg)


If you wish to keep using a rechargeable battery, then one suitable option is FL3/V80H. That is 3 16x5.8mm NiMH button cells in a flat in-line pack with wire leads. It fits perfectly in the space next to the ribbon cable. It needs to be secured with hot glue or foam mounting tape, and connected with wires run to the original battery location.  
![](ref/fl3v80h_placement.jpg)

The charging circuit is utterly basic, so do not connect any other type of battery except NiCD or NiMH.  
You can use any cell form factor and any larger or smaller mAh capacity, but must be 3.6v and only NiCD or NiMH chemistry.

## Upgrading to 256K
A 128k unit may be upgraded to 256k by just adding 4 more SRAM chips piggy-backed onto the existing chips.

The PCB has 4 DIP-28 footprints for the SRAM chips.  
Each DIP-28 footprint also has an extra via close to pin 20.

A 128k unit has a low-power 62256 installed in each footprint, and nothing connected to the via near pin 20.

To get 256k, a second set of chips are soldered piggyback on top of the first four.  
All pins except pin 20 (chip-select) are simply soldered to the chip below.  
Pin 20 is bent out and connected to the extra via on the pcb (with a short bit of wire to reach) and not connected to the chip below.  

No other parts or changes are needed to upgrade an existing 128k unit to 256k.

Any 62256 will work, but for old parts you want the low-power version for standby battery life.  
New parts already naturally have as low or lower standby current than the low-power versions of old parts even if they don't say "low power".  
Old standard: HM62256    70uA  
Old lowpower: HM62256LP  4uA  
Old lowpower: P51256SL   2uA  
New standard: AS6C62256  1uA

![](PICS/DATAPAC/PXL_20230908_214245735.jpg)


The same is true for rampac. Except:  
 - single 128k sram chip, ex: AS6C1008
 - chip-select is pin 30
![](PICS/rampac/20260724_152121677.JPG)

## Model compatibility  
Originally only North-American Models 100, 102, & 200 were ever supported.  
Kyotronic KC-85 and Olivetti M-10 are also supported today because RAMDSK has been disassembled and ported, and the assembly source means the international models could be added as well.  
The device is not compatible with NEC PC-8201/PC-8300.

Although the DATAPAC was primarily designed for Model 102 & 200, the crimp-on boxed male IDC pin header on the cable does not actually fit into a 200 without enlarging the opening around the bus connector on the 200. If you want to connect an original DATAPAC to a 200 without hacking up the 200's case or modifying the DATAPAC cable, you can build a small [adapter](ref/T200_adapter.jpg) by just soldering a [male](https://www.digikey.com/en/products/detail/sullins-connector-solutions/SBH11-PBPC-D20-ST-BK/1990068) & [female](https://www.digikey.com/en/products/detail/sullins-connector-solutions/SFH11-PBPC-D20-ST-BK/1990093) solder-type 2x20 boxed pin headers back to back. The solder box header does fit in the opening.
![](PICS/DATAPAC/does_not_fit_model_200.jpg)  
![](PICS/DATAPAC/T200_adapter_installed.jpg)

The DATAPAC case says "102/200", but it also works on Model 100, K85, and M10 with the right adapter cable. It's electrically compatible with everything but NEC.

For 100 & K85 the cable is just an IDC-DIP-40 aka "DIP-40 wire-to-board" connector and a standard 2x20 female IDC connector, both crimped onto a 40-pin ribbon cable about 8 inches long.  
[The Model 100 adapter part](https://github.com/bkw777/TRS-80_Disk_Video_Interface_Cable/blob/main/README.md#part-3---model-100-adapter) of this [3-part Disk/Video Interface Cable](http://tandy.wiki/Disk/Video_Interface:_Cable) is the same thing.

For Olivetti M-10 the cable is even simpler, a standard female to female IDC 40-pin ribbon cable.

[MiniNDP](#minindp) fits directly on both 102 and 200 with no adapter or cable, or M10 with a female-female ribbon cable at least 5 inches long.

[MiniNDP_u1M](#minindp-u1m---for-model-100-or-kyotronic-kc-85) fits directly in the bus socket of 100 or K85 with no adapter or cable, and the cover can even be closed over it.

# Software

 - [NODE ROM](ROM)  
 - [RAMDSK.CO](software/RAMDSK)  
 - [XOS-C](http://www.club100.org/library/libpg.html) ("sort of an OS" for the Model 200, does not require a rampac but leverages one if available. [Several of the NODE utils from the M100SIG require XOS-C.](software/Requires_XOS-C/))
 - [other](software)  

Originally these shipped with an [OPTION ROM](ROM) from NODE called RAMDISK.

Later, Paul Globman wrote [RAMDSK.CO](software/RAMDSK), and that was eventually licensed by NODE and shipped with new units.  

Later still, RAMDSK was updated with 2 changes:  
 - automatic repair of a corrupted format stamp on start-up  
 - support for 512k in 2 banks of 256k (RAMPAC & EXTRAM)

Recently, RAMDSK has been updated yet further:  
- disassembled to produce assembly source  
- ported to Kyotronic KC-85  
- ported to Olivetti M-10  
- support for 4 banks  
- format on demand from Label button  
- added safety confirmation to format & repair  
- removed dead code

Some other software culled from the [M100SIG archive](https://github.com/LivingM100SIG/Living_M100SIG) and [Club100](https://www.club100.org) are collected here in the [software](software) directory.  

## BASIC
How to access the hardware from BASIC.

### High level file operations using CALLable machine language routines
See [RAMDSK.DO](ROM/100/RAMDSK.DO) for the NODE ROM routines.  
See [RAMDSK.TIP](software/RAMDSK/RAMDSK.TIP) for the RAM100.CO/RAM200.CO routines.  
But note, the addresses in RAMDSK.TIP are incorrect for RAMDSK v2. We don't have a copy of RAMDSK v1 for 100 but we do for 200. So you can't follow those directions exactly except with RAMDSK v1 on 200.  

The latest RAMDSK built from the new source includes *.calls files that give the current addresses to the routines in those binaries, but actually using them has not been tested.

### Low level direct access using only BASIC
There are two low level operations that you use to access the device,  
BLOCK and BYTE, and each of those has two variations, for four total ops.

Select a BLOCK from BANK 0  
`OUT 129,n`  
Selects block# **n** (0-255) in bank 0, and resets the byte position to 0.

Select a BLOCK from BANK 1  
`OUT 133,n`  
Selects block# **n** (0-255) in bank 1, and resets the byte position to 0.

Read a BYTE  
`INP(131)`  
Reads the byte at the current byte position, and advances the byte position by one.

Write a BYTE  
`OUT 131,n`  
Writes the value **n** (0-255) to the current byte position, and advances the byte position by one.

The first read or write after selecting a block# applies to byte #0 of that block.  
The byte position advances by one after each read or write, so the next read or write will be byte #1, then byte #2, etc up to 1024.  
If you read or write more than 1024 times without selecting some other block, the byte position just rolls over to 0 again.

The position counter advances the same whether reading or writing.

Since the device can only read or write a single unsigned byte at a time, it's most efficient to use integer variables.  
Use the % suffix or DEFINT: `B%=INP(131)` or `DEFINT B : B=INP(131)`

The general sequence is always:  
1 - select a bank+block  
2 - read/write byte 0-1024 times

To seek to an arbitrary offset before reading or writing, read-and-ignore that many bytes.

For instance, in RBOOT.DO, to skip over the first 16 bytes of the block, it does `FORA=0TO15:N=INP(131):NEXT`  
N is not actually used, it's just reading 16 times and ignoring the data. This just advances the byte position counter to get from byte #0 past the 10-byte RAMDSK header and 6-byte .CO header to the start of the .CO executable data.

Examples

Select bank 0 block 0  
`OUT129,0`

read a byte, which will be byte #0 of this block  
`INP(131)`

Read and print the ascii of all the bytes in bank 0 block 2.  
(this will mess up the display from control bytes if there is a binary .CO file in this block)
```
10 OUT 129,2
20 FOR I=0 TO 1023
30 PRINT CHR$(INP(131));
40 NEXT
```

Do the same but in bank 1  
change line 10 to:  
`10 OUT 133,2`

Manually repair the first two bytes of block 0 to mark the bank as being formatted without touching any of the data.  
This means:
1. Select bank0 block0  
2. write one byte, value 64  
3. write one byte, value 4

`OUT129,0:OUT131,64:OUT131,4`

(BTW you usually don't need to do this because RAMDSK.CO will do it for you.)

# MiniNDP

New design that functions the same as DATAPAC/rampac.

1 megabyte in 4 banks of 256k.

How to access all 4 banks:  
Select bank 0, block N: `OUT 129,N`  
Select bank 1, block N: `OUT 133,N`  
Select bank 2, block N: `OUT 137,N`  
Select bank 3, block N: `OUT 141,N`

Everything else works the same as normal DATAPAC/rampac.

## MiniNDP EZ1M - For Model 102 and 200

Unlike the original DATAPAC, this actually fits into the bus port on the Model 200 without having to hack it's case.

![](ref/MiniNDP_EZ1M.a.jpg)
![](ref/MiniNDP_on_102.jpg)
![](ref/MiniNDP_on_200.jpg)
![](PCB/out/MiniNDP.jpg)
![](PCB/out/MiniNDP.2.jpg)
![](PCB/out/MiniNDP.top.jpg)
![](PCB/out/MiniNDP.bottom.jpg)
![](PCB/out/MiniNDP.svg)
[MiniNDP.bom.csv](PCB/out/MiniNDP.bom.csv)

BOM: [DigiKey](https://www.digikey.com/short/m4h7bmh0)  
[MiniNDP EZ1M_16 PCB @ OSHPark](https://oshpark.com/shared_projects/7Jpm6F6c)  
Cover: [MiniNDP_Cover.stl](COVER/out/MiniNDP_Cover.stl) -- [Cover @ JawsTec](https://shop.jawstec.com/3d-printed-minindp-cover_p658.php)  
[Both PCB & Cover @ PCBWAY](https://www.pcbway.com/project/shareproject/MiniNDP_mini_Node_DataPac_d08018c4.html)  

## MiniNDP u1M - For Model 100 or Kyotronic KC-85

![](ref/MiniNDP_u1M.a.jpg)  
![](ref/MiniNDP_u1M.b.jpg)  
![](ref/MiniNDP_u1M.c.jpg)  
![](PCB/out/MiniNDP_u1M.1.jpg)  
![](PCB/out/MiniNDP_u1M.2.jpg)  
![](PCB/out/MiniNDP_u1M.3.jpg)  
![](PCB/out/MiniNDP_u1M.top.jpg)  
![](PCB/out/MiniNDP_u1M.bottom.jpg)  
![](PCB/out/MiniNDP_u1M.svg)  

BOM: [MiniNDP_u1M.bom.csv](PCB/out/MiniNDP_u1M.bom.csv)  
[MiniNDP u1M_038 PCB @ OSHPark](https://oshpark.com/shared_projects/XwUDgfQu)

## MiniNDP M10 - For Olivetti M-10

![](PICS/M10/M10_disassembled.jpg)  
![](PICS/M10/M10_installed_uncovered.jpg)  
![](PICS/M10/M10_installed_with_cover.jpg)  
![](PCB/out/MiniNDP_M10.jpg)  
![](PCB/out/MiniNDP_M10.2.jpg)  
![](PCB/out/MiniNDP_M10.top.jpg)  
![](PCB/out/MiniNDP_M10.bottom.jpg)  
![](PCB/out/MiniNDP_M10.svg)  

BOM: [MiniNDP_M10.bom.csv](PCB/out/MiniNDP_M10.bom.csv)  
[MiniNDP M10_36 PCB @ OSHPark](https://oshpark.com/shared_projects/cUKKxHAa)  
Cover for M10: [MiniNDP_Cover_M10.stl](COVER/out/MiniNDP_Cover_M10.stl) -- [M10 Cover @ JawsTec](https://shop.jawstec.com/3d-printed-minindpm10-cover_p657.php)

## [Other Versions](MiniNDP_variants.md)  
[SL1M](MiniNDP_variants.md#sl1m---slim-1-meg) - slim 1 meg, all thin chips to make a thin card  
[T512](MiniNDP_variants.md#t512---tsop-128k256k512k) - TSOP 128k/256k/512k  
[EZ512](MiniNDP_variants.md#ez512---easy-build-512k) - SOIC 512k  
<!-- ["OG"](MiniNDP_variants.md#minindp-og) - 128k-512k, most like the original DATAPAC schematic, more parts and more difficult, but the parts are more common  -->
