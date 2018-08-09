# v65C02 8-bit Computer for the Nexys 4 DDR

### Description:
Verilog source to implement an 8-bit computer on the [Digilent Nexys 4 DDR](http://store.digilentinc.com/nexys-4-ddr-artix-7-fpga-trainer-board-recommended-for-ece-curriculum/) FPGA development board. The computer has the following specifications:

* Processor
    * MOS 65C02
        * [verilog-65C02](https://github.com/hoglet67/verilog-6502) soft core
        * 16-bit address bus
        * 8-bit data bus
* Memory
    * 32K x 8-bit RAM
        * 8x 36Kb Xilinx Block RAM
    * 16K x 8-bit ROM
        * 4x 36Kb Xilinx Block RAM
* Graphics
    * IBM VGA 80x25 16-color text
        * 720x400 at 70Hz
    * 4K x 8-bit Video RAM
        * 1x 36Kb Xilinx Block RAM
* Keyboard
    * PS/2 Keyboard
* Serial Port
    * UART

The user must generate the system and pixel clocks in the top-level module using the Xilinx Clocking Wizard. Due to copyright restrictions, the clock IP is not included with this repository.

65C02 source code written in [cc65](http://cc65.github.io/cc65/) assembly.

### Legal:
The Verilog sources and ROM BIOS are copyright (C) 2017-2018 Ryan Clarke under the GNU General Public License Version 3.

The original verilog-6502 soft core is copyright (C) Arlet Ottens, and the 65C02 extensions are copyright (C) 2016 David Banks and Ed Spittles.

Character ROM data is derived from the *IBM VGA8* font contained in [The Ultimate Oldschool PC Font Pack](http://int10h.org/oldschool-pc-fonts/) and is copyright (C) 2016 VileR under the Creative Commons Attribution-ShareAlike 4.0 International License.
