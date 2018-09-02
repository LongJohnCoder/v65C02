SHELL = /bin/sh

prefix      = ..
exec_prefix = $(prefix)
bin_dir      = $(exec_prefix)/bram_data

BIOS     = bios.rom
BIOS_COE = bios.coe
BIOS_MEM = bios.mem
OBJECTS  = main.o conio.o interrupts.o itoa.o monitor.o uart.o vga_init.o

AS       = ca65
ASFLAGS  = --cpu 65C02 --listing $(basename $@).lst --target none

LD       = ld65
LDCONFIG = memory.conf
LDFLAGS  = --config $(LDCONFIG) --mapfile $(basename $@).map

BIN2COE  = ./bin2coe.sh
BIN2MEM  = ./bin2mem.sh

.PHONY: all install clean

all: $(BIOS)

%.o : %.a65
	$(AS) $(ASFLAGS) -o $@ $<

main.o : main.a65 conio.inc memory.inc

conio.o : conio.a65 memory.inc

interrupts.o : interrupts.a65

itoa.o : itoa.a65

monitor.o : monitor.a65 ascii.inc memory.inc

uart.o : uart.a65 memory.inc

vga_init.o : vga_init.a65 ascii.inc colors.inc memory.inc

$(BIOS) : $(OBJECTS)
	$(LD) $(LDFLAGS) $^
	$(BIN2COE) $@
	$(BIN2MEM) $@

install:
	@cp -v $(BIOS_COE) $(bin_dir)
	@cp -v $(BIOS_MEM) $(bin_dir)

clean :
	@rm -fv *.lst
	@rm -fv *.map
	@rm -fv *.o
	@rm -fv $(BIOS)
	@rm -fv $(BIOS_COE)
	@rm -fv $(BIOS_MEM)
