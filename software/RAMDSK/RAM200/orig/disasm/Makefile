# Makefile for RAMDSK.CO
# Requires https://github.com/z88dk/z88dk
# Requires https://github.com/bkw777/dl2

NAME := RAM200
CO = $(NAME).CO
DO = $(NAME).DO
map = $(NAME).map

# Original RAM200.CO is compiled with TOP 0xE943 LEN 0x056B,
# which works out to HIMEM=0xEEAE.
#
# Use 0xEEAE (and ensure PRGLEN=0x56B) to match the original binary len & entry. 
# Otherwise use whatever you want to generate a custom relocated binary.
# If you don't care about matching the old binary for the sake of the BASIC bootstrap code,
# then use HIMEM=$(MAXRAM)
MAXRAM := 0xEEB0
#HIMEM := $(MAXRAM)
HIMEM := 0xEEAE

AS = z88dk-z80asm
ASFLAGS := -m8085 -no-synth # -v
XFLAGS :=

.PHONY: all
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
	$(AS) $(ASFLAGS) $(XFLAGS) -DHIMEM=$(HIMEM) -DPRGLEN=$$n -m -b -o=$@ $<
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

.PHONY: verify
verify: all
	cmp -l -b $(CO) ../RAM200.CO && echo "Build is identical to reference."
#	cmp -l -b $(CO) ../orig/ramdsk.co

.PHONY: install
install: $(DO)
	@which dl || echo "Please install https://github.com/bkw777/dl2 to bootstrap $@"
	dl -v -b $(DO)

.PHONY: clean
clean:
	rm -f *.o *.bin *.sym *.lis *.map *.def *.CO *.DO
