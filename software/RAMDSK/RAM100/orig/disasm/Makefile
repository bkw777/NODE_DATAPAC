# Makefile for RAM100.CO
# Requires https://github.com/z88dk/z88dk
# Requires https://github.com/bkw777/dl2

NAME := RAM100
CO = $(NAME).CO
DO = $(NAME).DO
map = $(NAME).map

AS = z88dk-z80asm
ASFLAGS := -m8085 -no-synth # -v
# z88dk-z80asm <= 24602 has a bug that it only accepts the zilog syntax for RST.
# If $(AS) is z88dk then add -DZ88DK=ver to flags. Used in m100_common.S85
ASFLAGS += $(shell $(AS) |awk '/^Z80 Macro Assembler /{split($$4,a,"-");if (a[1]>0) print "-DZ88DK="a[1]}')

XFLAGS :=

# don't delete .CO when building .DO etc.
.SECONDARY:

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
	$(AS) $(ASFLAGS) $(XFLAGS) -DPRGLEN=$$n -m -b -o=$@ $<
	@rm *.o

%.map: %.CO

%.DO: %.CO
	@which co2ba >/dev/null || echo "Please install https://github.com/bkw777/dl2 for co2ba to generate $@"
	co2ba $< savem >$@

.PHONY: verify
verify: $(CO)
	@cmp -l -b $< ../$< && echo "Built $< is identical to reference ../$<."

.PHONY: load
install: $(DO)
	@which dl || echo "Please install https://github.com/bkw777/dl2 to bootstrap $<"
	dl -v -b $<

.PHONY: clean
clean:
	rm -f *.o *.bin *.sym *.lis *.map *.def *.CO *.DO
