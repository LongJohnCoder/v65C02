SHELL = /bin/sh

BIOS     = bios.rom
BIOS_TXT = bios.txt
OBJECTS  = main.o interrupts.o vga.o conio.o

AS       = ca65
ASFLAGS  = --cpu 65C02 --listing $(basename $@).lst --target none

LD       = ld65
LDCONFIG = memory.conf
LDFLAGS  = --config $(LDCONFIG) --mapfile $(basename $@).map

XXD      = xxd
XXDFLAGS = -p -c 1

.PHONY: all rom2lst install uninstall clean

all: $(BIOS_TXT)

%.o : %.a65
	$(AS) $(ASFLAGS) -o $@ $<

$(BIOS) : $(OBJECTS)
	$(LD) $(LDFLAGS) $^

$(BIOS_TXT) : $(BIOS)
	$(XXD) $(XXDFLAGS) $< $@

install:
	@cp -v $(BIOS_TXT) ../hdl/memory/

uninstall:
	@rm -fv ../hdl/memory/$(BIOS_TXT)

clean :
	@rm -fv *.lst
	@rm -fv *.map
	@rm -fv *.o
	@rm -fv $(BIOS)
	@rm -fv $(BIOS_TXT)
