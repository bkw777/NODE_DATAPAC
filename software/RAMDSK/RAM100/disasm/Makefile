# Makefile for RAMDSK.CO
# Requires https://github.com/z88dk/z88dk

NAME := RAM100
CO = $(NAME).CO

# Real HIMEM is 0xF5F0 for a reset 32k machine.
# Original RAM100.CO is compiled with TOP 0xF076 LEN 0x0578,
# which works out to 0xF5EE.
#
# Use 0xF5EE to generate a binary identical to the original.
#
# Otherwise use whatever you want to generate a custom relocated binary
# that lives at some other addres.
HIMEM := 0xF5EE

AS = z88dk-z80asm
FLAGS := -m8085 -no-synth # -v

all: CO

.PHONY: CO
CO: $(CO)

# compile once with no header or org, get len, compile again with header & org
# self-indulgent way to get file length without ls/stat/wc/etc
%.CO: SHELL:=/bin/bash  # the read loop needs bash
%.CO: %.S85
	rm -f $@ ;$(AS) $(FLAGS) -b -o=$@ $< && n=0 && \
	while LANG=C IFS= read -d '' -r -n 1 x ;do ((n++)) ;done <$@ && \
	$(AS) $(FLAGS) -DHIMEM=$(HIMEM) -DPRGLEN=$$n -b -o=$@ $<
	@rm *.o
	@ls -l $@

.PHONY: clean
clean:
	rm -f *.o *.bin *.sym *.lis *.map *.def *.CO
