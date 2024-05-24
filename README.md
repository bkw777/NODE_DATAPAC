# NODE Systems DATAPAC
* [Documentation](#documentation)
* [DATAPAC Hardware](#datapac-hardware)
  * [Reproduction Schematic & PCB](#reproduction-schematic--pcb)
  * [Theory of Operation](#theory-of-operation)
  * [Battery](#battery)
  * [Model Compatibility](#model-compatibility)
* [RAMPAC Hardware](#rampac-hardware)
* [Software](#software)
  * [BASIC](#basic)
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
* [MiniNDP](#minindp)
  * [PCB & BOM](#minindp-pcb--bom)
  * [Enclosure](#minindp-enclosure)
  * [WIP/Experiments](#works-in-progress)

This repo documents the NODE Systems DATAPAC, RAMPAC, and a new clone, the [MiniNDP](#minindp).

The NODE Systems DATAPAC was a popular ram disk peripheral for TRS-80 / TANDY Models 100, 102, & 200 computers.

Later versions of the same device were called RAMPAC. They functioned the same as DATAPAC and used the same software, just in a much smaller form factor.

The schematic and PCB below documents the DATAPAC from examining 2 units. If I ever aquire a RAMPAC, I'll add that.

Here is some disorganized [INFO](software/) mostly gathered from the [M100SIG archive](https://github.com/LivingM100SIG/Living_M100SIG) and [club100](http://www.club100.org).

TLDR: To use the hardware, install [RAMDSK](#ramdsk), and what you get is a ram disk of 128k to 512k depending on model and installed ram.

The printing on the DATAPAC enclosure says 256k, and the circuitry and parts are all there to support 256k, but my two units only had 128k installed.  
The PCB has footprints for four 32k sram chips (62256 equivalent), for a total of 128k.  
To get 256k, a second set of chips are soldered piggyback on top of the first four, each with pin 20 bent out and connected to the pcb separately, and all other pins connected to the chip below.  
No other parts or changes are needed to upgrade an existing 128k unit to 256k.  

![](ref/NODE_DATAPAC_256K_1.jpg)
![](ref/NODE_DATAPAC_256K_2.jpg)
![](ref/NODE_DATAPAC_256K_3.jpg)
![](ref/NODE_DATAPAC_256K_4.jpg)

# Documentation
The original manual does not seem to be scanned or archived anywhere.

All we have today is a few bits of info from discussions in the [M100SIG archive](https://github.com/LivingM100SIG/Living_M100SIG) and Paul Globmans software on [club100](http://www.club100.org/library/libpg.html).  
Some of these are collected in [docs](docs).  
See also the docs for the various bits of [software](software).

A few of those documents say that the device originally shipped with the user manual pre-loaded onto the DATAPAC as a 12k text file, along with at least one BASIC program.  
If/when the battery died in the device and all data was lost, the Format operation in the option rom would also re-create the text file.  

Neither the option rom nor the text file are archived anywhere that I have been able to find yet.

If anyone has a RAMPAC, they probably also have the option rom, and the original manual could be recovered from that. Maybe one will turn up some day.

The magazine article by Paul Globman below says that the rom was called RAM+, and there IS an archived option rom image available called RAM+, but it is for an entirely different type of device, the [PCSG / Cryptronics RAM Expansion](http://tandy.wiki/PCSG_/_Cryptronics_RAM_Expansion) which provides RAM, like the [PG Designs](http://tandy.wiki/PG_Designs_M100_RAM_Expansion) or [QUAD](https//github.com/bkw777/reQUAD), not a RAM DISK. These devices all replace the internal 32k where the ram files live and where programs run etc. The DATAPAC/RAMPAC does something entirely different, see [Theory of Operation](#theory-of-operation). It is possible the NODE rom was also called RAM+, but PCSG RAM+ definitely does not drive the DATAPAC or RAMPAC.

Other References  
* "Database management with both the Node RAMPAC & DATAPAC."  
  Alspaugh, Ron - [Portable 100, Nov 90:8-11](https://archive.org/details/P100-Magazine/1990-11/page/8/)  
* "Node utility mini-extravaganza! Here are two special programs for Node Datapac/RAMPAC users."  
  Globman, Paul - [Portable 100, Dec 90:19-20](https://archive.org/details/P100-Magazine/1990-12/page/18/)  

# DATAPAC Hardware
## Reproduction Schematic & PCB
This is a new drawing but aims to reflect the original actual device as exactly as possible.  
It's meant to be a form of documentation or reference describing the original hardware as it was.  
For instance, the inconsistent thickness of power traces, and the 5V power trace that almost touches one of the mounting screw heads, are both exactly as in the original.  
(I added a fiber washer to that screw in my units after noticing that. The case is isolated, not connected to ground, but still...)
![](PCB/out/NODE_DATAPAC_256K_historical_reproduction.svg)

PCB TOP
![](PCB/out/NODE_DATAPAC_256K_historical_reproduction_top.jpg)

PCB BOTTOM
![](PCB/out/NODE_DATAPAC_256K_historical_reproduction_bottom.jpg)

The original PCB has no silkscreen. This image has silkscreen added to show where the components from the schematic go.
![](PCB/out/NODE_DATAPAC_256K_historical_reproduction_top_annotated.jpg)

## Theory of Operation
The circuit has 2 functions, SELECT-BLOCK and READ/WRITE-BYTE, controlled by the internal signals /BLOCK and /BYTE.

The U4 HC138 monitors four lines from the bus, `/Y0` `(A)` `A8` `A9`, and based on that asserts either `/BLOCK` or `/BYTE` or neither.  
If neither /BLOCK nor /BYTE is asserted then the bus traffic has no effect on any of the other chips.

The 3 HC161 form a 0-1023 counter, setting SRAM address bits A0-A9.  
Call this the byte-number or byte-position counter.

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

It's not really limited to 1024 reads/writes. If you read or write more than 1024 times total without selecting a new block, the byte-number counter just rolls over to 0 again.

You can also mix reads and writes in the same block. Each read OR write advances the byte-number the same way each time, regardless if the previous operation was a read or a write. For instance in order to skip over 64 bytes without modifying them and then start writing at the 65th byte, you would read-and-ignore 64 times and then start writing.

It's called a ramdisk because the device actually does operate like a disk even though it has no brains or firmware. The block-select latch acts like a track or sector address, and the binary counter acts like a disk or tape head reading or writing a sequential stream of bytes.

Later versions of RAMPAC were offered with 384k or 512k by adding a second bank of up to 256k, and later versions of RAMDSK.CO know how to access the 2nd bank.

The extra 256K is accessed by the state of bus address line A10 during a SELECT-BLOCK operation.  
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


If you wish to keep using a rechargeable battery, then a suitable option is FL3/V80H. That is 3 16x5.8mm NiMH button cells in a flat in-line pack with wire leads. It fits perfectly in the space next to the ribbon cable. It needs to be secured with hot glue or foam mounting tape, and connected with wires run to the original battery location.  
![](ref/fl3v80h_placement.jpg)

The charging circuit is utterly basic, so do not connect any other type of battery except NiCD or NiMH.  
You can use any cell form factor and any larger or smaller mAh capacity, but must be 3.6v and only NiCD or NiMH chemistry.

## Model compatibility
Only Models 100, 102, & 200 were ever supported.

The device is probably hardware compatible with the Olivetti M-10 and Kyotronic KC-85, though RAMDSK was never ported to them.

The device is not compatible with the NEC PC-8201/PC-8300 at all.

### Model 200
The connector on the DATAPAC [does not actually fit in a Model 200](ref/does_not_fit_model_200.jpg) without cutting the opening wider around the bus connector on the 200.

The only connector that fits in a 200 without hacking on the 200s case is a [solder-type 2x20 male box header](https://www.digikey.com/en/products/detail/sullins-connector-solutions/SBH11-PBPC-D20-ST-BK/1990068),
 which could be soldered back to back with the [female version](https://www.digikey.com/en/products/detail/sullins-connector-solutions/SFH11-PBPC-D20-ST-BK/1990093),
 to make an [adapter](ref/T200_adapter.jpg) to allow [connecting to a 200](ref/T200_adapter_installed.jpg) without having to damage the 200's case.

### Model 100
The case says "102/200", but it actually works on Model 100 also. It needs an adapter cable, but the cable is simple. It's just a "wire-to-board" IDC-DIP-40 crimp-on DIP connector and a standard 2x20 female IDC connector, both crimped on to a 40-pin ribbon cable about 8 inches long.  
[The Model 100 part](https://github.com/bkw777/TRS-80_Disk_Video_Interface_Cable/blob/main/README.md#part-3---model-100-adapter) of this [3-part cable for the Disk/Video Interface](http://tandy.wiki/Disk/Video_Interface:_Cable) is exactly the same thing.

# RAMPAC Hardware
About all we can say currently is that we know it was sold in 128k, 256k, 384k, and 512k capacities, and was "about 2 inches square".

We can say how it's banks worked, because we can look at RAMDSK and see what it wants, and verified by the fact that MiniNDP 512 actually works.  

MiniNDP schematic is essentially just a clone of the DATAPAC schematic with the coin cell mod applied and the multiple ram chips replaced by a single big one. RAMPAC schematic might have been different.

# [Software](software)

Originally these shipped with an option rom from NODE (written by Travelling Software), which does not seem to be archived anywhere.  
Later, each unit was also shipped with a copy of RAMDSK licensed from Paul Globman.

Today all we have is RAMDSK, but it claims to do everything that the option rom did. Although it does not reproduce the pre-loaded manual and utility files which the option rom did.

Some software culled from the M100SIG archive and Club100 are collected here in the [software](software) directory.  
Much of that software actually requires the original option rom, which is not available. Some of that could possibly be converted to work with RAMDSK instead of the rom by translating the call addresses per the RAMDSK.TIP file.

## BASIC
How to access the hardware from BASIC.

### High level file operations using CALLable machine language routines
See [RAMDSK.TIP](software/RAMDSK/RAMDSK.TIP)

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
And actually, it's not "up to 1024", it wraps around to 0 of the same block again if you keep reading or writing more than 1024 times without selecting some other block.

Since the device can only read or write a single byte at a time, it's most efficient to use integer variables with the % suffix, ie, use B%=INP(131) instead of B=INP(131) etc where possible.

The general sequence is always:  
1 - select a bank+block  
2 - read/write byte 0-1024 times

If you need to read or write some arbitrary set of bytes from the middle of a block, you must still read (or write) all the bytes from 0 up to the desired offset.  
For instance, in RBOOT.DO, to skip over the first 16 bytes of the block it does `FORA=0TO15:N=INP(131):NEXT`  
N is not actually used, it's just reading 16 times and ignoring the data. This just advances the byte position counter to get from byte #0 up to the start of the bytes that it actually wants.

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

(BTW you usually don't need to do that manually because RAMDSK.CO will do it for you if you just answer "Y" at the "Fix?" prompt.)

## RAMDSK
The "driver" software for the device is [RAMDSK](software/RAMDSK/)

RAMDSK claims to provide the same functionality as NODEs option rom, and even NODE themselves later licensed RAMDSK and included a copy with each unit.  
Even the rom calls from the option rom have equivalents in RAMDSK, though at different addresses. (see [RAMDSK.TIP](software/RAMDSK/RAMDSK.TIP))  
One thing RAMDSK does not do which the original option rom did, is re-create the user manual text file as part of the Format operation.

### Installing RAMDSK
Archived docs mention an 8 line BASIC program called BOOT that could be manually typed in to BASIC to bootstrap a copy of RAMDSK from a RAMPAC after a cold start.

That program does not seem to be archived anywhere, so in it's place there is `RBOOT` and `NBOOT` below which are new.  
This only works after a copy of RAMDSK has been copied to the RAMPAC.

To get RAMDSK installed the first time, copy RAM100.CO or RAM200.CO to the 100 or 200.

The most convenient way is to use a TPDD [client](http://tandy.wiki/TPDD_client) & [server](http://tandy.wiki/TPDD_server) to copy the file, then [adjust HIMEM](https://bitchin100.com/wiki/index.php?title=Loading_a_typical_CO_file) to run it.  

But if you don't already have something like a REX# with a TS-DOS option rom image, a more self-contained option is a BASIC loader:  
[software/RAMDSK/RAM100/RAM100.DO](software/RAMDSK/RAM100/RAM100.DO) for Model 100/102  
[software/RAMDSK/RAM200/RAM200.DO](software/RAMDSK/RAM200/RAM200.DO) for Model 200  

To bootstrap the BASIC loader from a PC running Windows:  
Install [tsend](https://github.com/bkw777/tsend)  
Then: `C:> tsend.ps1 -file RAM100.DO`

To bootstrap the BASIC loader from a PC running Linux, MACOS, FreeBSD, any unix, Cygwin/MSYS2:  
Install [dl2](https://github.com/bkw777/dl2)  
Then: `$ dl -v -b RAM100.DO`  

Another option for mac/linux, [pdd.sh](https://github.com/bkw777/pdd.sh) also has a bootstrap function and does not require you to compile anything.

Once you have RAMDSK installed, if you save a copy to the RAMPAC as the very first file after a fresh format, then in the future you can re-install RAMDSK from the RAMPAC itself after a cold reset without needing another computer or TPDD drive by manually typing in a short BASIC program.

These are optimized to tetris-pack into the fewest possible 40-column lines, not to be the most efficient code possible, please excuse the inexcusable IF and math inside the byte read loop. :)

RBOOT for Model 100  
[software/RAMDSK/RAM100/RBOOT.100](software/RAMDSK/RAM100/RBOOT.100)  
for [software/RAMDSK/RAM100/RAM100.CO](software/RAMDSK/RAM100/RAM100.CO)
```
1 CLEAR0,61558:T=61558:E=62957:OUT129,2
2 FORA=0TO15:N=INP(131):NEXT:FORA=TTOE
3 POKEA,INP(131):IFA=T+1007THENOUT129,1
4 ?".";:NEXT:SAVEM"RAM100",T,E,T
```

RBOOT for Model 200  
[software/RAMDSK/RAM200/RBOOT.200](software/RAMDSK/RAM200/RBOOT.200)  
for [software/RAMDSK/RAM200/RAM200.CO](software/RAMDSK/RAM200/RAM200.CO)
```
1 CLEAR0,59715:T=59715:E=61101:OUT129,2
2 FORA=0TO15:N=INP(131):NEXT:FORA=TTOE
3 POKEA,INP(131):IFA=T+1007THENOUT129,1
4 ?".";:NEXT:SAVEM"RAM200",T,E,T
```

RBOOT for Model 200, booting from Bank1  
If you want to get fancy, you could support both model 100 and model 200 at the same time on the same RAMPAC by putting a copy of RAM100.CO in Bank0 and a copy of RAM200.CO in Bank1, and modify RBOOT.200 to read from bank1 instead of bank0 by just changing `OUT129` to `OUT133`.
```
1 CLEAR0,59715:T=59715:E=61101:OUT133,2
2 FORA=0TO15:N=INP(131):NEXT:FORA=TTOE
3 POKEA,INP(131):IFA=T+1007THENOUT133,1
4 ?".";:NEXT:SAVEM"RAM200",T,E,T
```

### Using RAMDSK
Usage is mostly pretty self-explanatory.

The F1-Bank button switches between 2 banks of 256k, and is only functional on a RAMPAC that has more than 256k.

[It is fairly common for the first byte to get corrupted](software/RAMDSK/RAMPAC.001) ...Don't Panic(tm)  
You could do the manual BASIC one-liner `OUT129,0:OUT131,64:OUT131,4`, but RAMDSK also has a first-byte-fixer built-in.  
If you get the "Format RAM-Disk?" prompt on power-on, just answer "N".  
Then it will ask "Fix?", answer "Y".

## [NBOOT](software/NBOOT/)
Just for reference, to boot some other CO instead of RAMDSK,  
here  is a more flexible and generic bootstrapper for any .CO file up to 2038 bytes.  
* Reads the filename and start/length/exec values from the file itself  
* Works on any .CO file that fits in 2 blocks  
* Works on both Model 100 and 200
```
1 CLEAR32,59000:CLS:P=131:OUT129,2
2 FORA=0TO9:F$=F$+CHR$(INP(P)):NEXT
3 GOSUB8:T=N:GOSUB8:E=T+N-1:GOSUB8:X=N
4 F$=LEFT$(F$,6):N=T+1007:FORA=TTOE
5 ?@0,A:POKEA,INP(P):IFA=NTHENOUT129,1
6 NEXT:?@0,"Installed "F$:?"Type:"
7 ?"CLEAR 0,"T":NEW":SAVEMF$,T,E,X:END
8 N=INP(P)+INP(P)*256:RETURN
```

## RAMPAC Inspector
[RAMPAC Inspector](software/RPI)

Smaller than RD or N-DKTR, no machine code or calls, doesn't require the NODE ROM or RAMDSK, supports banks / all 512k.  
Just displays the raw data, no parsing or interpretation of the directory/file structures created by RAMDSK.CO etc.

## XOS-C
[XOS-C](http://www.club100.org/library/libpg.html) is sort of an OS for the Model 200.  
XOS-C does not require a RAMPAC, but leverages one if available.  
[Several of the NODE utils from the M100SIG require XOS-C.](software/Requires_XOS-C/)

## N-DKTR
[N-DKTR](software/N-DKTR/)

## NODE-PDD-Link
[NODE-PDD-Link](software/NODE-PDD-Link/)

## NDEXE
[NDEXE](software/NDEXE/)

## RAMPAC Diagnostic
[Rampac_Diagnostic/](software/Rampac_Diagnostic/)

<!-- 
## New Replacement PCB
Uses all the same through-hole parts, fits in the original enclosure, improves the trace routing a little, for example moving that VCC line away from that screw head, gnd traces replaced by pours, thicker and all the same size vcc lines, decoupling caps, silkscreen.  
There is not much reason to build this instead of a MiniNDP. Even if you had an original DATAPAC that was corroded by the battery, it would be easier and more history-preserving to just repair the corroded traces with bodge wires since all the parts are so big and simple.
![](PCB/out/NODE_DATAPAC_256K_bkw.svg)
![](PCB/out/NODE_DATAPAC_256K_bkw.top.jpg)
![](PCB/out/NODE_DATAPAC_256K_bkw.bottom.jpg)
![](PCB/out/NODE_DATAPAC_256K_bkw.f.jpg)
![](PCB/out/NODE_DATAPAC_256K_bkw.b.jpg)
-->

# MiniNDP

![](PCB/out/MiniNDP_512.svg)
![](PCB/out/MiniNDP_512.top.jpg)
![](PCB/out/MiniNDP_512.bottom.jpg)
![](PCB/out/MiniNDP_512.f.jpg)
![](PCB/out/MiniNDP_512.b.jpg)

Functions the same as DATAPAC / RAMPAC. Essentially the same circuit, just with a single 512k ram chip instead of 8 32k chips, surface mount parts instead of through hole, and directly attached instead of connected by a cable.

Has 512k in 2 banks of 256k like the final versions of RAMPAC.

The connector fits in a Model 200 without having to modify the 200.

The diode on RAMRST is copied from a user mod found on a DATAPAC. It appears to be intended to prevent a battery drain on the host computer while the DATAPAC is left connected to the host while the host is turned off.

Installed on a TANDY 102
![](ref/MiniNDP_on_102.jpg)

Installed on a TANDY 200
![](ref/MiniNDP_on_200.jpg)

(low profile version with CR2016 instead of CR2032)
![](ref/MiniNDP_and_cover.jpg)
![](ref/MiniNDP_and_cover.back.jpg)
![](ref/MiniNDP_and_cover.assembled.jpg)
![](ref/MiniNDP_bank0.jpg)
![](ref/MiniNDP_bank1.jpg)

The 512k board also still supports 256k and 128k. There is no real reason to do this now but if you wanted to install a 256k (AS6C2008A) 
or 128k (AS6C1008, IS62C1024, etc) SRAM, omit the U8 part (the 1G79), and solder-blob U8 pads 4 & 5 together. Those two pads are modified to also be a solder-jumper for this purpose.

## MiniNDP PCB & BOM
BOM [DigiKey](https://www.digikey.com/short/q4mh3b52)  
PCB <!-- [OSHPark](https://oshpark.com/shared_projects/), -->[PCBWAY](https://www.pcbway.com/project/shareproject/MiniNDP_mini_Node_DataPac_d08018c4.html), or there is a gerber zip in [releases](../../releases/)

For the PCB, you want ENIG copper finish so that the battery contact is gold. PCBWAY and JLCPCB are a bit expensive for ENIG. Elecrow is cheaper, and OSHPark is always ENIG.  

You can optionally make a thinner card by replacing BT1 and C1 with lower profile alternatives.  
|BATTERY|estimated life|holders that fit the footprint|height|C1 Capacitor|
|---|---|---|---|---|
|CR2032|7.5 years|[Keystone 3034](https://www.digikey.com/short/rmwrc5hv)<br>TE/Linx BAT-HLD-001-SMT<br>Adam Tech BH-67<br>MPD BK-912|4.1mm|[TAJC227K010RNJ](https://www.digikey.com/en/products/detail/kyocera-avx/TAJC227K010RNJ/1833766?s=N4IgTCBcDaICoEEBSBhMYDsBpADARhwCUA5JEAXQF8g) - 6032-28 220u 10v|
|CR2016|3 years|[Keystone 3028](https://www.digikey.com/short/m93fmzb2)|1.7mm|[TLJW157M010R0200](https://www.digikey.com/en/products/detail/kyocera-avx/TLJW157M010R0200/929982?s=N4IgTCBcDaICoBkBSB1AjAVgOwFkAMaeASnmHniALoC%2BQA) - 6032-15 150u 10v|

CR2032 height
![](PCB/out/MiniNDP_256_CR2032.jpg)

CR2016 height (nominally a CR2012 holder, but can take a CR2016)  
![](PCB/out/MiniNDP_256_CR2016.jpg)

## MiniNDP Enclosure
There are a few versions of printable cover in the [enclosure](enclosure) directory.  
There is OpenSCAD source and exported STL for a snap-on cover, with both a thick version for a card with CR2032 holder, and a thin version for a card with a CR2016 holder.  
There is also an STL for a slip cover by F. D. Singleton.  
The printable STLs are in [releases](../releases).

You can get both the PCB and enclosure at the same time from Elecrow by submitting the gerber zip and the enclosure stl, and it arrives in under 2 weeks even with the cheapest economy shipping option.

## Works in Progress
Experimental 1-meg version - Testing still pending.
```
OUT 129,N = select bank 0 block N
OUT 133,N = select bank 1 block N
OUT 137,N = select bank 2 block N
OUT 141,N = select bank 3 block N
```
![](PCB/out/MiniNDP_1M.svg)  
![](PCB/out/MiniNDP_1M.top.jpg)  
![](PCB/out/MiniNDP_1M.bottom.jpg)  
![](PCB/out/MiniNDP_1M.jpg)  

Alternative 1M "B" version  
![](PCB/out/MiniNDP_1M_B.top.jpg)  
![](PCB/out/MiniNDP_1M_B.bottom.jpg)  
![](PCB/out/MiniNDP_1M_B.jpg)  

new parts  
[AS6C8008 1Mx8 5v parallel sram](https://www.digikey.com/short/p7h3mj33)  
[FCT821 10-bit latch](https://www.digikey.com/short/74fmpjp2) (basicallly a 10-bit version of HC374 or HC574)

Alternative 512K "B" version.
![](PCB/out/MiniNDP_512_B.svg)  
![](PCB/out/MiniNDP_512_B.top.jpg)  
![](PCB/out/MiniNDP_512_B.bottom.jpg)  
![](PCB/out/MiniNDP_512_B.jpg)  
