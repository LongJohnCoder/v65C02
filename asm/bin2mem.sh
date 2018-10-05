#!/bin/bash

#===============================================================================
# Program   : bin2mem
# Author    : Ryan Clarke
# E-mail    : kj6msg@icloud.com
#===============================================================================
# Purpose : Converts a binary file to MEM format for Xilinx FPGA tools.
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

# MEM filename is input filename, stripped of extension, with .mem appended
MEMFILE=${1%.*}'.mem'

echo '// bin2mem conversion of '$1 > $MEMFILE
echo '@0000' >> $MEMFILE
xxd -p -c 1 $1 - >> $MEMFILE

exit 0
