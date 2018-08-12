SHELL = /bin/sh

prefix      = ..
exec_prefix = $(prefix)
bin_dir      = $(exec_prefix)/bram_data

BIOS     = bios.rom
BIOS_COE = bios.coe
BIOS_MEM = bios.mem
OBJECTS  = main.o interrupts.o vga.o conio.o

AS       = ca65
ASFLAGS  = --cpu 65C02 --listing $(basename $@).lst --target none

LD       = ld65
LDCONFIG = memory.conf
LDFLAGS  = --config $(LDCONFIG) --mapfile $(basename $@).map

BIN2COE  = ./bin2coe.sh
BIN2MEM  = ./bin2mem.sh

.PHONY: all install uninstall clean

all: $(BIOS)

%.o : %.a65
	$(AS) $(ASFLAGS) -o $@ $<

$(BIOS) : $(OBJECTS)
	$(LD) $(LDFLAGS) $^
	$(BIN2COE) $@
	$(BIN2MEM) $@

install:
	@cp -v $(BIOS_COE) $(bin_dir)
	@cp -v $(BIOS_MEM) $(bin_dir)

uninstall:
	@rm -fv $(bin_dir)/$(BIOS_COE)
	@rm -fv $(bin_dir)/$(BIOS_MEM)

clean :
	@rm -fv *.lst
	@rm -fv *.map
	@rm -fv *.o
	@rm -fv $(BIOS)
	@rm -fv $(BIOS_COE)
	@rm -fv $(BIOS_MEM)
