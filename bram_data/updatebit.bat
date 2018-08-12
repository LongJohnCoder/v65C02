@echo off

set PROJDIR="Z:\Documents\NerdLab\Development\FPGA\Nexys 4 DDR\v65C02"
set PATH=%PROJDIR%;C:\Xilinx\Vivado\2017.2\bin;%PATH%

set MMIFILE=bios.mmi
set MEMFILE=bios.mem
set BITFILE=..\v65C02.runs\impl_1\v65C02_Top.bit
set OUTFILE=..\v65C02.runs\impl_1\v65C02_Top_updated.bit

updatemem --force --meminfo %MMIFILE% --data %MEMFILE% --bit %BITFILE% --proc dummy --out %OUTFILE%
