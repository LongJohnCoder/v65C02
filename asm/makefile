SHELL = /bin/sh

prefix      = ..
exec_prefix = $(prefix)
bin_dir     = $(exec_prefix)/bram_data

BIOS     = bios.rom
BIOS_COE = bios.coe
BIOS_MEM = bios.mem
OBJECTS  = main.o conio.o convert.o interrupts.o keymap.o monitor.o uart.o

AS       = ca65
ASFLAGS  = --cpu 65C02 -l $(basename $@).lst -t none -I ./include/

LD       = ld65
LDCONFIG = memory.conf
LDFLAGS  = -C $(LDCONFIG) -m $(basename $@).map

BIN2COE  = ./bin2coe.sh
BIN2MEM  = ./bin2mem.sh

.PHONY: all install clean

all : $(BIOS)

%.o : %.a65
	$(AS) $(ASFLAGS) -o $@ $<

main.o : main.a65 include/conio.inc include/memory.inc include/uart.inc

conio.o : conio.a65 include/ascii.inc include/colors.inc include/conio.inc \
          include/memory.inc

convert.o : convert.a65

interrupts.o : interrupts.a65

keymap.o : keymap.a65

monitor.o : monitor.a65 include/ascii.inc include/conio.inc include/memory.inc

uart.o : uart.a65 include/memory.inc include/uart.inc

$(BIOS) : $(OBJECTS)
	$(LD) $(LDFLAGS) $^
	$(BIN2COE) $@
	$(BIN2MEM) $@

install :
	@cp -v $(BIOS_COE) $(bin_dir)
	@cp -v $(BIOS_MEM) $(bin_dir)

clean :
	@rm -fv *.lst
	@rm -fv *.map
	@rm -fv *.o
	@rm -fv $(BIOS)
	@rm -fv $(BIOS_COE)
	@rm -fv $(BIOS_MEM)
