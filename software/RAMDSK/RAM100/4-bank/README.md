This version of RAM100 is modified to support 4 banks.

Removed the feature to start in bank 1 instead of bank 0 by holding enter while launching.

top/exe address & length padded so that the binary is the same length as the original binary,
so that the 4-line bootstrap BASIC for the original is still valid for this version.

Without the padding, the binary could be 3 bytes smaller and the top address could be 5 bytes higher.  
See HIMEM in the makefile (set it to MAXRAM), and bkw: in the .S85 (comment out).
