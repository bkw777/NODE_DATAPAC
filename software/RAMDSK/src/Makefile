# Makefile for RAMDSK.CO
# Requires https://github.com/z88dk/z88dk
# Requires https://github.com/bkw777/dl2

MODELS := 100 200 # K85
NAME := RAM
SRC = RAMDSK.S85
INC = $(patsubst %,%.S85,$(MODELS))
CO = $(patsubst %,RAM%.CO,$(MODELS))
DO = $(patsubst %.CO,%.DO,$(CO))
map = $(patsubst %.CO,%.map,$(CO))

AS = z88dk-z80asm
ASFLAGS := -m8085 -no-synth # -v
XFLAGS :=

.PHONY: all
all: $(MODELS)

.PHONY: $(MODELS)
$(MODELS): $(CO) $(DO)

# We need the length of the binary to set ORG, but we don't know the length
# until after compile. So we compile once with default org 0 and no CO header
# just to get the length. Then compile again with correct ORG & CO header.
# Also generate map file to provide the function call addresses.
%.CO: $(SRC) $(INC)
	$(eval D = -DMODEL_$(patsubst RAM%.CO,%,$@))
	$(AS) $(ASFLAGS) $(XFLAGS) $(D) -b -o=$@ $< && \
	n=$$(wc -c <$@) && \
	$(AS) $(ASFLAGS) $(XFLAGS) $(D) -DPRGLEN=$$n -m -b -o=$@ $<
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
	cmp -l -b RAM100.CO ../RAM100/RAM100.CO && echo "Built RAM100.CO is identical to reference."
	cmp -l -b RAM200.CO ../RAM200/RAM200.CO && echo "Built RAM200.CO is identical to reference."

#.PHONY: install
#install: $(DO)
#	@which dl || echo "Please install https://github.com/bkw777/dl2 to bootstrap $@"
#	dl -v -b $(DO)

.PHONY: clean
clean:
	rm -f *.o *.bin *.sym *.lis *.map *.def *.CO *.DO
