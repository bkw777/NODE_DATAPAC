# Crude RAMPAC Inspector

You supply a bank number, block number, starting byte offset, and number of bytes, and it reads those bytes and displays them on screen.

bank: 0-3
block: 0-255
start: 0-1023
length: 1-1024

Press F2 while it's running to switch between ascii or hex display mode.

Press F8 while it's running or BREAK at the input prompt to quit.

The reason it exists when [RD](../Rampac_Diagnostic/) and [N-DKTR](../N-DKTR/) already exist is,  
* Smaller  
* No machine code - you can see everything it does or change anything it does all in BASIC  
* Stand-alone - does not require either the NODE rom or RAMDSK to work  
* Supports banks / devices with more than 256k

TODO - display/repair first 2 bytes formatted flag.  
TODO - display filenames and lengths from the headers.  
