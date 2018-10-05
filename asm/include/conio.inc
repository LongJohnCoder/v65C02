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
; File Name : conio.inc
; Project   : v65C02 8-bit Computer
; Author    : Ryan Clarke
; E-mail    : kj6msg@icloud.com
;===============================================================================
; Purpose : Console input/output macros for the v65C02 BIOS.
;===============================================================================


;= CONSTANTS ===================================================================

CURS = %00000010                        ; CURS bit mask for VGA STATUS register


;= DISABLE CURSOR ==============================================================
; Turns the cursor off by resetting the CURS bit of the STATUS register to 0.
;
; Parameters: none
; Returns:    none
;
; Destroys: A
;
; Cycles: 10

.macro cursor_off
            lda     #.LOBYTE(~CURS)     ; CURS bit mask off
            and     VGA_STATUS          ; reset CURS bit
            sta     VGA_STATUS          ; write the new VGA STATUS register
.endmacro


;= ENABLE CURSOR ===============================================================
; Turns the cursor on by setting the CURS bit of the STATUS register to 1.
;
; Parameters: none
; Returns:    none
;
; Destroys: A
;
; Cycles: 10

.macro cursor_on
            lda     #CURS               ; CURS bit mask on
            ora     VGA_STATUS          ; set CURS bit
            sta     VGA_STATUS          ; write the new VGA STATUS register
.endmacro
