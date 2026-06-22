# Makefile for RAMDSK.CO
# Requires https://github.com/z88dk/z88dk
# Requires https://github.com/bkw777/dl2

# this makefile is too complicated

MODELS = 100 200 K85
NAME = RAM
SRC = RAMDSK.S85
CALLS = FREE|KILL|LOAD|NAME|SAVE|SAVE1

AS = z88dk-z80asm
ASFLAGS := -m8085_strict -no-synth # -v
# z88dk-z80asm <= 24602 has a bug that it only accepts the zilog syntax for RST.
# If $(AS) is z88dk then add -DZ88DK=ver to flags.
ASFLAGS += $(shell $(AS) |awk '/^Z80 Macro Assembler /{split($$4,a,"-");if (a[1]>0) print "-DZ88DK="a[1]}')

# -DHIMEM=addr           # generate a relocated binary with specified HIMEM/END address
# -DBANKS_ONE_BASED      # display the bank number as Bank1-Bank4 instead of Bank0-Bank3
# -DNBANKS=n             # support 1-32 banks. Default 4. 2 to match legacy. 1 to make a version that only supports 256k but also the smallest
# -DMATCH_LEGACY_CO_HEADER  # add/remove code & padding as necessary to make TOP/END/EXE match the legacy binaries
# -DALT_BANKSW           # different method of bank-switch code that's a few bytes shorter but not as good
#
# If you comment out -DMATCH_LEGACY_CO_HEADER then RAM100.CO is smaller,
# lives higher in ram, and you gain 23 bytes of ram vs the legacy version.
# The only reason for matching the legacy top/end/exe is just so that the same
# 4-line RBOOT.BA with hard-coded TOP & END addresses works for both old & new.
# MiniNDP has RBOOT.BA on the silkscreen.
#
#XFLAGS := -DNBANKS=1                 # 256k   1317 bytes
#XFLAGS := -DNBANKS=2                 # 512k   1373 bytes
#XFLAGS :=                            # 1M     1380 bytes
XFLAGS := -DMATCH_LEGACY_CO_HEADER    # 1M     1406 bytes

# don't delete .CO when building .DO etc.
.SECONDARY:

.PHONY: all
all: $(MODELS)

.PHONY: $(MODELS)
$(MODELS): % : $(NAME)%.DO

# We need the length of the binary to set ORG, but we don't know the length
# until after compile. So we compile once with default org 0 and no CO header
# just to get the length. Then compile again with correct ORG & CO header.
# Also generate map file (-m) to provide the function call addresses,
# and filter .map to produce .calls
$(patsubst %,$(NAME)%.CO,$(MODELS)): $(NAME)%.CO : $(SRC) %.S85 recover.bas
	$(AS) $(ASFLAGS) $(XFLAGS) -DMODEL_$* -b -o=$@ $< && \
	n=$$(wc -c <$@) && \
	$(AS) $(ASFLAGS) $(XFLAGS) -DMODEL_$* -DPRGLEN=$$n -m -b -o=$@ $<
	@printf 'CALLable routines in $@\nSee RAMDSK.TIP, but use these addresses instead.\n\n' >$(NAME)$*.calls
	@IFS="$$IFS\$$" ;while read n x a x ;do case "$$n" in \
	$(CALLS)) echo "$$n	$$((0x$$a))" ;; \
	PRGTOP) PRGTOP=$$((0x$$a)) ;; \
	PRGEND) PRGEND=$$((0x$$a-1)) ;; \
	esac ;done >>$(NAME)$*.calls <$(NAME)$*.map ; \
	sed "s/_MODEL_/$*/g;s/_TOP_/$$PRGTOP/g;s/_END_/$$PRGEND/g" <recover.bas >RBOOT.$*
	@rm *.o $(NAME)$*.map

%.DO: %.CO
	@which -s co2ba || echo "Please install https://github.com/bkw777/dl2 for co2ba to generate $@"
	co2ba $< savem >$@

%.calls: %.CO
	@IFS="$$IFS\$$" ;while read n x a x ;do case "$$n" in $(CALLS)) printf '%s\t%d\n' "$$n" "0x$$a" ;; esac ;done >$@ <$*.map
	@rm $*.map

.PHONY: publish
publish: all
	@for m in $(MODELS) ;do cp -vf $(NAME)$$m.* RBOOT.$$m ../$(NAME)$$m/ ;done

.PHONY: load_%
load_%: $(NAME)%.DO
	@which -s dl || echo "Please install https://github.com/bkw777/dl2 to bootstrap $<"
	dl -v -b $<

.PHONY: clean
clean:
	rm -f *.o *.bin *.sym *.lis *.map *.def *.CO *.DO *.calls *.100 *.200 *.K85
