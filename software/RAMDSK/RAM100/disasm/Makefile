# Makefile for RAMDSK.CO
# Requires https://github.com/z88dk/z88dk

NAME := RAM100
CO = $(NAME).CO
map = $(NAME).map
DO = $(NAME).DO

# Real HIMEM is 0xF5F0 for a reset 32k machine.
# Original RAM100.CO is compiled with TOP 0xF076 LEN 0x0578,
# which works out to 0xF5EE.
#
# Use 0xF5EE to reproduce the original binary.
# Otherwise use whatever you want to generate a custom relocated binary.
MAXRAM32K := 0xF5F0 # hardware himem for 32k Model 100
MAXRAM24K := 0xD5F0 # hardware himem for 24k Model 100
MAXRAM16K := 0xB5F0 # hardware himem for 16k Model 100
MAXRAM8K  := 0x95F0 # hardware himem for 8k  Model 100
MAXRAM := $(MAXRAM32K)
HIMEM_ORIGINAL_RAM100 = 0xF5EE
#HIMEM := $(MAXRAM)
HIMEM := $(HIMEM_ORIGINAL_RAM100)

# z88dk compiler, output .map along with .CO
AS = z88dk-z80asm
FLAGS := -m8085 -no-synth # -v

all: DO

.PHONY: CO
CO: $(CO)

.PHONY: map
map: $(map)

.PHONY: DO
DO: $(DO)

# We need the length of the binary to set ORG, but we don't know the length
# until after compile. So we compile once with default org 0 and no CO header
# just to get the length. Then compile again with correct ORG & CO header.
# Also generate map file to provide the function call addresses.
%.CO: %.S85
	$(AS) $(FLAGS) -m -b -o=$@ $< && \
	n=$$(wc -c <$@) && \
	$(AS) $(FLAGS) -DHIMEM=$(HIMEM) -DPRGLEN=$$n -b -o=$@ $<
	@rm *.o
	@ls -l $@

%.map: %.CO
	@ls -l $@

# co2ba comes from https://github.com/bkw777/dl2
# generate a BASIC loader *.DO to install *.CO
%.DO: %.CO
	@which co2ba >/dev/null || echo "Please install https://github.com/bkw777/dl2 for co2ba to generate $@"
	co2ba $< savem >$@
	@ls -l $@

.PHONY: install
install: $(DO)
	@which dl || echo "Please install https://github.com/bkw777/dl2 to bootstrap $@"
	dl -v -b $(DO)

.PHONY: clean
clean:
	rm -f *.o *.bin *.sym *.lis *.map *.def *.CO
