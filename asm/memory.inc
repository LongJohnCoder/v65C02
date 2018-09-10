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
; Program   : BIOS
; File Name : memory.inc
; Project   : v65C02 8-bit Computer
; Author    : Ryan Clarke
; E-mail    : kj6msg@icloud.com
;===============================================================================
; Release History :
;
;    Version     | Date          | Description
;    -------------------------------------------------
;    0.0         | 08/07/2018    | Initial development
;===============================================================================
; Purpose : Include file outlining memory map for the v65C02 8-bit Computer.
;===============================================================================


ZP           = $0000
STACK        = $0100
BIOS_RAM     = $0200
PROG_RAM     = $0300
VRAM         = $8000
VGA_STATUS   = $9000
VGA_CURSL    = $9001
VGA_CURSH    = $9002
SSEG_DIGITS  = $9100
SSEG_DP      = $9101
SSEG_BYTE0   = $9102
SSEG_BYTE1   = $9103
SSEG_BYTE2   = $9104
SSEG_BYTE3   = $9105
UART_STATUS  = $9200
UART_BRGL    = $9201
UART_BRGH    = $9202
UART_TXREG   = $9203
UART_RXREG   = $9204
BIOS_ROM     = $C000
