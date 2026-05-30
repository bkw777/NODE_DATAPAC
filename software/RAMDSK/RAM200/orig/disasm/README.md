# RAM200 v1 & v2 disassembly

RAM200v1 is the original version before banks existed.

RAM200 is v2, the later version that adds support for 2 banks,  
and repairing the format stamp in first 2 bytes on the device.

`make clean all verify`

```
$ make clean all verify
rm -f *.o *.bin *.sym *.lis *.map *.def *.CO *.DO
z88dk-z80asm -m8085 -no-synth   -b -o=RAM200v1.CO RAM200v1.S85 && \
n=$(wc -c <RAM200v1.CO) && \
z88dk-z80asm -m8085 -no-synth   -DPRGLEN=$n -m -b -o=RAM200v1.CO RAM200v1.S85
co2ba RAM200v1.CO savem >RAM200v1.DO
z88dk-z80asm -m8085 -no-synth   -b -o=RAM200.CO RAM200.S85 && \
n=$(wc -c <RAM200.CO) && \
z88dk-z80asm -m8085 -no-synth   -DPRGLEN=$n -m -b -o=RAM200.CO RAM200.S85
co2ba RAM200.CO savem >RAM200.DO
Built RAM200v1.CO is identical to reference ../RAM200v1.CO.
Built RAM200.CO is identical to reference ../RAM200.CO.
$ 
```
