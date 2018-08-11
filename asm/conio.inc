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
; File Name : conio.inc
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
; Purpose : Include file associated with console I/O routines for v65C02 BIOS.
;===============================================================================


.PC02

.IMPORT     cursor_off
.IMPORT     cursor_on
.IMPORT     gotoxy
.IMPORT     puts
