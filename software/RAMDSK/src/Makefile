# Makefile for RAMDSK.CO
# Requires https://github.com/z88dk/z88dk
# Requires https://github.com/bkw777/dl2

# this makefile is too complicated and fragile

MODELS := 100 200 K85
NAME := RAM
SRC = RAMDSK.S85
INC = $(patsubst %,%.S85,$(MODELS))
CO  = $(patsubst %,RAM%.CO,$(MODELS))
DO  = $(patsubst %.CO,%.DO,$(CO))
map = $(patsubst %.CO,%.map,$(CO))
CALLS = FREE KILL LOAD NAME SAVE SAVE1

AS = z88dk-z80asm
ASFLAGS := -m8085 -no-synth # -v

# -DHIMEM=addr         # generate a relocated binary with specified HIMEM/END address
# -DBANKS_ONE_BASED    # display the bank number as Bank1-Bank4 instead of Bank0-Bank3
# -DNBANKS=n           # support n banks instead of the default 4 (or 2 for legacy)
# -DPRE_INIT_BANKSW    # enable the legacy feature that looks for ENTER key at start
# -DMATCH_LEGACY_CO_HEADER  # add/remove padding/code to make TOP/END/EXE match the legacy binaries
XFLAGS := -DMATCH_LEGACY_CO_HEADER

# don't delete .CO when building .DO etc.
.SECONDARY:

.PHONY: all
all: $(MODELS)

.PHONY: $(MODELS)
$(MODELS): % : $(NAME)%.DO

# We need the length of the binary to set ORG, but we don't know the length
# until after compile. So we compile once with default org 0 and no CO header
# just to get the length. Then compile again with correct ORG & CO header.
# Also generate map file to provide the function call addresses.
$(CO): RAM%.CO : $(SRC) %.S85
	$(eval D = -D$(patsubst RAM%.CO,MODEL_%,$@))
	$(AS) $(ASFLAGS) $(XFLAGS) $(D) -b -o=$@ $< && \
	n=$$(wc -c <$@) && \
	$(AS) $(ASFLAGS) $(XFLAGS) $(D) -DPRGLEN=$$n -m -b -o=$@ $<
	@rm *.o

%.map: %.CO

%.calls: %.map
	@while read n x a x ;do [[ " $(CALLS) " =~ " $$n " ]] && echo $$n $${a/\$/} ;done < $<

%.DO: %.CO
	@which -s co2ba || echo "Please install https://github.com/bkw777/dl2 for co2ba to generate $@"
	co2ba $< savem >$@

.PHONY: publish
publish: all
	@for m in $(MODELS) ;do cp -vf $(NAME)$$m.* ../$(NAME)$$m/ ;done

.PHONY: load_%
load_%: $(NAME)%.DO
	@which -s dl || echo "Please install https://github.com/bkw777/dl2 to bootstrap $<"
	dl -v -b $<

.PHONY: clean
clean:
	rm -f *.o *.bin *.sym *.lis *.map *.def *.CO *.DO
