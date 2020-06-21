TARGET=8snail
PASM=pasm
CSS=../listn.css
NAV=../navigate.js
EXOMIZER=../exomizer-2.0/src/exomizer
BIN2WAV=bin2wav
CC := $(or $(CC),gcc)

SRCDIR=../src


OBJCOPY := $(shell command -v gobjcopy 2>/dev/null)
ifndef OBJCOPY
    OBJCOPY := $(shell command -v objcopy 2>/dev/null)
endif

ifndef OBJCOPY
    $(error You need gobjcopy or objcopy) 
else
    $(info Found objcopy: $(OBJCOPY))
endif

export OBJCOPY


.PHONY:	exomizer all everything clean

all:
	@mkdir -p build
	@make -C build -f ../Makefile everything
	@echo "Built $(TARGET).rom in build/$(TARGET).rom"
	@ls -l build/$(TARGET).rom build/$(TARGET).wav

clean:
	rm -rf build
	make -C exomizer-2.0/src clean

everything:	exomizer $(TARGET).rom $(TARGET).wav

exomizer:
	make -C ../exomizer-2.0/src CC=gcc

8snail.0100: $(SRCDIR)/8snail.asm
	$(eval name=$(basename $@))
	$(PASM) $< $(name).lst.html $(name).hex
	$(OBJCOPY) -I ihex $(name).hex -O binary $@

player.a000:	$(SRCDIR)/player.asm
	$(eval name=$(basename $@))
	$(PASM) $< $(name).lst.html $(name).hex
	$(OBJCOPY) -I ihex $(name).hex -O binary $@

deexo.4000:	$(SRCDIR)/deexo.asm
	$(eval name=$(basename $@))
	$(PASM) $< $(name).lst.html $(name).hex
	$(OBJCOPY) -I ihex $(name).hex -O binary $@

reloc.0100:	$(SRCDIR)/reloc.asm
	$(eval name=$(basename $@))
	$(PASM) $< $(name).lst.html $(name).hex
	$(OBJCOPY) -I ihex $(name).hex -O binary $@

	# unpacked concatenated rom with player and music
8snail-flat.rom:	8snail.0100 player.a000 ../assets/flash.pt2	
	cat 8snail.0100 player.a000 ../assets/flash.pt2 >$@

8snail.exo:	8snail-flat.rom
	$(EXOMIZER) raw $< -o $@

$(TARGET).rom:	reloc.0100 deexo.4000 8snail.exo 
	cat $? > $@

$(TARGET).wav:	$(TARGET).rom
	$(BIN2WAV) -c 6 $< $@

