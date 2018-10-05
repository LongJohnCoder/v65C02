;===============================================================================
;Copyright (C) 2018 Ryan Clarke
;
;This program is free software (firmware): you can redistribute it and/or modify
;it under the terms of the GNU General Public License as published by
;the Free Software Foundation, either version 3 of the License, or
;(at your option) any later version.
;
;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.
;
;You should have received a copy of the GNU General Public License
;along with this program.  If not, see <http://www.gnu.org/licenses/>.
;===============================================================================

;===============================================================================
; Program   : v65C02 BIOS
; File Name : uart.inc
; Project   : v65C02 8-bit Computer
; Author    : Ryan Clarke
; E-mail    : kj6msg@icloud.com
;===============================================================================
; Purpose : UART constants for the v65C02 BIOS.
;===============================================================================


;= REGISTER BITS ===============================================================

TXBUSY = %00000001
RXFULL = %00000010


;= BAUD RATE GENERATOR VALUES ==================================================

B110     = 28408
B300     = 10416
B600     = 5207
B1200    = 2603
B2400    = 1301
B4800    = 650
B9600    = 325
B14400   = 216
B19200   = 162
B28800   = 108
B38400   = 80
B56000   = 55
B57600   = 53
B115200  = 26
B128000  = 23
B230400  = 13
B256000  = 11
B460800  = 6
B500000  = 5
B512000  = 5
B921600  = 2
B1000000 = 2
B1024000 = 2
B1562500 = 1
