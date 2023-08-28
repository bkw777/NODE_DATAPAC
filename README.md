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

### Original Schematic & PCB
This is a new drawing but aims to reflect the original actual device as exactly as possible.  
Both the schematic and the pcb are exactly like the real original, warts and all.  
It's meant to be a form of documentation or reference describing the original hardware as it was.  
![](PCB/out/NODE_DATAPAC_256K_historical.svg)

PCB TOP
![](PCB/out/NODE_DATAPAC_256K_historical_top.jpg)

PCB BOTTOM
![](PCB/out/NODE_DATAPAC_256K_historical_bottom.jpg)

The real PCB has no silkscreen. This image has silkscreen added to show where the components from the schematic go.
![](PCB/out/NODE_DATAPAC_256K_historical_top_annotated.jpg)


### New Schematic & PCB
This aims to be a functional replacement and will change over time to use newer parts.  
Currently still uses all the same main chips as the original. Changes so far are that many of the traces are rerouted, coin cell battery, decoupling caps, ground pours, silkscreen.  
Pending TODO items: Change the BUS connection to use a removable cable, and flip the pinout so that the computer end of the cable can use a connector that actually fits in a 200.
![](PCB/out/NODE_DATAPAC_256K_bkw0.svg)
![](PCB/out/NODE_DATAPAC_256K_bkw0_top.jpg)
![](PCB/out/NODE_DATAPAC_256K_bkw0_bottom.jpg)
![](PCB/out/NODE_DATAPAC_256K_bkw0_1.jpg)
![](PCB/out/NODE_DATAPAC_256K_bkw0_2.jpg)

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

Originally these shipped with an option rom from NODE, which does not seem to be archived anywhere.  

RAMDSK is purported to provide all or almost all of the same functionality as NODEs rom, and even NODE themselves later licensed RAMDSK and included a copy with each unit. It's unclear if this was in addition to their original rom, or fully replacing it.  
Even the rom calls from the option rom have equivalents in RAMDSK, though at different addresses.  
(One thing RAMDSK does not do which the original option rom did, is re-create the user manual text file as part of the Format function.)  

The only other significant software using this device seems to be [XOS-C](http://www.club100.org/library/libpg.html), which is sort of an OS for the Model 200. XOS does not require a RAMPAC or DATAPAC, but apparently makes good use of one if present. For instance, you can keep just a single copy of RAMDSK.CO in bank 3, yet be able to use it from any bank.  
I have not tried XOS-C yet, this is just from reading the description.

Some software culled from the M100SIG archive and Club100 are collected in [software](software)  

## Model compatibility
Apparently only Models 100, 102, & 200 were ever supported. (No NEC or Olivetti, etc)

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

U1-U3 form a 0-1023 counter, setting local sram address bits I am tentatively calling A0-A9. We'll call this the byte counter.

U6 sets local sram address bits I am tentatively calling A10-A17 from the bus AD0-AD7, and latches that setting, ignoring the bus except when triggered to get a new address.

BUS_A8, BUS_A9, Y0, and /A from the bus combine to produce two signals which I am tentatively calling /BLOCK and /BYTE.

Each time /BYTE is pulsed:
* The byte counter is advanced by 1 (A0-A9 are changed to the new address).
* All sram are disabled during the transition.

Each time /BLOCK is pulsed low and then back up, it does 2 things:
* U6 updates A10-A17 from bus AD0-AD7. 5 of those bits are used directly as A10-A14 going to all SRAM chips, and 3 A15-A17 are used indirectly to activate only 1 of the 8 chips. The end result is the same as the same 8 address lines going to a single larger chip. The rest of the time while /BLOCK is not low (or not transitioning from low to high) the local address lines are held latched in the last set state. They don't change with bus changes except when /BLOCK pulses low.
* The byte counter is reset to 0.

So the device appears to operate in 1k blocks, where the host computer gives 1 of 256 possible "block-start" addresses, then reads up to 1024 bytes, one at a time. Each time the host reads a byte, the counter advances itself and the next read will get the next byte. So the host does not set the address for each byte like with normal direct ram.  
The device is actually acting a bit like a disk even though it has no brains or firmware, in that the host sets a starting address and then reads a stream of bytes.

I do not yet know how the host computer side of the process works.

# WIP
* Replace all the THT parts with SMT parts  
* Replace the 3to8 decoder and 8 32k chips with a single 256k or 512k chip  
![](PCB/out/NODE_DATAPAC_256K_bkw1.svg)
![](PCB/out/NODE_DATAPAC_256K_bkw1_1.jpg)
![](PCB/out/NODE_DATAPAC_256K_bkw1_2.jpg)
