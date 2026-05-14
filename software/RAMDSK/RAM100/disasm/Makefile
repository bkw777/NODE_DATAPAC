# Makefile for RAMDSK.CO
# Requires https://github.com/z88dk/z88dk

NAME := RAM100
CO = $(NAME).CO

AS = z88dk-z80asm
FLAGS := -m8085 # -v

all: CO

.PHONY: CO
CO: $(CO)

%.CO: %.S85
	$(AS) $(FLAGS) -b -o=$@ $<
	@rm *.o
	@ls -l $@

.PHONY: clean
clean:
	rm -f *.o *.bin *.lis *.lst *.map *.def *.CO
