# Makefile for RAMDSK.CO
# Requires https://github.com/z88dk/z88dk
# Requires https://github.com/bkw777/dl2

NAME := RAM100
CO = $(NAME).CO
DO = $(NAME).DO
map = $(NAME).map

# Real HIMEM is 0xF5F0 for a reset 32k machine.
# Original RAM100.CO is compiled with TOP 0xF076 LEN 0x0578,
# which works out to HIMEM=0xF5EE.
#
# Use 0xF5EE (and ensure PRGLEN=0x578) to match the original binary len & entry. 
# Otherwise use whatever you want to generate a custom relocated binary.
# If you don't care about matching the old binary for the sake of the BASIC bootstrap code,
# then use HIMEM=$(MAXRAM) and comment-out padding: at the bottom of *.S85
MAXRAM32K := 0xF5F0 # hardware himem for 32k Model 100
MAXRAM24K := 0xD5F0 # hardware himem for 24k Model 100
MAXRAM16K := 0xB5F0 # hardware himem for 16k Model 100
MAXRAM8K  := 0x95F0 # hardware himem for 8k  Model 100
MAXRAM := $(MAXRAM32K)
#HIMEM := $(MAXRAM)
HIMEM = 0xF5EE

AS = z88dk-z80asm
ASFLAGS := -m8085 -no-synth # -v
# -DALT_BANK_LOGIC    slightly shorter but more fragile bank switch logic
# -DBANKS_ONE_BASED   display "Bank1" - "Bank4" (doesn't match original, also inconsisntent with block 0, byte 0, etc.)
XFLAGS := -DALT_BANK_LOGIC

all: DO

.PHONY: CO
CO: $(CO)

.PHONY: DO
DO: $(DO)

.PHONY: map
map: $(map)

# We need the length of the binary to set ORG, but we don't know the length
# until after compile. So we compile once with default org 0 and no CO header
# just to get the length. Then compile again with correct ORG & CO header.
# Also generate map file to provide the function call addresses.
%.CO: %.S85
	$(AS) $(ASFLAGS) $(XFLAGS) -b -o=$@ $< && \
	n=$$(wc -c <$@) && \
	$(AS) $(ASFLAGS) -DHIMEM=$(HIMEM) -DPRGLEN=$$n $(XFLAGS) -m -b -o=$@ $<
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
