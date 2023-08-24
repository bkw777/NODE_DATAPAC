# Reproduction of Node Systems DATAPAC

The NODE Systems DATAPAC and RAMPAC were a popular ram disk peripheral for TRS-80 / TANDY Models 100, 102, & 200 computers.

RAMPAC was a later device that apparently functioned exactly the same as DATAPAC, just in a different, smaller form factor and probably using different parts inside.

This schematic and PCB documents the DATAPAC. If I ever aquire a RAMPAC, I'll add that.

Some disorganized [INFO](http://tandy.wiki/NODE_DATAPAC) mostly gathered from the [M100SIG archive](https://github.com/LivingM100SIG/Living_M100SIG).  
Copies of most of the stuff above are in [REF/software](REF/software)  

TLDR: Install RAMDSK.CO (for 200) or RAM100.CO (for 100/102) to use the hardware, and what you get is a 128K or 256K ram disk.

![](REF/NODE_DATAPAC_256K_1.jpg)
![](REF/NODE_DATAPAC_256K_2.jpg)
![](REF/NODE_DATAPAC_256K_3.jpg)
![](REF/NODE_DATAPAC_256K_4.jpg)

### Original Schematic & PCB
This is a new drawing but aims to reflect the original actual device as exactly as possible.  
The both the schematic and the pcb are exactly like the real original, warts and all.  
![](PCB/NODE_DATAPAC_256K_historical.svg)

PCB TOP
![](PCB/NODE_DATAPAC_256K_historical_top.jpg)

PCB BOTTOM
![](PCB/NODE_DATAPAC_256K_historical_bottom.jpg)

The real PCB has no silkscreen. This image below has silkscreen added to show where the components from the schematic go.
![](PCB/NODE_DATAPAC_256K_historical_top_annotated.jpg)


### New Schematic & PCB
This aims to be a functional replacement and will change over time to use newer parts.  
This design currently still uses all the same chips as the original, and just changes the battery connections, adds decoupling caps,
and silkscreen.  
Next TODO: Change the BUS connection to use a removable cable, and flip the pinout so that the computer end of the cable can use a connector that actually fits in a 200.
![](PCB/NODE_DATAPAC_256K_bkw0.svg)
![](PCB/NODE_DATAPAC_256K_bkw0_top.jpg)
![](PCB/NODE_DATAPAC_256K_bkw0_bottom.jpg)
![](PCB/NODE_DATAPAC_256K_bkw0_1x.jpg)
![](PCB/NODE_DATAPAC_256K_bkw0_2x.jpg)

## Battery
The original battery is no longer made. The modern replacement is almost 2mm taller and does not fit inside the enclosure.

NODE Systems themselves used to perform an update to older units to replace the original rechargeable NiCD cell with a non-rechargeable lithium cell which was supposed to last about 5 years.

You can do that same mod today very easily. A standard CR2032 holder can be soldered right into the same holes where the original NiCD cell is, and the 200 ohm resistor needs to be removed and replaced with a diode (any kind, another 1N4148 is perfect). with the stripe away from the battery (same orientation as the other diode right next to it).
I don't know what the actual mod was that NODE did, but this mod should give about 4 years on a new CR2032.
BEFORE
![](PCB/NODE_DATAPAC_256K_batt_mod_before.jpg)
AFTER
![](PCB/NODE_DATAPAC_256K_batt_mod_after.jpg)
STEPS
![](PCB/NODE_DATAPAC_256K_batt_mod_01.jpg)
![](PCB/NODE_DATAPAC_256K_batt_mod_02.jpg)
![](PCB/NODE_DATAPAC_256K_batt_mod_03.jpg)
![](PCB/NODE_DATAPAC_256K_batt_mod_04.jpg)


If you wish to keep using a rechargeable battery, then a suitable option is FL3/V80H. That is 3 16x5.8mm NiMH button cells in a flat in-line pack with wire leads. It fits perfectly in the space next to the ribbon cable. It needs to be secured with hot glue or foam mounting tape, and connected with wires run to the original battery location.
![](REF/fl3v80h_placement.jpg)


## Software
Originally these were shipped with an option rom from NODE, which I do not have.  
RAMDSK is purported to provide all or almost all of the same functionality, and even NODE themselves eventually licensed RAMDSK from Paul Globman and included a copy with each unit. It's unclear if this was in addition to their own original rom, or fully replacing it.

The only other significant software using this device seems to be [XOS](http://www.club100.org/library/libpg.html), also from Paul Globman, which is sort of an OS for the Model 200. XOS does not require a RAMPAC or DATAPAC, but apparently makes good use of one if present.
I have not tried XOS yet.

## Model compatibility
The case says for Model 102/200, however...

### Model 200
The connector on the DATAPAC does NOT actually fit in a 200 without cutting the opening around the bus connector on the 200 wider.
![](REF/does_not_fit_model_200.jpg)

The only connector that fits in a 200 is a solder-type box header like used in this [cable for the Disk/Video Interface](http://tandy.wiki/Disk/Video_Interface:_Cable#Good_Cable).

### Model 100
This device actually works on Modle 100 too. It needs an adapter cable but the cable is simple.
From the top of that page with the Disk/Video Interface cables above, the Model 100 part of the [3-part cable](http://tandy.wiki/Disk/Video_Interface:_Cable#Good_Cable) works for this too. Just the Model 100 part, not the full cable with all 3 parts connected.
