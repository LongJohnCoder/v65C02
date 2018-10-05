#!/bin/bash

#===============================================================================
# Program   : bin2coe
# Author    : Ryan Clarke
# E-mail    : kj6msg@icloud.com
#===============================================================================
# Purpose : Converts a binary file to COE format for Xilinx FPGA tools.
#===============================================================================


# is there an input file?
if [ $# -eq 0 ] ; then
    echo "$0: Usage: $0 file" 1>&2
    exit 1
fi

# does the input file exist?
if [ ! -f $1 ] ; then
    echo "$0: File $1 does not exist, aborting." 1>&2
    exit 1
fi

# is the input file empty?
if [ ! -s $1 ] ; then
    echo "$0: File $1 is empty, aborting." 1>&2
    exit 1
fi

# COE filename is input filename, stripped of extension, with .coe appended
COEFILE=${1%.*}'.coe'

echo "; bin2coe conversion of $1" > $COEFILE
echo "memory_initialization_radix=16;" >> $COEFILE
echo "memory_initialization_vector=" >> $COEFILE
xxd -p -c 1 $1 - | sed 's/$/,/' | sed '$s/,/;/' >> $COEFILE

exit 0
