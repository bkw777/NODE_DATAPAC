# Makefile for RAM200.CO
# Requires https://github.com/z88dk/z88dk
# Requires https://github.com/bkw777/dl2

NAME := RAM200

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

# don't delete .CO when building .DO etc.
.SECONDARY:

.PHONY: all
all: v1 v2

.PHONY: map
map: $(map)

.PHONY: v1
v1: $(NAME)v1.DO

.PHONY: v2
v2: $(NAME).DO

# We need the length of the binary to set ORG, but we don't know the length
# until after compile. So we compile once with default org 0 and no CO header
# just to get the length. Then compile again with correct ORG & CO header.
# Also generate map file to provide the function call addresses.
%.CO: %.S85
	$(AS) $(ASFLAGS) $(XFLAGS) -b -o=$@ $< && \
	n=$$(wc -c <$@) && \
	$(AS) $(ASFLAGS) $(XFLAGS) -DPRGLEN=$$n -m -b -o=$@ $<
	@rm *.o

%.map: %.CO

%.DO: %.CO
	@which co2ba >/dev/null || echo "Please install https://github.com/bkw777/dl2 for co2ba to generate $@"
	co2ba $< savem >$@

.PHONY: verify
verify: all verify_v1 verify_v2

.PHONY: verify_v1
verify_v1: v1
	@c=$(NAME)v1.CO ;cmp -l -b $$c ../$$c && echo "Built $$c is identical to reference ../$$c."

.PHONY: verify_v2
verify_v2: v2
	@c=$(NAME).CO ;cmp -l -b $$c ../$$c && echo "Built $$c is identical to reference ../$$c."

.PHONY: load
load: $(NAME).DO
	@which dl || echo "Please install https://github.com/bkw777/dl2 to bootstrap $<"
	dl -v -b $<

.PHONY: clean
clean:
	rm -f *.o *.bin *.sym *.lis *.map *.def *.CO *.DO
