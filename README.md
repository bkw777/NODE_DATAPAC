# Reproduction of Node Systems DATAPAC

The NODE Systems DATAPAC and RAMPAC were a popular ram disk peripheral for TRS-80 / TANDY Models 100, 102, & 200 computers.

RAMPAC was a later device that functioned the same as DATAPAC, even using the same software to run it, just in a new smaller form factor.

This schematic and PCB documents the DATAPAC. If I ever aquire a RAMPAC, I'll add that.

Here is some disorganized [INFO](software/) mostly gathered from the [M100SIG archive](https://github.com/LivingM100SIG/Living_M100SIG) and [club100](http://www.club100.org).

TLDR: To use the hardware, install [RAMDSK.CO](software/RAMDSK/), and what you get is a 128K or 256K ram disk.

The enclosure printing says 256K, and the circuit is all there to support 256K, but my 2 units only had 128K installed.  
There are footprints on the PCB for 4 x 32K sram chips, for a total of 128K.  
To get 256K, a 2nd set of 4 chips are piggybacked on top of the first 4, with only pin 20 bent out and connected to the pcb instead of to the chip below.  
No other parts or changes are needed.

![](REF/NODE_DATAPAC_256K_1.jpg)
![](REF/NODE_DATAPAC_256K_2.jpg)
![](REF/NODE_DATAPAC_256K_3.jpg)
![](REF/NODE_DATAPAC_256K_4.jpg)

## Reproduction Schematic & PCB
This is a new drawing but aims to reflect the original actual device as exactly as possible.  
It's meant to be a form of documentation or reference describing the original hardware as it was.  
![](PCB/out/NODE_DATAPAC_256K_historical.svg)

PCB TOP
![](PCB/out/NODE_DATAPAC_256K_historical_top.jpg)

PCB BOTTOM
![](PCB/out/NODE_DATAPAC_256K_historical_bottom.jpg)

The real PCB has no silkscreen. This image has silkscreen added to show where the components from the schematic go.
![](PCB/out/NODE_DATAPAC_256K_historical_top_annotated.jpg)


<!-- 
## New Schematic & PCB
This aims to be a functional replacement and will change over time to use newer parts.  
Currently still uses all the same main chips as the original. Changes so far are that many of the traces are rerouted, coin cell battery, decoupling caps, ground pours, silkscreen.  
Pending TODO items: Change the BUS connection to use a removable cable, and flip the pinout so that the computer end of the cable can use a connector that actually fits in a 200.
![](PCB/out/NODE_DATAPAC_256K_bkw.svg)
![](PCB/out/NODE_DATAPAC_256K_bkw.top.jpg)
![](PCB/out/NODE_DATAPAC_256K_bkw.bottom.jpg)
![](PCB/out/NODE_DATAPAC_256K_bkw.f.jpg)
![](PCB/out/NODE_DATAPAC_256K_bkw.b.jpg)
-->

## Battery
The original battery is no longer made. The modern replacement is almost 2mm taller and does not fit inside the enclosure.

NODE Systems themselves used to perform an update to older units to replace the original rechargeable NiCD cell with a non-rechargeable lithium cell which was supposed to last about 5 years.

The change is simple and easy, and the parts are common. You just remove the old battery and the 200 ohm resistor, and replace them with a CR2032 holder and a diode. That's it. Both parts fit and solder right in the same locations where the old parts came out. Point the diode stripe away from the battery, just like the other diode that is right there next to it. Any kind of diode will do. Another 1N4148 like the other one that's already there is perfect.
This should give about 4 years of memory.  
(The original battery may have only lasted a number of months according to a review in the archives. So the coin cell mod is definitely an improvement as well as being available.)

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
![](REF/fl3v80h_placement.jpg)

## Documentation
The original manual does not seem to be scanned or archived anywhere.

All we have today is a few bits of info from discussions in the [M100SIG archive](https://github.com/LivingM100SIG/Living_M100SIG) and Paul Globmans software on [club100](http://www.club100.org/library/libpg.html).  
Some of these are collected [here](software).

A few of those documents indicate that the device shipped with the user manual pre-loaded onto the DATAPAC as an 11.7K text file, along with at least one BASIC program, and the Format function in the option rom would also re-create this file.

## Software
The "driver" software for the device is [RAMDSK](software/RAMDSK/)

Originally these shipped with an option rom from NODE (Written by Travelling Software), which does not seem to be archived anywhere.  

RAMDSK is purported to provide all or almost all of the same functionality as NODEs rom, and even NODE themselves later licensed RAMDSK and included a copy with each unit. It's unclear if this was in addition to their original rom, or fully replacing it.  
Even the rom calls from the option rom have equivalents in RAMDSK, though at different addresses.  
One thing RAMDSK does not do which the original option rom did, is re-create the user manual text file as part of the Format function.

The only other significant software using this device seems to be [XOS](http://www.club100.org/library/libpg.html), which is sort of an OS for the Model 200. XOS does not require a RAMPAC or DATAPAC, but apparently makes good use of one if present. For instance, you can keep just a single copy of RAMDSK.CO in bank 3, yet be able to use it from any bank.  
I have not tried XOS yet, this is just from reading the description.

Some software culled from the M100SIG archive and Club100 are collected in [software](software)  
Much of that software actually requires the original rom, which is not available. Some of that could possibly be converted to work with RAMDSK instead of the rom, by translating the call addresses, per the RAMDSK.TIP file.

The few documents we do have mention a BOOT program that could be manually typed in to BASIC to bootstrap a copy of RAMDSK from a RAMPAC after a cold start, but that file does not seem to be archived anywhere.

Currently the only way to get RAMDSK installed is to copy it via any of the normal ways. BASIC loader, TPDD, cassette.
The quickest way to go from scratch is the bootstrap directions in [software/RAMDSK/100/install.txt](software/RAMDSK/100/install.txt) or [software/RAMDSK/200/install.txt](software/RAMDSK/200/install.txt), which uses a bootstrapper program to feed a loader program into BASIC.

## Model compatibility
Apparently only Models 100, 102, & 200 were ever supported. (No NEC or Olivetti, etc)

There is no reason the device can't work on any of the other machines, merely the software was never written for or ported to them.

### Model 200
The connector on the DATAPAC does not actually fit in a Model 200 without cutting the opening wider around the bus connector on the 200.  
![](REF/does_not_fit_model_200.jpg)

The only connector that fits in a 200 without hacking on the 200s case is a solder-type IDC box header like [this](https://www.digikey.com/en/products/detail/sullins-connector-solutions/SBH11-PBPC-D20-ST-BK/1990068),
 which could be soldered back to back with the female version like [this](https://www.digikey.com/en/products/detail/sullins-connector-solutions/SFH11-PBPC-D20-ST-BK/1990093),
 to make an adapter to allow connecting to a 200 without having to damage the 200's case.

### Model 100
This "102/200" version actually works on Model 100 also. It needs an adapter cable, but the cable is simple. It's just a "wire-to-board" IDC-DIP-40 crimp-on DIP connector and a standard 2x20 female IDC connector, both crimped on to a 40-pin ribbon cable about 8 inches long.  
The Model 100 part of this [3-part cable for the Disk/Video Interface](http://tandy.wiki/Disk/Video_Interface:_Cable) is exactly the same thing.

## Theory of Operation
I am still piecing this together. This is only my hazy guess at how it works so far:

The 3 74x161 form a 0-1023 counter, setting local sram address bits A0-A9. We'll call this the byte counter.

The 74x374 sets local sram address bits A10-A17 from the bus AD0-AD7, and latches that setting, ignoring the bus except when triggered to get a new address.

BUS_A8, BUS_A9, Y0, and /A from the bus combine to produce two signals which I am calling /BLOCK and /BYTE.

Each time /BYTE is pulsed:
* The byte counter is advanced by 1 (A0-A9 are changed to the next address).

* All sram are disabled during the transition.

Each time /BLOCK is pulsed low and then back up, it does 2 things:
* 74x374 updates A10-A17 from bus AD0-AD7.  
  5 of those bits are used directly as A10-A14 going to all SRAM chips,  
  3 bits A15-A17 are used indirectly to select 1 of the 8 chips.  
  The end result is the same as if all 8 address lines went to a single larger chip.

* The byte counter is reset to 0.

So the device appears to operate in 1k blocks, where the host computer gives 1 of 256 possible "block-start" addresses, then reads or writes up to 1024 bytes, one at a time. Each time the host accesses a byte, the counter advances itself and the next read/write will get the next byte.  
The device is actually acting a bit like a disk even though it has no brains or firmware.

I do not yet know how the software side of the process works.

# MiniNDP
Works the same as DATAPAC, just with a single 256k (or 512k) SRAM and all SMT parts, and directly attached instead of connected by a cable.  

The connector fits in a Model 200 without having to modify the 200.  

Works on Model 100 with the same adapter cable described above.  

All the caps are optional. The original DATAPAC has no caps and works fine.  
C2 provides a few minutes of life without a battery.

The diode on RAM_RST is copied from a user mod found on a DATAPAC. It appears to be intended to prevent a battery drain on the host computer while the DATAPAC is left connected to the host while the host is turned off. R1 does the job of pulling RAM_RST/SLEEP high whenever needed, so it's not required to rely on the host to drive it high.

You can optionally make a thinner, flatter card by replacing BT1 and C2 with lower profile (and lower capacity) alternatives. The battery life and battery-change time will both be reduced.  
|BATTERY|estimated life|holders that fit the footprint|height|C2 Capacitor|
|---|---|---|---|---|
|CR2032|7.5 years|Keystone 3034<br>TE/Linx BAT-HLD-001-SMT<br>Adam Tech BH-67<br>MPD BK-912|4.1mm|[TAJC227K010RNJ](https://www.digikey.com/en/products/detail/kyocera-avx/TAJC227K010RNJ/1833766?s=N4IgTCBcDaICoEEBSBhMYDsBpADARhwCUA5JEAXQF8g) - 6032-28 220u 10v|
|CR2016|3 years|Keystone 3028|1.7mm|[TLJW157M010R0200](https://www.digikey.com/en/products/detail/kyocera-avx/TLJW157M010R0200/929982?s=N4IgTCBcDaICoBkBSB1AjAVgOwFkAMaeASnmHniALoC%2BQA) - 6032-15 150u 10v|

A 256Kx8 SRAM is ideal, but 512Kx8 are more available, so the circuit and pcb are designed to also accept a 512Kx8 SRAM in the same footprint with no changes needed.  
To allow the drop-in use of either a 256Kx8 or 512Kx8 part, the active-high CE2 pin on the 256Kx8 is hardwired high and not used to enable/disable the chip.  
That pin is an address line on a 512Kx8 part. So, tying the pin high makes it a no-op in both cases, and makes both parts act like a 256Kx8 that only has a single /CE pin.  
For the 256Kx8 part, note that it must specifically be AS6C2008A and not AS6C2008. Only the A version is 5v tolerant.  
For the 512Kx8 part, there is no A version. AS6C4008 is 5v tolerant.  

BOM [DigiKey](https://www.digikey.com/short/5rf5qqq7)  
PCB [OSHPark](https://oshpark.com/shared_projects/81zI8Ibg), [PCBWAY](https://www.pcbway.com/project/shareproject/MiniNDP_mini_Node_DataPac_d08018c4.html)  

For the PCB, you want ENIG copper finish so that the battery contact is gold. PCBWAY and JLCPCB are a bit expensive for ENIG. Elecrow is cheaper, and OSHPark is always ENIG.

For an enclosure, I have an idea for a design, but haven't drawn it up yet, meanwhile, FD Singleton has already designed a 3d-printable [slip cover](enclosure) that looks like it works pretty well.

![](PCB/out/MiniNDP_256.svg)
![](PCB/out/MiniNDP_256.top.jpg)
![](PCB/out/MiniNDP_256.bottom.jpg)
![](PCB/out/MiniNDP_256.f.jpg)
![](PCB/out/MiniNDP_256.b.jpg)

CR2032 height
![](PCB/out/MiniNDP_256_CR2032.jpg)

CR2016 height (nominally a CR2012 holder, but can take a CR2016)  
![](PCB/out/MiniNDP_256_CR2016.jpg)

Installed on a TANDY 102
![](REF/MiniNDP_on_102.jpg)

Installed on a TANDY 200
![](REF/MiniNDP_on_200.jpg)

FD Singelton's slip cover
![](REF/MiniNDP_FD_Singleton_slip_cover.jpg)
